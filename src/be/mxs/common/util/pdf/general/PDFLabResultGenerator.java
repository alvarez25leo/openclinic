package be.mxs.common.util.pdf.general;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.EndPage2;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Evaluate;
import be.mxs.common.util.system.PdfBarcode;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.LabRequest;
import be.openclinic.medical.RequestedLabAnalysis;
import be.openclinic.medical.LabAnalysis;
import net.admin.User;
import net.admin.AdminPerson;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.*;
import java.net.URL;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFLabResultGenerator extends PDFOfficialBasic {

    // declarations
    protected PdfWriter docWriter;
    private final int pageWidth = 100;
    private String type;
    Vector authorlist;


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFLabResultGenerator(User user, String sProject,String sPrintLanguage){
        this.user = user;
        this.sPrintLanguage=sPrintLanguage;
        this.sProject = sProject;

        doc = new Document();
    }

    public void addHeader(){
    }

    public void addContent(){
    }

    //--- ADD FOOTER ------------------------------------------------------------------------------
    protected void addFooter(String sId){
        int serverid=Integer.parseInt(sId.split("\\.")[0]);
        int transactionid=Integer.parseInt(sId.split("\\.")[1]);
        LabRequest labRequest=new LabRequest(serverid,transactionid);
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        AdminPerson adminPerson=AdminPerson.getAdminPerson(ad_conn,labRequest.getPersonid()+"");
        try {
			ad_conn.close();
		} 
        catch (SQLException e) {
			e.printStackTrace();
		}
        String sFooter=adminPerson.lastname.toUpperCase()+", "+adminPerson.firstname.toUpperCase()+" - "+sId+" - ";
        String sFooter2=ScreenHelper.getTran(null,"labresult", "footer", adminPerson.language);
        Font font = FontFactory.getFont(FontFactory.HELVETICA,7);
        PDFFooter footer = new PDFFooter(sFooter+" - "+sFooter2);
        docWriter.setPageEvent(footer);
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Vector labrequestids,Date since) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        //docWriter.setPageEvent(new EndPage2());
        this.req = req;

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic", 10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            doc.setPageSize(PageSize.A4);
            doc.setMargins(10,10,10,30);
            if(labrequestids.size()>0){
            	addFooter((String)labrequestids.elementAt(0));
            }
            doc.open();

            // add content to document
            for (int n=0;n<labrequestids.size();n++){
                if(n>0){
                    doc.newPage();
                }
                String id =(String)labrequestids.elementAt(n);
                printLabResult(id,since);
            }
		}
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
		}
		finally{
			if(doc!=null) doc.close();
            if(docWriter!=null) docWriter.close();
		}

		if(baosPDF.size() < 1){
			throw new DocumentException("document has no bytes");
		}

		return baosPDF;
	}

    //---- ADD PAGE HEADER ------------------------------------------------------------------------
    private void addPageHeader() throws Exception {
    	// empty
    }

    //--- PRINT LABRESULT -------------------------------------------------------------------------
    protected void printLabResult(String sLabRequestId,Date since){
        try {
        	authorlist= new Vector();
            authorlist.add(-1);
            int serverid=Integer.parseInt(sLabRequestId.split("\\.")[0]);
            int transactionid=Integer.parseInt(sLabRequestId.split("\\.")[1]);
            LabRequest labRequest=new LabRequest(serverid,transactionid);
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            AdminPerson adminPerson=AdminPerson.getAdminPerson(ad_conn,labRequest.getPersonid()+"");
            ad_conn.close();
            printHeader(labRequest,adminPerson);
            printContent(labRequest,adminPerson,since);
            printFooter(labRequest,adminPerson,since);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT FOOTER ----------------------------------------------------------------------------
    private void printFooter(LabRequest labRequest,AdminPerson adminPerson,Date since) throws Exception{
        table = new PdfPTable(100);
        table.setWidthPercentage(100);

        cell=createLabelCourier(" ",10,5,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        table.addCell(cell);
        
        cell=createLabelCourier("*",10,5,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table.addCell(cell);
        
        cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","resultnewerthan",user.person.language)+" "+ScreenHelper.fullDateFormat.format(since),8,90,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        table.addCell(cell);
        
        cell=createLabelCourier(" ",10,5,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        table.addCell(cell);

        cell=createLabelCourier("REV",10,5,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table.addCell(cell);

        cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","revlegenda",user.person.language),8,90,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        table.addCell(cell);
        
        for(int n=1;n<authorlist.size();n++) {
            cell=createLabelCourier("",10,10,Font.NORMAL);
            table.addCell(cell);
            cell=createLabelCourier(n+" = "+MedwanQuery.getInstance().getUserName((int)authorlist.elementAt(n)),8,90,Font.NORMAL);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
        }
        cell=createLabelCourier("\n",100,5,Font.NORMAL);
        
        // Show legenda when bacteriology results available
        if(labRequest.hasBacteriology()){
	        cell=createLabelCourier(" ",10,10,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        
	        cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","legenda",user.person.language),8,90,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
        }
        
        // Print general comment if it exists
        TransactionVO tran = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), labRequest.getTransactionid());
        if(tran!=null && tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_CLINICAL_INFORMATION").length()>0){
	        cell=createLabelCourier(" ",10,10,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        
	        cell=createLabelCourier(MedwanQuery.getInstance().getLabel("web","clinical.information",user.person.language)+": "+tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_CLINICAL_INFORMATION"),10,90,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
        }
        
        if(tran!=null && tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_COMMENT").length()>0){
	        cell=createLabelCourier(" ",10,10,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        
	        cell=createLabelCourier(MedwanQuery.getInstance().getLabel("web","conclusion",user.person.language)+": "+tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_COMMENT"),10,90,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
        }
        
        if(tran!=null && tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_REMARK").length()>0){
	        cell=createLabelCourier(" ",10,10,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        
	        cell=createLabelCourier(MedwanQuery.getInstance().getLabel("web","comment",user.person.language)+": "+tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_REMARK"),10,90,Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
        }
        
        cell=createLabelCourier(" ",10,10,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        table.addCell(cell);
        
        cell=createLabelCourier(" \n"+MedwanQuery.getInstance().getLabel("labresult","validatedby",user.person.language),10,90,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        table.addCell(cell);
        
        Enumeration enumeration = labRequest.getAnalyses().elements();
        Hashtable validators=new Hashtable();
        while(enumeration.hasMoreElements()){
            RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)enumeration.nextElement();
            if(validators.get(requestedLabAnalysis.getFinalvalidation()+"")==null){
                validators.put(requestedLabAnalysis.getFinalvalidation()+"","1");
                
                cell=createLabelCourier(" ",10,10,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                
                cell=createLabelCourier(MedwanQuery.getInstance().getUserName(requestedLabAnalysis.getFinalvalidation()),10,90,Font.BOLD);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
            }
        }
        
        doc.add(table);
    }

	private String extractResistance(String arvs,String arv){
		String resistance="";
		String[] arvlist = arvs.split(";");
		for(int n=0;n<arvlist.length;n++){
			if(arvlist[n].split("=")[0].equalsIgnoreCase(arv) && arvlist[n].split("=").length>1){
				return arvlist[n].split("=")[1];
			}
		}
		return resistance;
	}

    //--- PRINT CONTENT ---------------------------------------------------------------------------
    private void printContent(LabRequest labRequest,AdminPerson adminPerson,Date since) throws Exception{
        Debug.println("\n@@@@@@@@@@@@@@@@@@@@@@@@ printContent @@@@@@@@@@@@@@@@@@@@@@@@");
        
        table = new PdfPTable(100);
        table.setWidthPercentage(100);

        PdfPTable subTable = new PdfPTable(100);
        subTable.setWidthPercentage(100);

        SortedMap groups = new TreeMap();
        Enumeration enumeration = labRequest.getAnalyses().elements();
        while(enumeration.hasMoreElements()){
            RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)enumeration.nextElement();
            if(groups.get(getTran("labanalysis.group",requestedLabAnalysis.getLabgroup()))==null){
                groups.put(getTran("labanalysis.group",requestedLabAnalysis.getLabgroup()),new TreeMap());
            }
            ((TreeMap)groups.get(getTran("labanalysis.group",requestedLabAnalysis.getLabgroup()))).put(requestedLabAnalysis.getAnalysisCode()+"$"+LabAnalysis.labelForCode(requestedLabAnalysis.getAnalysisCode(),user.person.language),requestedLabAnalysis.getAnalysisCode());
        }
        
        Iterator groupsIterator = groups.keySet().iterator();
        int counter=0;
        while(groupsIterator.hasNext()){
        	counter++;        	
            String groupname=(String)groupsIterator.next();
            
            cell=createLabelCourier(" ",12,100,Font.NORMAL);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            subTable.addCell(cell);
            
            cell=createLabelCourier(groupname,12,41,Font.BOLD);
            cell.setBorder(PdfPCell.BOTTOM);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            subTable.addCell(cell);
            
            cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","value",user.person.language),10,15,Font.BOLD);
            cell.setBorder(PdfPCell.BOTTOM);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            subTable.addCell(cell);
            
            if(groupname.equalsIgnoreCase(MedwanQuery.getInstance().getLabel("labanalysis.group", "bacteriology", sPrintLanguage))){
	            cell=createLabelCourier("",10,44,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
            }
            else {
	            cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","unit",user.person.language),10,10,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
	            
	            cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","min",user.person.language),10,10,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
	            
	            cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","max",user.person.language),10,10,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
	            
	            cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labresult","normal",user.person.language),10,10,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
	            
	            cell=createLabelCourier("R",10,1,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
	            
	            cell=createLabelCourier("E",10,1,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
	            
	            cell=createLabelCourier("V",10,2,Font.BOLD);
	            cell.setBorder(PdfPCell.BOTTOM);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            subTable.addCell(cell);
            }
            
            TreeMap analysisList = (TreeMap)groups.get(groupname);
            Iterator analysisEnumeration = analysisList.keySet().iterator();
            while (analysisEnumeration.hasNext()){
                String analysisCode=(String)analysisList.get((String)analysisEnumeration.next());
                if(MedwanQuery.getInstance().getConfigString("hiddenLabAnalyses","").contains("*"+analysisCode+"*")){
                	continue;
                }
                Debug.println("##### analysisCode : "+analysisCode+" #####");
                
                String result="";
                String unit="";
                String min="";
                String max="";
                String normal="";
                String newresult="";
                int aExecuted=0;
                int aRegistered=0;
                int aValidated=0;
                int fonttype=Font.NORMAL;
                
                RequestedLabAnalysis requestedLabAnalysis=(RequestedLabAnalysis)labRequest.getAnalyses().get(analysisCode);
                if(requestedLabAnalysis!=null){
                    unit = requestedLabAnalysis.getResultUnit();
                    min = requestedLabAnalysis.getResultRefMin();
                    max = requestedLabAnalysis.getResultRefMax();
                    aRegistered = Integer.parseInt(ScreenHelper.checkString(requestedLabAnalysis.getResultUserId(),"0"));
                    aExecuted =requestedLabAnalysis.getTechnicalvalidation();
                    aValidated =requestedLabAnalysis.getFinalvalidation();
                    Debug.println("unit  : "+unit);
                    Debug.println("min   : "+min);
                    Debug.println("max   : "+max);
                    
                    if(requestedLabAnalysis.getFinalvalidationdatetime()!=null){
                    	if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getLimitedVisibility()>0 && !user.getAccessRight("labos.limitedvisibility.select")){
                    		result=MedwanQuery.getInstance().getLabel("web","invisible",sPrintLanguage);                	}
                    	else {
                    		result=requestedLabAnalysis.getResultValue();
                    	}
                        Debug.println("result : "+result);
                    	
                        normal=requestedLabAnalysis.getResultModifier();
                        Debug.println("normal : "+normal);
                        
                        if(requestedLabAnalysis.getFinalvalidationdatetime().after(since)){
                            newresult="*";
                            Debug.println("newresult : *");
                        }
                        if(normal.length()>0 && MedwanQuery.getInstance().getConfigString("abnormalModifiers","*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*").indexOf("*"+normal+"*")>-1){
                            fonttype=Font.BOLD;
                        }
                    }
                }
                int labResultFontSize=MedwanQuery.getInstance().getConfigInt("labResultFontSize",8);
                cell=createLabelCourier(newresult,labResultFontSize,5,fonttype);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                subTable.addCell(cell);
                
                cell=createLabelCourier(analysisCode,labResultFontSize,10,fonttype);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                subTable.addCell(cell);
                
                cell=createLabelCourier(LabAnalysis.labelForCode(analysisCode,user.person.language),labResultFontSize,26,fonttype);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                subTable.addCell(cell);
                
                Debug.println("Editor : "+LabAnalysis.getLabAnalysisByLabcode(analysisCode).getEditor());

                //*** 1 - ANTI-BIOGRAM ************************************************************
                if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getEditor().equalsIgnoreCase("antibiogram")){
                	Debug.println("*** 1 - antibiogram ***");
                	
	                //Stel het resultaat samen
                	//Voor elk van de ingevulde kiemen geven we de sensibiliteits-gegevens
                	Map ab = RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode());
                	result="";
                	String result2="";
                	if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getLimitedVisibility()>0 && !user.getAccessRight("labos.limitedvisibility.select")){
                		result=MedwanQuery.getInstance().getLabel("web","invisible",sPrintLanguage);                	}
                	else {
	                	if(ab.get("germ1")!=null && !(ab.get("germ1")+"").equalsIgnoreCase("")){
	                		result+=ab.get("germ1")+"\n";
	                		result2+="\n";
	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME1");
	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
	                			String[] tests = antibiotics.split(",");
	                			for(int n=0;n<tests.length;n++){
	                				if(tests[n].split("=").length==2){
	                					result+="\t"+getAntibiotic(tests[n].split("=")[0])+"\n";
	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], sPrintLanguage)+"\n";
	                				}
	                			}
	                		}
	                	}
	                	if(ab.get("germ2")!=null && !(ab.get("germ2")+"").equalsIgnoreCase("")){
	                		if(result.length()>0){
	                			result+="\n";
	                    		result2+="\n";
	                		}
	                		result2+="\n";
	                		result+=ab.get("germ2")+"\n";
	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME2");
	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
	                			String[] tests = antibiotics.split(",");
	                			for(int n=0;n<tests.length;n++){
	                				if(tests[n].split("=").length==2){
	                					result+="\t"+getAntibiotic(tests[n].split("=")[0])+"\n";
	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], sPrintLanguage)+"\n";
	                				}
	                			}
	                		}
	                	}
	                	if(ab.get("germ3")!=null && !(ab.get("3")+"").equalsIgnoreCase("")){
	                		if(result.length()>0){
	                			result+="\n";
	                    		result2+="\n";
	                		}
	                		result2+="\n";
	                		result+=ab.get("germ3")+"\n";
	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME3");
	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
	                			String[] tests = antibiotics.split(",");
	                			for(int n=0;n<tests.length;n++){
	                				if(tests[n].split("=").length==2){
	                					result+="\t"+getAntibiotic(tests[n].split("=")[0])+"\n";
	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], sPrintLanguage)+"\n";
	                				}
	                			}
	                		}
	                	}
                	}
                	cell=createLabelCourier(result2,labResultFontSize,3,Font.BOLD);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
                	cell=createLabelCourier(result,labResultFontSize,52,Font.NORMAL);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                String sAuthor ="";
	                if(aExecuted>0) {
	                	if(!authorlist.contains(aExecuted)) {
	                		authorlist.add(aExecuted);
	                	}
	                	sAuthor=authorlist.indexOf(aExecuted)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aRegistered>0) {
	                	if(!authorlist.contains(aRegistered)) {
	                		authorlist.add(aRegistered);
	                	}
	                	sAuthor=authorlist.indexOf(aRegistered)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aValidated>0) {
	                	if(!authorlist.contains(aValidated)) {
	                		authorlist.add(aValidated);
	                	}
	                	sAuthor=authorlist.indexOf(aValidated)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,2,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
                	Vector history = requestedLabAnalysis.getResultsHistory(user);
                	for(int n=0;n<history.size();n++){
                		String s = (String)history.elementAt(n);
                		if(s.split("\\|").length>=3){
	                        cell=createLabelCourier(s.split("\\|")[0]+": ",labResultFontSize,41,Font.NORMAL);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        subTable.addCell(cell);
	                        cell=createLabelCourier(s.split("\\|")[2].length()==0?"":s.split("\\|")[2],labResultFontSize,3,Font.NORMAL);
	    	                cell.setBorder(PdfPCell.TOP);
	    	                cell.setBorderColor(innerBorderColor);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        subTable.addCell(cell);
	                        cell=createLabelCourier(s.split("\\|")[1].length()==0?"":s.split("\\|")[1],labResultFontSize,56,Font.NORMAL);
	    	                cell.setBorder(PdfPCell.TOP);
	    	                cell.setBorderColor(innerBorderColor);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        subTable.addCell(cell);
                		}
                	}
                }
                //*** 2 - ANTI-BIOGRAM NEW ********************************************************
                else if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getEditor().equalsIgnoreCase("antibiogramnew")){
                	Debug.println("*** 2 - antibiogramnew ***");
                	
	                //Stel het resultaat samen
                	//Voor elk van de ingevulde kiemen geven we de sensibiliteits-gegevens
                	Map ab = RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode());
                	result="";
                	String result2="";
                	if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getLimitedVisibility()>0 && !user.getAccessRight("labos.limitedvisibility.select")){
                		result=MedwanQuery.getInstance().getLabel("web","invisible",sPrintLanguage);                	}
                	else {
	                	if(ab.get("germ1")!=null && !(ab.get("germ1")+"").equalsIgnoreCase("")){
	                		result+=ab.get("germ1")+"\n";
	                		result2+="\n";
	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME1");
	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
	                			String[] tests = antibiotics.split(",");
	                			for(int n=0;n<tests.length;n++){
	                				if(tests[n].split("=").length==2){
	                					result+="\t"+getAntibioticNew(tests[n].split("=")[0])+"\n";
	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], sPrintLanguage)+"\n";
	                				}
	                			}
	                		}
	                	}
	                	if(ab.get("germ2")!=null && !(ab.get("germ2")+"").equalsIgnoreCase("")){
	                		if(result.length()>0){
	                			result+="\n";
	                    		result2+="\n";
	                		}
	                		result2+="\n";
	                		result+=ab.get("germ2")+"\n";
	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME2");
	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
	                			String[] tests = antibiotics.split(",");
	                			for(int n=0;n<tests.length;n++){
	                				if(tests[n].split("=").length==2){
	                					result+="\t"+getAntibioticNew(tests[n].split("=")[0])+"\n";
	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], sPrintLanguage)+"\n";
	                				}
	                			}
	                		}
	                	}
	                	if(ab.get("germ3")!=null && !(ab.get("3")+"").equalsIgnoreCase("")){
	                		if(result.length()>0){
	                			result+="\n";
	                    		result2+="\n";
	                		}
	                		result2+="\n";
	                		result+=ab.get("germ3")+"\n";
	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME3");
	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
	                			String[] tests = antibiotics.split(",");
	                			for(int n=0;n<tests.length;n++){
	                				if(tests[n].split("=").length==2){
	                					result+="\t"+getAntibioticNew(tests[n].split("=")[0])+"\n";
	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], sPrintLanguage)+"\n";
	                				}
	                			}
	                		}
	                	}
                	}
                	cell=createLabelCourier(result2,labResultFontSize,3,Font.BOLD);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
                	cell=createLabelCourier(result,labResultFontSize,52,Font.NORMAL);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                String sAuthor ="";
	                if(aExecuted>0) {
	                	if(!authorlist.contains(aExecuted)) {
	                		authorlist.add(aExecuted);
	                	}
	                	sAuthor=authorlist.indexOf(aExecuted)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aRegistered>0) {
	                	if(!authorlist.contains(aRegistered)) {
	                		authorlist.add(aRegistered);
	                	}
	                	sAuthor=authorlist.indexOf(aRegistered)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aValidated>0) {
	                	if(!authorlist.contains(aValidated)) {
	                		authorlist.add(aValidated);
	                	}
	                	sAuthor=authorlist.indexOf(aValidated)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,2,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                Vector history = requestedLabAnalysis.getResultsHistory(user);
                	for(int n=0;n<history.size();n++){
                		String s = (String)history.elementAt(n);
                		if(s.split("\\|").length>=3){
	                        cell=createLabelCourier(s.split("\\|")[0]+": ",labResultFontSize,41,Font.NORMAL);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        subTable.addCell(cell);
	                        cell=createLabelCourier(s.split("\\|")[2].length()==0?"":s.split("\\|")[2],labResultFontSize,3,Font.NORMAL);
	    	                cell.setBorder(PdfPCell.TOP);
	    	                cell.setBorderColor(innerBorderColor);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        subTable.addCell(cell);
	                        cell=createLabelCourier(s.split("\\|")[1].length()==0?"":s.split("\\|")[1],labResultFontSize,56,Font.NORMAL);
	    	                cell.setBorder(PdfPCell.TOP);
	    	                cell.setBorderColor(innerBorderColor);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        subTable.addCell(cell);
                		}
                	}
                }
                //*** 2 - ANTI-VIROGRAM  ********************************************************
                else if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getEditor().equalsIgnoreCase("antivirogram")){
                	Debug.println("*** 2.1 - antivirogram ***");
                	
                	result="";
                	if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getLimitedVisibility()>0 && !user.getAccessRight("labos.limitedvisibility.select")){
                		result=MedwanQuery.getInstance().getLabel("web","invisible",sPrintLanguage);                	}
                	else {
                		
                    	cell=createLabelCourier(MedwanQuery.getInstance().getLabel("web", "arv.coltitle1", sPrintLanguage),labResultFontSize,18,Font.BOLD);
    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	                subTable.addCell(cell);
                    	cell=createLabelCourier(MedwanQuery.getInstance().getLabel("web", "arv.coltitle2", sPrintLanguage),labResultFontSize,18,Font.BOLD);
    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	                subTable.addCell(cell);
                    	cell=createLabelCourier(MedwanQuery.getInstance().getLabel("web", "arv.coltitle3", sPrintLanguage),labResultFontSize,19,Font.BOLD);
    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	                subTable.addCell(cell);
    	                
	                	cell=createLabelCourier("", labResultFontSize, 45, fonttype);
		                subTable.addCell(cell);

    	                PdfPTable tblResistance = new PdfPTable(20);
    	                boolean binitialized=false;
    	                for(int i=0;i<MedwanQuery.getInstance().getConfigInt("maxARVlines",12);i++){
    	                	String resistance = extractResistance(requestedLabAnalysis.getResultValue(), "a."+i);
    	                	if(resistance.length()>0){
    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arva", i+"", sPrintLanguage),labResultFontSize,5,Font.BOLD);
    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	    	                tblResistance.addCell(cell);
    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvresistance", resistance, sPrintLanguage),labResultFontSize,15,Font.NORMAL);
    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	    	                tblResistance.addCell(cell);
    	    	                binitialized=true;
    	                	}
    	                }
    	                if(!binitialized){
	                		cell=createLabelCourier("-",labResultFontSize,20,Font.NORMAL);
	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	                tblResistance.addCell(cell);
    	                }
    	                cell = new PdfPCell(tblResistance);
    	                cell.setColspan(18);
    	                cell.setBorder(PdfPCell.NO_BORDER);
    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	                subTable.addCell(cell);
    	                
    	                tblResistance = new PdfPTable(20);
    	                binitialized=false;
    	                for(int i=0;i<MedwanQuery.getInstance().getConfigInt("maxARVlines",12);i++){
    	                	String resistance = extractResistance(requestedLabAnalysis.getResultValue(), "b."+i);
    	                	if(resistance.length()>0){
    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvb", i+"", sPrintLanguage),labResultFontSize,5,Font.BOLD);
    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	    	                tblResistance.addCell(cell);
    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvresistance", resistance, sPrintLanguage),labResultFontSize,15,Font.NORMAL);
    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	    	                tblResistance.addCell(cell);
    	    	                binitialized=true;
    	                	}
    	                }
    	                if(!binitialized){
	                		cell=createLabelCourier("-",labResultFontSize,20,Font.NORMAL);
	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	                tblResistance.addCell(cell);
    	                }
    	                cell = new PdfPCell(tblResistance);
    	                cell.setColspan(18);
    	                cell.setBorder(PdfPCell.NO_BORDER);
    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	                subTable.addCell(cell);
    	                
    	                tblResistance = new PdfPTable(20);
    	                binitialized=false;
    	                for(int i=0;i<MedwanQuery.getInstance().getConfigInt("maxARVlines",12);i++){
    	                	String resistance = extractResistance(requestedLabAnalysis.getResultValue(), "c."+i);
    	                	if(resistance.length()>0){
    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvc", i+"", sPrintLanguage),labResultFontSize,5,Font.BOLD);
    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	    	                tblResistance.addCell(cell);
    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvresistance", resistance, sPrintLanguage),labResultFontSize,15,Font.NORMAL);
    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	    	                tblResistance.addCell(cell);
    	    	                binitialized=true;
    	                	}
    	                }
    	                if(!binitialized){
	                		cell=createLabelCourier("-",labResultFontSize,20,Font.NORMAL);
	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	                tblResistance.addCell(cell);
    	                }
    	                cell = new PdfPCell(tblResistance);
    	                cell.setColspan(19);
    	                cell.setBorder(PdfPCell.NO_BORDER);
    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
    	                subTable.addCell(cell);
                	}
                	
	                Vector history = requestedLabAnalysis.getResultsHistory(user);
                	for(int n=0;n<history.size();n++){
                		String s = (String)history.elementAt(n);
                		if(s.split("\\|").length>=1){
                			cell=createLabelCourier(s.split("\\|")[0]+": ",labResultFontSize,45,Font.NORMAL);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        subTable.addCell(cell);
                			if(s.split("\\|").length>=2 && s.split("\\|")[1].length()>0){
		                        PdfPTable tblResistance = new PdfPTable(20);
		                        for(int q=0;q<s.split("\\|")[1].split(";").length;q++){
	    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arva",s.split("\\|")[1].split(";")[q].split("=")[0] , sPrintLanguage),labResultFontSize,5,Font.BOLD);
	    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	    	                tblResistance.addCell(cell);
	    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvresistance", s.split("\\|")[1].split(";")[q].split("=")[1], sPrintLanguage),labResultFontSize,15,Font.NORMAL);
	    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	    	                tblResistance.addCell(cell);
		                        }
		    	                cell = new PdfPCell(tblResistance);
		    	                cell.setColspan(18);
		    	                cell.setBorder(PdfPCell.TOP);
		    	                cell.setBorderColor(innerBorderColor);
		    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		    	                subTable.addCell(cell);
                			}
                			else {
		    	                cell = createValueCell("-");
		    	                cell.setColspan(18);
		    	                cell.setBorder(PdfPCell.TOP);
		    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
		    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		    	                subTable.addCell(cell);
                			}
                			if(s.split("\\|").length>=3 && s.split("\\|")[2].length()>0){
                				PdfPTable tblResistance = new PdfPTable(20);
		                        for(int q=0;q<s.split("\\|")[2].split(";").length;q++){
	    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvb",s.split("\\|")[2].split(";")[q].split("=")[0] , sPrintLanguage),labResultFontSize,5,Font.BOLD);
	    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	    	                tblResistance.addCell(cell);
	    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvresistance", s.split("\\|")[2].split(";")[q].split("=")[1], sPrintLanguage),labResultFontSize,15,Font.NORMAL);
	    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	    	                tblResistance.addCell(cell);
		                        }
		    	                cell = new PdfPCell(tblResistance);
		    	                cell.setColspan(18);
		    	                cell.setBorder(PdfPCell.TOP);
		    	                cell.setBorderColor(innerBorderColor);
		    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		    	                subTable.addCell(cell);
                			}
                			else {
		    	                cell = createValueCell("-");
		    	                cell.setColspan(18);
		    	                cell.setBorder(PdfPCell.TOP);
		    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
		    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		    	                subTable.addCell(cell);
                			}
                			if(s.split("\\|").length>=4 && s.split("\\|")[3].length()>0){
                				PdfPTable tblResistance = new PdfPTable(20);
		                        for(int q=0;q<s.split("\\|")[3].split(";").length;q++){
	    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvc",s.split("\\|")[3].split(";")[q].split("=")[0] , sPrintLanguage),labResultFontSize,5,Font.BOLD);
	    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	    	                tblResistance.addCell(cell);
	    	                		cell=createLabelCourier(MedwanQuery.getInstance().getLabel("arvresistance", s.split("\\|")[3].split(";")[q].split("=")[1], sPrintLanguage),labResultFontSize,15,Font.NORMAL);
	    	    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	    	    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	    	    	                tblResistance.addCell(cell);
		                        }
		    	                cell = new PdfPCell(tblResistance);
		    	                cell.setColspan(19);
		    	                cell.setBorder(PdfPCell.TOP);
		    	                cell.setBorderColor(innerBorderColor);
		    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		    	                subTable.addCell(cell);
                			}
                			else {
		    	                cell = createValueCell("-");
		    	                cell.setColspan(19);
		    	                cell.setBorder(PdfPCell.TOP);
		    	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
		    	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		    	                subTable.addCell(cell);
                			}
                		}
                	}
                	
                }
                //*** 3 - NUMERIC *****************************************************************
                else if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getEditor().startsWith("numeric")){
                	Debug.println("*** 3 - numeric ***");
                	
	                cell=createLabelCourier(result,labResultFontSize,15,Font.BOLD);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                cell=createLabelCourier(unit,labResultFontSize,10,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                cell=createLabelCourier(min,labResultFontSize,10,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                cell=createLabelCourier(max,labResultFontSize,10,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);

                    if(normal.length()==0){
                    	Debug.println("'normal' is empty"); 
                    	
                    	//We proberen na te gaan of de waarde buiten de grenzen valt
                    	try{
	                        double iResult = Double.parseDouble(result.replaceAll(",", "\\."));
	                        double iMin = Double.parseDouble(min.replaceAll(",", "\\."));
	                        double iMax = Double.parseDouble(max.replaceAll(",", "\\."));

	                        Debug.println("iResult : "+iResult);
	                        Debug.println("iMin    : "+iMin);
	                        Debug.println("iMax    : "+iMax);
	                        
	                        if ((iResult >= iMin)&&(iResult <= iMax)){
	                            normal = "n";
	                        }
	                        else {
	                            double iAverage = (iMax-iMin);
	
	                            if (iResult > iMax+iAverage*2){
	                                normal = "+++";
	                            }
	                            else if (iResult > iMax + iAverage){
	                                normal = "++";
	                            }
	                            else if (iResult > iMax){
	                                normal = "+";
	                            }
	                            else if (iResult < iMin - iAverage*2){
	                                normal = "---";
	                            }
	                            else if (iResult < iMin - iAverage){
	                                normal = "--";
	                            }
	                            else if (iResult < iMin){
	                                normal = "-";
	                            }
	                        }
	                        
	                        Debug.println("normal  : "+normal); 
                    	}
                    	catch(Exception e2){
                    		//e2.printStackTrace();
                    	}
                    }
                    
                	Debug.println("normal : "+normal); 
                    
	                cell=createLabelCourier(normal,labResultFontSize,10,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                String sAuthor ="";
	                if(aExecuted>0) {
	                	if(!authorlist.contains(aExecuted)) {
	                		authorlist.add(aExecuted);
	                	}
	                	sAuthor=authorlist.indexOf(aExecuted)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aRegistered>0) {
	                	if(!authorlist.contains(aRegistered)) {
	                		authorlist.add(aRegistered);
	                	}
	                	sAuthor=authorlist.indexOf(aRegistered)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aValidated>0) {
	                	if(!authorlist.contains(aValidated)) {
	                		authorlist.add(aValidated);
	                	}
	                	sAuthor=authorlist.indexOf(aValidated)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,2,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                // comment
                	if(ScreenHelper.checkString(requestedLabAnalysis.getResultComment()).length()>0){
	                	cell=createLabelCourier("", 8, 41, fonttype);
		                subTable.addCell(cell);
		                
	                	cell=createLabelCourier(requestedLabAnalysis.getResultComment(),labResultFontSize,59,Font.NORMAL);
		                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		                subTable.addCell(cell);
                	}

	                //Nu gaan we na of er een extra lijn met commentaar moet worden afgedrukt
	                if(!MedwanQuery.getInstance().getLabel("labanalysis.refcomment",analysisCode,user.person.language).equalsIgnoreCase(analysisCode)){
	                	cell=createLabelCourier("", labResultFontSize, 41, fonttype);
		                subTable.addCell(cell);
		                
	                	cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labanalysis.refcomment",analysisCode,user.person.language),labResultFontSize,59,Font.NORMAL);
		                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		                subTable.addCell(cell);
	                }
                	Vector history = requestedLabAnalysis.getResultsHistory(user);
                	for(int n=0;n<history.size();n++){
                		String s = (String)history.elementAt(n);
                        cell=createLabelCourier(s.split("\\|")[0]+": ",labResultFontSize,41,Font.NORMAL);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                        subTable.addCell(cell);
                        cell=createLabelCourier(s.split("\\|").length<2?"":s.split("\\|")[1],labResultFontSize,59,Font.NORMAL);
    	                cell.setBorder(PdfPCell.TOP);
    	                cell.setBorderColor(innerBorderColor);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                        subTable.addCell(cell);
                	}
                }
                //*** 4 - CALCULATED *****************************************************************
                else if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getEditor().equalsIgnoreCase("calculated")){
            		LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(analysisCode);
            		if(analysis.getEditorparameters().startsWith("OP:CONC|")){
            			//Especially useful for phenotypes
            			result="";
            			String s=analysis.getEditorparameters().replaceAll("OP:CONC\\|", "");
            			String[] sPars = s.split(",");
            			for(int n=0;n<sPars.length;n++){
            				if(labRequest.getAnalyses().get(sPars[n].replaceAll("@", ""))!=null){
    	            			result+=((RequestedLabAnalysis)labRequest.getAnalyses().get(sPars[n].replaceAll("@", ""))).getResultValue();
            				}
            				else{
            					result="";
            					break;
            				}
            			}
            		}
            		else {
	                	String expression = analysis.getEditorparametersParameter("OP").split("\\|")[0];
	            		Hashtable pars = new Hashtable();
	            		if(analysis.getEditorparameters().split("|").length>0){
	            			String[] sPars = analysis.getEditorparametersParameter("OP").split("\\|")[1].replaceAll(" ", "").split(",");
	            			for(int n=0;n<sPars.length;n++){
		        				try{
		            				pars.put(sPars[n],((RequestedLabAnalysis)labRequest.getAnalyses().get(sPars[n].replaceAll("@", ""))).getResultValue());
		        				}
		        				catch(Exception p){}
	            			}
	            		}
						try{
							result = Evaluate.evaluate(expression, pars,analysis.getEditorparametersParameter("OP").split("\\|").length>2?Integer.parseInt(analysis.getEditorparametersParameter("OP").replaceAll(" ", "").split("\\|")[2]):5);
						}
						catch(Exception e){
	                		result = "?";
						}
            		}
                	Debug.println("*** 3 - numeric ***");
                	
	                cell=createLabelCourier(result,labResultFontSize,15,Font.BOLD);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                cell=createLabelCourier(unit,labResultFontSize,10,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                cell=createLabelCourier(min,labResultFontSize,10,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                cell=createLabelCourier(max,labResultFontSize,10,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);

                    if(normal.length()==0){
                    	Debug.println("'normal' is empty"); 
                    	
                    	//We proberen na te gaan of de waarde buiten de grenzen valt
                    	try{
	                        double iResult = Double.parseDouble(result.replaceAll(",", "\\."));
	                        double iMin = Double.parseDouble(min.replaceAll(",", "\\."));
	                        double iMax = Double.parseDouble(max.replaceAll(",", "\\."));

	                        Debug.println("iResult : "+iResult);
	                        Debug.println("iMin    : "+iMin);
	                        Debug.println("iMax    : "+iMax);
	                        
	                        if ((iResult >= iMin)&&(iResult <= iMax)){
	                            normal = "n";
	                        }
	                        else {
	                            double iAverage = (iMax-iMin);
	
	                            if (iResult > iMax+iAverage*2){
	                                normal = "+++";
	                            }
	                            else if (iResult > iMax + iAverage){
	                                normal = "++";
	                            }
	                            else if (iResult > iMax){
	                                normal = "+";
	                            }
	                            else if (iResult < iMin - iAverage*2){
	                                normal = "---";
	                            }
	                            else if (iResult < iMin - iAverage){
	                                normal = "--";
	                            }
	                            else if (iResult < iMin){
	                                normal = "-";
	                            }
	                        }
	                        
	                        Debug.println("normal  : "+normal); 
                    	}
                    	catch(Exception e2){
                    		//e2.printStackTrace();
                    	}
                    }
                    
                	Debug.println("normal : "+normal); 
                    
	                cell=createLabelCourier(normal,labResultFontSize,14,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                // comment
                	if(ScreenHelper.checkString(requestedLabAnalysis.getResultComment()).length()>0){
	                	cell=createLabelCourier("", labResultFontSize, 42, fonttype);
		                subTable.addCell(cell);
		                
	                	cell=createLabelCourier(requestedLabAnalysis.getResultComment(),labResultFontSize,58,Font.NORMAL);
		                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		                subTable.addCell(cell);
                	}

	                //Nu gaan we na of er een extra lijn met commentaar moet worden afgedrukt
	                if(!MedwanQuery.getInstance().getLabel("labanalysis.refcomment",analysisCode,user.person.language).equalsIgnoreCase(analysisCode)){
	                	cell=createLabelCourier("", labResultFontSize, 41, fonttype);
		                subTable.addCell(cell);
		                
	                	cell=createLabelCourier(MedwanQuery.getInstance().getLabel("labanalysis.refcomment",analysisCode,user.person.language),labResultFontSize,59,Font.NORMAL);
		                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
		                subTable.addCell(cell);
	                }
                }
                else {
                	cell=createLabelCourier(result,labResultFontSize,55,Font.NORMAL);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
                	
	                String sAuthor ="";
	                if(aExecuted>0) {
	                	if(!authorlist.contains(aExecuted)) {
	                		authorlist.add(aExecuted);
	                	}
	                	sAuthor=authorlist.indexOf(aExecuted)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aRegistered>0) {
	                	if(!authorlist.contains(aRegistered)) {
	                		authorlist.add(aRegistered);
	                	}
	                	sAuthor=authorlist.indexOf(aRegistered)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,1,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                sAuthor ="";
	                if(aValidated>0) {
	                	if(!authorlist.contains(aValidated)) {
	                		authorlist.add(aValidated);
	                	}
	                	sAuthor=authorlist.indexOf(aValidated)+"";
	                }
	                cell=createLabelCourier(sAuthor,labResultFontSize,2,fonttype);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                subTable.addCell(cell);
	                
	                if(ScreenHelper.checkString(requestedLabAnalysis.getResultComment()).length()>0){
	                	if(LabAnalysis.getLabAnalysisByLabcode(analysisCode).getEditor().equalsIgnoreCase("listbox")){
	                		for(int n=0;n<requestedLabAnalysis.getResultComment().split(";").length;n++){
	                			String resultcommentpart=requestedLabAnalysis.getResultComment().split(";")[n];
	                			if(resultcommentpart.split("=").length>1 && resultcommentpart.split("=")[1].length()>0 ){
				                	cell=createLabelCourier("", labResultFontSize, 41, fonttype);
					                subTable.addCell(cell);
				                	cell=createLabelCourier(resultcommentpart.replaceAll("=", ": "),labResultFontSize,59,Font.NORMAL);
					                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
					                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
					                subTable.addCell(cell);
	                			}
	                		}
	                	}
	                	else {
		                	cell=createLabelCourier("", labResultFontSize, 41, fonttype);
			                subTable.addCell(cell);
		                	cell=createLabelCourier(requestedLabAnalysis.getResultComment(),labResultFontSize,59,Font.NORMAL);
			                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
			                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
			                subTable.addCell(cell);
	                	}
                	}

                	Vector history = requestedLabAnalysis.getResultsHistory(user);
                	for(int n=0;n<history.size();n++){
                		String s = (String)history.elementAt(n);
                        cell=createLabelCourier(s.split("\\|")[0]+": ",labResultFontSize,41,Font.NORMAL);
    	                cell.setBorder(PdfPCell.TOP);
    	                cell.setBorderColor(innerBorderColor);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                        subTable.addCell(cell);
                        cell=createLabelCourier(s.split("\\|").length<=1?"":s.split("\\|")[1],labResultFontSize,59,Font.NORMAL);
    	                cell.setBorder(PdfPCell.TOP);
    	                cell.setBorderColor(innerBorderColor);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                        subTable.addCell(cell);
                	}
	                
                }
            }
            
            cell=createBorderlessCell(5);
            table.addCell(cell);
            
            cell=createBorderlessCell(90);
            cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+(counter==1?PdfPCell.TOP:0)+(counter==groups.keySet().size()?PdfPCell.BOTTOM:0));
            cell.addElement(subTable);
            table.addCell(cell);
            
            cell=createBorderlessCell(5);
            table.addCell(cell);
            
            subTable = new PdfPTable(100);
            subTable.setWidthPercentage(100);
        }
        
        doc.add(table);
    }
    
    //--- GET ANTIBIOTIC NEW ----------------------------------------------------------------------
    private String getAntibioticNew(String id){
    	if(id.equalsIgnoreCase("1")){
    		return ScreenHelper.getTranNoLink("antibiotics","pen",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("2")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","oxa",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("3")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","amp",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("4")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","amc",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("5")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","czo",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("6")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","mec",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("7")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","ctx",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("8")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","gen",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("9")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","amk",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("10")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","chl",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("11")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","tcy",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("12")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","col",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("13")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","ery",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("14")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","lin",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("15")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","pri",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("16")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","sxt",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("17")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","nit",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("18")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","nal",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("19")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","cip",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("20")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","ipm",sPrintLanguage);
    	}
    	else {
    		try{
    			int abid = Integer.parseInt(id);
    			if(abid>20){
    				return MedwanQuery.getInstance().getLabel("antibiotics",MedwanQuery.getInstance().getConfigString("extraAntibiotics","").split(";").length>Integer.parseInt(id)-20?MedwanQuery.getInstance().getConfigString("extraAntibiotics","").split(";")[Integer.parseInt(id)-21]:"",sPrintLanguage);
    			}
    	    	else {
    	    		return "?";
    	    	}
    		}
    		catch(Exception e){
	    		return "?";
    		}
    	}
    }
    
    //--- GET ANTIBIOTIC --------------------------------------------------------------------------
    private String getAntibiotic(String id){
    	if(id.equalsIgnoreCase("1")){
    		return MedwanQuery.getInstance().getLabel("web","penicillineg",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("2")){
    		return MedwanQuery.getInstance().getLabel("web","oxacilline",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("3")){
    		return MedwanQuery.getInstance().getLabel("web","ampicilline",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("4")){
    		return MedwanQuery.getInstance().getLabel("web","amoxicacclavu",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("5")){
    		return MedwanQuery.getInstance().getLabel("web","cefalotine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("6")){
    		return MedwanQuery.getInstance().getLabel("web","mecillinam",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("7")){
    		return MedwanQuery.getInstance().getLabel("web","cefotaxime",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("8")){
    		return MedwanQuery.getInstance().getLabel("web","gentamicine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("9")){
    		return MedwanQuery.getInstance().getLabel("web","amikacine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("10")){
    		return MedwanQuery.getInstance().getLabel("web","chloramphenicol",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("11")){
    		return MedwanQuery.getInstance().getLabel("web","tetracycline",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("12")){
    		return MedwanQuery.getInstance().getLabel("web","colistine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("13")){
    		return MedwanQuery.getInstance().getLabel("web","erythromycine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("14")){
    		return MedwanQuery.getInstance().getLabel("web","lincomycine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("15")){
    		return MedwanQuery.getInstance().getLabel("web","pristinamycine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("16")){
    		return MedwanQuery.getInstance().getLabel("web","cotrimoxazole",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("17")){
    		return MedwanQuery.getInstance().getLabel("web","nitrofurane",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("18")){
    		return MedwanQuery.getInstance().getLabel("web","acnalidixique",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("19")){
    		return MedwanQuery.getInstance().getLabel("web","ciprofloxacine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("20")){
    		return MedwanQuery.getInstance().getLabel("web","imipenem",sPrintLanguage);
    	}
    	else {
    		try{
    			int abid = Integer.parseInt(id);
    			if(abid>20){
    	    		return MedwanQuery.getInstance().getLabel("web","ab"+(Integer.parseInt(id)-20),sPrintLanguage);
    			}
    	    	else {
    	    		return "?";
    	    	}
    		}
    		catch(Exception e){
	    		return "?";
    		}
    	}
    }
    
    //--- PRINT HEADER ----------------------------------------------------------------------------
    private void printHeader(LabRequest labRequest,AdminPerson adminPerson) throws Exception{
        Encounter encounter = Encounter.getActiveEncounter(adminPerson.personid);
        table = new PdfPTable(100);
        table.setWidthPercentage(100);
        
        //Hospital logo
        try{
	        Image image =Image.getInstance(new URL(url+contextPath+projectDir+"/_img/logo_patientcard.gif"));
	        image.scaleToFit(72*400/254,144);
	        cell = new PdfPCell(image);
        }
        catch(Exception e){
        	cell=emptyCell();
        }
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setColspan(25);
        cell.setPadding(10);
        table.addCell(cell);
        
        PdfPTable table2 = new PdfPTable(1);
        table2.setWidthPercentage(100);
        
        //Label1
        cell=createLabel(ScreenHelper.getTranNoLink("labresult","title1",user.person.language).replaceAll("title1", ""),MedwanQuery.getInstance().getConfigInt("labtitle1size",14),1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table2.addCell(cell);
        
        //Label2
        cell=createLabel(ScreenHelper.getTranNoLink("labresult","title2",user.person.language).replaceAll("title2", ""),MedwanQuery.getInstance().getConfigInt("labtitle2size",10),1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table2.addCell(cell);
        
        //Label3        
        cell=createLabel(ScreenHelper.getTranNoLink("labresult","title3",user.person.language).replaceAll("title3", ""),MedwanQuery.getInstance().getConfigInt("labtitle3size",10),1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table2.addCell(cell);
        
        //Titel
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","title",user.person.language),14,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table2.addCell(cell);
        
        cell=createBorderlessCell(45);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.addElement(table2);
        table.addCell(cell);
        
        table2 = new PdfPTable(1);
        table2.setWidthPercentage(100);
       
        //*** barcode ***
        Image image = PdfBarcode.getBarcode("7"+labRequest.getTransactionid(), docWriter);
        cell = new PdfPCell(image);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setColspan(1);
        table2.addCell(cell);

        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","encounter.id",user.person.language)+": "+(encounter!=null?encounter.getUid():""),10,1,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table2.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","request.id",user.person.language)+": "+labRequest.getTransactionid(),10,1,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table2.addCell(cell);

        cell=createBorderlessCell(25);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.addElement(table2);
        table.addCell(cell);

        cell=createBorderlessCell(5);
        table.addCell(cell);

        //Patient Header
        PdfPTable subTable = new PdfPTable(100);
        subTable.setWidthPercentage(100);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","patient",user.person.language),10,100,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","name",user.person.language),8,10,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(adminPerson.firstname+" "+adminPerson.lastname,10,55,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","dateofbirth",user.person.language),8,10,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(adminPerson.dateOfBirth,10,25,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","gender",user.person.language),8,10,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(adminPerson.gender,10,5,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","personid",user.person.language),8,10,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(adminPerson.personid,10,15,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","archiveid",user.person.language),8,10,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(adminPerson.getID("archiveFileCode"),10,15,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","nationalid",user.person.language),8,10,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(adminPerson.getID("natreg")!=null?(String)adminPerson.getID("natreg"):"",10,25,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);

        cell=createBorderlessCell(5);
        table.addCell(cell);
        cell=createBorderlessCell(90);
        cell.setBorder(PdfPCell.BOX);
        cell.addElement(subTable);
        table.addCell(cell);
        cell=createBorderlessCell(5);
        table.addCell(cell);

        //Service Header
        subTable = new PdfPTable(100);
        subTable.setWidthPercentage(100);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","request",user.person.language),10,100,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","prescriber",user.person.language),8,20,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        TransactionVO tran = MedwanQuery.getInstance().loadTransaction(labRequest.getServerid(), labRequest.getTransactionid());
        String sPrescriber="";
        if(tran!=null){
        	ItemVO pItem = tran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_PRESCRIBER");
        	if(pItem!=null){
        		sPrescriber=pItem.getValue();
        	}
        }
        cell=createLabel(sPrescriber,10,45,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","requestdate",user.person.language),8,15,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(ScreenHelper.fullDateFormat.format(labRequest.getRequestdate()),10,20,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","service",user.person.language),8,20,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(labRequest.getServicename(),10,45,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(MedwanQuery.getInstance().getLabel("labresult","reportdate",user.person.language),8,15,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        cell=createLabel(ScreenHelper.fullDateFormat.format(new Date()),10,20,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        subTable.addCell(cell);
        
        HashSet samplereceptions = labRequest.getSampleReceptions(sPrintLanguage);
        Iterator i = samplereceptions.iterator();
        while(i.hasNext()) {
        	String key=(String)i.next();
	        cell=createLabel(MedwanQuery.getInstance().getLabel("web","samplereceivedby",user.person.language)+"\n["+key.split(";")[2]+"]",8,20,Font.ITALIC);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        subTable.addCell(cell);
	        cell=createLabel(User.getFullUserName(key.split(";")[0]),10,45,Font.BOLD);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        subTable.addCell(cell);
	        cell=createLabel(MedwanQuery.getInstance().getLabel("web","sampledate",user.person.language),8,15,Font.ITALIC);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        subTable.addCell(cell);
	        cell=createLabel(key.split(";")[1],10,20,Font.BOLD);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        subTable.addCell(cell);
        }
        

        cell=createBorderlessCell(5);
        table.addCell(cell);
        cell=createBorderlessCell(90);
        cell.setBorder(PdfPCell.BOX);
        cell.addElement(subTable);
        table.addCell(cell);
        cell=createBorderlessCell(5);
        table.addCell(cell);

        cell=createLabel(" ",8,100,Font.ITALIC);
        table.addCell(cell);

        doc.add(table);
    }

    
    //################################### UTILITY FUNCTIONS #######################################

    //--- CREATE UNDERLINED CELL ------------------------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE))); // underlined
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- PRINT VECTOR ----------------------------------------------------------------------------
    protected String printVector(Vector vector){
        StringBuffer buf = new StringBuffer();
        for(int i=0; i<vector.size(); i++){
            buf.append(vector.get(i)).append(", ");
        }

        // remove last comma
        if(buf.length() > 0) buf.deleteCharAt(buf.length()-2);

        return buf.toString();
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabelCourier(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.COURIER,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

}
