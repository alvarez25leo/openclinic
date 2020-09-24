<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Career,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditCareerUid = checkString(request.getParameter("EditCareerUid")),
           sPersonId      = checkString(request.getParameter("PersonId"));

    String sCareerBegin = checkString(request.getParameter("careerBegin")),
           sCareerEnd   = checkString(request.getParameter("careerEnd")),
           sContractUid = checkString(request.getParameter("contractUid")),
           sPosition    = checkString(request.getParameter("position")),
           sServiceUid  = checkString(request.getParameter("serviceUid")),
           sGrade       = checkString(request.getParameter("grade")),
           sStatus      = checkString(request.getParameter("status")),
           sComment     = checkString(request.getParameter("comment"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** saveCareer.jsp ******************");
        Debug.println("sEditCareerUid : "+sEditCareerUid);
        Debug.println("sPersonId      : "+sPersonId);
        Debug.println("sCareerBegin   : "+sCareerBegin);
        Debug.println("sCareerEnd     : "+sCareerEnd);
        Debug.println("sContractUid   : "+sContractUid);
        Debug.println("sPosition      : "+sPosition);
        Debug.println("sServiceUid    : "+sServiceUid);
        Debug.println("sGrade         : "+sGrade);
        Debug.println("sStatus        : "+sStatus);
        Debug.println("sComment       : "+sComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    Career career = new Career();
    career.personId = Integer.parseInt(sPersonId);
    String sMessage = "";
    
    if(sEditCareerUid.length() > 0){
        career.setUid(sEditCareerUid);
    }
    else{
        career.setUid("-1");
        career.setCreateDateTime(getSQLTime());
    }

    if(sCareerBegin.length() > 0){
        career.begin = ScreenHelper.parseDate(sCareerBegin);
    }
    if(sCareerEnd.length() > 0){
        career.end = ScreenHelper.parseDate(sCareerEnd);
    }

    career.contractUid = sContractUid;
    career.position = sPosition;
    career.serviceUid = sServiceUid;
    career.grade = sGrade;
    career.status = sStatus;
    career.comment = sComment;
    career.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    career.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = career.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran(request,"web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = getTran(request,"web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=career.getUid()%>"
}