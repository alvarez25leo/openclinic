<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<html>
<head>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
    <%=sJSDATE%>
    <%=sJSPOPUPSEARCH%>
    <%=sJSDROPDOWNMENU%>
    <%=sJSPROTOTYPE%>
    <%=sJSNUMBER%>
    <%=sJSTOGGLE%>
    <%=sCSSMODALBOX%>
    <%=sJSMODALBOX%>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%=sJSSCRPTACULOUS%>
  	<%=sJSSCRIPTS%>

</head>
<%

    String sPopupPage = checkString(request.getParameter("Page"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############################# /popup.jsp ##############################");
        Debug.println("sPopupPage : "+sPopupPage+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<script>  
  var dateFormat = "<%=ScreenHelper.stdDateFormat.toPattern()%>";
	
  <%-- ALERT DIALOG --%>
  function alertDialog(labelType,labelId){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      alertDialogAjax(labelType,labelId); // Opera          
    }
  }
  
  <%-- ALERT DIALOG DIRECT TEXT --%>
  function alertDialogDirectText(sMsg){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelValue="+sMsg;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      alert(sMsg); // Opera          
    }
  }
  <%-- ALERT DIALOG AJAX --%>
  function alertDialogAjax(labelType,labelId){
    var url = "<c:url value='/_common/getLabel.jsp'/>?ts=<%=ScreenHelper.getTs()%>&LabelType="+labelType+"&LabelId="+labelId;
    new Ajax.Request(url,{
      onSuccess:function(resp){
          var label = eval('('+resp.responseText+')').label.trim();
          if(label.length > 0){
            label = label.unhtmlEntities();
          alertDialogDirectText(label);
        }
        else{
          alert(labelType+"."+labelId);
        }
      }
    });
  }

  <%-- YESNO DIALOG --%>
  function yesnoDialog(labelType,labelId,callbackFunction){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts="+new Date().getTime()+"&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);

      if(callbackFunction){
    	if(answer==true) callbackFunction.call(this);
      }
      else return answer;
    }
    else{   
      var url = "<c:url value='/_common/getLabel.jsp'/>?ts=<%=ScreenHelper.getTs()%>&LabelType="+labelType+"&LabelId="+labelId;
      new Ajax.Request(url,{
        async:false,
        onSuccess:function(resp){
            var label = eval('('+resp.responseText+')').label.trim();
          if(label.length > 0){
            label = label.unhtmlEntities();
        	if(yesnoDialogDirectText(label)){
              callbackFunction.call(this);
        	}
          }
          else{
        	if(window.confirm(labelType+"."+labelId)){
              callbackFunction.call(this);
        	}
          }
        }
      });
    }
  }
  
  <%-- YESNO DIALOG DIRECT TEXT --%>
  function yesnoDialogDirectText(labelText){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/yesnoPopup.jsp'/>?ts="+new Date().getTime()+"&labelValue="+labelText;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelText);          
    }
    
    return answer; // FF
  }
    
  <%-- YESNO DELETE DIALOG --%>
  function yesnoDeleteDialog(){
	<%
	    /*
        String sAPPTITLE = ScreenHelper.checkString((String)session.getAttribute("activeProjectTitle"));
	    if(sAPPTITLE.length()==0) sAPPTITLE = "Openclinic";
	    
        String sWebLanguage = ScreenHelper.checkString((String)session.getAttribute(sAPPTITLE+"WebLanguage"));
        */
	%>
	return yesnoDialogDirectText("<%=ScreenHelper.getTranNoLink("Web","areYouSureToDelete",sWebLanguage)%>");	
  }
</script>
<%
%>
<script>
  var ie = document.all
  var ns6 = document.getElementById && !document.all

  <%-- OPEN POPUP --%>
  function openPopup(page,width,height,title){
    var url = "<c:url value='/popup.jsp'/>?Page="+page;
    if(width!=undefined) url+= "&PopupWidth="+width;
    if(height!=undefined) url+= "&PopupHeight="+height;
    if(title==undefined){
      if(page.indexOf("&") < 0){
        title = page.replace("/","_");
        title = replaceAll(title,".","_");
      }
      else{
        title = replaceAll(page.substring(1,page.indexOf("&")),"/","_");
        title = replaceAll(title,".","_");
      }
    }
    var w = window.open(url,title,"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
    w.moveBy(2000,2000);
  }

  <%-- REPLACE ALL --%>
  function replaceAll(s,s1,s2){
    while(s.indexOf(s1) > -1){
      s = s.replace(s1,s2);
    }
    return s;
  }

  <%-- ENTER EVENT --%>
  function enterEvent(e,targetKeyCode){
	var eventKey = e.which?e.which:window.event.keyCode;
	return (eventKey==targetKeyCode);
  }
  
  <%-- ENTER KEY PRESSED --%>
  function enterKeyPressed(e){
    var eventKey = e.which?e.which:window.event.keyCode;
	return (eventKey==13);
  }

  <%-- DELETE KEY PRESSED --%>
  function deleteKeyPressed(e){
	var eventKey = e.which?e.which:window.event.keyCode;
	return (eventKey==46);	
  }

  <%-- AJAX CHANGE SEARCH RESULTS --%>
  function ajaxChangeSearchResults(urlForm,SearchForm,moreParams){
    document.getElementById('divFindRecords').innerHTML = "<div style='text-align:center;padding-top:2px;'><img src='<%=sCONTEXTPATH%>/_img/themes/<%=checkString((String)session.getAttribute("UserTheme"))%>/ajax-loader.gif'/><br/>Loading..</div>";
    var url = urlForm;
    var params = Form.serialize(SearchForm)+moreParams;
    var myAjax = new Ajax.Updater("divFindRecords",url,{
      method: "POST",
      evalScripts: true,
      parameters:params,
      onSuccess:function(resp){
        document.getElementById("divFindRecords").innerHTML = trim(resp.responseText);
      },
      onFailure:function(){
        $("divFindRecords").innerHTML = "Problem with ajax request";
      }
    });
  }
</script>
  
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
</head>

<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;height:30px;visibility:hidden">
    <table width="100%" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
                <%=getTranNoLink("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>


<script>
  <%=getUserInterval(session,activeUser)%>

  function xmlReport(fname){
	    var URL = "<c:url value='util/createXMLReportPdf.jsp'/>?filename="+fname;
	    window.open(URL);
	  }

  function resizeMe(){
    <%
		String sPopupWidth = checkString(request.getParameter("PopupWidth"));
		if(sPopupWidth.length() > 0){
            %>w = <%=sPopupWidth%>;<%
		}
		else{
            %>
	        if(ie){
	          rcts = popuptbl.getClientRects();
	          w = rcts[0].right;
	        } 
	        else{
	          w = document.getElementById("popuptbl").clientWidth;
	        }
            <%
		}

		String sPopupHeight = checkString(request.getParameter("PopupHeight"));
		if(sPopupHeight.length() > 0){
            %>h =<%=sPopupHeight%>;<%
		}
		else{
            %>
	        if(ie){
	          rcts = popuptbl.getClientRects();
	          h = rcts[0].bottom+80;
	        }
	        else{
	          h = document.getElementById("popuptbl").clientHeight;
	        }
            <%
        }
    %>
    
    if(h > 800) h = 800;
    if(h > screen.height) h = screen.height;
    w = w+35;
    if(w < 400) w = 400;
    h = h+130;
    window.resizeTo(w,h);
    window.moveTo((screen.width-w)/2,(screen.height-h)/2);
  }
  
  if(typeof focusfield!="undefined") focusfield.focus();
  window.setTimeout('resizeMe();',200);
  
  <%-- The following script is used to hide the calendar whenever you click the document. --%>
  <%-- When using it you should set the name of popup button or image to "popcal", otherwise the calendar won't show up. --%>
  document.onmousedown = function(e){
    var n = !e?self.event.srcElement.name:e.target.name;

    if(document.layers){
      with(gfPop) var l = pageX, t = pageY, r = l+clip.width, b = t+clip.height;
      if(n!="popcal" && (e.pageX > r || e.pageX < l || e.pageY > b || e.pageY < t)){
        gfPop1.fHideCal();
        gfPop2.fHideCal();
        gfPop3.fHideCal();
      }
      return routeEvent(e);
    }
    else if(n!="popcal"){
      gfPop1.fHideCal();
      gfPop2.fHideCal();
      gfPop3.fHideCal();
    }
  }
  if(document.layers) document.captureEvents(Event.MOUSEDOWN);
  window.setTimeout('resizeMe();',200);
</script>
<%-- End Floating layer -------------------------------------------------------------------------%>
<body style="margin:2px;" onload="resizeMe();">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="popuptbl">
    <tr>
        <td colspan="3" style="vertical-align:top;" height="100%">
            <%
                response.setHeader("Pragma","no-cache"); //HTTP 1.0
                response.setDateHeader("Expires",0); //prevents caching at the proxy server
                ScreenHelper.setIncludePage("/"+customerInclude(sPopupPage),pageContext);
            %>
        </td>
    </tr>
</table>

</body>
</html>