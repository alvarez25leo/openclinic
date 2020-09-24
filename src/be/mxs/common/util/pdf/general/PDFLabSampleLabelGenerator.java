package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.medical.LabRequest;
import be.openclinic.medical.Labo;
import net.admin.User;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import java.io.ByteArrayOutputStream;
import java.util.Vector;
import java.util.Collections;
import java.util.Hashtable;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFLabSampleLabelGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    private String type;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }



    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFLabSampleLabelGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Vector samples) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
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
            Rectangle rectangle=new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("labLabelWidth",190)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("labLabelHeight",570)*72/254).floatValue());
            doc.setPageSize(rectangle.rotate());
            doc.setMargins(5,5,5,5);
            doc.open();
            
            // add content to document
            for(int n=0;n<samples.size();n++){
                if(n>0){
                    doc.newPage();
                }
                Hashtable h = (Hashtable)samples.elementAt(n);
                if(MedwanQuery.getInstance().getConfigString("labSampleLabelModel","model1").equalsIgnoreCase("model1")){
                	printSampleLabel(Integer.parseInt((String)h.get("serverid")),Integer.parseInt((String)h.get("transactionid"))+"."+n,(String)h.get("sample"));
                }
                else if(MedwanQuery.getInstance().getConfigString("labSampleLabelModel","model1").equalsIgnoreCase("model2")){
                	printSampleLabel2(Integer.parseInt((String)h.get("serverid")),Integer.parseInt((String)h.get("transactionid"))+"."+n,(String)h.get("sample"));
                	
                }
                else if(MedwanQuery.getInstance().getConfigString("labSampleLabelModel","model1").equalsIgnoreCase("model3")){
                	printSampleLabel3(Integer.parseInt((String)h.get("serverid")),Integer.parseInt((String)h.get("transactionid"))+"."+n,(String)h.get("sample"));
                	
                }
            }
		}
		catch(Exception e){
			e.printStackTrace();
            baosPDF.reset();
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
    }

    protected void printSampleLabel(int serverid,String transactionid,String sample){
        try {
            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("2"+ transactionid);
            Image image = barcode39.createImageWithBarcode(cb, null, null);
            image.scaleToFit(MedwanQuery.getInstance().getConfigInt("labLabelScaleWidth",120),MedwanQuery.getInstance().getConfigInt("labLabelScaleHeight",40));
            table = new PdfPTable(3);
            table.setWidthPercentage(100);
            cell=new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setColspan(2);
            cell.setPadding(0);
            table.addCell(cell);

            cell = new PdfPCell(new Paragraph(MedwanQuery.getInstance().getLabel("labanalysis.monster",sample,user.person.language),FontFactory.getFont(FontFactory.HELVETICA_BOLD,MedwanQuery.getInstance().getConfigInt("labLabelSampleFontSize",6),MedwanQuery.getInstance().getConfigInt("labLabelSampleFontBold",Font.NORMAL))));
            cell.setColspan(1);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPadding(0);
            table.addCell(cell);

            LabRequest labRequest = LabRequest.getUnsampledRequest(serverid,transactionid,user.person.language);
            cell = new PdfPCell(new Paragraph(labRequest.getPersonid()+" "+labRequest.getPatientname(),FontFactory.getFont(FontFactory.HELVETICA_BOLD,MedwanQuery.getInstance().getConfigInt("labLabelPatientFontSize",6),MedwanQuery.getInstance().getConfigInt("labLabelPatientFontBold",Font.NORMAL))));
            cell.setColspan(3);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(0);
            table.addCell(cell);

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printSampleLabel2(int serverid,String transactionid,String sample){
        try {
            table = new PdfPTable(3);
            table.setWidthPercentage(100);

            cell = new PdfPCell(new Paragraph("",FontFactory.getFont(FontFactory.HELVETICA_BOLD,MedwanQuery.getInstance().getConfigInt("labLabelSampleFontSize",6),MedwanQuery.getInstance().getConfigInt("labLabelSampleFontBold",Font.NORMAL))));
            cell.setColspan(3);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setFixedHeight(MedwanQuery.getInstance().getConfigInt("labLabelSampleTopMargin",90)*72/254);
            cell.setPadding(0);
            table.addCell(cell);

            PdfContentByte cb = docWriter.getDirectContent();
            Image image = null;
            
            if(MedwanQuery.getInstance().getConfigString("labLabelBarcodeType","code39").equalsIgnoreCase("interleave25")){
	            BarcodeInter25 barcode25 = new BarcodeInter25();
	            String sampleid=transactionid.split("\\.")[1];
	            if(sampleid.length()==1){
	            	sampleid="0"+sampleid;
	            }
	            String tranid=transactionid.split("\\.")[0]+sampleid;
	            barcode25.setCode("2"+(tranid.length()%2==0?"0":"")+tranid);
	            barcode25.setAltText("");
	            barcode25.setSize(1);
	            barcode25.setBaseline(0);
	            image = barcode25.createImageWithBarcode(cb, null, null);
            }
            else {
	            Barcode39 barcode39 = new Barcode39();
	            barcode39.setCode("2"+transactionid);
	            barcode39.setAltText("");
	            barcode39.setSize(1);
	            barcode39.setBaseline(0);
	            image = barcode39.createImageWithBarcode(cb, null, null);
            }
            image.scaleToFit(MedwanQuery.getInstance().getConfigInt("labLabelScaleWidth",120),MedwanQuery.getInstance().getConfigInt("labLabelScaleHeight",40));
            cell=new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(3);
            cell.setPadding(0);
            table.addCell(cell);

            cell = new PdfPCell(new Paragraph(transactionid+" - "+MedwanQuery.getInstance().getLabel("labanalysis.monster",sample,user.person.language),FontFactory.getFont(FontFactory.HELVETICA_BOLD,MedwanQuery.getInstance().getConfigInt("labLabelSampleFontSize",6),MedwanQuery.getInstance().getConfigInt("labLabelSampleFontBold",Font.NORMAL))));
            cell.setColspan(3);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(0);
            table.addCell(cell);

            LabRequest labRequest = LabRequest.getUnsampledRequest(serverid,transactionid,user.person.language);
            cell = new PdfPCell(new Paragraph(labRequest.getPersonid()+" "+labRequest.getPatientname(),FontFactory.getFont(FontFactory.HELVETICA_BOLD,MedwanQuery.getInstance().getConfigInt("labLabelPatientFontSize",6),MedwanQuery.getInstance().getConfigInt("labLabelPatientFontBold",Font.NORMAL))));
            cell.setColspan(3);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(0);
            table.addCell(cell);

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printSampleLabel3(int serverid,String transactionid,String sample){
        try {
            table = new PdfPTable(3);
            table.setWidthPercentage(100);

            float pageHeight = doc.getPageSize().getHeight();
            float pageWidth = doc.getPageSize().getWidth();

            PdfContentByte cb = docWriter.getDirectContent();
            Image image = null;
            
            String barcodeid = Labo.getLabBarcode(serverid+"."+transactionid.split("\\.")[0]+"."+sample,true);
            
            Barcode128 barcode128 = new Barcode128();
            barcode128.setCode(barcodeid);
            barcode128.setAltText("");
            barcode128.setSize(1);
            barcode128.setBaseline(0);
            image = barcode128.createImageWithBarcode(cb, null, null);
            image.scaleToFit(pageWidth*5/10,pageHeight*9/10);
            cell=new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(3);
            cell.setPadding(0);
            table.addCell(cell);

            cell = new PdfPCell(new Paragraph(barcodeid+" - "+MedwanQuery.getInstance().getLabel("labanalysis.monster",sample,user.person.language),FontFactory.getFont(FontFactory.HELVETICA_BOLD,MedwanQuery.getInstance().getConfigInt("labLabelSampleFontSize",6),MedwanQuery.getInstance().getConfigInt("labLabelSampleFontBold",Font.NORMAL))));
            cell.setColspan(3);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(0);
            table.addCell(cell);

            LabRequest labRequest = LabRequest.getUnsampledRequest(serverid,transactionid,user.person.language);
            cell = new PdfPCell(new Paragraph(labRequest.getPersonid()+" "+labRequest.getPatientname(),FontFactory.getFont(FontFactory.HELVETICA_BOLD,MedwanQuery.getInstance().getConfigInt("labLabelPatientFontSize",6),MedwanQuery.getInstance().getConfigInt("labLabelPatientFontBold",Font.NORMAL))));
            cell.setColspan(3);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(0);
            table.addCell(cell);

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
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
