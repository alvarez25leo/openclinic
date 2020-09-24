<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission(out,"occup.protocol.oesophagogastroduodenoscopy","select",activeUser)%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
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
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2"/>
        </tr>

        <%-- motive / premedication --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","motive",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_MOTIVE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_MOTIVE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","premedication",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PREMEDICATION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PREMEDICATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PREMEDICATION" property="value"/></textarea>
            </td>
        </tr>

        <%-- endoscopy_type / oesophago --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","endoscopy_type",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ENDOSCOPY_TYPE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ENDOSCOPY_TYPE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ENDOSCOPY_TYPE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","oesophago",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_OESOPHAGO")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_OESOPHAGO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_OESOPHAGO" property="value"/></textarea>
            </td>
        </tr>
    </table>

    <br>

    <table class="list" width="100%" cellspacing="1">
        <%-- cardia / empty --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"openclinic.chuk","cardia",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CARDIA")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CARDIA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CARDIA" property="value"/></textarea>
            </td>
        </tr>

        <%-- stomach / pylorus --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"openclinic.chuk","stomach",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_STOMACH")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_STOMACH" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_STOMACH" property="value"/></textarea>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"openclinic.chuk","pylorus",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PYLORUS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PYLORUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PYLORUS" property="value"/></textarea>
            </td>
        </tr>

        <%-- liquide_quantity_aspect / bulb --%>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran(request,"openclinic.chuk","liquide_quantity_aspect",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_LIQUIDE_QUANTITY_ASPECT")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_LIQUIDE_QUANTITY_ASPECT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_LIQUIDE_QUANTITY_ASPECT" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","bulb",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BULB")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BULB" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BULB" property="value"/></textarea>
            </td>
        </tr>

        <%-- pH / duodenum --%>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran(request,"openclinic.chuk","pH",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PH")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PH" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PH" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","duodenum",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_DUODENUM")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_DUODENUM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_DUODENUM" property="value"/></textarea>
            </td>
        </tr>

        <%-- fundus / Investigations_done --%>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran(request,"openclinic.chuk","fundus",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_FUNDUS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_FUNDUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_FUNDUS" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","Investigations_done",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BIOSCOPY")%> type="checkbox" id="central"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BIOSCOPY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BIOSCOPY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="central"><%=getTran(request,"openclinic.chuk","biopsy",sWebLanguage)%></label>
            </td>
        </tr>

        <%-- antre / conclusion --%>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran(request,"openclinic.chuk","antre",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ANTRE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ANTRE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ANTRE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CONCLUSION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>

        <%-- remarks --%>
        <tr>
            <td class="admin" style="vertical-align:top;"><%=getTran(request,"openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2" style="vertical-align:top;">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_REMARKS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_REMARKS" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2">
            	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.protocol.oesophagogastroduodenoscopy",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>
    
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    if(<%=((TransactionVO)transaction).getServerId()%>==1 && document.getElementById('encounteruid').value=='' <%=request.getParameter("nobuttons")==null?"":" && 1==0"%>){
		alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
		searchEncounter();
	}	
    else {
	    document.getElementById("buttonsDiv").style.visibility = "hidden";
	    var temp = Form.findFirstElement(transactionForm);// for ff compatibility
	    document.transactionForm.submit();
    }
  }
  function searchEncounter(){
      openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&Varcode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  if(<%=((TransactionVO)transaction).getServerId()%>==1 && document.getElementById('encounteruid').value=='' <%=request.getParameter("nobuttons")==null?"":" && 1==0"%>){
	alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	searchEncounter();
  }	
  
</script>