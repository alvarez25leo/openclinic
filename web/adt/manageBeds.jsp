<%@page import="be.openclinic.adt.Bed,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"adt.managebeds","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    // Find Params
    String sFindBedName        = checkString(request.getParameter("FindBedName")),
           sFindBedService     = checkString(request.getParameter("FindBedService")),
           sFindBedServiceName = checkString(request.getParameter("FindBedServiceName"));

    // Edit Params
    String sEditUID        = checkString(request.getParameter("EditUID")),
           sEditName       = checkString(request.getParameter("EditName")),
           sEditBedService = checkString(request.getParameter("EditBedService")),
           sEditPriority   = checkString(request.getParameter("EditPriority")),
           sEditLocation   = checkString(request.getParameter("EditLocation")),
           sEditComment    = checkString(request.getParameter("EditComment"));

    String sEditBedServiceName = checkString(request.getParameter("EditBedServiceName"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************************** adt/manageBeds.jsp **************************");
        Debug.println("sAction             : "+sAction);
        Debug.println("sFindBedName        : "+sFindBedName);
        Debug.println("sFindBedService     : "+sFindBedService);
        Debug.println("sFindBedServiceName : "+sFindBedServiceName+"\n");
         
        Debug.println("sEditUID            : "+sEditUID);
        Debug.println("sEditName           : "+sEditName);
        Debug.println("sEditBedService     : "+sEditBedService);
        Debug.println("sEditBedServiceName : "+sEditBedServiceName);
        Debug.println("sEditPriority       : "+sEditPriority);
        Debug.println("sEditLocation       : "+sEditLocation);
        Debug.println("sEditComment        : "+sEditComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    
    String sMsg = "";
    
    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("SAVE")){
        Bed tmpBed = new Bed();
        if(sEditUID.length() > 0 ){
            tmpBed = Bed.get(sEditUID);
        }
        else{
            tmpBed.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }        
        tmpBed.setName(sEditName);
        
        Service sTMP = Service.getService(sEditBedService);
        if(sTMP==null){
            sTMP = new Service();
        }
        tmpBed.setService(sTMP);
        
        int priority = 1;
        try{
            priority = Integer.parseInt(sEditPriority);
        }
        catch(Exception e){
        	// empty
        }
        
        tmpBed.setPriority(priority);
        tmpBed.setLocation(sEditLocation);
        tmpBed.setComment(sEditComment);
        tmpBed.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        tmpBed.setUpdateUser(activeUser.userid);
        tmpBed.store();
        
        sEditUID = tmpBed.getUid();
        sMsg = getTran(request,"web","dataIsSaved",sWebLanguage);
    }
    
    if(sEditUID.length() > 0){
        Bed tmpBed = Bed.get(sEditUID);
        
        sEditUID            = tmpBed.getUid();
        sEditName           = tmpBed.getName();
        sEditPriority       = Integer.toString(tmpBed.getPriority());
        sEditLocation       = tmpBed.getLocation();
        sEditComment        = tmpBed.getComment();
        sEditBedService     = tmpBed.getService().code;
        sEditBedServiceName = getTran(request,"Service",sEditBedService,sWebLanguage);
    }

    //--- SEARCH ----------------------------------------------------------------------------------
    if(sAction.equals("SEARCH") || sAction.equals("")){
%>

<%-- BEGIN FIND BLOCK--%>
<form name='FindBedForm' method='POST' action='<c:url value="/main.do"/>?Page=adt/manageBeds.jsp&ts=<%=getTs()%>'>
    <%=writeTableHeader("Web","manageBeds",sWebLanguage," doBack();")%>
    
    <table class='list' width='100%' cellspacing='1' onKeyDown='if(enterEvent(event,13)){doFind();return false;}else{return true;}'>    
        <%-- service --%>
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="FindBedService" value="<%=sFindBedService%>">
                <input class="text" type="text" name="FindBedServiceName" readonly size="<%=sTextWidth%>" value="<%=sFindBedServiceName%>">
             
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('FindBedService','FindBedServiceName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindBedForm.FindBedService.value='';FindBedForm.FindBedServiceName.value='';">
            </td>
        </tr>
        
        <%-- name --%>
        <tr>
            <td class="admin2"><%=getTran(request,"Web","name",sWebLanguage)%></td>
            <td class="admin2"><input class='text' name='FindBedName' value='<%=sFindBedName%>' size="<%=sTextWidth%>"></td>
        </tr>
        
        <%-- buttons --%>
        <tr>
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class='button' type='button' name='buttonfind' value='<%=getTranNoLink("Web","search",sWebLanguage)%>' onclick='doFind();'>&nbsp;
                <input class='button' type='button' name='buttonclear' value='<%=getTranNoLink("Web","Clear",sWebLanguage)%>' onclick='doClear();'>&nbsp;
                <input class='button' type='button' name='buttonnew' value='<%=getTranNoLink("Web","new",sWebLanguage)%>' onclick='doNew();'>&nbsp;
                <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
    
    <input type='hidden' name='Action' value=''>
</form>
<%
    }

    //--- SEARCH ----------------------------------------------------------------------------------
    if(sAction.equals("SEARCH")){
        StringBuffer sbResults = new StringBuffer();
        Vector vBeds = null;

        try {
            vBeds = Bed.selectBeds("","",sFindBedName,sFindBedService,"","","");

            Iterator iter = vBeds.iterator();
            Bed bTmp;
            String sClass = "1";
            String sServiceUID = "";
            String sServiceName = "";

            while(iter.hasNext()){
            	// alternate row-styles
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                bTmp = (Bed)iter.next();
                sServiceUID = checkString(bTmp.getServiceUID());
                if(sServiceUID.length() > 0){
                    sServiceName = getTran(request,"Service",sServiceUID,sWebLanguage);
                } 
                else{
                    sServiceName = "";
                }

                sbResults.append("<tr class='list"+sClass+"' onclick=\"doSelect('"+checkString(bTmp.getUid())+"');\">"+
                                  "<td>"+checkString(bTmp.getName())+"</td>"+
                                  "<td>"+sServiceName+"</td>"+
                                 "</tr>");
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        if(sbResults.length()==0){
            out.print(getTran(request,"web","norecordsfound",sWebLanguage));
        }
        else{
	        %>
	            <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
	                <tr class="admin">
	                    <td width='30%'><%=getTran(request,"Web","name",sWebLanguage)%></td>
	                    <td width='*'><%=getTran(request,"Web","service",sWebLanguage)%></td>
	                </tr>
	                <tbody class="hand"><%=sbResults%></tbody>
	            </table>
	
	            <div><%=vBeds.size()%> <%=getTran(request,"web","recordsfound",sWebLanguage)%></div>
	        <%
        }
    }

    //--- EDIT ------------------------------------------------------------------------------------
    if(sAction.equals("NEW") || sAction.equals("SELECT") || sAction.equals("SAVE")){
%>
<form name='EditBedForm' method='POST' action='<c:url value="/main.do"/>?Page=adt/manageBeds.jsp&ts=<%=getTs()%>'>
    <%=writeTableHeader("Web","manageBeds",sWebLanguage," doBack();")%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- service --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","service",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="hidden" name="EditBedService" value="<%=sEditBedService%>">
                <input class="text" type="text" name="EditBedServiceName" readonly size="<%=sTextWidth%>" value="<%=sEditBedServiceName%>">
                
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('EditBedService','EditBedServiceName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditBedForm.EditBedService.value='';EditBedForm.EditBedServiceName.value='';">
            </td>
        </tr>
        
        <%-- name --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","name",sWebLanguage)%> *</td>
            <td class="admin2"><input class='text' type='text' name='EditName' value='<%=sEditName%>' size="<%=sTextWidth%>"></td>
        </tr>

        <%-- priority --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","priority",sWebLanguage)%></td>
            <td class="admin2"><input class='text' type='text' name='EditPriority' value='<%=sEditPriority%>' size="2"></td>
        </tr>
        
        <%-- location --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","location",sWebLanguage)%></td>
            <td class="admin2">
                <input class='text' type='text' name='EditLocation' value='<%=sEditLocation%>' size="<%=sTextWidth%>">
                
                <%
                    // icon to open location-document
                    if(sEditLocation.length() > 0){
                        %><img src="<c:url value="/_img/icons/icon_view.png"/>" class="link" alt="<%=getTranNoLink("Web","view",sWebLanguage)%>" onclick="openFile()"><%
                    }
                %>
                <br>
                <%
                    if(sEditLocation.length() > 0 && sEditLocation.indexOf(".") > -1){
                        String sExtension = sEditLocation.substring(sEditLocation.indexOf(".")+1).toLowerCase();

                        if(MedwanQuery.getInstance().getConfigString("image_extensions","gif,jpg,bmp").toLowerCase().indexOf(sExtension)>-1){
                            %><img id="myImg" src="<%=MedwanQuery.getInstance().getConfigString("documentsdir","adt/documents/")+"/"+sEditLocation%>" alt="" width="<%=MedwanQuery.getInstance().getConfigString("adt.bed.imagewidth","250")%>" border=1><%
                        }
                    }
                %>
            </td>
        </tr>
        
        <%-- comment --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","comment",sWebLanguage)%></td>
            <td class="admin2"><%=writeTextarea("EditComment","","","",sEditComment)%></td>
        </tr>
        
        <input type='hidden' name='Action' value=''>
        <input type='hidden' name='EditUID' value='<%=sEditUID%>'>
        
        <%-- buttons --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class='button' type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBackToSearch();">
            <input class='button' type="button" name="newButton" value='<%=getTranNoLink("Web","new",sWebLanguage)%>' onclick="doNewBed();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>

	<%
	    if(sMsg.length() > 0){
	        %><%=sMsg%><%
	    }
	%>
</form>

<form target="_newForm" name="uploadForm" action="<c:url value='/adt/storeDocument.jsp'/>" method="post" enctype="multipart/form-data">
    <%=writeTableHeader("Web","upload_file",sWebLanguage," doBack();")%>
    
    <table class="list" width="100%" cellspacing="1">
        <input name="ReturnField" value="EditLocation" type="hidden"/>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran(request,"web","doc_upload",sWebLanguage)%>
                <br>
            </td>
            <td class="admin2">
                <input class='text' name="filename" type="file" title="" size='<%=sTextWidth%>'/>
                &nbsp;&nbsp;<input class='button' name="sendimage" type="submit" value="<%=getTranNoLink("web","upload_file",sWebLanguage)%>">
            </td>
        </tr>
    </table>
    
    <%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>
</form>
<%
    }
%>

<script>
  function doClear(){
    FindBedForm.FindBedService.value = "";
    FindBedForm.FindBedServiceName.value = "";
    FindBedForm.FindBedName.value = "";
  }

  function doFind(){
    if(FindBedForm.FindBedService.value != "" || FindBedForm.FindBedName.value != ""){
      FindBedForm.Action.value = "SEARCH";
      FindBedForm.buttonfind.disabled = true;
      FindBedForm.submit();
    }
    else{
      alertDialog("web.manage","dataMissing");
    }
  }

  function doNew(){
    FindBedForm.Action.value = "NEW";
    FindBedForm.submit();
  }

  function doSelect(id){
    window.location.href="<c:url value='/main.do'/>?Page=adt/manageBeds.jsp&Action=SELECT&EditUID="+id+"&ts=<%=getTs()%>";
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp&ts=<%=getTs()%>";
  }

  function doBackToSearch(){
    window.location.href = "<c:url value='/main.do'/>?Page=adt/manageBeds.jsp&ts=<%=getTs()%>";
  }

  <%-- search info service --%>
  function searchInfoService(sObject){
    if(sObject.value.length > 0){
      openPopup("/_common/search/serviceInformation.jsp&ServiceID="+sObject.value+"&ViewCode=on");
    }
  }

  <%-- DO NEW BED --%>
  function doNewBed(){
    EditBedForm.newButton.disabled = true;
    
    EditBedForm.Action.value = "NEW";
    EditBedForm.EditName.value = "";
    EditBedForm.EditPriority.value = "";
    EditBedForm.EditLocation.value = "";
    EditBedForm.EditComment.value = "";
    EditBedForm.EditUID.value = "";
    
    EditBedForm.submit();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(EditBedForm.EditBedService.value==""){
      alertDialog("web","no_bed_service");
    }
    else if(EditBedForm.EditName.value==""){
      alertDialog("web","no_bed_name");
    }
    else if(!isNumber(EditBedForm.EditPriority.value)){
      alertDialog("web","bed_invalid_priority");
    }
    else{
      EditBedForm.saveButton.disabled = true;
      EditBedForm.Action.value = "SAVE";
      EditBedForm.submit();
    }
  }

  function isNumber(val){
    if(isNaN(val)) return false;
    else           return true;
  }

  function openFile(){
    if(EditBedForm.EditLocation.value.length > 0){
      var url = "<%=MedwanQuery.getInstance().getConfigString("documentsdir","adt/documents/")+"/"+sEditLocation%>";
      window.open(url,"Location","height=500,width=550,toolbar=no,status=no,scrollbars=no,resizable=no,menubar=no");
    }
  }

  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }
</script>