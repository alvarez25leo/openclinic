<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
try{
	String personid = request.getParameter("personid");
	java.util.Date updatetime = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(request.getParameter("updatetime"));
	AdminPerson activeHistoryPatient = AdminPerson.getAdminHistoryPerson(personid,updatetime);

	String sGender = "&nbsp;", sComment = "&nbsp;", sNativeCountry = "&nbsp;", sLanguage = "&nbsp;", sNatreg = "&nbsp;"
            , sCivilStatus = "&nbsp;", sTracnetID = "&nbsp;", sTreatingPhysician = "&nbsp;", sComment3="", sDeathCertificateTo="", sDeathCertificateOn="";

    // language
    sWebLanguage = activeUser.person.language;
    if ((activeHistoryPatient.language!=null)&&(activeHistoryPatient.language.trim().length()>0)) {
        sLanguage = getTran(request,"Web.language",activeHistoryPatient.language,sWebLanguage);
    }

    // Gender
    if ((activeHistoryPatient.gender!=null)&&(activeHistoryPatient.gender.trim().length()>0)) {
        if (activeHistoryPatient.gender.equalsIgnoreCase("m")){
            sGender = getTran(request,"web.occup","male",sWebLanguage);
        }
        else if (activeHistoryPatient.gender.equalsIgnoreCase("f")){
            sGender = getTran(request,"web.occup","female",sWebLanguage);
        }
    }
    // sTracnetID
    if (checkString((String)activeHistoryPatient.adminextends.get("tracnetid")).length()>0) {
        sTracnetID = checkString((String)activeHistoryPatient.adminextends.get("tracnetid"));
    }

    // sDeathCertificateTo
    if (checkString((String)activeHistoryPatient.adminextends.get("deathcertificateto")).length()>0) {
    	sDeathCertificateTo = checkString((String)activeHistoryPatient.adminextends.get("deathcertificateto"));
    }

    // sDeathCertificateOn
    if (checkString((String)activeHistoryPatient.adminextends.get("deathcertificateon")).length()>0) {
    	sDeathCertificateOn = checkString((String)activeHistoryPatient.adminextends.get("deathcertificateon"));
    }

    // sTreatingPhysician
    if (checkString(activeHistoryPatient.comment1).length()>0) {
        sTreatingPhysician = activeHistoryPatient.comment1;
    }

    // civilstatus
    if ((activeHistoryPatient.comment2!=null)&&(activeHistoryPatient.comment2.trim().length()>0)) {
        sCivilStatus = getTran(request,"civil.status",activeHistoryPatient.comment2,sWebLanguage);
    }

    // comment
    if ((activeHistoryPatient.comment!=null)&&(activeHistoryPatient.comment.trim().length()>0)) {
        sComment = (activeHistoryPatient.comment);
    }

    // comment
    if ((activeHistoryPatient.comment3!=null)&&(activeHistoryPatient.comment3.trim().length()>0)) {
        sComment3 = (activeHistoryPatient.comment3);
    }

    // nativeCountry
    if ((activeHistoryPatient.nativeCountry!=null)&&(activeHistoryPatient.nativeCountry.trim().length()>0)) {
        sNativeCountry = getTran(request,"Country",activeHistoryPatient.nativeCountry,sWebLanguage);
    }

    // nat reg
    if (checkString(activeHistoryPatient.getID("natreg")).length()>0) {
        sNatreg = activeHistoryPatient.getID("natreg");
    }
%>
<%-- MAIN TABLE ----------------------------------------------------------------------------------%>
<table width='100%' cellspacing="1" class="list" style="border-top:none;">
    <%=(
        setRow(request,"Web","date",ScreenHelper.formatDate(updatetime),sWebLanguage)
        +setRow(request,"Web","nativecountry",sNativeCountry,sWebLanguage)
        +setRow(request,"Web","Language",sLanguage,sWebLanguage)
        +setRow(request,"Web","Gender",sGender,sWebLanguage)
        +setRow(request,"Web","natreg",sNatreg,sWebLanguage)
        +setRow(request,"Web","treating-physician",sTreatingPhysician,sWebLanguage)
        +setRow(request,"Web","civilstatus",sCivilStatus,sWebLanguage)
        +setRow(request,"Web","comment3",sComment3,sWebLanguage)
        +setRow(request,"Web","comment",sComment,sWebLanguage)
        )
    %>
    <tr height='1'><td width='<%=sTDAdminWidth%>'/></tr>
</table>
<%
    String sShowButton = checkString(request.getParameter("ShowButton"));
    if (!sShowButton.equals("false")){
%>
<%-- BUTTONS -------------------------------------------------------------------------------------%>
<%=ScreenHelper.alignButtonsStart()%>
    <%
        if (activeUser.getAccessRight("patient.administration.edit")){
        %>
            <input type="button" class="button" onclick="window.location.href='<c:url value="/patientedit.do"/>?Tab=Admin&ts=<%=getTs()%>'" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>"/>
        <%
        }
    %>
<%=ScreenHelper.alignButtonsStop()%>
<%
    }
}
catch(Exception e){
	e.printStackTrace();
}
%>