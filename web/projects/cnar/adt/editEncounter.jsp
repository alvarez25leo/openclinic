<%@page import="be.openclinic.adt.Encounter,
                be.openclinic.adt.Bed,java.util.*,be.openclinic.finance.Prestation,be.openclinic.finance.Debet,be.openclinic.finance.Insurance,java.util.Date" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"adt.encounter","all",activeUser)%>
<%!
    //--- GET DATE HOUR ---------------------------------------------------------------------------
    public java.util.Date getDateHour(String sDate, String sHour) {
        String sTmpHour[] = sHour.split(":");
        java.util.Date d=null;
        try{
        	d=new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(sDate+" "+sHour);
        }
        catch(Exception e){};
		return d;
    }
%>
<%
    Encounter tmpEncounter = null;

    boolean bActiveEncounterStatus;

    String sEditEncounterUID = checkString(request.getParameter("EditEncounterUID"));
    String sEditEncounterType = checkString(request.getParameter("EditEncounterType"));
    String sEditEncounterBegin = checkString(request.getParameter("EditEncounterBegin"));
    String sEditEncounterBeginHour = checkString(request.getParameter("EditEncounterBeginHour"));
    String sEditEncounterEnd = checkString(request.getParameter("EditEncounterEnd"));
    String sEditEncounterEndHour = checkString(request.getParameter("EditEncounterEndHour"));

    String sEditEncounterService = checkString(request.getParameter("EditEncounterService"));
    String sEditEncounterServiceName = checkString(request.getParameter("EditEncounterServiceName"));

    String sEditEncounterOrigin = checkString(request.getParameter("EditEncounterOrigin"));
    String sEditEncounterOriginCNAR1="",sEditEncounterOriginCNAR2="",sEditEncounterOriginCNAR3="",sEditEncounterOriginCNAR4="",sEditEncounterOriginCNAR5="",sEditEncounterOriginCNAR6="",sEditEncounterOriginCNAR7="";
    if(sEditEncounterOrigin.length()==0){
    	sEditEncounterOrigin=MedwanQuery.getInstance().getConfigString("defaultEncounterOrigin","");
    }
   	sEditEncounterOriginCNAR1=sEditEncounterOrigin.split("\\$")[0];
   	if(sEditEncounterOrigin.split("\\$").length>1){
       	sEditEncounterOriginCNAR2=sEditEncounterOrigin.split("\\$")[1];
       	if(sEditEncounterOrigin.split("\\$").length>2){
           	sEditEncounterOriginCNAR3=sEditEncounterOrigin.split("\\$")[2];
           	if(sEditEncounterOrigin.split("\\$").length>3){
               	sEditEncounterOriginCNAR4=sEditEncounterOrigin.split("\\$")[3];
               	if(sEditEncounterOrigin.split("\\$").length>4){
                   	sEditEncounterOriginCNAR5=sEditEncounterOrigin.split("\\$")[4];
                   	if(sEditEncounterOrigin.split("\\$").length>5){
                       	sEditEncounterOriginCNAR6=sEditEncounterOrigin.split("\\$")[5];
                       	if(sEditEncounterOrigin.split("\\$").length>6){
                           	sEditEncounterOriginCNAR7=sEditEncounterOrigin.split("\\$")[6];
                       	}
                   	}
               	}
           	}
       	}
   	}
    String sEditEncounterDestination = checkString(request.getParameter("EditEncounterDestination"));
    String sEditEncounterDestinationName = checkString(request.getParameter("EditEncounterDestinationName"));

    String sEditEncounterBed = checkString(request.getParameter("EditEncounterBed"));
    String sEditEncounterBedName = checkString(request.getParameter("EditEncounterBedName"));

    String sEditEncounterPatient = checkString(request.getParameter("EditEncounterPatient"));
    String sEditEncounterPatientName = checkString(request.getParameter("EditEncounterPatientName"));

    String sEditEncounterManager = checkString(request.getParameter("EditEncounterManager"));
    String sEditEncounterManagerName = checkString(request.getParameter("EditEncounterManagerName"));
    String sEditEncounterOutcome = checkString(request.getParameter("EditEncounterOutcome"));
    String sEditEncounterSituation = checkString(request.getParameter("EditEncounterSituation"));
    String sEditEncounterAccomodationPrestation = checkString(request.getParameter("EditEncounterAccomodationPrestation"));
    String sEditEncounterTransferDate = checkString(request.getParameter("EditEncounterTransferDate"));
    String sEditEncounterTransferHour = checkString(request.getParameter("EditEncounterTransferHour"));
    String sEditEncounterNewcase = checkString(request.getParameter("EditEncounterNewcase"));
    String sEditEncounterEtiology = checkString(request.getParameter("EditEncounterEtiology"));
    String sMaxTransferDate="";

    String sAction = checkString(request.getParameter("Action"));
    String sPopup = checkString(request.getParameter("Popup"));
    String sReadOnly = checkString(request.getParameter("ReadOnly"));

    String sAccountAccomodationDays = checkString(request.getParameter("AccountAccomodationDays"));
    if(sEditEncounterUID.length()==0 && sEditEncounterService.length()==0){
        sEditEncounterService=MedwanQuery.getInstance().getConfigString("defaultAdmissionService","");
        if(sEditEncounterService.length()>0){
            Service service = Service.getService(sEditEncounterService);
            sEditEncounterServiceName=service.getLabel(sWebLanguage);
        }
        sEditEncounterManager=MedwanQuery.getInstance().getConfigString("defaultAdmissionManager","");
        if(sEditEncounterManager.length()>0){
            UserVO user = MedwanQuery.getInstance().getUser(sEditEncounterManager);
            sEditEncounterManagerName=user.personVO.firstname.toUpperCase()+" "+user.personVO.lastname.toUpperCase();
        }
        sEditEncounterManager=MedwanQuery.getInstance().getConfigString("defaultAdmissionManager","");
    }

    if (Debug.enabled) {
        Debug.println("\n####################### EDIT PARAMS ###########################" +
                "\nEditEncounterUID     : " + sEditEncounterUID +
                "\nEncounterType        : " + sEditEncounterType +
                "\nEncounterBegin       : " + sEditEncounterBegin +
                "\nEncounterBeginHour   : " + sEditEncounterBeginHour +
                "\nEncounterEnd         : " + sEditEncounterEnd +
                "\nEncounterEndHour     : " + sEditEncounterEndHour +
                "\nEncounterPatient     : " + sEditEncounterPatient +
                "\nEncounterPatientName : " + sEditEncounterPatientName +
                "\nEncounterManager     : " + sEditEncounterManager +
                "\nEncounterManagerName : " + sEditEncounterManagerName +
                "\nEncounterService     : " + sEditEncounterService +
                "\nEncounterServiceName : " + sEditEncounterServiceName +
                "\nEncounterDestination     : " + sEditEncounterDestination +
                "\nEncounterDestinationName : " + sEditEncounterDestinationName +
                "\nEncounterBed         : " + sEditEncounterBed +
                "\nEncounterBedName     : " + sEditEncounterBedName +
                "\nAccountAccomodationDays     : " + sAccountAccomodationDays +
                "\n###############################################################"
        );
    }
    if (sAction.equals("SAVE")) {

        String sCloseActiveEncounter = checkString(request.getParameter("CloseActiveEncounter"));

        if (sCloseActiveEncounter.equals("CLOSE")) {
            if (Debug.enabled) {
                Debug.println("Closing active encounter!");
            }
            Encounter eActiveEncounter = Encounter.getActiveEncounter(activePatient.personid);
            eActiveEncounter.setEnd(ScreenHelper.getSQLDate(sEditEncounterBegin));
            eActiveEncounter.store();
        }

        tmpEncounter = new Encounter();

        if (sEditEncounterUID.length() > 0) {//update
            tmpEncounter = Encounter.get(sEditEncounterUID);
        } else {//insert
            tmpEncounter.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }
        tmpEncounter.setType(sEditEncounterType);


        tmpEncounter.setBegin(getDateHour(sEditEncounterBegin, sEditEncounterBeginHour));
        if (sEditEncounterEnd.length() > 0) {
            tmpEncounter.setEnd(getDateHour(sEditEncounterEnd, sEditEncounterEndHour));
        } else {
            tmpEncounter.setEnd(null);
        }
        tmpEncounter.setOutcome(sEditEncounterOutcome);
        tmpEncounter.setSituation(sEditEncounterSituation);

        Service tmpService ;
        Service tmpDestination;
        Bed tmpBed = null;
        AdminPerson tmpPatient;
        tmpService = Service.getService(sEditEncounterService);

        if (sEditEncounterType.equals("admission")) {
            tmpBed = Bed.get(sEditEncounterBed);
        }
        tmpDestination = Service.getService(sEditEncounterDestination);

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        tmpPatient = AdminPerson.getAdminPerson(ad_conn, sEditEncounterPatient);
        ad_conn.close();
        //AdminPerson tmpManager = AdminPerson.getAdminPerson(dbConnection,sEditEncounterManager);

        User tmpManager = new User();
        if (sEditEncounterManager.length() > 0) {
            tmpManager.initialize(Integer.parseInt(sEditEncounterManager));
        }

        if (tmpService == null) {
            tmpService = new Service();
        }
        if (tmpDestination == null) {
            tmpDestination = new Service();
        }
        if (tmpBed == null || sEditEncounterType.equalsIgnoreCase("visit")) {
            tmpBed = new Bed();
        }
        if (tmpPatient == null) {
            tmpPatient = new AdminPerson();
        }
        if (tmpManager == null) {
            tmpManager = new User();
        }

        tmpEncounter.setService(tmpService);
        tmpEncounter.setDestination(tmpDestination);
        tmpEncounter.setBed(tmpBed);
        tmpEncounter.setOrigin(sEditEncounterOrigin);

        tmpEncounter.setPatient(tmpPatient);
        tmpEncounter.setManager(tmpManager);
        tmpEncounter.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        tmpEncounter.setUpdateUser(activeUser.userid);
        tmpEncounter.setNewcase(sEditEncounterNewcase.equals("1")?1:0);
        tmpEncounter.setEtiology(sEditEncounterEtiology);
        if(sEditEncounterTransferDate.length()>0){
            if(sEditEncounterTransferHour.length()==0){
                sEditEncounterTransferHour="00:00";
            }
            tmpEncounter.setTransferDate(getDateHour(sEditEncounterTransferDate, sEditEncounterTransferHour));
        }

        tmpEncounter.store();

        if (request.getParameter("DoAccountAccomodationDays")!=null && sAccountAccomodationDays.length() > 0) {
            try {
                int accountAccomodationDays = Integer.parseInt(sAccountAccomodationDays);
                if (accountAccomodationDays != 0 ) {
                    Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
                    if(insurance==null){
                        out.print("<script>alert('"+getTranNoLink("web","no_insurance_available",sWebLanguage)+"')</script>");
                    }
                    else{
                        Prestation accomodationPrestation = Prestation.get(sEditEncounterAccomodationPrestation);
                        if(accomodationPrestation==null){
                            out.print("<script>alert('"+getTranNoLink("web","no_accomodation_prestation_defined",sWebLanguage)+"')</script>");
                        }
                        else {
                            Debet debet = new Debet();
                            debet.setQuantity(accountAccomodationDays);
                            debet.setAmount(accountAccomodationDays * accomodationPrestation.getPrice(insurance.getType()) * insurance.getPatientShare() / 100);
                            debet.setInsurarAmount(accountAccomodationDays * accomodationPrestation.getPrice(insurance.getType()) * (100 - insurance.getPatientShare()) / 100);
                            debet.setPrestationUid(accomodationPrestation.getUid());
                            debet.setInsuranceUid(insurance.getUid());
                            debet.setDate(new Date());
                            debet.setEncounterUid(tmpEncounter.getUid());
                            debet.setCreateDateTime(new Date());
                            debet.setUpdateDateTime(new Date());
                            debet.setUpdateUser(activeUser.userid);
                            debet.store();
                        }
                    }
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }

        sEditEncounterUID = checkString(tmpEncounter.getUid());
        if (sPopup.equalsIgnoreCase("yes")) {
%>
            <script>
                var o = window.opener;
                o.location.reload();
                window.close();
            </script>
            <%
        }
        %>
            <script>
                window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
            </script>
        <%
    }
    String sRfe="";
    if(sEditEncounterUID.length() > 0){

        sRfe= ReasonForEncounter.getReasonsForEncounterAsHtml(sEditEncounterUID,sWebLanguage,"_img/icons/icon_delete.png","deleteRFE($serverid,$objectid)");
        tmpEncounter = Encounter.get(sEditEncounterUID);
		if(tmpEncounter!=null && tmpEncounter.getMaxTransferDate()!=null){
			sMaxTransferDate=new SimpleDateFormat("dd/MM/yyyy").format(tmpEncounter.getMaxTransferDate());
		}
        sEditEncounterType            = checkString(tmpEncounter.getType());
        sEditEncounterBegin           = checkString(new SimpleDateFormat("dd/MM/yyyy").format(tmpEncounter.getBegin()));
        sEditEncounterBeginHour           = checkString(new SimpleDateFormat("HH:mm").format(tmpEncounter.getBegin()));

        if(tmpEncounter.getEnd() == null){
            sEditEncounterEnd         = "";
        }else{
            sEditEncounterEnd         = checkString(new SimpleDateFormat("dd/MM/yyyy").format(tmpEncounter.getEnd()));
            sEditEncounterEndHour     = checkString(new SimpleDateFormat("HH:mm").format(tmpEncounter.getEnd()));
        }

        if(tmpEncounter.getService() == null){
            sEditEncounterService     = "";
            sEditEncounterServiceName = "";
        }else {
            sEditEncounterService     = checkString(tmpEncounter.getService().code);
            sEditEncounterServiceName = checkString(getTran(request,"Service",tmpEncounter.getService().code,sWebLanguage));
        }
        if(tmpEncounter.getDestination() == null || checkString(tmpEncounter.getDestination().code).length()==0){
            sEditEncounterDestination     = "";
            sEditEncounterDestinationName = "";
        }else {
            sEditEncounterDestination     = checkString(tmpEncounter.getDestination().code);
            sEditEncounterDestinationName = checkString(getTran(request,"Service",tmpEncounter.getDestination().code,sWebLanguage));
        }

        if(tmpEncounter.getBed() == null){
            sEditEncounterBed         = "";
            sEditEncounterBedName     = "";
        }else{
            sEditEncounterBed         = checkString(tmpEncounter.getBed().getUid());
            sEditEncounterBedName     = checkString(tmpEncounter.getBed().getName());
        }
		sEditEncounterNewcase = tmpEncounter.getNewcase()+"";
		sEditEncounterEtiology = tmpEncounter.getEtiology();
        sEditEncounterPatient         = checkString(tmpEncounter.getPatient().personid);
        sEditEncounterOrigin         = checkString(tmpEncounter.getOrigin());
       	sEditEncounterOriginCNAR1=sEditEncounterOrigin.split("\\$")[0];
       	if(sEditEncounterOrigin.split("\\$").length>1){
           	sEditEncounterOriginCNAR2=sEditEncounterOrigin.split("\\$")[1];
           	if(sEditEncounterOrigin.split("\\$").length>2){
               	sEditEncounterOriginCNAR3=sEditEncounterOrigin.split("\\$")[2];
               	if(sEditEncounterOrigin.split("\\$").length>3){
                   	sEditEncounterOriginCNAR4=sEditEncounterOrigin.split("\\$")[3];
                   	if(sEditEncounterOrigin.split("\\$").length>4){
                       	sEditEncounterOriginCNAR5=sEditEncounterOrigin.split("\\$")[4];
                       	if(sEditEncounterOrigin.split("\\$").length>5){
                           	sEditEncounterOriginCNAR6=sEditEncounterOrigin.split("\\$")[5];
                           	if(sEditEncounterOrigin.split("\\$").length>6){
                               	sEditEncounterOriginCNAR7=sEditEncounterOrigin.split("\\$")[6];
                           	}
                       	}
                   	}
               	}
           	}
       	}
       	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        sEditEncounterPatientName     = checkString(ScreenHelper.getFullPersonName(tmpEncounter.getPatient().personid,ad_conn));
        sEditEncounterOutcome         = checkString(tmpEncounter.getOutcome());
        sEditEncounterSituation         = checkString(tmpEncounter.getSituation());

        if(tmpEncounter.getManager() == null){
            sEditEncounterManager     = "";
            sEditEncounterManagerName = "";
        }else{
            sEditEncounterManager         = checkString(tmpEncounter.getManager().userid);
            sEditEncounterManagerName     = checkString(ScreenHelper.getFullUserName(tmpEncounter.getManager().userid,ad_conn));
        }
        ad_conn.close();

        sEditEncounterUID             = checkString(tmpEncounter.getUid());
        if(Debug.enabled){
            Debug.println("####### TEST #######");
            Debug.println(" ServiceUID: " + sEditEncounterService);
            Debug.println(" ServiceName: " + sEditEncounterServiceName);
            Debug.println(" BedUID: " + sEditEncounterBed);
            Debug.println(" BedName: " + sEditEncounterBedName);
        }
    }
    else {
        sEditEncounterType = MedwanQuery.getInstance().getConfigString("defaultEncounterType","visit");
    }

    if(!(sEditEncounterPatient.length() > 0)){
        sEditEncounterPatient         = checkString(activePatient.personid);
    }
    if(!(sEditEncounterBegin.length() >0)){
        sEditEncounterBegin           = getDate();
    }
    if(!(sEditEncounterBeginHour.length() >0)){
        sEditEncounterBeginHour           = new SimpleDateFormat("HH:mm").format(new java.util.Date());
    }
%>
<%
    if(sPopup.equalsIgnoreCase("yes")){
%>
<form onclick="calculateAccomodationDates();" name='EditEncounterForm' id="EditEncounterForm" method='POST' action='<c:url value="/adt/template.jsp"/>?Page=editEncounter.jsp&ts=<%=getTs()%>'>
<%
    }else{
%>
<form onclick="calculateAccomodationDates();" name='EditEncounterForm' id="EditEncounterForm" method='POST' action='<c:url value="/main.do"/>?Page=adt/editEncounter.jsp&ts=<%=getTs()%>'>
<%
    }
%>
    <%
        String sOther = "";
        if(!sPopup.equalsIgnoreCase("yes")){
            sOther = " doBack();";
        }
    %>
    <%=writeTableHeader("Web.manage","manageEncounters",sWebLanguage,sOther)%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- type --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","type",sWebLanguage)%> *</td>
            <td class='admin2'>
                <select class='text' id='EditEncounterType' name='EditEncounterType' onchange="checkEncounterType();">
                    <%
                        String encountertypes=MedwanQuery.getInstance().getConfigString("encountertypes","admission,visit");
                        String sOptions[] = encountertypes.split(",");

                        for(int i=0;i<sOptions.length;i++){
                            out.print("<option value='" + sOptions[i] + "' ");
                            if(sEditEncounterType.equalsIgnoreCase(sOptions[i])){
                                out.print(" selected");
                            }
                            out.print(">" + getTran(request,"web",sOptions[i],sWebLanguage) + "</option>");
                        }

                    %>

                </select>
            </td>
        </tr>
        <%-- date begin --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","begindate",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeDateField("EditEncounterBegin","EditEncounterForm",sEditEncounterBegin+"' onkeyup='calculateAccomodationDates();' onclick='calculateAccomodationDates();' onchange='calculateAccomodationDates();",sWebLanguage)%>
                <input class="text" name="EditEncounterBeginHour" value="<%=sEditEncounterBeginHour%>" size="5" onkeyup='calculateAccomodationDates();' onblur="checkTime(this);calculateAccomodationDates();" onkeypress="keypressTime(this)">
            </td>
        </tr>
        <%-- date end --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","enddate",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeDateField("EditEncounterEnd","EditEncounterForm",sEditEncounterEnd+"' onkeyup='calculateAccomodationDates();' onclick='calculateAccomodationDates();' onchange='calculateAccomodationDates();",sWebLanguage)%>
                <input class="text" name="EditEncounterEndHour" value="<%=sEditEncounterEndHour%>" size="5" onkeyup='calculateAccomodationDates();' onblur="checkTime(this);calculateAccomodationDates();" onkeypress="keypressTime(this)">
            </td>
        </tr>
        <script type="text/javascript">
            function setTime(field){
                document.getElementsByName(field)[0].value=new Date().getHours()+":"+new Date().getMinutes();
            }
        </script>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","urgency.origin",sWebLanguage)%> *</td>
            <td class="admin2">
                <select class="text" name="EditEncounterOriginCNAR1" id="EditEncounterOriginCNAR1" onchange="loadSelect('cnar.origin.'+this.options[this.selectedIndex].value,document.getElementById('EditEncounterOriginCNAR2'))">
                    <option/>
                    <%
                        out.print(ScreenHelper.writeSelect(request,"urgency.origin",sEditEncounterOriginCNAR1,sWebLanguage));
                    %>
                </select>
                <select class='text' name='EditEncounterOriginCNAR2' id='EditEncounterOriginCNAR2'>
                    <%
                        out.print(ScreenHelper.writeSelect(request,"cnar.origin."+sEditEncounterOriginCNAR1,sEditEncounterOriginCNAR2,sWebLanguage));
                    %>
                </select>
                <input type='hidden' name='EditEncounterOrigin' id='EditEncounterOrigin'/>
            </td>
        </tr>
        <%-- origin comment --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","origin.details",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" cols="80" name="EditEncounterSituation" style="vertical-align:top;"><%=sEditEncounterSituation %></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"Web","socialservice.manager",sWebLanguage)%></td>
            <td class="admin2">
                <select class='text' name='EditEncounterOriginCNAR3' id='EditEncounterOriginCNAR3'>
                    <option/>
                    <%
                        out.print(ScreenHelper.writeSelect(request,"encounter.socialservice.manager",sEditEncounterOriginCNAR3,sWebLanguage));
                    %>
                </select>
            </td>
        </tr>
        <input type='hidden' name='EditEncounterPatient' value='<%=sEditEncounterPatient%>'>
        <%-- service --%>
       <tr id="Service">
           <td class="admin"><%=getTran(request,"Web","service",sWebLanguage)%> *</td>
           <td class='admin2'>
               <input type="hidden" name="EditEncounterService" value="<%=sEditEncounterService%>" onchange="setTransfer();">
               <input class="text" type="text" name="EditEncounterServiceName" id="EditEncounterServiceName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterServiceName%>" onblur="">
               <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="searchService('EditEncounterService','EditEncounterServiceName');">
               <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","clear",sWebLanguage)%>" onclick="EditEncounterForm.EditEncounterService.value='';EditEncounterForm.EditEncounterServiceName.value='';">
           </td>
       </tr>
        <%-- manager --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","manager",sWebLanguage)%></td>
            <td class="admin2">
                <input type='text' class='text' size='60' name='EditEncounterOriginCNAR4' id='EditEncounterOriginCNAR4' value='<%= sEditEncounterOriginCNAR4%>'/>
            </td>
        </tr>
        <%-- transfer --%>
       <tr id="transfer" style="visibility:visible;">
           <td class="admin"><%=getTran(request,"Web","transferdate",sWebLanguage)%></td>
           <td class='admin2'>
               <%=writeDateField("EditEncounterTransferDate","EditEncounterForm","",sWebLanguage)%>
               <input class="text" id="EditEncounterTransferHour" name="EditEncounterTransferHour" value="" size="5" onblur="checkTime(this)"/>
           </td>
       </tr>
        <tr id="internaltransfers">
            <td class="admin"><%=getTran(request,"Web","internal.transfers",sWebLanguage)%></td>
            <td class="admin2">
                <div id="divServices">
                    <table width="100%">
                <%
                    if (tmpEncounter != null) {
                        Vector transferHistory = tmpEncounter.getTransferHistory();
                        Encounter.EncounterService encounterService;
                        Hashtable username;
                        encounterService = tmpEncounter.getLastEncounterService();
                        if(encounterService!=null && encounterService.end==null){
                            username =User.getUserName(encounterService.managerUID);
                            %><tr><td><img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","delete",sWebLanguage)%>" onclick="deleteService('<%=encounterService.serviceUID%>')"></td>
                                <td><%=new SimpleDateFormat("dd/MM/yyyy HH:mm").format(encounterService.begin)+" - "%></td>
                                <td><b><%=getTran(request,"Service", encounterService.serviceUID, sWebLanguage)%></b></td>
                                <td><%=getTran(request,"web","bed",sWebLanguage)+": "+checkString(Bed.get(encounterService.bedUID).getName())%></td>
                                <td><%=getTran(request,"web","manager",sWebLanguage)+": "+(username!=null?username.get("firstname")+" "+username.get("lastname"):"")%></td>
                            </tr>
                            <%
                        }
                        for (int n = 0; n < transferHistory.size(); n++) {
                            encounterService = (Encounter.EncounterService) transferHistory.elementAt(n);
                            username =User.getUserName(encounterService.managerUID);
                            %><tr><td><img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","delete",sWebLanguage)%>" onclick="deleteService('<%=encounterService.serviceUID%>')"></td>
                                <td><%=new SimpleDateFormat("dd/MM/yyyy HH:mm").format(encounterService.begin)+" - "+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(encounterService.end)%></td>
                                <td><b><%=getTran(request,"Service", encounterService.serviceUID, sWebLanguage)%></b></td>
                                <td><%=getTran(request,"web","bed",sWebLanguage)+": "+checkString(Bed.get(encounterService.bedUID).getName())%></td>
                                <td><%=getTran(request,"web","manager",sWebLanguage)+": "+(username!=null?username.get("firstname")+" "+username.get("lastname"):"")%></td>
                            </tr>
                            <%
                        }
                    }
                %>
                    </table>
                </div>
            </td>
        </tr>
       	<tr>
            <td class="admin"><%=getTran(request,"Web","etiology",sWebLanguage)%></td>
            <td class='admin2'>
            	<input type="checkbox" name="EditEncounterNewcase" value="1" <%= sEditEncounterNewcase.equals("1")?"checked":""%>/><%=getTran(request,"Web","newcase",sWebLanguage)%>
                <select class="text" name="EditEncounterEtiology" style="vertical-align:top;">
                    <option value=""><%=getTran(request,"web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelect(request,"encounter.etiology",checkString(sEditEncounterEtiology),sWebLanguage)%>
                </select>
			</td>            
       	</tr>
        <%-- outcome --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","outcome",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="EditEncounterOutcome" style="vertical-align:top;">
                    <option value=""><%=getTran(request,"web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelect(request,"encounter.outcome",sEditEncounterOutcome,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr id="Destination" style="visibility: visible;">
            <td class="admin"><%=getTran(request,"Web","destination",sWebLanguage)%></td>
            <td class='admin2'>
                <select class="text" name="EditEncounterOriginCNAR5" id="EditEncounterOriginCNAR5" onchange="loadSelect('cnar.destination.'+this.options[this.selectedIndex].value,document.getElementById('EditEncounterOriginCNAR6'))">
                    <option/>
                    <%
                        out.print(ScreenHelper.writeSelect(request,"encounter.destination",sEditEncounterOriginCNAR5,sWebLanguage));
                    %>
                </select>
                <select class='text' name='EditEncounterOriginCNAR6' id='EditEncounterOriginCNAR6'>
                    <%
                        out.print(ScreenHelper.writeSelect(request,"cnar.destination."+sEditEncounterOriginCNAR5,sEditEncounterOriginCNAR6,sWebLanguage));
                    %>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","destination.details",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" cols="80" name="EditEncounterOriginCNAR7" id="EditEncounterOriginCNAR7" style="vertical-align:top;"><%=sEditEncounterOriginCNAR7 %></textarea>
            </td>
        </tr>
        <%
            int accountedDays=Encounter.getAccountedAccomodationDays(sEditEncounterUID);
            Vector accomodationDebets = Encounter.getAccountedAccomodations(sEditEncounterUID);
        %>
        <tr id="alreadyAccountedAccomodation"  style="visibility: <%=accomodationDebets.size()>0?"visible":"visible"%>;">
            <td class="admin"><%=getTran(request,"Web","alreadyaccountedaccomodation",sWebLanguage)%> </td><td class='admin2'> = <%=Encounter.getAccountedAccomodationDays(sEditEncounterUID)%> <%=getTran(request,"Web","days",sWebLanguage)%><%=tmpEncounter!=null && tmpEncounter.getDurationInDays()>0?" = <label id='d2'>"+Encounter.getAccountedAccomodationDays(sEditEncounterUID)*100/tmpEncounter.getDurationInDays()+"</label>%":""%>
            <BR/>
            <%
                for(int n=0;n<accomodationDebets.size();n++){
                    Debet debet = (Debet)accomodationDebets.elementAt(n);
                    out.print(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate())+": <b>"+debet.getQuantity()+"</b> "+getTran(request,"web","days",sWebLanguage)+" ("+debet.getPrestation().getDescription()+") = <b>"+debet.getAmount()+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</b> ("+getTran(request,"web","insurar",sWebLanguage)+" = "+debet.getInsurarAmount()+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")</BR/>");
                }
            %>
            </td>
        </tr>
        <tr id="notAccountedAccomodation" style="visibility: visible;">
            <td class="admin"><%=getTran(request,"Web","notaccountedaccomodation",sWebLanguage)%></td>
            <td class='admin2'>
                <select class="text" name="EditEncounterAccomodationPrestation" style="vertical-align:top;">
                    <%
                        String[] accomodationprestations = MedwanQuery.getInstance().getConfigString("accomodationPrestations","").split(";");
                        for (int n=0;n<accomodationprestations.length;n++){
                            Prestation prestation = Prestation.getByCode(accomodationprestations[n]);
                            if(prestation!=null){
                                out.println("<option value='"+prestation.getUid()+"'>"+prestation.getDescription()+"</option>");
                            }
                        }
                    %>
                </select>
                <BR/>
                <input type="checkbox" name="DoAccountAccomodationDays"/><%=getTran(request,"Web","doinvoice",sWebLanguage)%> <input type="text" class="text" name="AccountAccomodationDays" size="4" value="<%=tmpEncounter!=null?tmpEncounter.getDurationInDays()-accountedDays:0%>"/> <%=getTran(request,"web","days",sWebLanguage)%> <%=tmpEncounter!=null?"("+getTran(request,"web","actualencounterduration",sWebLanguage)+" = "+tmpEncounter.getDurationInDays()+" "+getTran(request,"web","days",sWebLanguage)+")":""%>
            </td>
        </tr>
        <%
            if(tmpEncounter!=null && checkString(tmpEncounter.getType()).equalsIgnoreCase("admission") && tmpEncounter.getDurationInDays()>accountedDays){
        %>
                <script type="text/javascript">document.getElementById("notAccountedAccomodation").style.display="block";</script>
        <%
            }
        %>
        <%=ScreenHelper.setFormButtonsStart()%>
            <%
                if(!sReadOnly.equalsIgnoreCase("yes")){
            %>
            <input class='button' type="button" id="saveButton" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            <%
                }
                if(!sPopup.equalsIgnoreCase("yes") && !sReadOnly.equalsIgnoreCase("yes")){
            %>
                <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
            <%
                }else{
            %>
                <input type="button" class="button" name="buttonclose" value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close()'>
            <%
                }
            %>
        <%=ScreenHelper.setFormButtonsStop()%>
        <%-- action, uid --%>
        <input type='hidden' name='Action' value=''>
        <input type='hidden' name='CloseActiveEncounter' value=''>
        <input type='hidden' name='Popup' value='<%=sPopup%>'>
        <input type='hidden' name='EditEncounterUID' value='<%=sEditEncounterUID%>'>
    </table>
    <%-- indication of obligated fields --%>
    <%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>
</form>
<%
    if (sEditEncounterUID.length()>0){
%>
        <table class="list" width="100%" cellspacing="1">
            <tr class="admin">
                <td align="center"><a href="javascript:openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=sEditEncounterUID%>&ts=<%=getTs()%>',700,400)"><%=getTran(request,"openclinic.chuk","rfe",sWebLanguage)%> <%=getTran(request,"Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></a></td>
            </tr>
            <tr>
                <td id="rfe"><%=sRfe%></td>
            </tr>
        </table>
        <%
        }
        else{

            Encounter activeEncounter=Encounter.getActiveEncounter(activePatient.personid);
        	if(activeEncounter != null && activeEncounter.getEnd()==null){
                bActiveEncounterStatus = true;
            }else{
                bActiveEncounterStatus = false;
            }

            if(bActiveEncounterStatus){
                %>
                    <script>
                        function closeActiveEncounter(){
                            EditEncounterForm.CloseActiveEncounter.value = "CLOSE";
                        }

                        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=adt.encounter&labelID=encounter_close";
                        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                        var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("adt.encounter","encounter_close",sWebLanguage)%>");


                        if(answer){
                            window.location.href='<c:url value="/main.do?Page=adt/editEncounter.jsp&EditEncounterUID="/><%=activeEncounter.getUid()%>';
                        }
                        else {
                            history.back();
                        }
                    </script>
                <%
            }
        }
    %>
<script>
function loadSelect(labeltype,select){
    var today = new Date();
    var url='<c:url value="/"/>/_common/search/searchByAjax/loadSelect.jsp?ts=' + today;
    new Ajax.Request(url,{
            method: "POST",
            postBody: 'labeltype=' + labeltype,
            onSuccess: function(resp){
                var sOptions = resp.responseText;
                if (sOptions.length>0){
                    var aOptions = sOptions.split("$");
                    select.options.length=0;
                    for(var i=0; i<aOptions.length; i++){
                    	aOptions[i] = aOptions[i].replace(/^\s+/,'');
                    	aOptions[i] = aOptions[i].replace(/\s+$/,'');
                        if ((aOptions[i].length>0)&&(aOptions[i]!=" ")){
                        	select.options[i] = new Option(aOptions[i].split("�")[1], aOptions[i].split("�")[0]);
                        }
                    }
                }
            },
            onFailure: function(){
            }
        }
    );
}
</script>
<script>
checkEncounterType();

    <%-- enable/disable button to choose a bed if service is chosen or not --%>
    function setBedButton(){
//        if(EditEncounterForm.EditEncounterService.value == "" || EditEncounterForm.EditEncounterServiceName.value == ""){
//            EditEncounterForm.SearchBedButton.disabled = true;
//            EditEncounterForm.EditEncounterBedName.value = "";
//            EditEncounterForm.EditEncounterBed.value = "";
//        }else{
//            EditEncounterForm.SearchBedButton.disabled = false;
            //EditEncounterForm.EditEncounterBedName.value = "";
            //EditEncounterForm.EditEncounterBed.value = "";
//        }
    }

    function searchService(serviceUidField,serviceNameField){
        var sNeedsBeds="";
        if(serviceNameField != 'EditEncounterDestinationName'){
			if(document.getElementById("EditEncounterType").value=='admission'){
				sNeedsBeds="&needsbeds=1";
			}
			else {
				sNeedsBeds="&needsvisits=1";
			}
        }
        openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField+sNeedsBeds);
        document.getElementById(serviceNameField).focus();
    }

    function searchDestination(serviceUidField,serviceNameField,findCode){
        var sNeedsBeds="";
        if(serviceNameField != 'EditEncounterDestinationName'){
			if(document.getElementById("EditEncounterType").value=='admission'){
				sNeedsBeds="&needsbeds=1";
			}
			else {
				sNeedsBeds="&needsvisits=1";
			}
        }
        openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField+"&FindCode="+findCode+sNeedsBeds);
        document.getElementById(serviceNameField).focus();
    }

//    function searchBed(bedUidField,bedNameField){
//       openPopup("/_common/search/searchBed.jsp&ts=<%=getTs()%>&VarCode="+bedUidField+"&VarText="+bedNameField + "&ViewCode=off&ServiceUID=" + EditEncounterForm.EditEncounterService.value);
//        EditEncounterForm.EditEncounterBedName.focus();
//    }

    function searchManager(managerUidField,managerNameField){
        openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID="+EditEncounterForm.EditEncounterService.value+"&FindServiceName="+EditEncounterForm.EditEncounterServiceName.value);
        EditEncounterForm.EditEncounterManagerName.focus();
    }

    function doSave(){
    	document.getElementById("EditEncounterOrigin").value=document.getElementById("EditEncounterOriginCNAR1").value+"$"+document.getElementById("EditEncounterOriginCNAR2").value+"$"+document.getElementById("EditEncounterOriginCNAR3").value+"$"+document.getElementById("EditEncounterOriginCNAR4").value+"$"+document.getElementById("EditEncounterOriginCNAR5").value+"$"+document.getElementById("EditEncounterOriginCNAR6").value+"$"+document.getElementById("EditEncounterOriginCNAR7").value;
		if(EditEncounterForm.EditEncounterBegin.value == ""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_begindate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_begindate",sWebLanguage)%>");
        }else if(ParseDate(EditEncounterForm.EditEncounterBegin.value)>new Date()){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_future_begindate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_future_begindate",sWebLanguage)%>");
        }else if(EditEncounterForm.EditEncounterBeginHour.value == ""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_beginhour";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_beginhour",sWebLanguage)%>");
    <%
      	if (sEditEncounterUID.length()>0){
    %>
        }else if(EditEncounterForm.EditEncounterEnd.value != "" && ParseDate(EditEncounterForm.EditEncounterEnd.value)<ParseDate('<%=sMaxTransferDate%>')){
                var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=encounter_wrong_enddate";
                var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_future_begindate",sWebLanguage)%>");
    <%
       	}
    %>        	        
        }else if(EditEncounterForm.EditEncounterEnd.value != "" && EditEncounterForm.EditEncounterEndHour.value == ""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_endhour";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_endhour",sWebLanguage)%>");
        }else if(!checkDates()){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=encounter_invalid_enddate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","encounter_invalid_enddate",sWebLanguage)%>");
        }else if ((EditEncounterForm.EditEncounterOutcome.selectedIndex>0)&&(EditEncounterForm.EditEncounterEnd.value == "")){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_enddate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_enddate",sWebLanguage)%>");
        }else if ((EditEncounterForm.EditEncounterOutcome.selectedIndex==0)&&(EditEncounterForm.EditEncounterEnd.value != "")){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_outcome";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_outcome",sWebLanguage)%>");
        }else if (EditEncounterForm.EditEncounterServiceName.value==""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_service";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_service",sWebLanguage)%>");
        }else if (EditEncounterForm.EditEncounterTransferDate && !EditEncounterForm.EditEncounterTransferDate.value=="" && !EditEncounterForm.EditEncounterEnd.value=="" && ParseDate(EditEncounterForm.EditEncounterTransferDate.value)>ParseDate(EditEncounterForm.EditEncounterEnd.value)){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=encounter_invalid_transferdate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","encounter_invalid_transferdate",sWebLanguage)%>");
        }else if (EditEncounterForm.EditEncounterOrigin.value==""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=encounter_invalid_origin";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","encounter_invalid_origin",sWebLanguage)%>");
        }else if (EditEncounterForm.EditEncounterEtiology.value==""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=encounter_no_etiology";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","encounter_no_etiology",sWebLanguage)%>");
        }else{
            EditEncounterForm.saveButton.disabled = true;
            EditEncounterForm.Action.value = "SAVE";
            EditEncounterForm.submit();
        }
        EditEncounterTransferDate
    }

    <%-- back --%>
    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    <%-- check if enddate is after begindate --%>
    function checkDates(){
        if(EditEncounterForm.EditEncounterEnd.value == ""){
            return true;
        }else{
            var end = ParseDate(EditEncounterForm.EditEncounterEnd.value);
            var begin = ParseDate(EditEncounterForm.EditEncounterBegin.value);
            if(end < begin || end>new Date()){
                return false;
            }else{
                calculateAccomodationDates();
                return true;
            }
        }
    }

    function calculateAccomodationDates(){
        if(EditEncounterForm.EditEncounterEnd.value.length>0 && EditEncounterForm.EditEncounterEndHour.value.length==0){
            EditEncounterForm.EditEncounterEndHour.value="12:00";
            if(EditEncounterForm.EditEncounterEnd.value.split("/").length==3 && EditEncounterForm.EditEncounterEnd.value.split("/")[2].length==4){
                if(isDate(EditEncounterForm.EditEncounterEnd.value.split("/")[0],EditEncounterForm.EditEncounterEnd.value.split("/")[1],EditEncounterForm.EditEncounterEnd.value.split("/")[2])){
                    var end = ParseDate(EditEncounterForm.EditEncounterEnd.value);
                    var toDay= new Date();
                    if(end.getYear()==toDay.getYear() && end.getMonth()==toDay.getMonth() && end.getDay()==toDay.getDay()){
                        setTime("EditEncounterEndHour");
                    }
                }
            }
        }
        else if(EditEncounterForm.EditEncounterEnd.value.length==0){
            EditEncounterForm.EditEncounterEndHour.value="";
        }
        if(EditEncounterForm.EditEncounterBegin.value.split("/").length==3){
            if(isDate(EditEncounterForm.EditEncounterBegin.value.split("/")[0],EditEncounterForm.EditEncounterBegin.value.split("/")[1],EditEncounterForm.EditEncounterBegin.value.split("/")[2])){
                var begin = ParseDate(EditEncounterForm.EditEncounterBegin.value);
                if(EditEncounterForm.EditEncounterBeginHour.value.split(":").length==2){
                    begin.setTime(begin.getTime()+EditEncounterForm.EditEncounterBeginHour.value.split(":")[0]*60*60000+EditEncounterForm.EditEncounterBeginHour.value.split(":")[1]*60000);
                }
                var end = new Date();
                if(EditEncounterForm.EditEncounterEnd.value.split("/").length==3 && EditEncounterForm.EditEncounterEnd.value.split("/")[2].length==4){
                    if(isDate(EditEncounterForm.EditEncounterEnd.value.split("/")[0],EditEncounterForm.EditEncounterEnd.value.split("/")[1],EditEncounterForm.EditEncounterEnd.value.split("/")[2])){
                        end = ParseDate(EditEncounterForm.EditEncounterEnd.value);
                    }
                }
                if(EditEncounterForm.EditEncounterEndHour.value.split(":").length==2){
                    end.setTime(end.getTime()+EditEncounterForm.EditEncounterEndHour.value.split(":")[0]*60*60000+EditEncounterForm.EditEncounterEndHour.value.split(":")[1]*60000);
                }
                if(end>=begin){
                    var days=Math.ceil((end.getTime()-begin.getTime())/(24*3600*1000));
                    var accounted=<%=Encounter.getAccountedAccomodationDays(sEditEncounterUID)%>;
                    if(document.getElementById("d2")!=null){
                        document.getElementById("d2").innerHTML=Math.round(accounted*100/days);
                    }
                    if(days!=accounted && Math.ceil(days-accounted)!=0){
                        document.getElementsByName("AccountAccomodationDays")[0].value=Math.ceil(days-accounted);
                        if(EditEncounterForm.EditEncounterType.value == "admission") {
                            show("notAccountedAccomodation");
                        }
                    }
                    else {
                        EditEncounterForm.DoAccountAccomodationDays.checked=false;
                        hide("notAccountedAccomodation");
                    }
                }
                else {
                    EditEncounterForm.DoAccountAccomodationDays.checked=false;
                    hide("notAccountedAccomodation");
                }
            }
        }
    }

    function ParseDate( str1 ){
        // Parse the string in DD/MM/YYYY format
        re = /(\d{1,2})\/(\d{1,2})\/(\d{4})/
        var arr = re.exec( str1 );
        return new Date( parseInt(arr[3]), parseInt(arr[2], 10) - 1, parseInt(arr[1], 10) );
    }

    <%-- check type and display right inputfields --%>
    function checkEncounterType(){
        if(EditEncounterForm.EditEncounterType.value == "admission"){
            //document.getElementById("Service").style.display = "block";
//            show("Bed");
            show("alreadyAccountedAccomodation");
            show("internaltransfers");
            calculateAccomodationDates();
        }else{
//            EditEncounterForm.EditEncounterBed.value="";
//            EditEncounterForm.EditEncounterBedName.value="";
//            setBedButton();
            //document.getElementById("Service").style.display = "none";
//            hide("Bed");
            document.getElementsByName('DoAccountAccomodationDays')[0].checked=false;
            hide("notAccountedAccomodation");
            hide("alreadyAccountedAccomodation");
            show("internaltransfers");
        }
    }

    function deleteService(sID){
        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
        var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");


        if(answer==1){
            var params = '';
            var today = new Date();
            var url= '<c:url value="/adt/ajaxActions/editEncounterDeleteService.jsp"/>?EncounterUID=<%=sEditEncounterUID%>&ServiceUID='+sID+'&ts='+today;
            document.getElementById('divServices').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Loading";
            new Ajax.Request(url,{
                    method: "GET",
                    parameters: params,
                    onSuccess: function(resp){
                        $('divServices').innerHTML=resp.responseText;
                    },
                    onFailure: function(){
                    }
                }
            );

        }
    }

    function setTransfer(){
        document.getElementById("EditEncounterTransferDate").value="<%=new SimpleDateFormat("dd/MM/yyyy").format(new Date())%>";
        document.getElementById("EditEncounterTransferHour").value="<%=new SimpleDateFormat("HH:mm").format(new Date())%>";
        show("transfer");
    }

    function deleteRFE(serverid,objectid){
        if(confirm("<%=getTran(null,"Web","AreYouSure",sWebLanguage)%>")){
            var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=sEditEncounterUID%>&language=<%=sWebLanguage%>";
            var today = new Date();
            var url= '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+today;
            new Ajax.Request(url,{
                    method: "GET",
                    parameters: params,
                    onSuccess: function(resp){
                        rfe.innerHTML=resp.responseText;
                    },
                    onFailure: function(){
                    }
                }
            );
        }
    }

    calculateAccomodationDates();
    hide("transfer");
    
</script>
