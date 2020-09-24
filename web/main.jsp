<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	// prevent caching
    response.setHeader("Content-Type","text/html;charset=ISO-8859-1");
    response.setHeader("Expires","Sat,6 May 1995 12:00:00 GMT");
    response.setHeader("Cache-Control","no-store,no-cache,must-revalidate");
    response.addHeader("Cache-Control","post-check=0,pre-check=0");
    response.setHeader("Pragma","no-cache");
    
    // WorkTime-message
    String sWorkTimeMessage = "";
    boolean alertWorkTimeMsg = false;
    String tz = MedwanQuery.getInstance().getConfigString("timeZone","");
    if(tz.length()>0){
    	tz="GMT"+tz+":00";
    }
	TimeZone.setDefault(java.util.TimeZone.getTimeZone(tz.length()>0?tz:java.util.TimeZone.getDefault().getID()));
    // only show message on server
    if(MedwanQuery.getInstance().getConfigString("masterEnabled").equals("1")){
        // get message from DB
        if(checkString((String)session.getAttribute("WorkTimeMessage")).length()==0){
            sWorkTimeMessage = getTranDb("WorkTime","WorkTimeMessage",sWebLanguage);

            // add WorkTimeMessage to session
            if(sWorkTimeMessage.length() > 0 && !sWorkTimeMessage.equalsIgnoreCase("WorkTimeMessage")){
                alertWorkTimeMsg = true;
                session.setAttribute("WorkTimeMessage",sWorkTimeMessage);
            } 
            else{
                session.removeAttribute("WorkTimeMessage");
            }
        }
        else{
            // get message from session
            sWorkTimeMessage = checkString((String)session.getAttribute("WorkTimeMessage"));
        }
    }
%>
<html id='html'>
<head>
  <%=sCSSNORMAL%>
  <%=sCSSMODALBOX%>
  <%=sJSTOGGLE%>
  <%=sJSFORM%>
  <%=sJSPOPUPMENU%>
  <%=sJSPROTOTYPE%>
  <%=sJSSCRPTACULOUS%>
  <%=sJSMODALBOX%>
  <%=sIcon%>
  <%=sJSSCRIPTS%>
  <%=sJSSTRINGFUNCTIONS%>
</head>

<%@include file="/includes/messageChecker.jsp"%>

<%
	String sPage = checkString(request.getParameter("Page"));
	//No reload for certain pages
	if(sPage.indexOf("statistics/")<0){
	%>
		<body id="body" onresize="if(window.confirm('<%=getTranNoLink("web","datamodified.doreload",sWebLanguage) %>')){window.setTimeout('window.location.reload();',200);}">
	<%
	}
	else{
		out.println("<body id='body'>");
	}
	if(request.getParameter("exitmessage")!=null){
        if(request.getParameter("exitmessage").startsWith("printlabels")){
            int serverid      = Integer.parseInt(request.getParameter("exitmessage").split("\\.")[1]),
                transactionId = Integer.parseInt(request.getParameter("exitmessage").split("\\.")[2]);
			
			%><script>window.open("<c:url value='/healthrecord/createLabSampleLabelPdf.jsp'/>?serverid=<%=serverid%>&transactionid=<%=transactionId%>&ts=<%=getTs()%>", "Popup"+new Date().getTime(), "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=400, height=300, menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);</script><%
        }
    }
%>


<table width="100%" border="0" cellspacing="0" cellpadding="0" id="holder">
    <tr>
		<img style='display: none' id='copytocb' height='20px' src='<%=sCONTEXTPATH%>/_img/icons/mobile/copy.png' onclick='copyTextToClipboard(document.getElementById("clipboard").innerHTML)'/>
        <span style='display: none' id='clipboard'><span>
        <td colspan="2" style="vertical-align:top;" id="header"><%ScreenHelper.setIncludePage(customerInclude("/_common/header.jsp"),pageContext);%></td>
    </tr>
    <% if(!"datacenter".equalsIgnoreCase((String)session.getAttribute("edition"))){ %>
    <tr class="menu_navigation">
        <td align="left" id="menu">
            <%ScreenHelper.setIncludePage("/_common/navigation.jsp",pageContext);%>
        </td>
        <td align="right" style="padding-top:3px;">
            <%ScreenHelper.setIncludePage(customerInclude("/_common/iconsRight.jsp"),pageContext);%>
        </td>
    </tr>
    <% } %>
    <%-- INCLUDE PAGE --%>
    <tr>
        <td colspan="2" height="100%" style="vertical-align:top;">
            <div class="content" id="Juist" width="100%" height="100%">
                <table width="100%" border="0" id="mijn" cellpadding="0" cellspacing="1">
                    <tr>
                        <td style="vertical-align:top;">
                            <%
								if(sPage.length() > 0 && !sPage.equalsIgnoreCase("null")){
								    ScreenHelper.setIncludePage(customerInclude("/"+sPage),pageContext);
								} 
								else{
								    ScreenHelper.setIncludePage(customerInclude("/_common/start.jsp"),pageContext);
								}
                            %>
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
</table>

<script>
  var dateFormat = "<%=ScreenHelper.stdDateFormat.toPattern()%>";
  var ie = document.all;
  var ns6 = document.getElementById && !document.all;
  
  function hideKeywordDivs(){
	  var divs = document.getElementsByTagName("div");
	  for(var i = 0; i < divs.length; i++){
		  if(divs[i].id.indexOf("keywords")==0 && divs[i].id.indexOf("keywords_")<0){
			  divs[i].innerHTML='';
		  }
	  }
  }
  
  function hasScrollbar(){
    return (document.getElementById("Juist").scrollHeight > document.getElementById("Juist").clientHeight);
  }
  
<%
    // do not resize textarea's in pages below : 
    if(!sPage.endsWith("medIntProctologyProtocols.jsp")){
        %>          
		  Event.observe(window,'load',function(){
			resizeAllTextareas(10);
		    changeInputColor();
		    pageResize();
	      });
	    <%
    }
  
    if(alertWorkTimeMsg){
		%>
		  var popupUrl = "<c:url value="/_common/search/workTimePopup.jsp"/>?ts=<%=getTs()%>&labelValue=<%=getTranNoLink("Web.Occup","medwan.common.workuntil",sWebLanguage)%> <%=sWorkTimeMessage%>";
		  var modalities = "dialogWidth:400px;dialogHeight:150px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
		  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("Web.Occup","medwan.common.workuntil",sWebLanguage)%>");
		<%
    }

    // alert message
    String msg = checkString(request.getParameter("msg"));
    if(msg.length() > 0){
		%>alertDialogDirectText("<%=msg%>");<%
    }

%>

window.setTimeout('document.getElementById("Juist").scrollTop=0',200);
</script>
</body>
</html>
