package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;

import javax.servlet.http.HttpServletRequest;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.PdfBarcode;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import be.openclinic.adt.Encounter;
import net.admin.*;

public class PDFCoveragePlanInvoiceGenerator extends PDFInvoiceGenerator {
    String PrintType;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFCoveragePlanInvoiceGenerator(User user, String sProject, String sPrintLanguage, String PrintType){
        this.user = user;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;
        this.PrintType=PrintType;

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
			doc.setPageSize(PageSize.A4);
            addFooter(sInvoiceUid.replaceAll("1\\.",""));

            doc.open();

            // get specified invoice
            CoveragePlanInvoice invoice = CoveragePlanInvoice.get(sInvoiceUid);
            Vector services = PrestationDebet.getServicesForCoveragePlanInvoice(sInvoiceUid);
            for(int n=0;n<services.size();n++){
            	String serviceUid=(String)services.elementAt(n);
            	if(n>0){
            		doc.newPage();
            	}
	            addHeading(invoice);
	            addCareProviderData(invoice,serviceUid);
	            printInvoice(invoice,serviceUid);
	            addFinancialMessage();
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

    private void addFinancialMessage() throws Exception {
        addBlankRow();
        table = new PdfPTable(3);
        table.setWidthPercentage(pageWidth);
        cell = createValueCell(getTran("rbfinancialmessagetitle")+getTran("rbmessagetitle2"),3);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
        table.addCell(createCell(new PdfPCell(getPrintedByInfo()),2,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
        cell = createBoldLabelCell(getTran("invoiceDirector"),1);
        table.addCell(cell);
        doc.add(table);
    }
    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(CoveragePlanInvoice invoice) throws Exception {
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

            //*** title ***
            if(invoice.getStatus().equalsIgnoreCase("closed")){
                table.addCell(createTitleCell(getTran("web","invoice").toUpperCase(),"",3));
            }
            else {
                table.addCell(createTitleCell(getTran("web","reimbursementnote").toUpperCase(),"",3));
            }

            //*** barcode ***
            Image image = PdfBarcode.getBarcode("6"+invoice.getInvoiceUid(), docWriter);            
            cell = new PdfPCell(image);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(1);
            table.addCell(cell);

            doc.add(table);
            addBlankRow();
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD INSURAR DATA ------------------------------------------------------------------------
    private void addCareProviderData(CoveragePlanInvoice invoice,String serviceUid){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        PdfPTable insurarTable = new PdfPTable(1);
        insurarTable.setWidthPercentage(pageWidth);

        try {
            Service service = Service.getService(serviceUid);
            insurarTable.addCell(createValueCell(service.getLabel(sPrintLanguage),1));

            // title = coverage plan name
            Insurar coveragePlan = invoice.getInsurar();
            table.addCell(createGrayCell(coveragePlan.getName().toUpperCase(),1,9,Font.BOLD));
            cell = createCell(new PdfPCell(insurarTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setPadding(cellPadding);
            table.addCell(cell);

            doc.add(table);
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT INVOICE ---------------------------------------------------------------------------
    protected void printInvoice(CoveragePlanInvoice invoice,String serviceUid){
        try {
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // invoice id
            cell = new PdfPCell(getInvoiceId(invoice));
            cell.setPadding(cellPadding);
            table.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createEmptyCell(1));

            // debets
            table.addCell(createGrayCell(getTran("web","invoiceDebets").toUpperCase(),1));
            getDebets(invoice,table,serviceUid);
            table.addCell(createEmptyCell(1));

            // credits
            PdfPTable creditTable = new PdfPTable(1);
            creditTable.addCell(createGrayCell(getTran("web","invoiceCredits").toUpperCase(),1));
            cell = new PdfPCell(getCredits(invoice,serviceUid));
            cell.setPadding(cellPadding);
            creditTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createCell(new PdfPCell(creditTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            table.addCell(createEmptyCell(1));

            // saldo
            PdfPTable saldoTable = new PdfPTable(1);
            saldoTable.addCell(createGrayCell(getTran("web","invoiceSaldo").toUpperCase(),1));
            cell = new PdfPCell(getSaldo());
            cell.setPadding(cellPadding);
            saldoTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createCell(new PdfPCell(saldoTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            table.addCell(createEmptyCell(1));


            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //### PRIVATE METHODS #########################################################################

    //--- GET DEBETS (prestations) ----------------------------------------------------------------
    // grouped by patient, sorted on date desc
    private void getDebets(CoveragePlanInvoice invoice, PdfPTable tableParent,String serviceUid){
        if(PrintType.equalsIgnoreCase("sortbypatient")){
            Vector debets = CoveragePlanInvoice.getDebetsForInvoice(invoice.getUid(),serviceUid);
            if(debets.size() > 0){
                PdfPTable table = new PdfPTable(20);
                table.setWidthPercentage(pageWidth);
                // header
                cell = createUnderlinedCell(getTran("web","patientordate"),1);
                PdfPTable singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
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
                cell = createCell(new PdfPCell(singleCellHeaderTable),7,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","total"),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","reimbursement"),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                table.addCell(cell);

                cell=new PdfPCell(table);
                cell.setPadding(cellPadding);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                // print debets
                double total = 0;
                PrestationDebet debet;
                String sPatientName, sPrevPatientName = "";
                boolean displayPatientName;

                for(int i=0; i<debets.size(); i++){
                    table = new PdfPTable(20);
                    table.setWidthPercentage(pageWidth);
                    debet = (PrestationDebet)debets.get(i);
                    sPatientName = debet.getPatientName()+";"+debet.getEncounter().getPatientUID();
                    displayPatientName = !sPatientName.equals(sPrevPatientName);
                    total+= debet.getInsurarAmount();
                    printDebet(table,debet,displayPatientName);
                    sPrevPatientName = sPatientName;
                    cell=new PdfPCell(table);
                    cell.setPadding(0);
                    tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
                }

                table = new PdfPTable(20);
                // spacer
                table.addCell(createEmptyCell(20));

                // display debet total
                table.addCell(createEmptyCell(12));
                cell = createLabelCell(getTran("web","subtotalprice"),5);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                cell.setPaddingRight(5);
                table.addCell(cell);
                table.addCell(createTotalPriceCellInsurar(total,3));
                cell=new PdfPCell(table);
                cell.setPadding(0);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                this.insurarDebetTotal = total;
            }
            else{
                table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
            }
        }
        else if(PrintType.equalsIgnoreCase("sortbydate")){
            Vector debets = CoveragePlanInvoice.getDebetsForInvoiceSortByDate(invoice.getUid(),serviceUid);
            if(debets.size() > 0){
                PdfPTable table = new PdfPTable(200);
                table.setWidthPercentage(pageWidth);
                // header
                cell = createUnderlinedCell(getTran("web","patientordate"),1);
                PdfPTable singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),30,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","encounter"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),35,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","fac"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),15,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","prestation"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),70,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","total"),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),25,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","reimbursement"),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),25,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                table.addCell(cell);

                cell=new PdfPCell(table);
                cell.setPadding(cellPadding);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                // print debets
                double total = 0;
                PrestationDebet debet;
                String sPatientName, sPrevPatientName = "";
                Date date=null,prevdate=null;
                boolean displayPatientName,displayDate;

                for(int i=0; i<debets.size(); i++){
                    table = new PdfPTable(200);
                    table.setWidthPercentage(pageWidth);
                    debet = (PrestationDebet)debets.get(i);
                    date = debet.getDate();
                    displayDate = !date.equals(prevdate);
                    sPatientName = debet.getPatientName();
                    displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName);
                    total+= debet.getInsurarAmount();
                    printDebet2(table,debet,displayDate,displayPatientName);
                    prevdate = date;
                    sPrevPatientName = sPatientName;
                    cell=new PdfPCell(table);
                    cell.setPadding(0);
                    tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
                }

                table = new PdfPTable(20);
                // spacer
                table.addCell(createEmptyCell(20));

                // display debet total
                table.addCell(createEmptyCell(12));
                cell = createLabelCell(getTran("web","subtotalprice"),5);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                cell.setPaddingRight(5);
                table.addCell(cell);
                table.addCell(createTotalPriceCellInsurar(total,3));
                cell=new PdfPCell(table);
                cell.setPadding(0);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                this.insurarDebetTotal = total;
            }
            else{
                table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
            }
        }
    }

    //--- GET CREDITS (payments) (sorted on date desc) --------------------------------------------
    private PdfPTable getCredits(CoveragePlanInvoice invoice,String serviceUid){
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
            cell = createCell(new PdfPCell(singleCellHeaderTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","comment"),1);
            cell.setBorderColorBottom(innerBorderColor);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),10,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","amount"),1);
            cell.setBorderColorBottom(innerBorderColor);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            table.addCell(cell);

            // get credits from uids
            double total = 0;
            Hashtable creditsHash = new Hashtable();
            InsurarCredit credit;
            String sCreditUid;

            for(int i=0; i<creditUids.size(); i++){
                sCreditUid = (String)creditUids.get(i);
                credit = InsurarCredit.get(sCreditUid);
                creditsHash.put(credit.getDate(),credit);
            }

            // sort credits on date
            Vector creditDates = new Vector(creditsHash.keySet());
            Collections.sort(creditDates);
            Collections.reverse(creditDates);

            java.util.Date creditDate;
            for(int i=0; i<creditDates.size(); i++){
                creditDate = (java.util.Date)creditDates.get(i);
                credit = (InsurarCredit)creditsHash.get(creditDate);
                total+= credit.getAmount();
                printCredit(table,credit);
            }

            // spacer
            table.addCell(createEmptyCell(20));

            // display credit total
            table.addCell(createEmptyCell(12));
            cell = createLabelCell(getTran("web","subtotalprice"),5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);
            table.addCell(createTotalPriceCell(total,3));

            this.creditTotal = total;
        }
        else{
            table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
        }

        return table;
    }

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet(PdfPTable invoiceTable, PrestationDebet debet, boolean displayPatientName){
        String sDebetDate = ScreenHelper.stdDateFormat.format(debet.getDate());
        double debetAmount = debet.getInsurarAmount();

        // encounter
        Encounter encounter = debet.getEncounter();
        String sEncounterName = "ERROR : encounter not found";
        if(encounter!=null){
            sEncounterName = checkString(encounter.getEncounterDisplayNameNoDate(this.sPrintLanguage));
        }

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
        if(displayPatientName){
            String insuranceMemberNumber="";
            try{
                Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(debet.getEncounter().getPatientUID());
                if(insurance!=null && insurance.getInsuranceNr().length()>0){
                    insuranceMemberNumber = "# "+insurance.getInsuranceNr();
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            invoiceTable.addCell(createValueCell(debet.getPatientName()+" �"+debet.getEncounter().getPatient().dateOfBirth+" "+debet.getEncounter().getPatient().gender+" "+insuranceMemberNumber,20,7,Font.BOLD));
        }
        invoiceTable.addCell(createEmptyCell(1));
        invoiceTable.addCell(createValueCell(sDebetDate,2));
        invoiceTable.addCell(createValueCell(sEncounterName,4));
        invoiceTable.addCell(createValueCell(sPrestationCode+debet.getQuantity()+" x "+sPrestationDescr,7));
        invoiceTable.addCell(createPriceCellInsurar(debet.getTotalAmount(),3));
        invoiceTable.addCell(createPriceCellInsurar(debetAmount,3));
    }

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet2(PdfPTable invoiceTable, PrestationDebet debet, boolean displayDate,boolean displayPatientName){
        String sDebetDate = ScreenHelper.stdDateFormat.format(debet.getDate());
        double debetAmount = debet.getInsurarAmount();

        // encounter
        Encounter encounter = debet.getEncounter();
        String sEncounterName = "ERROR : encounter not found";
        if(encounter!=null){
            sEncounterName = checkString(encounter.getEncounterDisplayNameNoDate(this.sPrintLanguage));
        }

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
        if(displayDate){
            invoiceTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(debet.getDate()),200,7,Font.BOLD));
        }
        if(displayPatientName){
            String insuranceMemberNumber="";
            try{
                Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(debet.getEncounter().getPatientUID());
                if(insurance!=null && insurance.getInsuranceNr().length()>0){
                    insuranceMemberNumber = "# "+insurance.getInsuranceNr();
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            invoiceTable.addCell(createEmptyCell(10));
            invoiceTable.addCell(createValueCell(debet.getPatientName()+" �"+debet.getEncounter().getPatient().dateOfBirth+" "+debet.getEncounter().getPatient().gender+" "+insuranceMemberNumber,190,7,Font.BOLD));
        }
        invoiceTable.addCell(createEmptyCell(30));
        invoiceTable.addCell(createValueCell(sEncounterName,35));
        invoiceTable.addCell(createValueCell(ScreenHelper.checkString(debet.getPatientInvoiceUid()).replaceAll("1\\.",""),15));
        invoiceTable.addCell(createValueCell(sPrestationCode+debet.getQuantity()+" x "+sPrestationDescr,70));
        invoiceTable.addCell(createPriceCellInsurar(debet.getTotalAmount(),25));
        invoiceTable.addCell(createPriceCellInsurar(debetAmount,25));
    }

    //--- PRINT CREDIT (payment) ------------------------------------------------------------------
    private double printCredit(PdfPTable invoiceTable, InsurarCredit credit){
        String sCreditDate = ScreenHelper.stdDateFormat.format(credit.getDate());
        double creditAmount = credit.getAmount();
        String sCreditComment = checkString(credit.getComment());
        String sCreditType = getTran("credit.type",credit.getType());

        // row
        invoiceTable.addCell(createValueCell(sCreditDate,2));
        invoiceTable.addCell(createValueCell(sCreditType,5));
        invoiceTable.addCell(createValueCell(sCreditComment,10));
        invoiceTable.addCell(createPriceCell(creditAmount,3));

        return creditAmount;
    }

    //--- GET SALDO -------------------------------------------------------------------------------
    private PdfPTable getSaldo(){
        PdfPTable table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        // debets
        table.addCell(createEmptyCell(12));
        cell = createLabelCell(getTran("web","invoiceDebets"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.insurarDebetTotal,3));

        // credits
        table.addCell(createEmptyCell(12));
        cell = createLabelCell(getTran("web","invoiceCredits"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.creditTotal,(this.creditTotal>=0),3));

        // spacer
        table.addCell(createEmptyCell(20));

        // saldo
        double saldo = (this.insurarDebetTotal - Math.abs(this.creditTotal));
        table.addCell(createEmptyCell(12));
        cell = createBoldLabelCell(getTran("web","totalprice").toUpperCase(),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createTotalPriceCell(saldo,3));

        return table;
    }

}