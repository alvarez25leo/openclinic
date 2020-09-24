<%@page import="be.openclinic.medical.Problem,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%" class="list" height="100%" cellspacing="0">
    <tr class="admin">
        <td colspan="3">
            <%=getTran(request,"web.occup","medwan.common.problemlist",sWebLanguage)%>&nbsp;
            <a href="javascript:showProblemlist();"><img height='16px' style='vertical-align: middle' src="<c:url value='/_img/icons/icon_edit2.png'/>" class="link" alt="<%=getTranNoLink("web","editproblemlist",sWebLanguage)%>" ></a>
        </td>
    </tr>
    
    <%
        Vector activeProblems = Problem.getActiveProblems(activePatient.personid);
        Problem activeProblem;

        if(activeProblems.size() > 0){
	        for(int n=0; n<activeProblems.size(); n++){
	            activeProblem = (Problem)activeProblems.elementAt(n);
	           
	            String sCode = "";
	            if(activeProblem.getCode()!=null && activeProblem.getCode().length()>0){
	            	sCode = (MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType()+"code"+activeProblem.getCode(),sWebLanguage));
	            }
	            
	            // controleren op toegangsrecht-restricties voor deze diagnose
	            if(activeUser.getAccessRight("occup.restricteddiagnosis.select") || !MedwanQuery.getInstance().isRestrictedDiagnosis(activeProblem.getCodeType(),activeProblem.getCode())){
	                out.print("<tr valign='top'>"+
	                           "<td><b>"+activeProblem.getCode()+"</b></td>"+
	                           "<td><b>"+sCode.trim()+"</b><i>"+(sCode.trim().length()>0?" ":"")+checkString(activeProblem.getComment()).trim()+"</i></td>"+
	                           "<td>"+ScreenHelper.stdDateFormat.format(activeProblem.getBegin())+"</td>"+
	                          "</tr>");
	            }
	            else{
	                out.print("<tr valign='top'>"+
	                           "<td style='{color: red}'><b><i>!!!</i></b></td>"+
	                           "<td style='{color: red}'><b><i>"+getTran(request,"web","diagnosis.restrictedaccess",sWebLanguage).toUpperCase()+"</i></td>"+
	                           "<td>"+ScreenHelper.stdDateFormat.format(activeProblem.getBegin())+"</td>"+
	                          "</tr>");
	            }
	        }
        }

        // vertical pusher
        %><tr height="99%"><td/></tr><%
    %>
</table>

<script>
  function showProblemlist(){
    openPopup("medical/manageProblems.jsp&ts=<%=getTs()%>",700,500);
  }
</script>