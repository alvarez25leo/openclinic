<%@page import="be.openclinic.hr.SalaryCalculationManager"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../hr/includes/commonFunctions.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));
    boolean ajaxMode = (checkString(request.getParameter("AjaxMode")).equalsIgnoreCase("true"));

    String sPeriodBegin = checkString(request.getParameter("beginDate")),
           sPeriodEnd   = checkString(request.getParameter("endDate")),
           sPersonId    = checkString(request.getParameter("personId"));
     
    if(sPeriodBegin.length()==0 || sPeriodEnd.length()==0){
        // currMonth : begin and end
        Calendar now = Calendar.getInstance();        
        int month = now.get(Calendar.MONTH)+1;
        String sMonth = Integer.toString(month);
        if(month < 10){
            sMonth = "0"+sMonth;
        }
                
        if(sPeriodBegin.length()==0){
            String sCurrMonthBegin = "01/"+sMonth+"/"+now.get(Calendar.YEAR);
            sPeriodBegin = sCurrMonthBegin;
        }
        
        if(sPeriodEnd.length()==0){
            String sCurrMonthEnd = now.getActualMaximum(Calendar.DAY_OF_MONTH)+"/"+sMonth+"/"+now.get(Calendar.YEAR);
            sPeriodEnd = sCurrMonthEnd;
        }
    }
    
    /// DEBUG ////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******* hr/management/createSalaryCalculationsForLeaves.jsp *******");
        Debug.println("sAction      : "+sAction);
        Debug.println("ajaxMode     : "+ajaxMode);
        Debug.println("sPersonId    : "+sPersonId);
        Debug.println("sPeriodBegin : "+sPeriodBegin);
        Debug.println("sPeriodEnd   : "+sPeriodEnd+"\n");
    }
    //////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    
    
    //*** CREATE **********************************************************************************
    if(sAction.equals("create")){
        java.util.Date periodBegin = null, periodEnd = null;
        
        if(sPeriodBegin.length() > 0){
            periodBegin = ScreenHelper.parseDate(sPeriodBegin);
        }
        if(sPeriodEnd.length() > 0){
            periodEnd = ScreenHelper.parseDate(sPeriodEnd);
        }
        
        int[] counters;
        if(sPersonId.length() > 0){
            // one specific dossier
        	counters = SalaryCalculationManager.createSalaryCalculationsForLeavesForPerson(Integer.parseInt(sPersonId),periodBegin,periodEnd,activeUser);
        }
        else{
        	// all dossiers 
            counters = SalaryCalculationManager.createSalaryCalculationsForLeaves(periodBegin,periodEnd,activeUser);        
        }
        
        int calculationsCreated   = counters[0],
            calculationsExisted   = counters[1],
            calculationsOverruled = counters[2];
        
        sMsg = "Created <b>"+calculationsCreated+"</b> calculations;<br>"+
               "<b>"+calculationsExisted+"</b> calculations already existed for the specified leave;<br>"+
               "<b>"+calculationsOverruled+"</b> calculations overruled by leaves.<br><br>"+
               "<i>When only few calculations were created, they might exist already.</i><br>"+
               "<i>If no period specified, the period is the current month.</i>";
    }

    if(ajaxMode==true){
    	// return message
    	%><%=sMsg%><%
    }
    else{
        %>   
<form name="EditForm" method="post" action="<c:url value='/main.do'/>?Page=hr/management/createSalaryCalculationsForLeaves.jsp&ts=<%=getTs()%>" onkeydown="if(enterEvent(event,13)){createCalculations();return false;}">
    <%=writeTableHeader("web.manage","createSalaryCalculationsForLeaves",sWebLanguage,"")%>
    <input type="hidden" name="Action" value="">

    <table border="0" width="100%" cellspacing="1">      
        <%-- beginDate --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web.hr","beginDate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("beginDate","EditForm",sPeriodBegin,sWebLanguage)%>          
            </td>                        
        </tr>
        
        <%-- endDate --%>
        <tr>
            <td class="admin"><%=getTran(request,"web.hr","endDate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("endDate","EditForm",sPeriodEnd,sWebLanguage)%>          
            </td>                        
        </tr> 
        
        <%-- employees --%>
        <tr>
            <td class="admin" style="vertical-align:top;"><%=getTran(request,"web.hr","employees",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%
                    Vector employeeNames = new Vector(SalaryCalculationManager.getEmployeePersonIds().values()); 

                    String sEmployeeName;
	                for(int i=0; i<employeeNames.size(); i++){
	                	sEmployeeName = (String)employeeNames.get(i);
	                    
	                	%><%=sEmployeeName%><br><%
	                }        
                %>
            </td>                        
        </tr>            
                                      
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2">
                <input type="button" class="button" name="buttonCreate" value="<%=getTranNoLink("web.manage","createCalculations",sWebLanguage)%>" onclick="createCalculations();">
                <input type="button" class="button" name="buttonBack" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    <br>
        
    <%
        // display message, if any
        if(sMsg.length() > 0){
            %><%=sMsg%><br><br><%
        }
    %>   
    
    <i><font color="green">Leaves have priority over workschedules.</font></i><br><br>
        
    <%-- default leave time --%>
    <%
        String sLeaveDuration = MedwanQuery.getInstance().getConfigString("hr.salarycalculation.leaveduration","7,6");
    %>
    <i>The default leave-duration is configured in 'hr.salarycalculation.leaveduration' to '<%=sLeaveDuration%>'.</i><br><br>
        
    <%-- link to hr/manage_leave --%>
    <% 
        if(activePatient!=null && activePatient.personid.length() > 0){
            %>
                <img src="<c:url value='/_img/themes/default/pijl.gif'/>">
                <a href="<c:url value='/main.do'/>?Page=hr/manage_leave.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran(request,"web","leaveForActivePatient",sWebLanguage)%></a><br>
            <%
        }
    %>      
    
    <%-- link to createSalaryCalculationsForWorkschedules --%>
    <img src="<c:url value='/_img/themes/default/pijl.gif'/>">
    <a href="<c:url value='/main.do'/>?Page=hr/management/createSalaryCalculationsForWorkschedules.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran(request,"web.manage","createSalaryCalculationsForWorkschedules",sWebLanguage)%></a>&nbsp;
</form>
    
<script>  
  <%-- CREATE CALCULATIONS --%>
  function createCalculations(){
      if(yesnoDeleteDialog()){
      var okToSubmit = true;
    
      if(okToSubmit){  
        <%-- begin can not be after end --%>
        if(document.getElementById("beginDate").value.length > 0 && document.getElementById("endDate").value.length > 0){
          var beginDate = makeDate(document.getElementById("beginDate").value);
          var endDate = makeDate(document.getElementById("endDate").value);
      
          if(beginDate.getTime() > endDate.getTime()){
            okToSubmit = false;
            alertDialog("web","beginMustComeBeforeEnd");
            document.getElementById("beginDate").focus();
          }
        }  
      }   
      
      if(okToSubmit){
        EditForm.buttonCreate.disabled = true;
        EditForm.buttonBack.disabled = true;
        EditForm.Action.value = "create";
        
        EditForm.submit();
      }
    }    
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=system/menu.jsp";
  }
</script>
        <%
    }
%>
