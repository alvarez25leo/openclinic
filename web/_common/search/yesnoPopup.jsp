<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sCSSNORMAL%>

<%
    // label value is given OR label type and id
    String labelValue = checkString(request.getParameter("labelValue"));
    String labelType, labelID, questionTran;

    if(labelValue.length() == 0){
        labelType = ScreenHelper.checkDbString(request.getParameter("labelType")).toLowerCase();
        labelID   = ScreenHelper.checkDbString(request.getParameter("labelID")).toLowerCase();
        questionTran = getTran(request,labelType,labelID,sWebLanguage);
    }
    else{
        questionTran = labelValue;
    }
%>

<body class="Geenscroll">
<table width="100%" height="100%">
    <tr>
        <td align="center">
            <br><%=org.owasp.encoder.Encode.forHtml(questionTran)%>
            <br><br><br>

            <input type="button" name="buttonYes" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.yes",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(1);"/>&nbsp;
            <input type="button" name="buttonNo" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.no",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(0);"/>
            <br><br>
        </td>
    </tr>
</table>

<script>
  setTimeout("self.moveTo((self.screen.width-266)/2,(self.screen.height-133)/2);",100);  
  setTimeout("document.getElementById('buttonNo').focus()",110);

  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
</script>
</body>