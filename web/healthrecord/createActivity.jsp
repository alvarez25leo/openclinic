<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String action = checkString(request.getParameter("action")).trim();
    String activityCode = checkString(request.getParameter("activityCode"));
    String labelnl = checkString(request.getParameter("labelnl"));
    String labelfr = checkString(request.getParameter("labelfr"));
    String labelen = checkString(request.getParameter("labelen"));
    boolean activityStored = false;

    String labelTran = getTran(request,"web.translations","label",sWebLanguage);

    if(action.equals("createActivity")){
        // store activity (in labels)
       	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps = ad_conn.prepareStatement("SELECT * FROM Labels WHERE labeltype = 'activitycodes' AND labelid = ?");
        ResultSet rs;
        ps.setString(1,activityCode);
        rs = ps.executeQuery();

        if(!rs.next()){
            int userId = Integer.parseInt(activeUser.userid);
            MedwanQuery.getInstance().storeLabel("activitycodes",activityCode,labelnl,activityCode,userId);
            MedwanQuery.getInstance().storeLabel("activitycodes",activityCode,labelfr,activityCode,userId);
            MedwanQuery.getInstance().storeLabel("activitycodes",activityCode,labelen,activityCode,userId);
            reloadSingleton(session);
            activityStored = true;
        }
        else{
            activityStored = false;
        }

        if(rs!=null) rs.close();
        if(ps!=null) ps.close();
		ad_conn.close();
		
        // message to user
        if(activityStored){
            %>
              <script>
                window.opener.location.reload();
                alertDialog("web.manage","newactivitycreated");
                window.close();
              </script>
            <%
        }
    }
%>

<head>
    <title><%=sAPPTITLE%></title>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
</head>

<body>
<form name="createForm" method="POST">
  <input type="hidden" name="action" value=""/>

  <table width='100%' border='0' cellspacing='1' cellpadding='0'>
    <%-- TITLE --%>
    <tr class="admin">
      <td colspan="2"><%=getTran(request,"web.manage","createActivity",sWebLanguage)%></td>
    </tr>

    <%-- INPUTFIELDS --%>
    <tr>
      <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web.manage","labanalysis.cols.code",sWebLanguage)%></td>
      <td class="admin2"><input class="text" type="text" name="activityCode" value="<%=activityCode%>" size="10" onBlur="isNumber(this);"></td>
    </tr>

    <tr>
      <td class="admin"><%=labelTran%> NL</td>
      <td class="admin2"><input class="text" type="text" name="labelnl" value="<%=labelnl%>" size="50" onblur="limitLength(this);"></td>
    </tr>

    <tr>
      <td class="admin"><%=labelTran%> FR</td>
      <td class="admin2"><input class="text" type="text" name="labelfr" value="<%=labelfr%>" size="50" onblur="limitLength(this);"></td>
    </tr>

    <tr>
      <td class="admin"><%=labelTran%> EN</td>
      <td class="admin2"><input class="text" type="text" name="labelen" value="<%=labelen%>" size="50" onblur="limitLength(this);"></td>
    </tr>
  </table>

  <script>
    function createActivity(){
      if(createForm.activityCode.value.length==0 || createForm.labelnl.value.length==0 ||
         createForm.labelfr.value.length==0 || createForm.labelen.value.length==0){
        alertDialog("web","somefieldsareempty");
        
             if(createForm.activityCode.value == ''){ createForm.activityCode.focus(); }
        else if(createForm.labelnl.value == ''){ createForm.labelnl.focus(); }
        else if(createForm.labelfr.value == ''){ createForm.labelfr.focus(); }
        else if(createForm.labelen.value == ''){ createForm.labelen.focus(); }
      }
      else{
        createForm.action.value = 'createActivity';
        createForm.submit();
      }
    }

    function clearForm(){
      createForm.activityCode.value = '';
      createForm.labelnl.value = '';
      createForm.labelfr.value = '';
      createForm.labelen.value = '';
      createForm.activityCode.focus();
    }

    window.resizeTo(500,210);
    createForm.activityCode.focus();

    <%
        if(action.equals("createActivity") && !activityStored){
          %>alertDialog("web.manage","activityExists");<%
        }
    %>
  </script>

  <%-- BUTTONS --%>
  <p align="center">
    <input class="button" type="button" name="CreateButton" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onClick="createActivity();">&nbsp;
    <input class="button" type="button" name="ClearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="clearForm();">&nbsp;
    <input class="button" type="button" name="buttonclose" value='<%=getTranNoLink("Web","close",sWebLanguage)%>' onclick="window.close();">
  </p>
</form>
</body>