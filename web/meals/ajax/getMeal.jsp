<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.Meal,
                be.openclinic.meals.MealItem,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sMealId = checkString(request.getParameter("mealId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************************ meals/ajax/getMeal.jsp ************************");
    	Debug.println("sMealId : "+sMealId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Meal item = new Meal(sMealId);
    if(sMealId.length() > 0 && !sMealId.equals("-1")){
        item = Meal.get(item);
    }
%>

<div id="mealEdit" style="width:514px">
    <table class="list" cellspacing="1" cellpadding="1" width="100%" onKeyDown="if(enterEvent(event,13)){setMeal();return false;}">
        <%-- MEAL NAME --%>
        <tr>
            <td class="admin" width="150px"><%=HTMLEntities.htmlentities(getTran(request,"meals","name",sWebLanguage))%></td>
            <td class="admin2">
                <input class="text" style="width:200px" type="text" name="mealName" id="mealName" value="<%=checkString(HTMLEntities.htmlentities(item.name))%>"/>
            </td>
        </tr>
        
        <%-- MEAL ITEMS --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"meals","mealItems",sWebLanguage))%></td>
            <td class="admin2">
                <a href="javascript:void(0)" class="link add" onclick="searchMealItem();"><%=HTMLEntities.htmlentities(getTran(request,"meals","addMealItem",sWebLanguage))%></a>
                <br/>
                
                <ul id="mealItemList" class="items" style="width:380px">
                    <%
                        Iterator iter = item.mealItems.iterator();
                        MealItem mealitem;
                        while(iter.hasNext()){
                            mealitem = (MealItem)iter.next();
                            out.write("<script>insertMealItem('"+mealitem.getUid()+"','"+mealitem.name+"','"+mealitem.unit+"','"+mealitem.quantity+"');</script>");
                        }
                    %>
                </ul>
            </td>
        </tr>
        
        <%-- MEAL NUTRICIENTS --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran(request,"meals","mealNutricients",sWebLanguage))%></td>
            <td class="admin2">
                <a href="javascript:void(0)" id="mealNutricientsButton" class="link down" onclick="getNutricientsInMeal(true);"><%=getTranNoLink("meals","seeMealNutricients",sWebLanguage)%></a>&nbsp;&nbsp;&nbsp;
                <a href="javascript:void(0)" id="mealNutricientsRefresh" class="link reload" style="display:none;" onclick="getNutricientsInMeal();"><%=getTranNoLink("meals","reloadMealNutrients",sWebLanguage)%></a>
                <ul id="mealNutricientList" class="items" style="display:none;width:380px"></ul>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="hidden" id="mealId" value="<%=checkString(item.getUid())%>"/>
                <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","save",sWebLanguage))%>" onclick="setMeal();">&nbsp;&nbsp;
                <%
                    if(!item.getUid().equalsIgnoreCase("-1")){
                	    %><input type="button" class="button" name="deleteButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteMeal('<%=item.getUid()%>');">&nbsp;&nbsp;<%
                    }
                %>                
                <input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
            </td>
        </tr>
    </table>
</div>

<div id="mealItemsList" style="width:500px">&nbsp;</div>