<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/commonFunctions.jsp"%>
<%=sJSPROTOTYPE%>
<%=sJSSTRINGFUNCTIONS%>

<html>
<head>
    <%
        sUserTheme = checkString((String)session.getAttribute("UserTheme"));
        if(sUserTheme.equals("default")) sUserTheme = "";
        if(sUserTheme.length() > 0) sUserTheme = "_"+sUserTheme;
    %>
    <link href="<%=sCONTEXTPATH%>/_common/_css/web<%=sUserTheme%>.css" rel="stylesheet" type="text/css" media="screen">
</head>

<body>
    <br><br>
    <br><br>
    <br><br>
    
<%
	//--- retrieve rules ---
	int minimumChars         = MedwanQuery.getInstance().getConfigInt("PasswordMinimumCharacters"),
	    notReusablePasswords = MedwanQuery.getInstance().getConfigInt("PasswordNotReusablePasswords");
	
	boolean lettersObliged      = MedwanQuery.getInstance().getConfigString("PasswordObligedLetters").equals("on"),
	        uppercaseObliged    = MedwanQuery.getInstance().getConfigString("PasswordObligedUppercase").equals("on"),
	        lowercaseObliged    = MedwanQuery.getInstance().getConfigString("PasswordObligedLowerCase").equals("on"),
	        numbersObliged      = MedwanQuery.getInstance().getConfigString("PasswordObligedNumbers").equals("on"),
	        alfanumericsObliged = MedwanQuery.getInstance().getConfigString("PasswordObligedAlfanumerics").equals("on");
	
	boolean noReuseOfOldPwd = (notReusablePasswords > 0); 
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************* userprofile/changepasswordonly.jsp *****************");
		Debug.println("minimumChars         : "+minimumChars);
		Debug.println("notReusablePasswords : "+notReusablePasswords);
		
		Debug.println("lettersObliged       : "+lettersObliged);
		Debug.println("uppercaseObliged     : "+uppercaseObliged);
		Debug.println("lowercaseObliged     : "+lowercaseObliged);
		Debug.println("numbersObliged       : "+numbersObliged);
		Debug.println("alfanumericsObliged  : "+alfanumericsObliged);
		
		Debug.println("--> noReuseOfOldPwd  : "+noReuseOfOldPwd+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    //--- DISPLAY PASSWORDS -----------------------------------------------------------------------
    if(request.getParameter("SaveUserProfile")==null){
        %>
            <form name='UserProfile' action='<c:url value='/changePassword.do'/>' method='post' onkeydown="if(enterEvent(event,13)){doSubmit();}">
                <input type='hidden' name='SaveUserProfile' value='ok'/>
                <input type='hidden' name='ts' value='<%=getTs()%>'/>
                    
                <table width='100%' align='center' cellspacing="1" class="list">
                    <%-- TITLE --%>
                    <tr class="admin">
                        <td colspan="2">&nbsp;&nbsp;<%=(getTranNoLink("Web.UserProfile","ChangePassword",sWebLanguage))%>&nbsp;</td>
                    </tr>

                    <%-- OldPassword --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutOldPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='OldPassword' class="text" size="25" maxLength="20"></td>
                    </tr>

                    <%-- NewPassword1 --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutNewPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='NewPassword1' class="text" size="25" maxLength="20"></td>
                    </tr>

                    <%-- NewPassword2 --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTranNoLink("Web.UserProfile","PutNewPasswordAgain",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='NewPassword2' class="text" size="25" maxLength="20"></td>
                    </tr>
                </table>

                <%-- SAVE BUTTON --%>
                <%=ScreenHelper.alignButtonsStart()%>
                    <input type='button' name='SaveUserProfile' class="button" value='<%=getTranNoLink("Web.UserProfile","Change",sWebLanguage)%>' OnClick='doSubmit();'>
                <%=ScreenHelper.alignButtonsStop()%>
            </form>

            <%-- CHECK IF FIELDS ARE PROPERLY SUPPLIED WITH DATA --%>
            <script>
              UserProfile.OldPassword.focus();

              <%-- DO SUBMIT --%>
              function doSubmit(){
                if(UserProfile.OldPassword.value.length==0){
                  UserProfile.OldPassword.focus();
                }
                else if(UserProfile.NewPassword1.value.length==0){
                  UserProfile.NewPassword1.focus();
                }
                else if(UserProfile.NewPassword2.value.length==0){
                  UserProfile.NewPassword2.focus();
                }
                else if(UserProfile.NewPassword1.value.length > 250){
                  alertDialog("web.Password","PasswordTooLong");
                  UserProfile.NewPassword1.focus();
                }
                else if(UserProfile.NewPassword2.value.length > 250){
                  alertDialog("web.Password","PasswordTooLong");
                  UserProfile.NewPassword2.focus();
                }
                else{
                  UserProfile.submit();
                }
              }
            </script>
        <%

        //--- DISPLAY APPLIED RULES ---------------------------------------------------------------
        out.print("<p style='font-size:12px;'>");

        // reuse of old password allowed ?
        if(noReuseOfOldPwd){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran(request,"web.userProfile","PasswordNoReuseOfOldPwdAllowed",sWebLanguage).replaceAll("#numberOfPasswords#",Integer.toString(notReusablePasswords))+"<br>");
        }
        
        if(minimumChars > -1){
            String msg = getTran(request,"Web.UserProfile","PasswordMinimumCharactersObliged",sWebLanguage);
            msg = msg.replaceFirst("#minChars#",minimumChars+"");
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(msg+"<br>");
        }

        if(numbersObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran(request,"Web.UserProfile","PasswordNumbersObliged",sWebLanguage)+"<br>");
        }
        
        if(lettersObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran(request,"Web.UserProfile","PasswordLettersObliged",sWebLanguage)+"<br>");
        }

        if(uppercaseObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran(request,"Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)+"<br>");
        }
        
        if(lowercaseObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran(request,"Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)+"<br>");
        }
        
        if(alfanumericsObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran(request,"Web.UserProfile","PasswordAlfanumericsObliged",sWebLanguage)+"<br>");
        }

        out.print("</p>");

        //--- show popup to remind the user to change his password ---
        boolean showReminder = !checkString(request.getParameter("popup")).equals("no");
        if(showReminder){
            %>
                <script>
                  alertDialog("web.password","mustUpdatePasswordNow");
                  UserProfile.OldPassword.focus();
                </script>
            <%
        }
    }
    //--- SAVE PASSWORDS --------------------------------------------------------------------------
    else{
        boolean rulesObeyed = true;
        boolean errorNewPassword = false;
        boolean errorOldPassword = false;
        StringBuffer allErrors = new StringBuffer();
        StringBuffer ruleErrors = new StringBuffer();

        // start table
        allErrors.append("<p align='center'>")
                 .append("<table>")
                 .append("<tr>")
                 .append("<td>")
                 .append("<font color='red'>");

        //--- retrieve passwords ---
        String sOldPassword  = checkString(request.getParameter("OldPassword")),
               sNewPassword  = checkString(request.getParameter("NewPassword1")),
               sNewPassword1 = checkString(request.getParameter("NewPassword2"));

        // reuse of old pwd allowed ?
        if(noReuseOfOldPwd){
            // how many of the used passwords must be considered ?
            int oldPwdCount = 10000; // all
            if(notReusablePasswords > 0){
                oldPwdCount = notReusablePasswords;
            }

            Debug.println("*********** noReuseOfOldPwd : "+noReuseOfOldPwd); ///////////
            Debug.println("*********** oldPwdCount : "+oldPwdCount); ///////////
            Debug.println("*********** sNewPassword1 : "+sNewPassword1); ///////////
            Debug.println("*********** sOldPassword : "+sOldPassword); ///////////
            boolean passwordIsUsedBefore = User.isPasswordUsedBefore(sNewPassword1,activeUser,oldPwdCount);
            Debug.println("*********** -->  passwordIsUsedBefore : "+passwordIsUsedBefore); ///////////

            if(passwordIsUsedBefore || sNewPassword1.equals(sOldPassword)){
                rulesObeyed = false;
                String msg = getTran(request,"web.userProfile","PasswordNoReuseOfOldPwdAllowed",sWebLanguage).replaceAll("#numberOfPasswords#",Integer.toString(notReusablePasswords));
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(msg).append("<br>");
            }
        }
        
        //--- apply rules ---
        // minimum characters
        if(minimumChars > -1){
            if(sNewPassword.length() < minimumChars){
                rulesObeyed = false;
                String msg = getTran(request,"Web.UserProfile","PasswordMinimumCharactersObliged",sWebLanguage);
                msg = msg.replaceFirst("#minChars#",minimumChars+"");
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(msg).append("<br>");
            }
        }

        // numbers obliged && letters obliged
        if(numbersObliged && lettersObliged){
            if(!ScreenHelper.containsNumber(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran(request,"Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLetter(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran(request,"Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // numbers obliged
            if(numbersObliged){
                if(!ScreenHelper.containsNumber(sNewPassword)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran(request,"Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
                }
            }

            // letters obliged
            if(lettersObliged){
                if(!ScreenHelper.containsLetter(sNewPassword)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran(request,"Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
                }
            }
        }

        // uppercase obliged and lowercase obliged
        if(uppercaseObliged && lowercaseObliged){
            if(!ScreenHelper.containsUppercase(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran(request,"Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLowercase(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran(request,"Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // uppercase obliged
            if(uppercaseObliged){
                if(!ScreenHelper.containsUppercase(sNewPassword)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran(request,"Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
                }
            }

            // lowercase obliged
            if(lowercaseObliged){
                if(!ScreenHelper.containsLowercase(sNewPassword)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran(request,"Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)).append("<br>");
                }
            }
        }

        // alfanumerics obliged
        if(alfanumericsObliged){
            if(!ScreenHelper.containsAlfanumerics(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran(request,"Web.UserProfile","PasswordAlfanumericsObliged",sWebLanguage)).append("<br>");
            }
        }

        //--- compare passwords ---
        if(!sNewPassword.equals(sNewPassword1)){
            errorNewPassword = true;
            allErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
            allErrors.append("<b>").append(getTran(request,"Web.UserProfile","ErrorNewPassword",sWebLanguage)).append("</b><br>");
        }
        else{
            byte[] aOldPassword = activeUser.encrypt(sOldPassword);

            if(!activeUser.checkPassword(aOldPassword)){
                errorOldPassword = true;
                allErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                allErrors.append("<b>").append(getTran(request,"Web.UserProfile","ErrorOldPassword",sWebLanguage)).append("</b><br>");
            }
            else{
                if(rulesObeyed && !errorOldPassword && !errorNewPassword){
                    // all OK : store new password in DB
                    byte[] aNewPassword = activeUser.encrypt(sNewPassword);
                    User uUser = new User();
                    uUser.password = aNewPassword;
                    uUser.userid = activeUser.userid;
                    uUser.savePasswordToDB();
                    
                    // also store the new password in session
                    activeUser.password = aNewPassword;
                    session.setAttribute("activeUser", activeUser);
                    
                    //*** 2 : set the updatetime to now when the password is used before, otherwise add the new password ***
                    String sSql = "UPDATE UsedPasswords SET updatetime = ?"+
                   	              " WHERE userId = ?"+
                                  "  AND CAST(encryptedPassword AS BINARY) = ?";
                    Connection conn = MedwanQuery.getInstance().getAdminConnection();
                    PreparedStatement ps = conn.prepareStatement(sSql);
                    ps.setTimestamp(1,getSQLTime()); // now
                    ps.setInt(2,Integer.parseInt(activeUser.userid));
                    ps.setBytes(3,activeUser.encrypt(sNewPassword1));
                    int updatedRecords = ps.executeUpdate();
                    ps.close();
                    conn.close();
                    
                    if(updatedRecords==0){                
                    	sSql = "INSERT INTO UsedPasswords(usedPasswordId,encryptedPassword,userId,updatetime,serverid)"+
                               " VALUES (?,?,?,?,?)";
                        conn = MedwanQuery.getInstance().getAdminConnection();
                        ps = conn.prepareStatement(sSql);
                        ps.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("UsedPasswords"));
                        ps.setBytes(2,activeUser.encrypt(sNewPassword1));
                        ps.setInt(3,Integer.parseInt(activeUser.userid));
                        ps.setTimestamp(4,getSQLTime()); // now
                        ps.setInt(5,MedwanQuery.getInstance().getConfigInt("serverId"));
                        ps.executeUpdate();
                        ps.close();
                        conn.close();
                    }
                    
                    // let user remember when he last changed his password
                    Parameter pwdChangeParam = new Parameter("pwdChangeDate",System.currentTimeMillis()+"");
                    activeUser.updateParameter(pwdChangeParam);

                    // display how long the password remains valid
                    int availability;
                    try{ availability = Integer.parseInt(MedwanQuery.getInstance().getConfigString("PasswordAvailability")); }
                    catch(NumberFormatException e1){ availability = -1; }

                    if(availability > 0){
                        String msg = getTran(request,"Web.UserProfile","PasswordAvailability",sWebLanguage);
                        msg = msg.replaceFirst("#validDays#",availability+"");

                        // go to userprofile indexpage with a message
				        if(request.getRequestURL().indexOf("main")>-1){
				        	allErrors.append("&msg=");
				        }
                        allErrors.append(msg);
                    }

			        if(request.getRequestURL().indexOf("main")>-1){
			        	allErrors.append("'</script>");
			        }
                }
            }
        }

        //--- back button ---
        StringBuffer backButton = new StringBuffer();
        if(rulesObeyed && !errorOldPassword && !errorNewPassword){
        	// OK, go to main page
	        backButton.append("<input type='button' class='button' value='").append(getTranNoLink("Web","back",sWebLanguage)).append("' ")
	                  .append("onclick='window.location.href=\""+sCONTEXTPATH+"/main.do\"'");
        }
        else{
        	// not OK, revert to password page
        	backButton.append("<input type='button' class='button' value='").append(getTranNoLink("Web","back",sWebLanguage)).append("' ")
                      .append("onclick='window.location.href=\""+sCONTEXTPATH+"/changePassword.do?popup=no\"'");
        }

        //--- display errors ---
        // end table
        allErrors.append(ruleErrors)
                 .append("<br>")
                 .append("</font>")
                 .append("</td>")
                 .append("</tr>")
                 .append("<tr><td align='center'>"+backButton+"</td></tr>")
                 .append("</table>")
                 .append("</p>");

        out.print(allErrors);
    }
%>
</body>
</html>