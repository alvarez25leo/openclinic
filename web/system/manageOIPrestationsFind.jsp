<%@page import="java.util.Vector,be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.Prestation" %>
<%@ page import="be.openclinic.finance.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<script src='<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js'></script>
<%=checkPermission(out,"system.management","select",activeUser)%>
<%
	
	try{
	String sFindPrestationCode  = checkString(request.getParameter("FindPrestationCode")),
           sFindPrestationDescr = checkString(request.getParameter("FindPrestationDescr")),
           sFindPrestationType  = checkString(request.getParameter("FindPrestationType")),
           sFindPrestationPrice = checkString(request.getParameter("FindPrestationPrice")),
		   sFindPrestationSort = request.getParameter("FindPrestationSort")!=null?request.getParameter("FindPrestationSort"):"OC_PRESTATION_CODE";
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","�");
    int prestationCount = 0;
    Vector foundPrestations = Prestation.searchPrestations("%"+sFindPrestationCode, "%"+sFindPrestationDescr, sFindPrestationType, sFindPrestationPrice,"",sFindPrestationSort);
    if (foundPrestations.size() > 0) {
%>
<table cellspacing="0" width="100%">
<tr class="admin">
    <td width="25">&nbsp;</td>
    <td width="100"><%=HTMLEntities.htmlentities(getTran(request,"web","code",sWebLanguage))%></td>
    <td width="300"><%=HTMLEntities.htmlentities(getTran(request,"web","description",sWebLanguage))%></td>
    <td width="70"><%=HTMLEntities.htmlentities(getTran(request,"web","type",sWebLanguage))%></td>
    <td width="80" align="left"><%=HTMLEntities.htmlentities(getTran(request,"web","price",sWebLanguage))%>&nbsp;<%=sCurrency%></td>
    <td><%=HTMLEntities.htmlentities(getTran(request,"web","categories",sWebLanguage))%></td>
    <td/>
</tr>
<tbody>
    <%
        String category="";
		//Find the applicable coverage plan based on active patient contributions
		if(activePatient!=null){
			String sBestInsurance=Insurance.getBestActiveCoveragePlan(activePatient.personid);
			Insurar insurar=null;
			if(sBestInsurance!=null && sBestInsurance.length()>0){
			   category=sBestInsurance.split(";")[1];
		       insurar = Insurar.get(sBestInsurance.split(";")[0]);
		    }
		}
        String sTranDelete = getTran(request,"Web", "delete", sWebLanguage);
        String sClass = "1", sType;
        Prestation prestation;

        for (int i = 0; i < foundPrestations.size(); i++) {
            prestation = (Prestation) foundPrestations.get(i);
            if(prestation.getType()==null || !prestation.getType().equalsIgnoreCase("con.openinsurance")){
	            prestationCount++;
	
	            // type
	            sType = checkString(prestation.getType());
	            if (sType.length() > 0) {
	                sType = getTran(request,"prestation.type", sType, sWebLanguage);
	            }
	
	            // alternate row-style
	            if (sClass.equals("")) sClass = "1";
	            else sClass = "";
	
	
	    %>
	                <tr class="list<%=sClass%>" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';">
	                    <td>
	                        <a href="javascript:deletePrestation('<%=prestation.getUid()%>');"><img src='<c:url value="/_img/icons/icon_delete.png"/>' border='0' alt="<%=sTranDelete%>"></a>
	                    </td>
	                    <td class="hand" onClick="editPrestation('<%=prestation.getUid()%>');"><%=HTMLEntities.htmlentities(checkString(prestation.getCode()))%></td>
	                    <td class="hand" onClick="editPrestation('<%=prestation.getUid()%>');"><%=HTMLEntities.htmlentities(checkString(prestation.getDescription()))%></td>
	                    <td class="hand" onClick="editPrestation('<%=prestation.getUid()%>');"><%=HTMLEntities.htmlentities(sType)%></td>
	                    <td class="hand" onClick="editPrestation('<%=prestation.getUid()%>');" align="left" nowrap><%=prestation.getPriceFormatted(category)%>&nbsp;</td>
	                    <td class="hand" onClick="editPrestation('<%=prestation.getUid()%>');"><%=prestation.getCategoriesFormatted(category)%></td>
	                    <td>&nbsp;</td>
	                </tr>
	            <%
            }
            if(prestationCount>100){
                break;
            }
        }
    %>
    </tbody>
</table>
    <%
}

// number of found records
if(prestationCount > 100){
    %>&gt;100 <%=HTMLEntities.htmlentities(getTran(request,"web","recordsFound",sWebLanguage))%><%
}
else if(prestationCount > 0){
    %><%=prestationCount%> <%=HTMLEntities.htmlentities(getTran(request,"web","recordsFound",sWebLanguage))%><%
}
else{
    %><br><%=HTMLEntities.htmlentities(getTran(request,"web","noRecordsFound",sWebLanguage))%><%
}
%>
<script>
  <%-- UPDATE ROW STYLES (after sorting) --%>
  function updateRowStyles(){
    for(var i=1; i<searchresults.rows.length; i++){
      if(i%2>0) searchresults.rows[i].className = "list";
      else      searchresults.rows[i].className = "list1";
    }
  }
</script>
<%
	}
	catch(Exception r){
		r.printStackTrace();
	}
%>