<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.MaintenancePlan"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sPlanUID = checkString(request.getParameter("PlanUID"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******** assets/ajax/maintenancePlan/deleteMaintenancePlan.jsp *********");
        Debug.println("sPlanUID : "+sPlanUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = MaintenancePlan.delete(sPlanUID);
    String sMessage = "";
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTranNoLink("web","dataIsDeleted",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTranNoLink("web","error",sWebLanguage)+"</font>";
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}