<%@page import="be.openclinic.pharmacy.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<form name="reports">
<%
	// production
	out.print(ScreenHelper.writeTblHeader(getTran(request,"web","pharmacy.reports.production",sWebLanguage),sCONTEXTPATH));
	out.println(writeTblChildWithCode("javascript:downloadTechnicalStats(\"undelivered.rwamaterial.orders\",\"openclinic\");",getTran(request,"Web","statistics.download.undelivered.rwamaterial.orders",sWebLanguage)));
	out.print(ScreenHelper.writeTblFooter()+"<br>");
	
	String stocks = "";
	Vector serviceStocks = ServiceStock.getStocksByUser(activeUser.userid);
	ServiceStock serviceStock;
	for(int n=0; n<serviceStocks.size(); n++){
		serviceStock = (ServiceStock)serviceStocks.elementAt(n);
		stocks+= "<option value='"+serviceStock.getUid()+"'>"+serviceStock.getName()+"</option>";
	}
	
	String firstdayPrevMonth = "01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100)),
	       lastdayPrevMonth = ScreenHelper.formatDate(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
	   	
	// search-fields
	out.print(ScreenHelper.writeTblHeader(getTran(request,"web","pharmacy.reports",sWebLanguage),sCONTEXTPATH));
	out.print("<tr><td class='admin' width='"+sTDAdminWidth+"'>"+ScreenHelper.uppercaseFirstLetter(getTranNoLink("web","date",sWebLanguage))+"&nbsp;</td><td class='admin2'>"+getTranNoLink("web","from",sWebLanguage)+"&nbsp;"+writeDateField("start","reports",firstdayPrevMonth,sWebLanguage)+"&nbsp;&nbsp;"+getTran(request,"web","to",sWebLanguage)+"&nbsp;"+writeDateField("end","reports",lastdayPrevMonth,sWebLanguage)+"&nbsp;</td></tr>");
	out.print("<tr><td class='admin'>"+getTran(request,"web","servicestock",sWebLanguage)+"&nbsp;</td><td class='admin2'><select name='servicestockuid' id='servicestockuid' class='text'>"+stocks+"</select></td></tr>");
	out.print(ScreenHelper.writeTblFooter()+"<br>");
   
	/*
	// stocks
	out.print(ScreenHelper.writeTblHeader(getTran(request,"web","pharmacy.reports.stocks",sWebLanguage),sCONTEXTPATH));
	out.print(ScreenHelper.writeTblFooter()+"<br>");
    */

	// products
	out.print(ScreenHelper.writeTblHeader(getTran(request,"web","pharmacy.reports.products",sWebLanguage),sCONTEXTPATH));
     out.print(writeTblChildWithCode("javascript:openPopup(\"pharmacy/expiredLots.jsp\",800,600,\"quickFile\")",getTran(request,"web","pharmacy.report.expiring.lots",sWebLanguage)));
	out.print(ScreenHelper.writeTblFooter()+"<br>");
    
	/**
	// supply
	out.print(ScreenHelper.writeTblHeader(getTran(request,"web","pharmacy.reports.supply",sWebLanguage),sCONTEXTPATH));
	 out.print(writeTblChildWithCode("javascript:pharmacyCsvReport(\"supplier.deliveries\")",getTran(request,"web","pharmacy.report.supplier.deliveries",sWebLanguage)));
  	out.print(ScreenHelper.writeTblFooter()+"<br>");
    **/
    
  	// outgoing
	out.print(ScreenHelper.writeTblHeader(getTran(request,"web","pharmacy.reports.outgoing",sWebLanguage),sCONTEXTPATH));
     out.print(writeTblChildWithCode("javascript:openPopup(\"pharmacy/patientDeliveries.jsp\",800,600,\"quickFile\")",getTran(request,"web","pharmacy.report.patientdeliveries",sWebLanguage)));
  	out.print(ScreenHelper.writeTblFooter()+"<br>");

%>
</form>

<script>
  function pharmacyCsvReport(sType){
    window.open("<c:url value="/"/>pharmacy/pharmacyCsvReport.jsp?type="+sType+"&start="+document.getElementById("start").value+
    		    "&end="+document.getElementById("end").value+"&servicestockuid="+document.getElementById("servicestockuid").value,1,1,"pharmacyreport");
  }
  
  function downloadTechnicalStats(query,db){
	    window.open("<c:url value='/util/csvStats.jsp?'/>query="+query+"&db="+db);
	  }

</script>