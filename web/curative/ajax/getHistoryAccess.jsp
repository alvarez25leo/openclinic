<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String personid=activePatient==null?"-99999999999":activePatient.personid;
	if(checkString(request.getParameter("personid")).length()>0){
		personid = request.getParameter("personid");
	}
    int iNb = (checkString(request.getParameter("nb")).length()>0)? Integer.parseInt(checkString(request.getParameter("nb"))):0;

    //SimpleDateFormat dateformat = new SimpleDateFormat("dd-MM-yyyy '"+getTranNoLink("web.occup"," - ",sWebLanguage)+"' HH:mm:ss");
    List l = AccessLog.getLastAccess("A."+personid,iNb);
    String s = "";
    int i = 0;
    Timestamp t;
    Hashtable u;
    
    if(l.size() > 1){
        Iterator it = l.iterator();
        while(it.hasNext()){
            Object[] ss = (Object[])it.next();
			try{
	            t = (Timestamp)ss[0];
	            u = User.getUserName((String)ss[1]);
	            s+= "\n<li style=\"width:100%;\" "+((i%2==0)?"class='odd'":"")+"><div> "+ScreenHelper.fullDateFormat.format(t)+" "+getTranNoLink("web","by",sWebLanguage)+" <b>"+u.get("firstname")+" "+u.get("lastname")+"</b></div></li>";
	            i++;
			}
			catch(Exception e){
				e.printStackTrace();
			}
        }
    }
    
	if(iNb>0 && l.size()>20){
	    %><div style="width:100%;text-align:right;"><a href="javascript:void(0)" onclick="Modalbox.show('<c:url value='/curative/ajax/getHistoryAccess.jsp'/>?personid=<%=personid %>&nb=0&ts='+new Date().getTime(), {title:'<%=getTranNoLink("web","history",sWebLanguage)%>', width: 420,height:370},{evalScripts: true} );" class="link"><%=getTranNoLink("web","expand_all",sWebLanguage)%></a></div><%
	}
%>

<ul class="items" style="width:380px;">
    <%=s%>
</ul>