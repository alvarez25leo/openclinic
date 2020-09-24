<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.openclinic.system.Config,
                java.util.Hashtable,
                java.util.Enumeration"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<script src='<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js'></script>
<%=checkPermission(out,"system.management","all",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindKey = checkString(request.getParameter("FindKey"));
    String sFindValue = checkString(request.getParameter("FindValue"));

    String sEditOc_key = checkString(request.getParameter("EditOc_key"));
    String sEditOc_value = checkString(request.getParameter("EditOc_value"));
    String sEditDefaultvalue = checkString(request.getParameter("EditDefaultvalue"));
    String sEditOverride = checkString(request.getParameter("EditOverride"));
    String sEditComment = checkString(request.getParameter("EditComment"));
    String sEditSQLvalue = checkString(request.getParameter("EditSQLvalue"));
    String sEditDeleted = checkString(request.getParameter("EditDeleted"));
    String sEditSynchronize = checkString(request.getParameter("EditSynchronize"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
	    Debug.println("\n************************* system/manageConfig.jsp **********************");
	    Debug.println("sAction : "+sAction);
	    Debug.println("sFindKey          : "+sFindKey);
	    Debug.println("sFindValue        : "+sFindValue);
	    Debug.println("sEditOc_key       : "+sEditOc_key);
	    Debug.println("sEditOc_value     : "+sEditOc_value);
	    Debug.println("sEditDefaultvalue : "+sEditDefaultvalue);
	    Debug.println("sEditOverride     : "+sEditOverride);
	    Debug.println("sEditComment      : "+sEditComment);
	    Debug.println("sEditSQLvalue     : "+sEditSQLvalue);
	    Debug.println("sEditDeleted      : "+sEditDeleted);
	    Debug.println("sEditSynchronize  : "+sEditSynchronize+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    boolean keyAllreadyExists = false;
    String msg = "";
    String sSelectedOc_key = "", sSelectedOc_value = "", sSelectedComment = "", sSelectedSynchronize = "",
           sSelectedDefaultvalue = "", sSelectedOverride = "", sSelectedSQL_value = "";

    //--- SEARCH -----------------------------------------------------------------------------------
    if(sAction.equals("Add")){
        if(sEditOc_key != null && sEditOc_key.length() > 0){
            // check existence
            boolean bExist = Config.exists(sEditOc_key);

            //*** insert ***
            if(!bExist) {
                Config objConfig = new Config();
                objConfig.setOc_key(sEditOc_key);
                objConfig.setOc_value(new StringBuffer(sEditOc_value));
                objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
                objConfig.setUpdatetime(getSQLTime());
                objConfig.setComment(new StringBuffer(sEditComment));
                objConfig.setDefaultvalue(sEditDefaultvalue);
                objConfig.setOverride(sEditOverride.length() > 0 ? Integer.parseInt(sEditOverride) : 0);
                objConfig.setSql_value(new StringBuffer(sEditSQLvalue));

                if(sEditDeleted.equals("on")){
                    objConfig.setDeletetime(new Timestamp(new java.util.Date().getTime()));
                }
                else{
                    objConfig.setDeletetime(null);
                }

                Config.addConfig(objConfig);

                msg = "Key '"+sEditOc_key+"' "+getTran(request,"Web", "added", sWebLanguage);
            } 
            else {
                // record found
                keyAllreadyExists = true;
                msg = "Key '"+sEditOc_key+"' "+getTran(request,"Web", "exists", sWebLanguage);
            }

            sFindKey = sEditOc_key;
            sAction = "Show";

            MedwanQuery.getInstance().reloadConfigValues();
        }
    }
    //--- SAVE -------------------------------------------------------------------------------------
    else if (sAction.equals("Save")) {
        if (sEditOc_key != null && sEditOc_key.length() > 0) {
            //*** update ***
            Config objConfig = Config.getConfig(sEditOc_key);
            
            objConfig.setOc_value(new StringBuffer(sEditOc_value));
            objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
            objConfig.setUpdatetime(getSQLTime());
            objConfig.setComment(new StringBuffer(sEditComment));
            objConfig.setDefaultvalue(sEditDefaultvalue);
            objConfig.setOverride(sEditOverride.length() > 0 ? Integer.parseInt(sEditOverride) : 0);
            objConfig.setSql_value(new StringBuffer(sEditSQLvalue));
            objConfig.setSynchronize(sEditSynchronize);

            if (sEditDeleted.equals("on")) {
                objConfig.setDeletetime(new Timestamp(new java.util.Date().getTime()));
            } 
            else {
                objConfig.setDeletetime(null);
            }

            Config.saveConfig(objConfig);

            msg = "Key '"+sEditOc_key+"' "+getTran(request,"Web", "saved", sWebLanguage);
            sAction = "Show";

            MedwanQuery.getInstance().reloadConfigValues();
        }
        out.print("<script>window.setTimeout('doSearch();',500);</script>");
    }
    //--- DELETE -----------------------------------------------------------------------------------
    else if (sAction.equals("Delete")) {
        if (sEditOc_key != null && sEditOc_key.length() > 0) {
            Config.deleteConfig(sEditOc_key);
            MedwanQuery.reload();
            sEditDeleted = "";

            msg = "Key '"+sEditOc_key+"' "+getTran(request,"Web", "deleted", sWebLanguage);
            sAction = "New";

            MedwanQuery.getInstance().reloadConfigValues();
        }
    }
    //--- NEW --------------------------------------------------------------------------------------
    else if (sAction.equals("New")) {
        sSelectedOc_key = sFindKey;
        sSelectedOc_value = sFindValue;
    }

    //--- SHOWDETAILS (= search one specific record to show later) ---------------------------------
    if (sAction.equals("Show")) {
        Config objConfig = Config.getConfig(sEditOc_key);
        if(objConfig!=null && objConfig.getOc_value()!=null){
	        if(objConfig.getDeletetime()!=null) sEditDeleted = "on";
	
	        sSelectedOc_key = sEditOc_key;
	        sSelectedOc_value = objConfig.getOc_value().toString();
	        sSelectedComment = objConfig.getComment().toString();
	        sSelectedDefaultvalue = objConfig.getDefaultvalue();
	        sSelectedOverride = Integer.toString(objConfig.getOverride());
	        sSelectedSQL_value = objConfig.getSql_value().toString();
	        sSelectedSynchronize = objConfig.getSynchronize();
	        
	        MedwanQuery.getInstance().reloadConfigValues();  
        }
        
        out.print("<script>window.setTimeout('doSearch();',500);</script>");
    }

%>
<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doSearch();}">
    <input type="hidden" name="Action">
    
    <%=writeTableHeader("Web.manage","ManageConfiguration",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table width="100%" cellspacing="1" cellpadding="0">
        <%-- search fields --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">Key</td>
            <td class="admin2"><input type="text" class="text" name="FindKey" size="40" value="<%=sFindKey%>"></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"Web","value",sWebLanguage)%></td>
            <td class="admin2"><input type="text" class="text" name="FindValue" size="40" value="<%=sFindValue%>"></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="button" class="button" name="SearchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onClick="doSearch();">&nbsp;
                <input type="button" class="button" name="ClearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="clearFindFields();">&nbsp;
                <input type="button" class="button" name="NewButton" value="<%=getTranNoLink("Web","New",sWebLanguage)%>" onClick="doNew();">&nbsp;
                <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
                &nbsp;
                <img src='<c:url value="/_img/themes/default/pijl.gif"/>'>
                <a  href="<c:url value='/main.do?Page=system/manageConfigTabbed.jsp?ts='/><%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran(request,"Web.Manage","manageConfigurationTabbed",sWebLanguage)%></a>&nbsp;
            </td>
        </tr>
    </table>
    <br>
    
    <div style="height:150px;width:100%" class="searchResults" id="divFindRecords"></div>
    <%
      //  if(sAction.equals("Show") || sAction.equals("New")){
            %>
            <br>
            <%-- edit fields --%>
            <table class="list" width="100%" cellspacing="1">
                <%-- key --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>">Key</td>
                    <td class="admin2"><input class="text" type="text" name="EditOc_key" value="<%=sSelectedOc_key%>" size="70"></td>
                </tr>
                <%-- value --%>
                <tr>
                    <td class="admin"><%=getTran(request,"Web","value",sWebLanguage)%></td>
                    <td class="admin2">
                    <%
                        if(sSelectedSQL_value.length() > 0 && sSelectedSQL_value.toLowerCase().startsWith("select")){
                            %><select class="text" name="EditOc_value"><%
	                        
                            Hashtable hSQL = Config.executeConfigSQL_value(sSelectedSQL_value);
	                        Enumeration enum2 = hSQL.keys();
	                        String sSQLID, sSQLName;
	                        while (enum2.hasMoreElements()) {
	                            sSQLID = (String) enum2.nextElement();
	                            sSQLName = (String) hSQL.get(sSQLID);
	
	                            if (sSQLID.equalsIgnoreCase(sSelectedOc_value)) {
	                                %><option value="<%=sSQLID%>" SELECTED><%=(sSQLID+" "+sSQLName)%></option><%
	                            }
                                else{
                                    %><option value="<%=sSQLID%>"><%=(sSQLID+" "+sSQLName)%></option><%
                                }
                            }
                            %></select><%
                        }
                        else{
                            %><%=writeTextarea("EditOc_value","","4","",sSelectedOc_value)%><%
                        }
                    %>
                    </td>
                </tr>
                <%-- default value --%>
                <tr>
                    <td class="admin"><%=getTran(request,"Web.Manage.Config","Defaultvalue",sWebLanguage)%></td>
                    <td class="admin2"><%=writeTextarea("EditDefaultvalue","","4","",sSelectedDefaultvalue)%></td>
                </tr>
                <%-- systemvalue overwritable --%>
                <tr>
                    <td class="admin"><%=getTran(request,"Web.Manage.Config","OverrideSystemValue",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="radio" name="EditOverride" value="0" onDblClick="uncheckRadio(this);" <%if(sSelectedOverride.equals("0")){out.print("checked");}%>><%=getTran(request,"Web","No",sWebLanguage)%>
                        <input type="radio" name="EditOverride" value="1" onDblClick="uncheckRadio(this);" <%if(sSelectedOverride.equals("1")){out.print("checked");}%>><%=getTran(request,"Web","Yes",sWebLanguage)%>
                    </td>
                </tr>
                <%-- SQL --%>
                <tr>
                    <td class="admin">SQL (SQLID, SQLName)</td>
                    <td class="admin2"><%=writeTextarea("EditSQLvalue","","4","",sSelectedSQL_value)%></td>
                </tr>
                <%-- comment --%>
                <tr>
                    <td class="admin"><%=getTran(request,"Web","Comment",sWebLanguage)%></td>
                    <td class="admin2"><%=writeTextarea("EditComment","","4","",sSelectedComment)%></td>
                </tr>
                <%-- synchronize --%>
                <tr>
                    <td class="admin"><%=getTran(request,"Web.manage","synchronise",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="checkbox" name="EditSynchronize" value="1" <%=(sSelectedSynchronize.equals("1")?"CHECKED":"")%>>
                    </td>
                </tr>
                <%-- deleted --%>
                <tr>
                    <td class="admin"><%=getTran(request,"Web","deleted",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="checkbox" name="EditDeleted" <%=(sEditDeleted.equals("on")?"CHECKED":"")%>>
                    </td>
                </tr>
                <tr>
                    <td class="admin"/>
                    <td class="admin2">
                     <%
                            if(sAction.equals("Show")){
                                %>
                                <input class='button' type="button" name="SaveButton" value='<%=getTranNoLink("Web","Save",sWebLanguage)%>' onclick="doSave();">&nbsp;
                                <input class="button" type="button" name="AddButton" value='<%=getTranNoLink("Web","Add",sWebLanguage)%>' onclick="doAdd();">&nbsp;
                                <input class="button" type="button" name="DeleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete();">&nbsp;
                                <%
                            }
                            else if(sAction.equals("New")){
                                %>
                                <input class="button" type="button" name="AddButton" value='<%=getTranNoLink("Web","Add",sWebLanguage)%>' onclick="doAdd();">&nbsp;
                                <%
                            }
                        %>
                    </td>
                </tr>
                <%-- message --%>
                <tr>
                    <td class="admin2" colspan="2">
                        <%
                          if(sAction.equals("Show") || sAction.equals("New")){
                              if(msg == null){
                                  // std message
                                  %><%=getTran(request,"Web.Manage","noDataChanged",sWebLanguage)%><%
                              }
                              else{
                                  // custom (red) message
                                  %><span <%=(keyAllreadyExists? "style=\"color:red\"":"")%>><%=msg%></span><%
                              }
                          }
                        %>
                    </td>
                </tr>
            </table>
            <%
      //  }
    %>
</form>

<%-- SCRIPTS -------------------------------------------------------------------------------------%>
<script>
  function doSave(){
    if(formComplete()){
      transactionForm.Action.value = 'Save';
      transactionForm.submit();
    }
  }

  function doAdd(){
    if(formComplete()){
      transactionForm.Action.value = 'Add';
      transactionForm.submit();
    }
  }
    
  <%-- DO DELETE --%>
  function doDelete(){
      if(yesnoDeleteDialog()){
      transactionForm.Action.value = "Delete";
      transactionForm.submit();
    }
  }

  function formComplete(){
    if(transactionForm.EditOc_key.value==""){
      alertDialog("Web","someFieldsAreEmpty");
      transactionForm.EditOc_key.focus();
      return false;
    }

    return true;
  }

  function doShow(key){
    transactionForm.EditOc_key.value = key;
    transactionForm.Action.value = 'Show';
    transactionForm.submit();
  }

  function doSearch(){
    var params = 'FindKey='+document.getElementsByName('FindKey')[0].value+
                 "&FindValue="+ document.getElementsByName('FindValue')[0].value;
    var url= '<c:url value="/system/manageConfigFind.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
      parameters: params,
      onSuccess: function(resp){
        $('divFindRecords').innerHTML = resp.responseText;
      }
    });
  }

  function doNew(){
    transactionForm.Action.value = 'New';
    transactionForm.submit();
  }

  function clearFindFields(){
    transactionForm.FindKey.value = "";
    transactionForm.FindValue.value = "";
    transactionForm.FindKey.focus();
  }

  function doBack(){
    window.location.href = '<c:url value='/main.do'/>?Page=system/menu.jsp';
  }

  window.setTimeout('transactionForm.FindKey.focus();',300);
</script>

<%-- ALERT ---------------------------------------------------------------------------------------%>
<%
    if(keyAllreadyExists){
        %><script>alertDialogDirectText("<%=msg%>");</script><%
    }
%>