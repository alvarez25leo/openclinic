<%@page import="be.openclinic.system.Examination"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"system.management","select",activeUser)%>
<%
    String sMsg = "";

    //--- SAVE ------------------------------------------------------------------------------------
	if(request.getParameter("saveButton")!=null){
		sMsg = "<font color='green'>"+getTran(request,"web","dataIsSaved",sWebLanguage)+"</font>";
		
		//*** 1 - encounters ***
		for(int n=1;n<6;n++){
			String type    = checkString(request.getParameter("FastEncounterType."+n)),
			       origin  = checkString(request.getParameter("FastEncounterOrigin."+n)),
			       service = checkString(request.getParameter("FastEncounterService."+n)),
				   manager = checkString(request.getParameter("FastEncounterManager."+n)),
			       situation = checkString(request.getParameter("FastEncounterSituation."+n));
			
			String s = "";
			if(type.length()>0 && origin.length()>0 && service.length()>0){
				s = type+";"+origin+";"+service;
				if(manager.length() > 0){
					s+= ";"+manager;
					if(situation.length()>0){
						s+=";"+situation;
					}
				}
			}
			MedwanQuery.getInstance().setConfigString("quickConsult"+n+"."+activeUser.userid,s);
		}

		//*** 2 - transactions ***
		for(int n=1; n<6; n++){
			String sTransaction = checkString(request.getParameter("FastTransaction."+n));
			MedwanQuery.getInstance().setConfigString("quickTransaction"+n+"."+activeUser.userid,sTransaction);
		}
	}
%>

<form name="shortcutForm" method="post">
    <%
	    if(sMsg.length() > 0){
	        %><%=sMsg%><%
	    }
    %>
    
    <%-------------------------------------------------------------------------------------------%> 
    <%-- 1 : ENCOUNTERS -------------------------------------------------------------------------%> 
    <%-------------------------------------------------------------------------------------------%> 
	<table class="list" cellpadding="0" cellspacing="1">
		<tr class='admin'>
			<td width="80"><%=getTran(request,"web","shortcut",sWebLanguage)%></td>
			<td><%=getTran(request,"web","type",sWebLanguage)%></td>
			<td><%=getTran(request,"web","origin",sWebLanguage)%></td>
			<td><%=getTran(request,"web","service",sWebLanguage)%></td>
			<td><%=getTran(request,"web","manager",sWebLanguage)%></td>
			<td><%=getTran(request,"web","situation",sWebLanguage)%></td>
		</tr>
		
	    <%-- FAST ENCOUNTER 1 -------------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fastencounter",sWebLanguage)%> 1</td>
			<td class='admin2'>
	            <select class='text' id='FastEncounterType.1' name='FastEncounterType.1' >
	            	<option value=''></option>
		            <%
		                String encountertypes=MedwanQuery.getInstance().getConfigString("encountertypes","admission,visit");
		                String sOptions[] = encountertypes.split(",");
						String fastencounter=MedwanQuery.getInstance().getConfigString("quickConsult1."+activeUser.userid,"");
		                for(int i=0;i<sOptions.length;i++){
		                    out.print("<option value='"+sOptions[i]+"' ");
		                    if(fastencounter.split(";").length>0 && fastencounter.split(";")[0].equalsIgnoreCase(sOptions[i])){
		                        out.print(" selected");
		                    }
		                    out.print(">"+getTran(request,"web",sOptions[i],sWebLanguage)+"</option>");		                    
		                }
		            %>
		        </select>
		    </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterOrigin.1">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"urgency.origin",fastencounter.split(";").length>1?fastencounter.split(";")[1]:"",sWebLanguage)%>
	            </select>
			</td>
	        <td class='admin2'>
	            <input type="hidden" name="FastEncounterService.1" id="FastEncounterService.1" value="<%=fastencounter.split(";").length>2?fastencounter.split(";")[2]:""%>">
	            <input type="text" class="text" name="FastEncounterServiceName.1" id="FastEncounterServiceName.1" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>2?getTranNoLink("service",fastencounter.split(";")[2],sWebLanguage):""%>" >
	          
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchService('FastEncounterService.1','FastEncounterServiceName.1');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterService.1').value='';document.getElementById('FastEncounterServiceName.1').value='';">
	        </td>
	        <td class="admin2">
	            <input type="hidden" name="FastEncounterManager.1" id="FastEncounterManager.1" value="<%=fastencounter.split(";").length>3?fastencounter.split(";")[3]:""%>">
	            <input type="text" class="text" name="FastEncounterManagerName.1" id="FastEncounterManagerName.1" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>3?User.getFirstUserName(fastencounter.split(";")[3]):""%>">
	         
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchManager('FastEncounterManager.1','FastEncounterManagerName.1');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterManager.1').value='';document.getElementById('FastEncounterManagerName.1').value='';">
	        </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterSituation.1">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"encounter.situation",fastencounter.split(";").length>4?fastencounter.split(";")[4]:"",sWebLanguage)%>
	            </select>
			</td>
		</tr>
		
	    <%-- FAST ENCOUNTER 2 -------------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fastencounter",sWebLanguage)%> 2</td>
			<td class='admin2'>
	            <select class='text' id='FastEncounterType.2' name='FastEncounterType.2' >
	            	<option value=''></option>
		            <%
						fastencounter=MedwanQuery.getInstance().getConfigString("quickConsult2."+activeUser.userid,"");
		                for(int i=0;i<sOptions.length;i++){
		                    out.print("<option value='"+sOptions[i]+"' ");
		                    if(fastencounter.split(";").length>0 && fastencounter.split(";")[0].equalsIgnoreCase(sOptions[i])){
		                        out.print(" selected");
		                    }
		                    out.print(">"+getTran(request,"web",sOptions[i],sWebLanguage)+"</option>");		                    
		                }
		            %>
		        </select>
		    </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterOrigin.2">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"urgency.origin",fastencounter.split(";").length>1?fastencounter.split(";")[1]:"",sWebLanguage)%>
	            </select>
			</td>
	        <td class='admin2'>
	            <input type="hidden" name="FastEncounterService.2" id="FastEncounterService.2" value="<%=fastencounter.split(";").length>2?fastencounter.split(";")[2]:""%>">
	            <input type="text" class="text" name="FastEncounterServiceName.2" id="FastEncounterServiceName.2" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>2?getTranNoLink("service",fastencounter.split(";")[2],sWebLanguage):""%>" >
	          
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchService('FastEncounterService.2','FastEncounterServiceName.2');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterService.2').value='';document.getElementById('FastEncounterServiceName.2').value='';">
	        </td>
	        <td class="admin2">
	            <input type="hidden" name="FastEncounterManager.2" id="FastEncounterManager.2" value="<%=fastencounter.split(";").length>3?fastencounter.split(";")[3]:""%>">
	            <input type="text" class="text" name="FastEncounterManagerName.2" id="FastEncounterManagerName.2" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>3?User.getFirstUserName(fastencounter.split(";")[3]):""%>">
	          
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchManager('FastEncounterManager.2','FastEncounterManagerName.2');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterManager.2').value='';document.getElementById('FastEncounterManagerName.2').value='';">
	        </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterSituation.2">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"encounter.situation",fastencounter.split(";").length>4?fastencounter.split(";")[4]:"",sWebLanguage)%>
	            </select>
			</td>
	    </tr>
	    
	    <%-- FAST ENCOUNTER 3 -------------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fastencounter",sWebLanguage)%> 3</td>
			<td class='admin2'>
	            <select class='text' id='FastEncounterType.3' name='FastEncounterType.3' >
	            	<option value=''></option>
		            <%
						fastencounter=MedwanQuery.getInstance().getConfigString("quickConsult3."+activeUser.userid,"");
		                for(int i=0;i<sOptions.length;i++){
		                    out.print("<option value='"+sOptions[i]+"' ");
		                    if(fastencounter.split(";").length>0 && fastencounter.split(";")[0].equalsIgnoreCase(sOptions[i])){
		                        out.print(" selected");
		                    }
		                    out.print(">"+getTran(request,"web",sOptions[i],sWebLanguage)+"</option>");
		                    
		                }
		            %>
		        </select>
		    </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterOrigin.3">
	                <option/>
	                <%
	                    out.print(ScreenHelper.writeSelect(request,"urgency.origin",fastencounter.split(";").length>1?fastencounter.split(";")[1]:"",sWebLanguage));
	                %>
	            </select>
			</td>
	        <td class='admin2'>
	            <input type="hidden" name="FastEncounterService.3" id="FastEncounterService.3" value="<%=fastencounter.split(";").length>2?fastencounter.split(";")[2]:""%>">
	            <input type="text" class="text" name="FastEncounterServiceName.3" id="FastEncounterServiceName.3" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>2?getTranNoLink("service",fastencounter.split(";")[2],sWebLanguage):""%>" >
	           
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchService('FastEncounterService.3','FastEncounterServiceName.3');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterService.3').value='';document.getElementById('FastEncounterServiceName.3').value='';">
	        </td>
	        <td class="admin2">
	            <input type="hidden" name="FastEncounterManager.3" id="FastEncounterManager.3" value="<%=fastencounter.split(";").length>3?fastencounter.split(";")[3]:""%>">
	            <input type="text" class="text" name="FastEncounterManagerName.3" id="FastEncounterManagerName.3" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>3?User.getFirstUserName(fastencounter.split(";")[3]):""%>">
	          
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchManager('FastEncounterManager.3','FastEncounterManagerName.3');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterManager.3').value='';document.getElementById('FastEncounterManagerName.3').value='';">
	        </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterSituation.3">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"encounter.situation",fastencounter.split(";").length>4?fastencounter.split(";")[4]:"",sWebLanguage)%>
	            </select>
			</td>
	    </tr>
	    
	    <%-- FAST ENCOUNTER 4 -------------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fastencounter",sWebLanguage)%> 4</td>
			<td class='admin2'>
	            <select class='text' id='FastEncounterType.4' name='FastEncounterType.4' >
	            	<option value=''></option>
		            <%
						fastencounter=MedwanQuery.getInstance().getConfigString("quickConsult4."+activeUser.userid,"");
		                for(int i=0;i<sOptions.length;i++){
		                    out.print("<option value='"+sOptions[i]+"' ");
		                    if(fastencounter.split(";").length>0 && fastencounter.split(";")[0].equalsIgnoreCase(sOptions[i])){
		                        out.print(" selected");
		                    }
		                    out.print(">"+getTran(request,"web",sOptions[i],sWebLanguage)+"</option>");		                    
		                }
		            %>
		        </select>
		    </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterOrigin.4">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"urgency.origin",fastencounter.split(";").length>1?fastencounter.split(";")[1]:"",sWebLanguage)%>
	            </select>
			</td>
	        <td class='admin2'>
	            <input type="hidden" name="FastEncounterService.4" id="FastEncounterService.4" value="<%=fastencounter.split(";").length>2?fastencounter.split(";")[2]:""%>">
	            <input type="text" class="text" name="FastEncounterServiceName.4" id="FastEncounterServiceName.4" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>2?getTranNoLink("service",fastencounter.split(";")[2],sWebLanguage):""%>" >
	         
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchService('FastEncounterService.4','FastEncounterServiceName.4');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterService.4').value='';document.getElementById('FastEncounterServiceName.4').value='';">
	        </td>
	        <td class="admin2">
	            <input type="hidden" name="FastEncounterManager.4" id="FastEncounterManager.4" value="<%=fastencounter.split(";").length>3?fastencounter.split(";")[3]:""%>">
	            <input type="text" class="text" name="FastEncounterManagerName.4" id="FastEncounterManagerName.4" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>3?User.getFirstUserName(fastencounter.split(";")[3]):""%>">
	         
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchManager('FastEncounterManager.4','FastEncounterManagerName.4');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterManager.4').value='';document.getElementById('FastEncounterManagerName.4').value='';">
	        </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterSituation.4">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"encounter.situation",fastencounter.split(";").length>4?fastencounter.split(";")[4]:"",sWebLanguage)%>
	            </select>
			</td>
	    </tr>
	    
	    <%-- FAST ENCOUNTER 5 -------------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fastencounter",sWebLanguage)%> 5</td>
			<td class='admin2'>
	            <select class='text' id='FastEncounterType.5' name='FastEncounterType.5' >
	            	<option value=''></option>
	            <%
					fastencounter=MedwanQuery.getInstance().getConfigString("quickConsult5."+activeUser.userid,"");
	                for(int i=0;i<sOptions.length;i++){
	                    out.print("<option value='"+sOptions[i]+"' ");
	                    if(fastencounter.split(";").length>0 && fastencounter.split(";")[0].equalsIgnoreCase(sOptions[i])){
	                        out.print(" selected");
	                    }
	                    out.print(">"+getTran(request,"web",sOptions[i],sWebLanguage)+"</option>");	                    
	                }
	            %>
		        </select>
		    </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterOrigin.5">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"urgency.origin",fastencounter.split(";").length>1?fastencounter.split(";")[1]:"",sWebLanguage)%>
	            </select>
			</td>
	        <td class='admin2'>
	            <input type="hidden" name="FastEncounterService.5" id="FastEncounterService.5" value="<%=fastencounter.split(";").length>2?fastencounter.split(";")[2]:""%>">
	            <input type="text" class="text" name="FastEncounterServiceName.5" id="FastEncounterServiceName.5" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>2?getTranNoLink("service",fastencounter.split(";")[2],sWebLanguage):""%>" >
	           
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchService('FastEncounterService.5','FastEncounterServiceName.5');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterService.5').value='';document.getElementById('FastEncounterServiceName.5').value='';">
	        </td>
	        <td class="admin2">
	            <input type="hidden" name="FastEncounterManager.5" id="FastEncounterManager.5" value="<%=fastencounter.split(";").length>3?fastencounter.split(";")[3]:""%>">
	            <input type="text" class="text" name="FastEncounterManagerName.5" id="FastEncounterManagerName.5" readonly size="<%=30%>" value="<%=fastencounter.split(";").length>3?User.getFirstUserName(fastencounter.split(";")[3]):""%>">
	           
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchManager('FastEncounterManager.5','FastEncounterManagerName.5');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('FastEncounterManager.5').value='';document.getElementById('FastEncounterManagerName.5').value='';">
	        </td>
		    <td class='admin2'>
	            <select class="text" name="FastEncounterSituation.5">
	                <option/>
	                <%=ScreenHelper.writeSelect(request,"encounter.situation",fastencounter.split(";").length>4?fastencounter.split(";")[4]:"",sWebLanguage)%>
	            </select>
			</td>
	    </tr>	
	</table>
	
	<br>
	      
	<%-------------------------------------------------------------------------------------------%>
    <%-- 2 : TRANSACTIONS -----------------------------------------------------------------------%>
	<%-------------------------------------------------------------------------------------------%> 	 
	<table class="list" cellpadding="0" cellspacing="1">       	    	    
		<tr class='admin'>
			<td width="80"><%=getTran(request,"web","shortcut",sWebLanguage)%></td>
			<td colspan=4><%=getTran(request,"web","type",sWebLanguage)%></td>
		</tr>
		
		<%
	        String sKey, sID, sSelected="",sEditTranType;
	        Vector vResults = Examination.searchAllExaminations();
	        Iterator iter = vResults.iterator();
	        Hashtable hExaminations = new Hashtable();
	        Hashtable hResults;
	
	        // get examinations
	        while (iter.hasNext()) {
	            hResults = (Hashtable) iter.next();
	            hExaminations.put(getTran(request,"examination", (String) hResults.get("id"), sWebLanguage), hResults.get("id"));
	        }
	
	        // sort examinations
	        Vector v = new Vector(hExaminations.keySet());
	        Collections.sort(v);
	
	        Iterator it;
	        Examination examination;
            
            // display permissions
            if(Debug.enabled) activeUser.displayAccessRights();
		%>
		
        <%-- FAST TRANSACTION 1 -----------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fasttransaction",sWebLanguage)%> 1</td>
			<td class='admin2' colspan='4'>
				<select name="FastTransaction.1" class="text">
                    <option value=""></option>
                    <%
                    	String fasttransaction=MedwanQuery.getInstance().getConfigString("quickTransaction1."+activeUser.userid);
	        	        it = v.iterator();
                        while(it.hasNext()){
                            sKey = (String)it.next();
                            sID = (String)hExaminations.get(sKey);
                            sKey = getTran(request,"examination",sID,sWebLanguage);
                            examination = Examination.get(sID);
                            sEditTranType = examination.getTransactionType();
							sSelected = "";
                            if(sEditTranType.equalsIgnoreCase(fasttransaction)){
                                sSelected = " selected";
                            }

                            // check permission
                            String sAccessRightForTransaction = MedwanQuery.getInstance().getAccessRightForTransaction(sEditTranType).toLowerCase();
                            if(activeUser.getAccessRight(sAccessRightForTransaction+".select")){
                                %><option value="<%=sEditTranType%>"<%=sSelected%>><%=sKey%></option><%
                            }
                        }
                    %>
                </select>
            </td>
        </tr>
        
        <%-- FAST TRANSACTION 2 -----------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fasttransaction",sWebLanguage)%> 2</td>
			<td class='admin2' colspan='4'>
				<select name="FastTransaction.2" class="text">
                    <option value=""></option>
                    <%
                    	fasttransaction=MedwanQuery.getInstance().getConfigString("quickTransaction2."+activeUser.userid);
	        	        it = v.iterator();
                        while(it.hasNext()){
                            sKey = (String)it.next();
                            sID = (String)hExaminations.get(sKey);
                            sKey = getTran(request,"examination",sID,sWebLanguage);
                            examination = Examination.get(sID);
                            sEditTranType = examination.getTransactionType();
							sSelected = "";
                            if(sEditTranType.equals(fasttransaction)){
                                sSelected = " selected";
                            }

                            // check permission
                            String sAccessRightForTransaction = MedwanQuery.getInstance().getAccessRightForTransaction(sEditTranType).toLowerCase();
                            if(activeUser.getAccessRight(sAccessRightForTransaction+".select")){
                                %><option value="<%=sEditTranType%>"<%=sSelected%>><%=sKey%></option><%
                            }
                        }
                    %>
                </select>
            </td>
		</tr>
		
        <%-- FAST TRANSACTION 3 -----------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fasttransaction",sWebLanguage)%> 3</td>
			<td class='admin2' colspan='4'>
				<select name="FastTransaction.3" class="text">
                    <option value=""></option>
                    <%
                    	fasttransaction=MedwanQuery.getInstance().getConfigString("quickTransaction3."+activeUser.userid);
	        	        it = v.iterator();
                        while(it.hasNext()){
                            sKey = (String)it.next();
                            sID = (String)hExaminations.get(sKey);
                            sKey = getTran(request,"examination",sID,sWebLanguage);
                            examination = Examination.get(sID);
                            sEditTranType = examination.getTransactionType();
                            
							sSelected = "";
                            if(sEditTranType.equals(fasttransaction)){
                                sSelected = " selected";
                            }

                            // check permission
                            String sAccessRightForTransaction = MedwanQuery.getInstance().getAccessRightForTransaction(sEditTranType).toLowerCase();
                            if(activeUser.getAccessRight(sAccessRightForTransaction+".select")){
                                %><option value="<%=sEditTranType%>"<%=sSelected%>><%=sKey%></option><%
                            }
                        }
                    %>
                </select>
            </td>
		</tr>
		
        <%-- FAST TRANSACTION 4 -----------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fasttransaction",sWebLanguage)%> 4</td>
			<td class='admin2' colspan='4'>
				<select name="FastTransaction.4" class="text">
                    <option value=""></option>
                    <%
                    	fasttransaction=MedwanQuery.getInstance().getConfigString("quickTransaction4."+activeUser.userid);
	        	        it = v.iterator();
                        while(it.hasNext()){
                            sKey = (String)it.next();
                            sID = (String)hExaminations.get(sKey);
                            sKey = getTran(request,"examination",sID,sWebLanguage);
                            examination = Examination.get(sID);
                            sEditTranType = examination.getTransactionType();
                            
							sSelected = "";
                            if(sEditTranType.equals(fasttransaction)){
                                sSelected = " selected";
                            }

                            // check permission
                            String sAccessRightForTransaction = MedwanQuery.getInstance().getAccessRightForTransaction(sEditTranType).toLowerCase();
                            if(activeUser.getAccessRight(sAccessRightForTransaction+".select")){
                                %><option value="<%=sEditTranType%>"<%=sSelected%>><%=sKey%></option><%
                            }
                        }
                    %>
                </select>
            </td>
		</tr>
		
        <%-- FAST TRANSACTION 5 -----------------------------------------------------------------%>
		<tr>
			<td class='admin'><%=getTran(request,"web","fasttransaction",sWebLanguage)%> 5</td>
			<td class='admin2' colspan='4'>
				<select name="FastTransaction.5" class="text">
                    <option value=""></option>
                    <%
                    	fasttransaction = MedwanQuery.getInstance().getConfigString("quickTransaction5."+activeUser.userid);
	        	        it = v.iterator();
                        while(it.hasNext()){
                            sKey = (String)it.next();
                            sID = (String)hExaminations.get(sKey);
                            sKey = getTran(request,"examination",sID,sWebLanguage);
                            examination = Examination.get(sID);
                            sEditTranType = examination.getTransactionType();
                            
							sSelected = "";
                            if(sEditTranType.equals(fasttransaction)){
                                sSelected = " selected";
                            }

                            // check permission
                            String sAccessRightForTransaction = MedwanQuery.getInstance().getAccessRightForTransaction(sEditTranType).toLowerCase();
                            if(activeUser.getAccessRight(sAccessRightForTransaction+".select")){
                                %><option value="<%=sEditTranType%>"<%=sSelected%>><%=sKey%></option><%
                            }
                        }
                    %>
                </select>
            </td>
		</tr>
	</table>
	
	<i><%=getTran(request,"web","onlyPermittedTransactionsAreDisplayed",sWebLanguage)%></i><br><br>
	    	
	<input type="submit" class="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>"/>
</form>

<script>
	function searchService(serviceUidField,serviceNameField){
	  openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	  document.getElementById(serviceNameField).focus();
	}
	
	function searchManager(managerUidField,managerNameField){
	  openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no");
	  document.getElementById(managerNameField).focus();
	}
</script>