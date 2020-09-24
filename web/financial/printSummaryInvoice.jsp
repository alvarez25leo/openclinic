<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.*"%>
<%@ page import="be.openclinic.finance.*" %>
<%
    String sInvoiceUid    = checkString(request.getParameter("SummaryInvoiceUID"));
    ByteArrayOutputStream baosPDF = null;

    try{
        // PDF generator
        SummaryInvoice invoice = SummaryInvoice.get(sInvoiceUid);
        sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
        PDFInvoiceGenerator pdfGenerator = null;
        if(checkString(request.getParameter("invoiceType")).equalsIgnoreCase("MFPSummary")){
        	pdfGenerator= new PDFSummaryInvoiceGeneratorMFP(activeUser,invoice.getPatient(),sProject,sWebLanguage);
        }
        else{
        	pdfGenerator= new PDFSummaryInvoiceGenerator(activeUser,invoice.getPatient(),sProject,sWebLanguage);
        }
        baosPDF = pdfGenerator.generatePDFDocumentBytes(request,sInvoiceUid);

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
        writer.println(this.getClass().getName()+ " caught an exception: "+ dex.getClass().getName()+ "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally{
        if(baosPDF != null) {
            baosPDF=null;
        }
    }
%>