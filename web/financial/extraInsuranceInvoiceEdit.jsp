<%@page import="be.openclinic.finance.*,
                java.util.Date,
                java.text.DecimalFormat"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"financial.insuranceinvoice","edit",activeUser)%>
<%=sJSPROTOTYPE%>
<%=sJSNUMBER%>

<%
    String sFindInsurarInvoiceUID = checkString(request.getParameter("FindInsurarInvoiceUID"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n**************** financial/extraInsuranceInvoiceEdit.jsp **************");
    	Debug.println("sFindInsurarInvoiceUID : "+sFindInsurarInvoiceUID+"\n");
    }    
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ExtraInsurarInvoice insurarInvoice;
    String sInsurarText = "";
    
    if(sFindInsurarInvoiceUID.length() > 0){
        insurarInvoice = ExtraInsurarInvoice.getViaInvoiceUID(sFindInsurarInvoiceUID);
        Insurar insurar = Insurar.get(checkString(insurarInvoice.getInsurarUid()));
        if(insurar!=null){
            sInsurarText = checkString(insurar.getName());
        }
    }
    else{
        insurarInvoice = new ExtraInsurarInvoice();
    }
%>
<form name="FindForm" id="FindForm" method='POST'>
    <%=writeTableHeader("web","extrainsuranceInvoiceEdit",sWebLanguage,"")%>
    
    <table class="menu" width="100%" cellpadding="0" cellspacing="1">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web.finance","invoiceid",sWebLanguage)%></td>
            <td class="admin2">
                <%-- INVOICE NUMBER --%>
                <input type="text" class="text" name="FindInsurarInvoiceUID" id="FindInsurarInvoiceUID" onblur="isNumber(this)" value="<%=sFindInsurarInvoiceUID%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurarInvoice();">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="doClear();">

                <%-- BUTTONS --%>
                <input type="button" class="button" name="ButtonFind" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="doFind()">
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="doNew();searchInsurar();">
            </td>
        </tr>
    </table>
</form>

<script>
  FindForm.FindInsurarInvoiceUID.focus();

  function searchInsurarInvoice(){
    openPopup("/_common/search/searchExtraInsurarInvoice.jsp&ts=<%=getTs()%>&doFunction=doFind()"+
    		  "&ReturnFieldInvoiceNr=FindInsurarInvoiceUID&FindInvoiceInsurar=<%=sFindInsurarInvoiceUID%>");
  }

  function doFind(){
    if(FindForm.FindInsurarInvoiceUID.value.length > 0){
      FindForm.submit();
    }
  }

  function doNew(){
    FindForm.FindInsurarInvoiceUID.value = "";
    FindForm.submit();
  }

  function doClear(){
	FindForm.FindInsurarInvoiceUID.value = "";
    FindForm.FindInsurarInvoiceUID.focus();
  }
</script>

<div id="divOpenInsurarInvoices" style="height:120px;width:100%" class="searchResults"></div>

<form name='EditForm' id="EditForm" method='POST'>
<table class='list' width='100%' cellspacing='1' cellpadding="0">
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"medical.accident","insurancecompany",sWebLanguage)%></td>
        <td class="admin2">
            <input type="hidden" name="EditNumber" value="<%=checkString(insurarInvoice.getNumber())%>">
            <input type="hidden" name="EditInsurarUID" value="<%=checkString(insurarInvoice.getInsurarUid())%>">
            <input type="text" class="text" readonly name="EditInsurarText" value="<%=sInsurarText%>" size="100">
            
            <%
                if(checkString(insurarInvoice.getUid()).length()==0){
		            %>
		            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
		            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
		            <%
                }
            %>
        </td>
    </tr>
    
    <tbody id="invoicedetails" style="visibility:hidden">
        <tr>
            <td class="admin"><%=getTran(request,"web.finance","invoiceid",sWebLanguage)%></td>
            <td class="admin2"><input type="text" class="text" readonly name="EditInvoiceUID" id="EditInvoiceUID" value="<%=checkString(insurarInvoice.getInvoiceUid())%>">
				<%
	            	if(checkString(insurarInvoice.getNumber()).length()>0 && !insurarInvoice.getInvoiceUid().equalsIgnoreCase(insurarInvoice.getInvoiceNumber())){
	            		out.print("("+insurarInvoice.getInvoiceNumber()+")");
	            	}
				%>
			</td>
        </tr>
        
        <%-- DATE --%>
        <tr>
            <td class='admin'><%=getTran(request,"Web","date",sWebLanguage)%> *</td>
            <%
                Date activeDate = insurarInvoice.getDate();
                if(activeDate==null){
                    activeDate = new Date();
                }
            %>
            <td class='admin2'><%=writeDateField("EditDate","EditForm",ScreenHelper.getSQLDate(activeDate),sWebLanguage)%></td>
        </tr>
        
        <%-- STATUS --%>
        <tr>
            <td class='admin'><%=getTran(request,"Web.finance","patientinvoice.status",sWebLanguage)%> *</td>
            <td class='admin2'>
                <select class="text" id="EditStatus" name="EditStatus" <%=insurarInvoice.getStatus()!=null && (insurarInvoice.getStatus().equalsIgnoreCase("closed") || insurarInvoice.getStatus().equalsIgnoreCase("canceled"))?"disabled":""%>>
                    <option/>
                    <%
                        String activeStatus = checkString(insurarInvoice.getStatus());
                        if(activeStatus.length()==0){
                            activeStatus = "open";
                        }
                    %>
                    <%=ScreenHelper.writeSelect(request,"finance.patientinvoice.status",activeStatus,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- PERIOD --%>
        <tr id="period" style="visibility:hidden">
            <td class='admin'><%=getTran(request,"web","period",sWebLanguage)%></td>
            <td class="admin2">
                <% Date previousmonth = new Date(new Date().getTime()-30*24*3600*1000l); %>
                <%=writeDateField("EditBegin","EditForm",new SimpleDateFormat("01/MM/yyyy").format(previousmonth),sWebLanguage)%>
                <%=getTran(request,"web","to",sWebLanguage)%>
                <%=writeDateField("EditEnd","EditForm",ScreenHelper.stdDateFormat.format(ScreenHelper.parseDate(new SimpleDateFormat("01/MM/yyyy").format(new Date())).getTime()-1),sWebLanguage)%>
                <input type="hidden" name="EditInvoiceService" id="EditInvoiceService" value="">
                <%
                    if(insurarInvoice==null || insurarInvoice.getStatus()==null || insurarInvoice.getStatus().equalsIgnoreCase("open")){
	                    %>
		                    <input class="text" type="text" name="EditInvoiceServiceName" id="EditInvoiceServiceName" readonly size="<%=sTextWidth%>" value="">
		                   
		                    <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('EditInvoiceService','EditInvoiceServiceName');">
		                    <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditInvoiceService').value='';document.getElementById('EditInvoiceServiceName').value='';">
	                    <%
                    }
                %>                        
                &nbsp;<input type="button" class="button" name="update" value="<%=getTranNoLink("web","update",sWebLanguage)%>" onclick="changeInsurar();"/>
            </td>
        </tr>
        
        <%-- BALANCE --%>
        <tr>
            <td class='admin'><%=getTran(request,"web.finance","balance",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' readonly type='text' id='EditBalance' name='EditBalance' value='<%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00")).format(insurarInvoice.getBalance())%>' size='20'> <%=MedwanQuery.getInstance().getConfigParam("currency","�")%>
            </td>
        </tr>
        
        <%-- DEBETS/PRESTATIONS --%>
        <tr>
            <td class='admin'><%=getTran(request,"web.finance","prestations",sWebLanguage)%></td>
            <td class='admin2'>
                <div id="divPrestations" style="height:120px;width:100%" class="searchResults"></div>
               
                <div style="padding-top:3px;">
                    <input class='button' type="button" name="ButtonDebetSelectAll" id="ButtonDebetSelectAll" value="<%=getTranNoLink("web","selectall",sWebLanguage)%>" onclick="selectAll('cbDebet',true,'ButtonDebetSelectAll','ButtonDebetDeselectAll',true);">&nbsp;
                    <input class='button' type="button" name="ButtonDebetDeselectAll" id="ButtonDebetDeselectAll" value="<%=getTranNoLink("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbDebet',false,'ButtonDebetDeselectAll','ButtonDebetSelectAll',true);">
                </div>
            </td>
        </tr>
        
        <%-- CREDITS/PAYMENTS --%>
        <tr>
            <td class='admin'><%=getTran(request,"web.finance","credits",sWebLanguage)%></td>
            <td class='admin2'>
                <div id="divCredits" style="height:120px;width:100%" class="searchResults"></div>
              
                <div style="padding-top:3px;">
                    <input class='button' type="button" name="ButtonInsurarInvoiceSelectAll" id="ButtonInsurarInvoiceSelectAll" value="<%=getTranNoLink("web","selectall",sWebLanguage)%>" onclick="selectAll('cbInsurarInvoice',true,'ButtonInsurarInvoiceSelectAll','ButtonInsurarInvoiceDeselectAll',false);">&nbsp;
                    <input class='button' type="button" name="ButtonInsurarInvoiceDeselectAll" id="ButtonInsurarInvoiceDeselectAll" value="<%=getTranNoLink("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbInsurarInvoice',false,'ButtonInsurarInvoiceDeselectAll','ButtonInsurarInvoiceSelectAll',false);">
                </div>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%
                    if(!(checkString(insurarInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(insurarInvoice.getStatus()).equalsIgnoreCase("canceled"))){
                        %><input class='button' type="button" name="ButtonSave" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave(this);">&nbsp;<%
                    }

                    // pdf print button for existing invoices
                    if(checkString(insurarInvoice.getUid()).length() > 0){
                        %><%=getTran(request,"Web.Occup","PrintLanguage",sWebLanguage)%><%
                        		
                     String sPrintLanguage = activeUser.person.language;
                     if(sPrintLanguage.length()==0){
                         sPrintLanguage = sWebLanguage;
                     }
                         
                     %>
                        <select class="text" name="PrintLanguage">
                            <%
	                            String tmpLang;
		                        String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
	                            StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages,",");
	                            while(tokenizer.hasMoreTokens()){
	                                tmpLang = tokenizer.nextToken();
	
	                                %><option value="<%=tmpLang%>" <%=(tmpLang.equalsIgnoreCase(sPrintLanguage)?"selected":"")%>><%=getTranNoLink("Web.language",tmpLang,sWebLanguage)%></option><%
	                            }
                            %>
                		</select>
                		
		                <select class="text" name="PrintType">
		                    <option value="sortbydate" <%=MedwanQuery.getInstance().getConfigString("defaultInvoiceSortType","sortbydate").equalsIgnoreCase("sortbydate")?"selected":""%>><%=getTranNoLink("web","sortbydate",sWebLanguage)%></option>
		                    <option value="sortbypatient" <%=MedwanQuery.getInstance().getConfigString("defaultInvoiceSortType","sortbydate").equalsIgnoreCase("sortbypatient")?"selected":""%>><%=getTranNoLink("web","sortbypatient",sWebLanguage)%></option>
		                </select>		                        
                    <%
                        
                 	String defaultmodel = MedwanQuery.getInstance().getConfigString("defaultExtraInvoiceModel","default");
                 	if(insurarInvoice.getInsurar()!=null && insurarInvoice.getInsurar().getDefaultInsurarInvoiceModel()!=null){
                 		defaultmodel = insurarInvoice.getInsurar().getDefaultInsurarInvoiceModel();
                    }
                 %>
                 <select class="text" name="PrintModel">
                     <option value="default" <%=defaultmodel.equalsIgnoreCase("default")?"selected":""%>><%=getTranNoLink("web","defaultmodel",sWebLanguage)%></option>
                     <%	
                         if(MedwanQuery.getInstance().getConfigInt("enableRwanda",1)==1){ 
	                         %>	
	                         <option value="ramanew" <%=defaultmodel.equalsIgnoreCase("ramanew")?"selected":""%>><%=getTranNoLink("web","ramanewmodel",sWebLanguage)%></option>
	                         <option value="ramacsv" <%=defaultmodel.equalsIgnoreCase("ramacsv")?"selected":""%>><%=getTranNoLink("web","ramacsvmodel",sWebLanguage)%></option>
	                         <option value="ctams" <%=defaultmodel.equalsIgnoreCase("ctams")?"selected":""%>><%=getTranNoLink("web","ctamsmodel",sWebLanguage)%></option>
	                         <%	
                  	     }
                     
                 	    if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){
                            %>
                            	<option value="mfp" <%=defaultmodel.equalsIgnoreCase("mfp")?"selected":""%>><%=getTranNoLink("web","mfpmodel",sWebLanguage)%></option>
  	                            <option value="msplscsv" <%=defaultmodel.equalsIgnoreCase("msplscsv")?"selected":""%>><%=getTranNoLink("web","msplscsvmodel",sWebLanguage)%></option>
							<%
          		        }
                 	    
               	        if(MedwanQuery.getInstance().getConfigInt("enableBurundi",0)==1){
                            %>
                            <option value="hmk" <%=defaultmodel.equalsIgnoreCase("hmk")?"selected":""%>><%=getTranNoLink("web","hmkmodel",sWebLanguage)%></option>
                            <option value="cplrcsv2" <%=defaultmodel.equalsIgnoreCase("cplrcsv")?"selected":""%>><%=getTranNoLink("web","cplrcsvmodel",sWebLanguage)%></option>
                            <%
               	        }
		              	if(MedwanQuery.getInstance().getConfigInt("enableCCBRT",0)==1){
		                    %>
		                    	<option value="ccbrtacsv" <%=defaultmodel.equalsIgnoreCase("ccbrtacsv")?"selected":""%>><%=getTranNoLink("web","ccbrtacsvmodel",sWebLanguage)%></option>
		                    	<option value="ccbrtbcsv" <%=defaultmodel.equalsIgnoreCase("ccbrtbcsv")?"selected":""%>><%=getTranNoLink("web","ccbrtbcsvmodel",sWebLanguage)%></option>
		                    <%
		           		}
                    %>
                </select>
                    <%
                        if(insurarInvoice.getStatus().equalsIgnoreCase("closed")){
                            %><input class="button" type="button" name="ButtonPrint" value='<%=getTranNoLink("Web","printinvoice",sWebLanguage)%>' onclick="doPrintPdf('<%=insurarInvoice.getUid()%>');"><%
                        }
                        else{
                            %><input class="button" type="button" name="ButtonPrint" value='<%=getTranNoLink("Web","printprestationlist",sWebLanguage)%>' onclick="doPrintPdf('<%=insurarInvoice.getUid()%>');"><%
                        }
                    }
                %>
            </td>
        </tr>
    </tbody>
</table>
<%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>

<div id="divMessage"></div>

<input type='hidden' name='EditInsurarInvoiceUID' id='EditInsurarInvoiceUID' value='<%=checkString(insurarInvoice.getUid())%>'>
</form>

<script>
<%-- DO SAVE --%>
function doSave(){
  if((EditForm.EditDate.value.length > 0) && (EditForm.EditStatus.selectedIndex > -1 && EditForm.EditInsurarUID.value.length>0)){
    var sCbs = "";
    for(i=0; i<EditForm.elements.length; i++){
      elm = EditForm.elements[i];
      if(elm.type=='checkbox' && elm.checked){
        sCbs+= elm.name.split("=")[0].replace("cbDebet","d").replace("cbInsurarInvoice","c")+",";
      }
    }

    EditForm.ButtonSave.disabled = true;
    var url = '<c:url value="/financial/extraInsuranceInvoiceSave.jsp"/>?ts='+new Date();
    document.getElementById('divMessage').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Saving";
    new Ajax.Request(url,{
      method: "POST",
      postBody: 'EditDate='+EditForm.EditDate.value
               +'&EditInsurarInvoiceUID='+EditForm.EditInsurarInvoiceUID.value
               +'&EditInvoiceUID='+EditForm.EditInvoiceUID.value
               +'&EditInsurarUID='+EditForm.EditInsurarUID.value
               +'&EditNumber='+EditForm.EditNumber.value
               +'&EditStatus='+EditForm.EditStatus.value
               +'&EditCBs='+sCbs
               +'&EditBalance='+EditForm.EditBalance.value,
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        $('divMessage').innerHTML = label.Message;
        $('EditInsurarInvoiceUID').value = label.EditInsurarInvoiceUID;
        $('EditInvoiceUID').value = label.EditInvoiceUID;
        $('FindInsurarInvoiceUID').value = label.EditInvoiceUID;
        EditForm.ButtonSave.disabled = false;
        window.setTimeout("loadOpenInsurarInvoices()",200);
        window.setTimeout("doFind()",200);
      },
      onFailure: function(){
        $('divMessage').innerHTML = "Error in function manageTranslationsStore() => AJAX";
      }
    });
  }
  else{
              window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran(null,"web.manage","dataMissing",sWebLanguage)%>');
  }
}

<%-- COUNT DEBETS --%>
function countDebets(){
  var tot = 0;
  for(i=0; i<EditForm.elements.length; i++){
    var elm = EditForm.elements[i];
    if(elm.name.indexOf('cbDebet') > -1){
      if(elm.checked){
        var amount = elm.name.split("=")[1];
        tot = tot+parseFloat(amount.replace(",","."));
      }
    }
  }
  return tot;
}

<%-- COUNT CREDITS --%>
function countCredits(){
  var tot = 0;
  for(i=0; i<EditForm.elements.length; i++){
    var elm = EditForm.elements[i];
    if(elm.name.indexOf('cbInsurarInvoice') > -1){
      if(elm.checked){
        var amount = elm.name.split("=")[1];
        tot = tot+parseFloat(amount.replace(",","."));
      }
    }
  }
  return tot;
}

<%-- UPDATE BALANCE --%>
function updateBalance(){
  EditForm.EditBalance.value = countDebets()+countCredits();
  EditForm.EditBalance.value = format_number(EditForm.EditBalance.value,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
}

<%-- SELECT ALL --%>
function selectAll(sStartsWith,bValue,buttonDisable,buttonEnable,bAdd){
  var tot = 0;
  for(i=0; i<EditForm.elements.length; i++){
    var elm = EditForm.elements[i];

    if(elm.name.indexOf(sStartsWith) > -1){
      if(elm.type=='checkbox' && elm.checked!=bValue){
        elm.checked = bValue;
      }
    }
  }
  updateBalance();
}

<%-- DO BALANCE --%>
function doBalance(oObject,bAdd){
  var amount = oObject.name.split("=")[1];

  if(bAdd){
    if(oObject.checked){
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",","."))+parseFloat(amount.replace(",","."));
    }
    else{
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) - parseFloat(amount.replace(",","."));
    }
  }
  else{
    if(oObject.checked){
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) - parseFloat(amount.replace(",","."));
    }
    else{
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",","."))+parseFloat(amount.replace(",","."));
    }
  }
  EditForm.EditBalance.value = format_number(EditForm.EditBalance.value,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
}

<%-- PRINT PDF --%>
function doPrintPdf(invoiceUid){
	  if(EditForm.PrintModel.value=='cplrcsv2'){
			var url = "<c:url value='/util/csvDocs.jsp'/>?invoiceuid="+invoiceUid+"&ts=<%=getTs()%>&docid=invoice.cplr2";
			window.open(url, "ExtraInsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
		  }
	  else if(EditForm.PrintModel.value=='ramacsv'){
			var url = "<c:url value='/util/csvDocs.jsp'/>?invoiceuid="+invoiceUid+"&ts=<%=getTs()%>&docid=invoice.rama.extra";
			window.open(url, "ExtraInsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
		  }
    else if(EditForm.PrintModel.value=='msplscsv'){
		var url = "<c:url value='/util/csvDocs.jsp'/>?invoiceuid=" + invoiceUid + "&ts=<%=getTs()%>&docid=invoice.mspls.extra";
	    window.open(url, "InsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
    }
    else if(EditForm.PrintModel.value=='ccbrtacsv'){
		var url = "<c:url value='/util/csvDocs.jsp'/>?invoiceuid=" + invoiceUid + "&ts=<%=getTs()%>&docid=invoice.ccbrta.extra";
	    window.open(url, "InsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
    }
    else if(EditForm.PrintModel.value=='ccbrtbcsv'){
		var url = "<c:url value='/util/csvDocs.jsp'/>?invoiceuid=" + invoiceUid + "&ts=<%=getTs()%>&docid=invoice.ccbrtb.extra";
	    window.open(url, "InsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
    }
	  else{
		var url = "<c:url value='/financial/createExtraInsurarInvoicePdf.jsp'/>?InvoiceUid="+invoiceUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value+ "&PrintType="+EditForm.PrintType.value+"&PrintModel="+EditForm.PrintModel.value;
	   	window.open(url, "InsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	  }
}

function searchInsurar(){
  openPopup("/_common/search/searchInsurar.jsp&ts="+new Date()+"&ReturnFieldInsurarUid=EditInsurarUID"+
		    "&ReturnFieldInsurarName=EditInsurarText&doFunction=changeInsurar()&excludePatientSelfIsurarUID=true"+
		    "&PopupHeight=500&PopupWith=500");
}

function doClearInsurar(){
  EditForm.EditInsurarUID.value = "";
  EditForm.EditInsurarText.value = "";
}

function loadOpenInsurarInvoices(){
  var url = '<c:url value="/financial/extraInsurarInvoiceGetOpenInsurarInvoices.jsp"/>?ts='+new Date();
  new Ajax.Request(url,{
    method: "GET",
    parameters: "",
    onSuccess: function(resp){
      $('divOpenInsurarInvoices').innerHTML = resp.responseText;
    }
  });
}

function setInsurarInvoice(sUid){
  FindForm.FindInsurarInvoiceUID.value = sUid;
  FindForm.submit();
}

<%-- CHANGE INSURAR --%>
function changeInsurar(){
  var tot = 0;
  if(EditForm.EditInsurarUID.value.length>0){
    document.getElementById("invoicedetails").style.visibility = "visible";
  }
  else{
    document.getElementById("invoicedetails").style.visibility = "hidden";
  }
  
  var url = '<c:url value="/financial/extraInsurarInvoiceGetPrestations.jsp"/>?ts='+new Date();
  document.getElementById('divPrestations').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading..";
  var pb = 'InsurarUid='+EditForm.EditInsurarUID.value+
           '&EditBegin='+EditForm.EditBegin.value+
           '&EditEnd='+EditForm.EditEnd.value+
           '&EditInvoiceService='+EditForm.EditInvoiceService.value+
           '&EditInsurarInvoiceUID=<%=checkString(insurarInvoice.getUid())%>';

  new Ajax.Request(url,{
    method: "POST",
    postBody: pb,
    onSuccess: function(resp){
      var s = resp.responseText;
      s=s.replace(/<1>/g,"<input type='checkbox' name='cbDebet");
      s=s.replace(/<2>/g,"' onclick='doBalance(this,true)' ");
      $('divPrestations').innerHTML = s;
      tot = tot+countDebets();
      document.getElementById('EditBalance').value = tot;
    }
  });

  var url = '<c:url value="/financial/extraInsurarInvoiceGetCredits.jsp"/>?ts='+new Date();
  document.getElementById('divCredits').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading..";
  new Ajax.Request(url,{
    method: "POST",
    postBody: 'InsurarUid='+EditForm.EditInsurarUID.value+
              '&EditInsurarInvoiceUID=<%=checkString(insurarInvoice.getUid())%>',
    onSuccess: function(resp){
      $('divCredits').innerHTML = resp.responseText;
      tot=tot-countCredits();
      document.getElementById('EditBalance').value = tot;
    }
  });
  
  if(document.getElementById("invoicedetails").style.visibility=="visible" && !(EditForm.EditInsurarUID.value.length>0 && (document.getElementById("EditStatus").value=='closed' || document.getElementById("EditStatus").value=='canceled'))){
    document.getElementById('period').style.visibility='visible';
  }
  else{
    document.getElementById('period').style.visibility='hidden';
  }
}

<%-- SEARCH SERVICE --%>
function searchService(serviceUidField,serviceNameField){
  openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  document.getElementById(serviceNameField).focus();
}

FindForm.FindInsurarInvoiceUID.focus();
loadOpenInsurarInvoices();
window.setTimeout("changeInsurar()",200);
</script>