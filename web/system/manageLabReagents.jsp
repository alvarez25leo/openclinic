<%@page import="be.openclinic.medical.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"lab.reagents","edit",activeUser)%>

<%
	String sAction = checkString(request.getParameter("Action"));

	String sFindReagentName = checkString(request.getParameter("FindReagentName"));
	
	String sEditLabReagentUid      = checkString(request.getParameter("EditLabReagentUid")),
		   sEditLabReagentName     = checkString(request.getParameter("EditLabReagentName")),
		   sEditLabReagentUnit     = checkString(request.getParameter("EditLabReagentUnit")),
		   sEditLabReagentProvider = checkString(request.getParameter("EditLabReagentProvider")),
		   sEditLabReagentProductUid = checkString(request.getParameter("EditLabReagentProductUid"));
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************** system/manageLabReagents.jsp **********************");
		Debug.println("sAction             : "+sAction);
		Debug.println("sFindReagentName    : "+sFindReagentName);
		Debug.println("sEditLabReagentUid  : "+sEditLabReagentUid);
		Debug.println("sEditLabReagentName : "+sEditLabReagentName);
		Debug.println("sEditLabReagentUnit : "+sEditLabReagentUnit);
		Debug.println("sEditLabReagentProvider   : "+sEditLabReagentProvider);
		Debug.println("sEditLabReagentProductUid : "+sEditLabReagentProductUid+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	String msg = "";
	
	//*** SAVE ********************************************
    if(sAction.equals("save")){
    	Reagent reagent;
    	if(sEditLabReagentUid.length()>0 && sEditLabReagentUid.split("\\.").length==2){	
    		reagent = Reagent.get(sEditLabReagentUid);
    	}
    	else{
            reagent = new Reagent();
            reagent.setUpdateUser(activeUser.userid);
    	}
    	
    	// Store reagent
    	reagent.setName(sEditLabReagentName);
    	reagent.setUnit(sEditLabReagentUnit);
    	reagent.setProvider(sEditLabReagentProvider);
    	reagent.setProductUid(sEditLabReagentProductUid);
    	reagent.setUpdateUser(activeUser.userid);
    	reagent.store();
    	
    	sEditLabReagentUid = reagent.getUid();
    	
        msg = getTran(request,"web","dataIsSaved",sWebLanguage);
        sAction = "search";
    }
	//*** DELETE ******************************************
    else if(sAction.equals("delete")){
        Reagent.delete(sEditLabReagentUid);
        msg = getTran(request,"web","dataIsDeleted",sWebLanguage);
    }
    
%>
<form id="transactionForm" name="transactionForm" onsubmit="return false;" method="post">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditLabReagentUid" id="EditLabReagentUid" value="<%=sEditLabReagentUid%>"/>
    
    <%=writeTableHeader("Web.manage","ManageLabReagents",sWebLanguage," doBack()")%>

    <%-- SEARCH FIELDS --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran(request,"web","name",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindReagentName" id="FindReagentName" size="20" maxlength="50" value="<%=sFindReagentName%>" onkeyup="searchReagent();">
            </td>
        </tr>
        
        <tr>
           <td/>
           <td>
               <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","Search",sWebLanguage)%>" onClick="transactionForm.Action.value='search';searchReagent();">&nbsp;
               <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","New",sWebLanguage)%>" onClick="newReagent();">&nbsp;
               <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="document.getElementById('FindReagentName').value='';">&nbsp;
           </td>
        </tr>
        
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td style="vertical-align:top;" colspan="2" class="white" width="100%">
                <div id="divFindRecords" style="height:100px"></div>
            </td>
        </tr>
    </table>
    
	<%
	    Reagent reagent = new Reagent();
		if(sAction.equals("search") || sAction.equals("new")){
		    // load specified prestation
		    if(sAction.equals("search")){
		    	reagent = Reagent.get(sEditLabReagentUid);
		    }
		}
	%>    
	
    <%-- EDIT FIELDS ----------------------------------------------------------------%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <%-- ID --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">ID</td>
            <td class="admin2"><label id='idlabel'><%=checkString(reagent.getUid())%></label></td>
        </tr>
        <%-- NAME --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","name",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="EditLabReagentName" id="EditLabReagentName" size="80" maxlength="255" value="<%=checkString(reagent.getName())%>">
            </td>
        </tr>
        <%-- UNIT --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","unit",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="EditLabReagentUnit" id="EditLabReagentUnit" size="10" maxlength="10" value="<%=checkString(reagent.getUnit())%>">
            </td>
        </tr>
        <%-- PROVIDER --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","provider",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" name="EditLabReagentProvider" id="EditLabReagentProvider" size="80" maxlength="255" value="<%=checkString(reagent.getProvider())%>">
            </td>
        </tr>
        <%-- PRODUCT --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","product",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="greytext" readonly size="8" name="EditLabReagentProductUid" id="EditLabReagentProductUid" value="<%=checkString(reagent.getProductUid())%>">
                <input type="text" class="greytext" name="productName" id="productName" readonly size="80" value="<%=reagent.getProduct()!=null?reagent.getProduct().getName():""%>">
                
                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchProduct('EditLabReagentProductUid','productName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('EditLabReagentProductUid').value='';document.getElementById('productName').value='';">
            </td>
        </tr>
        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <button class="button" name="saveButton" onclick="saveReagent();"><%=getTranNoLink("accesskey","save",sWebLanguage)%></button>&nbsp;
                <%
                    // no delete button for new lab procedure
                    if(sEditLabReagentUid.length()>0 && !sEditLabReagentUid.equals("-1")){
                        %><input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="deleteReagent('<%=reagent.getUid()%>');">&nbsp;<%
                    }
                %>
            </td>
        </tr>
    </table>
</form>

<script>
  <%-- SEARCH REAGENT --%>
  function searchReagent(){
    transactionForm.Action.value = "search";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchReagentShow.jsp',transactionForm);
  }

  <%-- SEARCH PRODUCT --%>
  function searchProduct(uid,name){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>&ReturnProductUidField="+uid+"&ReturnProductNameField="+name+
              "&DisplayProductsOfService=true&resetServiceStockUid=false";
    openPopup(url);
  }

  function ajaxChangeSearchResults(urlForm, SearchForm, moreParams){
    document.getElementById('divFindRecords').innerHTML = "<div style='text-align:center'><img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading..</div>";
    var url = urlForm;
    var params = Form.serialize(SearchForm)+moreParams;
    var myAjax = new Ajax.Updater("divFindRecords",url,{
      evalScripts:true,
      method: 'post',
      parameters: params,
      onFailure:function(){
        $('divFindRecords').innerHTML = "Problem with ajax request";
      }
    });
  }

  <%-- SAVE REAGENT --%>
  function saveReagent(){
	if(transactionForm.EditLabReagentName.value.length > 0 &&
	   transactionForm.EditLabReagentUnit.value.length > 0){
	  if(transactionForm.EditLabReagentUid.value.length==0){
	    transactionForm.EditLabReagentUid.value = "-1";
	  }
	  var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	  transactionForm.saveButton.style.visibility = "hidden";
	  transactionForm.Action.value = "save";
      document.transactionForm.submit();
	}
	else{
	  if(transactionForm.EditLabReagentName.value.length==0){
	    transactionForm.EditLabReagentName.focus();
	  }
	  else if(transactionForm.EditLabReagentUnit.value.length==0){
	  	transactionForm.EditLabReagentUnit.focus();
	  }

	  alertDialog("web.manage","dataMissing");
	}
  }
	
  <%-- DELETE REAGENT --%>
  function deleteReagent(sLabReagentUid){
      if(yesnoDeleteDialog()){
	  transactionForm.EditLabReagentUid.value = sLabReagentUid;
	  transactionForm.Action.value = "delete";
	  transactionForm.submit();
	}
  }

  <%-- SET REAGENT --%>
  function setReagent(uid,descr){
    var url = '<c:url value="/labos/getReagent.jsp"/>?ts='+new Date();
	new Ajax.Request(url,{
	  method: "GET",
      parameters: 'FindReagentUid='+uid,
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        
        $('EditLabReagentUid').value = uid;
        $('idlabel').innerHTML = uid;
        $('EditLabReagentName').value = label.Name;
        $('EditLabReagentUnit').value = label.Unit;
        $('EditLabReagentProvider').value = label.Provider;
        $('EditLabReagentProductUid').value = label.ProductUid;
        $('productName').value = label.ProductName;
      }
	});
  }

  <%-- NEW REAGENT --%>
  function newReagent(){
    $('idlabel').innerHTML = "";
    $('EditLabReagentUid').value = "";
    $('EditLabReagentName').value = "";
    $('EditLabReagentName').focus();
    
    $('EditLabReagentUnit').value = "";
    $('EditLabReagentProvider').value = "";
    $('EditLabReagentProductUid').value = "";
    $('productName').value = "";
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp";
  }
  
  window.setTimeout('document.getElementById("FindReagentName").focus();',500);
  searchReagent();
</script>