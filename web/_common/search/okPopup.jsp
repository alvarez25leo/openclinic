<%@page import="org.owasp.encoder.Encode"%>
<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sCSSNORMAL%>

<%
	// label value is given OR label type and id
    String labelValue = checkString(request.getParameter("labelValue"));
    String labelType="", labelID="", questionTran="";

    if(labelValue.length()==0){
        labelType = ScreenHelper.checkDbString(request.getParameter("labelType"));
        labelID   = ScreenHelper.checkDbString(request.getParameter("labelID"));
        questionTran = getTranNoLink(labelType,labelID,sWebLanguage);
    }
    else{
        questionTran = labelValue;
    } 
%>
<body class="Geenscroll">
<table width="100%" height="100%">
    <tr>
        <td align="center" style="padding:1px">
            <br><img src="<c:url value='/_img/icons/icon_warning.gif'/>"/> <%=Encode.forHtml(questionTran)%>
            <br><br><br>

            <input type="button" name="buttonOk" id="buttonOk" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.ok",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(1);"/>
            <br><br>
        </td>
    </tr>
</table>

<script>
  <%=sCenterWindow%>
  setTimeout("document.getElementById('buttonOK').focus()",100);
  //window.resizeTo(400,300);
  
  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
</script>
</body>