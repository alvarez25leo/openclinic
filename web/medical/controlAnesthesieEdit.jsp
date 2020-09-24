<%@page import="be.openclinic.medical.AnesthesieControl"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"medical.controlanesthesie","select",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action")),
           sCAID   = checkString(request.getParameter("EditUID"));

    // remember search-criteria, when returning to overview
    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd")),
           sFindOK    = checkString(request.getParameter("FindOK")),
           sPageIdx   = checkString(request.getParameter("PageIdx"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** medical/controlAnesthesieEdit.jsp ******************");
    	Debug.println("sAction    : "+sAction);
    	Debug.println("sCAID      : "+sCAID);
    	Debug.println("(to return) sFindBegin : "+sFindBegin);
    	Debug.println("(to return) sFindEnd   : "+sFindEnd);
    	Debug.println("(to return) sFindOK    : "+sFindOK);
    	Debug.println("(to return) sPageIdx   : "+sPageIdx+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    String sControlByName = "";
    AnesthesieControl ac;

   	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
   	
   	//*** SAVE ******************************************************
    if(sAction.equals("SAVE")){
        if(sCAID.length()==0){
            ac = new AnesthesieControl();
            ac.setCreateDateTime(getSQLTime());
        }
        else{
            ac = AnesthesieControl.get(sCAID);
            ac.setUid(sCAID);
        }

        String sDate = checkString(request.getParameter("EditDate"));
        if(sDate.length()==0) sDate = getDate();
        
        ac.setDate(ScreenHelper.getSQLDate(sDate));
        ac.setControlPerformedById(checkString(request.getParameter("EditControlByID")));
        ac.setBeginHour(checkString(request.getParameter("EditBeginHour")));
        ac.setEndHour(checkString(request.getParameter("EditEndHour")));
        ac.setDuration(checkString(request.getParameter("EditDuration")));
        
        // OK/NOK
        ac.setEquipmentAnesthesie(checkString(request.getParameter("EditEquipmentAnesthesie")));
        ac.setEquipmentAnesthesieRemark(checkString(request.getParameter("EditEquipmentAnesthesieRemark")));
        ac.setEquipmentMonitor(checkString(request.getParameter("EditEquipmentMonitor")));
        ac.setEquipmentMonitorRemark(checkString(request.getParameter("EditEquipmentMonitorRemark")));
        ac.setManageMedicines(checkString(request.getParameter("EditManageMedicines")));
        ac.setManageMedicinesRemark(checkString(request.getParameter("EditManageMedicinesRemark")));
        ac.setVacuumCleaner(checkString(request.getParameter("EditVacuumCleaner")));
        ac.setVacuumCleanerRemark(checkString(request.getParameter("EditVacuumCleanerRemark")));
        ac.setOxygen(checkString(request.getParameter("EditOxygen")));
        ac.setOxygenRemark(checkString(request.getParameter("EditOxygenRemark")));
        ac.setOther(checkString(request.getParameter("EditOther")));
        ac.setOtherRemark(checkString(request.getParameter("EditOtherRemark")));
        
        ac.setUpdateDateTime(getSQLTime());
        ac.setUpdateUser(activeUser.userid);
        ac.store();

        if(ac.getControlPerformedById().length()>0){
            sControlByName = ScreenHelper.getFullUserName(ac.getControlPerformedById(),ad_conn);
        }        
    }
    else if(sCAID.length() > 0){
        ac = AnesthesieControl.get(sCAID);
        if(ac.getControlPerformedById().length()>0){
            sControlByName = ScreenHelper.getFullUserName(ac.getControlPerformedById(),ad_conn);
        }
    }
    else{
        ac = new AnesthesieControl();
        ac.setDate(ScreenHelper.parseDate(getDate()));
        ac.setControlPerformedById(activeUser.userid);
        sControlByName = ScreenHelper.getFullUserName(activeUser.userid,ad_conn);
    }
   	
    ad_conn.close();
%>

<form name="transactionForm" method="post" action="<c:url value='/main.do'/>?Page=medical/controlAnesthesieEdit.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="FindBegin" value="<%=sFindBegin%>">
    <input type="hidden" name="FindEnd" value="<%=sFindEnd%>">
    <input type="hidden" name="FindOK" value="<%=sFindOK%>">
    <input type="hidden" name="PageIdx" value="<%=sPageIdx%>">
    <input type="hidden" name="EditUID" value="<%=ac.getUid()%>">
    <input type="hidden" name="Msg" value="">
    
    <%
        // back to overview, remembering the search-criteria
        if(sAction.equals("SAVE")){
            %>
            </form>
            
            <script>
              transactionForm.action = "<c:url value='/main.do?Page=medical/controlAnesthesieFind.jsp'/>&ts="+new Date().getTime();
              transactionForm.Action.value = "find";
              transactionForm.Msg.value = "saved";
              transactionForm.submit();
            </script>
            <%    	
        }
    %>
    
    <%=writeTableHeader("Web","controlanesthesie",sWebLanguage," doBack();")%>
    
    <table class="list" width="100%" border="0" cellspacing="1" cellpadding="0">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%></td>
            <td class="admin2" colspan="3"><%=writeDateField("EditDate","transactionForm",checkString(ScreenHelper.stdDateFormat.format(ac.getDate())),sWebLanguage)%></td>
        </tr>
        
        <%-- BEGIN HOUR --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","begin_hour",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <input type="text" class="text" id="abeginhour" name="EditBeginHour"onkeypress="keypressTime(this)" onblur="checkTime(this);calculateInterval('abeginhour','aendhour','aduration')" size="5" value="<%=ac.getBeginHour()%>">
                
                <a href="javascript:setCurrentTime('abeginhour');"><img src="<c:url value="/_img/icons/icon_compose.png"/>" class="link" title="<%=getTranNoLink("web","currenttime",sWebLanguage)%>"/></a>
            </td>
        </tr>
        
        <%-- END HOUR --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","end_hour",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <input type="text" class="text" id="aendhour" name="EditEndHour"onkeypress="keypressTime(this)" onblur="checkTime(this);calculateInterval('abeginhour','aendhour','aduration');" size="5" value="<%=ac.getEndHour()%>">
                
                <a href="javascript:setCurrentTime('aendhour');"><img src="<c:url value="/_img/icons/icon_compose.png"/>" class="link" title="<%=getTranNoLink("web","currenttime",sWebLanguage)%>"/></a>
            </td>
        </tr>
        
        <%-- DURATION --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","duration",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <input readonly type='text' class='text' id="aduration" name="EditDuration" size='5' value="<%=ac.getDuration()%>">
            </td>
        </tr>
        
        <%-- CONTROL PERFORMED BY --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","control_performed_by",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <input type="hidden" id="EditControlByID" name="EditControlByID" value="<%=ac.getControlPerformedById()%>">
                <input class="text" type="text" name="EditControlByName" readonly size="<%=sTextWidth%>" value="<%=sControlByName%>">
               
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchUser('EditControlByID','EditControlByName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditControlByID').value='';transactionForm.EditControlByName.value='';">
            </td>
        </tr>
    </table>
    <br>
    
    <%-- CHECK-LIST -----------------------------------------------------------------------------%>        
    <table class="list" width="100%" border="0" cellspacing="1" cellpadding="0">
        <tr class="admin">
            <td/>
            <td width="50"><%=getTran(request,"openclinic.chuk","ok",sWebLanguage)%></td>
            <td width="50"><%=getTran(request,"openclinic.chuk","nok",sWebLanguage)%></td>
            <td><%=getTran(request,"openclinic.chuk","remark",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","equipment_anesthesie",sWebLanguage)%></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditEquipmentAnesthesie" value="ok" <%=(ac.getEquipmentAnesthesie().equals("ok")?"checked":"")%>></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditEquipmentAnesthesie" value="nok" <%=(ac.getEquipmentAnesthesie().equals("nok")?"checked":"")%>></td>
            <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="100" rows="2" name="EditEquipmentAnesthesieRemark"><%=ac.getEquipmentAnesthesieRemark()%></textarea></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","equipment_monitor",sWebLanguage)%></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditEquipmentMonitor" value="ok"<%if(ac.getEquipmentMonitor().equals("ok")){out.print(" checked");}%>></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditEquipmentMonitor" value="nok"<%if(ac.getEquipmentMonitor().equals("nok")){out.print(" checked");}%>></td>
            <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="100" rows="2" name="EditEquipmentMonitorRemark"><%=ac.getEquipmentMonitorRemark()%></textarea></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","manage_medicines",sWebLanguage)%></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditManageMedicines" value="ok"<%if(ac.getManageMedicines().equals("ok")){out.print(" checked");}%>></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditManageMedicines" value="nok"<%if(ac.getManageMedicines().equals("nok")){out.print(" checked");}%>></td>
            <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="100" rows="2" name="EditManageMedicinesRemark"><%=ac.getManageMedicinesRemark()%></textarea></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","vacuum_cleaner",sWebLanguage)%></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditVacuumCleaner" value="ok"<%if(ac.getVacuumCleaner().equals("ok")){out.print(" checked");}%>></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditVacuumCleaner" value="nok"<%if(ac.getVacuumCleaner().equals("nok")){out.print(" checked");}%>></td>
            <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="100" rows="2" name="EditVacuumCleanerRemark"><%=ac.getVacuumCleanerRemark()%></textarea></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","oxygen",sWebLanguage)%></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditOxygen" value="ok"<%if(ac.getOxygen().equals("ok")){out.print(" checked");}%>></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditOxygen" value="nok"<%if(ac.getOxygen().equals("nok")){out.print(" checked");}%>></td>
            <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="100" rows="2" name="EditOxygenRemark"><%=ac.getOxygenRemark()%></textarea></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","other",sWebLanguage)%></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditOther" value="ok"<%if(ac.getOther().equals("ok")){out.print(" checked");}%>></td>
            <td class="admin2"><input type="radio" class="hand" onDblClick="uncheckRadio(this);" name="EditOther" value="nok"<%if(ac.getOther().equals("nok")){out.print(" checked");}%>></td>
            <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="100" rows="2" name="EditOtherRemark"><%=ac.getOtherRemark()%></textarea></td>
        </tr>
    </table>
     
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"medical.controlanesthesie",sWebLanguage,false)%>
	<%=ScreenHelper.alignButtonsStop()%>
</form>
    
<script>
  <%-- SET CURRENT TIME --%>
  function setCurrentTime(objName){
    var now = new Date();

    var minutes = now.getMinutes();
    if(minutes<10) minutes = "0"+minutes;

    var hours = now.getHours();
    if(hours<10) hours = "0"+hours;

    document.getElementById(objName).value = hours+":"+minutes;
    calculateInterval("abeginhour","aendhour","aduration");
  }

  <%-- CALCULATE INTERVAL --%>
  function calculateInterval(sBegin,sEnd,sReturn){
    document.getElementById(sReturn).value = "";
    
    if(document.getElementById(sBegin).value.length>0 && document.getElementById(sEnd).value.length>0){
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
      var sMinutes = (iMinutes%60)+"";

      document.getElementById(sReturn).value = sHour+":"+sMinutes;
      checkTime(document.getElementById(sReturn));
    }
  }

  <%-- GET MINUTES IN INTERVAL --%>
  function getMinutesInInterval(from,until){
    var millisDiff = until.getTime() - from.getTime();
    return (millisDiff/60000);
  }

  <%-- SEARCH USER --%>
  function searchUser(userID,userName){
    openPopup("/_common/search/searchUser.jsp&ts="+new Date().getTime()+"&ReturnUserID="+userID+"&ReturnName="+userName);
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
    transactionForm.saveButton.disabled = true;
    transactionForm.backButton.disabled = true;
    
    transactionForm.Action.value = "SAVE";
    transactionForm.submit();
  }
  
  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      transactionForm.action = "<c:url value='/main.do?Page=medical/controlAnesthesieFind.jsp'/>&ts="+new Date().getTime();
      transactionForm.Action.value = "find";
      transactionForm.submit();
    }
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>