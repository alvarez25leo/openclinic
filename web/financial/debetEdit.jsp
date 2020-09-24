<%@page import="be.openclinic.medical.Diagnosis"%>
<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.util.*" %>
<%@ page import="java.util.Date" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"financial.debet","select",activeUser)%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>

<%
try{
String sEditDebetUID = checkString(request.getParameter("EditDebetUID")),
sEditGroupIdx = checkString(request.getParameter("EditGroupIdx"));

    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd   = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*********************** financial/debetEdit.jsp **********************");
    	Debug.println("sEditDebetUID  : "+sEditDebetUID);
    	Debug.println("sEditGroupIdx  : "+sEditGroupIdx);  // Stijn   	
    	Debug.println("sFindDateBegin : "+sFindDateBegin);
    	Debug.println("sFindDateEnd   : "+sFindDateEnd);
    	Debug.println("sFindAmountMin : "+sFindAmountMin);
    	Debug.println("sFindAmountMax : "+sFindAmountMax+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sEditEncounterName = "",sEditDebetServiceUid="",sEditDebetServiceName="",sDefaultServiceUid="",sDefaultServiceName="";
    Debet debet;
    Encounter activeEncounter = null;
    if(activePatient!=null){
    	activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
    	if(activeEncounter!=null){
    		sEditDebetServiceUid=checkString(activeEncounter.getServiceUID());
	        if(sEditDebetServiceUid!=null){
	        	Service service = Service.getService(sEditDebetServiceUid);
	        	if(service!=null){
	        		sEditDebetServiceName=service.getLabel(sWebLanguage);
	        		sDefaultServiceUid=sEditDebetServiceUid;
	        		sDefaultServiceName=sEditDebetServiceName;
	        	}
	        }
    	}
    }

    if(sEditDebetUID.length() > 0){
    	MedwanQuery.getInstance().getObjectCache().removeObject("debet", sEditDebetUID);
        debet = Debet.get(sEditDebetUID);
        if(debet!=null){
	        sEditDebetServiceUid=debet.determineServiceUid(sEditDebetServiceUid);
	        if(sEditDebetServiceUid!=null){
	        	Service service = Service.getService(sEditDebetServiceUid);
	        	if(service!=null){
	        		sEditDebetServiceName=service.getLabel(sWebLanguage);
	        	}
	        }

	        Encounter encounter = debet.getEncounter();
	        if (encounter != null) {
	            sEditEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
	        }
        }
    }
    else {
        sEditDebetUID = "-1";

        debet = new Debet();
        debet.setQuantity(1);
        debet.setUid(sEditDebetUID);
        debet.setDate(ScreenHelper.getSQLDate(getDate()));
        if(activePatient!=null && activePatient.personid!=null){
	        Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
	        if (encounter != null) {
	            sEditEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
	            debet.setEncounter(encounter);
	            debet.setEncounterUid(checkString(encounter.getUid()));
	        }
        }
    }

%>
<form name='EditForm' id="EditForm" method='POST'>
    <%=writeTableHeader("web","debetEdit",sWebLanguage,"")%>
  
    <table class="menu" width="100%" cellspacing="0">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran(request,"web.occup","medwan.common.date",sWebLanguage)%></td>
            <td width="100"><%=getTran(request,"Web","Begin",sWebLanguage)%></td>
            <td width="150"><%=writeDateField("FindDateBegin","EditForm",sFindDateBegin,sWebLanguage)%></td>
            <td width="100"><%=getTran(request,"Web","end",sWebLanguage)%></td>
            <td><%=writeDateField("FindDateEnd","EditForm",sFindDateEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran(request,"web","amount",sWebLanguage)%></td>
            <td><%=getTran(request,"Web","min",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMin" value="<%=sFindAmountMin%>" onblur="isNumber(this)"></td>
            <td><%=getTran(request,"Web","max",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMax" value="<%=sFindAmountMax%>" onblur="isNumber(this)"></td>
        </tr>
        <tr>
            <td/>
            <td colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="loadUnassignedDebets()">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFindFields()">&nbsp;
                <% if(activeUser.getAccessRight("financial.debet.add")){ %>
	                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew()">&nbsp;
	            <% } %>
                <input type="button" class="button" name="ButtonDate" value="<%=getTranNoLink("Web","today",sWebLanguage)%>" onclick="document.getElementById('FindDateBegin').value='<%=ScreenHelper.stdDateFormat.format(new Date())%>';loadUnassignedDebets()">&nbsp;
            </td>
        </tr>
    </table>
    <br>
    
    <div id="divUnassignedDebets" class="searchResults" style="height:120px;"><img src="<c:url value="/_img/themes/default/ajax-loader.gif"/>"/><br/>Loading</div>
    <input class='text' readonly type='hidden' id='EditAmount' name='EditAmount' value='<%=debet.getAmount()+debet.getExtraInsurarAmount()%>' size='20'>
    <input class='text' readonly type='hidden' id='EditInsurarAmount' name='EditInsurarAmount' value='<%=debet.getInsurarAmount()%>' size='20'> 
    <br>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <tr>
            <td class='admin' width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","date",sWebLanguage)%> *</td>
            <td class='admin2'><%=ScreenHelper.writeDateField("EditDate","EditForm",ScreenHelper.getSQLDate(debet.getDate()),true,false,sWebLanguage,sCONTEXTPATH,"")%></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran(request,"Web","insurance",sWebLanguage)%> *</td>
            <td class='admin2'>
            	<input type="checkbox" name="EnableInsurance" id="EnableInsurance" checked  onchange="changeInsurance()"/>
                <select class="text" id='EditInsuranceUID' name="EditInsuranceUID" onchange="changeInsurance()">
                    <option/>
                    <%
                        Vector vInsurances = Insurance.getCurrentInsurances(activePatient.personid);
                        if (vInsurances!=null){
                            boolean bInsuranceSelected = false;
                            Insurance insurance,selectedInsurance;
							if(debet.getUid().equalsIgnoreCase("-1")){
								selectedInsurance = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
	                            for (int i=0;i<vInsurances.size();i++){
	                                insurance = (Insurance)vInsurances.elementAt(i);

	                                if (insurance!=null && insurance.isAuthorized() && insurance.getInsurar()!=null && insurance.getInsurar().getName()!=null && insurance.getInsurar().getName().trim().length()>0){
	                                    out.print("<option value='"+insurance.getUid()+"'");

	                                    if (selectedInsurance!=null && selectedInsurance.getUid().equals(insurance.getUid())){
	                                        out.print(" selected");
	                                        bInsuranceSelected = true;
	                                    }
	                                    else if (!bInsuranceSelected){
	                                        if(vInsurances!=null && vInsurances.size()==1){
	                                            out.print(" selected");
	                                            bInsuranceSelected = true;
	                                        }
	                                    }
                                        try{
                                        	out.print("/>"+insurance.getInsurar().getName()+" ("+insurance.getInsuranceCategory().getCategory()+": "+insurance.getInsuranceCategory().getPatientShare()+"/"+(100-Integer.parseInt(insurance.getInsuranceCategory().getPatientShare()))+")"+ (checkString(insurance.getInsuranceNr()).length()>0?" #"+insurance.getInsuranceNr():"")+"</option>");
                                        }
                                        catch(Exception e1){
                                        	out.print("/>"+insurance.getInsurar().getName()+ "</option>");
                                        }
	                                }
	                            }
							}
							else {
	                            for (int i=0;i<vInsurances.size();i++){
	                                insurance = (Insurance)vInsurances.elementAt(i);
	
	                                if (insurance!=null && insurance.isAuthorized() && insurance.getInsurar()!=null && insurance.getInsurar().getName()!=null && insurance.getInsurar().getName().trim().length()>0){
	                                    out.print("<option value='"+insurance.getUid()+"'");
	
	                                    if (checkString(debet.getInsuranceUid()).equals(insurance.getUid())){
	                                        out.print(" selected");
	                                        bInsuranceSelected = true;
	                                    }
	                                    else if (!bInsuranceSelected){
	                                        if(vInsurances.size()==1){
	                                            out.print(" selected");
	                                            bInsuranceSelected = true;
	                                        }
	                                        else if(insurance.getInsuranceCategory()!=null && insurance.getInsuranceCategory().getInsurarUid()!=null && !insurance.getInsuranceCategory().getInsurarUid().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("patientSelfIsurarUID","none"))){
	                                            out.print(" selected");
	                                            bInsuranceSelected = true;
	                                        }
	                                    }
	
                                        try{
                                        	out.print("/>"+insurance.getInsurar().getName()+" ("+insurance.getInsuranceCategory().getCategory()+": "+insurance.getInsuranceCategory().getPatientShare()+"/"+(100-Integer.parseInt(insurance.getInsuranceCategory().getPatientShare()))+")"+ (checkString(insurance.getInsuranceNr()).length()>0?" #"+insurance.getInsuranceNr():"")+"</option>");
                                        }
                                        catch(Exception e1){
                                        	out.print("/>"+insurance.getInsurar().getName()+ "</option>");
                                        }
	                                }
	                            }
							}
                        }
                        
                    %>
                </select>&nbsp;
                <%=getTran(request,"web","complementarycoverage",sWebLanguage)%>
                <select class="text" name="coverageinsurance" id="coverageinsurance" onchange="changeInsurance();checkCoverage();">
                    <option value=""></option>
					<%
						Insurance insurance=Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
						String extrainsurar="";
						if(insurance!=null && insurance.getExtraInsurarUid()!=null && insurance.getExtraInsurarUid().length()>0){
							extrainsurar=insurance.getExtraInsurarUid();
						}
						else{
							extrainsurar=MedwanQuery.getInstance().getConfigString("defaultExtraInsurar");
						}
						if(!debet.getUid().equalsIgnoreCase("-1")){
							extrainsurar=checkString(debet.getExtraInsurarUid());
						}
						
						Vector activeInsurances = Insurance.getCurrentInsurances(activePatient.personid);
						for(int n=0;n<activeInsurances.size();n++){
							Insurance ins = (Insurance)activeInsurances.elementAt(n);
							if(checkString(ins.getExtraInsurarUid()).length()>0){
								extrainsurar+="*"+ins.getExtraInsurarUid()+"*";
							}
						}
						Hashtable extrainsurars = (Hashtable)((Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase())).get("patientsharecoverageinsurance");
						if(extrainsurars!=null){
							Enumeration eExtrainsurars = extrainsurars.keys();
							while(eExtrainsurars.hasMoreElements()){
								String key = (String)eExtrainsurars.nextElement();
								//Check if the insurer needs approval
								boolean bCanAdd=false;
								Insurar insr = Insurar.get(key);
								if(insr!=null && insr.getNeedsApproval()==0){
									bCanAdd=true;
								}
								if((bCanAdd && insurance!=null) || (insurance!=null && extrainsurar!=null && extrainsurar.contains(key+"*"))){
									out.println("<option value='"+key+"' "+(checkString(insurance.getExtraInsurarUid()).equalsIgnoreCase(key)?"selected":"")+">"+getTran(request,"patientsharecoverageinsurance",key,sWebLanguage)+"</option>");								
								}
							}
						}
					%>
                </select>
            </td>
        </tr>
        <%
        	if(MedwanQuery.getInstance().getConfigInt("enableComplementaryInsurance2",0)==1){
        %>
        <tr>
            <td class='admin'><%=getTran(request,"Web","complementarycoverage2",sWebLanguage)%> *</td>
            <td class='admin2'>
                <select class="text" name="coverageinsurance2" id="coverageinsurance2" onchange="changeInsurance();checkCoverage();">
                    <option value=""></option>
					<%
						String extrainsurar2="";
						if(insurance!=null && insurance.getExtraInsurarUid2()!=null && insurance.getExtraInsurarUid2().length()>0){
							extrainsurar2=insurance.getExtraInsurarUid2();
						}
						if(!debet.getUid().equalsIgnoreCase("-1")){
							extrainsurar2=checkString(debet.getExtraInsurarUid2());
						}
						for(int n=0;n<activeInsurances.size();n++){
							Insurance ins = (Insurance)activeInsurances.elementAt(n);
							if(checkString(ins.getExtraInsurarUid2()).length()>0){
								extrainsurar2+="*"+ins.getExtraInsurarUid2()+"*";
							}
						}
						Hashtable extrainsurars2 = (Hashtable)((Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase())).get("patientsharecoverageinsurance2");
						if(extrainsurars2!=null){
							Enumeration eExtrainsurars2 = extrainsurars2.keys();
							while(eExtrainsurars2.hasMoreElements()){
								String key = (String)eExtrainsurars2.nextElement();
								//Check if the insurer needs approval
								boolean bCanAdd=false;
								Insurar insr = Insurar.get(key);
								if(insr!=null && insr.getNeedsApproval()==0){
									bCanAdd=true;
								}
								if(bCanAdd || extrainsurar2.contains(key+"*")){
									out.println("<option value='"+key+"' "+(checkString(insurance.getExtraInsurarUid2()).equalsIgnoreCase(key)?"selected":"")+">"+getTran(request,"patientsharecoverageinsurance2",key,sWebLanguage)+"</option>");								
								}
							}
						}
					%>
                </select>
              </td>
        </tr>
        <%
        	}
        %>
        <tr>
            <td class='admin'><%=getTran(request,"web","prestation",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input type="hidden" name="tmpPrestationUID">
                <input type="hidden" name="tmpPrestationName">
                <input type="hidden" name="tmpPrestationPrice"/>
                <input type="hidden" name="EditPrestationUID" value="<%=debet.getPrestationUid()%>">
                <%
					Prestation prestation = debet.getPrestation();
                	String sTitle="";
                	if(prestation!=null && checkString(prestation.getDescription()).length()>60){
                		sTitle=prestation.getDescription();
                	}
                
                %>

                <select title='<%=sTitle %>' class="text" name="EditPrestationName" id="EditPrestationName" onclick="this.title=this.options[this.selectedIndex].title" onchange="document.getElementById('EditPrestationGroup').value='';changePrestation(false);">
                    <option/>
                    <%
                        if (prestation!=null){
                            out.print("<option title='"+sTitle+"' selected value='"+checkString(prestation.getUid())+"'>"+checkString(prestation.getCode())+": "+checkString(prestation.getDescription(),60)+"</option>");
                        }

                        Vector vPopularPrestations = activeUser.getTopPopularPrestations(50);
                        if (vPopularPrestations!=null){
                            String sPrestationUid;
                            int total = 0;
                            for (int i=0;i<vPopularPrestations.size();i++){
                                sPrestationUid = checkString((String)vPopularPrestations.elementAt(i));
                                if (sPrestationUid.length()>0){
                                    prestation = Prestation.get(sPrestationUid);

                                    if (prestation!=null && prestation.getInactive()==0 && prestation.getDescription()!=null && prestation.getDescription().trim().length()>0 && !(debet.getPrestation()!=null && prestation.getUid().equals(debet.getPrestation().getUid()))){
                                    	sTitle="";
                                    	if(checkString(prestation.getDescription()).length()>60){
                                    		sTitle=prestation.getDescription();
                                    	}
                                        out.print("<option title='"+sTitle+"' value='"+checkString(prestation.getUid())+"'");

                                        if ((debet.getPrestationUid()!=null)&&(prestation!=null)&&(prestation.getUid()!=null)&&(prestation.getUid().equals(debet.getPrestationUid()))){
                                            out.print(" selected");
                                        }

                                        out.print(">"+checkString(prestation.getCode())+": "+checkString(prestation.getDescription(),60)+"</option>");
                                        total++;
                                        if(total>10){
                                        	break;
                                        }
                                    }
                                }
                            }
                        }
                    %>
                </select>
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="searchPrestation();">
				<%
					String showGroups="hidden";
					if(sEditDebetUID.length()==0 || sEditDebetUID.split("\\.").length<2){
						showGroups="visible";
					}
				%>
				<span name='groups' id='groups' style='visibility: <%=showGroups%>'>
					<%=getTran(request,"web","prestationgroups",sWebLanguage) %>
					<select class="text" name="EditPrestationGroup" id="EditPrestationGroup" onchange="document.getElementById('EditPrestationName').value='';changePrestation(false)">
	                    <option/>
						<%=ScreenHelper.getPrestationGroupOptions()%>
					</select>
					&nbsp;
					<input type='button' value='button' name='buttonquicklist' accesskey='Q' onclick='openQuicklist();' style='display: none'/>
					<a href="javascript:openQuicklist();"><%=getTran(request,"web","quicklist",sWebLanguage)%></a>
				</span>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran(request,"web","quantity",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' type='text' name='EditQuantity' id='EditQuantity' value='<%=debet.getQuantity()%>' size='4' onpaste='window.setTimeout("changePrestation(false);",100)' onkeyup='changePrestation(false);' onclick='window.setTimeout("changePrestation(false);",100)'>
            </td>
        </tr>
        <tr><td colspan='2' class='admin2' id='prestationcontent'>
        <%
	    	if(sEditDebetUID.length() > 0 && debet!=null && debet.getPrestation()!=null){
	    		// Stijn : updated whole paragraph below (contained mixed-up html)
	    		// Stijn : BUT I suppose you can just leave this static part out,
	    		// Stijn : these data are loaded by ajax at the end of the page
	    		out.print("<table width='100%' cellpadding='1' cellspacing='0'>");
	    		
	    		// header
	    	    out.print("<tr>"+
	                       "<td><b>"+getTran(request,"web","prestation",sWebLanguage)+"</b></td>"+
					       "<td><b>"+getTran(request,"web.finance","amount.patient",sWebLanguage)+"</b></td>"+
					       "<td><b>"+getTran(request,"web.finance","amount.insurar",sWebLanguage)+"</b></td>"+
					       "<td><b>"+getTranNoLink("web.finance","amount.complementaryinsurar",sWebLanguage)+"</b></td>"+
					       "<td><b>"+getTranNoLink("web","service",sWebLanguage)+"</b></td>"+
	                      "</tr>");
	    		
	    		// data
				String sNegociate="",sNegociate2="";
	    		prestation=debet.getPrestation();
		        if(activeUser.getAccessRight("financial.negotiate.tariff.select") && insurance.getInsurar().getAllowTariffNegociations()==1){
		        	sNegociate=" <img src='"+sCONTEXTPATH+"/_img/icons/icon_interactions.png' onclick='negotiate(\""+prestation.getUid()+"\")'/>";
		        }
		        if(activeUser.getAccessRight("financial.negotiate.tariff.select") && debet.getExtraInsurar()!=null && debet.getExtraInsurar().getAllowTariffNegociations()==1){
		        	sNegociate2=" <img src='"+sCONTEXTPATH+"/_img/icons/icon_interactions.png' onclick='negotiate2(\""+prestation.getUid()+"\")'/>";
		        }
				String coveragePct="";
				if(debet.getAmount()+debet.getInsurarAmount()!=0){
					coveragePct=" ("+Math.round(debet.getInsurarAmount()*100/(debet.getAmount()+debet.getInsurarAmount()))+"%)";
				}
	    		out.print("<tr>"+
	    		           "<td "+(debet.getExtraInsurarUid2()!=null && debet.getExtraInsurarUid2().length()>0?"class='strikeonly'":"")+">"+checkString(prestation.getCode())+": "+prestation.getDescription()+"</td>"+
	    		           "<td><span id='TPPP_"+prestation.getUid()+"'>"+debet.getAmount()+"</span> "+MedwanQuery.getInstance().getConfigParam("currency","RWF")+"</td>"+
	    		           "<td><span id='TPPI_"+prestation.getUid()+"'>"+debet.getInsurarAmount()+"</span> "+MedwanQuery.getInstance().getConfigParam("currency","RWF")+"<span id='TPPC_"+prestation.getUid()+"'>"+coveragePct+"</span>"+sNegociate+"</td>"+
	    		           "<td><span id='TPPE_"+prestation.getUid()+"'>"+debet.getExtraInsurarAmount()+"</span> "+MedwanQuery.getInstance().getConfigParam("currency","RWF")+sNegociate2+"</td>");
				String sServiceName = sEditDebetServiceName;
	    		if(prestation.getServiceUid()!=null && prestation.getServiceUid().length()>0){
					Service service = Service.getService(prestation.getServiceUid());
					if(service!=null){
						sServiceName=checkString(service.getLabel(sWebLanguage));
					}
					if(!sServiceName.equals(sEditDebetServiceName)){
						sServiceName="<font color='red'><b>"+sServiceName+"</b></font>";
					}
				}
		        out.println("<td>"+sServiceName+"</td>");
	            out.println("</tr>");
	    				
	            out.print("</table>");
	                       
				out.print("<input type='hidden' name='PPC_"+debet.getPrestationUid()+"' id='PPC_"+debet.getPrestationUid()+"' value='"+debet.getPrestation().getCode()+"'/>"+
				          "<input type='hidden' name='PPP_"+debet.getPrestationUid()+"' id='PPP_"+debet.getPrestationUid()+"' value='"+debet.getAmount()+"'/>"+
	                      "<input type='hidden' name='PPI_"+debet.getPrestationUid()+"' id='PPI_"+debet.getPrestationUid()+"' value='"+debet.getInsurarAmount()+"'/>"+
		                  "<input type='hidden' name='PPE_"+debet.getPrestationUid()+"' id='PPE_"+debet.getPrestationUid()+"' value='"+debet.getExtraInsurarAmount()+"'/>");
	    	}
        %>
        </td></tr>
        <tr>
            <td class='admin'><%=getTran(request,"web","encounter",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input type="hidden" name="EditEncounterUID" id="EditEncounterUID" value="<%=debet.getEncounterUid()%>">
                <input class="text" type="text" name="EditEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterName%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditEncounterUID','EditEncounterName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditEncounterUID.value='';EditForm.EditEncounterName.value='';">
            </td>
        </tr>
       <tr id="Service">
           <td class="admin"><%=getTran(request,"Web","linked.service",sWebLanguage)%></td>
           <td class='admin2'>
               <input type="hidden" name="EditDebetServiceUid" id="EditDebetServiceUid" value="<%=sEditDebetServiceUid%>">
               <input class="text" type="text" name="EditDebetServiceName" id="EditDebetServiceName" readonly size="<%=sTextWidth%>" value="<%=sEditDebetServiceName%>" >
               <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="alertcontinuity();searchService('EditDebetServiceUid','EditDebetServiceName');">
           </td>
       </tr>
		<tr>
		    <td class="admin" nowrap><%=getTran(request,"Web","indication",sWebLanguage)%>&nbsp;</td>
		    <td class="admin2">
		    	<select class='text' name='EditDiagnosis' id='EditDiagnosis'>
		    		<option/>
		    		<%
		    			Encounter encounter = null;
		    			if(debet!=null && checkString(debet.getEncounterUid()).length()>0){
		    				encounter=debet.getEncounter();
		    			}
		    			else{
		    				encounter = Encounter.getActiveEncounter(activePatient.personid);
		    			}
		    			if(encounter!=null && encounter.hasValidUid()){
		    				Vector diagnoses = Diagnosis.selectDiagnoses("", "", encounter.getUid(), "", "", "", "", "", "", "", "", "icd10", "OC_DIAGNOSIS_GRAVITY DESC");
		    				for(int n=0;n<diagnoses.size();n++){
		    					Diagnosis diagnosis = (Diagnosis)diagnoses.elementAt(n);
		    					out.println("<option "+(diagnosis.getUid().equalsIgnoreCase(debet.getDiagnosisUid())?"selected":"")+" value='"+diagnosis.getUid()+"'>"+diagnosis.getCode()+" - "+diagnosis.getLabel(sWebLanguage)+"</option>");
		    				}
		    			}
		    		%>
		    	</select>
		    </td>
		</tr>
        <tr>
            <td class='admin'><%=getTran(request,"web","invoicingcareprovider",sWebLanguage)+(MedwanQuery.getInstance().getConfigInt("invoicingCareProviderMandatory",0)==1?"*":"")%></td>
            <td class='admin2'>
            	<select class='text' name='EditCareProvider' id='EditCareProvider'>
            		<option value=''></option>
		            <%
		            	Vector users = UserParameter.getUserIdsExtended("invoicingcareprovider", "on");
		            	SortedSet usernames = new TreeSet();
		            	for(int n=0;n<users.size();n++){
		            		usernames.add(users.elementAt(n));
		            	}
		            	//Determine selected value
		            	String sSelectedValue="";
		            	if(!sEditDebetUID.equalsIgnoreCase("-1")){
		            		sSelectedValue=checkString(debet.getPerformeruid());
		            	}
		            	Iterator i = usernames.iterator();
		            	while(i.hasNext()){
		            		String u=(String)i.next();
		            		out.println("<option value='"+u.split(";")[2]+"'"+(sSelectedValue.equals(u.split(";")[2])?" selected":"")+">"+u.split(";")[0].toUpperCase()+", "+u.split(";")[1]+" ("+u.split(";")[2]+")</option>");
		            	}
		            %>
            	</select>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran(request,"web","invoices",sWebLanguage)%></td>
            <td class='admin2'>
                <table>
                	<tr>
                		<td class='admin2'><%=getTran(request,"web.finance","patientinvoice",sWebLanguage)%></td>
                		<td class='admin2'><input class='text' readonly type='text' name='EditPatientInvoiceUID' value='<%=checkString(debet.getPatientInvoiceUid())%>' size='20'></td>
			            <td class='admin2'><%=getTran(request,"web.finance","insurarinvoice",sWebLanguage)%></td>
			            <td class='admin2'>
			                <input class='text' readonly type='text' name='EditInsuranceInvoiceUID' value='<%=checkString(debet.getInsurarInvoiceUid())%>' size='20'>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin2'><%=getTran(request,"web","complementarycoverage",sWebLanguage)%></td>
			            <td class='admin2'>
			                <input class='text' readonly type='text' name='EditComplementaryInsuranceInvoiceUID' value='<%=checkString(debet.getExtraInsurarInvoiceUid())%>' size='20'>
			            </td>
			            <td class='admin2'><%=getTran(request,"web","complementarycoverage2",sWebLanguage)%></td>
			            <td class='admin2'>
			                <input class='text' readonly type='text' name='EditComplementaryInsuranceInvoiceUID2' value='<%=checkString(debet.getExtraInsurarInvoiceUid2())%>' size='20'>
			            </td>
                	</tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran(request,"web","comment",sWebLanguage)%></td>
            <td class='admin2'><input type="text" class="text" name="EditComment" id="EditComment" value="<%=checkString(debet.getComment()) %>" size="80" maxlength="255"/></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran(request,"web","canceled",sWebLanguage)%></td>
            <td class='admin2'><input <%=activeUser.getAccessRight("financial.debet.delete")?"":"disabled"%> type="checkbox" name="EditCredit" <%if (debet.getCredited()>0){out.print(" checked");}%> onclick="doCredit()"></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" id='buttonadmin'>
            <%
            	boolean canSave1=true,canSave2=true,canSave3=true,canSave4=true;
            	if(debet!=null && debet.getPatientInvoiceUid()!=null){
            		PatientInvoice invoice = PatientInvoice.get(debet.getPatientInvoiceUid());
            		if(invoice!=null && invoice.getStatus()!=null && !invoice.getStatus().equalsIgnoreCase("open")){
            			canSave1=false;
            		}
            	}
            	if(canSave1 && debet!=null && debet.getInsurarInvoiceUid()!=null){
            		InsurarInvoice invoice = InsurarInvoice.getWithoutDebetsOrCredits(debet.getInsurarInvoiceUid());
            		if(invoice!=null && invoice.getStatus()!=null && !invoice.getStatus().equalsIgnoreCase("open")){
            			canSave2=false;
            		}
            	}
            	if(canSave1 && canSave2 && debet!=null && debet.getExtraInsurarInvoiceUid()!=null){
            		ExtraInsurarInvoice invoice = ExtraInsurarInvoice.getWithoutDebetsOrCredits(debet.getExtraInsurarInvoiceUid());
            		if(invoice!=null && invoice.getStatus()!=null && !invoice.getStatus().equalsIgnoreCase("open")){
            			canSave3=false;
            		}
            	}
            	if(canSave1 && canSave2 && canSave3){
            		if((debet.getUid().split("\\.").length<2 && !activeUser.getAccessRight("financial.debet.add")) || (debet.getUid().split("\\.").length==2 && !activeUser.getAccessRight("financial.debet.edit"))){
            			canSave4=false;
            		}
            	}
            	if(canSave1 && canSave2 && canSave3 && canSave4){
            	%><input accesskey="S" class='button' type="button" name="buttonSave" id="buttonSave" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;<%
            	}
    			else if(!canSave1){
    			%><%=getTran(request,"Web","caredeliverylinkedtoclosedinvoice",sWebLanguage)%><br/><%
    			}
    			else if(!canSave2){
    			%><%=getTran(request,"Web","caredeliverylinkedtoclosedinsurarinvoice",sWebLanguage)%><br/><%
    			}
    			else if(!canSave3){
    			%><%=getTran(request,"Web","caredeliverylinkedtoclosedextrainsurarinvoice",sWebLanguage)%><br/><%
    			}
            	%>
                <input accesskey="P" class='button' type="button" name="buttonInvoice" value='<%=getTranNoLink("Web","patientInvoiceEdit",sWebLanguage)%>' onclick="doInvoice();">
                <input class='hiddenredbutton' type="button" name="buttonQuickInvoice" id="buttonQuickInvoice" value='<%=getTranNoLink("Web","patientQuickInvoiceEdit",sWebLanguage)%>' onclick="doQuickInvoice();">
            </td>
        </tr>
    </table>
    <%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>.
    <div id="divMessage" name="divMessage"></div>
    <input type='hidden' id="EditDebetUID" name='EditDebetUID' value='<%=sEditDebetUID%>'>
    <input type='hidden' id="EditGroupIdx" name='EditGroupIdx' value='<%=sEditGroupIdx%>'> <%-- // Stijn --%>
    <input type='hidden' id="prestationids" name="prestationids" value=""/>
</form>
<script>
	function alertcontinuity(){
		<%
			Encounter e = Encounter.getActiveEncounter(activePatient.personid);
			if(e!=null && e.getCategories()!=null && e.getCategories().length()>0 && !e.getCategories().equalsIgnoreCase("A")){
				out.println("alert('"+getTranNoLink("web","verifyencounter",sWebLanguage)+"')");
			}
		%>
	}
	
	function checkSaveButtonRights(){
		if(EditForm.buttonSave!=null){
			var bInvisible=(document.getElementById('EditDebetUID').value=='' || document.getElementById('EditDebetUID').value=='-1') && <%=activeUser.getAccessRight("financial.debet.add")?"false":"true"%>;
			if(!bInvisible){
				bInvisible=(document.getElementById('EditDebetUID').value!='' && document.getElementById('EditDebetUID').value!='-1') && <%=activeUser.getAccessRight("financial.debet.edit")?"false":"true"%>;
			}
			if(bInvisible){
				EditForm.buttonSave.style.display = "none";
			}
			else {
				EditForm.buttonSave.style.display = "";
			}
		}
	}
	
	function doInvoice(){
		window.location.href="<c:url value='/main.do?Page=financial/patientInvoiceEdit.jsp'/>";
	}
	
	function doQuickInvoice(){
		window.location.href="<c:url value='/main.do?Page=financial/patientInvoiceEdit.jsp&quick=1'/>";
	}
	
	function changeQuicklistPrestations(prestations,bInvoice){
		if(EditForm.EditEncounterUID.value.length==0 || EditForm.EditEncounterUID.value=='null'){
			alert('<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>');
			return;
		}
		$('prestationids').value=prestations;
        EditForm.EditPrestationName.style.backgroundColor='white';
        document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Calculating";
        var today = new Date();
        var url= '<c:url value="/financial/getPrestationAmount2.jsp"/>?ts='+today;
        new Ajax.Request(url,{
                method: "POST",
                postBody: 'PrestationUIDs=' + prestations +
	                '&EditDebetUID=' + EditForm.EditDebetUID.value+
    	            '&EditInsuranceUID=' + EditForm.EditInsuranceUID.value+
    	            '&EditEncounterUID=' + EditForm.EditEncounterUID.value+
    	            '&EditDate=' + EditForm.EditDate.value+
                   '&CoverageInsurance=' + EditForm.coverageinsurance.value+
                    '&EnableInsurance=' + (EditForm.EnableInsurance.checked?'1':'')+
                   '&PrestationServiceUid=' + EditForm.EditDebetServiceUid.value+
                   '&PrestationServiceName=' + EditForm.EditDebetServiceName.value+
                   <%
		               	if(MedwanQuery.getInstance().getConfigInt("enableComplementaryInsurance2",0)==1){
        	       %>
            	       '&CoverageInsurance2=' + EditForm.coverageinsurance2.value+
            	   <%
		               	}
        		   %>
                   '&EditQuantity=' + EditForm.EditQuantity.value,
                onSuccess: function(resp){
                    $('divMessage').innerHTML = "";
                    var label = eval('('+resp.responseText+')');
                    $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
                    $('EditInsurarAmount').value=label.EditInsurarAmount;
                    document.getElementById('prestationcontent').innerHTML=label.PrestationContent;
                    $('EditQuantity').style.visibility='hidden';
                    findPerformer();
                    if(bInvoice){
                    	doSave(true);
                    }
                },
                onFailure: function(){
                    $('divMessage').innerHTML = "Error in function changePrestation() => AJAX";
                }
            }
        );
        EditForm.EditPrestationUID.value = EditForm.EditPrestationName.value;
        checkSaveButtonRights();
	}
	


	function changePrestation(bFirst){
		  $('prestationids').value='';
	      if (EditForm.EditPrestationName.value.length==0 && EditForm.EditPrestationGroup.value.length==0){
	          EditForm.EditPrestationName.style.backgroundColor='#D1B589';
	          document.getElementById('prestationcontent').innerHTML='';
	      }
	      else {
	          if (!bFirst){
	      		if(EditForm.EditEncounterUID.value.length==0 || EditForm.EditEncounterUID.value=='null'){
	    			alert('<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>');
	    			return;
	    		}
	              document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Calculating";
	              var today = new Date();
	              var url= '<c:url value="/financial/getPrestationAmount2.jsp"/>?ts='+today;
	              new Ajax.Request(url,{
	                      method: "POST",
	                      postBody: 'PrestationUID=' + EditForm.EditPrestationName.value +
		 	 	              '&EditDebetUID=' + EditForm.EditDebetUID.value+
		                      '&PrestationGroupUID=' + EditForm.EditPrestationGroup.value+
		                      '&EditInsuranceUID=' + EditForm.EditInsuranceUID.value+
 	   	      	              '&EditEncounterUID=' + EditForm.EditEncounterUID.value+
		       	              '&EditDate=' + EditForm.EditDate.value+
		                      '&CoverageInsurance=' + EditForm.coverageinsurance.value+
		                      '&EnableInsurance=' + (EditForm.EnableInsurance.checked?'1':'')+
			                   '&PrestationServiceUid=' + EditForm.EditDebetServiceUid.value+
			                   '&PrestationServiceName=' + EditForm.EditDebetServiceName.value+
		                      <%
					               	if(MedwanQuery.getInstance().getConfigInt("enableComplementaryInsurance2",0)==1){
			        	       %>
			                      '&CoverageInsurance2=' + EditForm.coverageinsurance2.value+
			                  <%
					               	}
			                  %>
		                      '&EditQuantity=' + EditForm.EditQuantity.value,
	                      onSuccess: function(resp){
	                          $('divMessage').innerHTML = "";
	                          var label = eval('('+resp.responseText+')');
	                          $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
	                          $('EditInsurarAmount').value=label.EditInsurarAmount;
	                          document.getElementById('prestationcontent').innerHTML=label.PrestationContent;
			                  $('EditQuantity').style.visibility='visible';
	                          findPerformer();
	                      },
	                      onFailure: function(){
	                          $('divMessage').innerHTML = "Error in function changePrestation() => AJAX";
	                      }
	                  }
	              );
	          }
	      }

	      EditForm.EditPrestationUID.value = EditForm.EditPrestationName.value;
	      checkSaveButtonRights();
	}

	function changePrestationVariable(bFirst){
		  $('prestationids').value='';
	      if (EditForm.EditPrestationName.value.length==0 && EditForm.EditPrestationGroup.value.length==0){
	          EditForm.EditPrestationName.style.backgroundColor='#D1B589';
	          document.getElementById('prestationcontent').innerHTML='';
	      }
	      else {
	          EditForm.EditPrestationName.style.backgroundColor='white';
	          if (!bFirst){
	      		if(EditForm.EditEncounterUID.value.length==0 || EditForm.EditEncounterUID.value=='null'){
	    			alert('<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>');
	    			return;
	    		}
	              document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Calculating";
	              var today = new Date();
	              var url= '<c:url value="/financial/getPrestationAmount2.jsp"/>?ts='+today;
	              new Ajax.Request(url,{
	                      method: "POST",
	                      postBody: 'PrestationUID=' + EditForm.EditPrestationName.value +
		                      '&EditPrice=' + EditForm.tmpPrestationPrice.value+
		 	 	              '&EditDebetUID=' + EditForm.EditDebetUID.value+
		                      '&PrestationGroupUID=' + EditForm.EditPrestationGroup.value+
		      	              '&EditEncounterUID=' + EditForm.EditEncounterUID.value+
		                      '&EditInsuranceUID=' + EditForm.EditInsuranceUID.value+
		       	              '&EditDate=' + EditForm.EditDate.value+
		                      '&CoverageInsurance=' + EditForm.coverageinsurance.value+
		                      '&EnableInsurance=' + (EditForm.EnableInsurance.checked?'1':'')+
			                   '&PrestationServiceUid=' + EditForm.EditDebetServiceUid.value+
			                   '&PrestationServiceName=' + EditForm.EditDebetServiceName.value+
		                      <%
					               	if(MedwanQuery.getInstance().getConfigInt("enableComplementaryInsurance2",0)==1){
			        	       %>
			                      '&CoverageInsurance2=' + EditForm.coverageinsurance2.value+
			                  <%
					               	}
			                  %>
		                      '&EditQuantity=' + EditForm.EditQuantity.value,
	                      onSuccess: function(resp){
	                          $('divMessage').innerHTML = "";
	                          var label = eval('('+resp.responseText+')');
	                          $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
	                          $('EditInsurarAmount').value=label.EditInsurarAmount;
	                          document.getElementById('prestationcontent').innerHTML=label.PrestationContent;
			                  $('EditQuantity').style.visibility='visible';
	                          findPerformer();
	                      },
	                      onFailure: function(){
	                          $('divMessage').innerHTML = "Error in function changePrestation() => AJAX";
	                      }
	                  }
	              );
	          }
	      }

	      EditForm.EditPrestationUID.value = EditForm.EditPrestationName.value;
	}

  function changeInsurance(){
      if (EditForm.EditInsuranceUID.selectedIndex > 0){
  		if(EditForm.EditEncounterUID.value.length==0 || EditForm.EditEncounterUID.value=='null'){
			alert('<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>');
			return;
		}
    	  document.getElementById("EditPrestationGroup").selectedIndex=0;
    	  var today = new Date();
          var url= '<c:url value="/financial/getPrestationAmount2.jsp"/>?ts='+today;
          new Ajax.Request(url,{
                  method: "POST",
                  postBody: 'PrestationUIDs=' + document.getElementById('prestationids').value
	                +'&EditDebetUID=' + EditForm.EditDebetUID.value
                  	+'&PrestationUID=' + EditForm.EditPrestationName.value
    	            +'&EditEncounterUID=' + EditForm.EditEncounterUID.value
	                +'&CoverageInsurance=' + EditForm.coverageinsurance.value
                    +'&EnableInsurance=' + (EditForm.EnableInsurance.checked?'1':'')
    	            +'&EditDate=' + EditForm.EditDate.value
                    +'&PrestationServiceUid=' + EditForm.EditDebetServiceUid.value
                    +'&PrestationServiceName=' + EditForm.EditDebetServiceName.value
	                   <%
		               	if(MedwanQuery.getInstance().getConfigInt("enableComplementaryInsurance2",0)==1){
		       	       %>
	    		            +'&CoverageInsurance2=' + EditForm.coverageinsurance2.value
	    		       <%
		               	}
	    		       %>
                    +'&EditInsuranceUID=' + EditForm.EditInsuranceUID.value
                    +'&EditQuantity=' + EditForm.EditQuantity.value,
                  onSuccess: function(resp){
                      var label = eval('('+resp.responseText+')');
                      $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
                      $('EditInsurarAmount').value=label.EditInsurarAmount*EditForm.EditQuantity.value;
                      document.getElementById('prestationcontent').innerHTML=label.PrestationContent;
                      findPerformer();
                  },
                  onFailure: function(){
                      $('divMessage').innerHTML = "Error in function changeInsurance() => AJAX";
                  }
              }
          );
      }

  }
  
  function findPerformer(){
	  encounteruid=EditForm.EditEncounterUID.value;
      var today = new Date();
      var url= '<c:url value="/financial/debetEditGetDefaultCareProvider.jsp"/>?ts='+today;
	  var prests="";
      pars=document.all;
      for(n=0;n<document.all.length;n++){
          if(document.all[n].name && document.all[n].name.indexOf("PP")>-1){
          	prests+="&"+document.all[n].name+"="+document.all[n].value;
          }
      }
      new Ajax.Request(url,{
          method: "POST",
          postBody: prests
                  +'&encounteruid=' + encounteruid,
          onSuccess: function(resp){
              var label = eval('('+resp.responseText+')');
              for(z=1;z<$('EditCareProvider').options.length;z++){
        		  if($('EditCareProvider').options[z].value==label.performeruid){
        			  $('EditCareProvider').selectedIndex=z;
        		  }
        	  }
          },
          onFailure: function(){
              $('divMessage').innerHTML = "Error in function findPerformer() => AJAX";
          }
      }
	  );
	}

  function checkQuickInvoice(){
	  encounteruid=EditForm.EditEncounterUID.value;
      var today = new Date();
      var url= '<c:url value="/financial/checkQuickInvoice.jsp"/>?personid=<%=activePatient.personid%>&ts='+today;
      new Ajax.Request(url,{
          method: "POST",
          postBody: "",
          onSuccess: function(resp){
              var label = resp.responseText;
              if(label.indexOf("<OK>")>-1){
            	  document.getElementById('buttonQuickInvoice').style.visibility='visible';
              }
              else {
            	  document.getElementById('buttonQuickInvoice').style.visibility='hidden';
              }
          },
          onFailure: function(){
              $('divMessage').innerHTML = "Error in function checkQuickInvoice() => AJAX";
          }
      }
	  );
	}

  function doSave(bInvoice){
	  if(document.getElementById("invalidatesave")){
          alert('<%=getTranNoLink("web.manage","savenotallowed",sWebLanguage)%>');
          return false;
	  }
	  if('<%=MedwanQuery.getInstance().getConfigInt("invoicingCareProviderMandatory",0)%>'=='1' && document.getElementById('EditCareProvider').value==''){
          alert('<%=getTranNoLink("web","invoicingcareprovidermissing",sWebLanguage)%>');
          document.getElementById('EditCareProvider').focus();
          return false;
	  }
	  if((EditForm.EditDate.value.length>0)
          &&(EditForm.EditInsuranceUID.value.length>0)
          &&(EditForm.EditPrestationUID.value.length>0 || EditForm.EditPrestationGroup.value.length>0 || document.getElementById('prestationcontent').innerHTML.length>0)
          &&(EditForm.EditEncounterUID.value!="null" && EditForm.EditEncounterUID.value.length>0)){
          var sCredited = "0";
          var today = new Date();
          if (EditForm.EditCredit.checked){
              sCredited = "1";
          }
          var url= '<c:url value="/financial/debetSave2.jsp"/>?ts='+today;
          document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Loading";
		  var prests="";
          pars=document.all;
          for(n=0;n<document.all.length;n++){
              if(document.all[n].name && document.all[n].name.indexOf("PP")>-1){
              	prests+="&"+document.all[n].name+"="+document.all[n].value;
              }
          }
          new Ajax.Request(url,{
                  method: "POST",
                  postBody: 'EditDate=' + EditForm.EditDate.value
                          +'&EditDebetUID=' + EditForm.EditDebetUID.value
                          +'&EditInsuranceUID=' + EditForm.EditInsuranceUID.value
                          +'&EditPrestationUID=' + EditForm.EditPrestationUID.value
                          +'&EditPrestationGroupUID=' + EditForm.EditPrestationGroup.value
                          +'&EditAmount=' + EditForm.EditAmount.value
                          +'&EditInsurarAmount=' + EditForm.EditInsurarAmount.value
                          +'&EditEncounterUID=' + EditForm.EditEncounterUID.value
                          +'&EditPatientInvoiceUID=' + EditForm.EditPatientInvoiceUID.value
                          +'&EditInsuranceInvoiceUID=' + EditForm.EditInsuranceInvoiceUID.value
                          +'&EditComment=' + EditForm.EditComment.value
                          +'&EditQuantity=' + EditForm.EditQuantity.value
                          +'&EditExtraInsurarUID=' + EditForm.coverageinsurance.value
                          +'&EditDiagnosis=' + EditForm.EditDiagnosis.value
                          <%
	  		               	if(MedwanQuery.getInstance().getConfigInt("enableComplementaryInsurance2",0)==1){
    			   	       %>
                	          +'&EditExtraInsurarUID2=' + EditForm.coverageinsurance2.value
                	      <%
	  		               	}
                	      %>
                          +'&EditCareProvider=' + EditForm.EditCareProvider.value
                          +'&EditCredit=' + sCredited
                          +'&EditServiceUid=' + EditForm.EditDebetServiceUid.value
                          + prests,
                  onSuccess: function(resp){
                      var label = eval('('+resp.responseText+')');
                      $('divMessage').innerHTML=label.Message;
                      $('EditDebetUID').value=label.EditDebetUID;
                      window.setTimeout('reloadAfterSave('+bInvoice+');',500);
                  },
                  onFailure: function(){
                      $('divMessage').innerHTML = "Error in function doSave() => AJAX";
                  }
              }
          );
          checkQuickInvoice();
      }
      else {
          window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran(null,"web.manage","dataMissing",sWebLanguage)%>');
      }
  }
	function reloadAfterSave(bInvoice){
		doNew();
        loadUnassignedDebets();
        if(bInvoice){
      	  doQuickInvoice();
        }
	}
	function openQuicklist(){
  		if(EditForm.EditEncounterUID.value.length==0 || EditForm.EditEncounterUID.value=='null'){
			alert('<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>');
			return;
		}
		if(document.getElementById("EditInsuranceUID").value.length>0){
		    openPopup("/financial/quicklist.jsp&ts=<%=getTs()%>&EditInsuranceUID="+document.getElementById("EditInsuranceUID").value+"&PopupHeight=600&PopupWidth=1024");
		}
	}
	
  	function searchEncounter(encounterUidField,encounterNameField){
	    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+"&VarFunction=validateServiceUid()&FindEncounterPatient=<%=activePatient.personid%>");
	}
  	
  	function validateServiceUid(){
      var today = new Date();
      var url= '<c:url value="/financial/getDebetServiceUid.jsp"/>?encounteruid='+document.getElementById('EditEncounterUID').value+'&ts='+today;
      new Ajax.Request(url,{
          method: "POST",
          postBody: "",
          onSuccess: function(resp){
              var label = eval('('+resp.responseText+')');
    		  document.getElementById('EditDebetServiceUid').value=label.uid;
    		  document.getElementById('EditDebetServiceName').value=label.name;
    		  changePrestation(false);
          },
          onFailure: function(){
              $('divMessage').innerHTML = "Error in function validateServiceUid() => AJAX";
          }
      }
	  );
  	}

    function searchPrestation(){
  		if(EditForm.EditEncounterUID.value.length==0 || EditForm.EditEncounterUID.value=='null'){
			alert('<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>');
			return;
		}
    	document.getElementById('EditPrestationGroup').value='';
        EditForm.tmpPrestationName.value = "";
        EditForm.tmpPrestationUID.value = "";
        insuranceuid=document.getElementById("EditInsuranceUID").value;
        if(insuranceuid==''){
        	insuranceuid='?';
        }
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&PopupWidth=800&ReturnFieldUid=tmpPrestationUID&ReturnFieldDescr=tmpPrestationName&ReturnFieldPrice=tmpPrestationPrice&doFunction=changeTmpPrestation()&doFunctionVariable=changeTmpPrestationVariable()&checkInsurance="+insuranceuid+"&encounteruid="+EditForm.EditEncounterUID.value);
    }

    function doCredit(){
        if (EditForm.EditCredit.checked){
            EditForm.EditAmount.value = "0";
            EditForm.EditInsurarAmount.value = "0";
        }
    }

    function changeTmpPrestation(){
        if (EditForm.tmpPrestationUID.value.length>0){
            EditForm.EditPrestationUID.value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.title=EditForm.tmpPrestationName.title;
            EditForm.EditPrestationName.options[EditForm.EditPrestationName.options.length-1].text = EditForm.tmpPrestationName.value;
            EditForm.EditPrestationName.options[EditForm.EditPrestationName.options.length-1].value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[EditForm.EditPrestationName.options.length-1].selected = true;
            changePrestation(false);
            findPerformer();
        }
    }

    function changeTmpPrestationVariable(){
        if (EditForm.tmpPrestationUID.value.length>0){
            EditForm.EditPrestationUID.value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[EditForm.EditPrestationName.options.length-1].text = EditForm.tmpPrestationName.value;
            EditForm.EditPrestationName.options[EditForm.EditPrestationName.options.length-1].value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[EditForm.EditPrestationName.options.length-1].selected = true;
            changePrestationVariable(false);
            findPerformer();
        }
    }

  function doNew(){
    EditForm.EditDebetUID.value = "";
    EditForm.EditGroupIdx.value = ""; // Stijn : whole function
    EditForm.EditPrestationUID.value = "";
    EditForm.EditPrestationGroup.selectedIndex=-1;
    EditForm.EditPrestationName.selectedIndex = -1;
    document.getElementById('prestationcontent').innerHTML='';
    EditForm.EditAmount.value = "";
    EditForm.EditInsurarAmount.value = "";
    EditForm.EditComment.value = "";
    if (EditForm.EditCredit) EditForm.EditCredit.checked = false;
    EditForm.EditPatientInvoiceUID.value = "";
    EditForm.EditInsuranceInvoiceUID.value = "";
    EditForm.EditQuantity.value = "1";
    if(1==<%=MedwanQuery.getInstance().getConfigInt("resetServiceUidForNewDebet",0)%>){
	  EditForm.EditDebetServiceUid.value="<%=sDefaultServiceUid%>";
	  EditForm.EditDebetServiceName.value="<%=sDefaultServiceName%>";
    }
    if (EditForm.buttonSave) EditForm.buttonSave.disabled=false;
    document.getElementById('groups').style.visibility='visible';
    changePrestation(true);
    findPerformer();
    checkSaveButtonRights();
    document.getElementById('buttonadmin').innerHTML="<input accesskey='S' class='button' type='button' name='buttonSave' id='buttonSave' value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick='doSave();'/>&nbsp;<input accesskey='P' class='button' type='button' name='buttonInvoice' value='<%=getTranNoLink("Web","patientInvoiceEdit",sWebLanguage)%>' onclick='doInvoice()'/>&nbsp;<input class='hiddenredbutton' type='button' name='buttonQuickInvoice' id='buttonQuickInvoice' value='<%=getTranNoLink("Web","patientQuickInvoiceEdit",sWebLanguage)%>' onclick='doQuickInvoice()'/>";
    checkQuickInvoice();
  }

  function setDebet(sUid,groupIdx){
    EditForm.EditDebetUID.value = sUid;
    EditForm.EditGroupIdx.value = groupIdx; // Stijn : extra field which specifies debet to open after click on it which invokes a submit
    EditForm.submit();
  }

  function checkAdmissionDaysInvoiced(){
	  <%
	  	if(activeEncounter!=null && MedwanQuery.getInstance().getConfigInt("warnForUninvoicedAdmissionDays",1)==1 && activeEncounter.getType().equalsIgnoreCase("admission") && Encounter.getAccountedAccomodationDays(activeEncounter.getUid())<activeEncounter.getDurationInDays()){	
	  		Prestation pStay=null;
            if (activeEncounter.getService()!=null && activeEncounter.getService().stayprestationuid!=null) {
            	pStay = Prestation.get(activeEncounter.getService().stayprestationuid);
            }
            if(pStay!=null && pStay.getUid()!=null && pStay.getUid().split("\\.").length>1){
		  	%>
				var answer=yesnoDialogDirectText("<%=getTranNoLink("web","invoice.remaining.admission.days",sWebLanguage)+": "+(activeEncounter.getDurationInDays()-Encounter.getAccountedAccomodationDays(activeEncounter.getUid()))+" x "+pStay.getDescription()%>?");
				if(answer=='1'){
					invoiceRemainingAdmissionDays('<%=activeEncounter.getUid()%>');
				}
		  	<%
            }
            else {
	      	%>
	      		alert("<%=getTranNoLink("web","warn.invoice.remaining.admission.days",sWebLanguage)+": "+(activeEncounter.getDurationInDays()-Encounter.getAccountedAccomodationDays(activeEncounter.getUid()))%>");
	      	<%
            }
	  	}
	  %>
  }
  
  function invoiceRemainingAdmissionDays(encounteruid){
	    var today = new Date();
	    var url= '<c:url value="/financial/invoiceRemainingAdmissionDays.jsp"/>?encounteruid='+encounteruid+'&insuranceuid='+document.getElementById('EditInsuranceUID').value+'&ts='+today;
		new Ajax.Request(url,{
		  method: "POST",
	      parameters: "",
	      onSuccess: function(resp){
	    	  loadUnassignedDebets();
	      }
		});
  }
  function loadUnassignedDebets(){
    document.getElementById('divUnassignedDebets').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Loading";
    var params = 'FindDateBegin=' + EditForm.FindDateBegin.value
                +"&FindDateEnd="+EditForm.FindDateEnd.value
                +"&FindAmountMin="+EditForm.FindAmountMin.value
                "&FindAmountMax="+EditForm.FindAmountMax.value+
                "&GroupIdx="+EditForm.EditGroupIdx.value; // Stijn
    var today = new Date();
    var url= '<c:url value="/financial/debetGetUnassignedDebets.jsp"/>?ts='+today;
	new Ajax.Request(url,{
	  method: "GET",
      parameters: params,
      onSuccess: function(resp){
        $('divUnassignedDebets').innerHTML=resp.responseText;
      }
	});
  }

  <%-- TOGGLE DEBET GROUP --%> // Stijn : whole function
  function toggleDebetGroup(groupIdx){
	var groupTr = document.getElementById("groupTable_"+groupIdx);
	
	if(groupTr.style.display=="none"){
	  groupTr.style.display = "table-row";

	  document.getElementById("group"+groupIdx+"Plus").style.display = "none";
	  document.getElementById("group"+groupIdx+"Min").style.display = "block";
	}
	else{
	  groupTr.style.display = "none";

	  document.getElementById("group"+groupIdx+"Plus").style.display = "block";
	  document.getElementById("group"+groupIdx+"Min").style.display = "none";
	}
  }

  function clearFindFields(){
    EditForm.FindDateBegin.value = "";
    EditForm.FindDateEnd.value = "";
    EditForm.FindAmountMin.value = "";
    EditForm.FindAmountMax.value = "";
  }

  function checkCoverage(){
    if(document.getElementById("coverageinsurance").selectedIndex>0){
      document.getElementById("EditAmount").style.textDecoration="line-through";
    }
    else {
      document.getElementById("EditAmount").style.textDecoration="";
    }
  }
   
  function searchService(serviceUidField,serviceNameField){
	openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	document.getElementById(serviceNameField).focus();
  }
  
  function negotiate(prestationuid){
	  openPopup("/financial/negotiateTariff.jsp&prestationuid="+prestationuid+"&extrainsurance="+document.getElementById('coverageinsurance').value);
  }

  function negotiate2(prestationuid){
	  openPopup("/financial/negotiateTariff2.jsp&prestationuid="+prestationuid+"&extrainsurance="+document.getElementById('coverageinsurance').value);
  }

  checkCoverage();
  EditForm.EditDate.focus();
  changePrestation(true);
  loadUnassignedDebets();
  checkSaveButtonRights();
  checkQuickInvoice();
  checkAdmissionDaysInvoiced();
  //window.setTimeout("changePrestation(false);",300); // Stijn
</script>
<%
}
catch(Exception e){
	e.printStackTrace();
}
%>