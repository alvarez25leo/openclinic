<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory,java.util.StringTokenizer" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission(out,"occup.physioreport","select",activeUser)%>

<%
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();
%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
   
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        
        <%-- Report--%>
        <tr>
            <td class="admin"><%=getTran(request,"Web.Occup","medwan.common.report",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick(session,"ITEM_TYPE_PHYSIO_REP_REPORT")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_REP_REPORT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_REP_REPORT" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- Conclusion--%>
        <tr>
            <td class="admin"><%=getTran(request,"Web.Occup","medwan.common.conclusion",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick(session,"ITEM_TYPE_PHYSIO_REP_CONCLUSION")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_REP_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_REP_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>
    </table>
        
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.physioreport",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = '<c:url value="/main.do?Page=curative/index.jsp&ts="/><%=getTs()%>';
    }
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
    if(<%=((TransactionVO)transaction).getServerId()%>==1 && document.getElementById('encounteruid').value=='' <%=request.getParameter("nobuttons")==null?"":" && 1==0"%>){
	  alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	  searchEncounter();
	}	
    else{
	  transactionForm.saveButton.disabled = true;
	  <%
	      SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
	      out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
	  %>
    }
  }
  
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&Varcode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if(<%=((TransactionVO)transaction).getServerId()%>==1 && document.getElementById('encounteruid').value=='' <%=request.getParameter("nobuttons")==null?"":" && 1==0"%>){
	alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	searchEncounter();
  }	

  <%-- DO SAVE --%>
  function doSave(printDocument){
    if(printDocument){
      document.getElementsByName('be.mxs.healthrecord.updateTransaction.actionForwardKey')[0].value = "/healthrecord/editTransaction.do?ForwardUpdateTransactionId=true&printPDF=true&PrintLanguage="+transactionForm.PrintLanguage.value+"&ts=<%=getTs()%>";
      window.open("","newwindow","height=600, width=850, toolbar=yes, status=yes, scrollbars=yes, resizable=yes, menubar=yes");
      document.transactionForm.target = 'newwindow';
    }
      
    submitForm();
  }

  <%-- CREATE OFFICIAL PDF --%>
  function createOfficialPdf(printLang){
    var tranID = "<%=checkString(request.getParameter("be.mxs.healthrecord.transaction_id"))%>";
    var serverID = "<%=checkString(request.getParameter("be.mxs.healthrecord.server_id"))%>";

    window.location.href = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp?tranAndServerID_1="+tranID+"_"+serverID+"&PrintLanguage="+printLang+"&ts=<%=getTs()%>";

    window.opener.document.transactionForm.saveButton.disabled = false;
    window.opener.document.transactionForm.SaveAndPrint.disabled = false;
    window.opener.bSaveHasNotChanged = true;
    window.opener.location.reload();
    window.opener.location.href = "main.do?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  <%
      boolean printPDF = checkString(request.getParameter("printPDF")).equals("true");
      if(printPDF){
          String sPrintLanguage = checkString(activePatient.language);
          if(sPrintLanguage.length()==0){
              sPrintLanguage = sWebLanguage;
          }
          
          %>createOfficialPdf('<%=sPrintLanguage%>');<%
      }
  %>
</script>

<%=writeJSButtons("transactionForm","saveButton")%>