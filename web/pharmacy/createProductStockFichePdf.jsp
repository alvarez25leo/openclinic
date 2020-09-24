<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFProductStockFicheGenerator"%>

<%
    String sProductStockUid = checkString(request.getParameter("ProductStockUid")),
           sFicheYear       = checkString(request.getParameter("FicheYear")),
           sPrintLanguage   = activeUser.person.language;

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n**************** pharmacy/createProductStockFichePdf.jsp **************");
		Debug.println("sProductStockUid : "+sProductStockUid);
		Debug.println("sFicheYear       : "+sFicheYear);
		Debug.println("sPrintLanguage   : "+sPrintLanguage+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    ByteArrayOutputStream baosPDF = null;

    try{
        // PDF generator
        PDFProductStockFicheGenerator generator = new PDFProductStockFicheGenerator(activeUser,sProject);
        baosPDF = generator.generatePDFDocumentBytes(request,sProductStockUid,sFicheYear,sPrintLanguage);

        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=")
                          .append(sbFilename);

        // prepare response
        response.setHeader("Cache-Control","max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition",sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
    catch(DocumentException dex){
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName()+ " caught an exception: "+dex.getClass().getName()+"<br>");
        
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally{
        if(baosPDF!=null){
            baosPDF.reset();
        }
    }
%>