<%@page import="java.io.StringReader,
                org.dom4j.DocumentException,
                java.util.Vector" %>
<%@page errorPage="/includes/error.jsp" %>
<%@include file="/_common/templateAddIns.jsp" %>
<script src="<c:url value='/_common/_script/menu.js'/>"></script>

<%!
    //### INNERCLASS MENU #########################################################################
    public class Menu {
        public String labelid;
        public String accessrights;
        public String url;
        public String patientselected;
        public String activeencounter;
        public Vector menus;
        public String target;
        
        //--- CONSTRUCTOR -------------------------------------------------------------------------
        public Menu(){
            labelid = "";
            accessrights = "";
            url = "";
            patientselected = "";
            menus = new Vector();
            target = "";
        }
        //--- PARSE -------------------------------------------------------------------------------
        public void parse(Element eMenu){
            this.accessrights = checkString(eMenu.attributeValue("accessrights")).toLowerCase();
            this.labelid = checkString(eMenu.attributeValue("labelid")).toLowerCase();
            this.patientselected = checkString(eMenu.attributeValue("patientselected"));
            this.activeencounter = checkString(eMenu.attributeValue("activeencounter"));
            this.target = checkString(eMenu.attributeValue("target"));

            // replace ; by & if url is no javascript
            if(checkString(eMenu.attributeValue("url")).indexOf("javascript:") > -1){
                this.url = checkString(eMenu.attributeValue("url"));
            } else {
                this.url = checkString(eMenu.attributeValue("url")).replaceAll(";","&");
            }
            Menu childMenu;
            Element eChildMenu;
            Iterator eMenus = eMenu.elementIterator("Menu");
            while (eMenus.hasNext()){
                eChildMenu = (Element) eMenus.next();
                childMenu = new Menu();
                childMenu.parse(eChildMenu);
                this.menus.add(childMenu);
            }
        }
        //--- MAKE MENU ---------------------------------------------------------------------------
        public String makeMenu(boolean bMenu, String sWebLanguage, String sParentMenu, User user, boolean last, AdminPerson activePatient){
            String sReturn = "";
            try{
                if(this.accessrights.length() > 0){
                    // permission 'sa' can see everything
                    //                   if(user.getParameter("sa").length()==0){
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
                    else {
                        if(!user.getAccessRight((this.accessrights+".edit")) ||
                                !user.getAccessRight((this.accessrights+".add")) ||
                                //!user.getAccessRight((this.accessrights+".select")) ||
                                !user.getAccessRight((this.accessrights+".delete"))){
                            return "";
                        }
                    }
                    //                 }
                }
                
                if(this.activeencounter.equalsIgnoreCase("true")){
                	if(activePatient==null || Encounter.getActiveEncounter(activePatient.personid)==null){
                		return "";
                	
                	}
                }
                if((patientselected.equalsIgnoreCase("true")) && !bMenu){
                    return "";
                }
                
                if(this.url.length() > 0){
                    // leave url as-is if it contains a javascript call
                    if(!this.url.startsWith("javascript:")){
                        if(this.url.startsWith("/")){
                            this.url = sCONTEXTPATH+this.url;
                        }
                        if(this.url.indexOf("?") > 0) this.url += "&ts="+getTs();
                        else this.url += "?ts="+getTs();
                    }
                    sReturn += "";
                }

                // menu has submenus
                String sTranslation = getTranNoLink("Web",this.labelid,sWebLanguage);
                String subsubMenu = "";
                if(this.menus.size() > 0){
                    Menu subMenu;
                    for (int y = 0; y < this.menus.size(); y++){
                        subMenu = (Menu) this.menus.elementAt(y);
                        subsubMenu += subMenu.makeMenu(bMenu,sWebLanguage,this.labelid,user,(y==this.menus.size() - 1),activePatient);
                    }
                    
                    if(this.target.length() > 0){
                        sReturn+= "<li><a href='javascript:void(0); class='subparent''>"+sTranslation+"</a>";
                        sReturn+= "<ul class='level3'>";
                        sReturn+= (subsubMenu.length()>0)?subsubMenu:"<li><a href='javascript:void(0);'>empty</a></li>";
                        sReturn+= "</ul></li>";
                    }
                    else{
                        sReturn+= "<li><a href='javascript:void(0);' class='subparent'>"+sTranslation+"</a>";
                        sReturn+= "<ul class='level3'>";
                        sReturn+= (subsubMenu.length()>0)?subsubMenu:"<li><a href='javascript:void(0);'>empty</a></li>";
                        sReturn+= "</ul></li>";
                    }
                }
                else{
                    if(this.target.length() > 0){
                        sReturn+= "<li><a href=\""+this.url+"\">"+sTranslation+"</a></li>";
                    }
                    else{
                        sReturn+= "<li><a href=\""+this.url+"\">"+sTranslation+"</a></li>";
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
    String sPage = checkString(request.getParameter("Page")).toLowerCase();
    String sPersonID = checkString(request.getParameter("personid"));
    String sPatientNew = checkString(request.getParameter("PatientNew"));
  
    if(sPage.startsWith("start") || sPage.startsWith("_common/patientslist") || sPatientNew.equals("true")){
        session.removeAttribute("activePatient");
        activePatient = null;
        SessionContainerWO sessionContainerWO = (SessionContainerWO) session.getAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER");
        sessionContainerWO.setPersonVO(null);
%>
<script>
    window.document.title = "<%=sWEBTITLE+" "+getWindowTitle(request,sWebLanguage)%>";
</script>
<%
    }
    else if(sPersonID.length() > 0){
        activePatient = AdminPerson.getAdminPerson(sPersonID);
        session.setAttribute("activePatient",activePatient);
%>
<script>
    window.document.title = "<%=sWEBTITLE+" "+getWindowTitle(request,sWebLanguage)%>";
</script>
<% 
    }
    else {
	    sPersonID = checkString(request.getParameter("PersonID"));
	    if(sPersonID.length() > 0){
	        session.removeAttribute("activePatient");
	        activePatient = AdminPerson.getAdminPerson(sPersonID);
	    }
    }
    
	// check if user has access to the active patient
	if(sPage.indexOf("novipaccess")<0 && activePatient!=null && "1".equalsIgnoreCase((String)activePatient.adminextends.get("vip")) && !activeUser.getAccessRight("vipaccess.select")){
		// User has no access, redirect to warning screen
		%><script>window.location.href='<c:url value="main.do?Page=novipaccess.jsp"/>';</script><%
		out.flush();
	}
	
    session.setAttribute("activePatient",activePatient);
    boolean bMenu = false;
    if((activePatient!=null) && (activePatient.lastname!=null) && (activePatient.personid.trim().length() > 0)){
        if(!sPage.equals("patientslist.jsp")){
            bMenu = true;
        }
    }
    else {
        activePatient = new AdminPerson();
    }
%>
<table width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="*">
            <div id="topmenu">
                <ul class="level1" id="root">
                    <%
                        //-- menus ------------------------------------------------------------------------------------
                        SAXReader xmlReader = new SAXReader();
                        String sMenu = checkString((String) session.getAttribute("AccountancyMenuXML"));
                        Document document;
                        if(sMenu.length() > 0){
                            document = xmlReader.read(new StringReader(sMenu));
                        }
                        else{
                            String sMenuXML = MedwanQuery.getInstance().getConfigString("AccountancyMenuXMLFile");
                            if(sMenuXML.length()==0) sMenuXML = "menu_accountancy.xml";
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
                            session.setAttribute("AccountancyMenuXML",document.asXML());
                        }
                        
                        Vector vMenus = new Vector();
                        Menu menu;
                        if(document!=null){
                            Element root = document.getRootElement();
                            if(root!=null){
                                Iterator elements = root.elementIterator("Menu");
                                while (elements.hasNext()){
                                    menu = new Menu();
                                    menu.parse((Element) elements.next());
                                    vMenus.add(menu);
                                }
                            }
                        }

                        //menus
                        Menu subMenu;
                        for(int i=0; i<vMenus.size(); i++){
                            menu = (Menu)vMenus.elementAt(i);
                            String subs = "";
                            if(menu.patientselected.equalsIgnoreCase("true")&!bMenu){
                            	continue;
                            }
                            else if(menu.menus.size() > 0){
                                for(int y=0; y<menu.menus.size(); y++){
                                    subMenu = (Menu) menu.menus.elementAt(y);
                                    subs+= subMenu.makeMenu(bMenu,sWebLanguage,menu.labelid,activeUser,(y==menu.menus.size() - 1),activePatient);
                                }
                                out.write("<li class='menu_"+menu.labelid+"'>");
                                out.write("<a href='javascript:void(0)' class='parent'>"+getTranNoLink("Web",menu.labelid,sWebLanguage)+"</a>");
                                out.write("<ul class='level2'>");
                                out.write(subs);
                                out.write("</ul></li>");
                            }
                            // no submenus
                            else{
                                if(!menu.patientselected.equalsIgnoreCase("true") || bMenu){
                                    if(menu.url.length() > 0){
                                        if(menu.url.startsWith("/")){
                                            menu.url = sCONTEXTPATH+menu.url;
                                        }
                                        if(menu.url.indexOf("javascript:") < 0){
                                            if(menu.url.indexOf("?") > 0) menu.url += "&ts="+getTs();
                                            else menu.url += "?ts="+getTs();
                                        }
                                    }

                                    // only add menu to menubar if the user has the required accessright
                                    // or when no accessright is specified or when the user has 'sa' as a userparameter
                                    if((menu.accessrights.length() > 0 && activeUser.getAccessRight(menu.accessrights)) ||
                                            menu.accessrights.length()==0) /*|| activeUser.getParameter("sa").length()>0)*/ {
                                        if(menu.target.length() > 0){
                                            out.write("<li class='menu_"+menu.labelid+"'>");
                                            out.write("<a href="+menu.url+">"+getTranNoLink("Web",menu.labelid,sWebLanguage)+"</a>");
                                            out.write("</li>");
                                        } else {
                                            out.write("<li class='menu_"+menu.labelid+"'><a href="+menu.url+">"+getTranNoLink("Web",menu.labelid,sWebLanguage)+"</a></li>");
                                        }
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
    openPopup("<%=sHelp.replaceAll("@@language@@",activeUser.person.language)%>",800,600);
  }
  
  function newEncounter(){
	<%
		Encounter activeEncounter=Encounter.getActiveEncounter(activePatient.personid);
		if(activeEncounter!=null && activeEncounter.getEnd()==null){
            %>alertDialog('web','close.active.encounter.first');<%
		}
		else{
            %>window.location.href='<c:url value="/main.do"/>?Page=adt/editEncounter.jsp&ts=<%=getTs()%>';<%
		}
	%>
  }

  <%-- NEW FAST ENCOUNTER --%>
  function newFastEncounter(init){
	<%
	    activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
		if(activeEncounter!=null && activeEncounter.getEnd()==null){
            %>alertDialog('web','close.active.encounter.first');<%
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
  
  function readBarcode2(barcode){
    var transform = "<%=MedwanQuery.getInstance().getConfigString("CCDKeyboardTransformString","�&�\\\"'(��!�")%>";
    var oldbarcode = barcode;
    barcode = "";
    for (var n=0; n<oldbarcode.length; n++){
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
    else if(barcode.substring(0,1)=="1"){
      alert("OldBarcode = "+oldbarcode);
      alert("Barcode = "+barcode);
    }
    else if(barcode.substring(0,1)=="2"){
      //Registration of sample-entry
      if(document.getElementsByName('sampleReceiver')[0]!=undefined){
        document.getElementsByName('sampleReceiver')[0].innerHTML = "<input type='hidden' name='receive."+barcode.substring(1,3)+"."+barcode.substring(3,11)+"."+(barcode.length > 11 ? barcode.substring(11) : "?")+"' value='1'/>";
        frmSampleReception.submit();
      }
    }
    else if(barcode.substring(0,1)=="4" || barcode.substring(0,1)=="5"){
      window.open("<c:url value='/popup.jsp'/>?Page=_common/readBarcode.jsp&ts=<%=ScreenHelper.getTs()%>&barcode="+barcode,"barcode","toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
    }
    else if(barcode.substring(0,1)=="7"){
      url = "<c:url value='/main.do'/>?Page=financial/patientInvoiceEdit.jsp&ts=<%=ScreenHelper.getTs()%>&LoadPatientId=true&FindPatientInvoiceUID="+barcode.substring(1);
      window.location.href = url;
    }
    else if(barcode.substring(0,1)=="8"){
      url = "<c:url value='/main.do'/>?Page=financial/patientCreditEdit.jsp&ts=<%=ScreenHelper.getTs()%>&LoadPatientId=true&FindPatientCreditUID="+barcode.substring(1);
      window.location.href = url;
    }
  }
    
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
      var url = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID="+barcode.substring(1);
      window.open(url,"Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width - 800) / 2,(screen.height - 600) / 2);
    }
  }
  
  <%-- CREATE ARCHIVE FILE --%>
  function createArchiveFile(){
    openPopup("_common/createArchiveFile.jsp&ts=<%=getTs()%>",1,1);
  }
    
  <%-- READ FINGERPRINT --%>
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

  <%-- ENROLL FINGERPRINT --%>
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
    window.open("<c:url value='/adt/createPatientCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2,(screen.height - 300) / 2);
  }
  function printInsuranceCard(){
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
    window.open("<c:url value='/adt/createInsuranceCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2,(screen.height - 300) / 2);
  }
  function printCNOMCard(){
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
    window.open("<c:url value='/adt/createCNOMCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2,(screen.height - 300) / 2);
  }
  function printPatientLabel(){
    window.open("<c:url value='/adt/createPatientLabelPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2,(screen.height - 300) / 2);
  }
  function storePicture(){
    <%-- window.open("<c:url value='/util/storePicture.jsp'/>?ts=<%=getTs()%>&personid=<%=activePatient!=null?activePatient.personid:"0"%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2,(screen.height - 300) / 2); --%>
    var url = "<c:url value='/util/ajax/webcam.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:'<%=getTranNoLink("web","loadPicture",sWebLanguage)%>',width:650});
  }
  function showPicture(){
	    <%-- openPopup("util/showPicture.jsp&ts=<%=getTs()%>&personid=<%=activePatient!=null?activePatient.personid:"0"%>",400,400); --%>
	    var url = "<c:url value="/util/ajax/showPicture.jsp"/>?personid=<%=activePatient!=null?activePatient.personid:"0"%>&ts="+new Date().getTime();
	    Modalbox.show(url,{title:'<%=getTranNoLink("web","showPicture",sWebLanguage)%>',width:162});
	  }
  function deletePicture(){
    var url = "<c:url value='/util/ajax/deletePicture.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:'<%=getTranNoLink("web","loadPicture",sWebLanguage)%>',width:162});
  }
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/printPatient.jsp&Field=mijn&ts=<%=getTs()%>");
  }
    
  <%-- DELETE PAPER PRESCRIPTION --%>
  function deletepaperprescription(prescriptionuid){
    if(yesnoDeleteDialog()){
      var w = window.open('<c:url value='/medical/deletePaperPrescription.jsp'/>?ts=<%=getTs()%>&prescriptionuid='+prescriptionuid,"delete","toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
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
	    
    <%-- CONFIRM LOGOUT --%>
    function confirmLogout(){
      if(verifyPrestationCheck()){
        if(yesnoDeleteDialog()){
          document.location.href = "<c:url value='/logout.do'/>?ts=<%=getTs()%>";
        }
      }
    }
  }
  <%-- CLOSE MODALBOX--%>
  function closeModalbox(msg,time){
    if(!msg){
      Modalbox.hide();
    }
    else{
      if(!time) time = 1000;
      Modalbox.show('<div class=\'valid\'><p>'+msg+'</p><p style="text-align:center"><input class=\'button\' type=\'button\' style=\'padding-left:7px;padding-right:7px\' value=\'<%=getTranNoLink("web","ok",sWebLanguage)%>\' onclick=\'Modalbox.hide()\' /></p></div>',{title: "...",width:200});
      setTimeout("Modalbox.hide()",time);
    }
  }
  function refreshWindow(){
    window.location.reload(true);
  }
    
  <%-- MODALBOX YES OR NO --%>
  function yesOrNo(myfunction,msg){
    Modalbox.show('<div class=\'warning\'><p>'+msg+'</p><p style="text-align:center"><input class=\'button\' type=\'button\' style=\'padding-left:7px;padding-right:7px\' value=\'<%=getTranNoLink("web","yes",sWebLanguage)%>\' onclick=\'eval("'+myfunction+'");Modalbox.hide()\' />&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;<input type=\'button\' class=\'button\' style=\'padding-left:7px;padding-right:7px\' value=\'<%=getTranNoLink("web","no",sWebLanguage)%>\' onclick=\'Modalbox.hide()\' /></p></div>',{title: "<%=getTranNoLink("web","areyousure",sWebLanguage)%>",width:300});
  }

  <%-- OPEN POPUP --%>
  function openPopup(page,width,height,title){
    var url = "<c:url value='/popup.jsp'/>?Page="+page;
    if(width!=undefined) url+= "&PopupWidth="+width;
    if(height!=undefined) url+= "&PopupHeight="+height;
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
    var w = window.open(url,title,"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
    w.moveBy(2000,2000);
  }
    
  <%-- REPLACE ALL --%>
  function replaceAll(s,s1,s2){
    while(s.indexOf(s1) > -1){
      s = s.replace(s1,s2);
    }
    return s;
  }
  
  <%-- open search in progress popup --%>
  function openSearchInProgressPopup(){
    var popupWidth = 250;
    var popupHeight = 120;
    popup = window.open("","Searching","titlebar=no,title=no,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width="+popupWidth+",height="+popupHeight);
    popup.moveTo((this.screen.width - popupWidth)/2,(this.screen.height-popupHeight)/2);
    popup.document.write("<head><title><%=sWEBTITLE+" "+sAPPTITLE%></title><%=sCSSNORMAL%></head>");
    popup.document.write("<body onBlur='this.focus();' cellpadding='0' cellspacing='0'>");
    popup.document.write("<table width='100%' height='100%' cellspacing='0' cellpadding='0'>");
     popup.document.write("<tr>");
      popup.document.write("<td bgcolor='#eeeeee' style='text-align:center'>");
       popup.document.write("<%=getTranNoLink("web","searchInProgress",sWebLanguage)%>");
      popup.document.write("</td>");
     popup.document.write("</tr>");
    popup.document.write("</table>");
    popup.document.write("</body>");
    popup.document.close();
    popup.focus();
  }
    
  <%-- show admin popup --%>
  function showdrugsoutbarcode(){
   	openPopup("pharmacy/drugsOutBarcode.jsp&ts=<%=getTs()%>",700,500);
  }
  function showglobalhealthbarometer(){
  	window.open("http://www.globalhealthbarometer.net/globalhealthbarometer/datacenter/datacenterHomePublic.jsp?me=<%=MedwanQuery.getInstance().getConfigString("globalHealthBarometerUID","")%>&ts=<%=getTs()%>");
  }
  function showsourceforge(){
  	window.open("http://sourceforge.net/projects/open-clinic");
  }
  function showAdminPopup(){
    openPopup("/_common/patient/patientdataPopup.jsp&ts=<%=getTs()%>");
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
    
  function downloadPharmacyExport(){
	window.open("<c:url value='/pharmacy/exportFile.jsp'/>");
  }

  <%
    if(MedwanQuery.getInstance().getConfigInt("enableNationalBarcodeID",0)==1){
  %>
    function redirectNationalBarcodeId(id,lastname,firstname){
      window.location.href = '<c:url value="/"/>/main.do?Page=_common/patientslist.jsp?findnatreg='+id+'&findName='+lastname+'&findFirstname='+firstname;
    }
    
    function checkNationalBarcodeIdRedirect(){
      var url = '<c:url value="/adt/ajaxActions/checkNationalBarcodeId.jsp"/>?natreg=<%=activePatient==null?"":activePatient.getID("natreg")%>&ts='+new Date();
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
    
  function addAutoCompleter(key,id,div){
    new Ajax.Autocompleter(id,div,'util/loadAutoCompleteItems.jsp?key='+key,{   
	  minChars:1,
	  method:'post',
	  callback:genericEventDateCallback
	});
  }
	
  function genericEventDateCallback(element,entry){
    return "search="+element.value;
  }
</script>