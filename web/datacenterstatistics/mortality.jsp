<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"statistics.globalpathologydistribution","select",activeUser)%>

<table border="0" width="100%">
    <tr class="admin"><td><%=getTran(request,"web","statistics.mortality",sWebLanguage)%></td></tr>
</table>

<form method="POST">
    <select name="year" id="year" class="text">
        <%
            for(int n=0; n<10; n++){
                int activeYear = (Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-n);
                out.print("<option "+((activeYear+"").equalsIgnoreCase(request.getParameter("year"))?"selected":"")+" value='"+activeYear+"'>"+activeYear+"</option>");
            }
        %>
    </select>
    
    <input class="text" type="submit" name="submit" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
</form>

<table width="100%" border="0">
<%
    if(request.getParameter("submit")!=null){
		java.util.Date firstday = ScreenHelper.parseDate("01/01/"+request.getParameter("year")),
		               lastday  = ScreenHelper.parseDate("31/12/"+request.getParameter("year"));
		
		// US-date
	    if(ScreenHelper.stdDateFormat.toPattern().equals("MM/dd/yyyy")){
	        lastday = ScreenHelper.parseDate("12/31/"+request.getParameter("year"));
	    }
		
    	String sQuery = "select count(*) total, month(oc_encounter_enddate) month"+
    	                " from oc_encounters"+
                        "  where oc_encounter_enddate>=?"+
                        "   and oc_encounter_enddate<=?"+
                        "   and oc_encounter_outcome like 'dead%'"+
                        "   and oc_encounter_type = 'admission'"+
                        " group by month(oc_encounter_enddate)";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ps.setDate(1,new java.sql.Date(firstday.getTime()));
        ps.setDate(2,new java.sql.Date(lastday.getTime()));
        ResultSet rs = ps.executeQuery();
        java.util.Hashtable months = new Hashtable();
        int total = 0;
        while(rs.next()){
            String t = rs.getString("total");
            months.put(rs.getString("month"),t);
            total+= Integer.parseInt(t);
        }
        rs.close();
        ps.close();
        oc_conn.close();
        
        String s1 = "<tr>", s2 = "<tr>";
        for(int n=1; n<13; n++){
            s1+= ("<td class='admin' width='8%'>"+getTran(request,"web","month"+n,sWebLanguage)+"</td>");
            s2+= ("<td class='admin2' width='8%'><a href='javascript:showDeceased("+n+","+request.getParameter("year")+")'>"+(months.get(n+"")==null?"0":months.get(n+""))+"</a></td>");
        }
        s1+= "</tr>";
        s2+= "</tr>";
        
        out.print(s1+s2);
        
        // total
        out.print("<tr><td class='admin'>"+getTran(request,"web","total",sWebLanguage)+"</td><td class='admin2' colspan='11'>"+total+"</td></tr>");
    }
%>
</table>

<script>
  function showDeceased(month,year){
    openPopup("<c:url value="statistics/showDeceased.jsp"/>&month="+month+"&year="+year+"&ts=<%=getTs()%>",600,400);
  }
</script>