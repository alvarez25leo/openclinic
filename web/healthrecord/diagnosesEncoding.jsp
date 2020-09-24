<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                java.text.DecimalFormat,
                be.openclinic.medical.Diagnosis,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                be.openclinic.finance.*,
                java.util.*"%>
<%@page import="be.openclinic.medical.PaperPrescription"%>
<%@page import="be.openclinic.medical.ReasonForEncounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String activeEncounterUid = "", sRfe = "";
	SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
    
    ItemVO oldItemVO = curTran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
    if(oldItemVO!=null && oldItemVO.getValue().length()>0){
    	activeEncounterUid = oldItemVO.getValue();
    }
    else{
        Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(curTran.getUpdateTime().getTime()),activePatient.personid);
        if(activeEnc!=null){
        	activeEncounterUid = activeEnc.getUid();
        }
    }
    
    if(activeEncounterUid.length()>0){
        sRfe = ReasonForEncounter.getReasonsForEncounterAsHtml(activeEncounterUid,sWebLanguage,sCONTEXTPATH+"/_img/icons/icon_delete.png","deleteRFE($serverid,$objectid)");
		
		%>
			<table class="list" width="100%" cellspacing="0" cellpadding="2">
		      <tr class="admin">
			    <td align="center">
			    	<a href="javascript:openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=activeEncounterUid%>&ts=<%=getTs()%>',700,400);void(0);"><%=getTran(request,"openclinic.chuk","rfe",sWebLanguage)%> <%=getTran(request,"Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></a>
			    </td>
			  </tr>
			  <tr>
			    <td id="rfe"><%=sRfe%></td>
			  </tr>
			</table>
            <div style="padding-top:3px;"></div>
            <%if(activeEncounterUid.length()>0){ %>
				<table class="list" width="100%" cellspacing="0" cellpadding="2">
			      <tr class="admin">
				    <td align="center"><%=getTran(request,"web","ikirezi",sWebLanguage)%>
		            	<a href="javascript:doPanorama('<%=activeEncounterUid%>');"><img src="<c:url value='/_img/icons/icon_panorama.gif'/>" class="link" title="<%=getTranNoLink("ikirezi","panorama",sWebLanguage)%>" style="vertical-align:-4px;"></a>
				    </td>
				  </tr>
				  <tr id='ikirezi'>
				  </tr>
				</table>
			<%} %>
            <div style="padding-top:3px;"></div>
		<%
    }
    if(MedwanQuery.getInstance().getConfigString("showRecentEchographies","").length()>0){
    	String sEchographies="";
    	int days = MedwanQuery.getInstance().getConfigInt("showRecentEchographiesPeriodInDays",270);
    	long period=days*24;
    	period = period*3600*1000;
    	String sDateBegin=ScreenHelper.getSQLDate(new java.util.Date(new java.util.Date().getTime()-period));
    	Vector debets = Debet.getPatientDebetPrestations(MedwanQuery.getInstance().getConfigString("showRecentEchographies",""),activePatient.personid, sDateBegin, "", "", "");
		if(debets.size()>0){
	    	for(int n=0;n<debets.size();n++){
	    		sEchographies+=((String)debets.elementAt(n)).split(";")[0]+", ";
	    	}
			%>
				<table class="list" width="100%" cellspacing="1">
			      <tr class="admin">
				    <td align="center"><%=getTran(request,"openclinic.chuk","echographies.in.last",sWebLanguage)+" "+MedwanQuery.getInstance().getConfigInt("showRecentEchographiesPeriodInDays",270)+" "+getTran(request,"web","days",sWebLanguage)%></td>
				  </tr>
				  <tr>
				    <td id="echographies"><%=sEchographies%></td>
				  </tr>
				</table>
	            <div style="padding-top:3px;"></div>
			<%
		}			
    }
    
%>

<table class="list" width="100%" cellspacing="0" cellpadding="2">
  <tr class="admin">
    <td align="center"><a href="javascript:openPopup('healthrecord/findICPC.jsp&EncounterUid='+document.getElementById('encounteruid').value+'&AuthorUID='+(document.getElementById('diagnosisUser')?document.getElementById('diagnosisUser').value:'')+'&PopupWidth=700&PopupHeight=400&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>');void(0);"><%=getTran(request,"openclinic.chuk","diagnostic.document",sWebLanguage)%> <%=getTran(request,"Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></a></td>
  </tr>
  <tr>
    <td id='icpccodes'>
	  <table width='100%' id="icpccodesTable" cellspacing="0" cellpadding="2">
	    <%
		    Iterator items = curTran.getItems().iterator();
		    ItemVO item;
			
		    String sReferenceUID = curTran.getServerId()+"."+curTran.getTransactionId();
		    String sReferenceType = "Transaction";
		    Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID,sReferenceType);
		    Hashtable hDiagnosisInfo;
		    String sCode, sGravity, sCertainty, POA, NC, serviceUid, flags, userid, userwarning="", flagsuffix="";
	        String sClass = "1";
	        
		     while(items.hasNext()){
                 item = (ItemVO)items.next();
	            
                 if(item.getType().indexOf("ICPCCode")==0){
	                 sCode = item.getType().substring("ICPCCode".length(), item.getType().length());
			        
	                 hDiagnosisInfo = (Hashtable) hDiagnoses.get(sCode);
			         if(hDiagnosisInfo!=null){
			             sGravity = (String)hDiagnosisInfo.get("Gravity");
			             sCertainty = (String)hDiagnosisInfo.get("Certainty");
			             POA = (String) hDiagnosisInfo.get("POA");
			             NC = (String) hDiagnosisInfo.get("NC");
			             serviceUid = (String)hDiagnosisInfo.get("ServiceUid");
			             flags = (String)hDiagnosisInfo.get("Flags");
			             if(flags.indexOf("T")>-1){
			            	 flagsuffix=" <span style='background-color:black;color:white'><b>&nbsp;"+getTranNoLink("web","chronic",sWebLanguage)+"&nbsp;</b></span>";
			             }
			             else{
			            	 flagsuffix="";
			             }
			             userid = (String)hDiagnosisInfo.get("User");
	                     if(!userid.equalsIgnoreCase(activeUser.userid)){
	                    	 userwarning=" <img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' title='"+getTran(null,"web","author",sWebLanguage)+": "+User.getFullUserName(userid)+"'/>("+User.getFullUserName(userid)+")";
	                     }
			          }
			          else{
	                      sGravity = "";
	                      sCertainty = "";
	                      POA = "";
	                      NC = "";
	                      serviceUid = "";
	                      flags = "";
	                      userid="";
	                      flagsuffix="";
			          }
		                
		              // alternate row-style
		              if(sClass.length()==0) sClass = "1";
		              else                   sClass = "";
			         
			     	  %>
			     	  <tr id="ICPCCode<%=item.getItemId()%>" class="list<%=sClass%>">
			     		<td width="1%" nowrap><img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.png" class="link" onclick="deleteDiagnosis(ICPCCode<%=item.getItemId()%>);"/></td>
			            <td width="1%">ICPC</td>
			            <td width="1%"><b><%=item.getType().replaceAll("ICPCCode","")%></b></td>
			            <td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <font color='red'><i><%=item.getValue().trim()%></i></font>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+flagsuffix+")"%><%=userwarning %></i></b>
			              <input type='hidden' name='ICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=item.getValue().trim()%>"/>
			              <input type='hidden' name='GravityICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sGravity%>"/>
			              <input type='hidden' name='CertaintyICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sCertainty%>"/>
			              <input type='hidden' name='POAICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=POA%>"/>
			              <input type='hidden' name='NCICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=NC%>"/>
			              <input type='hidden' name='ServiceICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=serviceUid%>"/>
			              <input type='hidden' name='FlagsICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=flags%>"/>
			              <input type='hidden' name='UserICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=userid%>"/>
			            </td>
			          </tr>
			          <%
			      }
			      else if (item.getType().indexOf("ICD10Code")==0){
			          sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
			        
			          hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
			          if(hDiagnosisInfo!=null){
			              sGravity = (String)hDiagnosisInfo.get("Gravity");
			              sCertainty = (String)hDiagnosisInfo.get("Certainty");
			              POA = (String) hDiagnosisInfo.get("POA");
			              NC = (String) hDiagnosisInfo.get("NC");
			              serviceUid = (String)hDiagnosisInfo.get("ServiceUid");
			              flags = (String)hDiagnosisInfo.get("Flags");
				             if(flags.indexOf("T")>-1){
				            	 flagsuffix=" <span style='background-color:black;color:white'><b>&nbsp;"+getTranNoLink("web","chronic",sWebLanguage)+"&nbsp;</b></span>";
				             }
				             else{
				            	 flagsuffix="";
				             }
   			              userid = (String)hDiagnosisInfo.get("User");
	                     if(!userid.equalsIgnoreCase(activeUser.userid)){
	                    	 userwarning=" <img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' title='"+getTran(null,"web","author",sWebLanguage)+": "+User.getFullUserName(userid)+"'/>("+User.getFullUserName(userid)+")";
	                     }
			          } 
			          else{
			              sGravity = "";
			              sCertainty = "";
			              POA = "";
			              NC = "";
			              serviceUid = "";
			              flags = "";
			              flagsuffix="";
			              userid="";
			          }
		                
		              // alternate row-style
		              if(sClass.length()==0) sClass = "1";
		              else                   sClass = "";
			                 
			          %>
			          <tr id='ICD10Code<%=item.getItemId()%>' class="list<%=sClass%>">
			            <td width="1%" nowrap><img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.png" class="link" onclick="deleteDiagnosis(ICD10Code<%=item.getItemId()%>);"/></td>
		                <td width="1%">ICD10</td>
		                <td width="1%"><b><%=item.getType().replaceAll("ICD10Code","")%></b></td>
		                <td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <font color='red'><i><%=item.getValue().trim()%></i></font>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+flagsuffix+")"%><%=userwarning %></i></b>
			              <input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/>
			              <input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/>
			              <input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/>
			              <input type='hidden' name='POAICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=POA%>"/>
			              <input type='hidden' name='NCICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=NC%>"/>
			              <input type='hidden' name='ServiceICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=serviceUid%>"/>
			              <input type='hidden' name='FlagsICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=flags%>"/>			                   
			              <input type='hidden' name='UserICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=userid%>"/>			                   
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
<div style="padding-top:3px;"></div>

<table class="list" width="100%" cellspacing="0" cellpadding="2">
  <tr class="admin">
    <td align="center"><%=getTran(request,"openclinic.chuk","contact.diagnoses",sWebLanguage)%> <%=getTran(request,"Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></td>
  </tr>
  <tr>
    <td>
      
	  <table width='100%'>
	    <%
		    if(activeEncounterUid.length() > 0){
		        items = curTran.getItems().iterator();
			
		        sReferenceUID = curTran.getServerId()+"."+curTran.getTransactionId();
		        Vector d = Diagnosis.selectDiagnoses("","",activeEncounterUid,"","","","","","","","","","");
		      
		        sClass = "1";
		        Diagnosis diag;
		        for(int n=0; n<d.size(); n++){
		            diag = (Diagnosis)d.elementAt(n);
		      	 
	                sGravity = diag.getGravity()+"";
	                sCertainty = diag.getCertainty()+"";
	                POA = diag.getPOA();
	                NC = diag.getNC();
	                flags = diag.getFlags();
		             if(flags.indexOf("T")>-1){
		            	 flagsuffix=" <span style='background-color:black;color:white'><b>&nbsp;"+getTranNoLink("web","chronic",sWebLanguage)+"&nbsp;</b></span>";
		             }
		             else{
		            	 flagsuffix="";
		             }
	                
	                // alternate row-style
	                if(sClass.length()==0) sClass = "1";
	                else                   sClass = "";
	                    
			        if(diag.getCodeType().equalsIgnoreCase("icpc")){
		  			    %><tr class="list<%=sClass%>"><td width="1%">ICPC</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("icpccode"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+flagsuffix+")" %></i></b></td></tr><%
		            }
		            else if (diag.getCodeType().equalsIgnoreCase("icd10")){
		    		    %><tr class="list<%=sClass%>"><td width="1%">ICD10</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("icd10code"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+flagsuffix+")" %></i></b></td></tr><%
		            }
		        }
		    }
	    %>
	  </table>
	</td>
  </tr>
</table>
<%
	if(MedwanQuery.getInstance().getConfigInt("enableSNOMED",0)==1){
%>
<div style="padding-top:3px;"></div>
<table class="list" width="100%" cellspacing="0" cellpadding="2">
    <tr class="admin">
        <td align="center">SNOMED-CT</td>
    </tr>
    <tr>
        <td id='snomedcodes'></td>
    </tr>
</table>

<script>
  function readClipboard(){
	if(window.clipboardData){
	    var txt = window.clipboardData.getData("Text");
	    if(txt.length > 0){
	      if(window.DOMParser){
	        parser = new DOMParser();
	        xmlDoc = parser.parseFromString(txt,"text/xml");
	      }
	      else{
	        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
	        xmlDoc.async = "false";
	        xmlDoc.loadXML(txt);
	        
	        var concepts = xmlDoc.getElementsByTagName("concept");
	        if(concepts.length > 0){
	          var conceptId = concepts[0].getAttribute("id");
	          var snomedId = concepts[0].getAttribute("snomedId");
	          var ctv3id = concepts[0].getAttribute("ctv3id");
	  
	          var fullySpecifiedName = concepts[0].getAttribute("fullySpecifiedName");	
	          document.getElementById("snomedcodes").innerHTML+= "<span id='SNOMEDITEM."+conceptId+"'>"+
	                                                              "<input type='hidden' name='SNOMEDCONCEPT."+conceptId+"."+snomedId+"."+ctv3id+"' value='"+fullySpecifiedName+"'/>"+
	                                                              conceptId+" <b>"+fullySpecifiedName+"</b><br/>"+
	                                                             "</span>";
	          window.clipboardData.setData("Text","");
	        }  
	      }
	    }
	}
  }

  window.setInterval("readClipboard();",1000);
</script>
<%
	}
%>
<script>
  <%-- DELETE DIAGNOSIS --%>
  function deleteDiagnosis(itemid){
      if(yesnoDeleteDialog()){
      var index = itemid.parentNode.parentNode.rowIndex;
      document.getElementById("icpccodesTable").deleteRow(index);
    }  
  }
  
  function loadIkirezi(){
      var params = 'encounteruid=<%=activeEncounterUid%>';
	  var url= '<c:url value="/healthrecord/ajax/loadIkirezi.jsp"/>?ts='+new Date();
      new Ajax.Request(url,{
        method: "POST",
        parameters: params,
        onSuccess: function(resp){
          document.getElementById('ikirezi').innerHTML=resp.responseText;
        }
      });
  }

  function deleteRFE(serverid,objectid){
      if(yesnoDeleteDialog()){

      var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=activeEncounterUid%>&language=<%=sWebLanguage%>";
      var url= '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+new Date();
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          rfe.innerHTML=resp.responseText;
        }
      });
    }
  }
  window.setTimeout("loadIkirezi();",500);
</script>