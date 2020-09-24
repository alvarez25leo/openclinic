<%@page import="java.util.*,
                be.openclinic.medical.LabRequest,
                java.util.Date"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"labos.printnewresults","select",activeUser)%>
<%!
    public class LabRow {
        int type;
        String tag;

        public LabRow(int type, String tag){
            this.type = type;
            this.tag = tag;
        }
    }
%>
<form name="samplesForm" method="post">
    <%=writeTableHeader("Web","printnewlabresults",sWebLanguage," doBack();")%>
    
    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","stardate",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="startdate" value="<%=checkString(request.getParameter("startdate")).length()>0?checkString(request.getParameter("startdate")):ScreenHelper.formatDate(new Date())%>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
                <input class="button" type="submit" name="submit" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
</form>

<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=labos/index.jsp";
  }
</script>
<%
    if(request.getParameter("startdate")!=null){
%>
        <form  name="printfrm" id="printfrm" target="_print" action="<c:url value='/labos/createLabResultsPdf.jsp'/>" method="post">
<%
        java.util.Date date = ScreenHelper.parseDate(request.getParameter("startdate"));
        Vector reqs = LabRequest.findServiceValidatedRequestsSince("",date,sWebLanguage,999);

        SortedMap services = new TreeMap();
        Iterator iterator = reqs.iterator();
        while(iterator.hasNext()){
            LabRequest labRequest = (LabRequest)iterator.next();
            if(services.get(labRequest.getServicename())==null){
                services.put(labRequest.getServicename(),new Hashtable());
            }
            ((Hashtable)services.get(labRequest.getServicename())).put(labRequest,"1");
        }

    %>
    <table class="list" width="100%" cellspacing="1" cellpadding="0">
        <%
            Iterator servicesiterator = services.keySet().iterator();
            while(servicesiterator.hasNext()){
                String servicename = (String)servicesiterator.next();
                out.print("<tr class='admin'>"+
                           "<td colspan='3'><b>"+servicename+"</b></td>"+
                           "<td>"+getTran(request,"web","patient",sWebLanguage)+"</td>"+
                           "<td>"+getTran(request,"web","prescriber",sWebLanguage)+"</td>"+
                          "</tr>");
                
                Hashtable requests = (Hashtable)services.get(servicename);
                Enumeration requestsEnumeration = requests.keys();
                while(requestsEnumeration.hasMoreElements()){
                    LabRequest labRequest = (LabRequest)requestsEnumeration.nextElement();
                    out.print("<tr bgcolor='#FFFCD6'>"+
                               "<td>&nbsp;</td>"+
                               "<td><input type='checkbox' name='print."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"' checked/></td>"+
                               "<td><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>"+labRequest.getTransactionid()+"</b></a> "+ScreenHelper.formatDate(labRequest.getRequestdate(),ScreenHelper.fullDateFormat)+"</td><td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (�"+(labRequest.getPatientdateofbirth()!=null?ScreenHelper.formatDate(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")</td>"+
                               "<td><i>"+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>"+
                              "</tr>");
                }
            }
        %>
    </table>
    <%
        if(services.size()>0){
		    %>
		    <input type="hidden" name="startdate" id="startdate"/>
		    <input type="submit" class="button" name="submit" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onclick="document.getElementById('startdate').value=document.getElementById('trandate').value"/>
		    <%
        }
        
    %>
    </form>
    
    <script>
      function showRequest(serverid,transactionid){
        window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&s=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
      }
    </script>
<%
    }
%>
