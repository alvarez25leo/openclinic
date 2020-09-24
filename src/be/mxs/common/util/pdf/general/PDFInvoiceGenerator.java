package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.*;

import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;

import javax.servlet.http.HttpServletRequest;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.io.ExportSAP_AR_INV;
import be.openclinic.finance.ExtraInsurarInvoice;
import be.openclinic.finance.ExtraInsurarInvoice2;
import be.openclinic.finance.InsurarInvoice;
import be.openclinic.finance.Invoice;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.finance.SummaryInvoice;

public abstract class PDFInvoiceGenerator extends PDFBasic {

    // declarations
    protected PdfWriter docWriter;
    protected final int pageWidth = 90;
    protected final int cellPadding = 3;

    protected double patientDebetTotal = 0;
    protected double insurarDebetTotal = 0;
    protected double creditTotal = 0;

    protected String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","�");
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
    DecimalFormat priceFormatInsurar = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatInsurar","#,##0.00"));


    //--- ABSTRACT METHODS ------------------------------------------------------------------------
    public abstract ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sInvoiceUid) throws Exception;

    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Invoice inv) throws Exception {
    	return null;
    }

    //--- ADD FOOTER ------------------------------------------------------------------------------
    protected void addFooter(){
        String sFooter = getConfigString("footer."+sProject);
        sFooter = sFooter.replaceAll("<br>","\n").replaceAll("<BR>","\n");
        PDFFooter footer = new PDFFooter(sFooter+"\n");
        docWriter.setPageEvent(footer);
    }

    protected void addMFPFooter(PatientInvoice patientinvoice){
        String sFooter = getConfigString("footer."+sProject);
        sFooter = sFooter.replaceAll("<br>","\n").replaceAll("<BR>","\n");
        PDFMFPFooter footer = new PDFMFPFooter(sFooter+"\n",patientinvoice.getAcceptationUid()!=null && patientinvoice.getAcceptationUid().length()>0);
        docWriter.setPageEvent(footer);
    }

    protected void addMFPFooter(SummaryInvoice patientinvoice){
        String sFooter = getConfigString("footer."+sProject);
        sFooter = sFooter.replaceAll("<br>","\n").replaceAll("<BR>","\n");
        PDFMFPFooter footer = new PDFMFPFooter(sFooter+"\n",patientinvoice.getValidated()!=null && patientinvoice.getValidated().length()>0);
        docWriter.setPageEvent(footer);
    }

    protected void addFooter(String sInvoiceUid){
        String sFooter = getConfigString("footer."+sProject);
        sFooter = sFooter.replaceAll("<br>","\n").replaceAll("<BR>","\n");
        PDFFooter footer = new PDFFooter(sFooter+(sFooter.trim().length()>0?" - ":"")+getTran("web","invoice")+" "+sInvoiceUid);
        docWriter.setPageEvent(footer);
    }

    protected void addFooterWithText(String s){
        String sFooter = getConfigString("footer."+sProject);
        sFooter = sFooter.replaceAll("<br>","\n").replaceAll("<BR>","\n");
        PDFFooter footer = new PDFFooter(sFooter+(sFooter.trim().length()>0?" - ":"")+s);
        docWriter.setPageEvent(footer);
    }

    protected PdfPTable getInsurarInvoiceId(InsurarInvoice invoice){
        PdfPTable table = new PdfPTable(14);
        table.setWidthPercentage(pageWidth);

        // number
        String sInvoiceNr = invoice.getInvoiceNumber();
        table.addCell(createLabelCell((invoice.getStatus().equalsIgnoreCase("closed")?getTran("web","invoiceNumber"):getTran("web","proforma"))+":   ",2));
        table.addCell(createValueCell(sInvoiceNr,5,7,Font.BOLD));

        // date
        String sInvoiceDate = ScreenHelper.stdDateFormat.format(invoice.getDate());
        table.addCell(createLabelCell(getTran("web","date")+":   ",2));
        table.addCell(createValueCell(sInvoiceDate,5,7,Font.BOLD));

        return table;
    }


    protected PdfPTable getExtraInsurarInvoiceId(ExtraInsurarInvoice invoice){
        PdfPTable table = new PdfPTable(14);
        table.setWidthPercentage(pageWidth);

        // number
        String sInvoiceNr = invoice.getInvoiceNumber();
        table.addCell(createLabelCell((invoice.getStatus().equalsIgnoreCase("closed")?getTran("web","invoiceNumber"):getTran("web","proforma"))+":   ",2));
        table.addCell(createValueCell(sInvoiceNr,5,7,Font.BOLD));

        // date
        String sInvoiceDate = ScreenHelper.stdDateFormat.format(invoice.getDate());
        table.addCell(createLabelCell(getTran("web","date")+":   ",2));
        table.addCell(createValueCell(sInvoiceDate,5,7,Font.BOLD));

        return table;
    }

    protected PdfPTable getExtraInsurarInvoiceId2(ExtraInsurarInvoice2 invoice){
        PdfPTable table = new PdfPTable(14);
        table.setWidthPercentage(pageWidth);

        // number
        String sInvoiceNr = invoice.getInvoiceNumber();
        table.addCell(createLabelCell((invoice.getStatus().equalsIgnoreCase("closed")?getTran("web","invoiceNumber"):getTran("web","proforma"))+":   ",2));
        table.addCell(createValueCell(sInvoiceNr,5,7,Font.BOLD));

        // date
        String sInvoiceDate = ScreenHelper.stdDateFormat.format(invoice.getDate());
        table.addCell(createLabelCell(getTran("web","date")+":   ",2));
        table.addCell(createValueCell(sInvoiceDate,5,7,Font.BOLD));

        return table;
    }


    //--- GET INVOICE ID --------------------------------------------------------------------------
    protected PdfPTable getInvoiceId(Invoice invoice){
        PdfPTable table = new PdfPTable(14);
        table.setWidthPercentage(pageWidth);

        // number
        String sInvoiceUid = invoice.getUid();
        String sInvoiceNr = sInvoiceUid.substring(sInvoiceUid.indexOf(".")+1);
        table.addCell(createLabelCell((invoice.getStatus().equalsIgnoreCase("closed")?getTran("web","invoiceNumber"):getTran("web","proforma"))+":   ",2));
        table.addCell(createValueCell(sInvoiceNr,5,7,Font.BOLD));

        // date
        String sInvoiceDate = ScreenHelper.stdDateFormat.format(invoice.getDate());
        table.addCell(createLabelCell(getTran("web","date")+":   ",2));
        table.addCell(createValueCell(sInvoiceDate,5,7,Font.BOLD));

        return table;
    }

    //--- GET "PAY TO" INFO -----------------------------------------------------------------------
    protected PdfPTable getPayToInfo(){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        // contact data
        String contactData = getConfigString("contactData."+sProject);
        contactData = contactData.replaceAll("<br>","\n").replaceAll("<BR>","\n");
        table.addCell(createValueCell(contactData,1));

        // account
        String accountNumber = getConfigString("accountNumber."+sProject);
        accountNumber = accountNumber.replaceAll("<br>","\n").replaceAll("<BR>","\n");
        table.addCell(createValueCell(accountNumber,1));

        return table;
    }

    //--- GET "PRINTED BY" INFO -------------------------------------------------------------------
    // active user name and current date
    protected PdfPTable getPrintedByInfo(){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        String sPrintedBy = getTran("web","printedby")+" "+user.person.lastname+" "+user.person.firstname+" "+
                            getTran("web","on")+" "+ new SimpleDateFormat(MedwanQuery.getInstance().getConfigString("printedByDateFormat","dd/MM/yyyy")).format(new java.util.Date());
        table.addCell(createValueCell(sPrintedBy,1));

        return table;
    }


    //##################################### CELL FUNCTIONS ########################################

    //--- CREATE GRAY CELL (gray background) ------------------------------------------------------
    protected PdfPCell createGrayCell(String value, int colspan){
        return createGrayCell(value,colspan,7,Font.BOLD);
    }

    protected PdfPCell createGrayCell(String value, int colspan, int fontSize){
        return createGrayCell(value,colspan,fontSize,Font.BOLD);
    }

    protected PdfPCell createGrayCell(String value, int colspan, int fontSize, int fontWeight){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,fontWeight)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorderColor(innerBorderColor);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(3);

        return cell;
    }

    //--- CREATE TITLE CELL (large, bold) ---------------------------------------------------------
    protected PdfPCell createTitleCell(String title, String subTitle, int colspan){
        return createTitleCell(title,subTitle,colspan,0);
    }

    protected PdfPCell createTitleCell(String title, String subTitle, int colspan, int height){
        Paragraph paragraph = new Paragraph(title,FontFactory.getFont(FontFactory.HELVETICA,11,Font.BOLD));

        // add subtitle, if any
        if(subTitle.length() > 0){
            paragraph.add(new Chunk("\n\n"+subTitle,FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
        }

        cell = new PdfPCell(paragraph);
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        if(height > 0){
            cell.setPadding(height/2);
        }

        return cell;
    }

    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOTTOM);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPadding(5);

        return cell;
    }

    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedTextCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        return cell;
    }

    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedTextCell(String value, int colspan,int size){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,size,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        return cell;
    }

    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan, int size){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,size,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOTTOM);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPadding(1);

        return cell;
    }

    //--- CREATE VALUE CELL -----------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int colspan){
        return createValueCell(value,colspan,7,Font.NORMAL);
    }

    //--- CREATE VALUE CELL -----------------------------------------------------------------------
    protected PdfPCell createValueCellRight(String value, int colspan, int padding){
        cell = createValueCell(value,colspan,7,Font.NORMAL);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPadding(padding);
    	return cell;
    }

    protected PdfPCell createValueCellPadded(String value, int colspan){
        PdfPCell cell = createValueCell(value,colspan,7,Font.NORMAL);
        cell.setPadding(5);
    	return cell;
    }

    protected PdfPCell createValueCell(String value, int colspan, int fontSize, int fontWeight){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,fontWeight)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PRICE CELL (rigth align, currency) -----------------------------------------------
    protected PdfPCell createPriceCell(double price, int colspan){
        return createPriceCell(price,false,colspan);
    }

    protected PdfPCell createLargePriceCell(double price, int colspan){
        return createLargePriceCell(price,false,colspan);
    }

    protected PdfPCell createPriceCellInsurar(double price, int colspan){
        return createPriceCellInsurar(price,false,colspan);
    }

    protected PdfPCell createPriceCell(double price, boolean indicateNegative, int colspan){
        String sValue = priceFormat.format(price)+" "+sCurrency;
        if(indicateNegative){
            sValue = "- "+sValue;
        }

        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

    protected PdfPCell createLargePriceCell(double price, boolean indicateNegative, int colspan){
        String sValue = priceFormat.format(price)+" "+sCurrency;
        if(indicateNegative){
            sValue = "- "+sValue;
        }

        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,9,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

    protected PdfPCell createPriceCellInsurar(double price, boolean indicateNegative, int colspan){
        String sValue = priceFormatInsurar.format(price)+" "+sCurrency;
        if(indicateNegative){
            sValue = "- "+sValue;
        }

        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

    //--- CREATE TOTAL PRICE CELL (top border, right align, currency) -----------------------------
    protected PdfPCell createTotalPriceCell(double price, int colspan){
        return createTotalPriceCell(price,false,colspan);
    }

    protected PdfPCell createTotalPriceCell(double price, int colspan, java.util.Date date){
        return createTotalPriceCell(price,false,colspan,date);
    }

    protected PdfPCell createTotalPriceCell(double price, int colspan, java.util.Date date,String sPaymentCurrency){
        return createTotalPriceCell(price,false,colspan,date,sPaymentCurrency);
    }

    protected PdfPCell createTotalPriceCell(double price, int colspan, java.util.Date date,String sPaymentCurrency, int fontSize){
        return createTotalPriceCell(price,false,colspan,date,sPaymentCurrency, fontSize);
    }

    protected String getTotalPriceString(double price, boolean indicateNegative, java.util.Date date){
        return getTotalPriceString(price,false,date,"");
    }

    protected PdfPCell createTotalPriceCellInsurar(double price, int colspan){
        return createTotalPriceCellInsurar(price,false,colspan);
    }

    protected PdfPCell createTotalPriceCell(double price, boolean indicateNegative, int colspan){
		String sValue = (indicateNegative?"- ":"")+priceFormat.format(price)+" "+sCurrency;
    	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==1){
    		sValue = sCurrency+" "+(indicateNegative?"- ":"")+priceFormat.format(price);
    	}
        
        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.TOP);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

    protected PdfPCell createTotalPriceCell(double price, boolean indicateNegative, int colspan,java.util.Date date){
    	return createTotalPriceCell(price, indicateNegative, colspan, date, "");
    }
    protected PdfPCell createTotalPriceCell(double price, boolean indicateNegative, int colspan,java.util.Date date, String sPaymentCurrency){
		String sValue = (indicateNegative?"- ":"")+priceFormat.format(price)+" "+sCurrency;
    	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==1){
    		sValue = sCurrency+" "+(indicateNegative?"- ":"")+priceFormat.format(price);
    	}
    	
        String sAlternateCurrency = MedwanQuery.getInstance().getConfigString("AlternateCurrency","");
        if(sAlternateCurrency.length()>0 && sPaymentCurrency!=null){
        	if(MedwanQuery.getInstance().getConfigInt("printPaymentCurrencyOnly",0)==0) {
	        	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==0){
	        		sValue+="\n("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+" "+sAlternateCurrency+")";
	        	}
	        	else{
	        		sValue+="\n("+sAlternateCurrency+" "+(indicateNegative?"- ":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+")";
	        	}
        	}
        	else if(sPaymentCurrency.equalsIgnoreCase(sAlternateCurrency)){
        		//Only print the amount in the currency that was used for the payment
	        	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==0){
	        		sValue=new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+" "+sAlternateCurrency;
	        	}
	        	else{
	        		sValue=sAlternateCurrency+" "+(indicateNegative?"- ":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date));
	        	}
        	}
        }
        
        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.TOP);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        
        return cell;
    }

    protected PdfPCell createTotalPriceCell(double price, boolean indicateNegative, int colspan,java.util.Date date, String sPaymentCurrency, int fontSize){
		String sValue = (indicateNegative?"- ":"")+priceFormat.format(price)+" "+sCurrency;
    	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==1){
    		sValue = sCurrency+" "+(indicateNegative?"- ":"")+priceFormat.format(price);
    	}
    	
        String sAlternateCurrency = MedwanQuery.getInstance().getConfigString("AlternateCurrency","");
        if(sAlternateCurrency.length()>0 && sPaymentCurrency!=null){
        	if(MedwanQuery.getInstance().getConfigInt("printPaymentCurrencyOnly",0)==0) {
	        	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==0){
	        		sValue+="\n("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+" "+sAlternateCurrency+")";
	        	}
	        	else{
	        		sValue+="\n("+sAlternateCurrency+" "+(indicateNegative?"- ":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+")";
	        	}
        	}
        	else if(sPaymentCurrency.equalsIgnoreCase(sAlternateCurrency)){
        		//Only print the amount in the currency that was used for the payment
	        	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==0){
	        		sValue=new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+" "+sAlternateCurrency;
	        	}
	        	else{
	        		sValue=sAlternateCurrency+" "+(indicateNegative?"- ":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date));
	        	}
        	}
        }
        
        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.TOP);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        
        return cell;
    }

    protected String getTotalPriceString(double price, boolean indicateNegative,java.util.Date date, String sPaymentCurrency){
		String sValue = (indicateNegative?"- ":"")+priceFormat.format(price)+" "+sCurrency;
    	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==1){
    		sValue = sCurrency+" "+(indicateNegative?"- ":"")+priceFormat.format(price);
    	}
    	
        String sAlternateCurrency = MedwanQuery.getInstance().getConfigString("AlternateCurrency","");
        if(sAlternateCurrency.length()>0 && sPaymentCurrency!=null){
        	if(MedwanQuery.getInstance().getConfigInt("printPaymentCurrencyOnly",0)==0) {
	        	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==0){
	        		sValue+="\n("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+" "+sAlternateCurrency+")";
	        	}
	        	else{
	        		sValue+="\n("+sAlternateCurrency+" "+(indicateNegative?"- ":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+")";
	        	}
        	}
        	else if(sPaymentCurrency.equalsIgnoreCase(sAlternateCurrency)){
        		//Only print the amount in the currency that was used for the payment
	        	if(MedwanQuery.getInstance().getConfigInt("totalPriceCurrencyBeforeAmount",0)==0){
	        		sValue=new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date))+" "+sAlternateCurrency;
	        	}
	        	else{
	        		sValue=sAlternateCurrency+" "+(indicateNegative?"- ":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("AlternateCurrencyPriceFormat","# ##0.00")).format(price/ExportSAP_AR_INV.getExchangeRate(sAlternateCurrency, date));
	        	}
        	}
        }
        return sValue;
    }

    protected PdfPCell createTotalPriceCellInsurar(double price, boolean indicateNegative, int colspan){
        String sValue = priceFormatInsurar.format(price)+" "+sCurrency;
        if(indicateNegative){
            sValue = "- "+sValue;
        }

        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.TOP);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

    //--- CREATE LABEL CELL (left align) ----------------------------------------------------------
    protected PdfPCell createLabelCell(String label, int colspan){
        cell = new PdfPCell(new Paragraph(label,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createLabelCell(String label, int colspan, int size){
        cell = new PdfPCell(new Paragraph(label,FontFactory.getFont(FontFactory.HELVETICA,size,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPadding(1);

        return cell;
    }

    //--- CREATE BOLD LABEL CELL (left align) -----------------------------------------------------
    protected PdfPCell createBoldLabelCell(String label, int colspan){
        cell = new PdfPCell(new Paragraph(label,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBoldLabelCell(String label, int colspan,int size){
        cell = new PdfPCell(new Paragraph(label,FontFactory.getFont(FontFactory.HELVETICA,size,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBoldUnderlinedLabelCell(String label, int colspan){
        cell = new PdfPCell(new Paragraph(label,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD+Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE EMPTY CELL -------------------------------------------------------------------------
    protected PdfPCell createEmptyCell(int colspan){
        return createEmptyCell(5,colspan);
    }

    //--- CREATE EMPTY CELL -------------------------------------------------------------------------
    protected PdfPCell createEmptyCell(int height, int colspan){
        cell = new PdfPCell(new Paragraph("",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setPaddingTop(height);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

}