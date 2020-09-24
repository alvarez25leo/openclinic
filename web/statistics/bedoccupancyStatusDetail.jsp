<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd")),
           sBedId     = checkString(request.getParameter("BedID")),
           sBedName   = checkString(request.getParameter("BedName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*************** statistics/bedoccupancyStatusDetail.jsp ***************");
    	Debug.println("sFindBegin : "+sFindBegin);
    	Debug.println("sFindEnd   : "+sFindEnd);
    	Debug.println("sBedId     : "+sFindBegin);
    	Debug.println("sBedName   : "+sBedName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    if(sFindBegin.length()==0){
        sFindBegin = getDate();
    }

    if(sFindEnd.length()==0){
        sFindEnd = getDate(); 
    }
%>
<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doSearch();}">
    <%=writeTableHeader("Web","executive.bedoccupancy",sWebLanguage)%><br>
    
    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
        <tr class="admin">
            <td colspan="2"><%=getTran(request,"web","bed",sWebLanguage)+" "+sBedName%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"Web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"Web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearch();">
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                <input type="button" class="button" name="backClose" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="doClose();">
            </td>
        </tr>
    </table>

<script>
  transactionForm.FindBegin.focus();

  function doSearch(){
    transactionForm.ButtonSearch.disabled = true;
    transactionForm.ButtonClear.disabled = true;
    transactionForm.submit();
  }

  function clearSearchFields(){
    transactionForm.FindBegin.value = "";
    transactionForm.FindEnd.value = "";
    
    transactionForm.FindBegin.focus();
  }

  function doClose(){
    window.close();
  }
</script>

<%
    if(sBedId.length() > 0){
        String sSelect = "SELECT * FROM OC_ENCOUNTERS_VIEW"+
                         " WHERE OC_ENCOUNTER_BEDUID = ?"+
                         "  AND OC_ENCOUNTER_BEGINDATE >= ?"+
                         "  AND (OC_ENCOUNTER_ENDDATE <= ? OR OC_ENCOUNTER_ENDDATE IS NULL)"+
                         " ORDER BY OC_ENCOUNTER_BEGINDATE";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sSelect);
        ps.setString(1,sBedId);
        ps.setDate(2,ScreenHelper.getSQLDate(sFindBegin));
        ps.setDate(3,ScreenHelper.getSQLDate(sFindEnd));
        ResultSet rs = ps.executeQuery();
        String sPatientID, sServiceID, sBeginDate, sEndDate;
        int iTotal = 0;
        
        if(rs.next()){
        	rs.beforeFirst(); // revert
        	
	        while(rs.next()){
	            iTotal++;
	            
	            if(iTotal==1){
	                out.print("<br>"+
	                          "<table class='sortable' id='searchresults' width='100%' cellspacing='1' cellpadding='0'>");
	                          
	                // header
	                out.print("<tr class='admin'>"+
	                           "<td>"+getTran(request,"web","service",sWebLanguage)+"</td>"+
	                           "<td>"+getTran(request,"web","person",sWebLanguage)+"</td>"+
	                           "<td width='80'>"+getTran(request,"web","begin",sWebLanguage)+"</td>"+
	                           "<td width='80'>"+getTran(request,"web","end",sWebLanguage)+"</td>"+
	                          "</tr>");
	            }
	            
	            sPatientID = checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
	            if(sPatientID.length() > 0){
	              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
	                sPatientID = ScreenHelper.getFullPersonName(sPatientID,ad_conn);
	                ad_conn.close();
	            }
	
	            sServiceID = checkString(rs.getString("OC_ENCOUNTER_SERVICEUID"));
	            if(sServiceID.length()>0){
	                sServiceID = getTran(request,"service",sServiceID,sWebLanguage);
	            }
	            
	            sBeginDate = ScreenHelper.getSQLDate(rs.getDate("OC_ENCOUNTER_BEGINDATE"));
	            sEndDate = ScreenHelper.getSQLDate(rs.getDate("OC_ENCOUNTER_ENDDATE"));
	            
	            %><tr class="list"><td><%=sServiceID%></td><td><%=sPatientID%></td><td><%=sBeginDate%></td><td><%=sEndDate%></td></tr><%
	        }

	        out.print("</table>");
	        
	        out.print(getTran(request,"web","total",sWebLanguage)+": "+iTotal+"<br>");
        	%><%=iTotal%> <%=getTran(request,"web","recordsFound",sWebLanguage)%><%
        }
        else{
        	%><%=getTran(request,"web","noRecordsFound",sWebLanguage)%><%
        }
        
        rs.close();
        ps.close();
        oc_conn.close();
        
        // close-button
        out.print("<center><input type='button' class='button' value='"+getTranNoLink("web","close",sWebLanguage)+"' onclick='window.close()'/></center>");
    }
%>
</form>