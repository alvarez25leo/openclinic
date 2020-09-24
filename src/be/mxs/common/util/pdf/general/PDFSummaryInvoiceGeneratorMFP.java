package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.PdfBarcode;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import be.openclinic.adt.Encounter;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

import org.hnrw.report.Report_Identification;

public class PDFSummaryInvoiceGeneratorMFP extends PDFInvoiceGenerator {
    String sProforma = "no";

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFSummaryInvoiceGeneratorMFP(User user, AdminPerson patient, String sProject, String sPrintLanguage){
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();
    }

    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Invoice inv) throws Exception {
    	return null;
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sInvoiceUid) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

        // reset totals
        this.patientDebetTotal = 0;
        this.insurarDebetTotal = 0;
        this.creditTotal = 0;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			if(MedwanQuery.getInstance().getConfigString("invoicePaperFormat","A4").equalsIgnoreCase("A5")){
				doc.setPageSize(PageSize.A5);
			}
			else{
				doc.setPageSize(PageSize.A4);
			}
			doc.setMargins(MedwanQuery.getInstance().getConfigInt("patientInvoiceMarginLeft",new Float(doc.leftMargin()).intValue()), MedwanQuery.getInstance().getConfigInt("patientInvoiceMarginRight",new Float(doc.rightMargin()).intValue()), MedwanQuery.getInstance().getConfigInt("patientInvoiceMarginTop",new Float(doc.topMargin()).intValue()), MedwanQuery.getInstance().getConfigInt("patientInvoiceMarginBottom",new Float(doc.bottomMargin()).intValue()));
            
			
			// get specified invoice
            SummaryInvoice invoice = SummaryInvoice.get(sInvoiceUid);
            addMFPFooter(invoice);

            doc.open();

        	//Find services
        	Hashtable services = new Hashtable();
        	Vector debets = invoice.getAllDebets();
    		String serviceuid="";
        	for(int n=0;n<debets.size();n++){
        		Debet debet = (Debet)debets.elementAt(n);
        		if(debet!=null & debet.getServiceUid()!=null){
        			serviceuid=debet.getServiceUid();
        		}
        		else {
        			serviceuid=debet.getEncounter().getServiceUID();
        		}
        		if(services.get(serviceuid)==null){
        			services.put(serviceuid, "1");
        			Debug.println("Added service UID: "+serviceuid);
        		}
        	}
            
            int subinvoices=0;
            
            //get list of patientinsurances
            Vector insurances = Insurance.findInsurances("", "", "", "", "", patient.personid);
            for(int n=0;n<insurances.size();n++){
                Insurance insurance = (Insurance)insurances.elementAt(n);
                if(insurance!=null){
            		Debug.println("Analyzing insurar UID: "+insurance.getInsurarUid());
                    debets=invoice.getDebetsForInsurance(insurance.getUid());
                	Debug.println("Found "+debets.size()+" debets");
                    if(debets.size()>0){
                    	Debug.println("Running through "+services.size()+" services");
                        Enumeration eServices = services.keys();
                    	while(eServices.hasMoreElements()){
                    		serviceuid = (String)eServices.nextElement();
                    		Debug.println("Analyzing service: "+serviceuid);
                    		Service service = Service.getService(serviceuid);
                    		if(service!=null && service.costcenter!=null && service.costcenter.equalsIgnoreCase("H")){
                        		Debug.println("Costcenter = H");
                            	boolean hasDebets=false;
                    			for(int i=0;i<debets.size();i++){
                            		Debet debet = (Debet)debets.elementAt(i);
                            		if(debet!=null && debet.getServiceUid()!=null){
                            			if(debet.getServiceUid().equalsIgnoreCase(service.code)){
                            				hasDebets=true;
                            				break;
                            			}
                            		}
                            		else if(debet.getEncounter()!=null && debet.getEncounter().getServiceUID()!=null && debet.getEncounter().getServiceUID().equalsIgnoreCase(service.code)){
                            			hasDebets=true;
                            			break;
                            		}
                            	}
                    			if(hasDebets){
                            		Debug.println("Hasdebets = true");
	                    			if(subinvoices>0){
	                    				doc.newPage();
	                    			}
                            		Debug.println("Adding heading");
	            	                addHeading(invoice,subinvoices);
                            		Debug.println("Adding patientdata admission");
	            	                addPatientDataAdmission(invoice,service,subinvoices,debets,insurance);
                            		Debug.println("Adding invoice admission");
	            	                printInvoiceAdmission(invoice,service,debets);
	                        		subinvoices++;
                    			}
                    		}
                    		else{
                        		Debug.println("Costcenter <> H");
                            	boolean hasDebets=false;
                    			for(int i=0;i<debets.size();i++){
                            		Debet debet = (Debet)debets.elementAt(i);
                            		if(debet!=null && debet.getServiceUid()!=null){
                            			if(service!=null && service.code!=null && debet.getServiceUid().equalsIgnoreCase(service.code)){
                            				hasDebets=true;
                            				break;
                            			}
                            		}
                            		else if(debet.getEncounter()!=null && debet.getEncounter().getServiceUID()!=null && debet.getEncounter().getServiceUID().equalsIgnoreCase(service.code)){
                                		Debug.println("4");
                            			hasDebets=true;
                            			break;
                            		}
                            	}
                    			if(hasDebets){
                            		Debug.println("Hasdebets = true");
	                    			if(subinvoices>0){
	                    				doc.newPage();
	                    			}
                            		Debug.println("Adding heading");
	                                addHeading(invoice,subinvoices);
                            		Debug.println("Adding patientdata visit");
	                                addPatientDataVisit(invoice,service,subinvoices,debets,insurance);
                            		Debug.println("Adding invoice visit");
	                                printInvoiceVisit(invoice,service,debets);
	                        		subinvoices++;
                    			}
                    		}
                    	}
                    }
                }
            }
    		if(MedwanQuery.getInstance().getConfigInt("autoPrintPatientInvoice",0)==1){
    			PdfAction action = new PdfAction(PdfAction.PRINTDIALOG);
    			docWriter.setOpenAction(action);
    		}
        }
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
        }
		finally{
			if(doc!=null) {
				doc.close();
			}
            if(docWriter!=null) {
            	docWriter.close();
            }
		}
		if(baosPDF.size() < 1){
			throw new DocumentException("document has no bytes");
		}

		return baosPDF;
	}

    //---- ADD RECEIPT ----------------------------------------------------------------------------
    private void addReceipt(SummaryInvoice invoice) throws DocumentException {
        PdfPTable receiptTable = new PdfPTable(50);
        receiptTable.setWidthPercentage(pageWidth);

        // logo
        try{
            Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
            if(img==null){
                cell = createEmptyCell(10);
                receiptTable.addCell(cell);
            }
            else {
                img.scaleToFit(75,75);
                cell = new PdfPCell(img);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(10);
                receiptTable.addCell(cell);
            }
        }
        catch (Exception e){
        	Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
            e.printStackTrace();
        }

        table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.addCell(createGrayCell(getTran("web","receiptforinvoice").toUpperCase()+" #"+(sProforma.equalsIgnoreCase("yes")?ScreenHelper.getTranNoLink("invoice","PROFORMA",sPrintLanguage):invoice.getUid().split("\\.")[1])+" - "+ScreenHelper.stdDateFormat.format(invoice.getDate()),5,10,Font.BOLD));
        table.addCell(createValueCell(getTran("web","receivedfrom")+": "+patient.lastname.toUpperCase()+" "+patient.firstname+" ("+patient.personid+")",3,8,Font.NORMAL));
        table.addCell(createValueCell(patient.dateOfBirth,1,8,Font.NORMAL));
        table.addCell(createValueCell(patient.gender,1,8,Font.NORMAL));
       	table.addCell(createEmptyCell(3));
        table.addCell(createValueCell(getTran("web","prestations"),1,8,Font.NORMAL));
        double totalDebet=0;
        double totalinsurardebet=0;
        double totalextrainsurardebet=0;

    	//Find services
		String insurars="",extrainsurars="";
		Vector debets=invoice.getDebets();
    	for(int n=0;n<debets.size();n++){
    		ConsolidatedDebet debet = (ConsolidatedDebet)debets.elementAt(n);
    		if(debet.getInsurance()!=null && debet.getInsurance().getInsurar()!=null && debet.getInsurance().getInsurar().getName()!=null && insurars.indexOf(debet.getInsurance().getInsurar().getName())<0){
    			if(insurars.length()>0){
    				insurars+=", ";
    			}
    			insurars+=debet.getInsurance().getInsurar().getName();
    		}
   			if(debet!=null){
	            totalDebet+=debet.getPatientamount();
	            totalinsurardebet+=debet.getInsureramount();
	            totalextrainsurardebet+=debet.getExtrainsureramount();
   			}
    	}
    	
        table.addCell(createPriceCell(totalDebet,1));
        table.addCell(createValueCell(getTran("web","cashiersignature"),3,8,Font.NORMAL));
        table.addCell(createValueCell(getTran("web","payments"),1,8,Font.NORMAL));
        double totalCredit=0;
        for(int n=0;n<invoice.getCredits().size();n++){
            PatientCredit credit = PatientCredit.get((String)invoice.getCredits().elementAt(n));
            totalCredit+=credit.getAmount();
        }
        cell=createPriceCell(totalCredit,1);
        cell.setBorder(PdfPCell.BOTTOM);
        table.addCell(cell);
        table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(new Date()),3,8,Font.NORMAL));
        table.addCell(createValueCell(getTran("web.finance","balance"),1,8,Font.NORMAL));
        table.addCell(createPriceCell(invoice.getBalance(),1));
        if(ScreenHelper.checkString(insurars).length()>0){
	        table.addCell(createEmptyCell(3));
	        table.addCell(createValueCell(getTran("web","insurar"),1,8,Font.ITALIC));
	        cell = new PdfPCell(new Paragraph(priceFormat.format(totalinsurardebet)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
	        cell.setColspan(1);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);
        }
        if(ScreenHelper.checkString(extrainsurars).length()>0){
	        table.addCell(createEmptyCell(3));
	        table.addCell(createValueCell(getTran("web","extrainsurar"),1,8,Font.ITALIC));
	        cell = new PdfPCell(new Paragraph(priceFormat.format(totalextrainsurardebet)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
	        cell.setColspan(1);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);
        }
        cell = new PdfPCell(table);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setColspan(40);
        receiptTable.addCell(cell);
        if(ScreenHelper.checkString(insurars).length()>0){
        	receiptTable.addCell(createValueCell(getTran("web","insurar"),10,8,Font.BOLD));
        	receiptTable.addCell(createValueCell(insurars,24,7,Font.NORMAL));
        	receiptTable.addCell(createValueCell(getTran("web","bc.insurar"),8,8,Font.ITALIC));
	        cell = new PdfPCell(new Paragraph("",FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
	        cell.setColspan(8);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        receiptTable.addCell(cell);
        }
        if(ScreenHelper.checkString(extrainsurars).length()>0){
        	receiptTable.addCell(createValueCell(getTran("web","extrainsurar"),10,8,Font.BOLD));
        	receiptTable.addCell(createValueCell(extrainsurars,24,7,Font.NORMAL));
        	receiptTable.addCell(createValueCell(getTran("web","bc.extrainsurar"),8,8,Font.ITALIC));
	        cell = new PdfPCell(new Paragraph(invoice.getComment()+"",FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
	        cell.setColspan(8);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        receiptTable.addCell(cell);
        }
        receiptTable.addCell(createEmptyCell(50));
        receiptTable.addCell(createValueCell(getTran("web","service"),10,8,Font.BOLD));
        receiptTable.addCell(createValueCell(invoice.getServicesAsString(sPrintLanguage),40,7,Font.BOLD));
        receiptTable.addCell(createValueCell(getTran("web","prestations"),10,8,Font.BOLD));
        int nLines=2;
        for(int n=0;n<debets.size();n++){
            Debet debet = (Debet)debets.elementAt(n);
            String extraInsurar="";
            if(debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0){
                Insurar exIns = Insurar.get(debet.getExtraInsurarUid());
                if(exIns!=null){
                    extraInsurar=" >>> "+ScreenHelper.checkString(exIns.getName());
                    if(extraInsurar.indexOf("#")>-1){
                        extraInsurar=extraInsurar.substring(0,extraInsurar.indexOf("#"));
                    }
                }
            }
        	if(nLines==0){
                receiptTable.addCell(createEmptyCell(10));
                nLines=1;
        	}
        	else if(nLines==1){
        		nLines=0;
        	}
        	else {
        		nLines=1;
        	}
            receiptTable.addCell(createValueCell(debet.getQuantity()+" x  ["+debet.getPrestation().getCode()+"] "+debet.getPrestation().getDescription()+extraInsurar,20,7,Font.NORMAL));
        }
        receiptTable.addCell(createEmptyCell(50-((debets.size() % 2)*20)));
        receiptTable.addCell(createEmptyCell(50));
        receiptTable.addCell(createCell(createValueCell(" "),50,PdfPCell.ALIGN_CENTER,PdfPCell.BOTTOM));
        receiptTable.addCell(createEmptyCell(50));
        doc.add(receiptTable);
    }


    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(SummaryInvoice invoice,int subinvoice) throws Exception {
        table = new PdfPTable(5);
        table.setWidthPercentage(pageWidth);

        try {
            //*** logo ***
        	try{
                Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
                img.scaleToFit(75, 75);
                cell = new PdfPCell(img);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
            }
            catch(Exception e){
                Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
                e.printStackTrace();
                cell = new PdfPCell();
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
            }

        	PdfPTable table2 = new PdfPTable(30);
            table2.setWidthPercentage(pageWidth);
            Report_Identification report_identification = new Report_Identification(new java.util.Date());
            cell=createValueCell(getTran("web","mfp.ident.1.1"),10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createValueCell(getTran("web","mfp.ident.1.2"),13,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createValueCell(getTran("web","recordnumber")+": "+invoice.getUid().split("\\.")[1]+(subinvoice>0?"."+subinvoice:"")+"\n"+getTran("web","patientnumber")+": "+invoice.getPatientUid(),7,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);

            cell=createValueCell(getTran("web","mfp.ident.2.1"),10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createValueCell(getTran("web","health.facility")+":",5,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createValueCell(report_identification.getItem("OC_HC_FOSA"),8,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            if(!sProforma.equalsIgnoreCase("yes")){
                //*** barcode ***
                Image image = PdfBarcode.getBarcode("7"+invoice.getUid(), docWriter);            
                image.scaleAbsoluteWidth(75);
                cell = new PdfPCell(image);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setPadding(0);
                cell.setColspan(7);
            }
            else {
                cell = createEmptyCell(5);
            }
            table2.addCell(cell);

            cell=new PdfPCell(table2);
            cell.setColspan(4);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            doc.add(table);
            addBlankRow();

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD PATIENT DATA ------------------------------------------------------------------------
    private void addPatientDataVisit(SummaryInvoice invoice,Service service,int subinvoices,Vector activedebets,Insurance insurance){
        PdfPTable table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
        try{
        	AdminPerson person = invoice.getPatient();
        	if(person!=null){
        		Encounter encounter=null;
                Vector debets = new Vector();
            	for(int n=0;n<activedebets.size();n++){
            		Debet debet = (Debet)activedebets.elementAt(n);
            		if(debet!=null && debet.getServiceUid()!=null){
            			if(debet.getServiceUid().equalsIgnoreCase(service.code)){
            				debets.add(debet);
            				if(encounter==null){
            					encounter=debet.getEncounter();
            				}
            				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
            					encounter.setBegin(debet.getEncounter().getBegin());
            				}
            				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
            					encounter.setEnd(debet.getEncounter().getEnd());
            				}
            			}
            		}
            		else if(debet.getEncounter().getServiceUID().equalsIgnoreCase(service.code)){
        				debets.add(debet);
        				if(encounter==null){
        					encounter=debet.getEncounter();
        				}
        				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
        					encounter.setBegin(debet.getEncounter().getBegin());
        				}
        				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
        					encounter.setEnd(debet.getEncounter().getEnd());
        				}
            		}
            	}
        		
        		String natreg=ScreenHelper.checkString(insurance.getMemberImmat());
        		if(natreg.length()==0 && person.getAdminID("natreg")!=null){
        			natreg=person.getAdminID("natreg").value+"";
        		}
	        	cell=createLabelCell(getTran("web","mfp.immat")+":",20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(natreg,20);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.summary.invoice")+": "+(invoice.getUid().split("\\.").length>1?invoice.getUid().split("\\.")[1]+(subinvoices>0?"."+subinvoices:""):""),60,12);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","mfp.cardnumber"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getInsuranceNr(),80);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","mfp.affiliate"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getMember()+(insurance.getStatus().equalsIgnoreCase("affiliate")?" �"+person.dateOfBirth:""),50);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.natural"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories()!=null && encounter.getCategories().equalsIgnoreCase("A")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	String community="";
	        	AdminPrivateContact priv = person.getActivePrivate();
	        	if(priv!=null){
	        		community=priv.sector;
	        	}
	        	
	        	cell=createLabelCell(getTran("web","mfp.community"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(community,50);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.professional"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories()!=null && encounter.getCategories().equalsIgnoreCase("B")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","employer"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getMemberEmployer(),50);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.work"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories()!=null && encounter.getCategories().equalsIgnoreCase("C")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","beneficiary"),70);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.traffic"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories()!=null && encounter.getCategories().equalsIgnoreCase("D")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell("",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","himself"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getStatus().equalsIgnoreCase("affiliate")?"X":"",3);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",47);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.other"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories()!=null && encounter.getCategories().equalsIgnoreCase("E")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell("",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","partner"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getStatus().equalsIgnoreCase("partner")?"X":"",3);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","name")+":",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(insurance.getStatus().equalsIgnoreCase("partner")?person.lastname.toUpperCase()+", "+person.firstname+" (�"+person.dateOfBirth+")":"",40);
	        	table.addCell(cell);
	        	if(encounter.getCategories().equalsIgnoreCase("C")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","recordnumber",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.RECORDNUMBER."+encounter.getUid()),30);
	        	}
	        	else if(encounter.getCategories().equalsIgnoreCase("D")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","insurer",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.INSURER."+encounter.getUid()),30);
	        	}
	        	else {
		        	cell=createLabelCell("",30);
	        	}
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell("",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","child"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getStatus().equalsIgnoreCase("child")?"X":"",3);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","name")+":",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(insurance.getStatus().equalsIgnoreCase("child")?person.lastname.toUpperCase()+", "+person.firstname+" (�"+person.dateOfBirth+")":"",40);
	        	table.addCell(cell);
	        	if(encounter.getCategories().equalsIgnoreCase("C")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","immatnumber",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.IMMAT."+encounter.getUid()),30);
	        	}
	        	else if(encounter.getCategories().equalsIgnoreCase("D")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","accidentnumber",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.NUMBER."+encounter.getUid()),30);
	        	}
	        	else {
		        	cell=createLabelCell("",30);
	        	}
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","subinvoices"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(invoice.getPatientInvoiceNumbers(),80);
	        	table.addCell(cell);

	        	doc.add(table);
	        	
	        	addBlankRow();
        	}
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //--- ADD PATIENT DATA ------------------------------------------------------------------------
    private void addPatientDataAdmission(SummaryInvoice invoice,Service service,int subinvoice,Vector activedebets,Insurance insurance){
        PdfPTable table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
        try{
        	AdminPerson person = invoice.getPatient();
        	if(person!=null){
        		Encounter encounter=null;
                Vector debets = new Vector();
            	for(int n=0;n<activedebets.size();n++){
            		Debet debet = (Debet)activedebets.elementAt(n);
            		if(debet!=null && debet.getServiceUid()!=null){
            			if(debet.getServiceUid().equalsIgnoreCase(service.code)){
            				debets.add(debet);
            				if(encounter==null){
            					encounter=debet.getEncounter();
            				}
            				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
            					encounter.setBegin(debet.getEncounter().getBegin());
            				}
            				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
            					encounter.setEnd(debet.getEncounter().getEnd());
            				}
            			}
            		}
            		else if(debet.getEncounter().getServiceUID().equalsIgnoreCase(service.code)){
        				debets.add(debet);
        				if(encounter==null){
        					encounter=debet.getEncounter();
        				}
        				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
        					encounter.setBegin(debet.getEncounter().getBegin());
        				}
        				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
        					encounter.setEnd(debet.getEncounter().getEnd());
        				}
            		}
            	}
        		String natreg=ScreenHelper.checkString(insurance.getMemberImmat());
        		if(natreg.length()==0 && person.getAdminID("natreg")!=null){
        			natreg=person.getAdminID("natreg").value+"";
        		}
	        	cell=createLabelCell(getTran("web","mfp.immat")+":",20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(natreg,20);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.summary.invoice")+": "+(invoice.getUid().split("\\.").length>1?invoice.getUid().split("\\.")[1]+(subinvoice>0?"."+subinvoice:""):""),60,12);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","mfp.cardnumber"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getInsuranceNr(),80);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","mfp.affiliate"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getMember()+(insurance.getStatus().equalsIgnoreCase("affiliate")?" �"+person.dateOfBirth:""),50);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.natural"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories().equalsIgnoreCase("A")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	String community="";
	        	AdminPrivateContact priv = person.getActivePrivate();
	        	if(priv!=null){
	        		community=priv.sector;
	        	}
	        	
	        	cell=createLabelCell(getTran("web","mfp.community"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(community,50);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.professional"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories().equalsIgnoreCase("B")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","employer"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getMemberEmployer(),50);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.work"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories().equalsIgnoreCase("C")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","beneficiary"),70);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.traffic"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories().equalsIgnoreCase("D")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell("",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","himself"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getStatus().equalsIgnoreCase("affiliate")?"X":"",3);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",47);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","mfp.disease.other"),20);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        	table.addCell(cell);
	        	cell=createLabelCell("",1);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getCategories().equalsIgnoreCase("E")?"X":"\n",9);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell("",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","partner"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getStatus().equalsIgnoreCase("partner")?"X":"",3);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","name")+":",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(insurance.getStatus().equalsIgnoreCase("partner")?person.lastname.toUpperCase()+", "+person.firstname+" (�"+person.dateOfBirth+")":"",40);
	        	table.addCell(cell);
	        	if(encounter.getCategories().equalsIgnoreCase("C")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","recordnumber",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.RECORDNUMBER."+encounter.getUid()),30);
	        	}
	        	else if(encounter.getCategories().equalsIgnoreCase("D")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","insurer",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.INSURER."+encounter.getUid()),30);
	        	}
	        	else {
		        	cell=createLabelCell("",30);
	        	}
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell("",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","child"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(insurance.getStatus().equalsIgnoreCase("child")?"X":"",3);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","name")+":",5);
	        	table.addCell(cell);
	        	cell=createLabelCell(insurance.getStatus().equalsIgnoreCase("child")?person.lastname.toUpperCase()+", "+person.firstname+" (�"+person.dateOfBirth+")":"",40);
	        	table.addCell(cell);
	        	if(encounter.getCategories().equalsIgnoreCase("C")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","immatnumber",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.IMMAT."+encounter.getUid()),30);
	        	}
	        	else if(encounter.getCategories().equalsIgnoreCase("D")){
		        	cell=createLabelCell(ScreenHelper.getTran(null,"Web","accidentnumber",sPrintLanguage)+": "+Pointer.getPointer("ENCOUNTER.ACCIDENT.NUMBER."+encounter.getUid()),30);
	        	}
	        	else {
		        	cell=createLabelCell("",30);
	        	}
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","subinvoices"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(invoice.getPatientInvoiceNumbers(),80);
	        	table.addCell(cell);

	        	doc.add(table);
	        	
	        	addBlankRow();
        	}
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD INSURANCE DATA ----------------------------------------------------------------------
    private void addInsuranceData(Insurance insurance){
        try {
            if(insurance!=null){
                InsuranceCategory insuranceCat = insurance.getInsuranceCategory();
                if(insuranceCat!=null){
                    Insurar insurar = insuranceCat.getInsurar();
                    if(!insurar.getUid().equals(getConfigString("patientSelfInsurarUID"))){
                        PdfPTable table = new PdfPTable(1);
                        table.setWidthPercentage(pageWidth);

                        PdfPTable insuranceTable = new PdfPTable(1);
                        insuranceTable.addCell(createGrayCell(getTran("web","insurancyData").toUpperCase(),1));
                        cell = new PdfPCell(getInsuranceData(insurance));
                        cell.setPadding(cellPadding);
                        insuranceTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
                        table.addCell(createCell(new PdfPCell(insuranceTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                        table.addCell(createEmptyCell(1));

                        doc.add(table);
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT INVOICE ---------------------------------------------------------------------------
    private void printDebets(PatientInvoice invoice,Vector debets){
        try{
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // debets
            table.addCell(createGrayCell(getTran("web","invoiceDebets").toUpperCase(),1));
            getDebets(invoice,table,debets);
            table.addCell(createEmptyCell(1));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    private void printInvoiceVisit(SummaryInvoice invoice,Service service,Vector activedebets){
        try {
            PdfPTable table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);
            
            Encounter encounter = null;
            Vector debets = new Vector();
        	for(int n=0;n<activedebets.size();n++){
        		Debet debet = (Debet)activedebets.elementAt(n);
        		if(debet!=null && debet.getServiceUid()!=null){
        			if(debet.getServiceUid().equalsIgnoreCase(service.code)){
        				debets.add(debet);
        				if(encounter==null){
        					encounter=debet.getEncounter();
        				}
        				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
        					encounter.setBegin(debet.getEncounter().getBegin());
        				}
        				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
        					encounter.setEnd(debet.getEncounter().getEnd());
        				}
        			}
        		}
        		else if(debet.getEncounter().getServiceUID().equalsIgnoreCase(service.code)){
    				debets.add(debet);
    				if(encounter==null){
    					encounter=debet.getEncounter();
    				}
    				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
    					encounter.setBegin(debet.getEncounter().getBegin());
    				}
    				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
    					encounter.setEnd(debet.getEncounter().getEnd());
    				}
        		}
        	}

        	cell=createLabelCell(getTran("web","service")+":",20);
        	table.addCell(cell);
        	cell=createBoldLabelCell(invoice.getServicesAsString(debets,sPrintLanguage),80);
        	table.addCell(cell);

            cell=createValueCell("\n",100);
            table.addCell(cell);

            cell=createValueCell(getTran("web","mfp.acts.and.drugs"),40,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","code"),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell("#",5,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","up"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat1"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat2"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat3"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.supplement"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);

            double patientshare=0,insureramount=0,supplements=0,extrainsuraramount=0;
            SortedMap prestations = new TreeMap();
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null && debet.getQuantity()!=0){
        			//printDebet(debet,table);
            		if(prestations.get(debet.getPrestation().getDescription()+"."+debet.getInsuranceUid()+"."+debet.getPrestationUid())==null){
            			prestations.put(debet.getPrestation().getDescription()+"."+debet.getInsuranceUid()+"."+debet.getPrestationUid(), debet);
            		}
            		else {
            			Debet olddebet = (Debet)prestations.get(debet.getPrestation().getDescription()+"."+debet.getInsuranceUid()+"."+debet.getPrestationUid());
            			olddebet.setQuantity(olddebet.getQuantity()+debet.getQuantity());
            			olddebet.setAmount(olddebet.getAmount()+debet.getAmount());
            			olddebet.setInsurarAmount(olddebet.getInsurarAmount()+debet.getInsurarAmount());
            			olddebet.setExtraInsurarAmount(olddebet.getExtraInsurarAmount()+debet.getExtraInsurarAmount());
            			olddebet.setDate(debet.getDate());
            		}
        			patientshare+=debet.getAmount()+debet.getExtraInsurarAmount();
        			extrainsuraramount+=debet.getExtraInsurarAmount();
        			insureramount+=debet.getInsurarAmount();
        			supplements+=debet.getPrestation().getSupplement()*debet.getQuantity();
            	}
            }

            Iterator iPrestations = prestations.keySet().iterator();
            while(iPrestations.hasNext()){
            	Debet debet = (Debet)prestations.get(iPrestations.next());
            	printDebet(debet,table);
            }

            cell=createValueCell("",64,7,Font.BOLD);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare+insureramount),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare-supplements),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(supplements),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);

            cell=createValueCell("\n\n",100);
            table.addCell(cell);

            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.total"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare+insureramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.patientshare"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare-extrainsuraramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.extrainsurer"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(extrainsuraramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.insurer"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            doc.add(table);

            addBlankRow();
            
            table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);

            cell=createEmptyCell(70);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.done.at")+" "+ScreenHelper.stdDateFormat.format(new Date()),30);
            table.addCell(cell);
            cell=createValueCell("\n",100);
            table.addCell(cell);
    		String sPrinted=getTran("web","printedby")+": "+user.person.lastname.toUpperCase()+", "+user.person.firstname+" "+ScreenHelper.fullDateFormatSS.format(new java.util.Date());
    		if(ScreenHelper.checkString(invoice.getComment()).length()>0){
    			sPrinted+="\n\n\n"+ScreenHelper.getTran(null,"web.finance","otherreference",sPrintLanguage)+": "+invoice.getComment();
                table.addCell(cell);
    		}
    		cell=createValueCell(sPrinted,50);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            
            if(invoice.getValidated()!=null && invoice.getValidated().length()>0){
            	User validatinguser = User.get(Integer.parseInt(invoice.getValidated()));
	            cell=createValueCell(getTran("web","validatedby")+": "+validatinguser.person.lastname.toUpperCase()+", "+validatinguser.person.firstname+" ("+validatinguser.userid+") - "+invoice.getUpdateDateTime(),100);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
            }
            
            cell=createValueCell("\n",100);
            table.addCell(cell);

            cell=createValueCell(getTran("web","ctams.beneficiary.signature"),33);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
    		String signatures="";
    		Vector pointers=Pointer.getFullPointers("SUMINVSIGN."+invoice.getUid());
    		for(int n=0;n<pointers.size();n++){
    			if(n>0){
    				signatures+=", ";
    			}
    			String ptr=(String)pointers.elementAt(n);
    			signatures+=ptr.split(";")[0]+" - "+ScreenHelper.fullDateFormat.format(new SimpleDateFormat("yyyyMMddHHmmSSsss").parse(ptr.split(";")[1]));
    		}
    		if(signatures.length()>0){
    			signatures="\n"+ScreenHelper.getTran(null,"web.finance","signed.by",sPrintLanguage)+": "+signatures;
    		}
            cell=createValueCell(getTran("web","ctams.caregiver.signature")+signatures,33);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.facility.stamp"),34);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            
            doc.add(table);

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private void printInvoiceAdmission(SummaryInvoice invoice,Service service,Vector activedebets){
        try {
            PdfPTable table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);
            
            Encounter encounter = null;
            Vector debets = new Vector();
        	for(int n=0;n<activedebets.size();n++){
        		Debet debet = (Debet)activedebets.elementAt(n);
        		if(debet!=null && debet.getServiceUid()!=null){
        			if(debet.getServiceUid().equalsIgnoreCase(service.code)){
        				debets.add(debet);
        				if(encounter==null){
        					encounter=debet.getEncounter();
        				}
        				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
        					encounter.setBegin(debet.getEncounter().getBegin());
        				}
        				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
        					encounter.setEnd(debet.getEncounter().getEnd());
        				}
        			}
        		}
        		else if(debet.getEncounter().getServiceUID().equalsIgnoreCase(service.code)){
    				debets.add(debet);
    				if(encounter==null){
    					encounter=debet.getEncounter();
    				}
    				if(encounter.getBegin().after(debet.getEncounter().getBegin())){
    					encounter.setBegin(debet.getEncounter().getBegin());
    				}
    				if(encounter.getEnd()!=null && (debet.getEncounter().getEnd()==null || encounter.getEnd().before(debet.getEncounter().getEnd()))){
    					encounter.setEnd(debet.getEncounter().getEnd());
    				}
        		}
        	}
        	
        	cell=createLabelCell(getTran("web","service")+":",20);
        	table.addCell(cell);
        	cell=createBoldLabelCell(invoice.getServicesAsString(debets,sPrintLanguage),80);
        	table.addCell(cell);
        	cell=createLabelCell(getTran("web","bed")+":",20);
        	table.addCell(cell);
        	String bed="";
        	if(encounter !=null && encounter.getBed()!=null && encounter.getBed().getService()!=null && encounter.getBed().getService().code.equalsIgnoreCase(service.code)){
        		bed=encounter.getBed().getName()+" ("+encounter.getBed().getService().getFullyQualifiedName(user.person.language)+")";
        	}
        	cell=createBoldLabelCell(bed,80);
        	table.addCell(cell);
            cell=createLabelCell(getTran("web","period"),10);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            cell=createBoldLabelCell(ScreenHelper.stdDateFormat.format(encounter.getBegin())+" - "+(encounter.getEnd()==null?ScreenHelper.stdDateFormat.format(new java.util.Date()):ScreenHelper.stdDateFormat.format(encounter.getEnd())),20);
            cell.setBorder(PdfPCell.NO_BORDER);
        	table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","up"),10);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","supplement"),10);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","stay"),10);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","total"),10);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","total.supplements"),10);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","mfp.cat4"),10);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","mfp.cat5"),10);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null && "stay".equalsIgnoreCase(debet.getPrestation().getPrestationClass())){
            		//Dit is een verblijfsdebet, dus afdrukken
                    cell=createLabelCell("",30);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                    cell=createLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format((debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())/debet.getQuantity()-debet.getPrestation().getSupplement()),10);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                    cell=createLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getPrestation().getSupplement()),10);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                    cell=createLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getQuantity()),10);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                    cell=createLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(((debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())/debet.getQuantity()-debet.getPrestation().getSupplement())*debet.getQuantity()),10);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                    cell=createLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getQuantity()*debet.getPrestation().getSupplement()),10);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                    cell=createLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getInsurarAmount()),10);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                    cell=createLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getAmount()+debet.getExtraInsurarAmount()-debet.getQuantity()*debet.getPrestation().getSupplement()),10);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
            	}
            }
            cell=createValueCell("\n",100);
            table.addCell(cell);


            cell=createValueCell("\n",100);
            table.addCell(cell);

            cell=createValueCell(getTran("web","mfp.acts.and.drugs"),40,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","code"),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell("#",5,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","up"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat1"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat2"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat3"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.supplement"),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);

            double patientshare=0,insureramount=0,supplements=0,extrainsuraramount=0;
            SortedMap prestations = new TreeMap();
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null && debet.getQuantity()!=0){
            		if(prestations.get(debet.getPrestation().getDescription()+"."+debet.getInsuranceUid()+"."+debet.getPrestationUid())==null){
            			prestations.put(debet.getPrestation().getDescription()+"."+debet.getInsuranceUid()+"."+debet.getPrestationUid(), debet);
            		}
            		else {
            			Debet olddebet = (Debet)prestations.get(debet.getPrestation().getDescription()+"."+debet.getInsuranceUid()+"."+debet.getPrestationUid());
            			olddebet.setQuantity(olddebet.getQuantity()+debet.getQuantity());
            			olddebet.setAmount(olddebet.getAmount()+debet.getAmount());
            			olddebet.setInsurarAmount(olddebet.getInsurarAmount()+debet.getInsurarAmount());
            			olddebet.setExtraInsurarAmount(olddebet.getExtraInsurarAmount()+debet.getExtraInsurarAmount());
            			olddebet.setDate(debet.getDate());
            		}
        			patientshare+=debet.getAmount()+debet.getExtraInsurarAmount();
        			extrainsuraramount+=debet.getExtraInsurarAmount();
        			insureramount+=debet.getInsurarAmount();
        	    	if(debet==null || debet.getInsurance()==null || debet.getInsurance().getInsurar()==null || debet.getInsurance().getInsurar().getNoSupplements()==0){
        	    		supplements+=debet.getPrestation().getSupplement()*debet.getQuantity();
        	    	}
            	}
            }

            Iterator iPrestations = prestations.keySet().iterator();
            while(iPrestations.hasNext()){
            	Debet debet = (Debet)prestations.get(iPrestations.next());
            	printDebet(debet,table);
            }

            cell=createValueCell("",64,7,Font.BOLD);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare+insureramount),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare-supplements),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(supplements),9,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);

            cell=createValueCell("\n\n",100);
            table.addCell(cell);

            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.total"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare+insureramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.patientshare"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare-extrainsuraramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.extrainsurer"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(extrainsuraramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.insurer"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            doc.add(table);

            addBlankRow();
            
            table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);

            cell=createEmptyCell(70);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.done.at")+" "+ScreenHelper.stdDateFormat.format(new Date()),30);
            table.addCell(cell);
            cell=createValueCell("\n",100);
            table.addCell(cell);
    		if(ScreenHelper.checkString(invoice.getComment()).length()>0){
    			cell=createValueCell(ScreenHelper.getTran(null,"web.finance","otherreference",sPrintLanguage)+": "+invoice.getComment(),100);
                table.addCell(cell);
    		}
            cell=createValueCell(getTran("web","printedby")+": "+user.person.lastname.toUpperCase()+", "+user.person.firstname+" "+ScreenHelper.fullDateFormatSS.format(new java.util.Date()),100);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            if(invoice.getValidated()!=null && invoice.getValidated().length()>0){
            	User validatinguser = User.get(Integer.parseInt(invoice.getValidated()));
	            cell=createValueCell(getTran("web","validatedby")+": "+validatinguser.person.lastname.toUpperCase()+", "+validatinguser.person.firstname+" ("+validatinguser.userid+") - "+invoice.getUpdateDateTime(),100);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
            }
            
            cell=createValueCell("\n",100);
            table.addCell(cell);

            cell=createValueCell(getTran("web","ctams.beneficiary.signature"),33);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
    		String signatures="";
    		Vector pointers=Pointer.getFullPointers("SUMINVSIGN."+invoice.getUid());
    		for(int n=0;n<pointers.size();n++){
    			if(n>0){
    				signatures+=", ";
    			}
    			String ptr=(String)pointers.elementAt(n);
    			signatures+=ptr.split(";")[0]+" - "+ScreenHelper.fullDateFormat.format(new SimpleDateFormat("yyyyMMddHHmmSSsss").parse(ptr.split(";")[1]));
    		}
    		if(signatures.length()>0){
    			signatures="\n"+ScreenHelper.getTran(null,"web.finance","signed.by",sPrintLanguage)+": "+signatures;
    		}
            cell=createValueCell(getTran("web","ctams.caregiver.signature")+signatures,33);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.facility.stamp"),34);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            
            doc.add(table);

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private void printDebet(Debet debet,PdfPTable table){
    	boolean noSupplements=false;
    	if(debet!=null && debet.getInsurance()!=null && debet.getInsurance().getInsurar()!=null && debet.getInsurance().getInsurar().getNoSupplements()==1){
    		noSupplements=true;
    	}
    	if(debet!=null && debet.getPrestationUid()!=null && debet.getPrestationUid().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("anesthesiaPrestationUid","$$$"))){
    		//This is an anesthesia prestation, try to find the "parent prestation"
    		Debet parentDebet = Debet.getByRefUid(debet.getUid());
    		if(parentDebet!=null && parentDebet.getPrestation()!=null && parentDebet.getPrestation().getAnesthesiaPercentage()>0){
    			debet.getPrestation().setSupplement(parentDebet.getPrestation().getSupplement()*parentDebet.getPrestation().getAnesthesiaPercentage()/100);
    			noSupplements=false;
    		}
    	}
        cell=createValueCell(ScreenHelper.stdDateFormat.format(debet.getDate()),12);
        table.addCell(cell);
        cell=createLabelCell(debet.getPrestation().getDescription()+" ("+debet.getPrestation().getMfpPercentage()+"%)",28);
        table.addCell(cell);
        cell=createValueCell(debet.getPrestation().getCode()+"",10);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(debet.getQuantity()+"",5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format((debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())/debet.getQuantity()-(noSupplements?0:debet.getPrestation().getSupplement())),9);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()-(noSupplements?0:debet.getPrestation().getSupplement()*debet.getQuantity())),9);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getInsurarAmount()),9);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        boolean b=debet.getExtraInsurarAmount()>0;
        cell=createValueCell((b?"(":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getAmount()+debet.getExtraInsurarAmount()-(noSupplements?0:debet.getPrestation().getSupplement()*debet.getQuantity()))+(b?")":""),9);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format((noSupplements?0:debet.getPrestation().getSupplement()*debet.getQuantity())),9);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
    }
    
    //### PRIVATE METHODS #########################################################################

    //--- GET INSURANCE DATA ----------------------------------------------------------------------
    private PdfPTable getInsuranceData(Insurance insurance){
        PdfPTable table = new PdfPTable(14);
        table.setWidthPercentage(pageWidth);

        InsuranceCategory insuranceCat = insurance.getInsuranceCategory();
        Insurar insurar = insuranceCat.getInsurar();
        double patientShare = Double.parseDouble(insuranceCat.getPatientShare());

        //*** ROW 1 ***
        // insurar name
        table.addCell(createLabelCell(getTran("web","insurar"),2));
        table.addCell(createValueCell(":   "+insurar.getName(),5,8,Font.BOLD));

        // patient share
        table.addCell(createLabelCell(getTran("system.manage","categorypatientshare"),2));
        cell = createValueCell(":   "+patientShare+" %",2);
        table.addCell(cell);
        table.addCell(createLabelCell(getTran("hrm","dossiernr"),1));
        table.addCell(createValueCell(":   "+insurance.getInsuranceNr(),2));

        //*** ROW 2 ***
        // insurance category
        table.addCell(createLabelCell(getTran("web","tariff"),2));
        table.addCell(createValueCell(":   "+ getTran("insurance.types",insurance.getType()),5));

        // insurar share
        table.addCell(createLabelCell(getTran("system.manage","categoryinsurarshare"),2));
        cell = createValueCell(":   "+(100-patientShare)+" %",2);
        table.addCell(cell);
        table.addCell(createEmptyCell(3));

        return table;
    }

    //--- GET DEBETS (prestations) ----------------------------------------------------------------
    private void getDebets(PatientInvoice invoice,PdfPTable tableParent,Vector debets){

        Vector debetUids = debets;
        if(debetUids.size() > 0){
            PdfPTable table = new PdfPTable(20);
            table.setWidthPercentage(pageWidth);
            // header
            cell = createUnderlinedCell(getTran("web","date"),1);
            PdfPTable singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","encounter"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),4,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","prestation"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),8,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","patient"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","insurar"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","extrainsurar"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = new PdfPCell(table);
            cell.setPadding(cellPadding);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            // print debets
            double totalPatient = 0, totalInsurar = 0, totalExtraInsurar=0;
            Debet debet;
            String activePrestationClass="";

            Vector debetsVector = new Vector();
            for(int i=0; i<debetUids.size(); i++){
                debet = (Debet)debetUids.get(i);
                debetsVector.add(debet);
            }

            for(int i=0; i<debetUids.size(); i++){
                table = new PdfPTable(20);
                table.setWidthPercentage(pageWidth);
                debet = (Debet)debetUids.get(i);
                String prestationClass= debet.getPrestation().getReferenceObject().getObjectType()==null?"?":debet.getPrestation().getReferenceObject().getObjectType();
                if(!prestationClass.equalsIgnoreCase(activePrestationClass)){
                    //This is a new prestation class, go calculate the header
                    activePrestationClass=prestationClass;
                    printPrestationClass(table,activePrestationClass,debetsVector);
                }
                totalPatient+= debet.getAmount();
                totalInsurar+= debet.getInsurarAmount();
                totalExtraInsurar+= debet.getExtraInsurarAmount();
                printDebet(table,debet);
                cell = new PdfPCell(table);
                cell.setPadding(0);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
            }

            table = new PdfPTable(20);
            // spacer
            //table.addCell(createEmptyCell(20));

            // display debet total
            table.addCell(createEmptyCell(9));
            cell = createLabelCell(getTran("web","subtotalprice"),5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(cellPadding);
            table.addCell(cell);
            table.addCell(createTotalPriceCell(totalPatient,2));

            table.addCell(createTotalPriceCell(totalInsurar,2));

            table.addCell(createTotalPriceCell(totalExtraInsurar,2));
            cell = new PdfPCell(table);
            cell.setPadding(cellPadding);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            this.patientDebetTotal += totalPatient;
            this.insurarDebetTotal += totalInsurar;
        }
        else{
            table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
        }

    }

    //--- GET CREDITS (payments) ------------------------------------------------------------------
    private PdfPTable getCredits(PatientInvoice invoice){
        PdfPTable table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        Vector creditUids = invoice.getCredits();
        if(creditUids.size() > 0){
            // header
            cell = createUnderlinedCell(getTran("web","date"),1);
            PdfPTable singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","type"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","comment"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),9,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","patient"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(" ",1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            // get credits from uids
            double total = 0;
            Hashtable creditsHash = new Hashtable();
            PatientCredit credit;
            String sCreditUid;

            for(int i=0; i<creditUids.size(); i++){
                sCreditUid = (String)creditUids.get(i);
                credit = PatientCredit.get(sCreditUid);
                creditsHash.put(new SimpleDateFormat("yyyyMMddHHmmss").format(credit.getDate())+"."+credit.getUid(),credit);
            }

            // sort credits on date
            Vector creditDates = new Vector(creditsHash.keySet());
            Collections.sort(creditDates);
            Collections.reverse(creditDates);

            String creditDate;
            for(int i=0; i<creditDates.size(); i++){
                creditDate = (String)creditDates.get(i);
                credit = (PatientCredit)creditsHash.get(creditDate);
                total+= credit.getAmount();
                printCredit(table,credit);
            }

            // spacer
            //table.addCell(createEmptyCell(20));

            // display credit total
            table.addCell(createEmptyCell(9));
            cell = createLabelCell(getTran("web","subtotalprice"),5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(cellPadding);
            table.addCell(cell);
            table.addCell(createTotalPriceCell(total,3));
            table.addCell(createEmptyCell(3));

            this.creditTotal = total;
        }
        else{
            table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
        }

        return table;
    }

    //--- PRINT PRESTATIONCLASS -------------------------------------------------------------------
    private void printPrestationClass(PdfPTable invoiceTable,String prestationClass,Vector debets){
        double classPatientAmount = 0,classInsurarAmount=0,classExtraInsurarAmount=0;
        for(int n=0;n<debets.size();n++){
            Debet debet = (Debet)debets.elementAt(n);
            String sClass= debet.getPrestation().getReferenceObject().getObjectType()==null?"?":debet.getPrestation().getReferenceObject().getObjectType();
            if(sClass.equalsIgnoreCase(prestationClass)){
                classPatientAmount+=debet.getAmount();
                classInsurarAmount+=debet.getInsurarAmount();
                classExtraInsurarAmount+=debet.getExtraInsurarAmount();
            }
        }
        cell = new PdfPCell(new Paragraph(getTran("prestationclass",prestationClass),FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(14);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        invoiceTable.addCell(cell);
        cell = new PdfPCell(new Paragraph(priceFormat.format(classPatientAmount)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(2);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        invoiceTable.addCell(cell);
        cell = new PdfPCell(new Paragraph(priceFormat.format(classInsurarAmount)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(2);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        invoiceTable.addCell(cell);
        cell = new PdfPCell(new Paragraph(priceFormat.format(classExtraInsurarAmount)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(2);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        invoiceTable.addCell(cell);
    };

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet(PdfPTable invoiceTable, Debet debet){
        String sDebetDate = ScreenHelper.stdDateFormat.format(debet.getDate());
        double debetAmountPatient = debet.getAmount();
        double debetAmountInsurar = debet.getInsurarAmount();
        double debetAmountExtraInsurar = debet.getExtraInsurarAmount();

        // encounter
        Encounter debetEncounter = debet.getEncounter();
        String sEncounterName = debetEncounter.getEncounterDisplayNameNoDate(this.sPrintLanguage);

        // prestation
        Prestation prestation = debet.getPrestation();
        String sPrestationCode  = "", sPrestationDescr = "";
        if(prestation!=null){
            sPrestationCode  = checkString(prestation.getCode());
            sPrestationDescr = checkString(prestation.getDescription());
        }

        if(sPrestationCode.length() > 0){
            sPrestationCode = "["+sPrestationCode+"] ";
        }

        // row
        invoiceTable.addCell(createValueCell(sDebetDate,2));
        invoiceTable.addCell(createValueCell(sEncounterName,4));
        String extraInsurar="";
        if(debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0){
            Insurar exIns = Insurar.get(debet.getExtraInsurarUid());
            if(exIns!=null){
                extraInsurar=" >>> "+ScreenHelper.checkString(exIns.getName());
                if(extraInsurar.indexOf("#")>-1){
                    extraInsurar=extraInsurar.substring(0,extraInsurar.indexOf("#"));
                }
            }
        }
        invoiceTable.addCell(createValueCell(sPrestationCode+debet.getQuantity()+" x "+sPrestationDescr+extraInsurar,8));
        invoiceTable.addCell(createPriceCell(debetAmountPatient,2));
        invoiceTable.addCell(createPriceCell(debetAmountInsurar,2));
        invoiceTable.addCell(createPriceCell(debetAmountExtraInsurar,2));
    }

    //--- PRINT CREDIT (payment) ------------------------------------------------------------------
    private void printCredit(PdfPTable invoiceTable, PatientCredit credit){
        String sCreditDate = ScreenHelper.stdDateFormat.format(credit.getDate());
        double creditAmount = credit.getAmount();
        String sCreditComment = checkString(credit.getComment());
        String sCreditType = getTran("credit.type",credit.getType());

        // row
        invoiceTable.addCell(createValueCell(sCreditDate,2));
        invoiceTable.addCell(createValueCell(sCreditType,3));
        invoiceTable.addCell(createValueCell(sCreditComment,9));
        invoiceTable.addCell(createPriceCell(creditAmount,3));
        invoiceTable.addCell(createEmptyCell(3));
    }

    //--- GET SALDO -------------------------------------------------------------------------------
    private PdfPTable getSaldo(){
        PdfPTable table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        // debets
        table.addCell(createEmptyCell(9));
        cell = createLabelCell(getTran("web","invoiceDebets"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.patientDebetTotal,3));
        table.addCell(createEmptyCell(3));

        // credits
        table.addCell(createEmptyCell(9));
        cell = createLabelCell(getTran("web","invoiceCredits"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.creditTotal,(this.creditTotal>=0),3));
        table.addCell(createEmptyCell(3));

        // saldo
        table.addCell(createEmptyCell(9));
        cell = createBoldLabelCell(getTran("web","totalprice").toUpperCase(),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);

        double saldo = (this.patientDebetTotal - Math.abs(this.creditTotal));
        table.addCell(createTotalPriceCell(saldo,3));
        table.addCell(createEmptyCell(3));

        return table;
    }

}