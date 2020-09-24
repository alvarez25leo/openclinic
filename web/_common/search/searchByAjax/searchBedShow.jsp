<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.adt.Bed,
                be.openclinic.adt.Encounter,
                java.util.Vector,
                java.util.Hashtable"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- CREATE ENCOUNTER INFO -------------------------------------------------------------------
    public String createEncounterInfo(String sEncounterUID, String sLanguage){
        String sOutput;
        String sBegin, sEnd;

        Encounter eTmp = Encounter.get(sEncounterUID);
        if(eTmp.getBegin()!=null){
            sBegin = ScreenHelper.formatDate(eTmp.getBegin());
        }
        else{
            sBegin = "";
        }

        if(eTmp.getEnd()!=null){
            sEnd = ScreenHelper.formatDate(eTmp.getEnd());
        }
        else{
            sEnd = "";
        }

        sOutput = "<table class='list' width='100%' cellspacing='1' cellpadding='0'>"+
                   "<tr>"+
                    "<td colspan='2'>"+writeTableHeader("Web.manage","manageEncounters",sLanguage,"")+"</td>"+
                   "</tr>"+
                   "<tr>"+
                    "<td class='admin'>"+getTran(null,"Web","type",sLanguage)+"</td>"+
                    "<td class='admin2'>"+getTran(null,"Web",checkString(eTmp.getType()),sLanguage)+"</td>"+
                   "</tr>"+
                   "<tr>"+
                    "<td class='admin'>"+getTran(null,"Web","begindate",sLanguage)+"</td>"+
                    "<td class='admin2'>"+sBegin+"</td>"+
                   "</tr>"+
                   "<tr>"+
                    "<td class='admin'>"+getTran(null,"Web","enddate",sLanguage)+"</td>"+
                    "<td class='admin2'>"+sEnd+"</td>"+
                   "</tr>"+
                  "<tr>"+
                   "<td class='admin'>"+getTran(null,"Web","manager",sLanguage)+"</td>"+
                   "<td class='admin2'>"+(checkString(eTmp.getManagerUID()).length()>0?ScreenHelper.getFullPersonName(""+MedwanQuery.getInstance().getPersonIdFromUserId(Integer.parseInt(eTmp.getManagerUID()))):"")+
                  "</td>"+
                 "</tr>"+
                 "<tr>"+
                  "<td class='admin'>"+getTran(null,"Web","service",sLanguage)+"</td>"+
                  "<td class='admin2'>"+getTran(null,"Service",checkString(eTmp.getServiceUID()),sLanguage)+"</td>"+
                 "</tr>"+
                "</table>";
                
        return sOutput;
    }
%>

<%
    String sFindBedName = checkString(request.getParameter("FindBedName")),
           sViewCode    = checkString(request.getParameter("ViewCode")),
           sServiceUID  = checkString(request.getParameter("ServiceUID"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** searchByAjax/searchBedShow.jsp ********************");
    	Debug.println("sFindBedName  : "+sFindBedName);
    	Debug.println("sViewCode     : "+sViewCode);
    	Debug.println("sServiceUID   : "+sServiceUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    String sSelectBedName = ScreenHelper.normalizeSpecialCharacters(sFindBedName);
%>

<table width="100%" cellspacing="0" cellpadding="0" class="list">
    <%
        String sortColumn = " OC_BED_NAME";
        Vector vBeds = new Vector();
        if(sSelectBedName.length() > 0 || sServiceUID.length() > 0){
        	vBeds = Bed.selectBeds("","",sSelectBedName,sServiceUID,"","",sortColumn);
        }

        boolean recsFound = false;
        String sClass = "";
        String sClassOccupied;
        StringBuffer results = new StringBuffer();
        Hashtable hOccupiedInfo;
        Bed tmpBed;
        String sSelectable;
        String sPatientName = "";
        String sComment = "";
        String sEncounterUid = "";
        Boolean bStatus;

        Iterator iter = vBeds.iterator();
        while(iter.hasNext()){
            recsFound = true;
            tmpBed = (Bed)iter.next();

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            hOccupiedInfo = tmpBed.isOccupied();
            sComment= tmpBed.getComment();
            bStatus = (Boolean)hOccupiedInfo.get("status");

            if(bStatus.booleanValue()){
                //if occupied
                sEncounterUid = (String)hOccupiedInfo.get("encounterUid");
                if((hOccupiedInfo.get("patientUid")).equals(activePatient.personid)){
                    sSelectable = "onclick=\"setBed('"+tmpBed.getUid()+"','"+tmpBed.getName().toUpperCase()+"');\"";
                }
                else{
                    sSelectable = "";
                }

                sPatientName = ScreenHelper.getFullPersonName((String) hOccupiedInfo.get("patientUid"));
                sClassOccupied = "occupied";
            }
            else{
                // if not occupied
                sSelectable = "onclick=\"setBed('"+tmpBed.getUid()+"','"+tmpBed.getName().toUpperCase()+"');\"";
                sClassOccupied = "";
            }

            results.append("<tr");

            if(sClassOccupied.equals("")){
                sIcon = "";
                results.append("class='list"+sClass+"'><td/>");
                results.append("<td/>");
            }
            else{
                sIcon = "<img src='"+sCONTEXTPATH+"/_img/themes/default/menu_tee_plus.gif' onclick='toggleBedInfo(\""+tmpBed.getUid()+"\");' alt='"+getTranNoLink("Web.Occup","medwan.common.open",sWebLanguage)+"'>";
                results.append("class='list"+sClassOccupied+sClass+"'>"+
                               "<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.png' alt='"+getTranNoLink("Web","edit",sWebLanguage)+"' onclick=\"editEncounter('"+sEncounterUid+"');\"></td>");
                results.append("<td>"+sIcon+"</td>");
            }

            results.append("<td "+sSelectable+">"+tmpBed.getName().toUpperCase()+(sViewCode.equalsIgnoreCase("on")?" ("+tmpBed.getUid()+")":"")+"</td>")
                    .append("<td "+sSelectable+">"+sPatientName+"</td>")
                    .append("<td "+sSelectable+">"+sComment+"</td>")
                    .append("</tr>");
            
            if(bStatus.booleanValue()){
                results.append("<tr id='"+tmpBed.getUid()+"' style='display:none;'>"+
                                "<td/>"+
                                "<td/>"+
                                "<td colspan='3'>"+createEncounterInfo(sEncounterUid,sWebLanguage)+"</td>"+
                               "</tr>");
            }
            sPatientName = "";
        }

        if(recsFound){
		    %>
		        <%-- HEADER --%>
			    <tr class="admin">
			        <td width="20"/>
			        <td width="20"/>
			        <td width="100"><%=HTMLEntities.htmlentities(getTran(request,"web","bed",sWebLanguage))%></td>
			        <td><%=HTMLEntities.htmlentities(getTran(request,"Web","patient",sWebLanguage))%></td>
			        <td><%=HTMLEntities.htmlentities(getTran(request,"Web","comment",sWebLanguage))%></td>
			    </tr>
			    
			    <tbody class="hand"><%=HTMLEntities.htmlentities(results.toString())%></tbody>
		    <%
        }
    %>
</table>

<%
    if(!recsFound){
        // display 'no results' message
        %><div style='text-align:left;'><%=HTMLEntities.htmlentities(getTran(request,"web","noRecordsFound",sWebLanguage))%></div><%
    }
%>