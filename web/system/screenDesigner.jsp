<%@page import="java.io.StringReader,
                be.openclinic.system.Screen,
                be.openclinic.common.OC_Object"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"system.management","select",activeUser)%>
<%=sJSCHAR%>

<% 
    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n################## system/screenDesigner.jsp #################");
        Debug.println("No parameters\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
%>

<form name="editForm" id="editForm" method="post">    
    <%=writeTableHeader("web.manage","screenDesigner",sWebLanguage," doBack();")%>
    <input type="hidden" name="ScreenExamId" value="">
    <input type="hidden" name="performedAction" value="">
    
    <%-- SELECT SCREEN TO EDIT ------------------------------------------------------------------%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <%-- saved rows --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","chooseScreen",sWebLanguage)%></td>
            <td class="admin2">
                <span id="savedScreensDiv"><%-- Ajax --%></span>&nbsp;
                
                <input type="button" name="backButton" id="backButton" class="button" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();">
            </td>
        </tr>
    </table>
    
    <div id="msgDiv" style="height:20px;padding-top:2px"><%-- Ajax --%></div>

    <%-- EDIT SELECTED SCREEN -------------------------------------------------------------------%>
    <table width="100%" id="screenTable" cellspacing="1" cellpadding="0" class="list" style="display:none">
        <%-- widthInCells --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","numberOfColumns",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select class="text" name="ScreenWidth" value="" onChange="drawScreen();">
                    <option value="-1"><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        for(int i=2; i<=5; i++){
                            %><option value="<%=i%>"><%=i%></option><%    
                        }                    
                    %>
                </select> 
            </td>
        </tr>
        
        <%-- heightInRows --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","numberOfRows",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select class="text" name="ScreenHeight" value="" onChange="drawScreen();">
                    <option value="-1"><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        for(int i=1; i<=20; i++){
                            %><option value="<%=i%>"><%=i%></option><%    
                        }                    
                    %>
                </select> 
            </td>
        </tr>
        
        <%-- labels for screen name (per supported language) --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","screenName",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" id="labelsDiv" style="padding:5px;vertical-align:top;">
                <%-- Ajax --%>
            </td>
        </tr>
                
        <%-- layout --%>
        <tr>
            <td class="admin" style="vertical-align:top;padding-top:3px;"><%=getTran(request,"web","layout",sWebLanguage)%></td>
            <td id="layoutDiv" style="padding:5px;vertical-align:top;">
                <%-- Ajax --%>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input type="button" name="saveButton" id="saveButton" class="button" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onClick="storeScreen();">&nbsp;
            <input type="button" name="deleteButton" id="deleteButton" class="button" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onClick="deleteScreen();" style="display:none">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    
    <div id="tranTypeDiv" style="width:100%;height:22px;color:#999;"><%-- Ajax --%></div>
    
    <%-- link to manageServiceExaminations --%>
    <div id="linkDiv" style="width:100%;height:22px;display:none;padding-top:10px">
	    <img src="<c:url value='/_img/themes/default/pijl.gif'/>">
	    <a href="<c:url value='/main.do'/>?Page=system/manageServiceExaminations.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran(request,"web.manage","manageServiceExaminations",sWebLanguage)%></a>&nbsp;
    </div>
</form>

<%=ScreenHelper.contextFooter(request)%>
    
<script>
  <%-- LIST SAVED SCREENS --%>
  function listSavedScreens(screenuid){
    document.getElementById("savedScreensDiv").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/>&nbsp;&nbsp;Loading..";
    var url = "<c:url value='/system/ajax/screenDesigner/listSavedScreens.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      onSuccess: function(resp){
        document.getElementById("savedScreensDiv").innerHTML = trim(resp.responseText);
        if(screenuid && screenuid.length>0){
        	var options = editForm.ScreenUID.options;
        	for(n=0;n<options.length;n++){
        		if(options[n].value==screenuid){
        			options[n].selected=true;
        			break;
        		}
        	}
        }
        editForm.ScreenUID.focus();
        fetchScreen();
      },
      onFailure: function(resp){
        alert(resp.responseText); ///
        document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function listSavedScreens()</font>";
      }
    });
  }
  
  <%-- FETCH SCREEN --%>
  function fetchScreen(){
    <%-- reset --%>
    document.getElementById("layoutDiv").innerHTML = "";
    document.getElementById("msgDiv").innerHTML = "";
    document.getElementById("linkDiv").style.innerHTML = "";
    
    if(editForm.ScreenUID.selectedIndex==0){   
      document.getElementById("screenTable").style.display = "none";
      document.getElementById("msgDiv").innerHTML = "";
      document.getElementById("tranTypeDiv").innerHTML = "";
      document.getElementById("linkDiv").style.display = "none";

      clearForm();
    }
    else{
      var screenUID = editForm.ScreenUID.value;

      var url = "<c:url value='/system/ajax/screenDesigner/fetchScreen.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,{
        method: "GET",
        parameters: "ScreenUID="+screenUID,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          
          editForm.saveButton.disabled = false;   
          if(editForm.deleteButton) editForm.deleteButton.disabled = false;
          
          editForm.ScreenWidth.value = data.width;
          editForm.ScreenHeight.value = data.height;
          editForm.ScreenExamId.value = data.examId;
          document.getElementById("labelsDiv").innerHTML = data.labelsHtml;
                    
          document.getElementById("screenTable").style.display = "table";
            
          if(data.transactionType.length > 0){
            document.getElementById("tranTypeDiv").innerHTML = "<i>transactionType: <b>"+data.transactionType+"</b><br/>[Screen "+screenUID+" saved on "+data.updateTime+"]</i>";
          }
          else{
            document.getElementById("tranTypeDiv").innerHTML = "";
          }
          document.getElementById("linkDiv").style.display = "block";

          if(screenUID!="new"){
            drawScreen(screenUID);
            editForm.ScreenWidth.focus();
            editForm.deleteButton.style.display = "inline";
          }
          else{
            editForm.deleteButton.style.display = "none";
            document.getElementById("layoutDiv").innerHTML = "<i><%=getTranNoLink("web.manage","layoutInstructions",sWebLanguage)%></i>";
             
            if(data.width > -1 && data.height > -1){
              drawScreen(screenUID);
              focusFirstEmptyLanguage();
            }
          }         
        },
        onFailure: function(resp){
          alert(resp.responseText); ///
          document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function fetchScreen()</font>";
        }
      });
    }
  }
//OK     
  <%-- OK TO SWITCH SCREENS --%>
  function okToSwitchScreens(){
    var okToSwitchScreens = true;
    
    if(document.getElementById("screenTable").style.display=="none"){
      // always ok to switch when no screen displayed
    }
    else{
      if(sFormInitialStatus.length>0 && sFormInitialStatus!=serializeForm(editForm)){
        okToSwitchScreens = yesnoDialogDirectText('<%=getTran(null,"web.occup","medwan.common.buttonquestion",sWebLanguage)%>');
      }
    }
    
    return okToSwitchScreens;
  }
  
  <%-- DRAW SCREEN --%>
  function drawScreen(screenUID){
    if(screenUID==null){
      screenUID = editForm.ScreenUID.value;
      editForm.performedAction.value = "resize";
    }
    
    var width  = editForm.ScreenWidth.options[editForm.ScreenWidth.selectedIndex].value,
        height = editForm.ScreenHeight.options[editForm.ScreenHeight.selectedIndex].value;
    
    if(width > 0 && height > 0){
      document.getElementById("layoutDiv").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/>&nbsp;&nbsp;Loading..";
      
      var url = "<c:url value='/system/ajax/screenDesigner/drawScreen.jsp'/>?ts="+new Date().getTime();
      new Ajax.Updater("layoutDiv",url,{
        evalScripts: true,
        method: "post",
        parameters: "ScreenUID="+screenUID+
                    "&Width="+width+
                    "&Height="+height+
                    "&CellsEditable="+(screenUID=="new"?"false":"true"),
        onComplete: function(resp){
          if(screenUID=="new"){
            document.getElementById("layoutDiv").innerHTML+= "<i><%=getTranNoLink("web.manage","tableInstructionsNew",sWebLanguage)%></i>";
          }
          else{
            document.getElementById("layoutDiv").innerHTML+= "<i><%=getTranNoLink("web.manage","tableInstructions",sWebLanguage)%></i>";
          }
          document.getElementById("msgDiv").innerHTML = "";
          document.getElementById("linkDiv").style.display = "block";

          registerFormState(editForm);
        },          
        onFailure: function(){
          document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function drawScreen()</font>";
        }
      });
    }
    else{
      document.getElementById("layoutDiv").innerHTML = "";
      document.getElementById("linkDiv").style.display = "none";
    }
  }

  <%-- STORE SCREEN --%>
  function storeScreen(){    
    if(editForm.ScreenWidth.selectedIndex > 0 &&
       editForm.ScreenHeight.selectedIndex > 0 &&
       areAllLabelsSpecified()){
      document.getElementById("msgDiv").innerHTML = "&nbsp;<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/>&nbsp;&nbsp;Saving..";
      editForm.saveButton.disabled = true; 
      if(editForm.deleteButton) editForm.deleteButton.disabled = true; 
        
      var url = "<c:url value='/system/ajax/screenDesigner/storeScreen.jsp'/>?ts="+new Date().getTime();
      var params = "Width="+editForm.ScreenWidth.value+
                   "&Height="+editForm.ScreenHeight.value+
                   "&Labels="+concatLabels();
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");      
          clearForm();  
          document.getElementById("msgDiv").innerHTML = data.msg;
          document.getElementById("tranTypeDiv").innerHTML = "";
          listSavedScreens(data.screenuid); <%-- to update name of screen when name changed --%>
        },
        onFailure: function(){
          alert(resp.responseText); ///
          document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function storeScreen()</font>";
        } 
      });
    }
    else{
      if(editForm.ScreenWidth.selectedIndex==0){
        alertDialog("web.manage","dataMissing");
        editForm.ScreenWidth.focus();
      }
      else if(editForm.ScreenHeight.selectedIndex==0){
    	editForm.ScreenHeight.focus();
        alertDialog("web.manage","dataMissing");
      }
      else{
        alertDialog("web.manage","specifyANameInEachLanguage");
        focusFirstEmptyLanguage();
      }
    }
  }
//OK  
  <%-- FOCUS FIRST EMPTY LANGUAGE --%>
  function focusFirstEmptyLanguage(){
    var labelInputs = document.getElementsByTagName("input");
    
    for(var i=0; i<labelInputs.length; i++){
      if(labelInputs[i].name && labelInputs[i].name.startsWith("ScreenLabel_")){
    	if(labelInputs[i].value.length==0){
          labelInputs[i].focus();    
          break;
    	}
      }
    }
  }
  
  <%-- CONCAT LABELS --%>
  function concatLabels(){
    var sLabels = "";
    
    var labelInputs = document.getElementsByTagName("input");
    for(var i=0; i<labelInputs.length; i++){
      if(labelInputs[i].name && labelInputs[i].name.startsWith("ScreenLabel_")){
    	sLabels+= labelInputs[i].name.split("_")[1]+"�"+labelInputs[i].value;
    	sLabels+= "$"; // end with dollar	  
      }
    }
    
    return sLabels;
  }
  
  <%-- ARE ALL LABELS SPECIFIED --%>
  function areAllLabelsSpecified(){
    var allLabelsSpecified = true;
    
    var labelInputs = document.getElementsByTagName("input");
    for(var i=0; i<labelInputs.length; i++){
      if(labelInputs[i].name && labelInputs[i].name.startsWith("ScreenLabel_")){
    	if(labelInputs[i].value.length==0){
    	  allLabelsSpecified = false;  
    	}	  
      }
    }
    
    return allLabelsSpecified;  
  }
  
  <%-- EDIT CELL --%>
  var rowIdx = 0;
  
  function editCell(cellID,screenID){  
    var url = "<c:url value='/system/ajax/screenDesigner/editCell.jsp'/>?ts="+new Date().getTime();
    
    var cellIdx = cellID.substring(cellID.lastIndexOf("_")+1);
    rowIdx = cellID.substring(cellID.indexOf("_")+1,cellID.lastIndexOf("_"));
    
    Modalbox.show(
      url,
      {
        title:"<%=getTranNoLink("web.manage","editCell",sWebLanguage)%> <font color='#cccccc'>(row "+(parseInt(rowIdx)+1)+" / cell "+(parseInt(cellIdx)+1)+")</font>",
        width:850,
        params:"&CellID="+cellID,
        afterHide:function(){if(screenID>-1)fetchScreen();}
      },
      {
        evalScripts:true
      }
    );
  }

  <%-- DELETE SCREEN --%>
  function deleteScreen(){
    if(yesnoDeleteDialog()){
      var url = "<c:url value='/system/ajax/screenDesigner/deleteScreen.jsp'/>?ts="+new Date().getTime();

      document.getElementById("msgDiv").innerHTML = "&nbsp;<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/>&nbsp;&nbsp;Deleting..";
      editForm.saveButton.disabled = true; 
      editForm.deleteButton.disabled = true; 
      
      new Ajax.Request(url,{
        method: "GET",
        parameters: "ScreenUID="+editForm.ScreenUID.value+
                    "&ExamId="+editForm.ScreenExamId.value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");  
          clearForm();   
          document.getElementById("msgDiv").innerHTML = data.msg;
          listSavedScreens(); <%-- to remove name of screen when screen deleted --%>    
        },
        onFailure: function(){
          alert(resp.responseText); ///
          document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function deleteScreen()</font>";
        } 
      }); 
    }
  }
  
  <%-- DELETE ROW --%>
  function deleteRow(rowId){
    editForm.performedAction.value = "deleteRow";
    var url = "<c:url value='/system/ajax/screenDesigner/deleteRow.jsp'/>?ts="+new Date().getTime();

    document.getElementById("msgDiv").innerHTML = "&nbsp;<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/>&nbsp;&nbsp;Deleting..";
    editForm.saveButton.disabled = true; 
    editForm.deleteButton.disabled = true; 
      
    new Ajax.Request(url,{
      method: "GET",
      parameters: "ScreenUID="+editForm.ScreenUID.value+
                  "&RowId="+rowId,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");

        editForm.saveButton.disabled = false;   
        if(editForm.deleteButton) editForm.deleteButton.disabled = false;
        
        if(editForm.ScreenHeight.selectedIndex > 0){
          editForm.ScreenHeight.selectedIndex = editForm.ScreenHeight.selectedIndex-1;
        }
        drawScreen(editForm.ScreenUID.value);
        
        editForm.deleteButton.style.display = "inline";        
        document.getElementById("msgDiv").innerHTML = data.msg;
      },
      onFailure: function(){
        alert(resp.responseText); ///
        document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function deleteRow()</font>";
      } 
    }); 
  }
//OK  
  <%-- MOVE ROW --%>
  function moveRow(directionAndStep,rowId){
    editForm.performedAction.value = "moveRow";

    document.getElementById("msgDiv").innerHTML = "&nbsp;<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/>&nbsp;&nbsp;Moving..";
    editForm.saveButton.disabled = true; 
    editForm.deleteButton.disabled = true; 

    var url = "<c:url value='/system/ajax/screenDesigner/moveRow.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "ScreenUID="+editForm.ScreenUID.value+
                  "&RowId="+rowId+
                  "&DirectionAndStep="+directionAndStep,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");

        editForm.saveButton.disabled = false; 
        if(editForm.deleteButton) editForm.deleteButton.disabled = false; 
        
        drawScreen(editForm.ScreenUID.value); 
        document.getElementById("msgDiv").innerHTML = data.msg; 
        
        editForm.deleteButton.style.display = "inline";    
      },
      onFailure: function(){
        alert(resp.responseText); ///
        document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function moveRow()</font>";
      } 
    }); 
  }

  <%-- CONCAT ITEMS --%>
  function concatItems(){
    var sItems = "";
    
    var row;
    for(var i=2; i<itemsTable.rows.length; i++){ // 2 : skip header and add-row
      row = itemsTable.rows[i];    
      
      sItems+= row.cells[1].innerHTML+"�"+
               row.cells[2].innerHTML+"�";
      
      if(row.cells.length > 2){
        sItems+= row.cells[3].innerHTML;
      }
      
      sItems+= "$"; // end with dollar
    }
    
    return sItems;
  }
  
  <%-- CLEAR FORM --%>
  function clearForm(){
    editForm.ScreenWidth.selectedIndex = 0;
    editForm.ScreenHeight.selectedIndex = 0;
        
    editForm.ScreenUID.selectedIndex = 0;
    editForm.ScreenUID.focus();

    document.getElementById("layoutDiv").innerHTML = "";
    document.getElementById("msgDiv").innerHTML = "";
    document.getElementById("screenTable").style.display = "none";
  }
      
  <%-- DO BACK --%>
  function doBack(){
    if(okToSwitchScreens()){
      window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
    }
  }
  
  <%-- ######################################################################################## --%>
  <%-- ####################################### EDITCELL-POPUP ################################# --%> 
  <%-- ########################################################################################--%>
  
  <%-- CLOSE EDIT SCREEN --%>
  function closeEditScreen(checkState){
	if(checkState==null) checkState = true;

    if(checkState==true){
      if(sFormInitialStatus!=serializeForm(cellForm)){
        if(yesnoDialogDirectText('<%=getTran(null,"web.occup","medwan.common.buttonquestion",sWebLanguage)%>')){
          if(Modalbox.initialized){
            Modalbox.hide();
          }
        }
      }
      else{
        if(Modalbox.initialized){
          Modalbox.hide();
        }
      }
    }
    else{
      if(Modalbox.initialized){
        Modalbox.hide();
      }
    }
  }
  
  <%-- ADD-ROW CONTAINS DATA --%>
  function addRowContainsData(){
    return (cellForm.addItemTypeId.value.length > 0 ||
            cellForm.addHtmlElement.selectedIndex > 0 ||
            cellForm.addSize.selectedIndex > 0 ||
            cellForm.addDefaultValue.value.length > 0);
  }
  
  <%-- SELECT CLASS --%>
  function selectClass(tdId,className){
    unselectClass();
		
	cellForm.EditClass.value = className;
	document.getElementById(tdId).style.border = "1px solid red";
  }
  
  <%-- UNSELECT CLASS --%>
  function unselectClass(){
	cellForm.EditClass.value = "";
	
	var classTDs = document.getElementsByTagName("td");
	for(var i=0; i<classTDs.length; i++){
	  if(classTDs[i].id && classTDs[i].id.startsWith("classSelector")){
	    classTDs[i].style.border = "1px solid #ccc";	  
	  }
	}
  }
//OK  
  <%-- STORE CELL --%>
  function storeCell(sCellID){
    var okToSave = true;
    
    <%-- ask to add un-added item before saving cell --%>
    if(addRowContainsData()){
      if(window.showModalDialog?yesnoDialog("web.manage","addEditedRecord"):yesnoDialogDirectText('<%=getTranNoLink("web.manage","addEditedRecord",sWebLanguage)%>')){
        okToSave = (addItem()==true);
      }
    }  
    
    if(okToSave==true){
      if(atLeastOneItemSpecified()){ 
        document.getElementById("ajaxLoader").style.visibility = "visible";
        
        cellForm.addButton.disabled = true;
        cellForm.saveButton.disabled = true;    
        cellForm.closeButton.disabled = true;    
        
        var url = "<c:url value='/system/ajax/screenDesigner/storeCell.jsp'/>?ts="+new Date().getTime();
        var params = "CellId="+sCellID+
                     "&Width="+cellForm.EditWidth.value+
                     "&Colspan="+cellForm.EditColspan.value+
                     "&Items="+concatItems()+
                     "&Class="+cellForm.EditClass.value+
                     "&TranTypeId="+cellForm.EditTranTypeId.value; // common for all items
        new Ajax.Request(url,{
          method: "POST",
          parameters: params,
          onSuccess: function(resp){ 
            var data = eval("("+resp.responseText+")");
            document.getElementById("msgDiv").innerHTML = data.msg;
            document.getElementById("ajaxLoader").style.visibility = "hidden";    
            closeEditScreen(false);
          },
          onFailure: function(){
            alert(resp.responseText); ///
            document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function storeCell()</font>";
          }
        });     
      }
      else{
        alertDialog("web.manage","specifiyAtLeastoneItem");
      }
    }
  }
//NOK  
  <%-- CONCAT ITEMS --%>
  function concatItems(){
    var sItems = "";
    
    var row;
    for(var i=2; i<itemsTable.rows.length; i++){ // 2 : skip header and add-row
      row = itemsTable.rows[i];    
      
      sItems+= row.cells[1].innerHTML+"^"+ // itemTypeId
		       row.cells[2].innerHTML+"^"+ // htmlElement-type
		       row.cells[3].innerHTML+"^"+ // size
		       encodeURIComponent(row.cells[4].innerHTML)+"^"+ // defaultValue
               (row.cells[5].innerHTML.indexOf("/check.gif")>-1?"true":"false")+"^"+ // required
               row.cells[6].innerHTML+"^"; // followedBy
      
      // add print-labels
      if(row.cells[7].text){
        sItems+= encodeURIComponent(row.cells[7].text);
      }
      sItems+= "$"; // end with dollar
    }
    return sItems;
  }
//NOK  
  <%-- CONCAT PRINT-LABELS --%>
  function concatPrintlabels(){
    var sPrintlabels = "";
    
	var inputFields = document.getElementsByTagName("input");
	for(var i=0; i<inputFields.length; i++){ 
  	  if(inputFields[i].name && inputFields[i].name.startsWith("printLabel_")){
  		var lang = inputFields[i].name.substring(inputFields[i].name.indexOf("_")+1);
  		sPrintlabels+= lang+"_"+inputFields[i].value+";";
  	  }
	}
        
    return sPrintlabels;
  }
  
  <%-- AT LEAST ONE ITEM SPECIFIED --%>
  function atLeastOneItemSpecified(){
    return (itemsTable.rows.length > 0);   
  }
    
  <%-- DELETE ITEM --%>
  function deleteItem(rowId){
    var row = document.getElementById(rowId);
    row.parentNode.removeChild(row);
  }
//NOK  
  <%-- EDIT ITEM --%>
  function editItem(rowId){
    var row = document.getElementById(rowId);

    setAddRowOptions(cellForm.addHtmlElement);
    
    cellForm.activeRowId.value = rowId;
    cellForm.addItemTypeId.value = row.cells[1].innerHTML;
    cellForm.addHtmlElement.value = row.cells[2].innerHTML;
    cellForm.addSize.value = row.cells[3].innerHTML;
    cellForm.addDefaultValue.value = row.cells[4].innerHTML;
    cellForm.addRequired.checked = (row.cells[5].innerHTML.indexOf("/check.gif")>-1);
    cellForm.addFollowedBy.value = row.cells[6].innerHTML;

    cellForm.UpdateButton.disabled = false;
    
    document.getElementById("printlabelsDiv").style.display = "table-row";
    fetchPrintlabelsForItem(cellForm.activeCellId.value,cellForm.addItemTypeId.value);
    Modalbox.resizeToContent();    
  }

  <%-- UPDATE ITEM --%>
  function updateItem(){
    if(cellForm.addItemTypeId.value.length > 0 && cellForm.addHtmlElement.selectedIndex > 0 && allOrNoPrintlabelsSpecified()){
      var rowId = cellForm.activeRowId.value;
      var row = document.getElementById(rowId);
        
      row.cells[0].innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' onclick=\"deleteItem('"+rowId+"');\" alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' class='link'/>&nbsp;"+
                               "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.png' onclick=\"editItem('"+rowId+"');\" alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' class='link' style='vertical-align:-3px'/>";
      row.cells[1].innerHTML = cellForm.addItemTypeId.value;
      row.cells[2].innerHTML = cellForm.addHtmlElement.options[cellForm.addHtmlElement.selectedIndex].value;
      row.cells[3].innerHTML = cellForm.addSize.value;
      row.cells[4].innerHTML = cellForm.addDefaultValue.value;
      row.cells[5].innerHTML = (cellForm.addRequired.checked?"<img src='<%=sCONTEXTPATH%>/_img/themes/default/check.gif' alt='true'>":"<img src='<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif' alt='false'>");
      row.cells[6].innerHTML = cellForm.addFollowedBy.options[cellForm.addFollowedBy.selectedIndex].value;
      row.cells[7].innerHTML = "";

      clearAddRow();
      cellForm.UpdateButton.disabled = true;
      
      // print-labels
      row.cells[7].text = concatPrintlabels();
      document.getElementById("printlabelsDiv").style.display = "none";
      clearPrintlabels();
    }
  }
//NOK  
  <%-- FETCH PRINT-LABELS FOR ITEM --%>
  function fetchPrintlabelsForItem(cellId,itemTypeId){
    var url = "<c:url value='/system/ajax/screenDesigner/fetchPrintLabelsForItem.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "ItemTypeId="+itemTypeId+
                  "&CellId="+cellId,
      onSuccess: function(resp){ 
        var data = eval("("+resp.responseText+")");

    	var inputFields = document.getElementsByTagName("input");
    	for(var i=0; i<inputFields.length; i++){
    	  if(inputFields[i].name && inputFields[i].name.startsWith("printLabel_")){
    		var lang = inputFields[i].name.substring(inputFields[i].name.lastIndexOf("_")+1);
    		if((""+eval("data."+lang)).length > 0 && (""+eval("data."+lang))!="undefined"){
              document.getElementById("printLabel_"+lang).value = eval("data."+lang);
    		}
    	  }
    	}
      },
      onFailure: function(){
        alert(resp.responseText); ///
        document.getElementById("msgDiv").innerHTML = "<font color='red'>Error in function fetchPrintlabelsForItem()</font>";
      }
    }); 
  }
  
  <%-- CLEAR PRINT-LABELS --%>
  function clearPrintlabels(){
	var inputFields = document.getElementsByTagName("input");
	
	for(var i=0; i<inputFields.length; i++){
	  if(inputFields[i].name && inputFields[i].name.startsWith("printLabel_")){
		inputFields[i].value = "";
	  }
	}
  }
  
  <%-- ALL OR NO PRINT-LABELS SPECIFIED --%>
  function allOrNoPrintlabelsSpecified(){
	var labelsOK = false;
	
	var labelLengths = new Array();
	var inputFields = document.getElementsByTagName("input");
	var labelIdx = 0, labelFieldCount = 0;
	
	for(var i=0; i<inputFields.length; i++){
	  if(inputFields[i].name && inputFields[i].name.startsWith("printLabel_")){
		labelFieldCount++;
		if(inputFields[i].value.length > 0){
		  labelLengths[labelIdx++] = inputFields[i].value.length;
		}
	  }
	}

	var sum = 0;
	for(var i=0; i<labelLengths.length; i++){
	  sum+= labelLengths[i];
	}
	
	labelsOK = (sum==0 || labelLengths.length==labelFieldCount);
	
	if(labelsOK==false){
	  alertDialog("web.manage","specifyAllOrNoPrintlabels");	
	}
	
	return labelsOK;
  }  
  
  <%-- ADD ITEM --%>  
  function addItem(){ 
    if(cellForm.addItemTypeId.value.length > 0 && cellForm.addHtmlElement.selectedIndex > 0){
      if(isItemAlreadySelected(cellForm.addItemTypeId.value)==false){
        row = itemsTable.insertRow();

        <%-- alternate row-style --%>
        if(rowIdx%2==0) row.className = "list1";
        else            row.className = "list";
        
        row.insertCell();
        row.insertCell();
        row.insertCell();
        row.insertCell();
        row.insertCell();
        row.insertCell();
        row.insertCell();
        row.insertCell();
            
        row.id = "row_"+rowIdx; 
        row.cells[0].innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' onclick=\"deleteItem('row_"+rowIdx+"');\" alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' class='link'></a>&nbsp;"+
                                 "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.png' onclick=\"editItem('row_"+rowIdx+"');\" alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' class='link' style='vertical-align:-3px'></a>";
        row.cells[1].innerHTML = cellForm.addItemTypeId.value;
        row.cells[2].innerHTML = cellForm.addHtmlElement.options[cellForm.addHtmlElement.selectedIndex].value;
        row.cells[3].innerHTML = cellForm.addSize.value;
        row.cells[4].innerHTML = cellForm.addDefaultValue.value; 
        row.cells[5].innerHTML = (cellForm.addRequired.checked?"<img src='<%=sCONTEXTPATH%>/_img/themes/default/check.gif' alt='true'>":"<img src='<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif' alt='false'>");
        row.cells[6].innerHTML = cellForm.addFollowedBy.options[cellForm.addFollowedBy.selectedIndex].value;
        row.cells[7].innerHTML = ""; 
    
        rowIdx++;
        clearAddRow();
        Modalbox.resizeToContent();
        return true;
      }
      else{
        cellForm.addItemTypeId.focus();
        alertDialog("web.manage","itemAlreadyExists");
        return false;
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
      
           if(cellForm.addItemTypeId.value.length==0) cellForm.addItemTypeId.focus();
      else if(cellForm.addHtmlElement.selectedIndex==0) cellForm.addHtmlElement.focus();
      return false;
    }

    return false;
  }
  
  <%-- IS ITEM ALREADY SELECTED --%>
  function isItemAlreadySelected(itemId){
    var row;
    
    for(var i=2; i<itemsTable.rows.length; i++){ // 2 : skip header and add-row
      row = itemsTable.rows[i];    
      if(row.cells[1].innerHTML==itemId){
        return true;
      }
    }
    
    return false;
  }
  
  <%-- CLEAR ADD-ROW --%>
  function clearAddRow(){  
    cellForm.addItemTypeId.value = "";
    cellForm.addHtmlElement.selectedIndex = 0;
    cellForm.addSize.value = "";
    cellForm.addDefaultValue.value = "";
    cellForm.addRequired.checked = false;
    cellForm.addFollowedBy.selectedIndex = 0;

    cellForm.addSize.disabled = false;
    cellForm.addSize.style.background = "#ffffff";
    cellForm.addDefaultValue.disabled = false;
    cellForm.addDefaultValue.style.background = "#ffffff";
    cellForm.addRequired.disabled = false; 
    
    cellForm.addItemTypeId.focus();
  }
  
  <%-- SET ADD-ROW OPTIONS --%>
  function setAddRowOptions(elementTypeSelect){
	var elementType = elementTypeSelect.options[elementTypeSelect.selectedIndex].value;

    if(elementType==""){
      cellForm.addSize.disabled = false;
      cellForm.addSize.style.background = "#ffffff";
    
      cellForm.addDefaultValue.disabled = false;
      cellForm.addDefaultValue.style.background = "#ffffff";
    
      cellForm.addRequired.disabled = false;
      cellForm.addRequired.checked = false;
    }
    else if(elementType=="label"){
      cellForm.addSize.value = "";
      cellForm.addSize.disabled = true;
      cellForm.addSize.style.background = "#cccccc";

      cellForm.addRequired.value = "";
      cellForm.addRequired.disabled = true;
      cellForm.addRequired.checked = false;
    }
    else if(elementType=="text"){
      cellForm.addSize.disabled = false;
      cellForm.addSize.style.background = "#ffffff";
      
      cellForm.addDefaultValue.disabled = false;
      cellForm.addDefaultValue.style.background = "#ffffff";
      
      cellForm.addRequired.disabled = false;
      cellForm.addRequired.checked = false;
    }
    else if(elementType=="date"){
      cellForm.addSize.value = "";
      cellForm.addSize.disabled = true;
      cellForm.addSize.style.background = "#cccccc";
    }
    else if(elementType=="integer"){
      cellForm.addSize.disabled = false;
      cellForm.addSize.style.background = "#ffffff";
        
      cellForm.addDefaultValue.disabled = false;
      cellForm.addDefaultValue.style.background = "#ffffff";
        
      cellForm.addRequired.disabled = false;
      cellForm.addRequired.checked = false;
    }
    else if(elementType=="select"){
      cellForm.addSize.value = "";
      cellForm.addSize.disabled = true;
      cellForm.addSize.style.background = "#cccccc";
    }
    else if(elementType=="textArea"){
      cellForm.addSize.disabled = true;
      cellForm.addSize.style.background = "#ffffff";
        
      cellForm.addDefaultValue.disabled = false;
      cellForm.addDefaultValue.style.background = "#ffffff";
        
      cellForm.addRequired.disabled = false;
      cellForm.addRequired.checked = false;
    } 
    else if(elementType=="radio"){
      cellForm.addSize.value = "";
      cellForm.addSize.disabled = true;
      cellForm.addSize.style.background = "#cccccc";
    } 
    else if(elementType=="checkBox"){
      cellForm.addSize.value = "";
      cellForm.addSize.disabled = true;
      cellForm.addSize.style.background = "#cccccc";

      cellForm.addRequired.value = "";
      cellForm.addRequired.disabled = true;
      cellForm.addRequired.checked = false;
    } 
  } 
  
  <%-- REGISTER FORM STATE --%>
  var sFormInitialStatus = "";
  
  function registerFormState(form){
	sFormInitialStatus = serializeForm(form);
	editForm.performedAction.value = "";
  }
  
  <%-- SERIALIZE FORM --%>
  function serializeForm(form){
	var formValues = "";

	var elems = form.getElementsByTagName("input");
	for(var i=0; i<elems.length; i++){
	  if(elems[i].type=="radio" || elems[i].type=="checkbox"){
	    if(elems[i].checked){
	      formValues+= elems[i].value;
	    }
	  }
	  else{
	    if(elems[i].type!="button" && elems[i].type!="hidden"){
	      formValues+= elems[i].value;
	    }
	  }
	}

	elems = form.getElementsByTagName("select");
	for(var i=0; i<elems.length; i++){
	  if(elems[i].name!="ScreenUID"){
	    formValues+= elems[i].value;
	  }
	}

	elems = form.getElementsByTagName("textarea");
	for(var i=0; i<elems.length; i++){
	  formValues+= elems[i].innerHTML;
	}
	
	var rowsHtml = document.getElementById("layoutDiv").innerHTML; 
	formValues+= rowsHtml.length;
		
	return formValues.replace(/\s+/,"");
  }
  
  <%-- ####################################################################################### --%>
  <%-- ################### functions used by configured htmlElements (items) ################# --%>
  <%-- ####################################################################################### --%>
  
  <%-- CHECK INTEGER FIELD --%>
  function checkIntegerField(integerField){
    if(integerField.value.length>0 && !isNumber(integerField)){
      alertDialog("web","notNumeric");
      integerField.value = "";
      integerField.focus();
    }
  }
  listSavedScreens();

</script>

<%=writeJSButtons("editForm","saveButton")%>