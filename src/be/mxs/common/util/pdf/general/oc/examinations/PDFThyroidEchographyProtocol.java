package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFThyroidEchographyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                  
                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                }

                //*** RIGHT LOBE ********************************************************
                PdfPTable rightLobeTable = new PdfPTable(4);
                
                // echostructure right
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_RIGHT");
                if(itemValue.length() > 0){
                    rightLobeTable.addCell(createValueCell(getTran("openclinic.chuk","echostructure"),1));
                    rightLobeTable.addCell(createValueCell(itemValue,3));
                }

                // grande_axe right
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_RIGHT");
                if(itemValue.length() > 0){
                    rightLobeTable.addCell(createValueCell(getTran("openclinic.chuk","grande_axe"),1));
                    rightLobeTable.addCell(createValueCell(itemValue+" cm",3));
                }

                // nodules right
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_RIGHT");
                if(itemValue.length() > 0){
                    rightLobeTable.addCell(createValueCell(getTran("openclinic.chuk","nodules"),1));
                    rightLobeTable.addCell(createValueCell(itemValue,3));
                }

                // add right lobe table
                if(rightLobeTable.size() > 0){
                    table.addCell(createItemNameCell(getTran("openclinic.chuk","right_lobe"),1));
                    table.addCell(createCell(new PdfPCell(rightLobeTable),4,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                }

                //*** LEFT LOBE *********************************************************
                PdfPTable leftLobeTable = new PdfPTable(4);

                // echostructure left
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_LEFT");
                if(itemValue.length() > 0){
                    leftLobeTable.addCell(createValueCell(getTran("openclinic.chuk","echostructure"),1));
                    leftLobeTable.addCell(createValueCell(itemValue,3));
                }

                // grande_axe left
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_LEFT");
                if(itemValue.length() > 0){
                    leftLobeTable.addCell(createValueCell(getTran("openclinic.chuk","grande_axe"),1));
                    leftLobeTable.addCell(createValueCell(itemValue+" cm",3));
                }

                // nodules left
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_LEFT");
                if(itemValue.length() > 0){
                    leftLobeTable.addCell(createValueCell(getTran("openclinic.chuk","nodules"),1));
                    leftLobeTable.addCell(createValueCell(itemValue,3));
                }

                // add left lobe table
                if(leftLobeTable.size() > 0){
                    table.addCell(createItemNameCell(getTran("openclinic.chuk","left_lobe"),1));
                    table.addCell(createCell(new PdfPCell(leftLobeTable),4,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                }

                // isthmus
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ISTHMUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","isthmus"),itemValue);
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue.replaceAll("<br>","\r\n"));
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}
