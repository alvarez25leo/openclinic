<%@ page import="be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name="transactionForm">
<table width="100%">
<%
	Vector invoices = InsurarInvoice.searchInvoices(request.getParameter("start"),request.getParameter("end"),"","","");
	boolean bHasClosedInvoice=false;
	for(int n=invoices.size()-1;n>=0;n--){
		InsurarInvoice invoice=(InsurarInvoice)invoices.elementAt(n);
		if(invoice.getInsurarUid().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("MFP"))){
			if(checkString(request.getParameter("serviceid")).length()==0 || invoice.hasDebetsForService(checkString(request.getParameter("serviceid")))){
				out.println("<tr><td class='admin'>"+(invoice.getStatus().equalsIgnoreCase("closed")?"<input type='checkbox' name='inv-"+invoice.getUid()+"' checked/>":getTran(request,"finance.patientinvoice.status",invoice.getStatus(),sWebLanguage))+"</td><td class='admin'>"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"</td><td class='admin2'>"+invoice.getUid()+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</tr>");
				if(invoice.getStatus().equalsIgnoreCase("closed")){
					bHasClosedInvoice=true;
				}
			}
		}
	}
%>
</table>
<%
	if(bHasClosedInvoice){
%>
<input type='button' class='button' name='print' value='<%=getTranNoLink("web","print",sWebLanguage)%>' onclick='printSummary()'/>
<%
	}
%>
</form>

<script>
function printSummary(){
	var invoiceuids="";
	var all=document.getElementsByTagName("*");
	for(n=0;n<all.length;n++){
		if(all[n].name && all[n].name.indexOf("inv-")>-1){
			if(invoiceuids.length>0){
				invoiceuids+=";";
			}
			invoiceuids+=all[n].name.split("-")[1];
		}
	}
	if(invoiceuids.length>0){
	    window.open("<c:url value="/statistics/createMFPSummaryPdf.jsp"/>?invoiceUids="+invoiceuids);
		window.close();
	}
	else {
		alert('<%=getTranNoLink("web","noclosedinvoiceselected",sWebLanguage)%>');
	}
}
</script>
