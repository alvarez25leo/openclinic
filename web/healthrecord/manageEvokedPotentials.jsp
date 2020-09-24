<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"occup.ep","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value='/healthrecord/updateTransaction.do'/>?ts=<%=getTs()%>" focus='type'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp?ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
     
    <table class="list" width="100%" cellspacing="1">
        <tr>
            <td style="vertical-align:top;padding:0" class="admin2" width="50%">    
	            <table class="list" width='100%' border='0' cellspacing="1">
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
	                    
	                <%--  DONNEES CLINIQUES --%>
	                <tr>
	                   <td width ="<%=sTDAdminWidth%>" class='admin'><%=getTran(request,"web","ep.clinicaldata",sWebLanguage)%>&nbsp;</td>
	                   <td class='admin2'>
	                       <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick(session,"ITEM_TYPE_EP_CLINICALDATA")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_CLINICALDATA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_CLINICALDATA" property="value"/></textarea>
	                   </td>
	                </tr>
	            
	                <%--  MODALITE D ETUDE --%>
	                <tr>
	                    <td class='admin'><%=getTran(request,"web","ep.studymodality",sWebLanguage)%>&nbsp;</td>
	                    <td class='admin2'>
	                        <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick(session,"ITEM_TYPE_EP_STUDYMODALITY")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_STUDYMODALITY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_STUDYMODALITY" property="value"/></textarea>
	                    </td>
	                </tr>
	            
	                <%-- RESULTATS --%>
	                <tr>
	                    <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran(request,"web","results",sWebLanguage)%>&nbsp;</td>
	                    <td class="admin2" width="100%">
	                        <input <%=setRightClick(session,"ITEM_TYPE_EP_RESULTS")%> type="radio" id="resultRadio1" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_RESULTS" property="itemId"/>]>.value" value="medwan.results.normal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_RESULTS;value=medwan.results.normal" property="value" outputString="checked"/>><%=getLabel(request,"web","medwan.results.normal",sWebLanguage,"resultRadio1")%>
	                        <input <%=setRightClick(session,"ITEM_TYPE_EP_RESULTS")%> type="radio" id="resultRadio2" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_RESULTS" property="itemId"/>]>.value" value="medwan.results.abnormal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_RESULTS;value=medwan.results.abnormal" property="value" outputString="checked"/>><%=getLabel(request,"web","medwan.results.abnormal",sWebLanguage,"resultRadio2")%>
	                    </td>
	                </tr>
	                
	                <%-- DESCRIPTION --------------------------------------------------------%>
	                <tr class="admin">
	                    <td colspan="3"><%=getTran(request,"Web.Occup","medwan.healthrecord.description",sWebLanguage)%></td>
	                </tr>
	                
	                <%-- RAPPORT TECHNIQUE --%>
	                <tr>
	                    <td class='admin'><%=getTran(request,"web","technical.report",sWebLanguage)%>&nbsp;</td>
	                    <td class='admin2'>
	                        <textarea <%=setRightClick(session,"ITEM_TYPE_EP_TECHNICAL_REPORT")%> onKeyup="resizeTextarea(this,10);" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_TECHNICAL_REPORT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_TECHNICAL_REPORT" property="value"/></textarea>
	                    </td>
	                </tr>
	            
	                <%-- RESULTATS --%>
	                <tr>
	                    <td class='admin'><%=getTran(request,"web","results",sWebLanguage)%>&nbsp;</td>
	                    <td class='admin2'>
	                        <textarea <%=setRightClick(session,"ITEM_TYPE_EP_RESULTS_DESCRIPTION")%> onKeyup="resizeTextarea(this,10);" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_RESULTS_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_RESULTS_DESCRIPTION" property="value"/></textarea>
	                    </td>
	                </tr>
	            
	                <%-- CONCLUSION --%>
	                <tr>
	                    <td class='admin'><%=getTran(request,"web","conclusion",sWebLanguage)%>&nbsp;</td>
	                    <td class='admin2'>
	                        <textarea <%=setRightClick(session,"ITEM_TYPE_EP_CONCLUSION")%> onKeyup="resizeTextarea(this,10);" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EP_CONCLUSION" property="value"/></textarea>
	                    </td>
	                </tr>
	            </table>
	        </td>
	       
	        <%-- DIAGNOSIS --%>
	        <td class="admin" style="vertical-align:top;">
	            <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	        </td>
	    </tr>
	</table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>                    
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.ep",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  function submitForm(){
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    document.transactionForm.submit();
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>