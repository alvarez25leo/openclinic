package be.mxs.common.util.pdf.general;

import be.mxs.common.util.db.MedwanQuery;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.ColumnText;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;

public class PDFFooter extends PdfPageEventHelper {
	String sFooterText = "";
	int pagecount = 0;
    protected int fontSizePercentage = MedwanQuery.getInstance().getConfigInt("fontSizePercentage",100);

	//--- CONSTRUCTOR ---
	public PDFFooter(String sFooterText){
		this.sFooterText = sFooterText;
	}
	
    //--- ON END PAGE -----------------------------------------------------------------------------
    public void onEndPage(PdfWriter writer, Document document){
    	pagecount++;
    	    	
        Rectangle rect = document.getPageSize(); 
        
        if(MedwanQuery.getInstance().getConfigInt("pdfFooterTop",0)==1){
        	// footer text
	        ColumnText.showTextAligned(writer.getDirectContent(),
	                                   Element.ALIGN_CENTER, 
	                                   new Phrase(sFooterText,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)6*fontSizePercentage/100.0))),
	                                   (rect.getLeft()+rect.getRight())/2,rect.getTop()-26,0);
	        if(MedwanQuery.getInstance().getConfigInt("showFooterPageNumber",1)==1){
		        // page count
		        ColumnText.showTextAligned(writer.getDirectContent(),
		                                   Element.ALIGN_CENTER,
		                                   new Phrase(pagecount+"",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)6*fontSizePercentage/100.0))),
		                                   (rect.getLeft()+rect.getRight())/2,rect.getTop()-18,0);
	        }
        }
        else{
        	// footer text
	        ColumnText.showTextAligned(writer.getDirectContent(),
	                                   Element.ALIGN_CENTER,
	                                   new Phrase(sFooterText,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)6*fontSizePercentage/100.0))),
	                                   (rect.getLeft()+rect.getRight())/2,rect.getBottom()+26,0);
	        
	        if(MedwanQuery.getInstance().getConfigInt("showFooterPageNumber",1)==1){
		        // page count
		        ColumnText.showTextAligned(writer.getDirectContent(),
	                                       Element.ALIGN_CENTER,
	                                       new Phrase(pagecount+"",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)6*fontSizePercentage/100.0))),
	                                       (rect.getLeft()+rect.getRight())/2,rect.getBottom()+18,0);
	        }
        }
    }

}
