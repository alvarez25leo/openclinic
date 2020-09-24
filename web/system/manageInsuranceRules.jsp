<%@page import="be.openclinic.finance.Prestation"%>
<%@page import="be.openclinic.finance.Insurar"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"system.management","select",activeUser)%>
<%
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","�");
	String sPrestUid=checkString(request.getParameter("tmpPrestationUID"));
	String sQuantity=checkString(request.getParameter("EditPrestationQuantity"));
	String sDays=checkString(request.getParameter("EditPrestationDays"));
	String sInsurarUid=checkString(request.getParameter("EditInsurarUID"));
	String sFindButton=request.getParameter("findButton");
	String sShowOld=checkString(request.getParameter("ShowOld"));
	String sInsurarText="";
	Insurar insurar = Insurar.get(sInsurarUid);
	Double nDays=0.0,nQuantity=0.0;
	try{
		nDays=Double.parseDouble(sDays);
	}
	catch(Exception e){
		e.printStackTrace();
	}
	try{
		nQuantity=Double.parseDouble(sQuantity);
	}
	catch(Exception e){
		e.printStackTrace();
	}
	if(insurar!=null && insurar.getName()!=null){
		sInsurarText=insurar.getName();
	}
	String sCategory=checkString(request.getParameter("EditCategoryName"));
	
	if(request.getParameter("saveButton")!=null && sPrestUid.length()>0 && nQuantity*nDays>0 && sInsurarUid.length()>0){
		//Save rule
		Prestation.saveInsuranceRule(sPrestUid,sInsurarUid,nQuantity,nDays);
	}
	if(nQuantity<0 || nDays<0){
		sQuantity="";
		sDays="";
		sPrestUid="";
		sFindButton="1";
	}
%>
<form name='EditForm' id="EditForm" method='POST' action='<c:url value="/main.do?Page=system/manageInsuranceRules.jsp"/>'>
	<table class='list' border='0' width='100%' cellspacing='1'>
	        <tr>
	            <td class='admin'><%=getTran(request,"web","prestation",sWebLanguage)%></td>
	            <td class='admin2'>
	                <input type="hidden" name="tmpPrestationUID" id="tmpPrestationUID" value="<%=sPrestUid %>">
	                <input type="hidden" name="tmpPrestationName">
	
	                <select class="text" name="EditPrestationName" onchange="document.getElementById('tmpPrestationUID').value=this.value">
	                    <%
	                    	Prestation prest = Prestation.get(sPrestUid);
	                    	if (prest!=null){
	                    		
	                            out.print("<option selected value='"+checkString(prest.getUid())+"'>"+checkString(prest.getDescription())+"</option>");
	                        }
	                        Vector vPopularPrestations = activeUser.getTopPopularPrestations(10);
	                        if (vPopularPrestations!=null){
	                            String sPrestationUid;
	                            for (int i=0;i<vPopularPrestations.size();i++){
	                                sPrestationUid = checkString((String)vPopularPrestations.elementAt(i));
	                                if (sPrestationUid.length()>0){
	                                    Prestation prestation = Prestation.get(sPrestationUid);
	
	                                    if (prestation!=null && prestation.getDescription()!=null && prestation.getDescription().trim().length()>0 && !(prest!=null && prestation.getUid().equals(prest.getUid()))){
	                                        out.print("<option value='"+checkString(prestation.getUid())+"'");
	                                        out.print(">"+checkString(prestation.getDescription())+"</option>");
	                                    }
	                                }
	                            }
	                        }
	                    %>
	                </select>
	                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="searchPrestation();">
                	<img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","clear",sWebLanguage)%>" onclick="EditForm.EditPrestationName.selectedIndex=-1;EditForm.tmpPrestationUID.value='';">
	            </td>
	        </tr>
	        <tr>
		        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"medical.accident", "insurancecompany", sWebLanguage)%>
		        </td>
		        <td class="admin2">
		            <input type="hidden" name="EditInsurarUID" value="<%=sInsurarUid %>">
		            <input type="text" class="text" readonly name="EditInsurarText" value="<%=sInsurarText %>" size="100">
		            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="searchInsurar();">
		            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
		        </td>
		    </tr>
		    <tr>
		        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","quantity",sWebLanguage)%>
		        </td>
		        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationQuantity" size="10" maxlength="8" value="<%=sQuantity%>" onKeyup="if(!isNumber(this)){this.value='';}">
		        </td>
		    </tr>
		    <tr>
		        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","days",sWebLanguage)%>
		        </td>
		        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationDays" size="10" maxlength="8" value="<%=sDays%>" onKeyup="if(!isNumber(this)){this.value='';}">
		        </td>
		    </tr>
            <tr>
                <td class="admin"/>
                <td class="admin2">
                    <input type='submit' class="button" name="saveButton" value="<%=getTranNoLink("accesskey","save",sWebLanguage)%>"/>
                    <input type='submit' class="button" name="findButton" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
                </td>
            </tr>
	        
	</table>
</form>
<table class='list' border='0' width='100%' cellspacing='1'>

<%
	if(sFindButton!=null){
		String sSql="select distinct b.oc_insurar_name,c.oc_prestation_description,a.oc_insurancerule_quantity,oc_insurancerule_period"+
			",a.oc_insurancerule_insuraruid,a.oc_insurancerule_prestationuid"+
			" from oc_insurancerules a,oc_insurars b,oc_prestations c"+
			" where"+
			" b.oc_insurar_objectid=replace(a.oc_insurancerule_insuraruid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and "+
			" c.oc_prestation_objectid=replace(a.oc_insurancerule_prestationuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and "+
			" a.oc_insurancerule_insuraruid like '"+sInsurarUid+"%' and "+
			" a.oc_insurancerule_prestationuid like '"+sPrestUid+"%' "+
			" order by b.oc_insurar_name,c.oc_prestation_description";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ResultSet rs = ps.executeQuery();
		while (rs.next()){
			String iud=rs.getString("oc_insurancerule_insuraruid");
			String pud=rs.getString("oc_insurancerule_prestationuid");
			nQuantity=rs.getDouble("oc_insurancerule_quantity");
			nDays=rs.getDouble("oc_insurancerule_period");
			out.println("<tr class='list'>");
			%>
				<td><img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","delete",sWebLanguage)%>" onclick='selectPrestation("<%=iud%>","<%=pud %>",-1,-1);'></td>
			<%
			out.print("<td><a href='javascript:selectPrestation(\""+iud+"\",\""+pud+"\","+nQuantity+","+nDays+");'>"+rs.getString("oc_insurar_name")+"</a></td><td>"+rs.getString("oc_prestation_description")+"</td><td>"+
					nQuantity+"</td><td>"+nDays+"</td></tr>");
		}
		rs.close();
		ps.close();
		oc_conn.close();
%>
<%
	}
%>
</table>
<script>
	function selectPrestation(insuraruid,prestationuid,quantity,days){
		window.location.href='<c:url value="/main.do?Page=system/manageInsuranceRules.jsp"/>&tmpPrestationUID='+prestationuid+'&EditInsurarUID='+insuraruid+'&EditPrestationQuantity='+quantity+'&EditPrestationDays='+days+(quantity==-1 || days==-1?'&saveButton=true':'');
	}
	
    function searchPrestation(){
        EditForm.tmpPrestationName.value = "";
        EditForm.tmpPrestationUID.value = "";
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid=tmpPrestationUID&ReturnFieldDescr=tmpPrestationName&doFunction=changeTmpPrestation()");
    }
    
    function doClearInsurar() {
        EditForm.EditInsurarUID.value = "";
        EditForm.EditInsurarText.value = "";
    }

    function changeTmpPrestation(){
    	if (EditForm.tmpPrestationUID.value.length>0){
            EditForm.EditPrestationName.options[0].text = EditForm.tmpPrestationName.value;
            EditForm.EditPrestationName.options[0].value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[0].selected = true;
        }
    }
    function searchInsurar() {
        openPopup("/_common/search/searchInsurar.jsp&ts=<%=getTs()%>&ReturnFieldInsurarUid=EditInsurarUID&ReturnFieldInsurarName=EditInsurarText&doFunction=changeInsurar()&excludePatientSelfIsurarUID=true&PopupHeight=500&PopupWith=500");
    }
    function changeInsurar(){
    }    
        
</script>