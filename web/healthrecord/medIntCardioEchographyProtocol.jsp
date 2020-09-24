<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"occup.protocol.cardioechography","select",activeUser)%>

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

    <%
        TransactionVO tran = (TransactionVO)transaction;
    
        String sAO          = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_AO"),
               sSeptum      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_SEPTUM"),
               sOg          = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OG"),
               sParoiPost   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PAROI_POST"),
               sDtdvgA      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGA"),
               sFe          = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_FE"),
               sDtdvgB      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGB"),
               sRaccouc     = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_RACCOUC"),
               sVd          = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VD"),
               sPericardium = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PERICARDIUM"),
               sMitralValve = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MITRAL_VALVE"),
               sValveAort   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_AORT"),
               sValveTric   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_TRIC"),
               sValvePulm   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_PULM");
    %>

    <table class="list" width="100%" cellspacing="1" border="0">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="3">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- motive/reason --%>
        <tr style="vertical-align:top;">
            <td class="admin"><%=getTran(request,"openclinic.chuk","motive",sWebLanguage)%></td>
            <td style="vertical-align:top;padding:0" class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MOTIVE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MOTIVE" property="value"/></textarea>
            </td>
            <td class="admin2" colspan="2">
                <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
            </td>
        </tr>

        <%-- lookfirst / mode --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","lookfirst",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_TRANS")%> type="checkbox" id="cbtrans" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_TRANS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_TRANS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="cbtrans"><%=getTran(request,"openclinic.chuk","cardio.transthoracique",sWebLanguage)%></label>
                &nbsp;&nbsp;&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_OESO")%> type="checkbox" id="cboeso" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_OESO" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_OESO;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="cboeso"><%=getTran(request,"openclinic.chuk","cardio.oesophagienne",sWebLanguage)%></label>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","mode",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_TM")%> type="checkbox" id="cbtm" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_TM" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_TM;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="cbtm"><%=getTran(request,"openclinic.chuk","tm",sWebLanguage)%></label>
                &nbsp;&nbsp;&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_2D")%> type="checkbox" id="cb2d" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_2D" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_2D;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="cb2d"><%=getTran(request,"openclinic.chuk","2d",sWebLanguage)%></label>
                &nbsp;&nbsp;&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MODE_DOPPLER")%> type="checkbox" id="cbdoppler" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MODE_DOPPLER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MODE_DOPPLER;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="cbdoppler"><%=getTran(request,"openclinic.chuk","doppler",sWebLanguage)%></label>
            </td>
        </tr>

        <%-- ao / septum --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","ao",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_AO")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_AO" property="itemId"/>]>.value" value="<%=sAO%>">
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","septum",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_SEPTUM")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_SEPTUM" property="itemId"/>]>.value" value="<%=sSeptum%>">
            </td>
        </tr>

        <%-- og / paroi_post --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OG")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OG" property="itemId"/>]>.value" value="<%=sOg%>">
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","paroi_post",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PAROI_POST")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PAROI_POST" property="itemId"/>]>.value" value="<%=sParoiPost%>">
            </td>
        </tr>

        <%-- dtdvgA / fe --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","dtdvg",sWebLanguage)%> A</td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGA")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGA" property="itemId"/>]>.value" value="<%=sDtdvgA%>">
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","fe",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_FE")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_FE" property="itemId"/>]>.value" value="<%=sFe%>">
            </td>
        </tr>

        <%-- dtdvgB / raccouc --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","dtdvg",sWebLanguage)%> B</td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGB")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGB" property="itemId"/>]>.value" value="<%=sDtdvgB%>">
            </td>
            <td class="admin">% <%=getTran(request,"openclinic.chuk","raccouc",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_RACCOUC")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_RACCOUC" property="itemId"/>]>.value" value="<%=sRaccouc%>">
            </td>
        </tr>

        <%-- vd / pericardium --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","vd",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VD")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VD" property="itemId"/>]>.value" value="<%=sVd%>">
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","pericardium",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PERICARDIUM")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PERICARDIUM" property="itemId"/>]>.value" value="<%=sPericardium%>">
            </td>
        </tr>

        <%-- mitral_valve / valve_aort --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","mitral_valve",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MITRAL_VALVE")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MITRAL_VALVE" property="itemId"/>]>.value" value="<%=sMitralValve%>">
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","valve_aort",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_AORT")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_AORT" property="itemId"/>]>.value" value="<%=sValveAort%>">
            </td>
        </tr>

        <%-- valve_tric / valve_pulm --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","valve_tric",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_TRIC")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_TRIC" property="itemId"/>]>.value" value="<%=sValveTric%>">
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","valve_pulm",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_PULM")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_PULM" property="itemId"/>]>.value" value="<%=sValvePulm%>">
            </td>
        </tr>

        <%-- other / doppler --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","other",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OTHER")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OTHER" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","doppler",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DOPPLER")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DOPPLER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DOPPLER" property="value"/></textarea>
            </td>
        </tr>

        <%-- conclusion / remarks --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_CONCLUSION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_REMARKS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_REMARKS" property="value"/></textarea>
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>                    
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.protocol.cardioechography",sWebLanguage)%>
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
    else{
      Form.findFirstElement(transactionForm); // for ff compatibility
      document.getElementById("buttonsDiv").style.visibility = "hidden";
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

<%=writeJSButtons("transactionForm","saveButton")%>