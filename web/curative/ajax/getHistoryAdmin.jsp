<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    int iNb = (checkString(request.getParameter("nb")).length()>0)? Integer.parseInt(checkString(request.getParameter("nb"))):0;

    //SimpleDateFormat dateformat = new SimpleDateFormat("dd-MM-yyyy '"+getTranNoLink("web.occup"," - ",sWebLanguage)+"' HH:mm:ss");
	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	PreparedStatement ps;
	ResultSet rs;
	ps = conn.prepareStatement("select * from AdminHistory where personid=? order by updatetime desc");
	ps.setInt(1,Integer.parseInt(activePatient.personid));
	rs = ps.executeQuery();
	int i = 0;
    String s = "";
    Timestamp t;
    Hashtable u;
	while(rs.next()){
		if(i<iNb){
            t = rs.getTimestamp("updatetime");
            u = User.getUserName(rs.getString("updateuserid"));
            if(u!=null && u.size()>0){
            	s+= "\n<li style=\"width:100%;\" "+((i%2==0)?"class='odd'":"")+"><div><a href='javascript:openPopup(\"/_common/patient/patientdataHistoryPopup.jsp&ts="+getTs()+"&updatetime="+new SimpleDateFormat("yyyyMMddHHmmssSSS").format(t)+"&personid="+activePatient.personid+"\");'>"+ ScreenHelper.formatDate(t)+"</a> "+getTranNoLink("web","by",sWebLanguage)+" "+u.get("firstname")+" "+u.get("lastname")+"</div></li>";
            }
		}
		i++;
	}
	rs.close();
	ps.close();
	conn.close();
	
	if(i>=20){
	    %><div style="width:100%;text-align:right;"><a href="javascript:void(0)" onclick="Modalbox.show('<c:url value='/curative/ajax/getHistoryAdmin.jsp'/>?nb=0&ts='+new Date().getTime(),{title:'<%=getTranNoLink("web", "history",sWebLanguage)%>',width:420,height:370},{evalScripts:true});" class="link"><%=getTranNoLink("web","expand_all",sWebLanguage)%></a></div><%
	}
%>

<ul class="items" style="width:380px;">
    <%=s%>
</ul>