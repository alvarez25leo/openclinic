<%@page import="java.util.Vector,
                be.openclinic.medical.Prescription,
                be.openclinic.pharmacy.Product,
                java.text.DecimalFormat" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission(out,"occup.anesthesiaperop","select",activeUser)%>

<%!
    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product;
        product = Product.get(sProductUid);

        if (product != null && product.getName() == null) {
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }

    //--- GET ACTIVE PRESCRIPTIONS FROM RS --------------------------------------------------------
    private Vector getActivePrescriptionsFromRs(StringBuffer prescriptions, Vector vActivePrescriptions, String sWebLanguage) throws SQLException {
        Vector idsVector = new Vector();
        java.util.Date tmpDate;
        Product product = null;
        String sClass = "1", sPrescriptionUid, sDateBeginFormatted = "", sDateEndFormatted = "",
                sProductName = "", sProductUid, sPreviousProductUid = "", sTimeUnit = "", sTimeUnitCount = "",
                sUnitsPerTimeUnit = "", sPrescrRule = "", sProductUnit = "", timeUnitTran = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
               deleteTran  = getTranNoLink("Web", "delete", sWebLanguage);
        Iterator iter = vActivePrescriptions.iterator();

        // run thru found prescriptions
        Prescription prescription;

        while (iter.hasNext()) {
            prescription = (Prescription) iter.next();
            sPrescriptionUid = prescription.getUid();

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            idsVector.add(sPrescriptionUid);

            // format begin date
            tmpDate = prescription.getBegin();
            if (tmpDate != null) sDateBeginFormatted = stdDateFormat.format(tmpDate);
            else sDateBeginFormatted = "";

            // format end date
            tmpDate = prescription.getEnd();
            if (tmpDate != null) sDateEndFormatted = stdDateFormat.format(tmpDate);
            else sDateEndFormatted = "";

            // only search product-name when different product-UID
            sProductUid = prescription.getProductUid();
            if (!sProductUid.equals(sPreviousProductUid)) {
                sPreviousProductUid = sProductUid;
                product = getProduct(sProductUid);
                if (product != null) {
                    sProductName = product.getName();
                } else {
                    sProductName = "";
                }
                if (sProductName.length() == 0) {
                    sProductName = "<font color='red'>" + getTran(null,"web", "nonexistingproduct", sWebLanguage) + "</font>";
                }
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit = prescription.getTimeUnit();
            sTimeUnitCount = Integer.toString(prescription.getTimeUnitCount());
            sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

            // only compose prescriptio-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran(null,"web.prescriptions", "prescriptionrule", sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                if (product != null) {
                    sProductUnit = product.getUnit();
                } else {
                    sProductUnit = "";
                }
                // productunits
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran(null,"product.unit", sProductUnit, sWebLanguage);
                } else {
                    sProductUnit = getTran(null,"product.unit", sProductUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran(null,"prescription.timeunit", sTimeUnit, sWebLanguage);
                } else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran(request,"prescription.timeunits", sTimeUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.null("#timeunit#", timeUnitTran.toLowerCase());
            }

            //*** display prescription in one row ***
            prescriptions.append(sProductName+" ("+sPrescrRule.toLowerCase() + ") ");
        }
        return idsVector;
    }
%>
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
    <%
        String sAnesthesisitName = "";
        String sAnesthesistID = "";
        String sSurgeonName = "";
        String sSurgeonID = "";
        String sNurseName = "";
        String sNurseID = "";

        if (transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if (tran!=null){
                sAnesthesistID = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIST");

               	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                if(sAnesthesistID.length() > 0){
                    sAnesthesisitName = ScreenHelper.getFullUserName(sAnesthesistID,ad_conn);
                }

                sSurgeonID = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_SURGEON");

                if(sSurgeonID.length() > 0){
                    sSurgeonName = ScreenHelper.getFullUserName(sSurgeonID,ad_conn);
                }

                sNurseID = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_NURSE");

                if(sNurseID.length() > 0){
                    sNurseName = ScreenHelper.getFullUserName(sNurseID,ad_conn);
                }
                ad_conn.close();
            }
        }


    %>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" colspan="2">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"><%=getTran(request,"openclinic.chuk","anesthesie",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","begin_hour",sWebLanguage)%></td>
            <td class="admin2">
                <input type='text' class='text' id="abeginhour" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_BEGIN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_BEGIN" property="value"/>" onblur="checkTime(this);calculateInterval('abeginhour', 'aendhour', 'aduration')" size='5'>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","end_hour",sWebLanguage)%></td>
            <td class="admin2">
                <input type='text' class='text' id="aendhour" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_END" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_END" property="value"/>" onblur="checkTime(this);calculateInterval('abeginhour', 'aendhour', 'aduration')" size='5'>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","duration",sWebLanguage)%></td>
            <td class="admin2">
                <input readonly type='text' class='text' id="aduration" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_DIFFERENCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIA_DIFFERENCE" property="value"/>" size='5'>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"><%=getTran(request,"openclinic.chuk","intervention",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","begin_hour",sWebLanguage)%></td>
            <td class="admin2">
                <input type='text' class='text' id="ibeginhour" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_BEGIN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_BEGIN" property="value"/>" onblur="checkTime(this);calculateInterval('ibeginhour', 'iendhour', 'iduration')" size='5'>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","end_hour",sWebLanguage)%></td>
            <td class="admin2">
                <input type='text' class='text' id="iendhour" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_END" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_END" property="value"/>" onblur="checkTime(this);calculateInterval('ibeginhour', 'iendhour', 'iduration')" size='5'>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","duration",sWebLanguage)%></td>
            <td class="admin2">
                <input readonly type='text' class='text' id="iduration" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_DIFFERENCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION_DIFFERENCE" property="value"/>" size='5'>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","diagnostic",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_DIAGNOSTIC")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_DIAGNOSTIC" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_DIAGNOSTIC" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","intervention",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"><%=getTran(request,"openclinic.chuk","teamcomposition",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","anesthesist",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="EditAnesthesistID" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIST" property="itemId"/>]>.value" value="<%=sAnesthesistID%>">
                <input class="text" type="text" name="EditAnesthesistName" readonly size="<%=sTextWidth%>" value="<%=sAnesthesisitName%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchUser('EditAnesthesistID','EditAnesthesistName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditAnesthesistID').value='';transactionForm.EditAnesthesistName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","surgeon",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="EditSurgeonID" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_SURGEON" property="itemId"/>]>.value" value="<%=sSurgeonID%>">
                <input class="text" type="text" name="EditSurgeonName" readonly size="<%=sTextWidth%>" value="<%=sSurgeonName%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchUser('EditSurgeonID','EditSurgeonName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditSurgeonID').value='';transactionForm.EditSurgeonName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","nurse",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="EditNurseID" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_NURSE" property="itemId"/>]>.value" value="<%=sNurseID%>">
                <input class="text" type="text" name="EditNurseName" readonly size="<%=sTextWidth%>" value="<%=sNurseName%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchUser('EditNurseID','EditNurseName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditNurseID').value='';transactionForm.EditAnesthesistName.value='';">
            </td>
        </tr>
        <%-- DESCRIPTION --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"Web","description",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_DESCRIPTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_DESCRIPTION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran(request,"openclinic.chuk","incidents",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","foresees",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_FORESEES")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_FORESEES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_FORESEES" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","unforesees",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_UNFORESEES")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_UNFORESEES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_UNFORESEES" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","anesthesie",sWebLanguage)%></td>
            <td class="admin2">
                <table>
                    <tr>
                        <td width="150">
                            <input id="a1" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_GENERAL")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_GENERAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_GENERAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","anesthesie.general",sWebLanguage,"a1")%>
                        </td>
                        <td width="150">
                            <input id="a2" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_REGIONAL")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_REGIONAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_REGIONAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","anesthesie.regional",sWebLanguage,"a2")%>
                        </td>
                        <td>
                            <input id="a3" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_LOCAL")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_LOCAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_ANESTHESIE_LOCAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","anesthesie.local",sWebLanguage,"a3")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","technical",sWebLanguage)%></td>
            <td class="admin2">
                <table>
                    <tr>
                        <td width="150">
                            <input id="t1" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_MASK")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_MASK" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_MASK;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","technical.mask",sWebLanguage,"t1")%>
                        </td>
                        <td width="150">
                            <input id="t2" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBEORAL")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBEORAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBEORAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","technical.tubeoral",sWebLanguage,"t2")%>
                        </td>
                        <td>
                            <input id="t3" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBENASAL")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBENASAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TECHNICAL_TUBENASAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","technical.tubenasal",sWebLanguage,"t3")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","position",sWebLanguage)%></td>
            <td class="admin2">
                <table>
                    <tr>
                        <td width="150">
                            <input id="p1" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_POSITION_BACK")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_POSITION_BACK" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_POSITION_BACK;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","position.back",sWebLanguage,"p1")%>
                        </td>
                        <td width="150">
                            <input id="p2" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_POSITION_CENTRAL")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_POSITION_CENTRAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_POSITION_CENTRAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","position.central",sWebLanguage,"p2")%>
                        </td>
                        <td>
                            <input id="p3" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_POSITION_SIDE")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_POSITION_SIDE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_POSITION_SIDE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","position.side",sWebLanguage,"p3")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran(request,"openclinic.chuk","respiration",sWebLanguage)%></td>
            <td class="admin2">
                <table>
                    <tr>
                        <td width="150">
                            <input id="r1" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_SPONTANEOUS")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_SPONTANEOUS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_SPONTANEOUS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","respiration.spontaneous",sWebLanguage,"r1")%>
                        </td>
                        <td width="150">
                            <input id="r2" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_ASSIST")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_ASSIST" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_ASSIST;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","respiration.assist",sWebLanguage,"r2")%>
                        </td>
                        <td>
                            <input id="r3" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_VERIFY")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_VERIFY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_RESPIRATION_VERIFY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel(request,"openclinic.chuk","respiration.verify",sWebLanguage,"r3")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran(request,"openclinic.chuk","technical_problems",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","reference_equipment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_TP_REFERENCE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TP_REFERENCE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TP_REFERENCE" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","problem_description",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_TP_DESCRIPTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TP_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_TP_DESCRIPTION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"><%=getTran(request,"openclinic.chuk","pharmacovigilance",sWebLanguage)%></td>
            <td class="admin"><%=getTran(request,"openclinic.chuk","administer_medicines",sWebLanguage)%></td>
            <td class="admin2">
                <%
                    Vector vActivePrescriptions = Prescription.findActive(activePatient.personid, activeUser.userid, "", "", "", "", "", "");

                    StringBuffer prescriptions = new StringBuffer();
                    Vector idsVector = getActivePrescriptionsFromRs(prescriptions, vActivePrescriptions, sWebLanguage);
                    int foundPrescrCount = idsVector.size();

                    if (foundPrescrCount > 0) {
                        out.print(prescriptions);
                    }
                    else {
                        out.print(getTran(request,"web","noactiveprescriptionsfound",sWebLanguage));
                    }
                %>
            </td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran(request,"openclinic.chuk","inferior_effects",sWebLanguage)%></td>
            <td class="admin2">
                <span style="width:100px;"><%=getTran(request,"openclinic.chuk","allergies",sWebLanguage)%></span>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_ALLERGIES")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_ALLERGIES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_ALLERGIES" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin2">
                <span style="width:100px;"><%=getTran(request,"openclinic.chuk","others",sWebLanguage)%></span>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick(session,"ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_OTHERS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_OTHERS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_REPORT_PHARMACO_OTHERS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"/>
            <td class="admin2">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.anesthesiaperop.add") || activeUser.getAccessRight("occup.anesthesiaperop.edit")){
    %>
            <INPUT class="button" type="button" name="saveButton" id="save" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>
<script>
    function submitForm(){
        transactionForm.saveButton.disabled = true;
        <%
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
        %>
    }

    function calculateInterval(sBegin, sEnd, sReturn){
        document.getElementById(sReturn).value = "";
        if ((document.getElementById(sBegin).value.length>0) && (document.getElementById(sEnd).value.length>0)){
            var aTimeBegin = document.getElementById(sBegin).value.split(":");
            var startHour = aTimeBegin[0];
            if(startHour.length==0) startHour = 0;
            var startMinute = aTimeBegin[1];
            if(startMinute.length==0) startMinute = 0;

            var aTimeEnd = document.getElementById(sEnd).value.split(":");
            var stopHour = aTimeEnd[0];
            if(stopHour.length==0) stopHour = 0;
            var stopMinute = aTimeEnd[1];
            if(stopMinute.length==0) stopMinute = 0;

            var dateFrom = new Date(2000,1,1,0,0,0);
            dateFrom.setHours(startHour);
            dateFrom.setMinutes(startMinute);

            var dateUntil = new Date(2000,1,1,0,0,0);
            dateUntil.setHours(stopHour);
            dateUntil.setMinutes(stopMinute);

            var iMinutes = getMinutesInInterval(dateFrom,dateUntil);
            var sHour = parseInt(iMinutes / 60);
            var sMinutes = (iMinutes % 60)+"";

            document.getElementById(sReturn).value = sHour+":"+sMinutes;
            checkTime(document.getElementById(sReturn));
        }
    }

    function getMinutesInInterval(from,until){
        var millisDiff = until.getTime() - from.getTime();
        return (millisDiff/60000);
    }

    function searchUser(userID,userName){
        openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+userID+"&ReturnName="+userName);
    }

</script>