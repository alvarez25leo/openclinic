<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=Foundiougne&Dir=projects/foundiougne/");
%>