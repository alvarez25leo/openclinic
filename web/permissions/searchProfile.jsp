<%@page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"system.permissions","select",activeUser)%>
<%=checkPermission(out,"permissions.usersPerProfile","select",activeUser)%>

<%
    String sFindProfileID   = checkString(request.getParameter("FindProfileID")),
           sFindApplication = checkString(request.getParameter("FindApplication")),
           sOrderField      = checkString(request.getParameter("OrderField"));

    String sTmpProfileID, sTmpProfileName, sProfiles = "", sProfileName = "";

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* permissions/searchProfile.jsp ********************");
    	Debug.println("sFindProfileID   : "+sFindProfileID);
    	Debug.println("sFindApplication : "+sFindApplication);
    	Debug.println("sOrderField      : "+sOrderField+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Vector vUserProfiles = UserProfile.getUserProfiles();
    Iterator iter = vUserProfiles.iterator();

    UserProfile userProfile;
    while(iter.hasNext()){
        userProfile = (UserProfile)iter.next();
        sTmpProfileID = Integer.toString(userProfile.getUserprofileid());
        sTmpProfileName = userProfile.getUserprofilename();

        sProfiles+= "<option value='"+sTmpProfileID+"'";
        if(sFindProfileID.equals(sTmpProfileID)){
            sProfiles+= " selected";
            sProfileName = sTmpProfileName;
        }

        sProfiles+= ">"+sTmpProfileName+"</option>";
    }
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="OrderField" value="">

    <%-- PAGE TITLE --%>
    <%=writeTableHeader("Web.UserProfile","usersPerProfile",sWebLanguage," doBack();")%>

    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
        <%-- PROFILE --%>
        <tr>
            <td width="<%=sTDAdminWidth%>" class="admin2"><%=getTran(request,"Web.UserProfile","UserProfile",sWebLanguage)%></td>
            <td class="admin2">
                <select name="FindProfileID" class="text" onchange="transactionForm.FindApplication.selectedIndex = -1;transactionForm.submit();"><option/>
                    <%=sProfiles%>
                </select>
            </td>
        </tr>

        <%-- APPLICATION --%>
        <tr>
            <td class="admin2"><%=getTran(request,"Web","Applications",sWebLanguage)%></td>
            <td class="admin2">
                <select name="FindApplication" class="text" onChange="transactionForm.FindProfileID.selectedIndex = -1;transactionForm.submit();">
                    <option/>
                    <%
                        Hashtable hScreens = new Hashtable();
                        hScreens.put("administration", getTran(request,"Web","Administration",sWebLanguage));
                        hScreens.put("agenda",getTran(request,"Web","agenda",sWebLanguage));
                        hScreens.put("medicalrecord",getTran(request,"Web","medicalrecord",sWebLanguage));

                        String sScreen, sKey;
                        Enumeration e = hScreens.keys();
                        Hashtable hSorted = new Hashtable();
                        SortedSet set = new TreeSet();

                        // sort
                        while(e.hasMoreElements()){
                            sKey = (String)e.nextElement();
                            sScreen = (String)hScreens.get(sKey);
                            set.add(sScreen);
                            hSorted.put(sScreen,sKey);
                        }

                        Iterator it = set.iterator();
                        while (it.hasNext()){
                            sScreen = (String) it.next();
                            sKey = (String) hSorted.get(sScreen);

                            %><option value="<%=sKey%>"<%

                            if(sFindApplication.equals(sKey)){
                                sProfileName = sScreen;
                                %> selected<%
                            }

                            %>><%=sScreen%></option><%
                        }
                    %>
                </select>
            </td>
        </tr>
    </table>
</form>

<%
    if(sFindProfileID.length()>0 || sFindApplication.length()>0){
        %>
            <%-- PRINT BUTTON top --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" value="<%=getTranNoLink("Web.Occup","medwan.common.print",sWebLanguage)%>" class="button" onclick="doPrint();">
            <%=ScreenHelper.alignButtonsStop()%>

            <span id="printtable">
                <span class="menu"><b><%=sProfileName%></b></span>
 
                <table width="100%" class="menu" cellspacing="1" cellpadding="0">
                    <%-- HEADER : clickable --%>
                    <tr class="admin">
                        <td width="<%=sTDAdminWidth%>">
                            <span class="hand" onClick="transactionForm.OrderField.value='searchname';transactionForm.submit();">
                                <u><%=getTran(request,"Web","Name",sWebLanguage)%></u>
                            </span>
                        </td>

                        <td>
                            <u><%=getTran(request,"Web","service",sWebLanguage)%></u>
                        </td>

                        <td width="*">
                            <span class="hand" onClick="transactionForm.OrderField.value='userid';transactionForm.submit();">
                               <u><%=getTran(request,"Web.occup","medwan.authentication.login",sWebLanguage)%></u>
                            </span>
                        </td>
                    </tr>

                    <%
                        String sPersonID, sLastname, sFirstname, sLogin, sClass = "", sOldPersonID = "", sService="";
                        boolean bOK = false;
                        Vector vProfileOwners = new Vector();
                        if(sFindProfileID.length()>0){
                            vProfileOwners = UserProfile.getProfileOwnersByProfileId(sFindProfileID,sOrderField);
                            bOK = true;
                        }
                        else if(sFindApplication.length()>0){
                            vProfileOwners = UserProfile.getProfileOwnersByApplication(sFindApplication,sOrderField);
                            bOK = true;
                        }

                        if(bOK){
                            %><tbody class="hand"><%
                            		
                            Iterator iterator = vProfileOwners.iterator();
                            Hashtable hOwnerProfile;
                            while(iterator.hasNext()){
                                hOwnerProfile = (Hashtable)iterator.next();
                                sPersonID  = (String)hOwnerProfile.get("personid");
                                sLastname  = (String)hOwnerProfile.get("lastname");
                                sFirstname = (String)hOwnerProfile.get("firstname");
                                sLogin     = (String)hOwnerProfile.get("userid");

                                if(!sPersonID.equals(sOldPersonID)){
                                    sOldPersonID = sPersonID;
                                    sLastname+= " "+sFirstname;
                                    User user = User.get(Integer.parseInt(sLogin));
                                   	Service service = Service.getService(user.getParameter("defaultserviceid"));
                                   	if(service!=null){
                                   		sService = service.getLabel(sWebLanguage);
                                   	}
                                   	else{
                                   		sService="";
                                   	}

                                    // alternate row styles
                                    if(sClass.equals("")) sClass = "1";
                                    else                  sClass = "";

                                    %>
                                        <tr class="list<%=sClass%>" onclick="window.location.href = '<%=sCONTEXTPATH%>/main.do?Page=/permissions/userpermission.jsp&PersonID=<%=sPersonID%>&ts=<%=getTs()%>';">
                                            <td><%=sLastname%></td>
                                            <td width="1%" nowrap><%=sService%></td>
                                            <td><%=sLogin%></td>
                                        </tr>
                                    <%
                                }
                            }
                            %></tbody><%
                        }
                    %>
                </table>
            </span>

            <%-- BUTTONS at bottom --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" class="button" name="printButtonBottom" value="<%=getTranNoLink("Web.Occup","medwan.common.print",sWebLanguage)%>" onclick="doPrint();">
                <input type="button" class="button" name="backButton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' OnClick="doBack();">&nbsp;
            <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>

<script>
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/print.jsp&Field=printtable&ts=<%=getTs()%>");
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=permissions/index.jsp";
  }
</script>