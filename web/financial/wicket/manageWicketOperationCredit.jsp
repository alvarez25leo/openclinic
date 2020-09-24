<%@page import="be.openclinic.finance.*,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"financial.wicketoperation","select",activeUser)%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>

<%
    String sShowReturn = checkString(request.getParameter("ShowReturn"));
    String sBack = "";
    boolean bShow = false;

    if(sShowReturn.equals("TRUE")){
        bShow = true;
        sBack = " doSearchBack();";
    }

    String sEditWicketOperationUID     = checkString(request.getParameter("EditWicketOperationUID")),
           sEditWicketOperationDate    = checkString(request.getParameter("EditWicketOperationDate")),
           sEditWicketOperationAmount  = checkString(request.getParameter("EditWicketOperationAmount")),
           sEditWicketOperationType    = checkString(request.getParameter("EditWicketOperationType")),
           sEditWicketOperationCategory    = checkString(request.getParameter("EditWicketOperationCategory")),
           sEditWicketOperationComment = checkString(request.getParameter("EditWicketOperationComment")),
           sEditWicketOperationSource = checkString(request.getParameter("EditWicketOperationSource")),
           sEditWicketOperationSourceType = checkString(request.getParameter("EditWicketOperationSourceType")),
           sEditWicketOperationWicket  = checkString(request.getParameter("EditWicketOperationWicket"));
           
    if(request.getParameter("FindWicketOperationUID")!=null){
        sEditWicketOperationUID = checkString(request.getParameter("FindWicketOperationUID"));
    }
    int version = 0;

    // today as default date
    if(sEditWicketOperationDate.length()==0){
        sEditWicketOperationDate = ScreenHelper.stdDateFormat.format(new java.util.Date()); // now
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********** financial/wicket/manageWicketOperationCredit.jsp ***********"); 
    	Debug.println("sEditWicketOperationUID     : "+sEditWicketOperationUID); 
    	Debug.println("sEditWicketOperationDate    : "+sEditWicketOperationDate); 
    	Debug.println("sEditWicketOperationAmount  : "+sEditWicketOperationAmount); 
    	Debug.println("sEditWicketOperationType    : "+sEditWicketOperationType); 
    	Debug.println("sEditWicketOperationCategory: "+sEditWicketOperationCategory); 
    	Debug.println("sEditWicketOperationComment : "+sEditWicketOperationComment); 
    	Debug.println("sEditWicketOperationWicket  : "+sEditWicketOperationWicket+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    
    if(sEditWicketOperationUID.length() > 0){
        WicketCredit wicketOp = WicketCredit.get(sEditWicketOperationUID);

        if(checkString(wicketOp.getUid()).length() > 0){
	        if(wicketOp.getOperationDate()!=null){
	            sEditWicketOperationDate = ScreenHelper.stdDateFormat.format(wicketOp.getOperationDate());
	        }
	        sEditWicketOperationAmount = Double.toString(wicketOp.getAmount());
	        if(wicketOp.getComment()!=null){
	            sEditWicketOperationComment = wicketOp.getComment().toString();
	        }
	        sEditWicketOperationType = checkString(wicketOp.getOperationType());
	        sEditWicketOperationCategory = checkString(wicketOp.getCategory());
	        sEditWicketOperationWicket = checkString(wicketOp.getWicketUID());
	        if(wicketOp.getReferenceObject()!=null){
	        	sEditWicketOperationSourceType=wicketOp.getReferenceObject().getObjectType();
	        	sEditWicketOperationSource=wicketOp.getReferenceObject().getObjectUid();
	        }
	        version = wicketOp.getVersion();
        }
        else{
        	sMsg = getTran(request,"web","noRecordsFound",sWebLanguage);
        }
    }

    if(sEditWicketOperationWicket.length()==0){
        sEditWicketOperationWicket = activeUser.getParameter("defaultwicket");
    }
    if(sEditWicketOperationWicket.length()==0){
        sEditWicketOperationWicket = checkString((String)session.getAttribute("defaultwicket"));
    }
%>

<form name='FindForm' id="FindForm" method='POST'>
    <%=writeTableHeader("wicket","wicketcredit",sWebLanguage,sBack)%>
    
    <table class='menu' width='100%' cellspacing='1' cellpadding='0'>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">ID&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="FindWicketOperationUID" name="FindWicketOperationUID" onblur="isNumber(this)" value="<%=sEditWicketOperationUID%>">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindForm.FindWicketOperationUID.value = '';">
                
                <%-- BUTTONS --%>
                <input type="button" class="button" name="ButtonFind" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="doFind();">
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="doNew();">
            </td>
        </tr>
    </table>
    
    <%
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%
        }
    %>
</form>

<form name="EditForm" method="POST" action="<c:url value='/main.do'/>?Page=financial/wicket/manageWicketOperationCredit.jsp&ts=<%=getTs()%>">
	<input type='hidden' name='EditWicketOperationSource' id='EditWicketOperationSource' value='<%=sEditWicketOperationSource %>'/>
	<input type='hidden' name='EditWicketOperationSourceType' id='EditWicketOperationSourceType' value='<%=sEditWicketOperationSourceType %>'/>
    <table class='list' border='0' width='100%' cellspacing='1' cellpadding='0'>
        <%-- wicket --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"wicket","wicket",sWebLanguage)%>&nbsp;*</td>
            <td class='admin2'>
                <select class="text" name="EditWicketOperationWicket" id="EditWicketOperationWicket" onchange='loadWaitingTransfers();loadTodayCredits()'>
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        Vector vWickets = Wicket.getWicketsForUser(activeUser.userid);
                        Iterator iter = vWickets.iterator();
                        Wicket wicket;

                        String sSelected;
                        while(iter.hasNext()){
                            wicket = (Wicket)iter.next();
                            if(sEditWicketOperationWicket.equals(wicket.getUid())){
                                sSelected = " selected";
                            }
                            else{
                                sSelected = "";
                            }
                            
                            %><option value="<%=wicket.getUid()%>" <%=sSelected%>><%=wicket.getUid()%>&nbsp;<%=getTranNoLink("service",wicket.getServiceUID(),sWebLanguage)%></option><%
                        }
                    %>
                </select>
            </td>
        </tr>
		<%
			if(sEditWicketOperationSourceType.equalsIgnoreCase("WicketTransfer")){
		%>
	        <tr>
	            <td class="admin"><%=getTran(request,"web","from",sWebLanguage)%></td>
	            <td class="admin2" id='sourcetd'>
	                <%
	                	WicketDebet wo = WicketDebet.get(sEditWicketOperationSource);
	                	if(wo!=null && wo.getWicket()!=null && wo.getWicket().getService()!=null){
	                		out.print(wo.getWicket().getService().getLabel(sWebLanguage)+ " ("+wo.getUid()+")");
	                	}
	                %>
	            </td>
	        </tr>
        <%
			}
        %>
        <%-- DATE --%>
        <tr>
            <td class="admin" ><%=getTran(request,"Web","date",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2"><%=writeDateField("EditWicketOperationDate","EditForm",sEditWicketOperationDate,sWebLanguage)%>
            <%
                if(version > 1){
                    %><a href='javascript:void(0)' onclick='getWicketOperationHistory("<%=sEditWicketOperationUID %>",20)' class='link transactionhistory' title='<%=getTranNoLink("web","modificationshistory",sWebLanguage)%>' alt="<%=getTranNoLink("web","modificationshistory",sWebLanguage)%>">...</a><%
                }
            %>
            </td>
        </tr>
        
        <%-- OPERATION TYPE --%>
        <tr>
            <td class="admin"><%=getTran(request,"wicket","operation_type",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
           	<%
           		if(sEditWicketOperationType.equalsIgnoreCase("patient.payment")){
           			out.println(getTran(request,"credit.type","patient.payment",sWebLanguage));
           			out.print("<input type='hidden' name='EditWicketOperationType' id='EditWicketOperationType' value='"+sEditWicketOperationType+"'/>");
           		}
           		else{
	            	%>
		                <select class="text" name='EditWicketOperationType' id='EditWicketOperationType'>
		                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
		                    <%=ScreenHelper.writeSelect(request,"wicketcredit.type",sEditWicketOperationType,sWebLanguage)%>
		                </select>
	                <%
           		}
               %>
            </td>
        </tr>
        
        <tr>
            <td class="admin"><%=getTran(request,"wicket","operation_category",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
	            <select class="text" name='EditWicketOperationCategory' id='EditWicketOperationCategory'>
	            	<option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
	                <%=ScreenHelper.writeSelect(request,"credit.category",sEditWicketOperationCategory,sWebLanguage)%>
	            </select>
            </td>
        </tr>
        
        <%-- AMOUNT --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","amount",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input class="text" type="text" name="EditWicketOperationAmount" id="EditWicketOperationAmount" value="<%=sEditWicketOperationAmount%>" onblur="isNumberNegAndPos(this)"/> <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>
            </td>
        </tr>
        
        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="EditWicketOperationComment" id="EditWicketOperationComment" cols="55" rows="4"><%=sEditWicketOperationComment%></textarea>
            </td>
        </tr>
        
        <%=ScreenHelper.setFormButtonsStart()%>
        	<%
        		if((activeUser.getAccessRight("financial.superuser.select") || !sEditWicketOperationType.equalsIgnoreCase("patient.payment")) && (activeUser.getAccessRight("financial.wicketoperation.edit") || sEditWicketOperationUID.length()==0)){
        	        %><input class='button' type="button" name="EditSaveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;<%
        		}
                if(sEditWicketOperationUID.length()>0){
                    %><input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print",sWebLanguage)%>' onclick="doPrintPdf(document.getElementById('EditWicketOperationUID').value);"><%
                }
                if(bShow){
                    %><input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doSearchBack();"><%
                }
            %>
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    
    <input type="hidden" name="ShowReturn" value="<%=sShowReturn%>">
    <input type="hidden" name="EditWicketOperationUID" id="EditWicketOperationUID" value="<%=sEditWicketOperationUID%>"/>
    
    <span id="divMessage"></span>
</form>

<div id="divTodayCredits" style="width:100%;height:100px;overflow:auto;"></div>
<div id="divWaitingTransfers" style="width:100%;height:250px;overflow:auto;"></div>

<script>
  <%-- DO FIND --%>
  function doFind(){
    if(FindForm.FindWicketOperationUID.value.length>0){
      FindForm.submit();
    }
    else{
      FindForm.FindWicketOperationUID.focus();	
    }
  }

  <%-- DO NEW --%>
  function doNew(){
    FindForm.FindWicketOperationUID.value = "";
    EditForm.EditWicketOperationUID.value = "";

    FindForm.submit();
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
  }

  <%-- DO SEARCH BACK --%>
  function doSearchBack(){
    if(EditForm.EditWicketOperationWicket.value!=""){
      window.location.href="<c:url value='/main.do'/>?Page=financial/wicket/wicketOverview.jsp&WicketUID="+EditForm.EditWicketOperationWicket.value+"&ts=<%=getTs()%>";
    }
    else{
      window.location.href="<c:url value='/main.do'/>?Page=financial/wicket/findWickets.jsp&ts=<%=getTs()%>";
    }
  }

  <%-- DO CLEAR --%>
  function doClear(){
    EditForm.EditWicketOperationUID.value = "";
    EditForm.EditWicketOperationDate.value = "";
    EditForm.EditWicketOperationAmount.value = "";
    EditForm.EditWicketOperationType.value = "";
    EditForm.EditWicketOperationComment.value = "";
    EditForm.EditWicketOperationSource.value = "";
    EditForm.EditWicketOperationSourceType.value = "";
	if(document.getElementById('sourcetd')){
	 document.getElementById('sourcetd').innerHTML='';
	}
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(EditForm.EditWicketOperationWicket.value==""){
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran(null,"web.manage","dataMissing",sWebLanguage)%>');
      EditForm.EditWicketOperationWicket.focus();
    }
    else if(EditForm.EditWicketOperationDate.value==""){
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran(null,"web.manage","dataMissing",sWebLanguage)%>');
      EditForm.EditWicketOperationDate.focus();
    }
    else if(EditForm.EditWicketOperationType.value==""){
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran(null,"web.manage","dataMissing",sWebLanguage)%>');
      EditForm.EditWicketOperationType.focus();
    }
    else if(EditForm.EditWicketOperationAmount.value==""){
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran(null,"web.manage","dataMissing",sWebLanguage)%>');
      EditForm.EditWicketOperationAmount.focus();
    }
    else{
      EditForm.EditSaveButton.disabled = true;
      
      var url = '<c:url value="/financial/wicket/manageWicketOperationCreditSave.jsp"/>?ts='+new Date();
      new Ajax.Request(url,{
        method: "POST",
        postBody: 'EditWicketOperationUID='+EditForm.EditWicketOperationUID.value+
                  '&EditWicketOperationAmount='+EditForm.EditWicketOperationAmount.value+
                  '&EditWicketOperationType='+EditForm.EditWicketOperationType.value+
                  '&EditWicketOperationCategory='+EditForm.EditWicketOperationCategory.value+
                  '&EditWicketOperationComment='+EditForm.EditWicketOperationComment.value+
                  '&EditWicketOperationDate='+EditForm.EditWicketOperationDate.value+
                  '&EditWicketOperationSource='+EditForm.EditWicketOperationSource.value+
                  '&EditWicketOperationSourceType='+EditForm.EditWicketOperationSourceType.value+
                  '&EditWicketOperationWicket='+EditForm.EditWicketOperationWicket.value,
        onSuccess: function(resp){
          var label = eval('('+resp.responseText+')');
          $('divMessage').innerHTML = label.Message;
          doClear();
          loadTodayCredits();
        },
        onFailure: function(){
          $('divMessage').innerHTML = "Error in function doSave() => AJAX";
        }
      });

      EditForm.EditSaveButton.disabled = false;
    }
  }

  <%-- SEARCH WICKET --%>
  function searchWicket(wicketUidField,wicketNameField){
    openPopup("/_common/search/searchWicket.jsp&ts=<%=getTs()%>&VarCode="+wicketUidField+"&VarText="+wicketNameField);
  }

  <%-- SEARCH EDIT REFERENCE --%>
  function searchEditReference(referenceUidField,referenceNameField){
    if(document.getElementById("Editperson").checked){
      openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+referenceUidField+"&ReturnName="+referenceNameField+"&displayImmatNew=no&isUser=no");
    }
    else if(document.getElementById("Editservice").checked){
      openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+referenceUidField+"&VarText="+referenceNameField);
    }
  }

  <%-- CHANGE EDIT TYPE --%>
  function changeEditType(){
    if(document.getElementById("Editperson").checked){
      document.getElementById("EditTypeLabel").innerText = "<%=getTranNoLink("Web","person",sWebLanguage)%>";
    }
    else{
      document.getElementById("EditTypeLabel").innerText = "<%=getTranNoLink("Web","service",sWebLanguage)%>";
    }
    EditForm.EditWicketOperationReference.value = "";
    EditForm.EditWicketOperationReferenceName.value = "";
  }

  <%-- IS NUMBER NEG AND POS --%>
  function isNumberNegAndPos(sObject){
    if(sObject.value==0) return false;
    sObject.value = sObject.value.replace(",",".");
    if(sObject.value.charAt(0)=="-"){
      sObject.value = sObject.value.substring(1,sObject.value.length);
    }
    sObject.value = sObject.value.replace("-","");
    var string = sObject.value;
    var vchar = "01234567890.";
    var dotCount = 0;
    for(var i=0; i<string.length; i++){
      if(vchar.indexOf(string.charAt(i))==-1){
        sObject.value = "";
        //sObject.focus();
        return false;
      }
      else if(string.charAt(i)=="."){
        dotCount++;
        if(dotCount > 1){
          sObject.value = "";
          //sObject.focus();
          return false;
        }
      }
    }

    if(sObject.value.length > 250){
      sObject.value = sObject.value.substring(0,249);
    }

    return true;
  }

  <%-- SET WICKET --%>
  function setWicket(uid){
    EditForm.EditWicketOperationUID.value = uid;
    EditForm.submit();
  }
  
  function setWicketCredit(sourceUid,amount,comment){
	  document.getElementById('EditWicketOperationUID').value='';
	  document.getElementById('EditWicketOperationSource').value=sourceUid;
	  document.getElementById('EditWicketOperationSourceType').value='WicketTransfer';
	  document.getElementById('EditWicketOperationAmount').value=amount;
	  document.getElementById('EditWicketOperationComment').value=comment;
	  document.getElementById('EditWicketOperationType').value='<%=MedwanQuery.getInstance().getConfigString("defaultCashTransferType","cash.transfer")%>';
	  if(document.getElementById('sourcetd')){
		  document.getElementById('sourcetd').innerHTML=sourceUid;
	  }
  }

  <%-- LOAD TODAY CREDITS --%>
  function loadTodayCredits(){
    var url = '<c:url value="/financial/wicket/todayWicketCredits.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
      method: "POST",
      postBody: 'EditWicketOperationWicket='+document.getElementById('EditWicketOperationWicket').value,
      onSuccess: function(resp){
        $('divTodayCredits').innerHTML = resp.responseText;
      }
    });
  }

  <%-- LOAD TODAY CREDITS --%>
  function loadWaitingTransfers(){
    var url = '<c:url value="/financial/wicket/waitingTransfers.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
      method: "POST",
      postBody: 'EditWicketOperationWicket='+document.getElementById('EditWicketOperationWicket').value,
      onSuccess: function(resp){
        $('divWaitingTransfers').innerHTML = resp.responseText;
      }
    });
  }

  <%-- DO PRINT PDF --%>
  function doPrintPdf(creditUid){
    var url = "<c:url value='/financial/createWicketPaymentReceiptPdf.jsp'/>?CreditUid="+creditUid+"&ts=<%=getTs()%>&PrintLanguage=<%=sWebLanguage%>";
    window.open(url,"WicketPaymentReceiptPdf<%=getTs()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
  }

  loadTodayCredits();
  loadWaitingTransfers();
</script>