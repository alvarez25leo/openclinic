<%@page import="java.util.Vector,java.util.Hashtable"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindLastname   = checkString(request.getParameter("FindLastname")),
           sFindFirstname  = checkString(request.getParameter("FindFirstname")),
           sFindDOB        = checkString(request.getParameter("FindDOB")),
           sFindGender     = checkString(request.getParameter("FindGender")),
           sReturnPersonID = checkString(request.getParameter("ReturnPersonID")),
           sReturnFunction = checkString(request.getParameter("ReturnFunction")),
           sPersonID       = checkString(request.getParameter("PersonID")),
           sNatReg         = checkString(request.getParameter("NatReg")),
           sSetGreenField  = checkString(request.getParameter("SetGreenField"));

    if(sReturnPersonID.length()==0){
        sReturnPersonID = checkString(request.getParameter("ReturnField"));
    }

    String sReturnName = checkString(request.getParameter("ReturnName"));
    boolean bIsUser = checkString(request.getParameter("isUser")).equalsIgnoreCase("yes");
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* _common/search/searchPatient.jsp *******************");
    	Debug.println("sFindLastname   : "+sFindLastname);
    	Debug.println("sFindFirstname  : "+sFindFirstname);
    	Debug.println("sFindDOB        : "+sFindDOB);
    	Debug.println("sFindGender     : "+sFindGender);
    	Debug.println("sReturnPersonID : "+sReturnPersonID);
    	Debug.println("sReturnFunction : "+sReturnFunction);
    	Debug.println("sPersonID       : "+sPersonID);
    	Debug.println("sNatReg         : "+sNatReg);
    	Debug.println("sSetGreenField  : "+sSetGreenField+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="SearchForm" method="POST" onsubmit="doFind();return false;" onkeydown="if(enterEvent(event,13)){doFind();}">
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <%-- search fields row 1 --%>
        <tr height="25">
            <td class="admin2" nowrap>&nbsp;<%=getTran(request,"Web","name",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td class="admin2" nowrap>
                <input type="text" name="FindLastname" class="text" value="<%=sFindLastname%>" onblur="limitLength(this);">
            </td>
            
            <td class="admin2" nowrap>&nbsp;<%=getTran(request,"Web","firstname",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td class="admin2" nowrap>
                <input type="text" name="FindFirstname" class="text" value="<%=sFindFirstname%>" onblur="limitLength(this);">
            </td>
        </tr>
        <%
            if(!bIsUser){
        %>
        <%-- search fields row 2 --%>
        <tr>
            <td class="admin2" height="25" nowrap>&nbsp;<%=getTran(request,"Web","dateofbirth",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td class="admin2" nowrap>
                <input type="text" name="FindDOB" class="text" value="<%=sFindDOB%>" onblur="checkDate(this);">
            </td>
            
            <td class="admin2" nowrap>&nbsp;<%=getTran(request,"Web","gender",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td class="admin2" nowrap>
                <select class="text" name="FindGender">
                    <option/>
                    <option value="M"<%=(sFindGender.equalsIgnoreCase("m")?" selected":"")%>>M</option>
                    <option value="F"<%=(sFindGender.equalsIgnoreCase("f")?" selected":"")%>>F</option>
                </select>&nbsp;
            </td>
        </tr>
        
        <%-- search fields row 3 --%>
        <tr>
            <td class="admin2" class="admin2" height="25" nowrap>&nbsp;<%=getTran(request,"Web", "personid", sWebLanguage)%>&nbsp;&nbsp;</td>
            <td class="admin2" class="admin2" nowrap>
                <input type="text" name="PersonID" class="text" value="<%=sPersonID%>"/>
            </td>
            <%if(MedwanQuery.getInstance().getConfigString("edition").equalsIgnoreCase("bloodbank")){ %>
	            <td class="admin2" class="admin2" height="25" nowrap>&nbsp;<%=getTran(request,"Web", "giftid", sWebLanguage)%>&nbsp;&nbsp;</td>
	            <td class="admin2" class="admin2" nowrap>
	                <input type="text" name="giftid" id="giftid" class="text" value="<%=sPersonID%>"/>
	            </td>
            <%}
              else{%>
	            <td class="admin2" class="admin2" height="25" nowrap>&nbsp;<%=getTran(request,"web", "natreg", sWebLanguage)%>&nbsp;&nbsp;</td>
              	<td class='admin2'>
              		<input type='hidden' name='giftid' id='giftid'/>
	                <input type="text" name="NatReg" class="text" value="<%=sNatReg%>"/>
              	</td>
            <%} %>
        </tr>
        <%
            }
        %>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2">&nbsp;</td>
            <td class="admin2" height="25" colspan="3">
                <input class="button" type="button" name="buttonfind" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onClick="doFind();">&nbsp;
                <input class="button" type="button" name="buttonclear" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearFields();">
            </td>
        </tr>
        
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td style="vertical-align:top;" colspan="4" align="center" class="white" width="100%">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>

    <%-- hidden fields --%>
    <input type="hidden" name="isUser" value="<%=checkString(request.getParameter("isUser"))%>">
    <input type="hidden" name="displayImmatNew" value="<%=checkString(request.getParameter("displayImmatNew"))%>">
    <input type="hidden" name="ReturnPersonID" value="<%=sReturnPersonID%>">
    <input type="hidden" name="ReturnName" value="<%=sReturnName%>">
    <input type="hidden" name="SetGreenField" value="<%=sSetGreenField%>">
    <br>
    
    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
    </center>
</form>

<script>
  window.resizeTo(500,540);

  <%-- CLEAR FIELDS --%>
  function clearFields(){
    SearchForm.FindLastname.value = "";
    SearchForm.FindFirstname.value = "";
    SearchForm.FindDOB.value = "";
    SearchForm.FindGender.selectedIndex = -1;
    SearchForm.PersonID.value = "";
    
    SearchForm.FindLastname.focus();
  }

  <%-- DO FIND --%>
  function doFind(){
    if(SearchForm.FindDOB.value.length > 0){
      if(checkDate(SearchForm.FindDOB)){
        ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientShow.jsp', SearchForm);
      }
      else{
        SearchForm.FindDOB.value = "";
        SearchForm.FindDOB.focus();
      }
    }
    else{
      ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientShow.jsp', SearchForm);
    }
  }

  <%-- SET PERSON --%>
  function setPerson(sPersonID, sName){
    window.opener.document.getElementsByName("<%=sReturnPersonID%>")[0].value = sPersonID;

    if("<%=sSetGreenField%>" != ""){
      window.opener.document.getElementsByName("<%=sSetGreenField%>")[0].className = "green";
    }

    if("<%=sReturnName%>" != ""){
      window.opener.document.getElementsByName("<%=sReturnName%>")[0].value = sName;
    }

	<%
	    if(sReturnFunction.length()>0){
		    %>window.opener.<%=sReturnFunction%>;<%
        }
	%>

    window.close();
  }

  <%-- ADD PERSON --%>
  function addPerson(){
    if(($("FindLastname").value.length>0)&&($("FindFirstname").value.length>0)&&($("FindDOB").value.length>0)&&($("FindGender").value.length>0)){
      ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientAdd.jsp', SearchForm);
    }
    else{
      alertDialog("web","somefieldsareempty");
    }
  }
    
  window.setTimeout("SearchForm.FindLastname.focus();",300);
</script>