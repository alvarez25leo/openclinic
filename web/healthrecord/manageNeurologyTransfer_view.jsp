<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"occup.neurologytransfer","select",activeUser)%>
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
    <%--  TRANSFER DATE --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran(request,"Web.occup","neurology_transfer_transferdate",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" width="100%">
            <input type="text" class="text" size="12" maxLength="10" id="transferDate" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERDATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERDATE" property="value" formatType="date"/>"/>
            <script>writeMyDate("transferDate");</script>
        </td>
    </tr>
    <%--  CONSULTATION MOTIF --%>
    <tr>
        <td class="admin"><%=getTran(request,"Web.occup","neurology_transfer_consultationmotif",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_NEUROLOGY_TRANSFER_CONSULTATIONMOTIF")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_CONSULTATIONMOTIF" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_CONSULTATIONMOTIF" property="value"/></textarea>

            <%-- select a macro --%>
            <a  style="vertical-align:top;" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' onclick="showTerminologyList(this);">
                <img title="<%=getTranNoLink("web","terminologylist",sWebLanguage)%>" src="<c:url value="/_img/icons/icon_help.gif"/>">
            </a>
        </td>
    </tr>
    <%--  SUMMARY WORK DONE WITH PATIENT --%>
    <tr>
        <td class="admin"><%=getTran(request,"Web.occup","neurology_transfer_summaryworkdonewithpatient",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_NEUROLOGY_TRANSFER_SUMMARY_WORK_DONE_WITH_PATIENT ")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_SUMMARY_WORK_DONE_WITH_PATIENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_SUMMARY_WORK_DONE_WITH_PATIENT" property="value"/></textarea>

            <%-- select a macro --%>
            <a  style="vertical-align:top;" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' onclick="showTerminologyList(this);">
                <img title="<%=getTranNoLink("web","terminologylist",sWebLanguage)%>" src="<c:url value="/_img/icons/icon_help.gif"/>">
            </a>
        </td>
    </tr>
    <%-- TRANSFER MOTIF --%>
    <tr>
        <td class="admin"><%=getTran(request,"Web.occup","neurology_transfer_transfermotif",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERMOTIF")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERMOTIF" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERMOTIF" property="value"/></textarea>

            <%-- select a macro --%>
            <a  style="vertical-align:top;" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' onclick="showTerminologyList(this);">
                <img title="<%=getTranNoLink("web","terminologylist",sWebLanguage)%>" src="<c:url value="/_img/icons/icon_help.gif"/>">
            </a>
        </td>
    </tr>
    <%-- TRANSFER TREATMENT --%>
    <tr>
        <td class="admin"><%=getTran(request,"Web.occup","neurology_transfer_transfertreatment",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERTREATMENT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERTREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERTREATMENT" property="value"/></textarea>
        </td>
    </tr>
<%-- BUTTONS --%>
    <tr>
        <td class="admin"/>
        <td class="admin2">
    <%
        if(activeUser.getAccessRight("occup.neurologytransfer.add") || activeUser.getAccessRight("occup.neurologytransfer.edit")){
            %><INPUT class="button" type="button" name="saveButton" id="saveButton" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="submitForm();"/><%
        }
    %>
            <INPUT class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="doBack();">
        </td>
    </tr>
</table>
<script>
  document.getElementById("transferDate").focus();

  <%-- --%>
  function showTerminologyList(inputObj){
    openPopup("/_common/search/terminologyList.jsp&ReturnField="+inputObj.name);
  }

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
      window.location.href='<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }
</script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>