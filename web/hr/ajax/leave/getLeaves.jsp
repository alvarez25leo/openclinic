<%@page import="be.openclinic.hr.Leave,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../hr/includes/commonFunctions.jsp"%>

<%
    String sPatientId = checkString(request.getParameter("PatientId"));

    // search-criteria
    String sDuration     = checkString(request.getParameter("duration")),
           sType         = checkString(request.getParameter("type")),
           sAuthorizedBy = checkString(request.getParameter("authorizedBy")),
           sEpisodeCode  = checkString(request.getParameter("episodeCode")),
           sComment      = checkString(request.getParameter("comment"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************* hr/ajax/getLeaves.jsp *******************");
        Debug.println("sPatientId    : "+sPatientId);
        Debug.println("sDuration     : "+sDuration);
        Debug.println("sType         : "+sType);
        Debug.println("sAuthorizedBy : "+sAuthorizedBy);
        Debug.println("sEpisodeCode  : "+sEpisodeCode);
        Debug.println("sComment      : "+sComment+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Leave findObject = new Leave();
    findObject.personId = Integer.parseInt(sPatientId); // required
    if(sDuration.length() > 0){
        findObject.duration = Double.parseDouble(sDuration);
    }
    findObject.type = sType;
    findObject.episodeCode = sEpisodeCode;
    findObject.comment = sComment;
    
    List leaves = Leave.getList(findObject);
    DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigParam("priceFormat","0.00"));
    String sReturn = "";
    
    if(leaves.size() > 0){
        Hashtable hSort = new Hashtable();
        Leave leave;
                
        // sort on leave.begin
        for(int i=0; i<leaves.size(); i++){
            leave = (Leave)leaves.get(i);
            
            hSort.put(leave.begin.getTime()+"="+leave.getUid(),
                      (leave.isActive()?"style='background:#99cccc;'":"")+  
                      " onclick=\"displayLeave('"+leave.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(leave.begin)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(leave.end)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+deci.format(leave.duration).replaceAll(",",".")+" "+getTran(request,"web","days",sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+getTran(request,"hr.leave.type",leave.type,sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+leave.episodeCode+"</td>"+
                     "</tr>");
        }
    
        Vector keys = new Vector(hSort.keySet());
        Collections.sort(keys);
        Collections.reverse(keys);
        Iterator iter = keys.iterator();
        String sClass = "";
        
        while(iter.hasNext()){
            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            sReturn+= "<tr class='list"+sClass+"' "+hSort.get(iter.next());
        }
    }
    else{
        sReturn = "<td colspan='5'>"+getTran(request,"web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(leaves.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left:1px;">
        <td width="10%" nowrap><asc><%=HTMLEntities.htmlentities(getTran(request,"web.hr","begin",sWebLanguage))%></asc></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web.hr","end",sWebLanguage))%></td>
        <td width="15%" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","duration",sWebLanguage))%></td>
        <td width="20%" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web.hr","type",sWebLanguage))%></td>
        <td width="45%" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web.hr","episodeCode",sWebLanguage))%></td>
    </tr>
    
    <tbody class="hand">
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=leaves.size()+" "+getTran(request,"web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>