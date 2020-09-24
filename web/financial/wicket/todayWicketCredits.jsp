<%@page import="be.openclinic.finance.WicketCredit,java.util.Vector"%>
<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.finance.Wicket"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- ADD TODAY WICKETS -----------------------------------------------------------------------
    private String addTodayWickets(Vector vWickets, String sWeblanguage, boolean bCanEdit){
        String sReturn = "";

        if(vWickets!=null){
            String sClass = "";
            WicketCredit wicketOps;
            for(int i=0; i<vWickets.size(); i++){
                wicketOps = (WicketCredit)vWickets.elementAt(i);

                if(wicketOps!=null){
                	// alternate row-style
                    if(sClass.equals("")) sClass = "1";
                    else                  sClass = "";
                	
                    sReturn+= "<tr class='list"+sClass+"' "+(wicketOps.getOperationType().equalsIgnoreCase("patient.payment") && !bCanEdit?"":" onclick=\"setWicket('"+wicketOps.getUid()+"');\"")+">"+
                               "<td>"+ScreenHelper.stdDateFormat.format(wicketOps.getOperationDate())+"</td>"+
                               "<td>"+wicketOps.getUid()+"</td>"+
                               "<td>"+HTMLEntities.htmlentities(getTran(null,"service",Wicket.get(wicketOps.getWicketUID()).getServiceUID(),sWeblanguage))+"</td>"+
                               "<td>"+HTMLEntities.htmlentities(getTran(null,(wicketOps.getOperationType().equalsIgnoreCase("patient.payment")?"credit.type.hidden":"credit.type"),wicketOps.getOperationType(),sWeblanguage))+ "</td>"+
                               "<td>"+wicketOps.getAmount()+"</td>"+
                               "<td>"+HTMLEntities.htmlentities(wicketOps.getComment().toString())+"</td>"+
                              "</tr>";
                }
            }
        }
        
        return sReturn;
    }
%>

<%
    String sEditWicketOperationWicket = checkString(request.getParameter("EditWicketOperationWicket"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*************** financial/wicket/todayWicketCredits.jsp ***************");
    	Debug.println("sEditWicketOperationWicket : "+sEditWicketOperationWicket+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
     
    
    Vector vWicketsToday = WicketCredit.selectWicketOperations(getDate(), ScreenHelper.getDateAdd(getDate(),"1"),"","","",sEditWicketOperationWicket,"OC_WICKET_CREDIT_OPERATIONDATE DESC,OC_WICKET_CREDIT_OBJECTID DESC");
    Debug.println("--> vWicketsToday : "+vWicketsToday.size());
    
    if(vWicketsToday.size() > 0){
		%>
		<table width="100%" class="list" cellspacing="0" cellpadding="0">
		    <tr class="admin">
		        <td><%=HTMLEntities.htmlentities(getTran(request,"web","date",sWebLanguage))%></td>
		        <td>ID</td>
		        <td><%=HTMLEntities.htmlentities(getTran(request,"web","wicket",sWebLanguage))%></td>
		        <td><%=HTMLEntities.htmlentities(getTran(request,"wicket","operation_type",sWebLanguage))%></td>
		        <td width="200"><%=HTMLEntities.htmlentities(getTran(request,"web","amount",sWebLanguage))%> <%=MedwanQuery.getInstance().getConfigParam("currency","�")%></td>
		        <td><%=HTMLEntities.htmlentities(getTran(request,"web", "comment", sWebLanguage))%></td>
		    </tr>
		    
		    <tbody class="hand">
				<%=addTodayWickets(vWicketsToday,sWebLanguage,activeUser.getAccessRight("financial.superuser.select"))%>
		    </tbody>
		</table>
        <%
    }
%>