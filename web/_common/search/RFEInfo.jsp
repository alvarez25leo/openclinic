<%@page import="java.util.Vector,
                be.openclinic.medical.ReasonForEncounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sCode  = checkString(request.getParameter("Code")),
            sLabel = checkString(request.getParameter("Label")),
            reloadroot = checkString(request.getParameter("reloadroot")),
            complaintonset = checkString(request.getParameter("complaintonset")),
           sType  = checkString(request.getParameter("Type"));
           
    String sPatientUid = checkString(request.getParameter("patientuid"));
    if(sPatientUid.length()==0 && activePatient!=null){
    	sPatientUid = activePatient.personid;
    }

    String flags = ReasonForEncounter.getFlags(sType,sCode);
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************** _common/search/RFEInfo.jsp **********************");
    	Debug.println("sCode       : "+sCode);
    	Debug.println("sLabel      : "+sLabel);
    	Debug.println("sType       : "+sType);
    	Debug.println("sPatientUid : "+sPatientUid);
    	Debug.println("--> flags   : "+flags+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="RFEInfoForm" id="RFEInfoForm">
    <%=writeTableHeader("Web","diagnosegravityandcertainty",sWebLanguage," window.close();")%>
    
    <table class="list" width="100%" cellspacing="1">
        <!-- Diagnose code -->
        <tr>
            <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","diagnosiscode",sWebLanguage)%> *</td>
            <td class="admin2"><%=sCode%></td>
        </tr>
        
        <!-- Diagnose label-->
        <tr>
            <td class="admin"><%=getTran(request,"web",sType,sWebLanguage)%></td>
            <td class="admin2"><%=sLabel%></td>
        </tr>
        
        <!-- Diagnose label, equivalent -->
        <tr>
            <td class="admin"><%=sType.equalsIgnoreCase("icpc")?getTran(request,"web","ICD10",sWebLanguage):getTran(request,"web","ICPC",sWebLanguage)%>*</td>
            <td class="admin2">
                <%
                    String sFindCode = sCode;
                    if(sType.equalsIgnoreCase("icpc") && !sCode.startsWith("O") && sCode.length()>=3){
                        sFindCode = sCode.substring(0,3);
                    }
                    
                    Vector alternatives = null;
                    if(sCode.startsWith("+")){
                    	alternatives = new Vector();
                    }
                    else{
                    	alternatives = MedwanQuery.getInstance().getAlternativeDiagnosisCodes(sType,sFindCode);
                    }
                    
                    if(alternatives.size()==1){
                        out.print(alternatives.elementAt(0)+" "+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage));
                        flags = ReasonForEncounter.getFlags(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),flags);
                        
                        out.print("<input type='hidden' name='alternativeCode' id='alternativeCode' value='"+alternatives.elementAt(0)+"'/>");
                        out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage)+"'/>");
                    }
                    else if (alternatives.size()>1){
                        out.print("<select class='text' name='alternativeCode' id='alternativeCode' onclick=\"document.getElementsByName('alternativeCodeLabel')[0].value=document.getElementsByName('alternativeCode')[0].options[document.getElementsByName('alternativeCode')[0].selectedIndex].text.substring(document.getElementsByName('alternativeCode')[0].options[document.getElementsByName('alternativeCode')[0].selectedIndex].text.indexOf(' ')+1);\"><option/>");
                        for(int n=0; n<alternatives.size(); n++){
                            out.print("<option value='"+alternatives.elementAt(n)+"'>"+alternatives.elementAt(n)+" "+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(n),sWebLanguage)+"</option>");
                            flags = ReasonForEncounter.getFlags(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(n),flags);
                        }
                        out.print("</select>");
                        
                        out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage)+"'/>");
                    }
                %>
            </td>
        </tr>
        <!-- onset of complaints -->
        <tr>
            <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","complaints.onset",sWebLanguage)%></td>
            <td class="admin2">
            	<%=writeDateField("complaintsonset", "transactionForm", ScreenHelper.getDate(), sWebLanguage) %>
        	</td>
        </tr>
        <%
            if(flags.indexOf("C")>-1){
        %>
            <!-- confirmed -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","confirmed",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="confirmed" id="confirmed" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"confirmed")%>
                    <input type="radio" name="confirmed" id="confirmedNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"confirmedNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("D")>-1){
        %>
            <!-- digestif -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","digestive.problems",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="digestive" id="digestive" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"digestive")%>
                    <input type="radio" name="digestive" id="digestiveNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"digestiveNO")%>
                </td>
            </tr>
        <%
            }
			AdminPerson thePatient = AdminPerson.getAdminPerson(sPatientUid);
	        if(flags.indexOf("E")>-1 && thePatient!=null && !thePatient.gender.equalsIgnoreCase("m") && thePatient.getAge()>14 && activePatient.getAge()<50){
        %>
            <!-- pregnant -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","pregnant",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="pregnant" id="pregnant" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"pregnant")%>
                    <input type="radio" name="pregnant" id="pregnantNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"pregnantNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("R")>-1){
        %>
            <!-- chronic -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","chronic",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="chronic" id="chronic" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"chronic")%>
                    <input type="radio" name="chronic" id="chronicNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"chronicNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("V")>-1){
        %>
            <!-- vaccination -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","vaccination",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="vaccination" id="vaccination" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"vaccination")%>
                    <input type="radio" name="vaccination" id="vaccinationNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"vaccinationNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("S")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","severe",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="severe" id="severe" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"severe")%>
                    <input type="radio" name="severe" id="severeNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"severeNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("H")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","deshydration",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="deshydration" id="deshydration" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"deshydration")%>
                    <input type="radio" name="deshydration" id="deshydrationNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"deshydrationNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("B")>-1){
        %>
            <!-- bloody -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","bloody",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="bloody" id="bloody" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"bloody")%>
                    <input type="radio" name="bloody" id="bloodyNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"bloodyNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("K")>-1){
        %>
            <!-- bloody -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","bkplus",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="bkplus" id="bkplus" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"bkplus")%>
                    <input type="radio" name="bkplus" id="bkplusNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"bkplusNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("M")>-1){
        %>
            <!-- bloody -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","cutaneous",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="cutaneous" id="cutaneous" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"cutaneous")%>
                    <input type="radio" name="cutaneous" id="cutaneousNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"cutaneousNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("X")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","bacillaire",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="bacillaire" id="bacillaire" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"bacillaire")%>
                    <input type="radio" name="bacillaire" id="bacillaireNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"bacillaireNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("Y")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","amibienne",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="amibienne" id="amibienne" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"amibienne")%>
                    <input type="radio" name="amibienne" id="amibienneNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"amibienneNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("Z")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","shigellosis",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="shigellosis" id="shigellosis" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"shigellosis")%>
                    <input type="radio" name="shigellosis" id="shigellosisNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"shigellosisNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("I")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","intestinal",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="intestinal" id="intestinal" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"intestinal")%>
                    <input type="radio" name="intestinal" id="intestinalNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"intestinalNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("U")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","urinary",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="urinary" id="urinary" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"urinary")%>
                    <input type="radio" name="urinary" id="urinaryNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"urinaryNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("A")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","aptitudephys",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="aptitudephys" id="aptitudephys" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"aptitudephys")%>
                    <input type="radio" name="aptitudephys" id="aptitudephysNO "value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"aptitudephysNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("F")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","birthcert",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="birthcert" id="birthcert" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"birthcert")%>
                    <input type="radio" name="birthcert" id="birthcertNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"birthcertNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("G")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","deathcert",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="deathcert" id="deathcert" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"deathcert")%>
                    <input type="radio" name="deathcert" id="deathcertNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"deathcertNO")%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("J")>-1){
        %>
            <!-- severe -->
            <tr>
                <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","restcert",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="restcert" id="restcert" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"restcert")%>
                    <input type="radio" name="restcert" id="restcertNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"restcertNO")%>
                </td>
            </tr>
        <%
            }
        %>
        <!-- newcase -->
        <tr>
            <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","newcase",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="radio" name="newcase" id="newcase" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"newcase")%>
                <input type="radio" name="newcase" id="newcaseNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"newcaseNO")%>
            </td>
        </tr>
        <!-- planned -->
        <tr>
            <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","planned",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="radio" name="planned" id="planned" value="medwan.common.true"/><%=getLabel(request,"web","yes",sWebLanguage,"planned")%>
                <input type="radio" name="planned" id="plannedNO" value="medwan.common.false"/><%=getLabel(request,"web","no",sWebLanguage,"plannedNO")%>
            </td>
        </tr>
        
        <!-- transfer to problem list -->
        <tr>
            <td class="admin" nowrap><%=getTran(request,"medical.diagnosis","transfer.problemlist",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" name="DiagnosisTransferToProblemlist" id="DiagnosisTransferToProblemlist"/>
            </td>
        </tr>
        
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="EditAddButton" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="doAdd();">&nbsp;
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    
    <%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>
</form>

<script>
  function doAdd(){
    var flags = "";
    
    if(document.getElementById('aptitudephys')){
	  if(document.getElementById('aptitudephys').checked){
	    flags+= "A";
	  }
	  else{
        flags+= "a";
	  }
    }
    if(document.getElementById('bloody')){
	  if(document.getElementById('bloody').checked){
        flags+= "B";
      }
      else{
        flags+= "b";
      }
    }
    if(document.getElementById('confirmed')){
      if(document.getElementById('confirmed').checked){
	    flags+= "C";
	  }
	  else{
        flags+= "c";
      }
    }
    if(document.getElementById('digestive')){
      if(document.getElementById('digestive').checked){
        flags+="D";
      }
      else{
        flags+="d";
      }
    }
    if(document.getElementById('pregnant')){
      if(document.getElementById('pregnant').checked){
        flags+="E";
      }
      else{
        flags+="e";
      }
    }
    if(document.getElementById('birthcert')){
      if(document.getElementById('birthcert').checked){
        flags+="F";
      }
      else{
        flags+="f";
      }
    }
    if(document.getElementById('deathcert')){
      if(document.getElementById('deathcert').checked){
        flags+="G";
      }
      else{
        flags+="g";
      }
    }
    if(document.getElementById('deshydration')){
      if(document.getElementById('deshydration').checked){
        flags+="H";
      }
      else{
        flags+="h";
      }
    }
    if(document.getElementById('intestinal')){
      if(document.getElementById('intestinal').checked){
        flags+="I";
      }
      else{
        flags+="i";
      }
    }
    if(document.getElementById('restcert')){
      if(document.getElementById('restcert').checked){
        flags+="J";
      }
      else{
        flags+="j";
      }
    }
    if(document.getElementById('bkplus')){
      if(document.getElementById('bkplus').checked){
        flags+="K";
      }
      else{
        flags+="k";
      }
    }
    if(document.getElementById('cutaneous')){
      if(document.getElementById('cutaneous').checked){
        flags+="M"; 
	  }
	  else{
	    flags+="m";
	  }
    }
    if(document.getElementById('newcase')){
      if(document.getElementById('newcase').checked){
        flags+="N";
      }
      else{
        flags+="n";
      }
    }
    if(document.getElementById('planned')){
      if(document.getElementById('planned').checked){
	    flags+="P";
	  }
	  else{
	    flags+="p";
	  }
    }
    if(document.getElementById('chronic')){
      if(document.getElementById('chronic').checked){
        flags+="R";
	  }
	  else{
	    flags+="r";
	  }
    }
    if(document.getElementById('severe')){
      if(document.getElementById('severe').checked){
	    flags+="S";
	  }
	  else{
	    flags+="s";
	  }
    }
    if(document.getElementById('urinary')){
      if(document.getElementById('urinary').checked){
	    flags+="U";
	  }
	  else{
	    flags+="u";
	  }
    }
    if(document.getElementById('vaccination')){
      if(document.getElementById('vaccination').checked){
	    flags+="V";
	  }
	  else{
	    flags+="v";
	  }
    }
    if(document.getElementById('bacillaire')){
      if(document.getElementById('bacillaire').checked){
	    flags+="X";
	  }
	  else{
	    flags+="x";
	  }
    }
    if(document.getElementById('amibienne')){
      if(document.getElementById('amibienne').checked){
	    flags+="Y";
	  }
	  else{
	    flags+="y";
	  }
    }
    if(document.getElementById('shigellosis')){
      if(document.getElementById('shigellosis').checked){
	    flags+="Z";
	  }
	  else{
	    flags+="z";
	  }
    }
        
    // save the reason for encounter
    saveRFE(flags);
  }

  function saveRFE(flags){
    alt = "";
    if(document.getElementById("alternativeCode")){
      alt = document.getElementById("alternativeCode").value;
      if(alt.length==0){
    	  alert('<%=getTranNoLink("web","somedataismissing",sWebLanguage)%>');
    	  return;
      }
    }
    
    var params = "encounterUid=<%=ScreenHelper.checkString(request.getParameter("encounterUid"))%>"+
                 "&trandate=<%=ScreenHelper.checkString(request.getParameter("trandate"))%>"+
                 "&codeType=<%=sType%>"+
                 "&code=<%=sCode%>"+
                 "&onset="+document.getElementById("complaintsonset").value+
                 "&alternativeCodeType=<%=sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC"%>"+
                 "&alternativeCode="+alt+
                 "&language=<%=sWebLanguage%>"+
                 "&flags="+flags+
                 "&reloadroot=<%=reloadroot%>"+
                 "&userUid=<%=activeUser.userid%>";
    if(document.getElementById("DiagnosisTransferToProblemlist").checked){
    	params+="&transfertoproblemlist=1";
    }
    var url = '<c:url value="/healthrecord/storeRFE.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
      method: "GET",
      parameters: params,
      onSuccess: function(resp){
          window.opener.opener.document.getElementById('<%=ScreenHelper.checkString(request.getParameter("field"))%>').innerHTML=resp.responseText;
    	<%
    		if(reloadroot.equals("1")){
    	%>
	        if(document.getElementById("DiagnosisTransferToProblemlist").checked){
		        window.opener.opener.location.reload(true);
	        }
	    <%
    		}
	    %>
        window.opener.close();
        window.close();
      }
    });
  }
</script>