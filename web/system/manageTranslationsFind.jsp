<%@page import="java.util.Vector,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"system.management","select",activeUser)%>
<%
    // get values from form
    String findLabelID    = checkString(request.getParameter("FindLabelID")),
           findLabelType  = checkString(request.getParameter("FindLabelType")),
           findLabelLang  = checkString(request.getParameter("FindLabelLang")),
           findExactID  = checkString(request.getParameter("FindExactID")),
           findExactValue  = checkString(request.getParameter("FindExactValue")),
           findLabelValue = checkString(request.getParameter("FindLabelValue"));

    // exclusions on labeltype
    boolean excludeServices  = checkString(request.getParameter("excludeServices")).equals("true"),
            excludeFunctions = checkString(request.getParameter("excludeFunctions")).equals("true");

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n***************** system/manageTranslationsFind.jsp *******************");
    	Debug.println("findLabelID      : "+findLabelID);
    	Debug.println("findLabelType    : "+findLabelType);
    	Debug.println("findLabelLang    : "+findLabelLang);
    	Debug.println("findLabelValue   : "+findLabelValue);
    	Debug.println("findExactValue   : "+findExactValue);
    	Debug.println("findExactID      : "+findExactID);
    	Debug.println("excludeServices  : "+excludeServices);
    	Debug.println("excludeFunctions : "+excludeFunctions+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // compose query
    Vector vLabels = Label.findFunction_manageTranslationsPage(ScreenHelper.checkDbString(findLabelType).toLowerCase(),
                                                               ScreenHelper.checkDbString(findLabelID).toLowerCase(),
                                                               ScreenHelper.checkDbString(findLabelLang).toLowerCase(),
                                                               ScreenHelper.checkDbString(findLabelValue).toLowerCase(),
                                                               excludeFunctions,excludeServices);
    String sLabelType, sLabelID, sLabelLang, sLabelValue, sClass = "";
    StringBuffer foundLabels = new StringBuffer();
    Iterator iterFind = vLabels.iterator();
    int recsFound = 0;

    Label label;
    while(iterFind.hasNext()){
        label = (Label)iterFind.next();
        
        sLabelType = checkString(label.type);
        sLabelID = checkString(label.id);
        sLabelLang = checkString(label.language);
        sLabelValue = checkString(label.value);
        if(findExactID.equalsIgnoreCase("1") && !sLabelID.equalsIgnoreCase(findLabelID)){
        	continue;
        }
        if(findExactValue.equalsIgnoreCase("1") && !sLabelValue.equalsIgnoreCase(findLabelValue)){
        	continue;
        }

        // alternate row-style
        if(sClass.equals("")) sClass = "1";
        else                  sClass = "";

        // display label in row
        foundLabels.append("<tr class='list"+sClass+"'>")
                    .append("<td class='hand' onclick=\"setLabel('"+sLabelType+"','"+sLabelID+"');\">"+sLabelType+"</td>")
                    .append("<td class='hand' onclick=\"setLabel('"+sLabelType+"','"+sLabelID+"');\">&nbsp;"+HTMLEntities.htmlentities(sLabelID)+"</td>")
                    .append("<td class='hand' onclick=\"setLabel('"+sLabelType+"','"+sLabelID+"');\">&nbsp;"+HTMLEntities.htmlentities(getTran(null,"web.language",sLabelLang,sWebLanguage))+"</td>")
                    .append("<td class='hand' onclick=\"setLabel('"+sLabelType+"','"+sLabelID+"');\">&nbsp;"+HTMLEntities.htmlentities(sLabelValue).replaceAll("<br>","\n")+"</td>")
                   .append("</tr>");

        recsFound++;
    }

    if(recsFound > 0){
	    %>
	    <table width="100%" cellspacing="0" cellpadding="0" class="list">
	      <%-- HEADER --%>
	      <tr class="admin">
	        <td width="20%"><%=getTran(null,"Web.Translations","LabelType",sWebLanguage)%></td>
	        <td width="38%"><%=getTran(null,"Web.Translations","LabelID",sWebLanguage)%></td>
	        <td width="10%"><%=getTran(null,"Web","Language",sWebLanguage)%></td>
	        <td width="30%"><%=getTran(null,"Web","Value",sWebLanguage)%></td>
	      </tr>
	      <%-- FOUND LABELS --%>
	      <tbody id="Input_Hist" class="hand">
	        <%=foundLabels%>
	      </tbody>
	    </table>
	    
        <span><%=recsFound%> <%=HTMLEntities.htmlentities(getTranNoLink("web","recordsfound",sWebLanguage))%></span>
	    <%
    }
    else{
        %><span><%=HTMLEntities.htmlentities(getTranNoLink("web","noRecordsfound",sWebLanguage))%></span><%
    }
%>