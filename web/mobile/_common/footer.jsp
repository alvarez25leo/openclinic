<script>
  Event.observe(window,"load",function(){changeInputColor();});

  function logOut(){
    document.location.href = "<%=sCONTEXTPATH%>/mobileLogout.do?ts=<%=new java.util.Date().hashCode()%>";
  }
  function doNewSearch(){
    window.location.href = "searchPatient.jsp?ts=<%=new java.util.Date().hashCode()%>";
  }
  function showPatientMenu(){
    window.location.href = "patientMenu.jsp?ts=<%=new java.util.Date().hashCode()%>";
  }
</script>
 
<%
    // credits
    if(!sUriPage.endsWith("welcome.jsp") && !sUriPage.endsWith("login.jsp")){
	    %><div style="color:#999;text-align:right;font-size:9px">GA Open Source Edition by Post-Factum bvba</div><%
	}
%>
</body>
</html>