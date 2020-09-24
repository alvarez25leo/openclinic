<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    if(activePatient!=null && activePatient.personid.length()>0){
        AdminSocSec socsec = activePatient.socsec;

        if (socsec!=null){
            String sCovered = "";

            if (checkString(socsec.covered).length()>0){
                sCovered = getTran(request,"web.occup",socsec.covered,sWebLanguage);
            }

            String sAssuranceType = "";
            if (checkString(socsec.assurancetype).length()>0){
                sAssuranceType = getTran(request,"assurancetype",socsec.assurancetype,sWebLanguage);
            }

            %>
                <table width="100%" cellspacing="1" class="list">
                    <%=(setRow("Web.socsec","covered",sCovered,sWebLanguage)
                        +setRow("Web.socsec","enterprise",socsec.enterprise,sWebLanguage)
                        +setRow("Web.socsec","assurancenumber",socsec.assurancenumber,sWebLanguage)
                        +setRow("Web.socsec","assurancetype",sAssuranceType,sWebLanguage)
                        +setRow(request,"Web","start",socsec.start,sWebLanguage)
                        +setRow(request,"Web","stop",socsec.stop,sWebLanguage)
                        +setRow(request,"Web","comment",socsec.comment,sWebLanguage))
                    %>
                    <tr height='1'><td width='<%=sTDAdminWidth%>'/></tr>
                </table>
            <%
        }
    }
%>
<%-- BUTTONS -------------------------------------------------------------------------------------%>
<%
    String sShowButton = checkString(request.getParameter("ShowButton"));
    if(!sShowButton.equals("false")){
        %>
            <%=ScreenHelper.alignButtonsStart()%>
                <%
                    if (activeUser.getAccessRight("patient.administration.edit")){
                        %>
                            <input type="button" class="button" onclick="window.location.href='<c:url value="/patientedit.do"/>?Tab=AdminSocSec&ts=<%=getTs()%>'" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>">
                        <%
                    }
                %>
            <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>