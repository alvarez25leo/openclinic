<%@page import="be.openclinic.medical.Problem, java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission(out,"occupophtalmology","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp?ts=<%=getTs()%>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%-- TITLE --%>
    <table class="list" width='100%' cellspacing="0" cellpadding="0">
        <tr class="admin">
            <td width="1%" nowrap>
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td nowrap>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
            <td width="90%"><%=contextHeader(request,sWebLanguage)%></td>
        </tr>
    </table>
    
    <table class="list" width="100%" cellspacing="1">
	    
	    <%-- 0 - physician --%>
	    <tr>
	        <td class="admin"><%=getTran(request,"web","cdo.physician",sWebLanguage)%>&nbsp;*&nbsp;</td>
	        <td class="admin2" nowrap colspan="1">
	            <select id='physician' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_PHYSICIAN" property="itemId"/>]>.value" >
	                <option></option>
	                <%=ScreenHelper.writeSelectUpperCase("cdo.physician",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_PHYSICIAN"),sWebLanguage,false,false)%>
	            </select>
	        </td>
            <td class="admin"><%=getTran(request,"web","reference",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" colspan='3'>
                <input type="radio" class="hand" onDblClick="uncheckRadio(this);" id="rbreferenceyes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_REFERENCE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_REFERENCE;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel(request,"Web.Occup","medwan.common.yes",sWebLanguage,"rbexecutionyes")%>
                <input type="radio" class="hand" onDblClick="uncheckRadio(this);" id="rbreferenceno" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_REFERENCE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_REFERENCE;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel(request,"Web.Occup","medwan.common.no",sWebLanguage,"rbexecutionno")%>
            </td>
	    </tr>
	    
	    <%-- 1 - actual complaints --%>
	    <tr>
	        <td class="admin"><%=getTran(request,"web","actual.complaints",sWebLanguage)%>&nbsp;*&nbsp;</td>
	        <td class="admin2" colspan="5">	
	        	<input type="hidden" id="complaints" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_1" property="value"/>"/>
	        	<table width='100%'>
			        <%
			            String sComplaints = ((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_1");
			        
			        	Label label;
			        	int counter = 0;
			        	Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
			        	if(labelTypes !=null){
			                Hashtable labelIds = (Hashtable)labelTypes.get("cdo.1");
			                if(labelIds!=null) {
			                    Enumeration idsEnum = labelIds.elements();
			                    Hashtable hSelected = new Hashtable();
			                    while (idsEnum.hasMoreElements()) {
			                        label = (Label)idsEnum.nextElement();
			                        hSelected.put(label.value.toUpperCase(),label.id);
			                    }
			                    
			                    Vector keys = new Vector(hSelected.keySet());
			                    Collections.sort(keys);
			                    Iterator it = keys.iterator();
			                    String sLabelValue, sLabelID;
			                    while(it.hasNext()){
			                        sLabelValue = (String)it.next();
			                        sLabelID = (String)hSelected.get(sLabelValue);
			                        if(counter % 4 ==0){
			                        	if(counter>0){
			                        		out.println("</tr>");
			                        	}
			                        	out.println("<tr>");
			                        }
			                        counter++;
			                        
			       					%><td width='25%'><input class='hand' type="checkbox" name="complaints.<%=sLabelID%>" id="complaints.<%=sLabelID%>" value="<%=sLabelID%>" <%=sComplaints.indexOf("*"+sLabelID+"*")>-1?"checked":"" %>/><label for="complaints.<%=sLabelID%>" class="hand"><%=sLabelValue%></label></td><%
			                    }
			                }
			        	}
			        %>
		        	</tr>
	        	</table>
	            <textarea <%=setRightClickMini("ITEM_TYPE_CDO_1_COMMENT")%> onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" id="complaints_comment" class="text" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_1_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_1_COMMENT" translate="false" property="value"/></textarea>
	        </td>
    	</tr>
    	
    	<%-- 2 - localisation --%>
	    <tr>
	        <td class="admin"><%=getTran(request,"web","localisation",sWebLanguage)%></td>
	        <td class="admin2" colspan="5" nowrap>
	            <select id='cdo2' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_2" property="itemId"/>]>.value" onchange="if(this.value==0){document.getElementById('localisation_comment').style.visibility='visible'}else{document.getElementById('localisation_comment').value='';document.getElementById('localisation_comment').style.visibility='hidden'};">
	                <%=ScreenHelper.writeSelectUpperCase("cdo.2",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_2"),sWebLanguage,false,false)%>
	            </select>
	            <input onKeyup="this.value=this.value.toUpperCase();" type="text" id="localisation_comment" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_2_COMMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_2_COMMENT" translate="false" property="value"/>"/>
	        </td>
	    </tr>
	    
    	<%-- 3/4/5 - severity -------------%>
	    <tr>
	        <td class="admin"><%=getTran(request,"web","severity",sWebLanguage)%></td>
	        <td class="admin2" nowrap>
	            <select id='cdo3' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_3" property="itemId"/>]>.value" >
	                <%=ScreenHelper.writeSelectUpperCase("cdo.3",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_3"),sWebLanguage,false,false)%>
	            </select>
	            <br/>
	            <input onKeyup="this.value=this.value.toUpperCase();" type="text" id="severity_comment" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_3_COMMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_3_COMMENT" translate="false" property="value"/>"/>
	        </td>
	        <td class="admin"><%=getTran(request,"web","cdo.duration",sWebLanguage)%></td>
	        <td class="admin2" nowrap>
	            <select id='cdo4' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_4" property="itemId"/>]>.value" >
	                <%=ScreenHelper.writeSelectUpperCase("cdo.4",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_4"),sWebLanguage,false,false)%>
	            </select>
	            <br/>
	            <input onKeyup="this.value=this.value.toUpperCase();" type="text" id="duration_comment" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_4_COMMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_4_COMMENT" translate="false" property="value"/>"/>
	        </td>
	        <td class="admin"><%=getTran(request,"web","cdo.rythm",sWebLanguage)%></td>
	        <td class="admin2" nowrap>
	            <select id='cdo5' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_5" property="itemId"/>]>.value">
	                <%=ScreenHelper.writeSelectUpperCase("cdo.5",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_5"),sWebLanguage,false,false)%>
	            </select>
	            <br/>
	            <input onKeyup="this.value=this.value.toUpperCase();" type="text" id="rythm_comment" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_5_COMMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_5_COMMENT" translate="false" property="value"/>"/>
	        </td>
	    </tr>
	    
    	<%-- 6 - history --%>
	    <tr>
	        <td class="admin"><%=getTran(request,"web","cdo.history",sWebLanguage)%></td>
	        <td class="admin2" nowrap>	
	        	<input type="hidden" id="history" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_6" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_6" property="value"/>"/>
	        	<table width='100%'>
			        <%
			            String sHistory = ((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_6");
			        
			        	counter = 0;
			        	labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
			        	if(labelTypes !=null){
			                Hashtable labelIds = (Hashtable)labelTypes.get("cdo.6");
			                if(labelIds!=null) {
			                    Enumeration idsEnum = labelIds.elements();
			                    Hashtable hSelected = new Hashtable();
			                    while (idsEnum.hasMoreElements()) {
			                        label = (Label)idsEnum.nextElement();
			                        hSelected.put(label.value.toUpperCase(),label.id);
			                    }
			                    
			                    Vector keys = new Vector(hSelected.keySet());
			                    Collections.sort(keys);
			                    Iterator it = keys.iterator();
			                    String sLabelValue, sLabelID;
			                    while (it.hasNext()) {
			                        sLabelValue = (String)it.next();
			                        sLabelID = (String)hSelected.get(sLabelValue);
			                        if(counter % 4 ==0){
			                        	if(counter>0){
			                        		out.println("</tr>");
			                        	}
			                        	out.println("<tr>");
			                        }
			                        counter++;
			                        
							        %><td width='25%'><input class='hand' type="checkbox" name="history.<%=sLabelID%>" id="history.<%=sLabelID%>" value="<%=sLabelID%>" <%=sHistory.indexOf("*"+sLabelID+"*")>-1?"checked":"" %>/><label for="history.<%=sLabelID%>" class="hand"><%=sLabelValue%></label></td><%
			                    }
			                }
			        	}
			        %>
		        	</tr>
	        	</table>
	            <textarea onclick="this.value=this.value.toUpperCase();resizeTextarea(this,10);" id="history_comment" class="text" cols="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_6_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_6_COMMENT" translate="false" property="value"/></textarea>
	        </td>
	        
	        <%-- 7 - meds --%>
	        <td class="admin"><%=getTran(request,"web","cdo.meds",sWebLanguage)%></td>
	        <td class="admin2" nowrap>
	            <select onmouseover="this.className='text'" id='cdo7' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_7" property="itemId"/>]>.value">
	                <%=ScreenHelper.writeSelectUpperCase("cdo.7",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_7"),sWebLanguage,false,false)%>
	            </select>
	            <br/>
	            <textarea onclick="this.className='text'"  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="20" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_7_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_7_COMMENT" translate="false" property="value"/></textarea>
	        </td>
	        
	        <%-- 8 - allergy --%>
	        <td class="admin"><%=getTran(request,"web","cdo.allergy",sWebLanguage)%></td>
	        <td class="admin2" nowrap>
	            <select onmouseover="this.className='text'" id='cdo8' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_8" property="itemId"/>]>.value">
	                <%=ScreenHelper.writeSelectUpperCase("cdo.8",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_8"),sWebLanguage,false,false)%>
	            </select>
	            <br/>
	            <textarea onclick="this.className='text'"  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="20" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_8_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_8_COMMENT" translate="false" property="value"/></textarea>
	        </td>
	    </tr>
	    
    	<%-- 9/10 - history family + surgery ------------%>
	    <tr>
	        <td class="admin"><%=getTran(request,"web","cdo.history.family",sWebLanguage)%></td>
	        <td class="admin2" nowrap>
	            <select onmouseover="this.className='text'" id='cdo9' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_9" property="itemId"/>]>.value">
	                <%=ScreenHelper.writeSelectUpperCase("cdo.9",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_9"),sWebLanguage,false,false)%>
	            </select>
	            <br/>
	            <textarea onclick="this.className='text'"  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_9_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_9_COMMENT" translate="false" property="value"/></textarea>
	        </td>
	        
	        <td class="admin"><%=getTran(request,"web","cdo.history.surgery",sWebLanguage)%></td>
	        <td class="admin2" colspan="3" nowrap>
	            <select onmouseover="this.className='text'" id='cdo10' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_10" property="itemId"/>]>.value">
	                <%=ScreenHelper.writeSelectUpperCase("cdo.10",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_10"),sWebLanguage,false,false)%>
	            </select>
	            <br/>
	            <textarea onclick="this.className='text'"  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_10_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_10_COMMENT" translate="false" property="value"/></textarea>
	        </td>
	    </tr>
	    
    	<%-- history eye + intake -------------------%>
	    <tr>
	        <td class="admin"><%=getTran(request,"web","cdo.history.eye",sWebLanguage)%></td>
	        <td class="admin2">
	            <textarea onclick="this.className='text'"  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_11" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_11" translate="false" property="value"/></textarea>
	        </td>
	        
	        <td class="admin"><%=getTran(request,"web","cdo.intake",sWebLanguage)%></td>
	        <td class="admin2" colspan="3">
	            <textarea onclick="this.className='text'"  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_12" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_12" translate="false" property="value"/></textarea>
	        </td>
	    </tr>
	    
    	<%-- history eye --%>
	    <tr>
	    	<td class="admin2" colspan="2" style="vertical-align:top;padding:0px">
	    		<table width="100%">
	    			<tr>
	    				<td colspan="3" class="admin"><%=getTran(request,"web","cdo.avlsc",sWebLanguage)%></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.RE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLSC_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLSC_RE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_AVLSC_RE")%>/></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.LE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLSC_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLSC_LE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_AVLSC_LE")%>/></td>
					</tr>
	    			<tr>
	    				<td colspan="3" class="admin"><%=getTran(request,"web","cdo.ts",sWebLanguage)%></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.RE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_TS_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_TS_RE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_TS_RE")%>/></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.LE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_TS_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_TS_LE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_TS_LE")%>/></td>
					</tr>
	    			<tr>
	    				<td colspan="3" class="admin"><%=getTran(request,"web","cdo.avlac",sWebLanguage)%></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.RE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLAC_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLAC_RE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_AVLAC_RE")%>/></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.LE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLAC_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_AVLAC_LE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_AVLAC_LE")%>/></td>
					</tr>
	    			<tr>
	    				<td colspan="3" class="admin"><%=getTran(request,"web","cdo.laf.re",sWebLanguage)%></td>
	    				<td colspan="1" class="admin2"><%=getTran(request,"web","cdo.anterior.segment",sWebLanguage)%></td>
	    				<td colspan="5" class="admin2"><input  type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_RE_AS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_RE_AS" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_LAF_RE_AS")%>/></td>
	    			</tr>
	    			<tr>
	    				<td colspan="3" class="admin"></td>
	    				<td colspan="1" class="admin2"><%=getTran(request,"web","cdo.annexes",sWebLanguage)%></td>
	    				<td colspan="5" class="admin2"><input  type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_RE_ANNEXES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_RE_ANNEXES" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_LAF_RE_ANNEXES")%>/></td>
	    			</tr>
	    			<tr>
	    				<td colspan="3" class="admin"><%=getTran(request,"web","cdo.laf.le",sWebLanguage)%></td>
	    				<td colspan="1" class="admin2"><%=getTran(request,"web","cdo.anterior.segment",sWebLanguage)%></td>
	    				<td colspan="5" class="admin2"><input  type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_LE_AS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_LE_AS" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_LAF_LE_AS")%>/></td>
	    			</tr>
	    			<tr>
	    				<td colspan="3" class="admin"></td>
	    				<td colspan="1" class="admin2"><%=getTran(request,"web","cdo.annexes",sWebLanguage)%></td>
	    				<td colspan="5" class="admin2"><input  type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_LE_ANNEXES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_LAF_LE_ANNEXES" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_LAF_LE_ANNEXES")%>/></td>
	    			</tr>
   					<tr>
		    			<td colspan="3" class="admin"><%=getTran(request,"web","cdo.gonioscopy.exam",sWebLanguage)%></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.RE",sWebLanguage)%>: <input type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_RE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_RE")%>/></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.LE",sWebLanguage)%>: <input type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_LE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_FUNDUS_GONIOSCOPY_LE")%>/></td>
   					</tr>
	    			<tr>
	    				<td colspan="3" class="admin"><%=getTran(request,"web","cdo.pio",sWebLanguage)%></td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.RE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_PIO_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_PIO_RE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_PIO_RE")%>/> mmHg</td>
	    				<td colspan="3" class="admin2"><%=getTran(request,"web","cdo.LE",sWebLanguage)%>: <input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_PIO_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_PIO_LE" translate="false" property="value"/>" <%=setRightClickMini("ITEM_TYPE_CDO_PIO_LE")%>/> mmHg</td>
					</tr>
					<tr>
						<td colspan="9">
				    		<table width="100%">
				    			<tr>
					    			<td class="admin" nowrap><%=getTran(request,"web","cdo.fundus",sWebLanguage)%></td>
					    			<td class="admin" style="text-align: left"><%=getTran(request,"web","cdo.RE",sWebLanguage)%></td>
					    			<td class="admin" style="text-align: left"><%=getTran(request,"web","cdo.LE",sWebLanguage)%></td>
				    			</tr>
				    			<tr>
					    			<td class="admin" style="text-align: left">
									</td>	
					    						<tr height="50px"><td/></tr>				
					    			<td class="admin2" nowrap>
										<input type="checkbox" class="hand" id="cb_fundus_direct_re" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_DIRECT_RE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_DIRECT_RE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
										<%=getLabel(request,"web","cdo.direct",sWebLanguage,"cb_fundus_direct")%>&nbsp;					
										<input type="checkbox" class="hand" id="cb_fundus_20d_re" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_20D_RE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_20D_RE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
										<%=getLabel(request,"web","cdo.20D",sWebLanguage,"cb_fundus_20")%>&nbsp;					
										<input type="checkbox" class="hand" id="cb_fundus_90d_re" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_90D_RE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_90D_RE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
										<%=getLabel(request,"web","cdo.90D",sWebLanguage,"cb_fundus_90d")%>&nbsp;					
									</td>
					    			<td class="admin2" nowrap>
										<input type="checkbox" class="hand" id="cb_fundus_direct_le" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_DIRECT_LE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_DIRECT_LE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
										<%=getLabel(request,"web","cdo.direct",sWebLanguage,"cb_fundus_direct")%>&nbsp;					
										<input type="checkbox" class="hand" id="cb_fundus_20d_le" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_20D_LE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_20D_LE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
										<%=getLabel(request,"web","cdo.20D",sWebLanguage,"cb_fundus_20d")%>&nbsp;					
										<input type="checkbox" class="hand" id="cb_fundus_90d_le" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_90D_LE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_90D_LE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
										<%=getLabel(request,"web","cdo.90D",sWebLanguage,"cb_fundus_90d")%>&nbsp;					
									</td>
					    		</tr>
			   					<tr>
					    			<td class="admin" width="1%"><%=getTran(request,"web","cdo.cd",sWebLanguage)%></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_CD_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_CD_RE" translate="false" property="value"/>"/></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_CD_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_CD_LE" translate="false" property="value"/>"/></td>
			   					</tr>
			   					<tr>
					    			<td class="admin" width="1%"><%=getTran(request,"web","cdo.papil",sWebLanguage)%></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PAPIL_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PAPIL_RE" translate="false" property="value"/>"/></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PAPIL_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PAPIL_LE" translate="false" property="value"/>"/></td>
			   					</tr>
			   					<tr>
					    			<td class="admin"><%=getTran(request,"web","cdo.NFL",sWebLanguage)%></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_NFL_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_NFL_RE" translate="false" property="value"/>"/></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_NFL_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_NFL_LE" translate="false" property="value"/>"/></td>
			   					</tr>
			   					<tr>
					    			<td class="admin"><%=getTran(request,"web","cdo.macula",sWebLanguage)%></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_MACULA_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_MACULA_RE" translate="false" property="value"/>"/></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_MACULA_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_MACULA_LE" translate="false" property="value"/>"/></td>
			   					</tr>
			   					<tr>
					    			<td class="admin"><%=getTran(request,"web","cdo.vessels",sWebLanguage)%></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_VESSELS_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_VESSELS_RE" translate="false" property="value"/>"/></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_VESSELS_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_VESSELS_LE" translate="false" property="value"/>"/></td>
			   					</tr>
			   					<tr>
					    			<td class="admin"><%=getTran(request,"web","cdo.periphery",sWebLanguage)%></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PERIPHERY_RE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PERIPHERY_RE" translate="false" property="value"/>"/></td>
					    			<td class="admin2"><input type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PERIPHERY_LE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_FUNDUS_PERIPHERY_LE" translate="false" property="value"/>"/></td>
			   					</tr>
				    		</table>
						</td>
					</tr>
	    		</table>
	    	</td>
	    	<td class="admin2" colspan="4" style="vertical-align: top; padding: 0px">
	    		<table width="100%">
	    			<tr>
	    				<td class="admin"><%=getTran(request,"web","cdo.correction.worn",sWebLanguage)%></td>
	    				<td class="admin"><%=getTran(request,"web","cdo.RE",sWebLanguage)%></td>
	    				<td class="admin2" colspan="2"><input onblur="isNumber(this)" type="text" size="6" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_RIGHT_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_RIGHT_1" translate="false" property="value"/>"/>
	    					=<input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_RIGHT_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_RIGHT_2" translate="false" property="value"/>"/>
	    					/
	    					<input onblur="isNumber(this)" type="text" size="3" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_RIGHT_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_RIGHT_3" translate="false" property="value"/>"/>�
	    				</td>
	    			</tr>
	    			<tr>
	    				<td class="admin2"></td>
	    				<td class="admin"><%=getTran(request,"web","cdo.LE",sWebLanguage)%></td>
	    				<td class="admin2" colspan="2"><input onblur="isNumber(this)" type="text" size="6" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_LEFT_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_LEFT_1" translate="false" property="value"/>"/>
	    					=<input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_LEFT_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_LEFT_2" translate="false" property="value"/>"/>
	    					/
	    					<input onblur="isNumber(this)" type="text" size="3" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_LEFT_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_LEFT_3" translate="false" property="value"/>"/>�
	    				</td>
	    			</tr>
	    			<tr>
	    				<td class="admin2" colspan="2"></td>
	    				<td class="admin2" style='text-align: center'>
	    					<%=getTran(request,"web","cdo.addplus.L",sWebLanguage)%>
	    					<input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_ADD_L" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_ADD_L" translate="false" property="value"/>"/>
	    					<%=getTran(request,"web","cdo.addplus.R",sWebLanguage)%>
	    					<input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_ADD_R" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_16_ADD_R" translate="false" property="value"/>"/>
	    				</td>
	    				<td/>
	    			</tr>
	    			<tr>
	    				<td class="admin"><%=getTran(request,"web","cdo.refraction.measured",sWebLanguage)%></td>
	    				<td class="admin"><%=getTran(request,"web","cdo.RE",sWebLanguage)%></td>
	    				<td class="admin2" colspan="2"><input  onblur="isNumber(this)"type="text" size="6" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_RIGHT_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_RIGHT_1" translate="false" property="value"/>"/>
	    					=<input  onblur="isNumber(this)"type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_RIGHT_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_RIGHT_2" translate="false" property="value"/>"/>
	    					/
	    					<input  onblur="isNumber(this)"type="text" size="3" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_RIGHT_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_RIGHT_3" translate="false" property="value"/>"/>�
	    				</td>
	    			</tr>
	    			<tr>
	    				<td class="admin2"></td>
	    				<td class="admin"><%=getTran(request,"web","cdo.LE",sWebLanguage)%></td>
	    				<td class="admin2" colspan="2"><input  onblur="isNumber(this)"type="text" size="6" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_LEFT_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_LEFT_1" translate="false" property="value"/>"/>
	    					=<input  onblur="isNumber(this)"type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_LEFT_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_LEFT_2" translate="false" property="value"/>"/>
	    					/
	    					<input  onblur="isNumber(this)"type="text" size="3" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_LEFT_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_LEFT_3" translate="false" property="value"/>"/>�
	    				</td>
	    			</tr>
	    			<tr>
	    				<td class="admin2" colspan="2"></td>
	    				<td class="admin2" style='text-align: center'>
	    					<%=getTran(request,"web","cdo.addplus.L",sWebLanguage)%>
	    					<input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_ADD_L" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_ADD_L" translate="false" property="value"/>"/>
	    					<%=getTran(request,"web","cdo.addplus.R",sWebLanguage)%>
	    					<input onblur="isNumber(this)" type="text" size="5" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_ADD_R" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_17_ADD_R" translate="false" property="value"/>"/>
	    				</td>
	    				<td/>
	    			</tr>
	    			
    	            <%-- cdo visual field --%>
	    			<tr>
	    				<td class="admin" colspan="4"><%=getTran(request,"web","cdo.visual.field",sWebLanguage)%></td>
	    			</tr>
	    			<tr>
	    				<td colspan="4" class="admin2">
	    					<center>
			    				<table>
			    					<tr>
					    				<td height="143px" width="340px" background="<c:url value="/_img/ophtalmo_iota.png"/>" style="vertical-align: top">
					    					<table width="100%">
					    						<tr height="30px">
					    							<td width="12%"/>
					    							<td width="20%">
	    					                            <br><br><br>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_U_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_U_L;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td width="20%">
	    					                            <br><br><br>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_U_R" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_U_R;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td width="20%">
	    					                            <br><br><br>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_U_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_U_L;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td width="20%">
	    					                            <br><br><br>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_U_R" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_U_R;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td width="8%"/>
					    						</tr>
					    						
					    						<tr height="30px">
					    							<td/>
					    							<td>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_L_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_L_L;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_L_R" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_LEFT_L_R;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_L_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_L_L;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td>
					    								<center>
															<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_L_R" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_18_RIGHT_L_R;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
														</center>
													</td>
					    							<td/>
					    						</tr>
					    					</table>
					    				<td>
			    					</tr>
			    				</table>
		    				</center>
	    				</td>
	    			</tr>
	    			<tr>
	    				<td class="admin" colspan="4"><%=getTran(request,"web","cdo.visual.pupilles",sWebLanguage)%></td>
	    			</tr>
	    			<tr>
	    				<td class='admin2'/>
	    				<td class="admin2"><%=getTran(request,"web","cdo.size.in.mm",sWebLanguage)%></td>
	    				<td class="admin2"><%=getTran(request,"web","cdo.reaction",sWebLanguage)%></td>
	    				<td class="admin2"><%=getTran(request,"web","cdo.rapd",sWebLanguage)%></td>
	    			</tr>
	    			<tr>
	    				<td class="admin2" style="text-align: right"><font style="font-size: 35">P </font></td>
	    				<td class="admin2">
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H;value=1" property="value" outputString="checked"/> value="1"/>1
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H;value=2" property="value" outputString="checked"/> value="2"/>2
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H;value=3" property="value" outputString="checked"/> value="3"/>3
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_H;value=4" property="value" outputString="checked"/> value="4"/>4
							<BR/>
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L;value=1" property="value" outputString="checked"/> value="1"/>1
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L;value=2" property="value" outputString="checked"/> value="2"/>2
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L;value=3" property="value" outputString="checked"/> value="3"/>3
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_S_L;value=4" property="value" outputString="checked"/> value="4"/>4
						</td>
	    				<td class="admin2">
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_H;value=1" property="value" outputString="checked"/> value="1"/>1
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_H;value=2" property="value" outputString="checked"/> value="2"/>2
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_H;value=3" property="value" outputString="checked"/> value="3"/>3
							<BR/>
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_L;value=1" property="value" outputString="checked"/> value="1"/>1
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_L;value=2" property="value" outputString="checked"/> value="2"/>2
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_L" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_R_L;value=3" property="value" outputString="checked"/> value="3"/>3
	    				</td>
	    				<td class="admin2">
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_RAPD" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_RAPD;value=-" property="value" outputString="checked"/> value="-"/>-
							<BR/>
							<input ondblclick="uncheckRadio(this);" type="radio" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_RAPD" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_19_RAPD;value=+" property="value" outputString="checked"/> value="+"/>+
	    				</td>
	    			</tr>
	    		</table>
	    	</td>
	    </tr>
	    
    	<%-- cdo fundus --%>
	    <tr>
	    	<td class="admin2" colspan="2" style="padding: 0px">
	    		<table width='100%'>
	    			<tr>
				        <td class="admin"><%=getTran(request,"web","cdo.complementary.exams",sWebLanguage)%></td>
				        <td class="admin2">
				            <textarea  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_40" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_40" translate="false" property="value"/></textarea>
				        </td>
				    </tr>
	    		</table>
	    	</td>
	    	<td class="admin2" colspan="4" style="padding: 0px; vertical-align: top">
	    		<table width='100%'>
				    <tr>
				        <td class="admin"><%=getTran(request,"web","cdo.results",sWebLanguage)%></td>
				        <td class="admin2" colspan="3">
				            <textarea  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_41" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_41" translate="false" property="value"/></textarea>
				        </td>
	    			</tr>
	    		</table>
	    	</td>
	    </tr>
	    <tr>
	        <td class="admin" colspan="2"><%=getTran(request,"web","cdo.diagnosis",sWebLanguage)%></td>
	        <td class="admin" colspan="4"><%=getTran(request,"web","cdo.todays.intake",sWebLanguage)%></td>
	    </tr>
	    <tr>
	        <td class="admin" colspan="2" style="padding: 0px; vertical-align: top">
	        	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncodingNoRFE.jsp"),pageContext);%>
	            <textarea  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="60" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC" translate="false" property="value"/></textarea>
	        	
				 <!-- 
	        	<table width="100%">
	        		<%-- general diagnosis --%>
	        		<tr>
				        <td class="admin"><%=getTran(request,"web","cdo.general.diagnosis",sWebLanguage)%></td>
				        <td class="admin2">
				            <select id='physician' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL_1" property="itemId"/>]>.value" >
				                <option></option>
				                <%=ScreenHelper.writeSelectUpperCase("cdo.general.diagnosis",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL_1"),sWebLanguage,false,false)%>
				            </select><br/>
				            <select id='physician' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL_2" property="itemId"/>]>.value" >
				                <option></option>
				                <%=ScreenHelper.writeSelectUpperCase("cdo.general.diagnosis",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL_2"),sWebLanguage,false,false)%>
				            </select><br/>
				            <select id='physician' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL_3" property="itemId"/>]>.value" >
				                <option></option>
				                <%=ScreenHelper.writeSelectUpperCase("cdo.general.diagnosis",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL_3"),sWebLanguage,false,false)%>
				            </select><br/>
				            <textarea  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="60" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_GENERAL" translate="false" property="value"/></textarea>
				        </td>
	        		</tr>
	        		
	        		<%-- specific diagnosis --%>
	        		<tr>
				        <td class="admin"><%=getTran(request,"web","cdo.specific.diagnosis",sWebLanguage)%></td>
				        <td class="admin2">
				            <select id='physician' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC_1" property="itemId"/>]>.value" >
				                <option></option>
				                <%=ScreenHelper.writeSelectUpperCase("cdo.specific.diagnosis",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC_1"),sWebLanguage,false,true)%>
				            </select><br/>
				            <select id='physician' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC_2" property="itemId"/>]>.value" >
				                <option></option>
				                <%=ScreenHelper.writeSelectUpperCase("cdo.specific.diagnosis",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC_2"),sWebLanguage,false,true)%>
				            </select><br/>
				            <select id='physician' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC_3" property="itemId"/>]>.value" >
				                <option></option>
				                <%=ScreenHelper.writeSelectUpperCase("cdo.specific.diagnosis",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_42_SPECIFIC_3"),sWebLanguage,false,true)%>
				            </select><br/>
				        </td>
	        		</tr>
	        	</table>
		         -->
	        </td>
	        <td class="admin" colspan="4" style="padding: 0px; vertical-align: top">
	        	<table width="100%">
	        		<tr>
				        <td class="admin" colspan="3"><%=getTran(request,"web","cdo.treatment",sWebLanguage)%></td>
				    </tr>
	        		<tr>
				        <td class="admin" width="30%"><%=getTran(request,"web","cdo.name",sWebLanguage)%></td>
				        <td class="admin" width="15%"><%=getTran(request,"web","cdo.treatment.rythm",sWebLanguage)%></td>
				        <td class="admin" width="15%"><%=getTran(request,"web","cdo.treatment.duration",sWebLanguage)%></td>
				    </tr>
				    <tr>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_1_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_1_3" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_1_4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_1_4" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_1_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_1_5" translate="false" property="value"/>"/></td>
				    </tr>
				    <tr>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_2_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_2_3" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_2_4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_2_4" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_2_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_2_5" translate="false" property="value"/>"/></td>
				    </tr>
				    <tr>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_3_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_3_3" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_3_4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_3_4" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_3_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_3_5" translate="false" property="value"/>"/></td>
				    </tr>
				    <tr>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_4_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_4_3" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_4_4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_4_4" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_4_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_4_5" translate="false" property="value"/>"/></td>
				    </tr>
				    <tr>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_5_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_5_3" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_5_4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_5_4" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_5_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_5_5" translate="false" property="value"/>"/></td>
				    </tr>
				    <tr>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="40" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_6_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_6_3" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_6_4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_6_4" translate="false" property="value"/>"/></td>
				    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="10" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_6_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_6_5" translate="false" property="value"/>"/></td>
				    </tr>
				    <tr>
				    	<td class="admin2" colspan="3">
				            <textarea  onKeyup="this.value=this.value.toUpperCase();resizeTextarea(this,10);" class="text" cols="60" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_43_COMMENT" translate="false" property="value"/></textarea>
				    	</td>
				    </tr>
	        	</table>
	        </td>
	    </tr>
	    
	    <!-- 
		<tr>
	        <td class="admin" colspan="6"><%=getTran(request,"web","cdo.next.control",sWebLanguage)%></td>
		</tr>
		<tr>
	        <td class="admin" colspan="1"><%=getTran(request,"web","cdo.date",sWebLanguage)%></td>
	        <td class="admin" colspan="1"><%=getTran(request,"web","cdo.reason",sWebLanguage)%></td>
	        <td class="admin" colspan="2"><%=getTran(request,"web","cdo.todo",sWebLanguage)%></td>
	        <td class="admin" colspan="2"><%=getTran(request,"web","cdo.physician",sWebLanguage)%></td>
		</tr>
	    <tr>
	    	<td class="admin2"><input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_DATE_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_DATE_1" translate="false" property="value"/>" id="cdodate1" OnBlur='checkDate(this)'> <script>writeMyDate("cdodate1");</script></td>
	    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="50" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_REASON_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_REASON_1" translate="false" property="value"/>"/></td>
	    	<td class="admin2" colspan="2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_TODO_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_TODO_1" translate="false" property="value"/>"/></td>
	    	<td class="admin2" colspan="2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_PHYSICIAN_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_PHYSICIAN_1" translate="false" property="value"/>"/></td>
	    </tr>
	    <tr>
	    	<td class="admin2"><input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_DATE_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_DATE_2" translate="false" property="value"/>" id="cdodate2" OnBlur='checkDate(this)'> <script>writeMyDate("cdodate2");</script></td>
	    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="50" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_REASON_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_REASON_2" translate="false" property="value"/>"/></td>
	    	<td class="admin2" colspan="2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_TODO_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_TODO_2" translate="false" property="value"/>"/></td>
	    	<td class="admin2" colspan="2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_PHYSICIAN_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_PHYSICIAN_2" translate="false" property="value"/>"/></td>
	    </tr>
	    <tr>
	    	<td class="admin2"><input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_DATE_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_DATE_3" translate="false" property="value"/>" id="cdodate3" OnBlur='checkDate(this)'> <script>writeMyDate("cdodate3");</script></td>
	    	<td class="admin2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="50" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_REASON_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_REASON_3" translate="false" property="value"/>"/></td>
	    	<td class="admin2" colspan="2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_TODO_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_TODO_3" translate="false" property="value"/>"/></td>
	    	<td class="admin2" colspan="2"><input onKeyup="this.value=this.value.toUpperCase();" type="text" size="30" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_PHYSICIAN_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CDO_44_PHYSICIAN_3" translate="false" property="value"/>"/></td>
	    </tr>
	    -->
    </table>
        
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occupophtalmology",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>

	<%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){			
	document.getElementById("complaints").value = "";
	document.getElementById("history").value = "";
	
	var inputs = document.getElementsByTagName("input");
	for(var i = 0; i < inputs.length; i++) {
	  if(inputs[i].name.indexOf("complaints.")==0 && inputs[i].checked) {
	  	document.getElementById("complaints").value+="*"+inputs[i].value+"*";
	  }
	  if(inputs[i].name.indexOf("history.")==0 && inputs[i].checked) {
	  	document.getElementById("history").value+="*"+inputs[i].value+"*";
	  }
	}
	if(document.getElementById("complaints").value.length==0 || document.getElementById("physician").value.length==0 || (!document.getElementById("rbreferenceyes").checked && !document.getElementById("rbreferenceno").checked)){
	  alertDialog("web","cdo.obligatefields2");
	}
	else{
	  var temp = Form.findFirstElement(transactionForm);//for ff compatibility
      <%
       	SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
       	out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
	}
  }
  function searchEncounter(){
      pu = openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  if(<%=((TransactionVO)transaction).getServerId()%>==1 && document.getElementById('encounteruid').value=='' <%=request.getParameter("nobuttons")==null?"":" && 1==0"%>){
	  alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	  searchEncounter();
  }	
	
  document.getElementById("cdo2").onchange();
</script>

<%=writeJSButtons("transactionForm","saveButton")%>
