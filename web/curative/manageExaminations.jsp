<%@page import="be.mxs.common.model.vo.healthrecord.HealthRecordVO"%>
<%@page import="be.dpms.medwan.common.model.vo.occupationalmedicine.VerifiedExaminationVO,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"examinations","select",activeUser)%>

<%!
    //--- WRITE EXAMINATION -----------------------------------------------------------------------
    private String writeExamination(User activeUser, int counter, String sTranTitle, String sTranDate,
    		                        String sTranType, String sTranId, String sTranServerId,
    		                        String sWebLanguage, String sCONTEXTPATH){	    
		// alternate row-style
	    String sClass = "1";
		if(counter%2==0) sClass = "1";
		else             sClass = "";
		
        return "<tr class='list"+sClass+"'>"+
		        "<td>"+
		         "<img src='"+sCONTEXTPATH+"/_img/themes/default/pijl.gif'>"+
		         "<button accesskey='"+counter+"' class='buttoninvisible' onclick=\"window.location.href='"+sCONTEXTPATH+"/healthrecord/createTransaction.do?be.mxs.healthrecord.createTransaction.transactionType="+sTranType+"&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&ts="+getTs()+"'\"></button>"+
		         "<u>"+(counter)+"</u> "+sTranTitle+
		        "</td>"+
		        "<td align='center'>"+
		         "<a onmouseover=\"window.status='';return true;\" href=\""+sCONTEXTPATH+"/healthrecord/createTransaction.do?be.mxs.healthrecord.createTransaction.transactionType="+sTranType+"&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&ts="+getTs()+"\">"+
		          getTran(null,"Web.Occup","medwan.common.new",sWebLanguage)+
		         "</a>"+
		        "</td>"+
		        "<td align='center'>"+
		         "<a onmouseover=\"window.status='';return true;\" href=\""+sCONTEXTPATH+"/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType="+sTranType+"&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&be.mxs.healthrecord.transaction_id="+sTranId+"&be.mxs.healthrecord.server_id="+sTranServerId+"&ts="+getTs()+"\">"+
		          sTranDate+
		         "</a>"+
		        "</td>"+
		        "<td/><td/>"+
		       "</tr>";
    }
%>

<table width="100%" cellspacing="0" cellpadding="2" class="menu" id="mainTable">
<%
    //--- 1 - DOCUMENTS ---------------------------------------------------------------------------
	if(activeUser.getAccessRight("occup.externaldocuments")){
	    %>
		    <tr class="admin">
		        <td colspan="5">&nbsp;<%=getTran(request,"web","documents",sWebLanguage)%></td>
		    </tr>
		    <tr>
		        <td colspan="5">
		            <img src="<c:url value="/_img/themes/default/pijl.gif"/>">&nbsp;<a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_EXTERNAL_DOCUMENT&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&ts=<%=getTs()%>"><%=getTran(request,"Web","add.new.document",sWebLanguage)%></a>
		        </td>
		    </tr>
	    <%
	}

    //--- 2 - GLOBAL EXAMINATIONS -----------------------------------------------------------------
    SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    sessionContainerWO.init(activePatient.personid);
    Vector userServiceExams = ScreenHelper.getExaminationsForServiceIncludingParents(activeUser.activeService.code,activeUser.person.language);
   	userServiceExams = sessionContainerWO.getHealthRecordVO().getVerifiedExaminations(sessionContainerWO,userServiceExams);

    VerifiedExaminationVO verifiedExaminationVO;
    SortedMap exams = new TreeMap();
    int counter = 0;
    String examName;
    for(int n=0; n<userServiceExams.size(); n++){
        verifiedExaminationVO = (VerifiedExaminationVO) userServiceExams.get(n);
        examName = getTran(request,"examination",verifiedExaminationVO.examinationId+"",sWebLanguage);
        exams.put(examName,verifiedExaminationVO);
    }

    // header
    if(activeUser.getAccessRight("examinations.global.select")){
	    %>
	    <tr class="admin">
	        <td width="400">&nbsp;<%=getTran(request,"web","globalexaminations",sWebLanguage)%></td>
	        <td width="100"/>
	        <td align="center" width="100"><%=getTran(request,"web","lastexamination",sWebLanguage)%></td>
	        <td align="center" width="100"><%=getTran(request,"web","planned",sWebLanguage)%></td>
	        <td/>
	    </tr>
	    <%


		//*** SURVEILLANCE ***
	    String sTTNursing = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_SURVEILLANCE_PROTOCOL";
	    String sTranNursing = getTran(request,"web.occup",sTTNursing,sWebLanguage);
	    TransactionVO tranNursing = sessionContainerWO.getLastTransaction(sTTNursing);
	   
	    String sNursingTranId = "";
	    String sNursingServerId = "";
	    String sNursingDate = "";
	
	    if(tranNursing!=null){
	        sNursingTranId = tranNursing.getTransactionId().intValue()+"";
	        sNursingServerId = tranNursing.getServerId()+"";
	        sNursingDate = ScreenHelper.stdDateFormat.format(tranNursing.getUpdateTime());
	    }
	
		//*** LABO ***
	    String sTTLabo = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST";
	    String sTranLabo = getTran(request,"web.occup",sTTLabo,sWebLanguage);
	    TransactionVO tranLabo = sessionContainerWO.getLastTransaction(sTTLabo);

	    String sLaboTranId = "";
	    String sLaboServerId = "";
	    String sLaboDate = "";
	
	    if(tranLabo!=null){
	        sLaboTranId = tranLabo.getTransactionId().intValue()+"";
	        sLaboServerId = tranLabo.getServerId()+"";
	        sLaboDate = ScreenHelper.stdDateFormat.format(tranLabo.getUpdateTime());
	    }
	
		//*** ANATOMOPATHOLOGY ***
	    String sTTAna = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ANATOMOPATHOLOGY";
	    String sTranAna = getTran(request,"web.occup",sTTAna,sWebLanguage);
	    TransactionVO tranAna = sessionContainerWO.getLastTransaction(sTTAna);
	
	    String sAnaTranId = "";
	    String sAnaServerId = "";
	    String sAnaDate = "";

	    if(tranAna!=null){
	        sAnaTranId = tranAna.getTransactionId().intValue()+"";
	        sAnaServerId = tranAna.getServerId()+"";
	        sAnaDate = ScreenHelper.stdDateFormat.format(tranAna.getUpdateTime());
	    }
	
		//*** ARCHIVE ***
	    String sTTArc = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ARCHIVE_DOCUMENT";
	    String sTranArc = getTran(request,"web.occup",sTTArc,sWebLanguage);
	    TransactionVO tranArc = sessionContainerWO.getLastTransaction(sTTArc);
	
	    String sArcTranId = "";
	    String sArcServerId = "";
	    String sArcDate = "";

	    if(tranArc!=null){
	        sArcTranId = tranArc.getTransactionId().intValue()+"";
	        sArcServerId = tranArc.getServerId()+"";
	        sArcDate = ScreenHelper.stdDateFormat.format(tranArc.getUpdateTime());
	    }
	
		//*** MIR2 ***
	    String sTTMir = MedwanQuery.getInstance().getConfigString("defaultMedicalImagingRequestTransactionType","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2");
	    String sTranMir = getTran(request,"web.occup",sTTMir,sWebLanguage);
	    TransactionVO tranMir = sessionContainerWO.getLastTransaction(sTTMir);
	  
	    String sMirTranId = "";
	    String sMirServerId = "";
	    String sMirDate = "";
	
	    if(tranMir!=null){
	        sMirTranId = tranMir.getTransactionId().intValue()+"";
	        sMirServerId = tranMir.getServerId()+"";
	        sMirDate = ScreenHelper.stdDateFormat.format(tranMir.getUpdateTime());
	    }
	    
	    //*** REFERENCE ***
	    String sTTReference ="be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_REFERENCE";
	    String sTranReference = getTran(request,"web.occup",sTTReference,sWebLanguage);
	    TransactionVO tranReference = sessionContainerWO.getLastTransaction(sTTReference);
	
	    String sReferenceTranId = "";
	    String sReferenceServerId = "";
	    String sReferenceDate = "";

	    if(tranReference!=null){
	        sReferenceTranId = tranReference.getTransactionId().intValue()+"";
	        sReferenceServerId = tranReference.getServerId()+"";
	        sReferenceDate = ScreenHelper.stdDateFormat.format(tranReference.getUpdateTime());
	    }
	
	    //*** CARE ****************************************
	    if(activeUser.getAccessRight("occup.surveillance.select")) out.print(writeExamination(activeUser,counter++,sTranNursing,sNursingDate,sTTNursing,sNursingTranId,sNursingServerId,sWebLanguage,sCONTEXTPATH));
	    if(activeUser.getAccessRight("occup.labrequest.select")) out.print(writeExamination(activeUser,counter++,sTranLabo,sLaboDate,sTTLabo,sLaboTranId,sLaboServerId,sWebLanguage,sCONTEXTPATH));
	    if(activeUser.getAccessRight("occup.medicalimagingrequest.select")) out.print(writeExamination(activeUser,counter++,sTranMir,sMirDate,sTTMir,sMirTranId,sMirServerId,sWebLanguage,sCONTEXTPATH));
	    if(activeUser.getAccessRight("occup.anatomopathology.select")) out.print(writeExamination(activeUser,counter++,sTranAna,sAnaDate,sTTAna,sAnaTranId,sAnaServerId,sWebLanguage,sCONTEXTPATH));
	    if(activeUser.getAccessRight("occup.reference.select")) out.print(writeExamination(activeUser,counter++,sTranReference,sReferenceDate,sTTReference,sReferenceTranId,sReferenceServerId,sWebLanguage,sCONTEXTPATH));
	    if(activeUser.getAccessRight("occup.arch.documents.select")) out.print(writeExamination(activeUser,counter++,sTranArc,sArcDate,sTTArc,sArcTranId,sArcServerId,sWebLanguage,sCONTEXTPATH));
	 
	    if(activeUser.getAccessRight("prescriptions.care.select")){
			// alternate row-style
	 		String sClass = "1";
	 		if(counter%2==0) sClass = "1";
	 		else             sClass = "";
	
	 		%>
			    <tr class="list<%=sClass%>">
			        <td>
			            <img src="<c:url value="/_img/themes/default/pijl.gif"/>"><button accesskey="<%=counter%>" class="buttoninvisible" onclick="javascript:openPopup('medical/manageCarePrescriptionsPopup.jsp',700,400);"></button><u><%=counter++%></u> <a href="javascript:openPopup('medical/manageCarePrescriptionsPopup.jsp',700,400);void(0);"><%=getTran(request,"web","careprescriptions",sWebLanguage)%></a>
			        </td>
			        <td/><td/><td/><td/>
			    </tr>
	        <%
	    }

	    //*** DRUGS ***************************************
	    if(activeUser.getAccessRight("prescriptions.drugs.select")){
	        // alternate row-style
	        String sClass = "1"; 
	        if(counter%2==0) sClass = "1";
	        else             sClass = "";
	        
		    %>
			    <tr class="list<%=sClass%>">
			        <td>
			            <img src="<c:url value="/_img/themes/default/pijl.gif"/>"><button accesskey="<%=counter%>" class="buttoninvisible" onclick="javascript:openPopup('medical/managePrescriptionsPopup.jsp',700,400);"></button><u><%=counter++%></u> <a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp',700,400);void(0);"><%=getTran(request,"web","medications",sWebLanguage)%></a>
			        </td>
			        <td/><td/><td/><td/>
			    </tr>
		    <%
        }

    }

    //--- 3 - SPECIFIC EXAMINATIONS ---------------------------------------------------------------
    Vector examNames = new Vector(exams.keySet());
    if(activeUser.getAccessRight("examinations.specific.select")){

    	String sServiceSuffix = "";
    	if(activeUser.activeService.code.length() > 0){
    		sServiceSuffix = " ("+getTran(request,"Service",activeUser.activeService.code,sWebLanguage)+")";
    	}
    	
	    %>
	    <%-- TITLE --%>
	    <tr class="admin">
	        <td colspan="5">&nbsp;<%=getTran(request,"web","specificExaminations",sWebLanguage)%><%=sServiceSuffix%></td>
	    </tr>
	    
	    <%
	        String sClass = "1";
	        Collections.sort(examNames);

	        for(int n=0; n<examNames.size(); n++){
	            examName = (String)examNames.get(n);
	            verifiedExaminationVO = (VerifiedExaminationVO)exams.get(examName);
	            
	            if(MedwanQuery.getInstance().getConfigString("noShowExaminationsGender"+activePatient.gender,"").indexOf(verifiedExaminationVO.getTransactionType()+";")<0){
	            	// alternate row-style
	            	if(sClass.length()==0) sClass = "1";
	            	else                   sClass = "";
	            	
		            %>
		            <tr class="<%=(verifiedExaminationVO.getPlannedExaminationDue().equalsIgnoreCase("medwan.common.true")?"menuItemRed":"list"+sClass)%>">
		                <%-- examination name --%>
		                <td><img src="<c:url value="/_img/themes/default/pijl.gif"/>"><button class='buttoninvisible'></button>  <%=ScreenHelper.uppercaseFirstLetter(examName)%></td>
		                <%-- create --%>
		                <td align="center">
		                    <%
		                        if(((verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY")) && (checkString(verifiedExaminationVO.getLastExamination()).length()==0))
		                        ||(!verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY"))
		                        &&(!verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_PEDIATRY_DELIVERY"))){
		                    %>
		                    <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&ts=<%=getTs()%>">
		                        <%=getTran(request,"Web.Occup","medwan.common.new",sWebLanguage)%>
		                    </a>
		                    <%
		                        }
		                    %>
		                </td>
		                <%-- edit (last examination date) --%>
		                <td align="center">
		                    <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&be.mxs.healthrecord.transaction_id=<%=verifiedExaminationVO.getLastExaminationId()%>&be.mxs.healthrecord.server_id=<%=verifiedExaminationVO.getLastExaminationServerId()%>&ts=<%=getTs()%>">
		                        <%=checkString(verifiedExaminationVO.getLastExamination())%>
		                    </a>
		                </td>
		                <%-- edit (planned examination date) --%>
		                <td align="center">
		                    <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>">
		                        <%=checkString(verifiedExaminationVO.getPlannedExaminationDueDateString())%>
		                    </a>
		                </td>
		                <td/>
		            </tr>
		            <%
	            }
	        }
	    %>
	    <%-- OTHER SERVICES AND THEIR EXAMINATIONS --------------------------------------------------%>
	    <tr id="otherServicesHeader" onClick="toggleOtherServices();" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" height="15">
	        <td colspan="5">
	            <img src="<c:url value="/_img/themes/default/pijl.gif"/>">&nbsp;<a href="#"><b><%=getTran(request,"Web.manage","examinationsofotherservices",sWebLanguage)%></b></a>
	        </td>
	    </tr>
	<%
    }

%>
        </td>
    </tr>
</table>
      
<div id="otherServicesTable" style="display:none;">
<table width="100%" cellspacing="1" cellpadding="1" class="menu" style="border-top:none;">
    <tr>
        <td style="padding-left:20px;">
            <table width="100%" cellspacing="1" cellpadding="1" class="menu">
    <%
        Hashtable otherServices = ScreenHelper.getServiceContexts();
        otherServices.remove(activeUser.activeService.code);

        // run thru other services, displaying their linked examinations
        String serviceId, defaultContext, sClass = "";
        String showExamsTran = getTran(request,"web.manage","showExaminations",sWebLanguage);
        Vector otherServiceExams;
		
        SortedMap otherServicesSorted = new TreeMap();
        Enumeration servicesEnum = otherServices.keys();
        while(servicesEnum.hasMoreElements()){
        	serviceId=(String)servicesEnum.nextElement();
        	otherServicesSorted.put(getTran(request,"service",serviceId,sWebLanguage).toUpperCase()+";"+serviceId,otherServices.get(serviceId));
        }        
        
        Iterator servicesIterator = otherServicesSorted.keySet().iterator();
        while(servicesIterator.hasNext()){
        	String s=(String)servicesIterator.next();
        	String serviceName=s.split(";")[0];
            serviceId = s.split(";")[1];
            defaultContext = (String)otherServices.get(serviceId);

            // get examinations linked to current service
            otherServiceExams = ScreenHelper.getExaminationsForService(serviceId,activeUser.person.language);

            if(otherServiceExams.size() > 0){
                sessionContainerWO.getHealthRecordVO().setUpdated(true);
                otherServiceExams = sessionContainerWO.getHealthRecordVO().getVerifiedExaminations(sessionContainerWO,otherServiceExams);

                // alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                Hashtable otherExams = new Hashtable();
                for(int n=0; n<otherServiceExams.size(); n++){
                    verifiedExaminationVO = (VerifiedExaminationVO)otherServiceExams.get(n);
                   
                    if(MedwanQuery.getInstance().getConfigString("noShowExaminationsGender"+activePatient.gender,"").indexOf(verifiedExaminationVO.getTransactionType()+";")<0){
	                    examName = getTran(request,"examination",verifiedExaminationVO.examinationId+"",sWebLanguage);
	                    otherExams.put(examName,verifiedExaminationVO);
                    }
                }

                examNames = new Vector(otherExams.keySet());
                Collections.sort(examNames);
                
                %>
                    <%-- SERVICE HEADER --%>
                    <tr class="list<%=sClass%>" id="otherServiceHeader_<%=serviceId%>" title="<%=showExamsTran%>" onclick="hideAllServiceExaminations('<%=serviceId%>');toggleServiceRow('<%=serviceId%>');" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                        <%-- plus-sign and servicename --%>
                        <td colspan="4">
                            <img id="img_<%=serviceId%>" src="<%=sCONTEXTPATH%>/_img/icons/icon_plus.png" class="link" style="vertical-align:-3px;"/>&nbsp;<%=serviceName%>
                            (<%=examNames.size()%> <%=getTran(request,"web.manage","examinations",sWebLanguage).toLowerCase()%>)
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4" style="padding-left:20px;">
                            <table width="100%" cellpadding="1" cellspacing="0" id="otherServiceExams_<%=serviceId%>" style="display:none;" class="menu">
                            <%
                                if(otherServiceExams.size() > 0){
                            %>
                                <%-- sub-header --%>
                                <tr class="admin">
                                    <td width="360"><%=getTran(request,"web","examination",sWebLanguage)%></td>
                                    <td width="100"/>
                                    <td align="center" width="100"><%=getTran(request,"web","lastexamination",sWebLanguage)%></td>
                                    <td align="center" width="100"><%=getTran(request,"web","planned",sWebLanguage)%></td>
                                    <td/>
                                </tr>
                                <%
                                    // sort other examinations
                                    String sInnerClass = "";
                                
                                    for(int n=0; n<examNames.size(); n++){
                                        examName = (String)examNames.get(n);
                                        verifiedExaminationVO = (VerifiedExaminationVO)otherExams.get(examName);   

                                        // alternate row-style
                                    	if(sInnerClass.length()==0) sInnerClass = "1";
                                    	else                        sInnerClass = "";
                                %>
                                <tr class="list<%=sInnerClass%>">
                                    <%-- examination name --%>
                                    <td><img src="<c:url value='/_img/themes/default/pijl.gif'/>"><button class="buttoninvisible"></button> <%=ScreenHelper.uppercaseFirstLetter(examName)%></td>
                                    <%-- create --%>
                                    <td align="center">
                                        <%
                                            if(verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY") && checkString(verifiedExaminationVO.getLastExamination()).length()>0){
                                                // empty
                                            }
                                            else if(verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DENTIST") && checkString(verifiedExaminationVO.getLastExamination()).length()>0){
                                            	// empty
                                            }
                                            else{
		                                        %>
		                                        <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=defaultContext%>&ts=<%=getTs()%>">
		                                            <%=getTran(request,"Web.Occup","medwan.common.new",sWebLanguage)%>
		                                        </a>
		                                        <%
                                            }
                                        %>
                                    </td>
                                    <%-- edit (last examination date) --%>
                                    <td align="center">
                                        <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&be.mxs.healthrecord.transaction_id=<%=verifiedExaminationVO.getLastExaminationId()%>&be.mxs.healthrecord.server_id=<%=verifiedExaminationVO.getLastExaminationServerId()%>&ts=<%=getTs()%>">
                                            <%=checkString(verifiedExaminationVO.getLastExamination())%>
                                        </a>
                                    </td>
                                    <%-- edit (planned examination date) --%>
                                    <td align="center">
                                        <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=defaultContext%>&be.mxs.healthrecord.transaction_id=<%=verifiedExaminationVO.getLastExaminationId()%>&be.mxs.healthrecord.server_id=<%=verifiedExaminationVO.getLastExaminationServerId()%>&ts=<%=getTs()%>">
                                            <%=checkString(verifiedExaminationVO.getPlannedExaminationDueDateString())%>
                                        </a>
                                    </td>
                                    <td/>
                                </tr>
                                <%
                                    }
                                }
                                else{
                                    %><tr><td colspan="5">&nbsp;<%=getTran(request,"web.manage","noLinkedExaminationsFound",sWebLanguage)%></td></tr><%
                                }
                                %>
                            </table>
                        </td>
                    </tr>
                <%
            }
        }
    %>
            </table>
        </td>
    </tr>
</table>
</div>
    
<script>
  <%-- HIDE ALL SERVICE EXAMINATIONS --%>
  function hideAllServiceExaminations(clickedService){
    var tables = document.getElementsByTagName("table");
    for(var i=0; i<tables.length; i++){
      if(tables[i].id.indexOf("otherServiceExams_") > -1){
        if(tables[i].id != ("otherServiceExams_"+clickedService)){
          tables[i].style.display = "none";
          document.getElementById("img_"+tables[i].id.split("_")[1]).src = "<%=sCONTEXTPATH%>/_img/icons/icon_plus.png";
        }
      }
    }
  }

  <%-- TOGGLE OTHER SERVICES --%>
  function toggleOtherServices(){
    var divObj = document.getElementById("otherServicesTable");

    if(divObj.style.display == "none"){
      divObj.style.display = "";
      document.getElementById("mainTable").style.borderBottom = "none";
    }
    else{
      divObj.style.display = "none";
      document.getElementById("mainTable").style.borderBottom = "";
    }
  }

  <%-- TOGGLE SERVICE ROW --%>
  <%
      String showTran = getTranNoLink("web.manage","showExaminations",sWebLanguage),
             hideTran = getTranNoLink("web.manage","hideExaminations",sWebLanguage);
  %>
  function toggleServiceRow(serviceIdx){
    var headerObj = document.getElementById("otherServiceHeader_"+serviceIdx);
    var divObj = document.getElementById("otherServiceExams_"+serviceIdx);
    var imgObj = document.getElementById("img_"+serviceIdx);

    if(divObj.style.display == "none"){
      divObj.style.display = "";
      headerObj.title = "<%=hideTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/icons/icon_minus.png";
    }
    else{
      divObj.style.display = "none";
      headerObj.title = "<%=showTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/icons/icon_plus.png";
    }
  }
</script>