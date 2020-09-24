<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="java.io.StringReader,
                org.dom4j.DocumentException,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<%@include file="/includes/commonFunctions.jsp"%>
<script src="<c:url value='/_common/_script/menu.js'/>"></script>
<%=sSUBMODAL %>

<%!
    //### INNER CLASS : Menu ######################################################################
    public class Menu {
        public String labelid;
        public String accessrights;
        public String url;
        public String patientselected;
        public String employeeselected;
        public String dossierselected;
        public String activeencounter;
        private String enableParameter;
        private String accesskey;
        public boolean isEnabled;
        public Vector menus;
        
        //--- CONSTRUCTOR -------------------------------------------------------------------------
        public Menu(){
            labelid = "";
            accessrights = "";
            url = "";
            patientselected = "";
            employeeselected = "";
            dossierselected = "";
            enableParameter="";
            isEnabled=false;
            menus = new Vector();
            accesskey="";
        }
        
        //--- PARSE -------------------------------------------------------------------------------
        public void parse(Element eMenu){
            this.accessrights = checkString(eMenu.attributeValue("accessrights")).toLowerCase();
            this.labelid = checkString(eMenu.attributeValue("labelid")).toLowerCase();
            this.patientselected = checkString(eMenu.attributeValue("patientselected"));
            this.employeeselected = checkString(eMenu.attributeValue("employeeselected"));
            this.dossierselected = checkString(eMenu.attributeValue("dossierselected"));
            this.activeencounter = checkString(eMenu.attributeValue("activeencounter"));
            this.enableParameter = checkString(eMenu.attributeValue("enableparameter"));
            this.accesskey = checkString(eMenu.attributeValue("accesskey"));
            this.isEnabled=false;
            if(this.enableParameter.length()==0 || MedwanQuery.getInstance().getConfigInt(this.enableParameter,0)==1){
            	this.isEnabled=true;
            }

            // replace ; by & if url is no javascript
            if(checkString(eMenu.attributeValue("url")).indexOf("javascript:") > -1){
                this.url = checkString(eMenu.attributeValue("url"));
            }
            else{
                this.url = checkString(eMenu.attributeValue("url")).replaceAll(";","&");
            }
            
            Menu childMenu;
            Element eChildMenu;
            Iterator eMenus = eMenu.elementIterator("Menu");
            while(eMenus.hasNext()){
                eChildMenu = (Element)eMenus.next();
                childMenu = new Menu();
                childMenu.parse(eChildMenu);
                this.menus.add(childMenu);
            }
        }
        
        //--- MAKE MENU ---------------------------------------------------------------------------
        public String makeMenu(boolean bMenu, String sWebLanguage, String sParentMenu, User user, boolean last, 
                               AdminPerson activePatient, boolean isEmployee){
            String sReturn = "";
            if(!isEnabled){
            	return "";
            }
            try{
                if(this.accessrights.length() > 0){
                    // permission 'sa' can see everything
                    //if(user.getParameter("sa").length()==0){
                        // screen and permission specified
                        if(this.accessrights.toLowerCase().endsWith(".edit") ||
                           this.accessrights.toLowerCase().endsWith(".add") ||
                           this.accessrights.toLowerCase().endsWith(".select") ||
                           this.accessrights.toLowerCase().endsWith(".delete")){
                            if(!user.getAccessRight(this.accessrights)){
                                return "";
                            }
                        }
                        // only screen specified -> interprete as all permissions required
                        // Manageing a page, means you can add, edit and delete.
                        else{
                            if(!user.getAccessRight((this.accessrights+".edit")) ||
                               !user.getAccessRight((this.accessrights+".add")) ||
                               //!user.getAccessRight((this.accessrights+".select")) ||
                              !user.getAccessRight((this.accessrights+".delete"))){
                                return "";
                            }
                        }
                    //}
                }
                
                if(this.activeencounter.equalsIgnoreCase("true")){
                    if(activePatient==null || Encounter.getActiveEncounter(activePatient.personid)==null){
                        return "";
                    }
                }

                if(patientselected.equalsIgnoreCase("true") && !bMenu){
                    return "";
                }
                if(employeeselected.equalsIgnoreCase("true") && !bMenu){
                    return "";
                }
                if(dossierselected.equalsIgnoreCase("true") && !bMenu){
                    return "";
                }
                
                if(this.url.length() > 0){
                    // leave url as-is if it contains a javascript call
                    if(!this.url.startsWith("javascript:")){
                        if(this.url.startsWith("/")){
                            this.url = sCONTEXTPATH+this.url;
                        }
                        
                        if(this.url.indexOf("?") > 0) this.url+= "&ts="+getTs();
                        else                          this.url+= "?ts="+getTs();
                    }
                    
                    sReturn+= "";
                }

                // menu has submenus
                String sTranslation = getTranNoLink("Web",this.labelid,sWebLanguage);
                String subsubMenu = "";
                if(this.menus.size() > 0){
                    Menu subMenu=null;
                    for(int y=0; y<this.menus.size(); y++){
                        subMenu = (Menu)this.menus.elementAt(y);

                        
                        if((subMenu.dossierselected.equalsIgnoreCase("true") && (activePatient==null || activePatient.personid.length()==0))){
                            continue;
                        }
                        else if((subMenu.patientselected.equalsIgnoreCase("true")&!bMenu) || (subMenu.employeeselected.equalsIgnoreCase("true")&!isEmployee)){
                            continue;
                        }
                        else{
                            subsubMenu+= subMenu.makeMenu(bMenu,sWebLanguage,this.labelid,user,(y==this.menus.size()-1),activePatient,isEmployee);
                        }
                    }
                    
                    sReturn+= "<li><a href='javascript:void(0);' class='subparent'>"+sTranslation+"</a>";
                    sReturn+= "<ul class='level3'>";
                    sReturn+= (subsubMenu.length()>0)?subsubMenu:"<li><a href='javascript:void(0);'>empty</a></li>";
                    sReturn+= "</ul></li>";
                } 
                else{
                	if(this.url.startsWith("javascript:")){
                        sReturn+= "<li><a  href='#' onClick=\""+this.url+"\">"+sTranslation+"</a></li>";
                        if(this.accesskey.length()>0){
                        	sReturn+="<input type='button' value='button' name='buttonalert' accesskey='"+this.accesskey+"' onclick=\""+this.url.replace("javascript:","")+"\" style='display: none'/>";
                        }
                	}
                	else{
                		sReturn+= "<li><a href='#' onClick=\"javascript:clickMenuItem('"+this.url+"');\">"+sTranslation+"</a></li>";
                        if(this.accesskey.length()>0){
                        	sReturn+="<input type='button' value='button' name='buttonalert' accesskey='"+this.accesskey+"' onclick=\"window.location.href=\'"+this.url+"\';\"  style='display: none'/>";
                        }
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            
            return sReturn;
        }
    }
%>

<% 
    String sPage = checkString(request.getParameter("Page")).toLowerCase(),
           sPersonID = checkString(request.getParameter("personid")),
           sPatientNew = checkString(request.getParameter("PatientNew"));

    if(sPage.startsWith("start") || sPage.startsWith("_common/patientslist") || sPatientNew.equals("true")){
        session.removeAttribute("activePatient");
        activePatient = null;
        SessionContainerWO sessionContainerWO = (SessionContainerWO) session.getAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER");
        sessionContainerWO.setPersonVO(null);
        
		%><script>window.document.title = "<%=sWEBTITLE+" "+getWindowTitle(request,sWebLanguage)%>";</script><%
    } 
    else if(sPersonID.length() > 0){
        activePatient = AdminPerson.getAdminPerson(sPersonID);
        session.setAttribute("activePatient",activePatient);
        
		%><script>window.document.title = "<%=sWEBTITLE+" "+getWindowTitle(request,sWebLanguage)%>";</script><%
    }
    else{ 
	    sPersonID = checkString(request.getParameter("PersonID"));
    	try{
    		sPersonID = Integer.parseInt(sPersonID)+"";
    	}
    	catch(Exception e){
    	    // empty
    	}

	    if(sPersonID.length() > 0){
	        session.removeAttribute("activePatient");
	        activePatient = AdminPerson.getAdminPerson(sPersonID);
	    }
    }
    
    //First check if user has access to the active patient
    if(sPage.indexOf("novipaccess")<0 && activePatient!=null && "1".equalsIgnoreCase((String)activePatient.adminextends.get("vip")) && !activeUser.getAccessRight("vipaccess.select")){
        //User has no access, redirect to warning screen
        %><script>window.location.href='<c:url value="main.do?Page=novipaccess.jsp"/>';</script><%
        out.flush();
    }
    if(activePatient!=null){
    	session.setAttribute("activePatient",activePatient);
    }

    boolean bMenu = false;
    if((activePatient!=null) && (activePatient.lastname!=null) && (activePatient.personid.trim().length() > 0)){
        if(!sPage.equals("patientslist.jsp")){
            bMenu = true;
        }
    } 
    else{
        activePatient = new AdminPerson();
    }

    boolean isEmployee = activePatient.isEmployee();
    Debug.println("dropdownmenu : isEmployee : "+isEmployee);
%>

<table width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="*">
            <div id="topmenu">
                <ul class="level1" id="root">
                    <%
                        //-- menus ----------------------------------------------------------------
                        SAXReader xmlReader = new SAXReader();
                        String sMenu = checkString((String) session.getAttribute("MenuXML"));
                        Document document;
                        
                        if(sMenu.length() > 0){
                            document = xmlReader.read(new StringReader(sMenu));
                        }
                        else{
                            String sMenuXML = MedwanQuery.getInstance().getConfigString("MenuXMLFile","menu.xml");
                            String sMenuXMLUrl = "http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")+"/"+sAPPDIR+"/_common/xml/"+sMenuXML+"&ts="+getTs();

                            // Check if menu file exists, else use file at templateSource location.
                            try{
                                document = xmlReader.read(new URL(sMenuXMLUrl));
                                Debug.println("Using custom menu file : "+sMenuXMLUrl);
                            }
                            catch(DocumentException e){
                                sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource")+"/"+sMenuXML;
                                document = xmlReader.read(new URL(sMenuXMLUrl));
                                Debug.println("Using default menu file : "+sMenuXMLUrl);
                            }
                            session.setAttribute("MenuXML",document.asXML());
                        }
                        
                        Vector vMenus = new Vector();
                        Menu menu;
                        if(document!=null){
                            Element root = document.getRootElement();
                            if(root!=null){
                                Iterator elements = root.elementIterator("Menu");
                                while(elements.hasNext()){
                                    menu = new Menu();
                                    menu.parse((Element)elements.next());
                                    vMenus.add(menu);
                                }
                            }
                        }

                        // menus
                        Menu subMenu;
                        for(int i=0; i<vMenus.size(); i++){
                            menu = (Menu) vMenus.elementAt(i);
                            String subs = "";

                            if((menu.dossierselected.equalsIgnoreCase("true") && (activePatient==null || activePatient.personid.length()==0))){
                                continue;
                            }
                            else if((menu.patientselected.equalsIgnoreCase("true")&!bMenu) || (menu.employeeselected.equalsIgnoreCase("true")&!isEmployee)){
                                continue;
                            }
                            else if(!menu.isEnabled){
                            	continue;
                            }
                            else if(menu.menus.size() > 0){
                                if(!menu.labelid.equalsIgnoreCase("hidden")){
                                    for(int y=0; y<menu.menus.size(); y++){
                                        subMenu = (Menu)menu.menus.elementAt(y);
                                         
                                        if((subMenu.dossierselected.equalsIgnoreCase("true") && (activePatient==null || activePatient.personid.length()==0))){
                                            continue;
                                        }
                                        else if((subMenu.patientselected.equalsIgnoreCase("true")&!bMenu) || (subMenu.employeeselected.equalsIgnoreCase("true")&!isEmployee)){
                                            continue;
                                        }
                                        else{
                                            subs+= subMenu.makeMenu(bMenu,sWebLanguage,menu.labelid,activeUser,(y==menu.menus.size() - 1),activePatient,isEmployee);
                                        }
                                    }
                                    
                                    out.print("<li class='menu_"+menu.labelid+"'>");
                                    out.print("<a "+(menu.accesskey.length()>0?"accesskey=\""+menu.accesskey+"\"":"")+" href='javascript:void(0)' class='parent'>"+getTranNoLink("Web",menu.labelid,sWebLanguage)+"</a>");
                                    out.print("<ul class='level2'>");
                                    out.print(subs);
                                    out.print("</ul></li>");
                                }
                            }
                            // no submenus
                            else{
                                if(!menu.patientselected.equalsIgnoreCase("true") || bMenu){
                                    // only add menu to menubar if the user has the required accessright
                                    // or when no accessright is specified or when the user has 'sa' as a userparameter
                                    if((menu.accessrights.length() > 0 && activeUser.getAccessRight(menu.accessrights)) ||
                                        menu.accessrights.length()==0) /*|| activeUser.getParameter("sa").length()>0)*/ {
                                        if(menu.url.length() > 0){
                                            if(menu.url.startsWith("/")){
                                                menu.url = sCONTEXTPATH+menu.url;
                                            }
                                            
                                            if(menu.url.indexOf("javascript:") < 0){
                                                if(menu.url.indexOf("?") > 0) menu.url+= "&ts="+getTs();
                                                else                          menu.url+= "?ts="+getTs();
                                            }
                                        }
                                        
                                        if(menu.url.endsWith(";")){
                                        	menu.url = menu.url.substring(0,menu.url.indexOf(";")-1);
                                        }

                                        out.print("<li class='menu_"+menu.labelid+"'>");

                                    	if(menu.url.startsWith("javascript:")){
                                    		out.print("<a "+(menu.accesskey.length()>0?"accesskey=\""+menu.accesskey+"\"":"")+" href='#' onClick=\""+menu.url+"\">"+getTranNoLink("Web",menu.labelid,sWebLanguage)+"</a>");                                            
                                    	}
                                    	else{
                                    		out.print("<a "+(menu.accesskey.length()>0?"accesskey=\""+menu.accesskey+"\"":"")+" href='#' onClick=\"javascript:clickMenuItem('"+menu.url+"');\">"+getTranNoLink("Web",menu.labelid,sWebLanguage)+"</a>");
                                        }
                                    	
                                        out.print("</li>");                                       
                                    }
                                }
                            }
                        }
                        
                        String sHelp = MedwanQuery.getInstance().getConfigString("HelpFile");%>
                </ul>
            </div>
        </td>
    </tr>
</table>

<script>    
  <%-- OPEN HELP FILE --%>
  function openHelpFile(){
    window.open("<%=sHelp.replaceAll("@@language@@",activeUser.person.language.toLowerCase())%>");
  }

  <%-- NEW ENCOUNTER --%>
  function newEncounter(){
    <%
        Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
        if(activeEncounter!=null && activeEncounter.getEnd()==null){
            %>alertDialog("web","close.active.encounter.first");<%
        }
        else{
            %>window.location.href = '<c:url value="/main.do"/>?Page=adt/editEncounter.jsp&ts=<%=getTs()%>';<%
        }
    %>
  }
  <%-- NEW FAST ENCOUNTER --%>
  function newFastEncounter(init){
    <%
        activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
        if(activeEncounter!=null && activeEncounter.getEnd()==null){
            %>alertDialog("web","close.active.encounter.first");<%
        }
        else{
            %>
              var url = '<c:url value="/"/>/adt/newEncounter.jsp?ts=<%=getTs()%>&init='+init;
              new Ajax.Request(url,{
                method: "GET",
                parameters: "",
                onSuccess: function(resp){
                  window.location.reload();
                }
              });
            <%
        }
    %>
  }
  <%-- NEW FAST TRANSACTION --%>
  function newFastTransaction(transactionType){
    if(<%=Encounter.selectEncounters("","","","","","","","",activePatient.personid,"").size()%>>0){
      window.location.href='<c:url value="/"/>healthrecord/createTransaction.do?be.mxs.healthrecord.createTransaction.transactionType='+transactionType+'&ts=<%=getTs()%>';
    }
    else{
      alertDialog("web","create.encounter.first");
    }
  }

  <%-- READ BARCODE --%>
  function readBarcode(){
	    openPopup("/_common/readBarcode.jsp&ts=<%=getTs()%>");
	  }
	    
  function showPACS(){
	    openPopup("/pacs/studyList.jsp&ts=<%=getTs()%>",800,400).focus();
	  }
	    
  function xmlReport(fname){
	    var URL = "<c:url value='util/createXMLReportPdf.jsp'/>?filename="+fname;
	    window.open(URL);
	  }
  function doPanorama(uid){
	  var w = 800;
	  var h = 600;
	  if(uid){
		  openPopup("/ikirezi/panorama.jsp&init=1&encounteruid="+uid+"&ts=<%=getTs()%>",w,h).focus();
	  }
	  else{
		  openPopup("/ikirezi/panorama.jsp&init=1&ts=<%=getTs()%>",w,h).focus();
	  }
  }
	    
  function doClinicalPathways(uid){
	  if(uid){
		  openPopup("/ikirezi/clinicalPathways.jsp&encounteruid="+uid+"&ts=<%=getTs()%>",1024,600).focus();
	  }
	  else{
		  openPopup("/ikirezi/clinicalPathways.jsp&ts=<%=getTs()%>",1024,600).focus();
	  }
  }

  function doAssistant(){
	    openPopup("/ikirezi/assistant.jsp&type=investigations&ts=<%=getTs()%>",500,300).focus();
	  }
	    
  function createTransactionItem(transactiontype,itemtype){
	    openPopup("/system/manageTransactionItems.jsp&transactionTypeId="+transactiontype+"&itemTypeId="+itemtype.replace("[","%5B").replace("]","%5D")+"&ActionField=Save&ts=<%=getTs()%>",800,600).focus();
	  }
  function searchGeneralNomenclature(CategoryUidField,CategoryNameField,type){
	    openPopup("/_common/search/searchNomenclatureGeneral.jsp&ts=<%=getTs()%>&FindType="+type+"&VarCode="+CategoryUidField+"&VarText="+CategoryNameField);
	}
  function updateMultiCheckbox(cbField,hiddenField,sID){
	  var cbChecked = cbField.checked;
	  var cbValues = document.getElementById(hiddenField).value;
	  if(cbChecked && cbValues.indexOf(sID+";")<0){
		  document.getElementById(hiddenField).value=document.getElementById(hiddenField).value+sID+";"
	  }
	  else if(!cbChecked){
		  document.getElementById(hiddenField).value=document.getElementById(hiddenField).value.replace(sID+";","");
	  }
  }
	    
  function uploadDocs(){
	    openPopup("/util/uploadDocuments.jsp&ts=<%=getTs()%>",400,400).focus();
	  }
  
  function pharmacyDeliveryQueues(){
	    openPopup("pharmacy/managePharmacyQueue.jsp&ts=<%=getTs()%>",800,600).focus();
  }
	    
  function readBarcode2(barcode){
    var transform = "<%=MedwanQuery.getInstance().getConfigString("CCDKeyboardTransformString","�&�\\\"'(��!�")%>";
    var oldbarcode = barcode;
    barcode = "";
    for(var n=0; n<oldbarcode.length; n++){
      if(transform.indexOf(oldbarcode.substring(n,n+1)) > -1){
        barcode = barcode+transform.indexOf(oldbarcode.substring(n,n+1));
      }
      else{
        barcode = barcode+oldbarcode.substring(n,n+1);
      }
    }
    document.getElementsByName('barcode')[0].style.visibility = "hidden";
    if(barcode.substring(0,1)=="0"){
        window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID="+barcode.substring(1);
    }
    else if(barcode.substring(0,1)=="T"){
        window.location.href = "<c:url value='/main.do'/>?Page=curative/loadTicketPerson.jsp&ts=<%=ScreenHelper.getTs()%>&TicketID="+barcode.substring(1);
    }
    else if(barcode.substring(0,1)=="1"){
      alert("OldBarcode = "+oldbarcode);
      alert("Barcode = "+barcode);
    }
    else if(barcode.substring(0,1)=="2"){
      if(document.getElementById('sampleReceiver')!=undefined){
    	var code="'receive.<%=MedwanQuery.getInstance().getConfigString("serverId")%>."+barcode.substring(1,barcode.length-1)+"'";
    	//alert(code);
        document.getElementById('sampleReceiver').innerHTML = "<input type='hidden' name="+code+" value='1'/>";
        frmSampleReception.submit();
      }
    }
    else if(barcode.substring(0,1)=="4" || barcode.substring(0,1)=="5"){
        window.open("<c:url value='/popup.jsp'/>?Page=_common/readBarcode.jsp&ts=<%=ScreenHelper.getTs()%>&barcode="+barcode,"barcode","toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no");
      }
    else if(barcode.substring(0,1)=="R"){
        url = "<c:url value='/main.do'/>?Page=financial/patientCreditEdit.jsp&ts=<%=ScreenHelper.getTs()%>&LoadPatientId=true&FindPatientCreditUID="+barcode.substring(1);
        window.location.href = url;
      }
    else if(barcode.substring(0,1)=="7"){
        url = "<c:url value='/main.do'/>?Page=financial/patientInvoiceEdit.jsp&ts=<%=ScreenHelper.getTs()%>&LoadPatientId=true&FindPatientInvoiceUID="+barcode.substring(1);
        window.location.href = url;
      }
    else if(barcode.substring(0,1)=="8"){
        url = "<c:url value='/main.do'/>?Page=financial/patientCreditEdit.jsp&ts=<%=ScreenHelper.getTs()%>&LoadPatientId=true&FindPatientCreditUID="+barcode.substring(1);
        window.location.href = url;
      }
    else if(barcode.substring(0,1)=="9"){
        url = "<c:url value='/main.do'/>?Page=pharmacy/manageProductStockDocuments.jsp&ts=<%=ScreenHelper.getTs()%>&doaction=edit&documentuid="+barcode.substring(1);
        window.location.href = url;
      }
  }

  function executeLocalDeviceCommand(devicetype,examtype){
  	var url = "<%=MedwanQuery.getInstance().getConfigString("executeDeviceCommand","http://localhost/diagnostics/startDevice.jsp")%>?ts="+new Date().getTime()+
  		"&devicetype="+devicetype+
		"&examtype="+examtype+
		"&personid=<%=activePatient==null?"":activePatient.personid%>"+
		"&lastname=<%=activePatient==null?"":activePatient.lastname%>"+
		"&firstname=<%=activePatient==null?"":activePatient.firstname%>"+
		"&dateofbirth=<%=activePatient==null?"":activePatient.dateOfBirth%>"+
		"&gender=<%=activePatient==null?"":activePatient.gender%>"+
		"&userid=<%=activeUser==null?"":activeUser.userid%>"+
		"&username=<%=activeUser==null?"":activeUser.person.getFullName()%>"+
		"&clinicname=<%=getTranNoLink("web","hospitalname",sWebLanguage)%>";
  	window.open(url);
  }

  <%-- READ BARCODE 3 --%>
  function readBarcode3(barcode){
    var transform = "<%=MedwanQuery.getInstance().getConfigString("CCDKeyboardTransformString","�&�\\\"'(��!�")%>";
    var oldbarcode = barcode;
    barcode = "";
    for(var n=0; n<oldbarcode.length; n++){
      if(transform.indexOf(oldbarcode.substring(n,n+1)) > -1){
        barcode = barcode+transform.indexOf(oldbarcode.substring(n,n+1));
      }
      else{
        barcode = barcode+oldbarcode.substring(n,n+1);
      }
    }
    document.getElementsByName('barcode')[0].style.visibility = "hidden";
    if(barcode.substring(0,1)=="0"){
      window.open("<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID="+barcode.substring(1), "Popup"+new Date().getTime(), "toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width - 800) / 2, (screen.height - 600) / 2);
    }
  }
  
  function getTransactionHistory(transactionid,depth){
    openPopup("healthrecord/getTransactionHistory.jsp&ts=<%=getTs()%>&transactionid="+transactionid+"&depth="+depth,1000,600);
  }

  function getWicketOperationHistory(uid,depth){
    openPopup("financial/getWicketOperationHistory.jsp&ts=<%=getTs()%>&uid="+uid+"&depth="+depth,1000,600);
  }
    
  <%-- CREATE ARCHIVE FILE --%>
  function createArchiveFile(){
    openPopup("_common/createArchiveFile.jsp&ts=<%=getTs()%>",1,1);
  }

  <%-- READ FINGER PRINT --%>
  function readFingerprint(){
    <%
        if(checkString(MedwanQuery.getInstance().getConfigString("referringServer")).length()==0){
            %>openPopup("_common/readFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%="http://"+request.getServerName()+"/"+sCONTEXTPATH%>",400,100);<%
        }
        else{
            %>openPopup("_common/readFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%=MedwanQuery.getInstance().getConfigString("referringServer")+sCONTEXTPATH%>",400,300);<%
        }
    %>
  }
  
  <%-- ENROLL FINGER PRINT --%>
  function enrollFingerPrint(){
    <%
        if(checkString(MedwanQuery.getInstance().getConfigString("referringServer")).length()==0){
            %>openPopup("_common/enrollFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%="http://"+request.getServerName()+"/"+sCONTEXTPATH%>");<%
        }
        else{
            %>openPopup("_common/enrollFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%=MedwanQuery.getInstance().getConfigString("referringServer")+sCONTEXTPATH%>");<%
        }
    %>
  }
  function printPatientCard(){
	    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
	    window.open("<c:url value='/adt/createPatientCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);
	  }
  function printBloodDonorCard(){
	    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
	    window.open("<c:url value='/cnts/createDonorCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);
	  }
  function printInsuranceCard(){
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter", "Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no, resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
    window.open("<c:url value='/adt/createInsuranceCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes, resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);
  }
  function printCNOMCard(){
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
    window.open("<c:url value='/adt/createCNOMCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width-400)/2,(screen.height-300)/2);
  }
  function copyTextToClipboard(text) {
	  var textArea = document.createElement("textarea");

	  //
	  // *** This styling is an extra step which is likely not required. ***
	  //
	  // Why is it here? To ensure:
	  // 1. the element is able to have focus and selection.
	  // 2. if element was to flash render it has minimal visual impact.
	  // 3. less flakyness with selection and copying which **might** occur if
	  //    the textarea element is not visible.
	  //
	  // The likelihood is the element won't even render, not even a flash,
	  // so some of these are just precautions. However in IE the element
	  // is visible whilst the popup box asking the user for permission for
	  // the web page to copy to the clipboard.
	  //

	  // Place in top-left corner of screen regardless of scroll position.
	  textArea.style.position = 'fixed';
	  textArea.style.top = 0;
	  textArea.style.left = 0;

	  // Ensure it has a small width and height. Setting to 1px / 1em
	  // doesn't work as this gives a negative w/h on some browsers.
	  textArea.style.width = '2em';
	  textArea.style.height = '2em';

	  // We don't need padding, reducing the size if it does flash render.
	  textArea.style.padding = 0;

	  // Clean up any borders.
	  textArea.style.border = 'none';
	  textArea.style.outline = 'none';
	  textArea.style.boxShadow = 'none';

	  // Avoid flash of white box if rendered for any reason.
	  textArea.style.background = 'transparent';


	  textArea.value = text;

	  document.body.appendChild(textArea);
	  textArea.focus();
	  textArea.select();

	  try {
	    var successful = document.execCommand('copy');
	    var msg = successful ? 'successful' : 'unsuccessful';
	    console.log('Copying text command was ' + msg);
	  } catch (err) {
	    console.log('Oops, unable to copy');
	  }

	  document.body.removeChild(textArea);
	}
	function doc_keyUp(e) {
		if(e.altKey  && e.keyCode==84){
			toggleEditMode(true);
		}
  		<%if(checkString((String)session.getAttribute("editmode")).equals("1")){%>
			if(e.ctrlKey  && e.keyCode==67){
				document.getElementById("copytocb").onclick();
			}
  		<%}%>
	}
	// register the handler if edit has been toggled
	document.addEventListener('keyup', doc_keyUp, false);

  function printWordDocuments(transactionuid){
	  if(transactionuid && transactionuid.length>0){
		  openPopup("<c:url value='util/printWordDocuments.jsp'/>&transactionuid="+transactionuid+"&ts=<%=getTs()%>&PopupWidth=600&PopupHeight=300");
	  }
	  else{
		  openPopup("<c:url value='util/printWordDocuments.jsp'/>&ts=<%=getTs()%>&PopupWidth=600&PopupHeight=300");
	  }
  }

  
  function printPatientLabel(){
	    window.open("<c:url value='/adt/createPatientLabelPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300)/2);
  }
  function printClinixRecord(){
	    window.open("<c:url value='/util/exportClinix.jsp'/>?ts=<%=getTs()%>&personid=<%=activePatient.personid%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300)/2);
  }
    function printMedicalCard(){
	    window.open("<c:url value='/print/printMedicalCard.jsp'/>?ts=<%=getTs()%>&personid=<%=activePatient.personid%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width - 800) / 2, (screen.height - 600)/2);
  }
  function storePicture(){
    var url = "<c:url value='/util/ajax/webcam.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:'<%=getTranNoLink("web","storePicture",sWebLanguage)%>',width:650});
  }
  function showPicture(){
    var url = "<c:url value="/util/ajax/showPicture.jsp"/>?personid=<%=activePatient!=null?activePatient.personid:"0"%>&ts="+new Date().getTime();
    Modalbox.show(url,{title:'<%=getTranNoLink("web","showPicture",sWebLanguage)%>',width:250,height:350});
  }
  function deletePicture(){
    var url = "<c:url value='/util/ajax/deletePicture.jsp'/>?personid=<%=activePatient!=null?activePatient.personid:"0"%>&ts="+new Date().getTime();
    window.open(url);
  }

  <!-- here -->
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/printPatient.jsp&Field=mijn&ts=<%=getTs()%>");
  }

  function deletepaperprescription(prescriptionuid){
    if(yesnoDeleteDialog()){
      window.open('<c:url value='/medical/deletePaperPrescription.jsp'/>?ts=<%=getTs()%>&prescriptionuid='+prescriptionuid,"delete","toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
    }
  }
    
  <%-- GET POS PRINTER SERVER --%>
  function getPOSPrinterServer(){
    var POSPrinterServer = 'http://localhost/openclinic';
    var url = '<%=MedwanQuery.getInstance().getConfigString("javaPOSServer","http://localhost/openclinic")%>/util/getPOSPrinterServer.jsp';
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        if(label.server.length>0){
          POSPrinterServer=label.server;
        }
      }
    });
    return POSPrinterServer;
  }


  function toggleEditMode(dorefresh){
    var today = new Date();
    var url= '<c:url value="/system/toggleEditMode.jsp"/>?language=<%=sWebLanguage%>&ts='+today;
	new Ajax.Request(url,{
	  method: "POST",
      parameters: "",
      onSuccess: function(resp){
    	  if(document.getElementById('editmode')){
    		  document.getElementById('editmode').innerHTML=resp.responseText;
    	  }
    	  if(dorefresh){
    		  window.location.reload();
    	  }
      }
	});
  }

  <%-- CONFIRM LOGOUT --%>
  function confirmLogout(){
    if(verifyPrestationCheck()){
      yesnoDialog("web.occup","confirm.logout",function(){
    	document.location.href = "<c:url value='/logout.do'/>?ts=<%=getTs()%>";
      });
    }
  }

  <%-- CLOSE MODALBOX--%>
  function closeModalbox(msg,time){
    if(!msg){
      Modalbox.hide();
    }
    else{
      if(!time) time = 1000;
      Modalbox.show('<div class=\'valid\'><p>'+msg+'</p><p style="text-align:center"><input class=\'button\' type=\'button\' style=\'padding-left:7px;padding-right:7px\' value=\'<%=getTranNoLink("web","ok",sWebLanguage)%>\' onclick=\'Modalbox.hide()\'/></p></div>',{title:"...",width:200});
      setTimeout("Modalbox.hide()",time);
    }
  }

  <%-- YESNO MODALBOX (2 buttons) --%>
  function yesnoModalBox(yesFunction,msg){
    var html = "<div style='border:1px solid #bbccff;padding:1px;'>"+
			    "<p style='text-align:center'>"+msg+"</p>"+
			    "<p style='text-align:center'>"+
			     "<input type='button' class='button' style='padding-left:7px;padding-right:7px' value='<%=getTranNoLink("web","yes",sWebLanguage)%>' onclick='"+yesFunction+";Modalbox.hide();'/>&nbsp;&nbsp;"+
			     "<input type='button' class='button' style='padding-left:7px;padding-right:7px' value='<%=getTranNoLink("web","no",sWebLanguage)%>' onclick='Modalbox.hide();'/>"+
			    "</p>"+
			   "</div>";
    Modalbox.show(html,{title:'<%=getTranNoLink("web","message",sWebLanguage)%>',width:300});
  }

  <%-- REFRESH WINDOW --%>
  function refreshWindow(){
    window.location.reload(true);
  }
  
  function deletekeywordindb(type,id,targettextfield){
	  if(confirm("<%=getTran(null,"Web","AreYouSure",sWebLanguage)%>")){
		  	var params = "labeltype="+type+"&labelid="+id;
		   	var url = '<c:url value="/healthrecord/ajax/deleteKeyword.jsp"/>?ts='+new Date().getTime();
			new Ajax.Request(url,{
			method: "POST",
			parameters: params,
			onSuccess: function(resp){
				document.getElementById(targettextfield).click();
		    }
			});
	  }
  }
  
  <%-- OPEN POPUP --%>
  function openPopup(page,width,height,title,parameters){
    var url = "<c:url value='/popup.jsp'/>?Page="+page;
    if(width!=undefined){
    	url+= "&PopupWidth="+width;
    }
    else{
   		width=1;
    }
    if(height!=undefined){
    	url+= "&PopupHeight="+height;
    }
    else{
   		height=1;
    }
    if(title==undefined){
      if(page.indexOf("&") < 0){
        title = page.replace("/","_");
        title = replaceAll(title,".","_");
      }
      else{
        title = replaceAll(page.substring(1,page.indexOf("&")),"/","_");
        title = replaceAll(title,".","_");
      }
    }
    if(!parameters || parameters.length==0){
    	parameters="toolbar=no,status=yes,scrollbars=yes,resizable=yes,width="+width+",height="+height+",menubar=no";
    }
    popup = window.open(url,title,parameters);
    if(width && height){
    	popup.resizeTo(width,height);
    }
    popup.moveBy(2000,2000);
    return popup;
  }
  
  <%-- REPLACE ALL --%>
  function replaceAll(s,s1,s2){
    while(s.indexOf(s1) > -1){
      s = s.replace(s1,s2);
    }
    return s;
  }
    
  <%-- OPEN SEARCH IN PROGRESS POPUP --%>
  function openSearchInProgressPopup(){
    var popupWidth = 250;
    var popupHeight = 120;
    popup = window.open("","Searching","titlebar=no,title=no,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width="+popupWidth+",height="+popupHeight);
    popup.moveTo((this.screen.width-popupWidth)/2,(this.screen.height-popupHeight)/2);
    popup.document.write("<head><title><%=sWEBTITLE+" "+sAPPTITLE%></title><%=sCSSNORMAL%></head>");
    popup.document.write("<body onBlur='this.focus();' cellpadding='0' cellspacing='0'>");
    popup.document.write("<table width='100%' height='100%' cellspacing='0' cellpadding='0'>");
     popup.document.write("<tr>");
      popup.document.write("<td bgcolor='#eeeeee' style='text-align:center'>");
       popup.document.write("<%=getTran(null,"web","searchInProgress",sWebLanguage)%>");
      popup.document.write("</td>");
     popup.document.write("</tr>");
    popup.document.write("</table>");
    popup.document.write("</body>");
    popup.document.close();
    popup.focus();
  }
  <%-- show drugs out barcode --%>
  function showdrugsoutbarcode(){
    openPopup("pharmacy/drugsOutBarcode.jsp&ts=<%=getTs()%>",700,500);
  }
  <%-- show global health barometer --%>
  function showglobalhealthbarometer(){
    window.open("http://www.globalhealthbarometer.net/globalhealthbarometer/datacenter/datacenterHomePublic.jsp?me=<%=MedwanQuery.getInstance().getConfigString("globalHealthBarometerUID","")%>&ts=<%=getTs()%>");
  }
  <%-- show sourge force --%>
  function showsourceforge(){
    window.open("http://sourceforge.net/projects/open-clinic");
  }
  <%-- show wiki --%>
  function showwiki(){
    window.open("http://ice.minf.be/xwiki");
  }
  <%-- open RFE list --%>
  function openRFEList(){
    <%
        if(activePatient!=null && activePatient.personid.length() > 0){
            Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
            if(encounter!=null){
                %>openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=encounter.getUid()%>&ts=<%=getTs()%>',700,400);<%
            }
        }
    %>
  }
  function quickinventoryupdate(){
	    void(0);
	    openPopup("/pharmacy/quickInventoryUpdate.jsp&ts=<%=getTs()%>",300,400);
	  }
  function showAdminPopup(){
	    openPopup("/_common/patient/patientdataPopup.jsp&ts=<%=getTs()%>");
	  }
  
  function showQueues(){
      window.open("<c:url value='/util/manageQueues.jsp'/>?ts=<%=getTs()%>","Queue","toolbar=no,status=no,scrollbars=yes,resizable=yes,width=800,height=740,location=no,menubar=no").moveTo((screen.width - 800) / 2,(screen.height - 620) / 2);
	  //openPopup("/util/manageQueues.jsp&ts=<%=getTs()%>&PopupWidth=800&PopupHeight=620");
  }
  function searchLab(){
    window.location.href = "<c:url value="/"/>main.do?Page=labos/showLabRequestList.jsp&ts=<%=getTs()%>";
  }
  function showLabResultsEdit(){
    window.location.href = "<c:url value="/"/>main.do?Page=labos/manageLaboResultsEdit.jsp&type=patient&open=true&Action=find&ts=<%=getTs()%>";
  }
  function searchMyHospitalized(){
    clearPatient();
    SF.Action.value = "MY_HOSPITALIZED";
    SF.submit();
  }
  function searchMyVisits(){
    clearPatient();
    SF.Action.value = "MY_VISITS";
    SF.submit();
  }

  <%-- show manual --%>
  function showmanual(){
    <%
        if(MedwanQuery.getInstance().getConfigString("documentationLanguages","en,fr").toLowerCase().indexOf(sWebLanguage.toLowerCase())>-1){
            %>window.open("<c:url value="/documents/help/"/>openclinic_manual_<%=sWebLanguage.toLowerCase()%>.pdf");<%
        }
        else{
            %>window.open("<c:url value="/documents/help/"/>openclinic_manual_en.pdf");<%
        }
    %>
  }    
  
  function showmanualgmao(){
	    <%
	        if(MedwanQuery.getInstance().getConfigString("documentationLanguages","en,fr").toLowerCase().indexOf(sWebLanguage.toLowerCase())>-1){
	            %>window.open("<c:url value="/documents/help/"/>gmao_manual_<%=sWebLanguage.toLowerCase()%>.pdf");<%
	        }
	        else{
	            %>window.open("<c:url value="/documents/help/"/>gmao_manual_en.pdf");<%
	        }
	    %>
	  }    
  
  function showversionhistory(){
	    var w = window.open("<c:url value='/util/versions.txt'/>");
  }
    
  function showteleconsultation(){
	  var key=window.prompt('<%=getTranNoLink("web","teleconsultationkey",sWebLanguage)%>');
	  if(key.length>0){
		  key='/r/'+key;
	  }
	  window.open("https://appr.tc"+key,"OpenClinic-Teleconsultation","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
  }
  
  function showsmartglasses(){
	  var key=window.prompt('<%=getTranNoLink("web","teleconsultationkey",sWebLanguage)%>');
	  if(key && key!='null'){
		  window.open("https://wizzeye.app/"+key,"OpenClinic-Teleconsultation","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	  }
  }
  
  function downloadPharmacyExport(){
    var w = window.open("<c:url value='/pharmacy/exportFile.jsp'/>");
  }

  <%
      if(MedwanQuery.getInstance().getConfigInt("enableNationalBarcodeID",0)==1){
  %>
  function redirectNationalBarcodeId(id,lastname,firstname){
    window.location.href = '<c:url value="/"/>/main.do?Page=_common/patientslist.jsp?findnatreg='+id+'&findName='+lastname+'&findFirstname='+firstname;
  }
    
  function checkNationalBarcodeIdRedirect(){
    var url = '<c:url value="/adt/ajaxActions/checkNationalBarcodeId.jsp"/>?natreg=<%=activePatient==null?"":activePatient.getID("natreg")%>&ts='+new Date().getTime();
    new Ajax.Request(url,{
      method:"GET",
      parameters:"",
      onSuccess:function(resp){
        var data = resp.responseText.split("$");
        if(data.length > 1){
          redirectNationalBarcodeId(data[0],data[1],data[2]);
        }
      }
    });
  }
  window.setInterval('checkNationalBarcodeIdRedirect();',2000);
  <%
      }
  %>
    
  <%-- ADD AUTO COMPLETER --%>
  function addAutoCompleter(key,id,div){
    new Ajax.Autocompleter(id,div,'util/loadAutoCompleteItems.jsp?key='+key,{   
      inChars:1,
      method:'post',
      callback:genericEventDateCallback
    });
  }
  
  function showLibrary(){
	  openPopup("util/library.jsp&PopupWidth=800&PopupHeight=600");
  }
    
  function genericEventDateCallback(element,entry){
    return "search="+element.value;
  }
</script>