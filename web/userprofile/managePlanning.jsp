<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp" %>
<%@include file="/includes/validateUser.jsp" %>
<%String sAction = checkString(request.getParameter("Action"));
    String sEditFrom = checkString(request.getParameter("EditFrom"));
    String sEditUntil = checkString(request.getParameter("EditUntil"));
    String sEditUserIDs = checkString(request.getParameter("EditUserIDs"));
    String sEditExamDuration = checkString(request.getParameter("PlanningExamDuration"));
    String sEditZoom = checkString(request.getParameter("EditZoom"));
    String sEditDoubleBookingProhibited = checkString(request.getParameter("PlanningDoubleBookingProhibited"));

    //--- DISPLAY ---------------------------------------------------------------------------------
    if (sAction.length() == 0) {
        sEditFrom = checkString(activeUser.getParameter("PlanningFindFrom"));
        if (sEditFrom.length() == 0) {
            sEditFrom = 8 + "";
        }
        sEditUntil = checkString(activeUser.getParameter("PlanningFindUntil"));
        if (sEditUntil.length() == 0) {
            sEditUntil = 20 + "";
        }
        sEditExamDuration = checkString(activeUser.getParameter("PlanningExamDuration"));
        if (sEditExamDuration.length() == 0) {
            sEditExamDuration = 30 + "";
        }
        sEditUserIDs = checkString(activeUser.getParameter("PlanningFindUserIDs"));
        sEditDoubleBookingProhibited=checkString(activeUser.getParameter("PlanningDoubleBookingProhibited"));
        sEditZoom = checkString(activeUser.getParameter("PlanningFindZoom"));
        if (sEditZoom.length() == 0) {
            sEditZoom = 40 + "";
        }

     long iZoom = Math.round(Double.parseDouble(sEditZoom));
%>
<%=sCSSWEEKPLANNER%>
<form name="formEdit" id="formEdit" method='post'>
    <input type="hidden" name="Action" value="save"/>
    <input type="hidden" name="EditFrom" id="EditFrom" value="<%=sEditFrom%>"/>
    <input type="hidden" name="EditUntil" id="EditUntil" value="<%=sEditUntil%>"/>
    <input type="hidden" name="EditZoom" id="EditZoom" value="<%=sEditZoom%>"/>
    <%=writeTableHeader("Web.UserProfile", "managePlanning", sWebLanguage, " doBack();")%>
    <table width='100%' cellspacing="1" cellpadding="0" class="list">
        <tr>
            <%-- EXAM_DURATION --%>
            <td class="admin"><%=getTran(request,"web", "examduration", sWebLanguage)%>
            </td>
            <td class="admin2">
                <select class='text' name="PlanningExamDuration" id="PlanningExamDuration" size="1">
                    <%
                        for(int i=5;i<125;i=i+5){
                            out.write("<option value='"+i+"' "+((Integer.parseInt(sEditExamDuration)==i)?"selected=selected":"")+">"+i+"</option>");
                        }
                    %>
                </select> <%=getTran(request,"web.occup", "medwan.common.minutes", sWebLanguage)%>
            </td>
        </tr>
        <%
        	if(SH.cs("calendarVersion","1").equalsIgnoreCase("1")){
        %>
        <tr>
            <%-- DOUBLE BOOKING PROHIBITED --%>
            <td class="admin"><%=getTran(request,"web", "doublebookingprohibited", sWebLanguage)%>
            </td>
            <td class="admin2">
            	<input type='checkbox' style="margin-left:30px;margin-right:10px;" name='PlanningDoubleBookingProhibited' id='PlanningDoubleBookingProhibited' <%=sEditDoubleBookingProhibited.equalsIgnoreCase("1")?"checked":"" %> value="1"/>
            </td>
        </tr>
        <%
        	}
        %>
        <tr>
            <td class="admin"><%=getTran(request,"planning","users_with_permission",sWebLanguage)%></td>
            <td class="admin2">
				<table width='100%'>
					<tr>
						<td>
							<input type='hidden' name='userid' id='userid' value=''/>
							<input type='text' class='text' size='30' name='username' id='username' readonly value=''/>
							<img style='vertical-align: middle' src='<%=sCONTEXTPATH %>/_img/icons/icon_search.png' onclick='searchPlanningUser()'/>
							<img style='vertical-align: middle' src='<%=sCONTEXTPATH %>/_img/icons/icon_delete.png' onclick='document.getElementById("userid").value="";document.getElementById("username").value="";'/>
							<input type='checkbox' class='text' name='useredit' id='useredit'/><%=getTran(request,"agenda","edit",sWebLanguage) %>
							<input type='checkbox' class='text' name='useradd' id='useradd'/><%=getTran(request,"agenda","add",sWebLanguage) %>
							<input type='button' onclick='addUser();' class='button' name='addButton' value='<%=getTran(request,"web","add",sWebLanguage) %>'/>
						</td>
					</tr>
					<tr id='trusers'>
					</tr>
				</table>
            </td>
        </tr>
		<!-- 
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran(request,"planning", "users_with_permission", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="hidden" name="EditUserIDs" value="<%=sEditUserIDs%>">
                <input type="hidden" name="EditUserID">
                <input style="margin-left:30px;" class="text" type="text" name="EditUserName" readonly size="<%=sTextWidth%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPlanningUser()">
                <img src="<c:url value="/_img/icons/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="doAdd()">
                <br>
                <table style="margin-left:30px;" id="tableUsers">
                    <tr height="1">
                        <td width="20"/>
                    </tr>
                    <%if (sEditUserIDs.length() > 0) {
                        String[] aUserIDs = sEditUserIDs.split(";");
                        String sUserName;
                        for (int i = 0; i < aUserIDs.length; i++) {
                            if (aUserIDs[i].length() > 0) {
                                sUserName = ScreenHelper.getFullUserName(aUserIDs[i]);%>
                    <tr id='tr<%=aUserIDs[i]%>'>
                        <td>
                            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete('tr<%=aUserIDs[i]%>',this.parentNode.parentNode.rowIndex)">
                        </td>
                        <td><%=sUserName%>
                        </td>
                    </tr>
                    <%		}
                    	}
                    }%>
                </table>
            </td>
        </tr>
         -->
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"hrm", "uur", sWebLanguage)%>
            </td>
            <td class="admin2">
                <br/> <br/>
                <div id="zoom-track" style="margin-left:30px;width:500px;" class="slider" >
                    <div id="schedulebegin" class="handle" ><span style="left:-35px;width:80px;"><%=getTranNoLink("web", "begin", sWebLanguage)%> <%=sEditFrom%> h</span>
                    </div>
                    <div id="scheduleend" class="handle"><span style="left:5px;width:80px;"><%=getTranNoLink("web", "end", sWebLanguage)%> <%=sEditUntil%> h</span>
                    </div>
                    <div id="zoom-track-selected" class="zoom-track-selected">&nbsp;</div>
                </div>
                <br/>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web.UserProfile", "agenda.zoom", sWebLanguage)%>
            </td>
            <td class="admin2">
                <div id="zoom_slider" style="margin-left:30px;" class="slider" style="width:200px;">
                    <div id="zoom_handle" class="handle">&nbsp;</div>
                </div>
                <br/>
                <div id="weekScheduler_container" style="margin-left:30px;width:580px;">
                    <div id="weekScheduler_top">
                         <div class="spacer"><span></span>
                    </div>
                    <div class="days" id="weekScheduler_dayRow">
                        <div><%=getTran(request,"web", "monday", sWebLanguage)%><span></span></div>
                        <div><%=getTran(request,"web", "Tuesday", sWebLanguage)%><span></span></div>
                        <div><%=getTran(request,"web", "Wednesday", sWebLanguage)%><span></span></div>
                        <div><%=getTran(request,"web", "Thursday", sWebLanguage)%><span></span></div>
                    </div>
                </div>
                    <div id="weekScheduler_hours">
                        <div id="calendarContentTime1" style="line-height:<%=iZoom%>px;height:<%=iZoom%>px" class='content_hour'>8:<span id="content_hour1" style="line-height:<%=iZoom%>px;" class="content_hour">00</span>
                        </div>
                        <div id="calendarContentTime2" style="line-height:<%=iZoom%>px;height:<%=iZoom%>px" class='content_hour'>9:<span id="content_hour2" style="line-height:<%=iZoom%>px;" class="content_hour">00</span>
                        </div>
                    </div>
                    <div id="weekScheduler_appointments">
                        <% for (int i = 0; i < 4; i++) {    // Looping through the days of a week
                            out.write("<div class='weekScheduler_appointments_day' >");
                            out.write("<div id='weekScheduler_appointment_hour_1_" + i + "' class='weekScheduler_appointmentHour' style='height:" + (iZoom) + "'><span class='line' id='line_1_"+i+"' style='height:"+((iZoom/2)-2)+"'>&nbsp;</span></div>\n");
                            out.write("<div id='weekScheduler_appointment_hour_2_" + i + "' class='weekScheduler_appointmentHour' style='height:" + (iZoom) + "'><span class='line' id='line_2_"+i+"' style='height:"+((iZoom/2)-2)+"'>&nbsp;</span></div>\n");
                            out.write("</div>");
                        } %>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;</td><td class="admin2"> <div id="updateByAjax" style="margin-left:30px;">&nbsp;</div>
                <input style="margin-left:30px;" type='button' name='saveButton' class="button" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onClick="doSubmit();">
                <input type='button' name='backButton' class="button" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' OnClick='doBack();'>
            </td>
        </tr>
    </table>
    <script>
        setSlider = function() {
            //----  ZOOM  ---------//
            var box = $("calendarContentTime1");
            var box2 = $("calendarContentTime2");

            new Control.Slider("zoom_handle", "zoom_slider", {
                range: $R(60, 250),
                sliderValue: <%=sEditZoom%>,
                onSlide: function(value) {
                    box.setStyle({ height: value + 'px',lineHeight:value + 'px' });
                    box2.setStyle({ height: value + 'px',lineHeight:value + 'px'  });
                    $("content_hour1").setStyle({ lineHeight:value + 'px' });
                    $("content_hour2").setStyle({ lineHeight:value + 'px' });
                    var value2 = (value/2)-2;
                    for (var i = 0; i <= 4; i++) {
                        if ($("weekScheduler_appointment_hour_1_" + i)) {
                            $("weekScheduler_appointment_hour_1_" + i).setStyle({ height: value + 'px',lineHeight:value + 'px' });
                            $("weekScheduler_appointment_hour_2_" + i).setStyle({ height: value + 'px',lineHeight:value + 'px'  });

                            $("line_1_" + i).setStyle({ height: value2 + 'px',lineHeight:value2 + 'px'  });
                            $("line_2_" + i).setStyle({ height: value2 + 'px',lineHeight:value2 + 'px'  });
                        }
                    }
                },
                onChange: function(value) {
                    $("EditZoom").value = value;
                }
            });

        //----  Day part time ------//
            var begin = "schedulebegin";
            var end = "scheduleend";
            new Control.Slider([begin,end], 'zoom-track', {
                sliderValue:['<%=sEditFrom%>','<%=sEditUntil%>'], range:$R(0, 23.30),

                values:[<% for(int i=0;i<24;i++){out.write(""+i+","+i+".15,"+i+".30,"+i+".45"+((i<23)?",":""));}%>],
                restricted:true,
                spans:['zoom-track-selected'],
                onSlide: function(values) {
                    $(begin).firstChild.innerHTML = ("<%=getTranNoLink("web","begin",sWebLanguage)%> " + ((needZero(values[0]))?values[0]+"0":values[0]) + " h");
                    $(end).firstChild.innerHTML = ("<%=getTranNoLink("web","end",sWebLanguage)%> " + ((needZero(values[1]))?values[1]+"0":values[1]) + " h");
                },
                onChange: function(values) {
                    $("EditFrom").value = ((needZero(values[0]))?values[0]+"0":values[0]);
                    $("EditUntil").value = ((needZero(values[1]))?values[1]+"0":values[1]);
                }
            });
        }
        var needZero = function(number) {
           try {
             return (number.toString().indexOf(".3") != -1);
           } catch (ex) { return false; }
        }
        <%-- CHECK TIME OUT --%>
        function doSubmit() {
            $("updateByAjax").innerHTML = "<div class='wait'><img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/></div>";
            var params = Form.serialize("formEdit");
            new Ajax.Updater("updateByAjax", "<%=sCONTEXTPATH%>/userprofile/managePlanning.jsp?ts=<%=getTs()%>", {parameters:params,evalScripts:true});
       }
        function searchPlanningUser() {
            openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID=userid&ReturnName=username&PopupWidth=600");
        }
  		function addUser(){
  			var rights="";
  			if(document.getElementById('useredit').checked){
  				rights+="u";
  			}
  			if(document.getElementById('useradd').checked){
  				rights+="c";
  			}
  			var params=	"userid="+document.getElementById('userid').value+"&rights="+rights;
  			var url = "<%=sCONTEXTPATH%>/userprofile/addAgendaUser.jsp";
  			new Ajax.Request(url,{
  				method: "POST",
  				parameters: params,
  				onSuccess: function(resp){
  			    	loadUsers();
  				}
  			});
  		}

  		function deleteUser(id){
  			var params=	"userid="+id;
  			var url = "<%=sCONTEXTPATH%>/userprofile/deleteAgendaUser.jsp";
  			new Ajax.Request(url,{
  				method: "POST",
  				parameters: params,
  				onSuccess: function(resp){
  			    	loadUsers();
  				}
  			});
  		}

  		function loadUsers(){
  			var params="";
  			var url = "<%=sCONTEXTPATH%>/userprofile/loadAgendaUsers.jsp";
  			new Ajax.Request(url,{
  				method: "POST",
  				parameters: params,
  				onSuccess: function(resp){
  			    	document.getElementById('trusers').innerHTML=resp.responseText;
  				}
  			});
  		}

  		function doAdd() {
            var array = formEdit.EditUserIDs.value.split(";");
            var bExist = false;
            for (var i = 0; i < array.length; i++) {
                if (array[i] == formEdit.EditUserID.value) {
                    bExist = true;
                }
            }
            if (!bExist) {
                formEdit.EditUserIDs.value += ";" + formEdit.EditUserID.value;
                var tr = tableUsers.insertRow(tableUsers.rows.length);
                tr.id = "tr" + formEdit.EditUserID.value;
                var td = tr.insertCell(0);
                td.innerHTML = "<img src='<c:url value="/_img/icons/icon_delete.png"/>' class='link' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick='doDelete(\"tr" + formEdit.EditUserID.value + "\",this.parentNode.parentNode.rowIndex)'>";
                tr.appendChild(td);
                td = tr.insertCell(1);
                td.innerHTML = formEdit.EditUserName.value;
                tr.appendChild(td);
            }
            formEdit.EditUserID.value = "";
            formEdit.EditUserName.value = "";
        }
        function doDelete(id, index) {
            if (confirm("<%=getTran(null,"Web","AreYouSure",sWebLanguage)%>")) {
                formEdit.EditUserIDs.value = deleteRowFromArrayString(formEdit.EditUserIDs.value, id);
                tableUsers.deleteRow(index);
            }
        }
        function deleteRowFromArrayString(sArray, rowid) {
            rowid = rowid.substring(2);
            var array = sArray.split(";");
            for (var i = 0; i < array.length; i++) {
                if (array[i].indexOf(rowid) > -1) {
                    array.splice(i, 1);
                }
            }
            return array.join(";");
        }
        setSlider();
    function doBack() {
        window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
    }
   	loadUsers();
    </script>
</form>
<%}
//--- SAVE AND RETURN TO INDEX ----------------------------------------------------------------
else if (sAction.equals("save")) {
    try{
    Parameter parameter = new Parameter("PlanningFindFrom", sEditFrom, activeUser.userid);
    activeUser.removeParameter("PlanningFindFrom");
    activeUser.updateParameter(parameter );
    activeUser.parameters.add(parameter);
    parameter = new Parameter("PlanningFindUntil", sEditUntil, activeUser.userid);
    activeUser.removeParameter("PlanningFindUntil");
    activeUser.updateParameter(parameter);
    activeUser.parameters.add(parameter);
    parameter = new Parameter("PlanningFindZoom", sEditZoom, activeUser.userid);
    activeUser.removeParameter("PlanningFindZoom");
    activeUser.updateParameter(parameter);
    activeUser.parameters.add(parameter);
    parameter = new Parameter("PlanningFindUserIDs", sEditUserIDs, activeUser.userid);
    activeUser.removeParameter("PlanningFindUserIDs");
    activeUser.updateParameter(parameter);
    activeUser.parameters.add(parameter);
    parameter = new Parameter("PlanningDoubleBookingProhibited", sEditDoubleBookingProhibited, activeUser.userid);
    activeUser.removeParameter("PlanningDoubleBookingProhibited");
    activeUser.updateParameter(parameter);
    activeUser.parameters.add(parameter);
    parameter = new Parameter("PlanningExamDuration", sEditExamDuration, activeUser.userid);
    activeUser.removeParameter("PlanningExamDuration");
    activeUser.updateParameter(parameter);
    activeUser.parameters.add(parameter);
    session.setAttribute("activeUser", activeUser);
    out.write("<span class='valid'>"+
                   "<img src='"+sCONTEXTPATH+"/_img/themes/default/valid.gif' style='vertical-align:-3px;'>&nbsp;"+
                   HTMLEntities.htmlentities(getTranNoLink("web","dataissaved",sWebLanguage))+
                  "</span><script>if($('tabpatient')){setTimeout('window.location.reload()',500);}else{formFindUser.submit();}</script>");
    }
    catch(Exception e){
        out.write("<span class='error'>"+
                   "<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px;'>&nbsp;"+
                   HTMLEntities.htmlentities(getTranNoLink("Web.Control", "dberror", sWebLanguage))+
                   "<br>"+e.getMessage()+
                  "</span>");
    }
    // return to userprofile index%>
<%}%>