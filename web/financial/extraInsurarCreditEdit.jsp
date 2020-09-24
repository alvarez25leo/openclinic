<%@page import="be.openclinic.finance.InsurarCredit, be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/ajaxRequirements.jsp"%>
<%=checkPermission(out,"financial.insurarCreditEdit","edit",activeUser)%>
<%
    String sAction = checkString(request.getParameter("Action"));

    String sEditCreditUid        = checkString(request.getParameter("EditCreditUid")),
           sEditCreditDate       = checkString(request.getParameter("EditCreditDate")),
           sEditCreditInsurarUid = checkString(request.getParameter("EditCreditInsurarUid")),
           sEditCreditInvoiceUid = checkString(request.getParameter("EditCreditInvoiceUid")),
           sEditCreditInvoiceNr  = checkString(request.getParameter("EditCreditInvoiceNr")),
           sEditCreditAmount     = checkString(request.getParameter("EditCreditAmount")),
           sEditCreditType       = checkString(request.getParameter("EditCreditType")),
           sEditCreditDescr      = checkString(request.getParameter("EditCreditDescription")),
		   sEditCreditWicketUid  = checkString(request.getParameter("EditCreditWicketUid"));
    
    String sFindDateBegin         = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd           = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin         = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax         = checkString(request.getParameter("FindAmountMax")),
           sFindCreditInsurarUid  = checkString(request.getParameter("FindCreditInsurarUid")),
           sFindCreditInsurarName = checkString(request.getParameter("FindCreditInsurarName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** financial/insurarEditCredit.jsp ******************");
        Debug.println("sAction               : "+sAction);
        Debug.println("sEditCreditUid        : "+sEditCreditUid);
        Debug.println("sEditCreditDate       : "+sEditCreditDate);
        Debug.println("sEditCreditInsurarUid : "+sEditCreditInsurarUid);
        Debug.println("sEditCreditInvoiceUid : "+sEditCreditInvoiceUid);
        Debug.println("sEditCreditInvoiceNr  : "+sEditCreditInvoiceNr);
        Debug.println("sEditCreditAmount     : "+sEditCreditAmount);
        Debug.println("sEditCreditType       : "+sEditCreditType);
        Debug.println("sEditCreditDescr      : "+sEditCreditDescr);
        Debug.println("sEditCreditWicketUid  : "+sEditCreditWicketUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sEditCreditInsurarName, msg = "";

    // set default wicket if no wicket specified
    if(sEditCreditWicketUid.length()==0){
        sEditCreditWicketUid = activeUser.getParameter("defaultwicket");
    }
    if(sEditCreditWicketUid.length()==0){
        sEditCreditWicketUid = checkString((String)session.getAttribute("defaultwicket"));
    }
    
    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        InsurarCredit credit;
        if(sEditCreditUid.length() > 0){
            credit = InsurarCredit.get(sEditCreditUid);
        }
        else{
            credit = new InsurarCredit();
            credit.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }

        credit.setDate(ScreenHelper.getSQLDate(sEditCreditDate));
        credit.setInsurarUid(sEditCreditInsurarUid);
        credit.setInvoiceUid(sEditCreditInvoiceUid);
        credit.setAmount(Double.parseDouble(sEditCreditAmount));
        credit.setType(sEditCreditType);
        credit.setComment(sEditCreditDescr);

        credit.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        credit.setUpdateUser(activeUser.userid);
        credit.store(Integer.parseInt(activeUser.userid));

        msg = getTran(request,"web","dataIsSaved",sWebLanguage);

        //*** update wicket credit ********************************************
        if(sEditCreditWicketUid.length() > 0){
            // get wicket credit belonging to this insurarCredit, if any specified
            WicketCredit wicketCredit = null;
            if(sEditCreditUid.length() > 0){
                wicketCredit = WicketCredit.getByReferenceUid(sEditCreditUid,"InsurarCredit");
            }

            // create wicket credit if not found or not specified
            if(wicketCredit==null || wicketCredit.getUid()==null || wicketCredit.getUid().length()==0){
                wicketCredit = new WicketCredit();

                wicketCredit.setWicketUID(sEditCreditWicketUid);
                session.setAttribute("defaultwicket",sEditCreditWicketUid);
                wicketCredit.setCreateDateTime(ScreenHelper.getSQLDate(sEditCreditDate));
                wicketCredit.setUserUID(Integer.parseInt(activeUser.userid));
            }

            wicketCredit.setOperationDate(new Timestamp(ScreenHelper.parseDate(sEditCreditDate).getTime()));
            wicketCredit.setOperationType(sEditCreditType);
            wicketCredit.setAmount(Double.parseDouble(sEditCreditAmount));

            // set credit comment + invoice number as default comment
            if(wicketCredit.getComment()==null || (wicketCredit.getComment()!=null && wicketCredit.getComment().toString().length()==0)){
                wicketCredit.setComment(Insurar.get(credit.getInsurarUid()).getName()+(ScreenHelper.checkString(credit.getComment()).length()==0?"":" ("+ScreenHelper.checkString(credit.getComment())+")")+" - "+sEditCreditInvoiceUid.replaceAll("1\\.",""));
            }

            wicketCredit.setInvoiceUID(sEditCreditInvoiceUid);

            // reference to patientCredit
            ObjectReference objRef = new ObjectReference();
            objRef.setObjectType("InsurarCredit");
            objRef.setObjectUid(credit.getUid());
            wicketCredit.setReferenceObject(objRef);
            wicketCredit.setUpdateDateTime(getSQLTime());
            wicketCredit.setUpdateUser(activeUser.userid);

            wicketCredit.store();

            // recalculate wicket balance
            Wicket wicket = Wicket.get(sEditCreditWicketUid);
            wicket.recalculateBalance();
        }
    }

    //--- LOAD SPECIFIED CREDIT -------------------------------------------------------------------
    if(sEditCreditUid.length()>0 && !sAction.equalsIgnoreCase("save")){
        InsurarCredit credit = InsurarCredit.get(sEditCreditUid);

        sEditCreditUid         = credit.getUid();
        sEditCreditDate        = checkString(ScreenHelper.stdDateFormat.format(credit.getDate()));
        sEditCreditInsurarUid  = credit.getInsurarUid();
        sEditCreditInsurarName = Insurar.get(sEditCreditInsurarUid).getName();
        sEditCreditInvoiceUid  = credit.getInvoiceUid();
        sEditCreditInvoiceNr   = sEditCreditInvoiceUid.substring(sEditCreditInvoiceUid.indexOf(".")+1);
        sEditCreditAmount      = Double.toString(credit.getAmount());
        sEditCreditDescr       = credit.getComment();
        sEditCreditType        = credit.getType();
    }
    else{
        // new credit
        sEditCreditUid         = "";
        sEditCreditDate        = getDate(); // now
        sEditCreditInsurarUid  = "";
        sEditCreditInsurarName = "";
        sEditCreditInvoiceUid  = "";
        sEditCreditInvoiceNr   = "";
        sEditCreditAmount      = "";
        sEditCreditType        = MedwanQuery.getInstance().getConfigString("defaultInsuranceCreditType","insurance.payment");
        sEditCreditDescr       = "";
    }

    if(sEditCreditType.length()==0) sEditCreditType = "insurance.payment";
%>
<form name="EditForm" id="EditForm" method="POST" onClick="clearMessage();">
    <%=writeTableHeader("financial","extraInsurarCreditEdit",sWebLanguage," doBack();")%>
    
    <table class="menu" width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td class="admin"><%=getTran(request,"web","insurar",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2" colspan="4">
                <input type="hidden" name="FindCreditInsurarUid" id="FindCreditInsurarUid" value="<%=sFindCreditInsurarUid%>">
                <input class="text" type="text" name="FindCreditInsurarName" id="FindCreditInsurarName" readonly size="60" value="<%=sFindCreditInsurarName%>">
                <img src="<c:url value='/_img/icons/icon_search.png'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar('FindCreditInsurarUid','FindCreditInsurarName');">
                <img src="<c:url value='/_img/icons/icon_delete.png'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.FindCreditInsurarUid.value='';EditForm.FindCreditInsurarName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web.occup","medwan.common.date",sWebLanguage)%></td>
            <td class="admin2" width="100"><%=getTran(request,"Web","Begin",sWebLanguage)%></td>
            <td class="admin2" width="150"><%=writeDateField("FindDateBegin","EditForm",sFindDateBegin,sWebLanguage)%></td>
            <td class="admin2" width="100"><%=getTran(request,"Web","end",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindDateEnd","EditForm",sFindDateEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","amount",sWebLanguage)%></td>
            <td class="admin2"><%=getTran(request,"Web","min",sWebLanguage)%></td>
            <td class="admin2"><input type="text" class="text" name="FindAmountMin" id="FindAmountMin" value="<%=sFindAmountMin%>" onblur="isNumber(this)"></td>
            <td class="admin2"><%=getTran(request,"Web","max",sWebLanguage)%></td>
            <td class="admin2"><input type="text" class="text" name="FindAmountMax" id="FindAmountMax" value="<%=sFindAmountMax%>" onblur="isNumber(this)"></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2" colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="loadUnassignedCredits(EditForm.FindCreditInsurarUid.value)">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFindFields()">&nbsp;
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="clearEditFields();">&nbsp;
            </td>
        </tr>
    </table>
    <br>
    
    <div id="divCredits" class="searchResults" style="height:122px;width:100%">
        <%=getTran(request,"financial","selectInsurar",sWebLanguage)%>
    </div>
    <br>
    
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditCreditUid" id="EditCreditUid" value="<%=sEditCreditUid%>">
    
    <table class="list"width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","date",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2"><%=writeDateField("EditCreditDate","EditForm",sEditCreditDate,sWebLanguage)%></td>
        </tr>
        
        <%-- INSURAR --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","insurar",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="hidden" name="EditCreditInsurarUid" value="<%=sEditCreditInsurarUid%>">
                <input class="text" type="text" name="EditCreditInsurarName" readonly size="60" value="<%=sEditCreditInsurarName%>">
              
                <%-- icons --%>
                <img src="<c:url value='/_img/icons/icon_search.png'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar('EditCreditInsurarUid','EditCreditInsurarName');">
                <img src="<c:url value='/_img/icons/icon_delete.png'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditInsurarUid.value='';EditForm.EditCreditInsurarName.value='';">
            </td>
        </tr>
        
        <%-- INVOICE --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","invoice",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="hidden" name="EditCreditInvoiceUid" value="<%=sEditCreditInvoiceUid%>">
                <input class="text" type="text" name="EditCreditInvoiceNr" readonly size="10" value="<%=sEditCreditInvoiceNr%>">
                
                <%-- icons --%>
                <img src="<c:url value='/_img/icons/icon_search.png'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInvoice('EditCreditInvoiceUid','EditCreditInvoiceNr','EditCreditAmount','EditCreditInsurarUid','EditCreditInsurarName');">
                <img src="<c:url value='/_img/icons/icon_delete.png'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditInvoiceUid.value='';EditForm.EditCreditInvoiceNr.value='';">
            </td>
        </tr>
        
        <%-- AMOUNT --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","amount",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input class="text" type="text" name="EditCreditAmount" value="<%=sEditCreditAmount%>" size="10" maxLength="9" onKeyUp="isNumberNegativeAllowed(this)">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>
            </td>
        </tr>
        
        <%-- TYPE --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","type",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <select class="text" name="EditCreditType">
                <option value=""></option>
                    <%=ScreenHelper.writeSelectUnsorted(request,"credit.type",sEditCreditType,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- DESCRIPTION --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","description",sWebLanguage)%></td>
            <td class="admin2"><%=writeTextarea("EditCreditDescription","","","",sEditCreditDescr)%></td>
        </tr>
        
        <%-- WICKETS --%>
        <%
            Vector userWickets = Wicket.getWicketsForUser(activeUser.userid);
            if(userWickets.size() > 0){
                %>
                    <tr>
                        <td class="admin"><%=getTran(request,"wicket","wicket",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <select class="text" id="EditCreditWicketUid" name="EditCreditWicketUid">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%
                                    Iterator iter = userWickets.iterator();
                                    Wicket wicket;

                                    while(iter.hasNext()){
                                        wicket = (Wicket)iter.next();

                                        %>
                                          <option value="<%=wicket.getUid()%>" <%=sEditCreditWicketUid.equals(wicket.getUid())?" selected":""%>>
                                              <%=wicket.getUid()%>&nbsp;<%=getTranNoLink("service",wicket.getServiceUID(),sWebLanguage)%>
                                          </option>
                                        <%
                                    }
                                %>
                            </select>
                        </td>
                    </tr>
                <%
            }
            else{
                %><input type="hidden" name="EditCreditWicketUid"><%
            }
        %>
        
        <%-- BUTTONS & PRINT --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;&nbsp;
               
                <span id="printsection" name="printsection" style="visibility:hidden">
                    <%=getTran(request,"Web.Occup","PrintLanguage",sWebLanguage)%>&nbsp;

                    <%
                        String sPrintLanguage = activeUser.person.language;
                        if(sPrintLanguage.length()==0){
                            sPrintLanguage = sWebLanguage;
                        }

                        String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
                    %>

                    <select class="text" name="PrintLanguage" id="PrintLanguage">
                        <%
                            String tmpLang;
                            StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
                            while(tokenizer.hasMoreTokens()){
                                tmpLang = tokenizer.nextToken();

                                %><option value="<%=tmpLang%>"<%=(tmpLang.equalsIgnoreCase(sPrintLanguage)?" selected":"")%>><%=getTranNoLink("Web.language",tmpLang,sWebLanguage)%></option><%
                            }
                        %>
                    </select>

                    <%-- BUTTONS --%>
                    <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print",sWebLanguage)%>' onclick="doPrintPdf(document.getElementById('EditCreditUid').value);">
                    <%
                    	if(MedwanQuery.getInstance().getConfigInt("javaPOSenabled",0)==1){
                            %><input class="button" type="button" name="buttonPrintPOS" value='<%=getTranNoLink("Web","print.receipt",sWebLanguage)%>' onclick="doPrintPatientPaymentReceipt();"><%
                        }
                    %>                    
                </span>
            </td>
        </tr>
    </table>
    <%=getTran(request,"web","asterisk_fields_are_obligate",sWebLanguage)%>
    
    <%-- display message --%>
    <br><br><span id="msgArea">&nbsp;<%=msg%></span>
</form>

<script>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById("msgArea").innerHTML = "";<%
        }
    %>
  }

  function doSave(){
    if(EditForm.EditCreditDate.value.length > 0 &&
       EditForm.EditCreditInsurarUid.value.length > 0 &&
       EditForm.EditCreditInsurarName.value.length > 0 &&
       EditForm.EditCreditInvoiceUid.value.length > 0 &&
       EditForm.EditCreditAmount.value.length > 0 &&
       EditForm.EditCreditType.value.length > 0){
       EditForm.Action.value = "save";
       EditForm.submit();
    }
    else{
      if(EditForm.EditCreditDate.value.length==0){
        EditForm.EditCreditDate.focus();
      }
      else if(EditForm.EditCreditInsurarName.value.length==0){
        EditForm.EditCreditInsurarName.focus();
      }
      else if(EditForm.EditCreditAmount.value.length==0){
        EditForm.EditCreditAmount.focus();
      }
      else if(EditForm.EditCreditInvoiceUid.value.length==0){
        EditForm.EditCreditInvoiceNr.focus();
      }
      else if(EditForm.EditCreditType.value.length==0){
        EditForm.EditCreditType.focus();
      }

                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran(null,"web.manage","dataMissing",sWebLanguage)%>');
    }
  }

  function searchInsurar(insurarUidField,insurarNameField){
    openPopup("/_common/search/searchInsurar.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldInsurarUid="+insurarUidField+
              "&ReturnFieldInsurarName="+insurarNameField);
  }

  function searchInvoice(invoiceUidField,invoiceNrField,invoiceBalanceField,insurarUidField,insurarNameField){
    var url = "/_common/search/searchExtraInsurarInvoice.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldInvoiceUid="+invoiceUidField+
              "&ReturnFieldInvoiceNr="+invoiceNrField+
              "&FindInvoiceStatus=<%=MedwanQuery.getInstance().getConfigString("defaultInvoiceStatus","open")%>"+
              "&FindInvoiceInsurar="+EditForm.EditCreditInsurarUid.value+
              "&FindInvoiceBalanceMin=0.01"+
              "&Action=search";

    if(invoiceBalanceField!=undefined){
      url+= "&ReturnFieldInvoiceBalance="+invoiceBalanceField;
    }

    if(insurarUidField!=undefined){
      url+= "&ReturnFieldInsurarUid="+insurarUidField;
    }
      
    if(insurarNameField!=undefined){
      url+= "&ReturnFieldInsurarName="+insurarNameField;
    }

    openPopup(url);
  }             

  function loadUnassignedCredits(sInsurarUid){
    if(EditForm.FindCreditInsurarUid.value.length > 0){
      $("divCredits").innerHTML = "<br><br><br><div id='ajaxLoader' style='display:block;text-align:center;'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..</div>";
          
      var params = "FindDateBegin="+document.getElementById('FindDateBegin').value+
                   "&FindDateEnd="+document.getElementById('FindDateEnd').value+
                   "&FindAmountMin="+document.getElementById('FindAmountMin').value+
                   "&FindAmountMax="+document.getElementById('FindAmountMax').value+
                   "&insurarUid="+sInsurarUid;
      var url = "<c:url value='/financial/getUnassignedInsurarCredits.jsp'/>?ts="+new Date();
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          $("divCredits").innerHTML = resp.responseText;
        }
      });
    }
  }

  function selectCredit(creditUid,creditDate,amount,type,descr,invoiceUid,wicketuid){
    EditForm.EditCreditWicketUid.value=wicketuid;
    EditForm.EditCreditUid.value = creditUid;
    EditForm.EditCreditDate.value = creditDate;
    EditForm.EditCreditAmount.value = amount;
    EditForm.EditCreditType.value = type;
    EditForm.EditCreditDescription.value = descr;
    EditForm.EditCreditInvoiceUid.value = invoiceUid;

    if(invoiceUid.indexOf(".")>-1){
      EditForm.EditCreditInvoiceNr.value = invoiceUid.split(".")[1];
    }
    else{
      EditForm.EditCreditInvoiceNr.value = "";
    }
    EditForm.EditCreditInsurarUid.value = EditForm.FindCreditInsurarUid.value;
    EditForm.EditCreditInsurarName.value = EditForm.FindCreditInsurarName.value;
    
    document.getElementById('printsection').style.visibility = 'visible';
    document.getElementById('PrintLanguage').show();
  }

  function clearEditFields(){
    EditForm.EditCreditUid.value = "";
    EditForm.EditCreditDate.value = "<%=getDate()%>";
    EditForm.EditCreditInsurarUid.value = "";
    EditForm.EditCreditInsurarName.value = "";
    EditForm.EditCreditInvoiceUid.value = "";
    EditForm.EditCreditInvoiceNr.value = "";
    EditForm.EditCreditAmount.value = "";
    EditForm.EditCreditType.value = "<%=MedwanQuery.getInstance().getConfigString("defaultInsurarCreditType","insurance.payment")%>";
    EditForm.EditCreditDescription.value = "";
    document.getElementById('printsection').style.visibility = "hidden";
    document.getElementById('PrintLanguage').style.visibility = "hidden";
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
  }

  function clearFindFields(){
    EditForm.FindDateBegin.value = "";
    EditForm.FindDateEnd.value = "";
    EditForm.FindAmountMin.value = "";
    EditForm.FindAmountMax.value = "";
  }
  
  function doPrintPdf(creditUid){
    var url = "<c:url value='/financial/createInsurarPaymentReceiptPdf.jsp'/>?CreditUid="+creditUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value;
    window.open(url,"PaymentReceiptPdf<%=getTs()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
  }

  function doPrintPatientPaymentReceipt(){
	var url = '<c:url value="/financial/printInsurarPaymentReceiptOffline.jsp"/>'+
	          '?credituid='+document.getElementById('EditCreditUid').value+
	          '&language=<%=sWebLanguage%>&userid=<%=activeUser.userid%>'+
	          '&ts='+new Date();
    new Ajax.Request(url,{
	  method: "GET",
      parameters: "",
      onSuccess: function(resp){
       	var label = eval('('+resp.responseText+')');
       	if(label.message.length>0){
          alertDialog(label.message.unhtmlEntities());
        }
      },
	  onFailure: function(){
		alert("Error printing receipt");
      }
    });
  }
  
  EditForm.EditCreditDate.focus();
  loadUnassignedCredits(EditForm.FindCreditInsurarUid.value);
  
  if(document.getElementById('EditCreditUid').value.length > 0){
    document.getElementById('printsection').style.visibility = 'visible';
    document.getElementById('PrintLanguage').show();
  }
</script>