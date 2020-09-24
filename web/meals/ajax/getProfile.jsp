<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.MealProfile,
                be.openclinic.meals.MealItem,
                be.openclinic.meals.Meal,
                java.util.Date,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- GET HOURS FIELD -------------------------------------------------------------------------
    public String getHoursField(String id, Date date, String sWebLanguage){
	    String sOut = getTran(null,"meals","at",sWebLanguage)+"&nbsp;";
	    
	    // hours
	    sOut+= "<select id='mealHour_"+id+"' style='width:40px' class='text'>";
	    for(int i=0; i<=23; i++){
	        sOut+= "<option value="+i+" "+(date.getHours()==i?"selected ":"")+">"+(i<10?"0"+i:""+i)+"</option>";
	    }
	    sOut+= "</select>:";
	    
	    // minutes
	    sOut+= "<select id='mealMin_"+id+"' style='width:40px' class='text'>";
	    for(int i=0; i<=59; i+=5){
	        sOut+= "<option value="+i+" "+(date.getMinutes()==i?"selected ":"")+">"+(i<10?"0"+i:""+i)+"</option>";
	    }
	    
	    return sOut+"</select>";
	}
%>

<%
    String sProfileId = checkString(request.getParameter("profileId"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n*********************** meals/ajax/getProfile.jsp *********************");
		Debug.println("sProfileId : "+sProfileId+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    MealProfile profile = null;
	if(sProfileId.equals("-1")){
		profile = new MealProfile();	
	}
	else{
		profile = MealProfile.getProfile(sProfileId);
	}
%>

<div id="profileEdit" style="width:514px">
    <table class="list" cellspacing="1" cellpadding="1" width="100%" onKeyDown="if(enterEvent(event,13)){setProfile();return false;}">
        <%-- PROFILE NAME --%>
        <tr>
            <td class="admin" width="100"><%=HTMLEntities.htmlentities(getTran(request,"meals","name",sWebLanguage))%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input class="text" style="width:200px" type="text" name="profileName" id="profileName" value="<%=checkString(HTMLEntities.htmlentities(profile.name))%>"/>
            </td>
        </tr>
        
        <%-- PROFILE ITEMS (MEALS) --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"meals","profileItems",sWebLanguage))%></td>
            <td class="admin2">
                <a href="javascript:void(0)" class="link add" onclick="searchMeal();"><%=HTMLEntities.htmlentities(getTran(request,"web","add",sWebLanguage)+" "+getTranNoLink("meals","meal",sWebLanguage))%></a>
                <br>
                
                <ul id="profileItemList" class="items" style="width:380px">
                    <%
                        List profiles = profile.getProfileMeals();
                        Iterator iter = profiles.iterator();
                        while(iter.hasNext()){
                            profile = (MealProfile)iter.next();
                            
                            out.write("<li id='meal_"+profile.mealUid+"'>"+
                                       "<div style='width:35px'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' class='link' title='"+getTranNoLink("web","delete",sWebLanguage)+"' onclick='removeMealFromProfile(\""+profile.mealUid+"\");'></div>"+
                                       "<div style='width:120px'>"+getHoursField(profile.mealUid,profile.mealDatetime,sWebLanguage)+"</div>"+
                              		   "<div style='width:190px'>"+HTMLEntities.htmlentities(profile.mealName)+"</div>"+
                                      "</li>");
                        }
                    %>
                </ul>
            </td>
        </tr>
        
        <%-- PROFILE NUTRICIENTS --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"meals","nutricients",sWebLanguage))%></td>
            <td class="admin2">
                <a href="javascript:void(0)" id="profileNutricientsButton" class="link down" onclick="getNutricientsInProfile(true);"><%=getTranNoLink("meals","seeNutricients",sWebLanguage)%></a>&nbsp;&nbsp;&nbsp;
                <ul id="profileNutricientsList" class="items" style="display:none;width:380px"></ul>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="hidden" id="profileId" value="<%=checkString(profile.getUid())%>"/>
                <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","save",sWebLanguage))%>" onclick="setProfile();">&nbsp;
                <%
                    if(!profile.getUid().equalsIgnoreCase("-1")){
                    	%><input class="button" type="button" name="deleteButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteProfile('<%=profile.getUid()%>');">&nbsp;<%
                    }
                %>
                <input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">                
            </td>
        </tr>
    </table>
</div>

<div id="mealItemsList" style="width:500px">&nbsp;</div>