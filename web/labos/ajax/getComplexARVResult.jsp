<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp" %>
<%!
	String extractResistance(String arvs,String arv){
		String resistance="";
		String[] arvlist = arvs.split(";");
		for(int n=0;n<arvlist.length;n++){
			if(arvlist[n].split("=")[0].equalsIgnoreCase(arv) && arvlist[n].split("=").length>1){
				return arvlist[n].split("=")[1];
			}
		}
		return resistance;
	}
%>
<%
	String sAntivirogramuid = checkString(request.getParameter("antivirogramuid"));
	String arvs = checkString(request.getParameter("arvs"));
    boolean bEditable = checkString(request.getParameter("editable")).equals("true");
    String[] antivirogram = sAntivirogramuid.split("\\.");%>

<table width="100%" id="antivirogramtable">
    <tr width="100%" class='admin'>
        <td width="33%" class="longTitle"><%=HTMLEntities.htmlentities(getTran(request,"web","arv.coltitle1",sWebLanguage))%></td>
        <td width="33%" class="longTitle"><%=HTMLEntities.htmlentities(getTran(request,"web","arv.coltitle2",sWebLanguage))%></td>
        <td class="longTitle"><%=HTMLEntities.htmlentities(getTran(request,"web","arv.coltitle3",sWebLanguage))%></td>
    </tr>
	<tr>
		<td valign="top">
			<table width="100%">
			<%
		        // EXTRA LAB RESULTS
		        for(int i=0;i<MedwanQuery.getInstance().getConfigInt("maxARVlines",12);i++){
		            if(getTran(request,"arva",i+"",sWebLanguage).indexOf("<a")<0){
		                %>
				    <tr>
				        <td class='admin'><%=HTMLEntities.htmlentities(getTran(request,"arva",i+"",sWebLanguage))%></td>
				        <td>
				        	<select class='text' name="arvA.<%=i%>" id="arvA.<%=i%>">
				        		<option/>
				        		<%=ScreenHelper.writeSelect(request,"arvresistance",extractResistance(arvs,"a."+i),sWebLanguage)%>
				        	</select>
				        </td>
				    </tr>
		                <%
		            }
		        }
			%>
			</table>
		</td>
		<td valign="top">
			<table width="100%">
			<%
		        // EXTRA LAB RESULTS
		        for(int i=0;i<MedwanQuery.getInstance().getConfigInt("maxARVlines",12);i++){
		            if(getTran(request,"arvb",i+"",sWebLanguage).indexOf("<a")<0){
		                %>
				    <tr>
				        <td class='admin'><%=HTMLEntities.htmlentities(getTran(request,"arvb",i+"",sWebLanguage))%></td>
				        <td>
				        	<select class='text' name="arvB.<%=i%>" id="arvB.<%=i%>">
				        		<option/>
				        		<%=ScreenHelper.writeSelect(request,"arvresistance",extractResistance(arvs,"b."+i),sWebLanguage)%>
				        	</select>
				        </td>
				    </tr>
		                <%
		            }
		        }
			%>
			</table>
		</td>
		<td valign="top">
			<table width="100%">
			<%
		        // EXTRA LAB RESULTS
		        for(int i=0;i<MedwanQuery.getInstance().getConfigInt("maxARVlines",12);i++){
		            if(getTran(request,"arvc",i+"",sWebLanguage).indexOf("<a")<0){
		                %>
				    <tr>
				        <td class='admin'><%=HTMLEntities.htmlentities(getTran(request,"arvc",i+"",sWebLanguage))%></td>
				        <td>
				        	<select class='text' name="arvC.<%=i%>" id="arvC.<%=i%>">
				        		<option/>
				        		<%=ScreenHelper.writeSelect(request,"arvresistance",extractResistance(arvs,"c."+i),sWebLanguage)%>
				        	</select>
				        </td>
				    </tr>
		                <%
		            }
		        }
			%>
			</table>
		</td>
	</tr>
  
    <tr>
        <td colspan="3">
        	<%if(bEditable){ %>
            <input class="button" type="button" name="saveButton" id="saveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="saveAntiviroGramme('<%=sAntivirogramuid%>');">
            <%} %> 
			<input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
        </td>
    </tr>
</table>

