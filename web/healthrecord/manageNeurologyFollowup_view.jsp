<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"occup.neurologyfollowup","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

<%=contextHeader(request,sWebLanguage)%>
<table class="list" width="100%" cellspacing="1">
    <%-- DATE --%>
    <tr>
        <td class="admin">
            <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeTranDate();</script>
        </td>
    </tr>
    <%--  DESCRIPTION --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran(request,"Web.occup","neurology_followup_description",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" width="100%">
            <textarea id="focusField" onKeyup="resizeTextarea(this,10);limitChars(this5000);" <%=setRightClick(session,"ITEM_TYPE_NEUROLOGY_FOLLOWUP_DESCRIPTION")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_FOLLOWUP_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_FOLLOWUP_DESCRIPTION" property="value"/></textarea>
        </td>
    </tr>
    <%--  THERAPEUTICAL MODIFICATIONS --%>
    <tr>
        <td class="admin"><%=getTran(request,"Web.occup","neurology_followup_therapeutical_modifications",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_NEUROLOGY_FOLLOWUP_THERAPEUTICAL_MODIFICATIONS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_FOLLOWUP_THERAPEUTICAL_MODIFICATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_FOLLOWUP_THERAPEUTICAL_MODIFICATIONS" property="value"/></textarea>
        </td>
    </tr>
</table>
    
<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <%=getButtonsHtml(request,activeUser,activePatient,"occup.neurologyfollowup",sWebLanguage)%>
<%=ScreenHelper.alignButtonsStop()%>

<script>
  document.getElementById("focusField").focus();

  <%-- SUBMIT FORM --%>
  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href='<c:url value="/main.do?Page=curative/index.jsp&ts="/><%=getTs()%>';
    }
  }
</script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>