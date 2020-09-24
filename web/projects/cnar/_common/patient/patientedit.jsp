<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String tab = checkString(request.getParameter("Tab"));
    if(tab.equals("")) tab = "Admin";

    boolean activePatientIsUser = false;
    if(activePatient!=null){
        activePatientIsUser = activePatient.isUser();
    }
%>
<form name="PatientEditForm" id="PatientEditForm" method="POST" action='<c:url value='/main.do'/>?Page=_common/patient/patienteditSave.jsp&SavePatientEditForm=ok&Tab=<%=tab%>&ts=<%=getTs()%>'>
    <%-- TABS -----------------------------------------------------------------------------------%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td style="border-bottom: 1px solid Black;" width="5">&nbsp;</td>
            <td class="tabunselected" width="1%" onclick="activateTab('Admin')" id="td0" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran(request,"Web","actualpersonaldata",sWebLanguage)%></b>&nbsp;</td>
            <td style="border-bottom: 1px solid Black;" width="5">&nbsp;</td>
            <td class="tabunselected" width="1%" onclick="activateTab('AdminPrivate')" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran(request,"Web","private",sWebLanguage)%></b>&nbsp;</td>
            <td style="border-bottom: 1px solid Black;" width="5">&nbsp;</td>
            <td class="tabunselected" width="1%" onclick="activateTab('AdminFamilyRelation')" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran(request,"Web","AdminFamilyRelation",sWebLanguage)%></b>&nbsp;</td>
            <td width="*" class='tabs'>&nbsp;</td>
        </tr>
    </table>
    <%-- ONE TAB --------------------------------------------------------------------------------%>
    <table width="100%" border="0" cellspacing="0">
        <tr id="tr0-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdmin.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr1-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdminPrivate.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr3-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdminFamilyRelation.jsp"),pageContext);%></td>
        </tr>
    </table>
    <%-- SAVE BUTTONS ---------------------------------------------------------------------------%>
    <%
        if (activeUser.getAccessRight("patient.administration.edit")){
            %>
                <div id="saveMsg"><%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>.</div>
                <%=ScreenHelper.alignButtonsStart()%>
                    <input class="button" type="button" name="SavePatientEditForm" value="<%=getTran(null,"Web","Save",sWebLanguage)%>" onclick="checkSubmit();">&nbsp;
                    <input class="button" type="button" name="cancel" value="<%=getTran(null,"Web","back",sWebLanguage)%>" onClick='window.location.href="<c:url value='/patientdata.do'/>?ts=<%=getTs()%>";'>&nbsp;
                <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    %>
<script>
  var maySubmit = true;
  var displayGenericAlert = true;

  <%-- CHECK SUBMIT --%>
  function checkSubmit(){
    maySubmit = true;
    if(maySubmit){ maySubmit = checkSubmitAdmin(); }
    if(maySubmit){ maySubmit = checkSubmitAdminPrivate(); }
    if(maySubmit){ maySubmit = checkSubmitAdminFamilyRelation(); }
    if(maySubmit){
      openPopup("/_common/patient/patienteditSavePopup.jsp&PersonID=<%=(activePatient!=null?activePatient.personid:"")%>&Lastname="+PatientEditForm.Lastname.value+"&Firstname="+PatientEditForm.Firstname.value+"&DateOfBirth="+PatientEditForm.DateOfBirth.value+"&ImmatNew=&NatReg="+PatientEditForm.NatReg.value+"&ts=<%=getTs()%>");
    }
    else if(displayGenericAlert){        
      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=somefieldsareempty";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","somefieldsareempty",sWebLanguage)%>");
    }
  }

  <%-- DO SUBMIT --%>
  function doSubmit(){
    PatientEditForm.SavePatientEditForm.disabled = true;
    PatientEditForm.submit();
  }

  <%-- ACTIVATE TAB --%>
  function activateTab(sTab){
    document.getElementById("tr0-view").style.display = "none";
    td0.className = "tabunselected";
    if(sTab=="Admin"){
      document.getElementById("tr0-view").style.display = "";
      td0.className = "tabselected";
      PatientEditForm.Lastname.focus();
      document.getElementById("saveMsg").style.display = "block";
    }

    document.getElementById("tr1-view").style.display = "none";
    td1.className = "tabunselected";
    if(sTab=="AdminPrivate"){
      document.getElementById("tr1-view").style.display = "";
      td1.className = "tabselected";
      PatientEditForm.PBegin.focus();
      document.getElementById("saveMsg").style.display = "block";
    }

    document.getElementById("tr3-view").style.display = "none";
    td3.className="tabunselected";
    if(sTab=="AdminFamilyRelation"){
      document.getElementById("tr3-view").style.display = "";
      td3.className = "tabselected";
      document.getElementById("saveMsg").style.display = "none";
    }

  }
  activateTab("<%=tab%>");
</script>
</form>