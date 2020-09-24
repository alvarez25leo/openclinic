<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    response.setHeader("Pragma","no-cache"); // HTTP 1.0
    response.setDateHeader("Expires",0); // prevents caching at the proxy server

    String historyBack = checkString(request.getParameter("historyBack"));

    SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    TransactionVO oldTran = sessionContainerWO.getCurrentTransactionVO();
    String sTranId   = checkString(request.getParameter("be.mxs.healthrecord.transaction_id"));
    String sServerId = checkString(request.getParameter("be.mxs.healthrecord.server_id"));

    sessionContainerWO.setCurrentTransactionVO(MedwanQuery.getInstance().loadTransaction(Integer.parseInt(sServerId), Integer.parseInt(sTranId)));
%>
<html>
    <head>
        <%=sCSSNORMAL%>
        <%=sJSTOGGLE%>
        <%=sJSFORM%>
        <%=sJSPOPUPMENU%>
        <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    </head>

    <body style="border:3px" onBlur="this.focus();">
        <script>
          function noError(){
            return true;
          }

          window.onerror = noError;
        </script>

        <table width="100%" border="0" cellspacing="0" cellpadding="0" class="list">
            <tr>
                <td style="vertical-align:top;" class="white">
                    <%
                        ScreenHelper.setIncludePage("/healthrecord/content.jsp", pageContext);
                    %>
                </td>
            </tr>
        </table>

        <script>
          window.resizeTo(800,570);

          var sfEls1 = document.getElementsByTagName("INPUT");
          for (var i=0; i<sfEls1.length; i++) {
            if (sfEls1[i].className=="button"){
              sfEls1[i].style.visibility = 'hidden';
            }
          }
        </script>

        <%-- BUTTONS --%>
        <%=ScreenHelper.alignButtonsStart()%>
            <input type="button" class="button" name="ButtonBack" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="<%=(historyBack.length() > 0?"history.go(-"+historyBack+");":"history.go(-1);")%>">
            <input type="button" class="button" name="ButtonClose" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
            <br><br>
        <%=ScreenHelper.alignButtonsStop()%>
    </body>
</html>
<%
    sessionContainerWO.setCurrentTransactionVO(oldTran);
%>