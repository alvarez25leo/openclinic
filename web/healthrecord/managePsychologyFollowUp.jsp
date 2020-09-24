<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
	private String addPsychology(int iTotal, String sTmpPsychologyDate, String sTmpPsychologyTime, String sTmpPsychologyObservation, String sTmpPsychologyConclusion, String sWebLanguage) {
	    return "<tr class='list"+(iTotal%2==0?"":"1")+"' id='rowPsychology" + iTotal + "'>"
	            + "<td colspan='2'>"
	            + " <a href='javascript:deletePsychology(rowPsychology" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.png' alt='" + getTran(null,"Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> "
	            + " <a href='javascript:editPsychology(rowPsychology" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.png' alt='" + getTran(null,"Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>"
	            + " &nbsp;" + sTmpPsychologyDate + "</td>"
	            + "<td>&nbsp;" + sTmpPsychologyTime + "</td>"
	            + "<td>" + sTmpPsychologyObservation + "</td>"
	            + "<td>" + sTmpPsychologyConclusion + "</td>"
	            + "</tr>";
	}


%>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
<%
	String sDivPsychology="";
	String sPsychology="";
	TransactionVO tran=null;
	if(transaction!=null){
        tran = (TransactionVO) transaction;
        if (tran != null) {
            sPsychology = getItemType(tran.getItems(), sPREFIX+"ITEM_TYPE_PSYCHOLOGY_OBSERVATION").replaceAll("\n","<br/>").replaceAll("\r","");
        }
	}
	
	System.out.println(sPsychology);
	
    int iTotal = 1;

    if (sPsychology.indexOf("�") > -1) {
        String sTmpPsychology = sPsychology;
        String sTmpPsychologyDate, sTmpPsychologyTime, sTmpPsychologyObservation, sTmpPsychologyConclusion;
        sPsychology = "";
        while (sTmpPsychology.toLowerCase().indexOf("$") > -1) {
            sTmpPsychologyDate = "";
            sTmpPsychologyTime = "";
            sTmpPsychologyObservation = "";
            sTmpPsychologyConclusion = "";

            if (sTmpPsychology.toLowerCase().indexOf("�") > -1) {
            	sTmpPsychologyDate = sTmpPsychology.substring(0, sTmpPsychology.toLowerCase().indexOf("�"));
            	sTmpPsychologyDate = ScreenHelper.convertDate(sTmpPsychologyDate);
                sTmpPsychology = sTmpPsychology.substring(sTmpPsychology.toLowerCase().indexOf("�") + 1);
            }
            if (sTmpPsychology.toLowerCase().indexOf("�") > -1) {
            	sTmpPsychologyTime = sTmpPsychology.substring(0, sTmpPsychology.toLowerCase().indexOf("�"));
                sTmpPsychology = sTmpPsychology.substring(sTmpPsychology.toLowerCase().indexOf("�") + 1);
            }
            if (sTmpPsychology.toLowerCase().indexOf("�") > -1) {
            	sTmpPsychologyObservation = sTmpPsychology.substring(0, sTmpPsychology.toLowerCase().indexOf("�"));
                sTmpPsychology = sTmpPsychology.substring(sTmpPsychology.toLowerCase().indexOf("�") + 1);
            }
            if (sTmpPsychology.toLowerCase().indexOf("$") > -1) {
            	sTmpPsychologyConclusion = sTmpPsychology.substring(0, sTmpPsychology.toLowerCase().indexOf("$"));
                sTmpPsychology = sTmpPsychology.substring(sTmpPsychology.toLowerCase().indexOf("$") + 1);
            }

            sPsychology += "rowPsychology" + iTotal + "=" + sTmpPsychologyDate + "�" + sTmpPsychologyTime + "�" + sTmpPsychologyObservation + "�" + sTmpPsychologyConclusion + "$";
            sDivPsychology = addPsychology(iTotal, sTmpPsychologyDate, sTmpPsychologyTime, sTmpPsychologyObservation, sTmpPsychologyConclusion, sWebLanguage)+sDivPsychology;
            iTotal++;
        }
    } else if (sPsychology.length() > 0) {
        String sTmpPsychology = sPsychology;
        sPsychology += "rowPsychology" + iTotal + "=��" + sTmpPsychology + "$";
        sDivPsychology += addPsychology(iTotal, "", "", "", sTmpPsychology, sWebLanguage);
        iTotal++;
    }
%>
<%=checkPermission(out,"occup.psychologyfollowup","select",activeUser)%>
<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

 
<%=contextHeader(request,sWebLanguage)%>
<table class="list" width="100%" cellspacing="1"> 
    <%-- DIAGNOSIS --%>
    <tr>
    	<td class="admin" colspan="2">
	      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
    	</td>
    </tr>
    
<%--  Personne de r�f�rence/Institution --%>
    <tr>
        <td class="admin" width="10%"><%=getTran(request,"web","referenceperson",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <input class="text" type="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_REFERENCEPERSON" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_REFERENCEPERSON" property="value"/>">
        </td>
    </tr>
    
<%--  Noms du psychologue clinicien --%>
    <tr>
        <td class="admin" width="10%"><%=getTran(request,"web","psychologist",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <input class="text" type="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_PSYCHOLOGIST" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_PSYCHOLOGIST" property="value"/>">
        </td>
    </tr>
    
<%--  Anamn�se familiale --%>
    <tr>
        <td class="admin" width="20%"><%=getTran(request,"web","familyhistory",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_PSYFU_FAMILYHISTORY")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_FAMILYHISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_FAMILYHISTORY" property="value"/></textarea>
        </td>
    </tr>
    
<%--  Anamn�se personnelle et contexte de la crise --%>
    <tr>
        <td class="admin"><%=getTran(request,"web","personalhistory.and.cisiscontext",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_PSYFU_PERSONALHISTORY")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_PERSONALHISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYFU_PERSONALHISTORY" property="value"/></textarea>
        </td>
    </tr>

    <tr class="admin" >
        <td colspan="2" > <%=getTran(request,"web","followup.chart",sWebLanguage)%></td>
    </tr>
    <tr>
    	<td colspan="2">
	    	<table id="tblPsychology" width="100%">
	    		<tr>
	                <td class="admin" width="36">&nbsp;</td>
	  	     		<td class="admin"><%=getTran(request,"web","date",sWebLanguage)%></td>
	  	     		<td class="admin"><%=getTran(request,"web","hour",sWebLanguage)%></td>
		     		<td class="admin"><%=getTran(request,"web","session.report",sWebLanguage)%></td>
		     		<td class="admin"><%=getTran(request,"web","evolution",sWebLanguage)%></td>
	                <td class="admin">&nbsp;</td>
		     	</tr>
		     	<tr>
	                <td class="admin2"></td>
	                <td class="admin2" nowrap><%=writeDateField("PsychologyDate", "transactionForm",SH.formatDate(new java.util.Date()),sWebLanguage)%></td>
	                <td class="admin2"><input type="text" class="text" name="PsychologyTime" size="8" value="<%=SH.formatDate(new java.util.Date(), SH.hourFormat)%>"></td>
	                <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" class="text" name="PsychologyObservation" cols="60"></textarea></td>
	                <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" class="text" name="PsychologyConclusion" cols="60"></textarea></td>
	                <td class="admin2">
	                    <input type="button" class="button" name="ButtonAddPsychology" onclick="addPsychology()" value="<%=getTranNoLink("Web","add",sWebLanguage)%>">
	                    <input type="button" class="button" name="ButtonUpdatePsychology" onclick="updatePsychology()" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>">
	                </td>
		     	</tr>
	            <%=sDivPsychology%>
	            
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION1" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION2" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION3" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION4" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION5" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION6" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION7" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION8" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION9" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION10" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION11" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION12" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION13" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION14" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION15" property="itemId"/>]>.value"/>
	    	</table>
	    </td>
    </tr>
	<%-- BUTTONS --%>
       <tr>
           <td class="admin"/>
           <td class="admin2">
               <%=getButtonsHtml(request,activeUser,activePatient,"occup.psychologyfollowup",sWebLanguage)%>
           </td>
       </tr>
</table>

<script>
  var iIndexPersoonlijk = <%=iTotal%>;
  var sPsychology = "<%=sPsychology%>";

  <%-- SUBMIT FORM --%>
  function submitForm(){
    addPsychology();
    if(sPsychology.length>=75000){
    	alert('<%=getTranNoLink("web","texttoolong.createnewdocument",sWebLanguage)%>');
    }
    else{
	    transactionForm.saveButton.disabled = true;
	    while (sPsychology.indexOf("rowPsychology")>-1){
	        sTmpBegin = sPsychology.substring(sPsychology.indexOf("rowPsychology"));
	        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
	        sPsychology = sPsychology.substring(0,sPsychology.indexOf("rowPsychology"))+sTmpEnd;
	    }
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION1" property="itemId"/>]>.value")[0].value = sPsychology.substring(0,5000);
	    if(sPsychology.length>5000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION2" property="itemId"/>]>.value")[0].value = sPsychology.substring(5000,10000);
	    if(sPsychology.length>10000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION3" property="itemId"/>]>.value")[0].value = sPsychology.substring(10000,15000);
	    if(sPsychology.length>15000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION4" property="itemId"/>]>.value")[0].value = sPsychology.substring(15000,20000);
	    if(sPsychology.length>20000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION5" property="itemId"/>]>.value")[0].value = sPsychology.substring(20000,25000);
	    if(sPsychology.length>25000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION6" property="itemId"/>]>.value")[0].value = sPsychology.substring(25000,30000);
	    if(sPsychology.length>30000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION7" property="itemId"/>]>.value")[0].value = sPsychology.substring(30000,35000);
	    if(sPsychology.length>35000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION8" property="itemId"/>]>.value")[0].value = sPsychology.substring(35000,40000);
	    if(sPsychology.length>40000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION9" property="itemId"/>]>.value")[0].value = sPsychology.substring(40000,45000);
	    if(sPsychology.length>45000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION10" property="itemId"/>]>.value")[0].value = sPsychology.substring(45000,50000);
	    if(sPsychology.length>50000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION11" property="itemId"/>]>.value")[0].value = sPsychology.substring(50000,55000);
	    if(sPsychology.length>55000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION12" property="itemId"/>]>.value")[0].value = sPsychology.substring(55000,60000);
	    if(sPsychology.length>60000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION13" property="itemId"/>]>.value")[0].value = sPsychology.substring(60000,65000);
	    if(sPsychology.length>65000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION14" property="itemId"/>]>.value")[0].value = sPsychology.substring(65000,70000);
	    if(sPsychology.length>70000) document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PSYCHOLOGY_OBSERVATION15" property="itemId"/>]>.value")[0].value = sPsychology.substring(70000,75000);
	    
	    <%
	        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
		
	    	out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
	    %>
    }
  }
  
  function addPsychology(){
    if(isAtLeastOnePsychologyFieldFilled()){
      iIndexPersoonlijk ++;
      sPsychology+="rowPsychology"+iIndexPersoonlijk+"="+document.getElementById("transactionForm").PsychologyDate.value+"�"+document.getElementById("transactionForm").PsychologyTime.value+"�"+document.getElementById("transactionForm").PsychologyObservation.value+"�"+document.getElementById("transactionForm").PsychologyConclusion.value+"$";
      var tr = tblPsychology.insertRow(tblPsychology.rows.length);
      tr.id = "rowPsychology"+iIndexPersoonlijk;
	
      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deletePsychology(rowPsychology"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editPsychology(rowPsychology"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.png' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);
	
      td = tr.insertCell(1);
      td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").PsychologyDate.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").PsychologyTime.value;
      tr.appendChild(td);
	
      td = tr.insertCell(3);
      td.innerHTML =  document.getElementById("transactionForm").PsychologyObservation.value.replace(new RegExp("\n", "g"),"<br/>").replace(new RegExp("\r", "g"),"");
      tr.appendChild(td);
	
      td = tr.insertCell(4);
      td.innerHTML = document.getElementById("transactionForm").PsychologyConclusion.value.replace(new RegExp("\n", "g"),"<br/>").replace(new RegExp("\r", "g"),"");
      tr.appendChild(td);
	
      // reset
      clearPsychologyFields();
      document.getElementById("transactionForm").ButtonUpdatePsychology.disabled = true;
  }
}

function isAtLeastOnePsychologyFieldFilled(){
  if(document.getElementById("transactionForm").PsychologyObservation.value != "") return true;
  if(document.getElementById("transactionForm").PsychologyConclusion.value != "") return true;
  return false;
}

function deletePsychology(rowid){
    if(yesnoDeleteDialog()){
    sPsychology = deleteRowFromArrayString(sPsychology,rowid.id);
    tblPsychology.deleteRow(rowid.rowIndex);
    clearPsychologyFields();
  }
}

function editPsychology(rowid){
  var row = getRowFromArrayString(sPsychology,rowid.id);

  document.getElementById("transactionForm").PsychologyDate.value = getCelFromRowString(row,0);
  document.getElementById("transactionForm").PsychologyTime.value = getCelFromRowString(row,1);
  document.getElementById("transactionForm").PsychologyObservation.value = getCelFromRowString(row,2).replace(new RegExp("<br/>", "g"),"\n");
  document.getElementById("transactionForm").PsychologyConclusion.value = getCelFromRowString(row,3).replace(new RegExp("<br/>", "g"),"\n");
  resizeTextarea(document.getElementById("transactionForm").PsychologyObservation,10);
  resizeTextarea(document.getElementById("transactionForm").PsychologyConclusion,10);
  editPsychologyRowid = rowid;
  document.getElementById("transactionForm").ButtonUpdatePsychology.disabled = false;
}

function updatePsychology(){
  if(isAtLeastOnePsychologyFieldFilled()){
    // update arrayString
    newRow = editPsychologyRowid.id+"="
	         +document.getElementById("transactionForm").PsychologyDate.value+"�"
	       	 +document.getElementById("transactionForm").PsychologyTime.value+"�"
             +document.getElementById("transactionForm").PsychologyObservation.value.replace(new RegExp("\n", "g"),"<br/>").replace(new RegExp("\r", "g"),"")+"�"
             +document.getElementById("transactionForm").PsychologyConclusion.value.replace(new RegExp("\n", "g"),"<br/>").replace(new RegExp("\r", "g"),"");

    sPsychology = replaceRowInArrayString(sPsychology,newRow,editPsychologyRowid.id);

    // update table object
    var row = tblPsychology.rows[editPsychologyRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deletePsychology("+editPsychologyRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editPsychology("+editPsychologyRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.png' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").PsychologyDate.value;
    row.cells[2].innerHTML = "&nbsp;"+document.getElementById("transactionForm").PsychologyTime.value;
    row.cells[3].innerHTML = document.getElementById("transactionForm").PsychologyObservation.value.replace(new RegExp("\n", "g"),"<br/>").replace(new RegExp("\r", "g"),"");
    row.cells[4].innerHTML = document.getElementById("transactionForm").PsychologyConclusion.value.replace(new RegExp("\n", "g"),"<br/>").replace(new RegExp("\r", "g"),"");

    // reset
    clearPsychologyFields();
    document.getElementById("transactionForm").ButtonUpdatePsychology.disabled = true;
  }
}

function clearPsychologyFields(){
  document.getElementById("transactionForm").PsychologyDate.value = "";
  document.getElementById("transactionForm").PsychologyTime.value = "";
  document.getElementById("transactionForm").PsychologyObservation.value = "";
  document.getElementById("transactionForm").PsychologyConclusion.value = "";
}
	
  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for (var i=0;i<array.length;i++){
      if (array[i].indexOf(rowid)>-1){
        array.splice(i,1);
      }
    }
    return array.join("$");
  }

  function getRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    var row = "";
    for (var i=0;i<array.length;i++){
      if (array[i].indexOf(rowid)>-1){
        row = array[i].substring(array[i].indexOf("=")+1);
        break;
      }
    }
    return row;
  }
  
  function getCelFromRowString(sRow,celid){
    var row = sRow.split("�");
	  return row[celid];
  }

  function replaceRowInArrayString(sArray,newRow,rowid){
    var array = sArray.split("$");
    for (var i=0;i<array.length;i++){
      if (array[i].indexOf(rowid)>-1){
        array.splice(i,1,newRow);
        break;
      }
    }
    return array.join("$");
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