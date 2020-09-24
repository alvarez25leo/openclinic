<%@page import="java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    boolean needsbeds = false;
	boolean needsvisits = false;
    boolean showinactive = false;
    boolean lockservices = false;

    //--- GET PARENT ------------------------------------------------------------------------------
    private String getParent(String sCode, String sWebLanguage){
        String sReturn = "";
        if(sCode!=null && (sCode.trim().length()>0)){
            String sLabel = getTran(null,"Service",sCode,sWebLanguage);

            Vector vParentIDs = Service.getParentIds(sCode);
            Iterator iter = vParentIDs.iterator();
            String sParentID;

            while(iter.hasNext()){
                sParentID = (String)iter.next();
                if(sParentID!=null && (!sParentID.equals("0000")) && (sParentID.trim().length() > 0)){

                    sReturn = getParent(sParentID,sWebLanguage)+
                              "<img src='"+sCONTEXTPATH+"/_img/themes/default/pijl.gif'>&nbsp;"+
                              "<a href='javascript:populateService(\""+sCode+"\")' title='"+getTranNoLink("Web.Occup","medwan.common.open",sWebLanguage)+"'>"+sLabel+"</a>";
                }
            }

            if(sReturn.trim().length()==0){
                sReturn = sReturn+"<img src='"+sCONTEXTPATH+"/_img/themes/default/pijl.gif'>&nbsp;"+
                          "<a href='javascript:populateService(\""+sCode+"\")' title='"+getTranNoLink("Web.Occup","medwan.common.open",sWebLanguage)+"'>"+sLabel+"</a>";
            }
        }
        
        return sReturn;
    }

    //--- WRITE MY ROW ----------------------------------------------------------------------------
    private String writeMyRow(String sType, String sID, String sWebLanguage, String sIcon, User user, boolean lockservices){
        String row = "";
        
        String sLabel = getTran(null,sType, sID, sWebLanguage).replaceAll("'","�");
        boolean hasBeds = !needsbeds || Service.hasBeds(sID);
        boolean acceptsvisits = !needsvisits || Service.acceptsVisits(sID);
        Service service=Service.getService(sID);

        if(service!=null){
            boolean isactive = showinactive || !service.inactive.equalsIgnoreCase("1");

            if(isactive){
            	if("gmao".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))){
                	if(lockservices && ScreenHelper.checkString(service.defaultContext).length()>0){
                		hasBeds=false;
                	}
                	else{
                		hasBeds=service.isAuthorizedUser(user.userid) || user.isAdmin();
                	}
            	}
                // Set display class
                String sClass = "";
                if(service.inactive.equalsIgnoreCase("1")){
                    sClass = "strikeonly";
                }

                if(sIcon.length()==0 && MedwanQuery.getInstance().existSubServices(sID)){
                    sIcon = "<img src='"+sCONTEXTPATH+"/_img/themes/default/menu_tee_plus.gif' onclick='populateService(\""+sID+"\")' alt='"+getTranNoLink("Web.Occup", "medwan.common.open", sWebLanguage)+"'>";
                }

                row+= "<tr>"+
                       " <td>"+sIcon+"</td><td><img src='"+sCONTEXTPATH+"/_img/icons/icon_view.png' alt='"+getTranNoLink("Web", "view", sWebLanguage)+"' onclick='viewService(\""+sID+"\")'></td>" +
                       " <td class='"+sClass+"'>"+sID+"</td>";

                if(sLabel.indexOf("<a") > -1){
                    // label is a link to manageTranslations
                    row+= "<td class='"+sClass+"'>"+sLabel+"</td>";
                }
                else{
                    row+= "<td class='"+sClass+"'>"+(hasBeds && acceptsvisits ? "<a href='javascript:selectParentService(\""+sID+"\",\""+sLabel+"\")' title='"+getTranNoLink("Web", "select", sWebLanguage)+"'>" : "")+sLabel+(hasBeds && acceptsvisits? "</a>" : "")+"</td>";
                }
            	if("gmao".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))){
					if(!service.isAuthorizedUser(user.userid)){
						row+="<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_forbidden.png'/></td>";
					}
					if(ScreenHelper.checkString(service.defaultContext).length()>0){
						if(service.defaultContext.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("GMAOLocalServerId","-1"))){
							row+="<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_unlocked.png'/></td>";
						}
						else{
							row+="<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_locked.png'/></td>";
						}
					}
					else if(MedwanQuery.getInstance().getConfigInt("GMAOLocalServerId",-1)>0){
						row+="<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_locked.png'/></td>";
					}
            	}
                row += "</tr>";
            }
        }
        
        return row;
    }
%>

<%
	needsbeds    = "1".equalsIgnoreCase(request.getParameter("needsbeds"));
	needsvisits  = "1".equalsIgnoreCase(request.getParameter("needsvisits"));
    showinactive = "1".equalsIgnoreCase(request.getParameter("showinactive"));
    lockservices = "1".equalsIgnoreCase(request.getParameter("lockservices"));

    // form data
    String sViewCode       = checkString(request.getParameter("ViewCode")),
           sFindText       = checkString(request.getParameter("FindText")).toUpperCase(),
           sFindCode       = checkString(request.getParameter("FindCode")).toUpperCase(),
           sFindParentCode = request.getParameter("FindParentCode");

    // options
    String sSearchInternalServices = checkString(request.getParameter("SearchInternalServices"));
    boolean searchInternalServices = true; // default
    if(sSearchInternalServices.length() > 0){
        searchInternalServices = sSearchInternalServices.equalsIgnoreCase("true");
    }

    String sSearchExternalServices = checkString(request.getParameter("SearchExternalServices"));
    boolean searchExternalServices = false; // default
    if(sSearchExternalServices.length() > 0){
        searchExternalServices = sSearchExternalServices.equalsIgnoreCase("true");
    }

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* searchServiceShow.jsp *******************");
	    Debug.println("sViewCode       : "+sViewCode);
	    Debug.println("sFindText       : "+sFindText);
	    Debug.println("sFindCode       : "+sFindCode);
	    Debug.println("sFindParentCode : "+sFindParentCode+"\n");
	    Debug.println("searchInternalServices : "+searchInternalServices);
	    Debug.println("searchExternalServices : "+searchExternalServices+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////

    
    // variables
    StringBuffer sOut = new StringBuffer();
    String sServiceID, sNavigation = "";
    Hashtable hSelected = new Hashtable();
    SortedSet set = new TreeSet();
    Object element;
    int iTotal = 0;

    //*** search on findCode **********************************************************************
    if(sFindCode.length() > 0){
        Vector vServiceIDs = Service.getServiceIDsByParentID(sFindCode);
        Iterator iter = vServiceIDs.iterator();

        while(iter.hasNext()){
            sServiceID = (String)iter.next();
            set.add(sServiceID);
            hSelected.put(sServiceID,writeMyRow("Service",sServiceID,sWebLanguage,"",activeUser,lockservices));

            iTotal++;
        }

        sNavigation = getParent(sFindCode,sWebLanguage);
    }
    //*** search on findText **********************************************************************
    else if(sFindText != null && sFindText.length() > 0){
        Vector vServiceIDs = Service.getServiceIDsByText(sWebLanguage,sFindText);
        Iterator iter = vServiceIDs.iterator();
        String labelid;
        boolean displayLabel;

        while(iter.hasNext()){
            labelid = (String) iter.next();
            
            // decide wether to display internal and or external services
            displayLabel = false;
            if(sFindParentCode==null && searchInternalServices && searchExternalServices){
                displayLabel = true;
            }
            else if(sFindParentCode==null && searchInternalServices){
                if(!Service.isExternalService(labelid)){
                    displayLabel = true;
                }
            }
            else if(sFindParentCode==null && searchExternalServices){
                if(Service.isExternalService(labelid)){
                    displayLabel = true;
                }
            } 
            else if(sFindParentCode != null){
                displayLabel = true;
            }

            // add label to labels that will be displayed
            if(displayLabel){
                set.add(labelid);
                hSelected.put(labelid,writeMyRow("service",labelid,sWebLanguage,"",activeUser,lockservices));
                iTotal++;
            }
        }
    }
    //*** empty search ****************************************************************************
    else{
        if(MedwanQuery.getInstance().getConfigString("fillUpSearchServiceScreens").equalsIgnoreCase("on")){
            Vector vServiceIDs;
            if(sFindParentCode==null){
                vServiceIDs = Service.getTopServiceIDs();
            } 
            else{
                vServiceIDs = Service.getServiceIDsByParentID(sFindParentCode);
            }
            Iterator iter = vServiceIDs.iterator();

            boolean displayService;

            while(iter.hasNext()){
                sServiceID = (String)iter.next();
                
                // decide wether to display internal and or external services
                displayService = false;
                if(sFindParentCode==null && searchInternalServices && searchExternalServices){
                    displayService = true;
                } 
                else if(sFindParentCode==null && searchInternalServices){
                    if(!Service.isExternalService(sServiceID)){
                        displayService = true;
                    }
                } 
                else if(sFindParentCode==null && searchExternalServices){
                    if(Service.isExternalService(sServiceID)){
                        displayService = true;
                    }
                }
                else if(sFindParentCode!=null){
                    displayService = true;
                }

                if(displayService){
                    set.add(sServiceID);
                    hSelected.put(sServiceID,writeMyRow("service",sServiceID,sWebLanguage,"",activeUser,lockservices));
                    iTotal++;
                }
            }
            
            sNavigation = getParent(sFindCode, sWebLanguage);
        }
    }
%>

<div style="padding:2px;">
    &nbsp;<a href="javascript:clearSearchFields();doFind();">Home</a>
</div>

<div id="navigationMenu"><%=sNavigation%></div>

<table width="100%" cellspacing="1">
    <%
        if(sViewCode.length() > 0){
            if(iTotal==0){
                sViewCode = sFindCode;
            }
            
            String sLabel = HTMLEntities.htmlentities(getTran(request,"Service",sViewCode,sWebLanguage));
            Service sService = Service.getService(sViewCode);

            if(sService!=null){
                String sCountry = HTMLEntities.htmlentities(checkString(sService.country));
                if(sCountry.length() > 0){
                    sCountry = HTMLEntities.htmlentities(getTran(request,"Country",sCountry,sWebLanguage));
                }

                out.print(HTMLEntities.htmlentities(setRow(request,"Web","Address",checkString(sService.address),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","zipcode",checkString(sService.zipcode),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","city",checkString(sService.city),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","country",sCountry,sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","telephone",checkString(sService.telephone),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","fax",checkString(sService.fax),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","contract",checkString(sService.contract),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","contracttype",checkString(sService.contracttype),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","contactperson",checkString(sService.contactperson),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","comment",checkString(sService.comment),sWebLanguage)));
                out.print(HTMLEntities.htmlentities(setRow(request,"Web","medicalcentre",checkString(sService.code5),sWebLanguage)));

			    %>
			    <tr height="30px">
			        <td width="30%">&nbsp;</td>
			        <td>&nbsp;</td>
			    </tr>
			    <tr>
			        <td colspan="2" align="right">
			            <input type="button" class="button" value="<%=getTranNoLink("Web","select",sWebLanguage)%>"
			                   onclick="selectParentService('<%=sViewCode%>','<%=sLabel%>');">
			        </td>
			    </tr>
			    <%
	        }
	    }
        else{
	        // sort
	        Iterator it = set.iterator();
	        while(it.hasNext()){
	            element = it.next();
	            sOut.append((String) hSelected.get(element.toString()));
	        }
	
	        // display search results
	        if(iTotal > 0){
			    %>
			    <tbody class="hand">
			        <%=HTMLEntities.htmlentities(sOut.toString())%>
			    </tbody>
			    <%
	    	}
	        else{
		        // display 'no results' message
		        String serviceType;
		        if(searchExternalServices && searchInternalServices){
		            serviceType = "services";
		        }
		        else{
		                 if(sFindParentCode==null && searchExternalServices) serviceType = "externalservices";
		            else if(sFindParentCode==null && searchInternalServices) serviceType = "internalservices";
		            else serviceType = "services";
		        }
	        
			    %>
			    <tr>
			        <td colspan="3"><%=HTMLEntities.htmlentities(getTran(request,"web","no"+serviceType+"found",sWebLanguage))%>
			        </td>
			    </tr>
			    <%
	        }	        
	    %>
	    
	    <%-- SPACER --%>
	    <tr height="1">
	        <td width="1%">&nbsp;</td>
	        <td width="1%">&nbsp;</td>
	        <td width="1%">&nbsp;</td>
	    </tr>
    <%
        }
    %>
</table>