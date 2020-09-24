<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                java.text.DecimalFormat,
                be.openclinic.medical.Diagnosis,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                java.util.*" %>
<%@ page import="be.openclinic.medical.PaperPrescription" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String activeEncounterUid="",sRfe="";
	SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
    TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
    ItemVO oldItemVO = curTran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
    if (oldItemVO != null && oldItemVO.getValue().length()>0) {
    	activeEncounterUid = oldItemVO.getValue();
    }
    else {
        Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(curTran.getUpdateTime().getTime()),activePatient.personid);
        if(activeEnc!=null){
        	activeEncounterUid=activeEnc.getUid();
        }
    }
    if(activeEncounterUid.length()>0){
        sRfe= ReasonForEncounter.getReasonsForEncounterAsHtml(activeEncounterUid,sWebLanguage,"_img/icons/icon_delete.png","deleteRFE($serverid,$objectid)");
		%>
			<table class="list" width="100%" cellspacing="1">
			    <tr class="admin">
			        <td align="center"><a href="javascript:openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=activeEncounterUid%>&ts=<%=getTs()%>',700,400);void(0);"><%=getTran(request,"openclinic.chuk","rfe",sWebLanguage)%> <%=getTran(request,"Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></a></td>
			    </tr>
			    <tr>
			        <td id="rfe"><%=sRfe%></td>
			    </tr>
			</table>
			<br/>
		<%
    }
%>
<table class="list" width="100%" cellspacing="1">
    <tr class="admin">
        <td align="center"><a href="javascript:openPopup('healthrecord/findDSM4.jsp&PopupWidth=700&PopupHeight=400&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>');void(0);"><%=getTran(request,"openclinic.chuk","diagnostic.document",sWebLanguage)%> <%=getTran(request,"Web.Occup","DSM4",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></a></td>
    </tr>
    <tr>
        <td id='dsm4codes'>
	        <table width='100%'>
			        <%
			         Iterator items = curTran.getItems().iterator();
			         ItemVO item;
			
			         String sReferenceUID = curTran.getServerId() + "." + curTran.getTransactionId();
			         String sReferenceType = "Transaction";
			         Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID, sReferenceType);
			         Hashtable hDiagnosisInfo;
			         String sCode, sGravity, sCertainty,POA,NC,serviceUid,flags;

			         while (items.hasNext()) {
			             item = (ItemVO) items.next();
			             if (item.getType().indexOf("DSM4Code") == 0) {
			                 sCode = item.getType().substring("DSM4Code".length(), item.getType().length());
			                 hDiagnosisInfo = (Hashtable) hDiagnoses.get(sCode);
			                 if (hDiagnosisInfo != null) {
			                     sGravity = (String) hDiagnosisInfo.get("Gravity");
			                     sCertainty = (String) hDiagnosisInfo.get("Certainty");
			                     POA = (String) hDiagnosisInfo.get("POA");
			                     NC = (String) hDiagnosisInfo.get("NC");
			                     serviceUid = (String) hDiagnosisInfo.get("ServiceUid");
			                     flags = (String) hDiagnosisInfo.get("Flags");
			                 } else {
			                     sGravity = "";
			                     sCertainty = "";
			                     POA = "";
			                     NC = "";
			                     serviceUid="";
			                     flags="";
			                 }
			     			%><tr id="DSM4Code<%=item.getItemId()%>"><td width="1%" nowrap>
			                         <img src="<c:url value='/_img/icons/icon_delete.png'/>" onclick="deleteDiagnosis('DSM4Code<%=item.getItemId()%>');"/>
			                         </td><td width="1%">DSM4</td><td width="1%"><b><%=item.getType().replaceAll("DSM4Code","")%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b>
			                         <input type='hidden' name='DSM4Code<%=item.getType().replaceAll("DSM4Code","")%>' value="<%=item.getValue().trim()%>"/><input type='hidden' name='GravityDSM4Code<%=item.getType().replaceAll("DSM4Code","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyDSM4Code<%=item.getType().replaceAll("DSM4Code","")%>' value="<%=sCertainty%>"/><input type='hidden' name='POADSM4Code<%=item.getType().replaceAll("DSM4Code","")%>' value="<%=POA%>"/><input type='hidden' name='NCDSM4Code<%=item.getType().replaceAll("DSM4Code","")%>' value="<%=NC%>"/><input type='hidden' name='ServiceDSM4Code<%=item.getType().replaceAll("DSM4Code","")%>' value="<%=serviceUid%>"/><input type='hidden' name='FlagsDSM4Code<%=item.getType().replaceAll("DSM4Code","")%>' value="<%=flags%>"/>
			                   </td></tr>
			                 <%
			             }
			             else if (item.getType().indexOf("ICD10Code")==0){
			                 sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
			                 hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
			                 if (hDiagnosisInfo != null) {
			                     sGravity = (String) hDiagnosisInfo.get("Gravity");
			                     sCertainty = (String) hDiagnosisInfo.get("Certainty");
			                     POA = (String) hDiagnosisInfo.get("POA");
			                     NC = (String) hDiagnosisInfo.get("NC");
			                     serviceUid = (String) hDiagnosisInfo.get("ServiceUid");
			                     flags = (String) hDiagnosisInfo.get("Flags");
			                 } else {
			                     sGravity = "";
			                     sCertainty = "";
			                     POA = "";
			                     NC = "";
			                     serviceUid = "";
			                     flags = "";
			                 }
			                 %><tr id='ICD10Code<%=item.getItemId()%>'><td width="1%" nowrap>
			                         <img src='<c:url value="/_img/icons/icon_delete.png"/>' onclick="deleteDiagnosis('ICD10Code<%=item.getItemId()%>');"/>
			                         </td><td width="1%">ICD10</td><td width="1%"><b><%=item.getType().replaceAll("ICD10Code","")%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b>
			                         <input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/><input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/><input type='hidden' name='POAICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=POA%>"/><input type='hidden' name='NCICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=NC%>"/><input type='hidden' name='ServiceICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=serviceUid%>"/><input type='hidden' name='FlagsICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=flags%>"/>			                   
			                         </td></tr>
			                 <%
			             }
			         }
			        %>
	        </table>
	    </td>
    </tr>
</table>
<table class="list" width="100%" cellspacing="1">
    <tr class="admin">
        <td align="center"><%=getTran(request,"openclinic.chuk","contact.diagnoses",sWebLanguage)%> <%=getTran(request,"Web.Occup","DSM4",sWebLanguage)%>/<%=getTran(request,"Web.Occup","ICD-10",sWebLanguage)%></td>
    </tr>
    <tr>
        <td>
	        <table width='100%'>
		        <%
		        if(activeEncounterUid.length()>0){
			         items = curTran.getItems().iterator();
			
			         sReferenceUID = curTran.getServerId() + "." + curTran.getTransactionId();
			         sReferenceType = "Transaction";
			         Vector d = Diagnosis.selectDiagnoses("","",activeEncounterUid,"","","","","","","","","","");

			         for (int n=0;n<d.size();n++) {
			        	 Diagnosis diag=(Diagnosis)d.elementAt(n);
	                     sGravity = diag.getGravity()+"";
	                     sCertainty = diag.getCertainty()+"";
	                     POA = diag.getPOA();
	                     NC = diag.getNC();
	                     flags = diag.getFlags();
		     		     if (diag.getCodeType().equalsIgnoreCase("dsm4")){
			     			%>
		                         <tr><td width="1%">DSM4</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("dsm4code"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b></td></tr>
			                 <%
			             }
			             else if (diag.getCodeType().equalsIgnoreCase("icd10")){
				     			%>
		                         <tr><td width="1%">ICD10</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("icd10code"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b></td></tr>
			                 <%
			             }
			         }
		        }
		        %>
	        </table>
	    </td>
    </tr>
</table>
<table class="list" width="100%" cellspacing="1">
    <tr class="admin">
        <td align="center">SNOMED-CT</td>
    </tr>
    <tr>
        <td id='snomedcodes'>
	    </td>
    </tr>
</table>
<script>
	function readClipboard(){
		var txt=window.clipboardData.getData("Text");
		if(txt.length>0){
			if (window.DOMParser){
			  parser=new DOMParser();
			  xmlDoc=parser.parseFromString(txt,"text/xml");
			}
			else {
			  xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
			  xmlDoc.async="false";
			  xmlDoc.loadXML(txt);
			  var concepts=xmlDoc.getElementsByTagName("concept");
			  if(concepts.length>0){
			      var conceptId=concepts[0].getAttribute("id");
			      var snomedId=concepts[0].getAttribute("snomedId");
			      var ctv3id=concepts[0].getAttribute("ctv3id");
				  var fullySpecifiedName=concepts[0].getAttribute("fullySpecifiedName");	
				  document.getElementById("snomedcodes").innerHTML+="<span id='SNOMEDITEM."+conceptId+"'><input type='hidden' name='SNOMEDCONCEPT."+conceptId+"."+snomedId+"."+ctv3id+"' value='"+fullySpecifiedName+"'/>"+conceptId+" <b>"+fullySpecifiedName+"</b><br/></span>";
				  window.clipboardData.setData("Text","");
			  }  
			}
		}
	}
	window.setInterval("readClipboard();",1000);
</script>
<script>
  function deleteDiagnosis(itemid){
      if(confirm("<%=getTran(null,"Web","AreYouSure",sWebLanguage)%>")){
    	  document.getElementById(itemid).innerHTML='';
      }
  }

  function deleteRFE(serverid,objectid){
      if(confirm("<%=getTran(null,"Web","AreYouSure",sWebLanguage)%>")){
          var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=activeEncounterUid%>&language=<%=sWebLanguage%>";
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
</script>
