<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    if(activePatient!=null && activePatient.personid.length()>0){
        AdminPrivateContact apc = ScreenHelper.getActivePrivate(activePatient);

        if (apc!=null){
            %>
                <table width="100%" cellspacing="1" class="list">
                    <%=ScreenHelper.setGuineaAdminPrivateContact(request,apc,sWebLanguage)%>
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
                <input type="button" class="button" value="<%=getTran(null,"Web","history",sWebLanguage)%>" name="ButtonHistoryPrivate" onclick="parent.location='patienthistory.do?ts=<%=getTs()%>&contacttype=private'">&nbsp;
                <%
                    if (activeUser.getAccessRight("patient.administration.edit")){
                        %>
                            <input type="button" class="button" onclick="window.location.href='<c:url value="/patientedit.do"/>?Tab=AdminPrivate&ts=<%=getTs()%>'" value="<%=getTran(null,"Web","edit",sWebLanguage)%>">
                        <%
                    }
                %>
            <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>