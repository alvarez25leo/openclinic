<%@page import="be.mxs.common.util.io.messync.Examination,
                be.openclinic.system.ServiceExamination,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"system.manageserviceexaminations","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindServiceCode = checkString(request.getParameter("FindServiceCode")),
           sFindServiceText = checkString(request.getParameter("FindServiceText"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** system/manageServiceExaminations.jsp *****************");
        Debug.println("sAction          : "+sAction);
        Debug.println("sFindServiceCode : "+sFindServiceCode);
        Debug.println("sFindServiceText : "+sFindServiceText+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    

    //--- SAVE ------------------------------------------------------------------------------------
    // delete all examinations for the specified service,
    // then add all selected examinations (those in request)
    if(sAction.equals("save")){
    	MedwanQuery.getInstance().setServiceexaminations(new Hashtable());
    	MedwanQuery.getInstance().setServiceexaminationsincludingparent(new Hashtable());
    	ServiceExamination.deleteAllExaminationsForService(sFindServiceCode);

        String examId;
		Enumeration params = request.getParameterNames();
		while(params.hasMoreElements()){
			String param = (String)params.nextElement();
			
			if(param.startsWith("cb_")){
				examId = param.substring("cb_".length());
		        examId = examId.substring(examId.indexOf("_")+1);
				
				ServiceExamination serviceExamination = new ServiceExamination();
				serviceExamination.setExaminationid(examId);
				serviceExamination.setServiceid(sFindServiceCode);
				serviceExamination.saveToDB();
			}
		}

		sMsg = getTran(request,"web","dataSaved",sWebLanguage);
		sAction = "edit";
    }
%>

<form id="transactionForm" name="transactionForm" method="post" action="<%=sCONTEXTPATH%>/main.jsp?Page=system/manageServiceExaminations.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="Action" id="Action" value="">
    
    <%=writeTableHeader("Web.manage","ManageServiceExaminations",sWebLanguage," doBack();")%>
    
    <%-- SEARCH SERVICE --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr height="22">
            <td class="admin2" width="160">&nbsp;<%=getTran(request,"web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="FindServiceText" READONLY size="<%=sTextWidth%>" title="<%=sFindServiceText%>" value="<%=sFindServiceText%>">                
                <img src='<%=sCONTEXTPATH%>/_img/icons/icon_search.png' id='buttonService' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>'
                 onclick="hideServicesTable();openPopup('_common/search/searchService.jsp&VarCode=FindServiceCode&VarText=FindServiceText&onlySelectContractWithDivision=false');">
                 &nbsp;<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick="clearServiceSelection();">
              
                <input type="hidden" name="FindServiceCode" value="<%=sFindServiceCode%>">&nbsp;

                <%-- BUTTONS --%>
                <input type="button" class="button" name="editButton" value="<%=getTranNoLink("Web","Edit",sWebLanguage)%>" onclick="doAction('edit');">
            </td>
        </tr>
    </table>
    
    <div id="msgDiv" style="height:20px"><%=sMsg%></div>
    
    <%
        if(sAction.equals("edit") && sFindServiceCode.length() > 0){
            %>
			<table width="100%" id="servicesTable" class="list" cellpadding="0" cellspacing="1">
			    <%
		        	Vector examinations = ServiceExamination.selectServiceExaminations(sFindServiceCode);
		        	Hashtable hExaminations = new Hashtable();
		        	ServiceExamination examination;
		        	for(int n=0; n<examinations.size(); n++){
		        		examination = (ServiceExamination)examinations.elementAt(n);
		        		hExaminations.put(examination.getExaminationid(),"1");
		        	}
		        	
		        	// Load available examinations and put them in a sorted map
		        	SortedMap exams = new TreeMap();
		    		SAXReader xmlReader = new SAXReader();
			        String sMenuXML = MedwanQuery.getInstance().getConfigString("examinationsXMLFile","examinations.xml");
			        String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
			        Debug.println("Reading '"+sMenuXMLUrl+"'");
			        Document document = xmlReader.read(new URL(sMenuXMLUrl));
			        if(document!=null){
			            Element root = document.getRootElement();
			            if(root!=null){
			                Iterator elements = root.elementIterator("Row");
			                while(elements.hasNext()){
			                    Element e = (Element) elements.next();
			                    if(e!=null){
				                    String elementClass = "?";
				                    Element eClass = e.element("class");
				                    if(eClass!=null){
				                    	elementClass = eClass.getText();
				                    }
				                    if(exams.get(elementClass)==null){
				                    	exams.put(elementClass,new TreeMap());
				                    }
				                    
				                    SortedMap serviceExams = (TreeMap)exams.get(elementClass);
				                    serviceExams.put(e.element("id").getText(),e.element("id").getText()+";"+e.element("transactiontype").getText());
			                    }
			                }
			            }
			        }
			        //If customexaminations exist, also add them to the list
			        sMenuXML = MedwanQuery.getInstance().getConfigString("customExaminationsXMLFile","customexaminations.xml");
			        sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
			        Debug.println("Reading '"+sMenuXMLUrl+"'");
			        try{
				        document = xmlReader.read(new URL(sMenuXMLUrl));
				        if(document!=null){
				            Element root = document.getRootElement();
				            if(root!=null){
				                Iterator elements = root.elementIterator("Row");
				                while(elements.hasNext()){
				                    Element e = (Element) elements.next();
				                    if(e!=null){
					                    String elementClass = "?";
					                    Element eClass = e.element("class");
					                    if(eClass!=null){
					                    	elementClass = eClass.getText();
					                    }
					                    if(exams.get(elementClass)==null){
					                    	exams.put(elementClass,new TreeMap());
					                    }
					                    
					                    SortedMap serviceExams = (TreeMap)exams.get(elementClass);
					                    serviceExams.put(e.element("id").getText(),e.element("id").getText()+";"+e.element("transactiontype").getText());
				                    }
				                }
				            }
				        }
			        }
			        catch(Exception e){}
			        // display examinations per service
					Iterator examIter = exams.keySet().iterator();
			        String sServiceId, sServiceName;
			        while(examIter.hasNext()){
			        	sServiceId = (String)examIter.next();
			        	sServiceName = getTran(request,"web",sServiceId,sWebLanguage);
			           
			        	// header
			        	%>
			        	    <tr class="admin">
			        	        <td colspan="5"><b><%=sServiceName%></b>&nbsp;
			        	            <a href="javascript:void(0);" onclick="checkAll(true,'<%=sServiceId%>');"><%=getTran(request,"web.manage.checkDb","checkAll",sWebLanguage)%></a>
		                            <a href="javascript:void(0);" onclick="checkAll(false,'<%=sServiceId%>');"><%=getTran(request,"web.manage.checkDb","uncheckAll",sWebLanguage)%></a>
		                        </td>
		                    </tr>
		                <%
		                
			        	SortedMap serviceExams = (TreeMap)exams.get(sServiceId);
			        	Iterator examsIter = serviceExams.keySet().iterator();
			        	
						int examCounter = 0;	
						String sExamId, sExamName;
			        	while(examsIter.hasNext()){
			        		if(examCounter%5==0){
			        			out.print("<tr valign='top'>");
			        		}
			        		
			        		sExamId = (String)examsIter.next();
			        		sExamName = getTran(request,"examination",sExamId,sWebLanguage)+" ("+sExamId+")";
			        		
							String screen = MedwanQuery.getInstance().getForward(((String)serviceExams.get(sExamId)).split(";")[1]);
			        		out.print("<td class='admin'>"+
							           "<table width='100%'><tr valign='top'><td width='1px'><img height='16px' src='"+sCONTEXTPATH+"/_img/icons/icon_eye2.png' onclick='preview(\""+sExamId+"\")' title='"+getTranNoLink("web","preview",sWebLanguage)+"'/></td><td width='1px'><input type='checkbox' name='cb_"+sServiceId+"_"+sExamId+"' id='cb_"+sServiceId+"_"+sExamId+"' "+(hExaminations.get(((String)serviceExams.get(sExamId)).split(";")[0])!=null?"checked":"")+"/></td><td><label label for='cb_"+sServiceId+"_"+sExamId+"'>"+sExamName+"</label></td></tr></table>"+
			        		          "</td>");
			        		examCounter++;
			        		
			        		if(examCounter%5 ==0){
			        			out.print("</tr>");
			        		}
			        	}
			        	
			        	if(examCounter%5!=0){
			        		// add empty cells
				        	while(examCounter%5!=0){
				        		out.print("<td class='admin2'/>");
				        		examCounter++;
				        	}
		        			out.print("</tr>");
			        	}
			        }
		    	%>
		    </table>    
		    
			<%-- UN/CHECK ALL --%>
			<a href="javascript:void(0);" onclick="checkAll(true,'all');"><%=getTran(request,"web.manage.checkDb","checkAll",sWebLanguage)%></a>
			<a href="javascript:void(0);" onclick="checkAll(false,'all');"><%=getTran(request,"web.manage.checkDb","uncheckAll",sWebLanguage)%></a>
					
			<%-- BUTTONS --%>
			<%=ScreenHelper.alignButtonsStart()%>
				<input type="button" class="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doAction('save');">&nbsp;
				<input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
			<%=ScreenHelper.alignButtonsStop()%>
        <%
        }
        else{
        	%>
				<%-- BACK BUTTON --%>
				<%=ScreenHelper.alignButtonsStart()%>
					<input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
				<%=ScreenHelper.alignButtonsStop()%>
        	<%
        }
    %>
</form>

<script>
  <%-- CHECK ALL --%> 
  function checkAll(setChecked,sServiceId){
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
    	if(sServiceId=="all"){
          transactionForm.elements[i].checked = setChecked;
    	}  
    	else if(transactionForm.elements[i].id.startsWith("cb_"+sServiceId)){
          transactionForm.elements[i].checked = setChecked;
        }
      }
    }
  }

  <%-- SHOW SCREEN --%>
  function showScreen(transactionType){
    openPopup(transactionType);
  }

  <%-- DO ACTION --%>
  function doAction(sAction){
    transactionForm.Action.value = sAction;
    transactionForm.submit();
  }
  
  <%-- HIDE SERVICES TABLE --%>
  function hideServicesTable(){
    if(document.getElementById("servicesTable")){
      document.getElementById("servicesTable").style.display = "none";
    }
    document.getElementById("msgDiv").innerHTML = "";
  }
  
  <%-- CLEAR SERVICE SELECTION --%>
  function clearServiceSelection(){
    document.getElementsByName("FindServiceCode")[0].value = "";
    document.getElementsByName("FindServiceText")[0].value = "";
    
    if(document.getElementById("servicesTable")){
      document.getElementById("servicesTable").style.display = "none";
    }
    document.getElementById("msgDiv").innerHTML = "";
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }
  
  function preview(examid){
	  openPopup("/system/previewExam.jsp&examid="+examid+"&PopupWidth=1024&PopupHeight=768");
  }
</script>