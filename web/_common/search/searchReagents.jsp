<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sFindReagentName = checkString(request.getParameter("FindReagentName"));
    String sFunction = checkString(request.getParameter("doFunction"));
    
    String sReturnFieldUid   = checkString(request.getParameter("ReturnFieldUid")),
           sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr")),
           sReturnFieldUnit  = checkString(request.getParameter("ReturnFieldUnit"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* _common/search/searchReagents.jsp ******************");
    	Debug.println("sFindReagentName  : "+sFindReagentName);
    	Debug.println("sFunction         : "+sFunction);
    	Debug.println("sReturnFieldUid   : "+sReturnFieldUid);
    	Debug.println("sReturnFieldDescr : "+sReturnFieldDescr);
    	Debug.println("sReturnFieldUnit  : "+sReturnFieldUnit+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="SearchForm" method="POST" onkeyup="if(enterEvent(event,13)){searchReagents();}">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="ReturnFieldUid" value="<%=sReturnFieldUid%>">
    <input type="hidden" name="ReturnFieldDescr" value="<%=sReturnFieldDescr%>">
    <input type="hidden" name="ReturnFieldUnit" value="<%=sReturnFieldUnit%>">

    <%=writeTableHeader("web.manage","searchreagent",sWebLanguage," window.close();")%>
    <table width="100%" cellspacing="1" cellpadding="0" class="menu">
        <%
            if(!"no".equalsIgnoreCase(request.getParameter("header"))){
        %>
        <%-- NAME --%>
        <tr>
            <td class="admin2" width="120" nowrap><%=getTran(request,"web","name",sWebLanguage)%></td>
            <td class="admin2" width="380" nowrap>
                <input type="text" class="text" name="FindReagentName" id="FindReagentName" size="20" maxlength="20" value="<%=sFindReagentName%>" onkeyup="searchReagents();">
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr height="25">
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="searchReagents();" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">
            </td>
        </tr>
        <%
            }
        %>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td style="vertical-align:top;" colspan="2" class="white" width="100%">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>
    <br>
    
    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
    </center>
</form>

<script>
  window.resizeTo(800,600);
  window.setTimeout("SearchForm.FindReagentName.focus();",300);

  function clearFields(){
    SearchForm.FindReagentName.value = "";
    SearchForm.FindReagentName.focus();
  }

  <%-- SEARCH REAGENTS --%>
  function searchReagents(){
    SearchForm.Action.value = "search";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchReagentShow.jsp',SearchForm);
  }

  <%-- SET REAGENT --%>
  function setReagent(uid,descr,unit){
    if("<%=sReturnFieldUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldUid%>")[0].value = uid;
    }
    if("<%=sReturnFieldDescr%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldDescr%>")[0].value = descr;
    }
    if("<%=sReturnFieldUnit%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldUnit%>")[0].value = unit;
    }

    <%
	    if(sFunction.length() > 0){
	        out.print("window.opener."+sFunction+";");
	    }
    %>

    window.close();
  }
  
  window.setTimeout("document.getElementsByName('FindReagentName')[0].focus();",300);
</script>