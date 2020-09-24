<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"occup.ophtalmology.consultation","select",activeUser)%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
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
        String sTranCurrentGlasses_OD    = "";
        String sTranCurrentGlasses_OD_D  = "";
        String sTranCurrentGlasses_OD_DX = "";
        String sTranCurrentGlasses_ADD   = "";
        String sTranCurrentGlasses_OG    = "";
        String sTranCurrentGlasses_OG_D  = "";
        String sTranCurrentGlasses_OG_DX = "";

        String sTranAutorefractor_OD     = "";
        String sTranAutorefractor_OD_D   = "";
        String sTranAutorefractor_OD_DX  = "";
        String sTranAutorefractor_ADD    = "";
        String sTranAutorefractor_OG     = "";
        String sTranAutorefractor_OG_D   = "";
        String sTranAutorefractor_OG_DX  = "";

        String sTranBlurtest_OD          = "";
        String sTranBlurtest_OD_D        = "";
        String sTranBlurtest_OD_DX       = "";
        String sTranBlurtest_ADD         = "";
        String sTranBlurtest_OG          = "";
        String sTranBlurtest_OG_D        = "";
        String sTranBlurtest_OG_DX       = "";

        String sTranNewGlasses_OD        = "";
        String sTranNewGlasses_OD_D      = "";
        String sTranNewGlasses_OD_DX     = "";
        String sTranNewGlasses_ADD       = "";
        String sTranNewGlasses_OG        = "";
        String sTranNewGlasses_OG_D      = "";
        String sTranNewGlasses_OG_DX     = "";

        String sTranOcularTension_OD     = "";
        String sTranOcularTension_OG     = "";

        String sTranOphtalmologyConsContext = "";

        if (transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if (tran!=null){
                /*CURRENT GLASS VALUES*/
                sTranCurrentGlasses_OD    = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD");
                sTranCurrentGlasses_OD_D  = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D");
                sTranCurrentGlasses_OD_DX = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX");
                sTranCurrentGlasses_ADD   = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_ADD");
                sTranCurrentGlasses_OG    = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG");
                sTranCurrentGlasses_OG_D  = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D");
                sTranCurrentGlasses_OG_DX = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX");

                /*AUTOREFRACTOR VALUES*/
                sTranAutorefractor_OD     = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD");
                sTranAutorefractor_OD_D   = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D");
                sTranAutorefractor_OD_DX  = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX");
                sTranAutorefractor_ADD    = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_ADD");
                sTranAutorefractor_OG     = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG");
                sTranAutorefractor_OG_D   = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D");
                sTranAutorefractor_OG_DX  = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX");

                /*BLURTEST VALUES*/
                sTranBlurtest_OD          = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD");
                sTranBlurtest_OD_D        = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D");
                sTranBlurtest_OD_DX       = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX");
                sTranBlurtest_ADD         = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_ADD");
                sTranBlurtest_OG          = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG");
                sTranBlurtest_OG_D        = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D");
                sTranBlurtest_OG_DX       = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX");

                /*NEW GLASSES VALUES*/
                sTranNewGlasses_OD        = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD");
                sTranNewGlasses_OD_D      = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D");
                sTranNewGlasses_OD_DX     = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX");
                sTranNewGlasses_ADD       = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD");
                sTranNewGlasses_OG        = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG");
                sTranNewGlasses_OG_D      = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D");
                sTranNewGlasses_OG_DX     = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX");


                sTranOcularTension_OD     = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD");
                sTranOcularTension_OG     = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG");

                sTranOphtalmologyConsContext = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT");
            }
        }

    %>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" colspan="3">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="4">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="3"><%=getTran(request,"openclinic.chuk","context",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input onDblClick="uncheckRadio(this);" id="rbcontextambulant" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT")%> type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT;value=ophtalmology.consultation.ambulant" property="value" outputString="checked"/> value="ophtalmology.consultation.ambulant"/>
                &nbsp;<%=getLabel(request,"web.occup","ophtalmology.consultation.ambulant",sWebLanguage,"rbcontextambulant")%>
                &nbsp;<input onDblClick="uncheckRadio(this);" id="rbcontextpatient" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT")%> type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT;value=ophtalmology.consultation.hospitalized" property="value" outputString="checked"/> value="ophtalmology.consultation.hospitalized"/>
                &nbsp;<%=getLabel(request,"web.occup","ophtalmology.consultation.hospitalized",sWebLanguage,"rbcontextpatient")%>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="3"><%=getTran(request,"openclinic.chuk","anamnese",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_ANAMNESE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_ANAMNESE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_ANAMNESE" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" width="150" rowspan="6"><%=getTran(request,"openclinic.chuk","vision.acuity",sWebLanguage)%></td>
            <td class="admin" width="150" rowspan="2"><%=getTran(request,"openclinic.chuk","current.glasses",sWebLanguage)%></td>
            <td class="admin" width="50"><%=getTran(request,"openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2" width="100">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2" width="100">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2" width="100">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran(request,"openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_ADD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_ADD" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
        </tr>

        <tr>
            <td class="admin" rowspan="2"><%=getTran(request,"openclinic.chuk","autorefractor",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran(request,"openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_ADD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_ADD" property="itemId"/>]>.value" value="<%=sTranAutorefractor_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran(request,"openclinic.chuk","blurtest",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD" property="itemId"/>]>.value" value="<%=sTranBlurtest_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D" property="itemId"/>]>.value" value="<%=sTranBlurtest_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX" property="itemId"/>]>.value" value="<%=sTranBlurtest_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran(request,"openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_AAD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_ADD" property="itemId"/>]>.value" value="<%=sTranBlurtest_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG" property="itemId"/>]>.value" value="<%=sTranBlurtest_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D" property="itemId"/>]>.value" value="<%=sTranBlurtest_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX" property="itemId"/>]>.value" value="<%=sTranBlurtest_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="3"><%=getTran(request,"openclinic.chuk","pupil",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PUPIL")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PUPIL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PUPIL" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"><%=getTran(request,"openclinic.chuk","biomicroscopy",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","cornea",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","chambre.anterieure",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","cristallin",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran(request,"openclinic.chuk","ocular.tension",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD" property="itemId"/>]>.value" value="<%=sTranOcularTension_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;mmHg
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG" property="itemId"/>]>.value" value="<%=sTranOcularTension_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;mmHg
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"><%=getTran(request,"openclinic.chuk","retina",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","optical.nerve",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","macula",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_MACULA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_MACULA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_MACULA" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","periphery",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="3"><%=getTran(request,"openclinic.chuk","diagnosis",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_DIAGNOSIS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_DIAGNOSIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_DIAGNOSIS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"><%=getTran(request,"openclinic.chuk","treatment",sWebLanguage)%></td>
            <td class="admin" colspan="2"></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran(request,"openclinic.chuk","new.glasses",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran(request,"openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD" property="itemId"/>]>.value" value="<%=sTranNewGlasses_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/themes/default/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;�
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="3"><%=getTran(request,"openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_REMARKS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_REMARKS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="3"/>
            <td class="admin2" colspan="4">
        <%-- BUTTONS --%>
        <%
          if (activeUser.getAccessRight("occup.ophtalmology.consultation.add") || activeUser.getAccessRight("occup.ophtalmology.consultation.edit")){
        %>
                <INPUT class="button" type="button" name="saveButton" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="doSubmit()"/>
        <%
          }
        %>
                <INPUT class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
    <%=ScreenHelper.contextFooter(request)%>
<script>
    if("<%=sTranOphtalmologyConsContext%>" == "0"){
        document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value')[0].checked = true;
    }else if("<%=sTranOphtalmologyConsContext%>" == "1"){
        document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value')[1].checked = true;
    }
    function doSubmit(){
        transactionForm.saveButton.disabled = true;
        document.transactionForm.submit();
    }

    function isMyNumber(sObject){
          if(sObject.value==0) return false;
          sObject.value = sObject.value.replace(",",".");
          var string = sObject.value;
          var vchar = "01234567890.+-";
          var dotCount = 0;

          for(var i=0; i < string.length; i++){
            if (vchar.indexOf(string.charAt(i)) == -1)	{
              sObject.value = "";
              return false;
            }
            else{
              if(string.charAt(i)=="."){
                dotCount++;
                if(dotCount > 1){
                  sObject.value = "";
                  return false;
                }
              }

              if ((string.charAt(i)=="-")||(string.charAt(i)=="+")){
                  if (i>0){
                      sObject.value = "";
                      return false;
                  }
              }
            }
          }

          if(sObject.value.length > 250){
            sObject.value = sObject.value.substring(0,249);
          }

          return true;
    }
</script>
</form>