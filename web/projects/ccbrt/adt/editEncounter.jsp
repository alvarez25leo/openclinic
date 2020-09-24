<%@page import="be.openclinic.system.Screen"%>
<%@page import="be.openclinic.adt.Encounter,
                be.openclinic.adt.Bed,java.util.*,
                be.openclinic.finance.Prestation,
                be.openclinic.finance.Debet,
                be.openclinic.finance.Insurance,
                java.util.Date,
                be.openclinic.medical.ReasonForEncounter,
                be.mxs.common.util.system.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"adt.encounter","all",activeUser)%>
<%=sJSDATE%>

<%!
    //--- GET DATE HOUR ---------------------------------------------------------------------------
    public java.util.Date getDateHour(String sDate, String sHour){
        String sTmpHour[] = sHour.split(":");
        java.util.Date d = null;
        try{
        	d = ScreenHelper.fullDateFormat.parse(sDate+" "+sHour);
        }
        catch(Exception e){
        	// empty
        }
        
		return d;
    }
%>

<%
	String sAction = checkString(request.getParameter("Action"));

	String sPopup    = checkString(request.getParameter("Popup")),
	       sReadOnly = checkString(request.getParameter("ReadOnly"));

    String sEditEncounterUID = checkString(request.getParameter("EditEncounterUID")),
           sEditEncounterType = checkString(request.getParameter("EditEncounterType")),
           sEditEncounterBegin = checkString(request.getParameter("EditEncounterBegin")),
           sEditEncounterBeginHour = checkString(request.getParameter("EditEncounterBeginHour")),
           sEditEncounterEnd = checkString(request.getParameter("EditEncounterEnd")),
           sEditEncounterReference = checkString(request.getParameter("EditEncounterReference")),
           sEditEncounterEndHour = checkString(request.getParameter("EditEncounterEndHour")),
           sEditEncounterCategories = checkString(request.getParameter("EditEncounterCategories"));
    
    if(sEditEncounterCategories.length()==0){
    	sEditEncounterCategories=MedwanQuery.getInstance().getConfigString("defaultEncounterCategory","A");
    }

    String sEditEncounterService = checkString(request.getParameter("EditEncounterService"));
    String sEditEncounterServiceName = checkString(request.getParameter("EditEncounterServiceName"));

    String sEditEncounterOrigin = checkString(request.getParameter("EditEncounterOrigin"));
    if(sEditEncounterOrigin.length()==0){
    	sEditEncounterOrigin = MedwanQuery.getInstance().getConfigString("defaultEncounterOrigin","");
    }
    String sEditEncounterDestination = checkString(request.getParameter("EditEncounterDestination"));
    String sEditEncounterDestinationName = checkString(request.getParameter("EditEncounterDestinationName"));

    String sEditEncounterBed = checkString(request.getParameter("EditEncounterBed"));
    String sEditEncounterBedName = checkString(request.getParameter("EditEncounterBedName"));

    String sEditEncounterPatient = checkString(request.getParameter("EditEncounterPatient"));
    String sEditEncounterPatientName = checkString(request.getParameter("EditEncounterPatientName"));

    String sEditEncounterManager = checkString(request.getParameter("EditEncounterManager")),
           sEditEncounterManagerName = checkString(request.getParameter("EditEncounterManagerName")),
           sEditEncounterOutcome = checkString(request.getParameter("EditEncounterOutcome")),
           sEditEncounterSituation = checkString(request.getParameter("EditEncounterSituation")),
           sEditEncounterAccomodationPrestation = checkString(request.getParameter("EditEncounterAccomodationPrestation")),
           sEditEncounterTransferDate = checkString(request.getParameter("EditEncounterTransferDate")),
           sEditEncounterTransferHour = checkString(request.getParameter("EditEncounterTransferHour")),
           sEditEncounterAccidentRecordNumber = checkString(request.getParameter("EditEncounterAccidentRecordNumber")),
           sEditEncounterAccidentImmat = checkString(request.getParameter("EditEncounterAccidentImmat")),
           sEditEncounterAccidentInsurer = checkString(request.getParameter("EditEncounterAccidentInsurer")),
           sEditEncounterAccidentNumber = checkString(request.getParameter("EditEncounterAccidentNumber"));
    
    String sAccountAccomodationDays = checkString(request.getParameter("AccountAccomodationDays"));
    if(sEditEncounterUID.length()==0 && sEditEncounterService.length()==0){
        sEditEncounterService=MedwanQuery.getInstance().getConfigString("defaultAdmissionService","");
        if(sEditEncounterService.length() > 0){
            Service service = Service.getService(sEditEncounterService);
            sEditEncounterServiceName=service.getLabel(sWebLanguage);
        }
        
        sEditEncounterManager = MedwanQuery.getInstance().getConfigString("defaultAdmissionManager","");
        if(sEditEncounterManager.length() > 0){
            UserVO user = MedwanQuery.getInstance().getUser(sEditEncounterManager);
            sEditEncounterManagerName = user.personVO.firstname.toUpperCase()+" "+user.personVO.lastname.toUpperCase();
        }
        sEditEncounterManager = MedwanQuery.getInstance().getConfigString("defaultAdmissionManager","");
    }

    Encounter tmpEncounter = null;
    boolean bActiveEncounterStatus;
    String sMaxTransferDate = "";
    
    if(Debug.enabled){
        Debug.println("\n************************ EDIT ENCOUNTER ************************");
        Debug.println("EditEncounterUID         : "+sEditEncounterUID);
        Debug.println("EncounterType            : "+sEditEncounterType);
        Debug.println("EncounterBegin           : "+sEditEncounterBegin);
        Debug.println("EncounterBeginHour       : "+sEditEncounterBeginHour);
        Debug.println("EncounterEnd             : "+sEditEncounterEnd);
        Debug.println("EncounterEndHour         : "+sEditEncounterEndHour);
        Debug.println("EncounterPatient         : "+sEditEncounterPatient);
        Debug.println("EncounterPatientName     : "+sEditEncounterPatientName);
        Debug.println("EncounterManager         : "+sEditEncounterManager);
        Debug.println("EncounterManagerName     : "+sEditEncounterManagerName);
        Debug.println("EncounterService         : "+sEditEncounterService);
        Debug.println("EncounterServiceName     : "+sEditEncounterServiceName);
        Debug.println("EncounterDestination     : "+sEditEncounterDestination);
        Debug.println("EncounterDestinationName : "+sEditEncounterDestinationName);
        Debug.println("EncounterBed             : "+sEditEncounterBed);
        Debug.println("EncounterBedName         : "+sEditEncounterBedName);
        Debug.println("AccountAccomodationDays  : "+sAccountAccomodationDays+"\n");
    }
    
    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("SAVE")){
        String sCloseActiveEncounter = checkString(request.getParameter("CloseActiveEncounter"));

        if(sCloseActiveEncounter.equals("CLOSE")){
            Debug.println("*** Closing active encounter ***");
            Encounter eActiveEncounter = Encounter.getActiveEncounter(activePatient.personid);
            eActiveEncounter.setEnd(ScreenHelper.getSQLDate(sEditEncounterBegin));
            eActiveEncounter.store();
        }

        tmpEncounter = new Encounter();
        if(sEditEncounterUID.length() > 0){//update
            tmpEncounter = Encounter.get(sEditEncounterUID);
        }
        else{
        	//insert
            tmpEncounter.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }
        tmpEncounter.setType(sEditEncounterType);


        tmpEncounter.setBegin(getDateHour(sEditEncounterBegin, sEditEncounterBeginHour));
        if(sEditEncounterEnd.length() > 0){
            tmpEncounter.setEnd(getDateHour(sEditEncounterEnd, sEditEncounterEndHour));
        } else{
            tmpEncounter.setEnd(null);
        }
        tmpEncounter.setOutcome(sEditEncounterOutcome);
        tmpEncounter.setSituation(sEditEncounterSituation);
        tmpEncounter.setCategories(sEditEncounterCategories);
		tmpEncounter.setEtiology(sEditEncounterReference);

        Service tmpService, tmpDestination;
        Bed tmpBed = null;
        AdminPerson tmpPatient;
        tmpService = Service.getService(sEditEncounterService);

        if(sEditEncounterType.equals("admission")){
            tmpBed = Bed.get(sEditEncounterBed);
        }
        tmpDestination = Service.getService(sEditEncounterDestination);
        tmpPatient = AdminPerson.getAdminPerson(sEditEncounterPatient);

        User tmpManager = new User();
        if(sEditEncounterManager.length() > 0){
            tmpManager.initialize(Integer.parseInt(sEditEncounterManager));
        }

        if(tmpService==null){
            tmpService = new Service();
        }
        if(tmpDestination==null){
            tmpDestination = new Service();
        }
        if(tmpBed==null || sEditEncounterType.equalsIgnoreCase("visit")){
            tmpBed = new Bed();
        }
        if(tmpPatient==null){
            tmpPatient = new AdminPerson();
        }
        if(tmpManager==null){
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
        if(sEditEncounterTransferDate.length()>0){
            if(sEditEncounterTransferHour.length()==0){
                sEditEncounterTransferHour = "00:00";
            }
            tmpEncounter.setTransferDate(getDateHour(sEditEncounterTransferDate, sEditEncounterTransferHour));
        }

        tmpEncounter.store();

        if(request.getParameter("DoAccountAccomodationDays")!=null && sAccountAccomodationDays.length() > 0){
            try {
                int accountAccomodationDays = Integer.parseInt(sAccountAccomodationDays);
                if(accountAccomodationDays!=0){
                    Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
                    if(insurance==null){
                        out.print("<script>alertDialog('web','no_insurance_available');</script>");
                    }
                    else{
                        Prestation accomodationPrestation = Prestation.get(sEditEncounterAccomodationPrestation);
                        if(accomodationPrestation==null){
                            out.print("<script>alertDialog('web','no_accomodation_prestation_defined');</script>");
                        }
                        else{
                            Debet debet = new Debet();
                            debet.setQuantity(accountAccomodationDays);
                            double patientAmount=0,insurarAmount=0;
                            
        	                double dPrice = accomodationPrestation.getPrice(insurance.getType());
                            if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==1){
                            	dPrice+=accomodationPrestation.getSupplement();
                            }
                            
        	                double dInsuranceMaxPrice = accomodationPrestation.getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
        	                if(tmpEncounter!=null && tmpEncounter.getType().equalsIgnoreCase("admission") && accomodationPrestation.getMfpAdmissionPercentage()>0){
        	                	dInsuranceMaxPrice = accomodationPrestation.getInsuranceTariff(insurance.getInsurar().getUid(),"*H");
        	                }
        	                
        	                String sShare=checkString(accomodationPrestation.getPatientShare(insurance)+"");
        	                if(sShare.length()>0){
        	                	patientAmount = accountAccomodationDays * dPrice * Double.parseDouble(sShare) / 100;
        	                    insurarAmount = accountAccomodationDays * dPrice - patientAmount;
        	                 
        	                    if(dInsuranceMaxPrice>=0){
        	                    	insurarAmount=accountAccomodationDays * dInsuranceMaxPrice;
        	                   		patientAmount=accountAccomodationDays * dPrice - insurarAmount;
        	                    }
        	                    if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==0){
        	                    	patientAmount+=accountAccomodationDays*accomodationPrestation.getSupplement();
        	                    }
        	                }
                            if(insurance.getInsurar()!=null && accomodationPrestation.isVisibleFor(insurance.getInsurar(),tmpService)){
	                            debet.setAmount(patientAmount);
	                            debet.setInsurarAmount(insurarAmount);
	                            debet.setPrestationUid(accomodationPrestation.getUid());
	                            debet.setInsuranceUid(insurance.getUid());
	                            debet.setDate(new Date());
	                            debet.setEncounterUid(tmpEncounter.getUid());
	                            debet.setCreateDateTime(new Date());
	                            debet.setUpdateDateTime(new Date());
	                            debet.setUpdateUser(activeUser.userid);
	                            debet.setServiceUid(tmpEncounter.getServiceUID());
	                            debet.store();
                            }	                            
                        }
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        // Accident de travail
        if(sEditEncounterCategories.equalsIgnoreCase("C")){
            Pointer.deletePointers("ENCOUNTER.ACCIDENT.IMMAT."+tmpEncounter.getUid());
            if(sEditEncounterAccidentImmat.length()>0){
            	Pointer.storePointer("ENCOUNTER.ACCIDENT.IMMAT."+tmpEncounter.getUid(),sEditEncounterAccidentImmat);
            }
            
            Pointer.deletePointers("ENCOUNTER.ACCIDENT.RECORDNUMBER."+tmpEncounter.getUid());
            if(sEditEncounterAccidentRecordNumber.length()>0){
            	Pointer.storePointer("ENCOUNTER.ACCIDENT.RECORDNUMBER."+tmpEncounter.getUid(),sEditEncounterAccidentRecordNumber);
            }
        }
        
        // Accident de circulation
        if(sEditEncounterCategories.equalsIgnoreCase("D")){
            Pointer.deletePointers("ENCOUNTER.ACCIDENT.INSURER."+tmpEncounter.getUid());
            if(sEditEncounterAccidentInsurer.length()>0){
            	Pointer.storePointer("ENCOUNTER.ACCIDENT.INSURER."+tmpEncounter.getUid(),sEditEncounterAccidentInsurer);
            }
            
            Pointer.deletePointers("ENCOUNTER.ACCIDENT.NUMBER."+tmpEncounter.getUid());
            if(sEditEncounterAccidentNumber.length()>0){
            	Pointer.storePointer("ENCOUNTER.ACCIDENT.NUMBER."+tmpEncounter.getUid(),sEditEncounterAccidentNumber);
            }
        }

        sEditEncounterUID = checkString(tmpEncounter.getUid());
        if(sPopup.equalsIgnoreCase("yes")){
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
              window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
            </script>
        <%
    }
    
    String sRfe = "";
    if(sEditEncounterUID.length() > 0){
        sRfe = ReasonForEncounter.getReasonsForEncounterAsHtml(sEditEncounterUID,sWebLanguage,"_img/icons/icon_delete.png","deleteRFE($serverid,$objectid)");
        tmpEncounter = Encounter.get(sEditEncounterUID);
		if(tmpEncounter!=null && tmpEncounter.getMaxTransferDate()!=null){
			sMaxTransferDate = ScreenHelper.stdDateFormat.format(tmpEncounter.getMaxTransferDate());
		}
        sEditEncounterType = checkString(tmpEncounter.getType());
        sEditEncounterBegin = checkString(ScreenHelper.stdDateFormat.format(tmpEncounter.getBegin()));
        sEditEncounterBeginHour = checkString(ScreenHelper.hourFormat.format(tmpEncounter.getBegin()));
		sEditEncounterReference = checkString(tmpEncounter.getEtiology());
        
        if(tmpEncounter.getEnd()==null){
            sEditEncounterEnd = "";
        }else{
            sEditEncounterEnd = checkString(ScreenHelper.stdDateFormat.format(tmpEncounter.getEnd()));
            sEditEncounterEndHour = checkString(ScreenHelper.hourFormat.format(tmpEncounter.getEnd()));
        }

        if(tmpEncounter.getService()==null){
            sEditEncounterService = "";
            sEditEncounterServiceName = "";
        }else{
            sEditEncounterService = checkString(tmpEncounter.getService().code);
            sEditEncounterServiceName = checkString(getTran(request,"Service",tmpEncounter.getService().code,sWebLanguage));
        }
        
        if(tmpEncounter.getDestination()==null || checkString(tmpEncounter.getDestination().code).length()==0){
            sEditEncounterDestination = "";
            sEditEncounterDestinationName = "";
        }else{
            sEditEncounterDestination = checkString(tmpEncounter.getDestination().code);
            sEditEncounterDestinationName = checkString(getTran(request,"Service",tmpEncounter.getDestination().code,sWebLanguage));
        }

        if(tmpEncounter.getBed()==null){
            sEditEncounterBed = "";
            sEditEncounterBedName = "";
        }else{
            sEditEncounterBed = checkString(tmpEncounter.getBed().getUid());
            sEditEncounterBedName = (tmpEncounter.getBed().getServiceUID()==null?"":tmpEncounter.getBed().getServiceUID()+": ")+checkString(tmpEncounter.getBed().getName());
        }
        
		sEditEncounterCategories = checkString(tmpEncounter.getCategories());
        sEditEncounterPatient = checkString(tmpEncounter.getPatient().personid);
        sEditEncounterOrigin = checkString(tmpEncounter.getOrigin());
        sEditEncounterPatientName = checkString(ScreenHelper.getFullPersonName(tmpEncounter.getPatient().personid));
        sEditEncounterOutcome = checkString(tmpEncounter.getOutcome());
        sEditEncounterSituation = checkString(tmpEncounter.getSituation());

        if(tmpEncounter.getManager()==null){
            sEditEncounterManager = "";
            sEditEncounterManagerName = "";
        }
        else{
            sEditEncounterManager = checkString(tmpEncounter.getManager().userid);
            sEditEncounterManagerName = checkString(ScreenHelper.getFullUserName(tmpEncounter.getManager().userid));
        }

        sEditEncounterUID = checkString(tmpEncounter.getUid());
        sEditEncounterAccidentNumber=Pointer.getPointer("ENCOUNTER.ACCIDENT.NUMBER."+tmpEncounter.getUid());
        sEditEncounterAccidentRecordNumber=Pointer.getPointer("ENCOUNTER.ACCIDENT.RECORDNUMBER."+tmpEncounter.getUid());
        sEditEncounterAccidentInsurer=Pointer.getPointer("ENCOUNTER.ACCIDENT.INSURER."+tmpEncounter.getUid());
        sEditEncounterAccidentImmat=Pointer.getPointer("ENCOUNTER.ACCIDENT.IMMAT."+tmpEncounter.getUid());
    }
    else{
        sEditEncounterType = MedwanQuery.getInstance().getConfigString("defaultEncounterType","visit");
    }

    if(!(sEditEncounterPatient.length() > 0)){
        sEditEncounterPatient = checkString(activePatient.personid);
    }
    if(!(sEditEncounterBegin.length() > 0)){
        sEditEncounterBegin = getDate();
    }
    if(!(sEditEncounterBeginHour.length() > 0)){
        sEditEncounterBeginHour = ScreenHelper.hourFormat.format(new java.util.Date());
    }
%>

<%
    if(sPopup.equalsIgnoreCase("yes")){
		%><form onclick="calculateAccomodationDates();" name='EditEncounterForm' id="EditEncounterForm" method='POST' action='<c:url value="/adt/template.jsp"/>?Page=editEncounter.jsp&ts=<%=getTs()%>'><%
    }
    else{
		%><form onclick="calculateAccomodationDates();" name='EditEncounterForm' id="EditEncounterForm" method='POST' action='<c:url value="/main.do"/>?Page=adt/editEncounter.jsp&ts=<%=getTs()%>'><%
    }

    String sOther = "";
    if(!sPopup.equalsIgnoreCase("yes")){
        sOther = " doBack();";
    }
%>

    <%=writeTableHeader("Web.manage","manageEncounters",sWebLanguage,sOther)%>
    
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- type --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","type",sWebLanguage)%> *</td>
            <td class='admin2'>
            <%
            	if(sEditEncounterUID.split("\\.").length<=1 ||sEditEncounterType.length()==0){
            %>
                <select class='text' id='EditEncounterType' name='EditEncounterType' onchange="checkEncounterType();">
                    <%
                        String encountertypes = MedwanQuery.getInstance().getConfigString("encountertypes","admission,visit");
                        String sOptions[] = encountertypes.split(",");

                        for(int i=0;i<sOptions.length;i++){
                            out.print("<option value='"+sOptions[i]+"' ");
                            if(sEditEncounterType.equalsIgnoreCase(sOptions[i])){
                                out.print(" selected");
                            }
                            out.print(">"+getTran(request,"web",sOptions[i],sWebLanguage)+"</option>");
                        }
                    %>
                </select>
            <%
            	}
            	else{
            %>
            	<label class='text' width='20'><b><%=getTranNoLink("web",sEditEncounterType,sWebLanguage)%></b></label>
            	<input type='hidden' id='EditEncounterType' name='EditEncounterType' value='<%=sEditEncounterType%>'/>
            <%
            	}
            %>
            </td>
        </tr>
        
        <%-- date begin --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","begindate",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeDateField("EditEncounterBegin","EditEncounterForm",sEditEncounterBegin+"' onkeyup='calculateAccomodationDates();' onclick='calculateAccomodationDates();' onchange='calculateAccomodationDates();",sWebLanguage)%>
                <input class="text" name="EditEncounterBeginHour" value="<%=sEditEncounterBeginHour%>" size="5" onkeyup='calculateAccomodationDates();' onblur="checkTime(this);calculateAccomodationDates();" onkeypress="keypressTime(this)">
            </td>
        </tr>
        
        <%-- date end --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","enddate",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeDateField("EditEncounterEnd","EditEncounterForm",sEditEncounterEnd+"' onkeyup='calculateAccomodationDates();' onclick='calculateAccomodationDates();' onchange='calculateAccomodationDates();",sWebLanguage)%>
                <input class="text" name="EditEncounterEndHour" value="<%=sEditEncounterEndHour%>" size="5" onkeyup='calculateAccomodationDates();' onblur="checkTime(this);calculateAccomodationDates();" onkeypress="keypressTime(this)">
            </td>
        </tr>
                
        <%-- origin --%>
        <tr>
            <td class="admin"><%=getTran(request,"openclinic.chuk","urgency.origin",sWebLanguage)%> *</td>
            <td class="admin2">
                <select class="text" name="EditEncounterOrigin">
                    <option/>
                    <%=ScreenHelper.writeSelect(request,"urgency.origin",sEditEncounterOrigin,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <input type='hidden' name='EditEncounterPatient' value='<%=sEditEncounterPatient%>'>
        
        <%-- service --%>
        <tr id="Service">
            <td class="admin"><%=getTran(request,"web","service",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input type="hidden" name="EditEncounterService" id="EditEncounterService" value="<%=sEditEncounterService%>" onchange="EditEncounterForm.EditEncounterBed.value='';EditEncounterForm.EditEncounterBedName.value='';setBedButton();setTransfer();changeService();">
                <input class="text" type="text" name="EditEncounterServiceName" id="EditEncounterServiceName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterServiceName%>" >
                
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"web","select",sWebLanguage)%>" onclick="searchService('EditEncounterService','EditEncounterServiceName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","clear",sWebLanguage)%>" onclick="EditEncounterForm.EditEncounterService.value='';EditEncounterForm.EditEncounterServiceName.value='';">
            </td>
        </tr>
        
        <%-- manager --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","manager",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="EditEncounterManager" id="EditEncounterManager" value="<%=sEditEncounterManager%>">
                <input class="text" type="text" name="EditEncounterManagerName" id="EditEncounterManagerName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterManagerName%>">
               
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"web","select",sWebLanguage)%>" onclick="searchManager('EditEncounterManager','EditEncounterManagerName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","clear",sWebLanguage)%>" onclick="EditEncounterForm.EditEncounterManager.value='';EditEncounterForm.EditEncounterManagerName.value='';">
            </td>
        </tr>
        
       <%-- transfer --%>
       <tr id="transfer" style="visibility:visible;">
           <td class="admin"><%=getTran(request,"web","transferdate",sWebLanguage)%></td>
           <td class='admin2'>
               <%=writeDateField("EditEncounterTransferDate","EditEncounterForm","",sWebLanguage)%>
               <input class="text" id="EditEncounterTransferHour" name="EditEncounterTransferHour" value="" size="5" onblur="checkTime(this)"/>
           </td>
       </tr>
       
       <%-- bed --%>
       <tr id="Bed" style="visibility:visible;">
            <td class="admin"><%=getTran(request,"web","bed",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="hidden" name="EditEncounterBed" id="EditEncounterBed" value="<%=sEditEncounterBed%>" onchange="setBedButton();">
                <input class="text" type="text" name="EditEncounterBedName" id="EditEncounterBedName" size="<%=sTextWidth%>" value="<%=sEditEncounterBedName%>" readonly>
               
                <img src="<c:url value="/_img/icons/icon_search.png"/>" id="SearchBedButton" class="link" alt="<%=getTran(null,"web","select",sWebLanguage)%>" onclick="searchBed('EditEncounterBed','EditEncounterBedName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","clear",sWebLanguage)%>" onclick="EditEncounterForm.EditEncounterBed.value='';EditEncounterForm.EditEncounterBedName.value='';">
            </td>
        </tr>
        
        <%-- INTERNAL TRANSFERS --%>
        <tr id="internaltransfers">
            <td class="admin"><%=getTran(request,"web","internal.transfers",sWebLanguage)%></td>
            <td class="admin2">
                <div id="divServices">
                    <table width="100%">
                <%
                    if(tmpEncounter!=null){
                        Hashtable username;
                        
                        Encounter.EncounterService encounterService = tmpEncounter.getLastEncounterService();
                        if(encounterService!=null && encounterService.end==null){
                            username = User.getUserName(encounterService.managerUID);
                            
                            %>
                            <tr>
                                <td width="25"><img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","delete",sWebLanguage)%>" onclick="deleteService('<%=encounterService.serviceUID%>')"></td>
                                <td width="200"><%=ScreenHelper.formatDate(encounterService.begin)+" - "%></td>
                                <td><b><%=getTran(request,"Service",encounterService.serviceUID, sWebLanguage)%></b></td>
                                <td><%=getTran(request,"web","bed",sWebLanguage)+": "+checkString(Bed.get(encounterService.bedUID).getName())%></td>
                                <td><%=getTran(request,"web","manager",sWebLanguage)+": "+(username!=null?username.get("firstname")+" "+username.get("lastname"):"")%></td>
                            </tr>
                            <%
                        }

                        Vector transferHistory = tmpEncounter.getTransferHistory();
                        for(int n=0; n<transferHistory.size(); n++){
                            encounterService = (Encounter.EncounterService)transferHistory.elementAt(n);
                            username = User.getUserName(encounterService.managerUID);
                            
                            %>
                            <tr>
                                <td width="25"><img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","delete",sWebLanguage)%>" onclick="deleteService('<%=encounterService.serviceUID%>')"></td>
                                <td width="200"><%=ScreenHelper.formatDate(encounterService.begin)+" - "+ScreenHelper.fullDateFormat.format(encounterService.end)%></td>
                                <td><b><%=getTran(request,"Service",encounterService.serviceUID,sWebLanguage)%></b></td>
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
        
        <%-- SITUATION --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","situation",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="EditEncounterSituation" style="vertical-align:top;">
                    <%=ScreenHelper.writeSelectUnsorted(request,"encounter.situation",sEditEncounterSituation,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- OUTCOME --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","outcome",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="EditEncounterOutcome" style="vertical-align:top;">
                    <option value=""><%=getTran(request,"web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelectUnsorted(request,"encounter.outcome",sEditEncounterOutcome,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- DESTINATION --%>
        <tr id="Destination" style="visibility:visible;">
            <td class="admin"><%=getTran(request,"web","destination",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="hidden" name="EditEncounterDestination" value="<%=sEditEncounterDestination%>">
                <input class="text" type="text" name="EditEncounterDestinationName" id="EditEncounterDestinationName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterDestinationName%>" >
               
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"web","select",sWebLanguage)%>" onclick="searchService('EditEncounterDestination','EditEncounterDestinationName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","clear",sWebLanguage)%>" onclick="EditEncounterForm.EditEncounterDestination.value='';EditEncounterForm.EditEncounterDestinationName.value='';">
            </td>
        </tr>
        
        <%-- CATEGORY --%>
        <tr id="Category" style="visibility:visible;">
            <td class="admin"><%=getTran(request,"web","category",sWebLanguage)%></td>
            <td class='admin2'>
                <input type='radio' class="hand" onClick='setcategoryfields()' id='EditEncounterCategoriesA' name='EditEncounterCategories' value='A' ondblclick='this.checked=!this.checked' <%=sEditEncounterCategories.indexOf("A")>=0?"checked":"" %>/><%=getLabel(request,"web","mfp.disease.natural",sWebLanguage,"EditEncounterCategoriesA")%>&nbsp;
                <input type='radio' class="hand" onClick='setcategoryfields()' id='EditEncounterCategoriesB' name='EditEncounterCategories' value='B' ondblclick='this.checked=!this.checked' <%=sEditEncounterCategories.indexOf("B")>=0?"checked":"" %>/><%=getLabel(request,"web","mfp.disease.professional",sWebLanguage,"EditEncounterCategoriesB")%>&nbsp;
                <input type='radio' class="hand" onClick='setcategoryfields()' id='EditEncounterCategoriesC' name='EditEncounterCategories' value='C' ondblclick='this.checked=!this.checked' <%=sEditEncounterCategories.indexOf("C")>=0?"checked":"" %>/><%=getLabel(request,"web","mfp.disease.work",sWebLanguage,"EditEncounterCategoriesC")%>&nbsp;
                <input type='radio' class="hand" onClick='setcategoryfields()' id='EditEncounterCategoriesD' name='EditEncounterCategories' value='D' ondblclick='this.checked=!this.checked' <%=sEditEncounterCategories.indexOf("D")>=0?"checked":"" %>/><%=getLabel(request,"web","mfp.disease.traffic",sWebLanguage,"EditEncounterCategoriesD")%>&nbsp;
                <input type='radio' class="hand" onClick='setcategoryfields()' id='EditEncounterCategoriesE' name='EditEncounterCategories' value='E' ondblclick='this.checked=!this.checked' <%=sEditEncounterCategories.indexOf("E")>=0?"checked":"" %>/><%=getLabel(request,"web","mfp.disease.other",sWebLanguage,"EditEncounterCategoriesE")%>&nbsp;
            </td>
        </tr>

        <%-- Know CCBRT from where? --%>
        	    <%-- 1 - actual complaints --%>
       	<%	
       		String lastEtiology = Encounter.lastEtiology(activePatient.personid);
       		if(lastEtiology.length()==0 || lastEtiology.equalsIgnoreCase(sEditEncounterUID)){
       	%>
	    <tr>
	       	<input type="hidden" id="reference" name="EditEncounterReference" value="<%=sEditEncounterReference%>"/>
	        <td class="admin"><%=getTran(request,"web","ccbrt.reference",sWebLanguage)%>&nbsp;*&nbsp;</td>
	        <td class="admin2" colspan="5">	
	        	<table width='100%'>
			        <%
			            String sReferences = sEditEncounterReference;
			        
			        	Label label;
			        	int counter = 0;
			        	Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
			        	if(labelTypes !=null){
			                Hashtable labelIds = (Hashtable)labelTypes.get("ccbrt.reference");
			                if(labelIds!=null) {
			                    Enumeration idsEnum = labelIds.elements();
			                    Hashtable hSelected = new Hashtable();
			                    while (idsEnum.hasMoreElements()) {
			                        label = (Label)idsEnum.nextElement();
			                        hSelected.put(label.value.toUpperCase(),label.id);
			                    }
			                    
			                    Vector keys = new Vector(hSelected.keySet());
			                    Collections.sort(keys);
			                    Iterator it = keys.iterator();
			                    String sLabelValue, sLabelID;
			                    while(it.hasNext()){
			                        sLabelValue = (String)it.next();
			                        sLabelID = (String)hSelected.get(sLabelValue);
			                        if(counter % 4 ==0){
			                        	if(counter>0){
			                        		out.println("</tr>");
			                        	}
			                        	out.println("<tr>");
			                        }
			                        counter++;
			                        
			       					%><td width='25%'><input class='hand' type="checkbox" name="reference.<%=sLabelID%>" id="reference.<%=sLabelID%>" value="<%=sLabelID%>" <%=sReferences.indexOf("*"+sLabelID+"*")>-1?"checked":"" %>/><label for="reference.<%=sLabelID%>" class="hand"><%=sLabelValue%></label></td><%
			                    }
			                }
			        	}
			        %>
		        	</tr>
	        	</table>
	        </td>
    	</tr>
        <%} %>
        <%-- ALREADY ACCOUNTED ACCOMODATION --%>
        <%
            int accountedDays = Encounter.getAccountedAccomodationDays(sEditEncounterUID);
            Vector accomodationDebets = Encounter.getAccountedAccomodations(sEditEncounterUID);
        %>
        <tr id="alreadyAccountedAccomodation"  style="visibility: <%=accomodationDebets.size()>0?"visible":"visible"%>;">
            <td class="admin"><%=getTran(request,"web","alreadyaccountedaccomodation",sWebLanguage)%> </td><td class='admin2'> = <%=Encounter.getAccountedAccomodationDays(sEditEncounterUID)%> <%=getTran(request,"web","days",sWebLanguage)%><%=tmpEncounter!=null && tmpEncounter.getDurationInDays()>0?" = <label id='d2'>"+Encounter.getAccountedAccomodationDays(sEditEncounterUID)*100/tmpEncounter.getDurationInDays()+"</label>%":""%>
            <BR/>
            <%
                for(int n=0; n<accomodationDebets.size(); n++){
                    Debet debet = (Debet)accomodationDebets.elementAt(n);
                    if(debet==null && debet.getPrestation()==null){
                    	out.print(ScreenHelper.stdDateFormat.format(debet.getDate())+": <b>"+debet.getQuantity()+"</b> "+getTran(request,"web","days",sWebLanguage)+" ("+debet.getPrestation().getDescription()+") = <b>"+debet.getAmount()+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</b> ("+getTran(request,"web","insurar",sWebLanguage)+" = "+debet.getInsurarAmount()+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")</BR/>");
                    }
                }
            %>
            </td>
        </tr>
        
        <%-- NOT ACCOUNTED ACCOMODATION --%>
        <tr id="notAccountedAccomodation" style="display: hidden;">
            <td class="admin"><%=getTran(request,"web","notaccountedaccomodation",sWebLanguage)%></td>
            <td class='admin2'>
                <select class="text" name="EditEncounterAccomodationPrestation" id="EditEncounterAccomodationPrestation" style="vertical-align:top;">
                    <%
                    	String defaultStay = "";
	                    if(tmpEncounter!=null && tmpEncounter.getService()!=null && tmpEncounter.getService().stayprestationuid!=null){
	                    	defaultStay = tmpEncounter.getService().stayprestationuid;
	                    }
                    
                        Vector prestations = Prestation.getPrestationsByClass(MedwanQuery.getInstance().getConfigString("stayclass","stay"));
                        for(int n=0; n<prestations.size(); n++){
                            Prestation prestation = (Prestation)prestations.elementAt(n);
                            if(prestation!=null){
                                out.print("<option value='"+prestation.getUid()+"' "+(defaultStay.equalsIgnoreCase(prestation.getUid())?"selected":"")+">"+prestation.getCode()+": "+prestation.getDescription()+"</option>");
                            }
                        }
                    %>
                </select>
                <br/>
                
                <input type="checkbox" name="DoAccountAccomodationDays"/><%=getTran(request,"web","doinvoice",sWebLanguage)%> <input type="text" class="text" name="AccountAccomodationDays" size="4" value="<%=tmpEncounter!=null?tmpEncounter.getDurationInDays()-accountedDays:0%>"/> <%=getTran(request,"web","days",sWebLanguage)%> <%=tmpEncounter!=null?"("+getTran(request,"web","actualencounterduration",sWebLanguage)+" = "+tmpEncounter.getDurationInDays()+" "+getTran(request,"web","days",sWebLanguage)+")":""%>
            </td>
        </tr>
        <%
            if(tmpEncounter!=null && checkString(tmpEncounter.getType()).equalsIgnoreCase("admission") && tmpEncounter.getDurationInDays()>accountedDays){
                %><script>document.getElementById("notAccountedAccomodation").style.visibility="visible";</script><%
            }
        %>
        
        <%=ScreenHelper.setFormButtonsStart()%>
        <%
            if(!sReadOnly.equalsIgnoreCase("yes")){
                %><input class='button' type="button" id="saveButton" name="saveButton" value='<%=getTranNoLink("web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;<%
            }
            if(!sPopup.equalsIgnoreCase("yes") && !sReadOnly.equalsIgnoreCase("yes")){
                %><input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("web","back",sWebLanguage)%>' onclick="doBack();"><%
            }
            else{
                %><input type="button" class="button" name="buttonclose" value='<%=getTranNoLink("web","close",sWebLanguage)%>' onclick='window.close()'><%
            }
        %>
        <%=ScreenHelper.setFormButtonsStop()%>
        
        <%-- hidden fields --%>
        <input type="hidden" name="Action" value="">
        <input type="hidden" name="CloseActiveEncounter" value="">
        <input type="hidden" name="Popup" value="<%=sPopup%>">
        <input type="hidden" name="EditEncounterUID" value="<%=sEditEncounterUID%>">
        <input type="hidden" id="maxTransferDate" value="<%=sMaxTransferDate%>">
    </table>
    
    <%=getTran(request,"web","colored_fields_are_obligate",sWebLanguage)%>
</form>

<%
    if(sEditEncounterUID.length() > 0){
	    %>
	        <table class="list" width="100%" cellspacing="1">
	            <tr class="admin">
	                <td align="center"><a href="javascript:openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=sEditEncounterUID%>&ts=<%=getTs()%>',700,400);void(0);"><%=getTran(request,"openclinic.chuk","rfe",sWebLanguage)%> <%=getTran(request,"Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></a></td>
	            </tr>
	            <tr>
	                <td id="rfe"><%=sRfe%></td>
	            </tr>
	        </table>
	    <%
    }
    else{
        Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
        if(activeEncounter!=null && activeEncounter.getEnd()==null){
            bActiveEncounterStatus = true;
        }
        else{
            bActiveEncounterStatus = false;
        }

        if(bActiveEncounterStatus){
            %>
              <script>
                function closeActiveEncounter(){
                  EditEncounterForm.CloseActiveEncounter.value = "CLOSE";
                }

                if(yesnoDialogDirectText('<%=getTran(null,"adt.encounter","encounter_close",sWebLanguage)%>')){
                  window.location.href='<c:url value="/main.do?Page=adt/editEncounter.jsp&EditEncounterUID="/><%=activeEncounter.getUid()%>';
                }
                else{
                  history.back();
                }
              </script>
            <%
        }
    }
%>
    
<script>  
  dateFormat = "<%=ScreenHelper.stdDateFormat.toPattern()%>";
  
  if(EditEncounterForm.EditEncounterService.value==""){
    EditEncounterForm.SearchBedButton.disabled = true;
  }
  else{
    EditEncounterForm.SearchBedButton.disabled = false;
  }
  checkEncounterType();

  <%-- SET TIME --%>
  function setTime(field){
    document.getElementsByName(field)[0].value = (new Date().getHours()>10?new Date().getHours():"0"+new Date().getHours())+":"+
                                                 (new Date().getMinutes()>10?new Date().getMinutes():"0"+new Date().getMinutes());
  }
  
  <%-- SET BED BUTTON --%>
  function setBedButton(){
    if(EditEncounterForm.EditEncounterService.value=="" || EditEncounterForm.EditEncounterServiceName.value==""){
      EditEncounterForm.SearchBedButton.disabled = true;
      EditEncounterForm.EditEncounterBedName.value = "";
      EditEncounterForm.EditEncounterBed.value = "";
    }
    else{
      EditEncounterForm.SearchBedButton.disabled = false;
    }
  }

  <%-- SEARCH SERVICE --%>
  function searchService(serviceUidField,serviceNameField){
    var sNeedsBeds = "";
    if(serviceNameField!='EditEncounterDestinationName'){
	  if(document.getElementById("EditEncounterType").value=='admission'){
		sNeedsBeds = "&needsbeds=1";
	  }
	  else{
		sNeedsBeds = "&needsvisits=1";
	  }
    }
        
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarSelectDefaultStay=true&VarCode="+serviceUidField+"&VarText="+serviceNameField+sNeedsBeds);
    document.getElementById(serviceNameField).focus();
  }
    
  <%-- SET CATEGORY FIELDS --%>
  function setcategoryfields(){
  }

  <%-- SEARCH BED --%>
  function searchBed(bedUidField,bedNameField){
    openPopup("/_common/search/searchBed.jsp&ts=<%=getTs()%>&VarCode="+bedUidField+"&VarText="+bedNameField+"&ViewCode=off&ServiceUID="+EditEncounterForm.EditEncounterService.value);
    EditEncounterForm.EditEncounterBedName.focus();
  }

  <%-- SEARCH MANAGER --%>
  function searchManager(managerUidField,managerNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID="+EditEncounterForm.EditEncounterService.value+"&FindServiceName="+EditEncounterForm.EditEncounterServiceName.value);
    EditEncounterForm.EditEncounterManagerName.focus();
  }

  <%-- DO SAVE --%>
  function doSave(){
	if(EditEncounterForm.EditEncounterBegin.value==""){
      alertDialog("web","no_encounter_begindate");
      EditEncounterForm.EditEncounterBegin.focus();
    }
	else if(makeDate(EditEncounterForm.EditEncounterBegin.value)>new Date()){
      alertDialog("web","no_future_begindate");
      EditEncounterForm.EditEncounterBegin.focus();
    }
	else if(EditEncounterForm.EditEncounterBeginHour.value==""){
      alertDialog("web","no_future_beginhour");
      EditEncounterForm.EditEncounterBeginHour.focus();
	<%
	    if(sEditEncounterUID.length() > 0){
	%>
    }
	else if(EditEncounterForm.EditEncounterEnd.value!="" && makeDate(EditEncounterForm.EditEncounterEnd.value)<makeDate(document.getElementById("maxTransferDate").value)){
      alertDialog("web","encounter_enddate_before_maxtransfer");
      EditEncounterForm.EditEncounterEnd.focus();
	<%
	   	}
	%>        	        
    }
	else if(EditEncounterForm.EditEncounterEnd.value!="" && EditEncounterForm.EditEncounterEndHour.value==""){
      alertDialog("web","no_encounter_endhour");
      EditEncounterForm.EditEncounterEndHour.focus();            
    }
    else if(!checkDates()){
      alertDialog("web","encounter_invalid_enddate");
      EditEncounterForm.EditEncounterEndHour.focus();
    }
    else if((EditEncounterForm.EditEncounterOutcome.selectedIndex>0)&&(EditEncounterForm.EditEncounterEnd.value=="")){
      alertDialog("web","no_encounter_enddate");
      EditEncounterForm.EditEncounterEnd.focus();
    }
    else if((EditEncounterForm.EditEncounterType.value=='admission')&&(EditEncounterForm.EditEncounterOutcome.selectedIndex==0)&&(EditEncounterForm.EditEncounterEnd.value!="")){
      alertDialog("web","no_encounter_outcome");
      EditEncounterForm.EditEncounterOutcome.focus();
    }
    else if(EditEncounterForm.EditEncounterOrigin.value==""){
      alertDialog("web","encounter_invalid_origin");
      EditEncounterForm.EditEncounterOrigin.focus();
    }
    else if(EditEncounterForm.EditEncounterServiceName.value==""){
        alertDialog("web","no_encounter_service");
        EditEncounterForm.EditEncounterServiceName.focus();
    }
    else if(EditEncounterForm.EditEncounterTransferDate && !EditEncounterForm.EditEncounterTransferDate.value=="" && !EditEncounterForm.EditEncounterEnd.value=="" && makeDate(EditEncounterForm.EditEncounterTransferDate.value)>makeDate(EditEncounterForm.EditEncounterEnd.value)){
      alertDialog("web","encounter_invalid_transferdate");
      EditEncounterForm.EditEncounterTransferDate.focus();
    }
    else if(!categoryCheck()){
      alertDialog("web","encounter_invalid_categories");
      EditEncounterForm.EditEncounterCategories.focus();
    }
    else{
		var inputs = document.getElementsByTagName("input");
		for(var i = 0; i < inputs.length; i++) {
		  if(inputs[i].name.indexOf("reference.")==0 && inputs[i].checked) {
		  	document.getElementById("reference").value+="*"+inputs[i].value+"*";
		  }
		}
		if(EditEncounterForm.EditEncounterReference && EditEncounterForm.EditEncounterReference.value==""){
	        alertDialog("web","no_encounter_reference");
		}
		else{
	      EditEncounterForm.saveButton.disabled = true;
	      EditEncounterForm.Action.value = "SAVE";
	      EditEncounterForm.submit();
    	}
    }	
  }
	
  <%-- CATEGORY CHECK --%>
  function categoryCheck(){
   	<%
  		if(MedwanQuery.getInstance().getConfigInt("encounterDiseaseCategoryMandatory",0)==0){
   			out.print("return true;");
   		}
   	%>
   	for(var n=0; n<EditEncounterForm.EditEncounterCategories.length; n++){
  	  if(EditEncounterForm.EditEncounterCategories[n].checked){
    	return true;
      }
    }
    	
    return false;
  }
    
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  <%-- CHECK DATES --%>
  <%-- check if enddate is after begindate --%>
  function checkDates(){
    if(EditEncounterForm.EditEncounterEnd.value==""){
      return true;
    }

    var end   = makeDate(EditEncounterForm.EditEncounterEnd.value),
        begin = makeDate(EditEncounterForm.EditEncounterBegin.value);
    if(end < begin || end>new Date()){
      return false;
    }
    else{
      calculateAccomodationDates();
      return true;
    }
  }

  <%-- CALCULATE ACCOMODATION DATES --%>
  function calculateAccomodationDates(){
    if(EditEncounterForm.EditEncounterEnd.value.length>0 && EditEncounterForm.EditEncounterEndHour.value.length==0){
      EditEncounterForm.EditEncounterEndHour.value = "12:00";
      
      var sEndDate = EditEncounterForm.EditEncounterEnd.value;
      var dateParts = sEndDate.split("/");
      if(dateParts.length==3 && dateParts[2].length==4){
        if(isDate(dateParts[0],dateParts[1],dateParts[2])){
          var end = makeDate(sEndDate);
          var today = new Date();
          if(end.getYear()==today.getYear() && end.getMonth()==today.getMonth() && end.getDay()==today.getDay()){
            setTime("EditEncounterEndHour");
          }
        }
      }
    }
    else if(EditEncounterForm.EditEncounterEnd.value.length==0){
      EditEncounterForm.EditEncounterEndHour.value = "";
    }
        
    if(EditEncounterForm.EditEncounterBegin.value.split("/").length==3){
      if(isDate(EditEncounterForm.EditEncounterBegin.value.split("/")[0],EditEncounterForm.EditEncounterBegin.value.split("/")[1],EditEncounterForm.EditEncounterBegin.value.split("/")[2])){
        var begin = makeDate(EditEncounterForm.EditEncounterBegin.value);
        if(EditEncounterForm.EditEncounterBeginHour.value.split(":").length==2){
          begin.setTime(begin.getTime()+EditEncounterForm.EditEncounterBeginHour.value.split(":")[0]*60*60000+EditEncounterForm.EditEncounterBeginHour.value.split(":")[1]*60000);
        }
        
        var end = new Date();
        if(EditEncounterForm.EditEncounterEnd.value.split("/").length==3 && EditEncounterForm.EditEncounterEnd.value.split("/")[2].length==4){
          if(isDate(EditEncounterForm.EditEncounterEnd.value.split("/")[0],EditEncounterForm.EditEncounterEnd.value.split("/")[1],EditEncounterForm.EditEncounterEnd.value.split("/")[2])){
            end = makeDate(EditEncounterForm.EditEncounterEnd.value);
          }
        }
        
        if(EditEncounterForm.EditEncounterEndHour.value.split(":").length==2){
          end.setTime(end.getTime()+EditEncounterForm.EditEncounterEndHour.value.split(":")[0]*60*60000+EditEncounterForm.EditEncounterEndHour.value.split(":")[1]*60000);
        }
        <%
	    	if(MedwanQuery.getInstance().getConfigString("encounterDurationCalculationMethod","simple").equalsIgnoreCase("noLastDay")){
	            %>end = new Date(end.getFullYear(),end.getMonth(),end.getDate(),0,0,0,0);<%
	       	}
	    %>
        
	    if(end>=begin){
          var days = Math.ceil((end.getTime()-begin.getTime())/(24*3600*1000));
          var accounted = <%=Encounter.getAccountedAccomodationDays(sEditEncounterUID)%>;
          if(document.getElementById("d2")!=null){
            document.getElementById("d2").innerHTML = Math.round(accounted*100/days);
          }
                    
          if(days!=accounted && Math.ceil(days-accounted)!=0){
            document.getElementsByName("AccountAccomodationDays")[0].value=Math.ceil(days-accounted);
            if(EditEncounterForm.EditEncounterType.value=="admission"){
              show("notAccountedAccomodation");
            }
          }
          else{
            EditEncounterForm.DoAccountAccomodationDays.checked = false;
            hide("notAccountedAccomodation");
          }
        }
        else{
          EditEncounterForm.DoAccountAccomodationDays.checked = false;
          hide("notAccountedAccomodation");
        }
      }
    }
  }

  <%-- CHECK ENCOUNTER TYPE --%>
  <%-- display inputfields according to encounter type --%>
  function checkEncounterType(){
		//Clear encounterType related fields
		if(document.getElementById("EditEncounterService")) document.getElementById("EditEncounterService").value='';
		if(document.getElementById("EditEncounterServiceName")) document.getElementById("EditEncounterServiceName").value='';
		if(document.getElementById("EditEncounterManager")) document.getElementById("EditEncounterManager").value='';
		if(document.getElementById("EditEncounterManagerName")) document.getElementById("EditEncounterManagerName").value='';
		if(document.getElementById("EditEncounterBed")) document.getElementById("EditEncounterBed").value='';
		if(document.getElementById("EditEncounterBedName")) document.getElementById("EditEncounterBedName").value='';
    if(EditEncounterForm.EditEncounterType.value=="admission"){
      //document.getElementById("Service").style.display = "block";
      show("Bed");
      show("alreadyAccountedAccomodation");
      show("internaltransfers");
      calculateAccomodationDates();
    }
    else{
      EditEncounterForm.EditEncounterBed.value="";
      EditEncounterForm.EditEncounterBedName.value="";
      setBedButton();
      
      //document.getElementById("Service").style.display = "none";
      hide("Bed");
      document.getElementsByName('DoAccountAccomodationDays')[0].checked=false;
      hide("notAccountedAccomodation");
      hide("alreadyAccountedAccomodation");
      show("internaltransfers");
    }
  }

  <%-- DELETE SERVICE --%>
  function deleteService(sServiceID){
    if(yesnoDeleteDialog()){
      var url = "<c:url value='/adt/ajaxActions/editEncounterDeleteService.jsp'/>"+
                "?EncounterUID=<%=sEditEncounterUID%>"+
    		    "&ServiceUID="+sServiceID+
    		    "&ts="+new Date().getTime();
      document.getElementById('divServices').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/>&nbsp;Deleting";
      new Ajax.Updater("divServices",url,{
        evalScripts:true,
        onComplete:function(resp){
          $('divServices').innerHTML = resp.responseText;
        }
      });
    }
  }
    
  <%-- SET TRANSFER --%>
  function setTransfer(){
    document.getElementById("EditEncounterTransferDate").value = "<%=ScreenHelper.stdDateFormat.format(new Date())%>";
    document.getElementById("EditEncounterTransferHour").value = "<%=ScreenHelper.hourFormat.format(new Date())%>";
    show("transfer");
  }

  <%-- DELETE RFE --%>
  function deleteRFE(serverid,objectid){
    if(yesnoDeleteDialog()){
      var params = "serverid="+serverid+
                   "&objectid="+objectid+
                   "&encounterUid=<%=sEditEncounterUID%>"+
                   "&language=<%=sWebLanguage%>";
      var url = '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+new Date().getTime();
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          rfe.innerHTML = resp.responseText;
        }
      });
    }
  }

  <%-- CHANGE SERVICE --%>
  function changeService(){
    var url = '<c:url value="/adt/findServiceStayPrestation.jsp"/>'+
              '?serviceid='+document.getElementById('EditEncounterService').value+
              '&ts='+new Date().getTime();
    new Ajax.Request(url,{
      parameters: "",
      onSuccess: function(resp){
        var stayprestation = resp.responseText;
        var stays = document.getElementById('EditEncounterAccomodationPrestation').options;
        
        for(var n=0;n<stays.length;n++){
          if(stays[n].value==stayprestation){
            stays[n].selected=true;
          }
          else{
            stays[n].selected=false;
          }
        }
      }
    });
  }

  calculateAccomodationDates();
  hide("transfer");
  setcategoryfields();
</script>