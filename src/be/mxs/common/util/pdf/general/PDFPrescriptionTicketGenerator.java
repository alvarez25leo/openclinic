package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import net.admin.User;
import net.admin.AdminPerson;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.util.Vector;
import java.text.SimpleDateFormat;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFPrescriptionTicketGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPrescriptionTicketGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, AdminPerson person,String prescription,String prescriptiondate) throws Exception {
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
        User user= (User)session.getAttribute("activeUser");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            Rectangle rectangle= new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("patientPrescriptionWidth",1050)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientPrescriptionHeight",1980)*72/254).floatValue());
            doc.setPageSize(rectangle);
            doc.setMargins(20,20,20,20);
            doc.open();
            sPrintLanguage=user.person.language;
            printPrescription(person,prescription,prescriptiondate,user);
    		if(MedwanQuery.getInstance().getConfigInt("autoPrintPrescription",0)==1){
    			PdfAction action = new PdfAction(PdfAction.PRINTDIALOG);
    			docWriter.setOpenAction(action);
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
    }

    protected void printPrescription(AdminPerson person,String prescription,String prescriptiondate,User user){
        try {
            String countrycode=MedwanQuery.getInstance().getConfigString("countrycode","BE");
            if(countrycode.equalsIgnoreCase("RW")){
                table = new PdfPTable(10);
                table.setWidthPercentage(pageWidth);
                cell = new PdfPCell();
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(0);
                cell.setFixedHeight(100*72/254);
                cell.setColspan(10);
                table.addCell(cell);
                //Identification of prescriber
                // - barcode
                PdfContentByte cb = docWriter.getDirectContent();
                Barcode39 barcode39 = new Barcode39();
                barcode39.setCode(ScreenHelper.checkString(user.getParameter("organisationid")));
                Image image = barcode39.createImageWithBarcode(cb, null, null);
                cell = new PdfPCell(image);
                cell.setBorder(PdfPCell.BOTTOM+PdfPCell.RIGHT);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setColspan(5);
                cell.setPadding(0);
                cell.setFixedHeight(230*72/254);
                table.addCell(cell);
                // - name prescriber
                PdfPTable wrappertable = new PdfPTable(1);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","name.prescriber"),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                wrappertable.addCell(cell);
                cell=new PdfPCell(new Paragraph(user.person.lastname.toUpperCase()+" "+user.person.firstname.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,9,Font.BOLD)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                wrappertable.addCell(cell);
                cell=new PdfPCell(wrappertable);
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(0);
                cell.setFixedHeight(230*72/254);
                cell.setColspan(5);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                table.addCell(cell);
                //Identification of patient
                wrappertable = new PdfPTable(10);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","inserted.by.prescriber").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(10);
                wrappertable.addCell(cell);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","name.lastname")+" "+getTran("pdfprescriptions","name.lastname.claimant"),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(3);
                wrappertable.addCell(cell);
                cell=new PdfPCell(new Paragraph(person.lastname.toUpperCase()+" "+person.firstname.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,9,Font.BOLD)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(7);
                wrappertable.addCell(cell);
                cell=new PdfPCell(wrappertable);
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(0);
                cell.setFixedHeight(175*72/254);
                cell.setColspan(10);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                table.addCell(cell);
                //Prescription content
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","vignette"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
                cell.setBorder(PdfPCell.RIGHT+PdfPCell.BOTTOM);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(3);
                cell.setFixedHeight(930*72/254);
                table.addCell(cell);
                cell=new PdfPCell(formatPresctiption(prescription));
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(7);
                cell.setFixedHeight(930*72/254);
                table.addCell(cell);
                //Signature prescriber
                Paragraph paragraph = new Paragraph();
                Chunk chunk = new Chunk(getTran("pdfprescriptions","stamp.prescriber")+"\n\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.lastname+" "+user.person.firstname+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().businessfunction+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().business+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().district+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().city+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().telephone+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(ScreenHelper.checkString("# "+user.getParameter("organisationid")),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                cell=new PdfPCell(paragraph);
                cell.setBorder(PdfPCell.BOTTOM+PdfPCell.RIGHT);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(5);
                cell.setFixedHeight(320*72/254);
                table.addCell(cell);
                paragraph = new Paragraph();
                chunk = new Chunk(getTran("pdfprescriptions","date.signature.prescriber")+"\n\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(prescriptiondate+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD));
                paragraph.add(chunk);
                cell=new PdfPCell(paragraph);
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(5);
                cell.setFixedHeight(320*72/254);
                table.addCell(cell);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","medicine.prescription").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(10);
                table.addCell(cell);


                doc.add(table);
            }
            else {
                table = new PdfPTable(10);
                table.setWidthPercentage(pageWidth);
                cell = new PdfPCell();
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(0);
                cell.setFixedHeight(100*72/254);
                cell.setColspan(10);
                table.addCell(cell);
                //Identification of prescriber
                // - barcode
                PdfContentByte cb = docWriter.getDirectContent();
                Barcode39 barcode39 = new Barcode39();
                barcode39.setCode(ScreenHelper.checkString(user.getParameter("organisationid")));
                Image image = barcode39.createImageWithBarcode(cb, null, null);
                cell = new PdfPCell(image);
                cell.setBorder(PdfPCell.BOTTOM+PdfPCell.RIGHT);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setColspan(5);
                cell.setPadding(0);
                cell.setFixedHeight(230*72/254);
                table.addCell(cell);
                // - name prescriber
                PdfPTable wrappertable = new PdfPTable(1);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","name.prescriber"),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                wrappertable.addCell(cell);
                cell=new PdfPCell(new Paragraph(user.person.lastname.toUpperCase()+" "+user.person.firstname.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,9,Font.BOLD)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                wrappertable.addCell(cell);
                cell=new PdfPCell(wrappertable);
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(0);
                cell.setFixedHeight(230*72/254);
                cell.setColspan(5);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                table.addCell(cell);
                //Identification of patient
                wrappertable = new PdfPTable(10);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","inserted.by.prescriber").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(10);
                wrappertable.addCell(cell);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","name.lastname")+" "+getTran("pdfprescriptions","name.lastname.claimant"),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(3);
                wrappertable.addCell(cell);
                cell=new PdfPCell(new Paragraph(person.lastname.toUpperCase()+" "+person.firstname.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,9,Font.BOLD)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(7);
                wrappertable.addCell(cell);
                cell=new PdfPCell(wrappertable);
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(0);
                cell.setFixedHeight(175*72/254);
                cell.setColspan(10);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                table.addCell(cell);
                //Prescription content
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","vignette"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
                cell.setBorder(PdfPCell.RIGHT+PdfPCell.BOTTOM);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(0);
                cell.setPaddingRight(10);
                cell.setColspan(3);
                cell.setFixedHeight(930*72/254);
                table.addCell(cell);
                cell=new PdfPCell(formatPresctiption(prescription));
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(7);
                cell.setFixedHeight(930*72/254);
                table.addCell(cell);
                //Signature prescriber
                Paragraph paragraph = new Paragraph();
                Chunk chunk = new Chunk(getTran("pdfprescriptions","stamp.prescriber")+"\n\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.lastname+" "+user.person.firstname+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().businessfunction+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().business+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().district+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().city+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(user.person.getActivePrivate().telephone+"\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(ScreenHelper.checkString("# "+user.getParameter("organisationid")),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                cell=new PdfPCell(paragraph);
                cell.setBorder(PdfPCell.BOTTOM+PdfPCell.RIGHT);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(5);
                cell.setFixedHeight(320*72/254);
                table.addCell(cell);
                paragraph = new Paragraph();
                chunk = new Chunk(getTran("pdfprescriptions","date.signature.prescriber")+"\n\n",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
                paragraph.add(chunk);
                chunk = new Chunk(prescriptiondate+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD));
                paragraph.add(chunk);
                cell=new PdfPCell(paragraph);
                cell.setBorder(PdfPCell.BOTTOM);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(5);
                cell.setFixedHeight(320*72/254);
                table.addCell(cell);
                cell=new PdfPCell(new Paragraph(getTran("pdfprescriptions","medicine.prescription").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(10);
                cell.setColspan(10);
                table.addCell(cell);


                doc.add(table);
            }



            /*
            table = new PdfPTable(4);
            table.setWidthPercentage(pageWidth);
            Encounter encounter = Encounter.getActiveEncounter(person.personid);
            if(encounter!=null){
                Chunk chunk0 = new Chunk("ID "+person.personid+"\n\n",FontFactory.getFont(FontFactory.HELVETICA,9,Font.BOLD));
                Chunk chunk1 = new Chunk(ScreenHelper.stdDateFormat.format(encounter.getBegin())+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD));
                Chunk chunk2 = new Chunk(encounter.getUid(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC));
                Paragraph paragraph = new Paragraph();
                paragraph.add(chunk0);
                paragraph.add(chunk1);
                paragraph.add(chunk2);
                cell = new PdfPCell(paragraph);
                cell.setBorder(PdfPCell.BOX);
                cell.setPaddingLeft(5);
                cell.setPaddingRight(5);
            }
            else {
                cell=createLabel("",6,1,Font.NORMAL);
                cell.setBorder(PdfPCell.NO_BORDER);
            }
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            table.addCell(cell);

            //Barcode + archiving code
            PdfPTable wrapperTable = new PdfPTable(3);
            wrapperTable.setWidthPercentage(100);

            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("0"+person.personid);
            Image image = barcode39.createImageWithBarcode(cb, null, null);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setColspan(2);
            cell.setPadding(0);
            wrapperTable.addCell(cell);

            PdfPTable subTable = new PdfPTable(1);
            subTable.setWidthPercentage(100);
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardarchivecode",user.person.language),6,1,Font.ITALIC);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPadding(0);
            subTable.addCell(cell);
            cell=createLabel(person.getID("archiveFileCode").toUpperCase(),10,1,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPadding(0);
            subTable.addCell(cell);
            cell = createBorderlessCell(1);
            cell.addElement(subTable);
            cell.setPadding(0);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            wrapperTable.addCell(cell);

            cell = createBorderlessCell(3);
            cell.addElement(wrapperTable);
            cell.setPadding(0);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table.addCell(cell);

            //Name
            cell=createLabel(person.firstname+" "+person.lastname,10,4,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);


            if(type.equalsIgnoreCase("1") && encounter!=null){
                //Date of birth & gender
                cell=createLabel(person.dateOfBirth,7,2,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                cell=createLabel(person.gender,7,2,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                table.addCell(cell);
                //Service & Bed
                cell=createLabel(encounter.getService()!=null?encounter.getService().getLabel(user.person.language)+(encounter.getBed()!=null?" ("+encounter.getBed().getName()+")":""):"",7,4,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                cell=createLabel(encounter.getManager()!=null?User.getUserName(encounter.getManagerUID()).get("firstname")+" "+User.getUserName(encounter.getManagerUID()).get("lastname"):"",7,4,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
            }
            else {
                //Date of birth & gender
                cell=createLabel(person.dateOfBirth+" "+person.gender,7,1,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                //Service & Bed
                cell=createLabel(encounter!=null && encounter.getService()!=null?encounter.getService().getLabel(user.person.language)+(encounter.getBed()!=null?" ("+encounter.getBed().getName()+")":""):"",7,3,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                table.addCell(cell);
            }



            doc.add(table);
            doc.setJavaScript_onLoad(MedwanQuery.getInstance().getConfigString("cardJavaScriptOnLoad","document.print();"));
            */
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

    private Paragraph formatPresctiption(String prescription){
        Paragraph paragraph = new Paragraph();
        Chunk chunk;
        String[] lines =prescription.split("\n");
        for(int n=0;n<lines.length;n++){
            if(lines[n].startsWith("R/")){
                chunk = new Chunk(lines[n]+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD));
            }
            else {
                chunk = new Chunk(lines[n]+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL));
            }
            paragraph.add(chunk);
        }
        return paragraph;
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