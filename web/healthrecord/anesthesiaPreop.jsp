<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"occup.anesthesiapreop","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
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
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="4">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>

                <input type='text' class='text' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HOUR" property="value"/>"onkeypress="keypressTime(this)" onblur='checkTime(this)' size='5'>
                &nbsp;<%=getTran(request,"web.occup","medwan.common.hour",sWebLanguage)%>
            </td>
        </tr>

        <%-- GENERALITIES --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","anesthesia.indication",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_INDICATION")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1a" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION" property="itemId"/>]>.value" value="openclinic.common.urgency" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION;value=openclinic.common.urgency" property="value" outputString="checked"/>><%=getLabel(request,"openclinic.chuk","openclinic.common.urgency",sWebLanguage,"sum_r1a")%>
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_INDICATION")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1b" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION" property="itemId"/>]>.value" value="openclinic.common.programmed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION;value=openclinic.common.programmed" property="value" outputString="checked"/>><%=getLabel(request,"openclinic.chuk","openclinic.common.programmed",sWebLanguage,"sum_r1b")%>
            </td>
        </tr>

        <%-- INTERVENTION --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","intervention",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_INTERVENTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>

        <%-- PATIENT ANTECEDENTS ----------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="5"><%=getTran(request,"openclinic.chuk","patient.antecedents",sWebLanguage)%></td>
        </tr>
        
        <%-- ROW 1 --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2" width="200"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_TOBACCO")%> type="checkbox" id="cbtobacco" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TOBACCO" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TOBACCO;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","tobacco",sWebLanguage,"cbtobacco")%></td>
            <td class="admin2" width="200"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_ASTHMA")%> type="checkbox" id="cbasthma" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ASTHMA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ASTHMA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","asthma",sWebLanguage,"cbasthma")%></td>
            <td class="admin2" width="200"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_DIABETES")%> type="checkbox" id="cbdiabetes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DIABETES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DIABETES;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","diabetes",sWebLanguage,"cbdiabates")%></td>
            <td class="admin2"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_HEPATITIS")%> type="checkbox" id="cbhepatitis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HEPATITIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HEPATITIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","hepatitis",sWebLanguage,"cbhepatitis")%></td>
        </tr>

        <%-- ROW 2 --%>
        <tr>
            <td class="admin"/>
            <td class="admin2"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_ALLERGY")%> type="checkbox" id="cballergy" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ALLERGY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ALLERGY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","allergy",sWebLanguage,"cballergy")%></td>
            <td class="admin2"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CARDIOPATHY")%> type="checkbox" id="cbcardiopathy" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CARDIOPATHY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CARDIOPATHY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","cardiopathy",sWebLanguage,"cbcardiopathy")%></td>
            <td class="admin2"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_HYPERTENSION")%> type="checkbox" id="cbhypertension" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HYPERTENSION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HYPERTENSION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","hypertension",sWebLanguage,"cbhypertension")%></td>
            <td class="admin2"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_OTHERA")%> type="checkbox" id="cbother" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","other",sWebLanguage,"cbother")%></td>
        </tr>

        <%-- PREVIOUS ANESTHESIA --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","previous_anesthesia",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_PREVIOUS_ANESTHESIA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREVIOUS_ANESTHESIA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREVIOUS_ANESTHESIA" property="value"/></textarea>
            </td>
        </tr>

        <%-- NEURLOGIC PROBLEM --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","neurologic_problem",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_NEUROLOGIC_PROBLEM")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NEUROLOGIC_PROBLEM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NEUROLOGIC_PROBLEM" property="value"/></textarea>
            </td>
        </tr>

        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","comment",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_COMMENTA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_COMMENTA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_COMMENTA" property="value"/></textarea>
            </td>
        </tr>

        <%-- PATIENT CLINICAL --------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="5"><%=getTran(request,"openclinic.chuk","patient.clinical",sWebLanguage)%></td>
        </tr>

        <%-- GENERAL CONDITION --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","general.condition",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_GENERAL_CONDITION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GENERAL_CONDITION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GENERAL_CONDITION" property="value"/></textarea>
            </td>
        </tr>

        <%-- BLOOD PRESSURE --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)%></td>
            <td class="admin2">
                <%=getTran(request,"Web.Occup","medwan.healthrecord.cardial.bras-droit",sWebLanguage)%>
                <input id="sbpr" <%=setRightClick(session,"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> /
                <input id="dbpr" <%=setRightClick(session,"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> mmHg
            </td>
            <td class="admin2" colspan="3">
                <%=getTran(request,"Web.Occup","medwan.healthrecord.cardial.bras-gauche",sWebLanguage)%>
                <input id="sbpl" <%=setRightClick(session,"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> /
                <input id="dbpl" <%=setRightClick(session,"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> mmHg
            </td>
        </tr>

        <%-- CONJUNCTIVA --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","conjunctiva",sWebLanguage)%></td>
            <td class="admin2" colspan="4"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CONJUNCTIVA")%> type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CONJUNCTIVA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CONJUNCTIVA" property="value"/>"></td>
        </tr>

        <%-- OEDEMA LEGS --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","oedema.legs",sWebLanguage)%></td>
            <td class="admin2" colspan="4"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_OEDEMA_LEGS")%> type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OEDEMA_LEGS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OEDEMA_LEGS" property="value"/>"></td>
        </tr>

        <%-- DYSPNOE --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","dyspnoe",sWebLanguage)%></td>
            <td class="admin2" colspan="4"><input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_DYSPNOE")%> type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DYSPNOE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DYSPNOE" property="value"/>"></td>
        </tr>

        <%-- OTHER --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","other",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_OTHERB")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERB" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERB" property="value"/></textarea>
            </td>
        </tr>

        <%-- EXAMENS PARACLINIQUES --------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="5"><%=getTran(request,"openclinic.chuk","paraclinic.examinations",sWebLanguage)%></td>
        </tr>

        <%-- ANESTHESIA COMPONENTS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_HB")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HB" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HB" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.hb",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_NA")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NA" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.na",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_K")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_K" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_K" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.k",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CA")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CA" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.ca",sWebLanguage)%>
            </td>
        </tr>

        <%-- ANESTHESIA --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_GLUC")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GLUC" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GLUC" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.glucose",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_UREUM")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_UREUM" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_UREUM" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.ureum",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CREATININE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CREATININE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CREATININE" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.creatinine",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_PROTIDES")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTIDES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTIDES" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.protides",sWebLanguage)%>
            </td>
        </tr>

        <%-- ANESTHESIA --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_SGOT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGOT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGOT" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.sgot",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="3">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_SGPT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGPT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGPT" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.sgpt",sWebLanguage)%>
            </td>
        </tr>

        <%-- ANESTHESIA --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_FIBRINOGENE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_FIBRINOGENE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_FIBRINOGENE" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.fibrinogene",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_PLATELETS")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PLATELETS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PLATELETS" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.platelets",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_TCA")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TCA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TCA" property="value"/>">
                <%=getTran(request,"openclinic.chuk","anesthesia.tca",sWebLanguage)%>
            </td>
        </tr>

        <%-- XRAY LUNGS --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","xray.lungs",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_XRAY_LUNGS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_XRAY_LUNGS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_XRAY_LUNGS" property="value"/></textarea>
            </td>
        </tr>

        <%-- ECG --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","ecg",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_ECG")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ECG" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ECG" property="value"/></textarea>
            </td>
        </tr>

        <%-- EYE FUNDUS --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","eyefundus",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_EYE_FUNDUS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_EYE_FUNDUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_EYE_FUNDUS" property="value"/></textarea>
            </td>
        </tr>

        <%-- TREATMENT --------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="5"><%=getTran(request,"openclinic.chuk","treatment",sWebLanguage)%></td>
        </tr>

        <%-- CURRENT TREATMENT --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","current.treatment",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CURRENT_TREATMENT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CURRENT_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CURRENT_TREATMENT" property="value"/></textarea>
            </td>
        </tr>

        <%-- CONCLUSION --%>
        <tr class="admin">
            <td colspan="5"><%=getTran(request,"openclinic.chuk","conclusion",sWebLanguage)%></td>
        </tr>

        <%-- INTUBATION --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","intubation",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_INTUBATION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTUBATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTUBATION" property="value"/></textarea>
            </td>
        </tr>

        <%-- ANESTHESIA CLASS --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","anesthesia.class",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
            	<%=getLabel(request,"openclinic.chuk","openclinic.anesthesia.asa",sWebLanguage,"class r1")%>																										      			
                <select <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CLASS_ASA")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS_ASA" property="itemId"/>]>.value" class="text">
                	<option/>
                	<%=ScreenHelper.writeSelect(request, "asa", ((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS_ASA"), sWebLanguage) %>
                </select>
                &nbsp;
            	<%=getLabel(request,"openclinic.chuk","openclinic.anesthesia.mallampati",sWebLanguage,"class r1")%>
                <select <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CLASS_MALLAMPATI")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS_MALLAMPATI" property="itemId"/>]>.value" class="text">
                	<option/>
                	<%=ScreenHelper.writeSelect(request, "mallampati", ((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS_MALLAMPATI"), sWebLanguage) %>
                </select>
                &nbsp;
                &nbsp;<textarea onKeyup="resizeTextarea(this,10);limitChars(this,4000);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_CLASSCOMMENT")%> class="text" cols="80" rows="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASSCOMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASSCOMMENT" property="value"/></textarea>
            </td>
        </tr>

        <%-- ANESTHESIO PROTOCOL --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","anesthesia.protocol",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_PROTOCOLE")%> type="radio" onDblClick="uncheckRadio(this);" id="protocole_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE" property="itemId"/>]>.value" value="openclinic.anesthesia.ag" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE;value=openclinic.anesthesia.ag" property="value" outputString="checked"/>><%=getLabel(request,"openclinic.chuk","openclinic.anesthesia.ag",sWebLanguage,"protocol_r1")%>
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_PROTOCOLE")%> type="radio" onDblClick="uncheckRadio(this);" id="protocole_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE" property="itemId"/>]>.value" value="openclinic.anesthesia.locoregional" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE;value=openclinic.anesthesia.locoregional" property="value" outputString="checked"/>><%=getLabel(request,"openclinic.chuk","openclinic.anesthesia.locoregional",sWebLanguage,"protocol_r2")%>
                <input <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_PROTOCOLE")%> type="radio" onDblClick="uncheckRadio(this);" id="protocole_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE" property="itemId"/>]>.value" value="openclinic.anesthesia.local" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE;value=openclinic.anesthesia.local" property="value" outputString="checked"/>><%=getLabel(request,"openclinic.chuk","openclinic.anesthesia.local",sWebLanguage,"protocol_r3")%>
            </td>
        </tr>

        <%-- SOBER --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","sober",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_DATE" property="value"/>" id="soberdate" OnBlur='checkDate(this)'>
                <script>writeMyDate("soberdate");</script>

                <input type='text' class='text' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_HOUR" property="value"/>"onkeypress="keypressTime(this)" onblur='checkTime(this)' size='5'>
                &nbsp;<%=getTran(request,"web.occup","medwan.common.hour",sWebLanguage)%>
            </td>
        </tr>

        <%-- PREMEDICATION --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","premedication",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_PREMEDICATION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREMEDICATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREMEDICATION" property="value"/></textarea>
            </td>
        </tr>
    </table>
    <div style="padding-top:5px;"></div>
    
    <%-- DIAGNOSES --%>
    <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncodingWide.jsp"),pageContext);%>            
    
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.anesthesiapreop",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SET BP --%>
  function setBP(oObject,sbp,dbp){
    if(oObject.value.length>0){
      if(!isNumberLimited(oObject,40,300)){
        alertDialog("Web.Occup","out-of-bounds-value");
      }
      else if((sbp.length>0)&&(dbp.length>0)){
        isbp = document.getElementsByName(sbp)[0].value*1;
        idbp = document.getElementsByName(dbp)[0].value*1;
        if(idbp>isbp){
        	alertDialog("Web.Occup","error.dbp_greather_than_sbp");
        }
      }
    }
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
    if(document.getElementById('encounteruid').value.length==0){
	  alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
      searchEncounter();
	}	
    else{
	  var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	  document.getElementById("buttonsDiv").style.visibility = "hidden";
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
</script>

<%=writeJSButtons("transactionForm","saveButton")%>