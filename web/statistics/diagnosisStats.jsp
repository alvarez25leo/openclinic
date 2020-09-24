<%@page import="be.openclinic.statistics.DiagnosisStats,
                java.text.DecimalFormat,
                java.util.*,
                be.openclinic.statistics.DiagnosisGroupStats,
                be.openclinic.statistics.DStats"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"statistics.globalpathologydistribution","select",activeUser)%>
<%
    int detail = 5;
    if(request.getParameter("detail")!=null){
        try{
            detail = Integer.parseInt(request.getParameter("detail"));
        }
        catch(Exception e){
            // empty
        }
    }
    
    String sortorder = checkString(request.getParameter("sortorder"));
    String contacttype = "admission";
    if(request.getParameter("contacttype")!=null){
        contacttype = request.getParameter("contacttype");
    }
    if(sortorder.length()==0){
        sortorder = "duration";
    }
    
    String todate   = checkString(request.getParameter("todate")),
           fromdate = checkString(request.getParameter("fromdate"));

    if(todate.length()==0){
        todate = ScreenHelper.stdDateFormat.format(new java.util.Date());
    }
    if(fromdate.length()==0){
        fromdate = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    
    String service  = checkString(request.getParameter("ServiceID"));
    String serviceName = "";
    if(service.length() > 0){
        serviceName=getTran(request,"service",service,sWebLanguage);
    }
    
    String showCalculations = checkString(request.getParameter("showCalculations"));
    
    String codetype = checkString(request.getParameter("codetype"));
    Boolean bGroups = false;
    if(codetype.equalsIgnoreCase("icd10groups")){
        bGroups = true;
        codetype = "icd10";
    }
    if(codetype.equalsIgnoreCase("icpcgroups")){
        bGroups = true;
        codetype = "icpc";
    }
    
    boolean popup = checkString(request.getParameter("popup")).equalsIgnoreCase("true");
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** statistics/diagnosisStats.jsp ********************");
    	Debug.println("detail      : "+detail);
    	Debug.println("todate      : "+todate);
    	Debug.println("fromdate    : "+fromdate);
    	Debug.println("service     : "+service);
    	Debug.println("serviceName : "+serviceName);
    	Debug.println("showCalculations : "+showCalculations);
    	Debug.println("codetype    : "+codetype);
    	Debug.println("popup       : "+popup+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    DecimalFormat deciComma = new DecimalFormat("#0.00");
    
%>
<form name="diagstats" id="diagstats" method="post">
    <%=writeTableHeader("Web","statistics.globalpathology",sWebLanguage,(popup?"closeWindow()":" doBack()"))%>
    
    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"web","codetype",sWebLanguage)%></td>
            <td class="admin2">
                <%-- CODE TYPE --%>
                <select name="codetype" class="text">
                    <option value="icpc" <%="icpc".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icpc",sWebLanguage)%></option>
                    <option value="icd10" <%="icd10".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icd10",sWebLanguage)%></option>
                    <option value="icpcgroups" <%="icpcgroups".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icpcgroups",sWebLanguage)%></option>
                    <option value="icd10groups" <%="icd10groups".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icd10groups",sWebLanguage)%></option>
                </select>
                
                <%-- CODE --%>
                <%=getTran(request,"web","code",sWebLanguage)%>
                <input type="text" class="text" name="code" value="<%=checkString(request.getParameter("code"))%>"/>
                <input type="checkbox" name="codedetails" <%=request.getParameter("codedetails")!=null?"checked":""%>>
                
                <%-- DETAIL --%>
                <%=getTran(request,"web","detail",sWebLanguage)%>
                <select name="detail" class="text">
                    <option value="1" <%=detail==1?"selected":""%>>1</option>
                    <option value="2" <%=detail==2?"selected":""%>>2</option>
                    <option value="3" <%=detail==3?"selected":""%>>3</option>
                    <option value="4" <%=detail==4?"selected":""%>>4</option>
                    <option value="5" <%=detail==5?"selected":""%>>5</option>
                </select>
                
                <%-- CONTACT TYPE --%>
                <select class="text" name="contacttype" id="contacttype" onchange="validateContactType();">
                    <%=ScreenHelper.writeSelect(request,"encountertype",contacttype,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- PERIOD --%>
        <tr>
            <td class="admin"><%=getTran(request,"web","period",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=getTran(request,"web","from",sWebLanguage)%>&nbsp;<%=writeDateField("fromdate","diagstats",fromdate,sWebLanguage)%>&nbsp;
                <%=getTran(request,"web","to",sWebLanguage)%>&nbsp;<%=writeDateField("todate","diagstats",todate,sWebLanguage)%>&nbsp;
            </td>
        </tr>
        
        <%-- SERVICE --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","service",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <input type="hidden" name="ServiceID" id="ServiceID" value="<%=service%>">
                <input class="text" type="text" name="ServiceName" id="ServiceName" readonly size="<%=sTextWidth%>" value="<%=serviceName%>">
             
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('ServiceID','ServiceName');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="ServiceID.value='';ServiceName.value='';">
            </td>
        </tr>
        
        <%-- CALCULATIONS --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","show.statistical.calculations",sWebLanguage)%></td>
            <td class="admin2" colspan='2'>
                <input id="showCalculations" type="checkbox" name="showCalculations" <%=showCalculations.length()>0?"checked":""%>>
            </td>
        </tr>
        
        <%-- SORT ORDER --%>
        <tr>
            <td class="admin"><%=getTran(request,"Web","sortorder",sWebLanguage)%></td>
            <td class="admin2">
                <select name="sortorder" id="sortorder" class="text">
                    <option value="duration" <%="duration".equalsIgnoreCase(sortorder)?" selected":""%>><%=getTranNoLink("web","sortorder.duration",sWebLanguage)%></option>
                    <option value="count" <%="count".equalsIgnoreCase(sortorder)?" selected":""%>><%=getTranNoLink("web","sortorder.count",sWebLanguage)%></option>
                    <option value="dead" <%="dead".equalsIgnoreCase(sortorder)?" selected":""%>><%=getTranNoLink("web","sortorder.dead",sWebLanguage)%></option>
                </select>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="submit" class="button" name="calculate" value="<%=getTranNoLink("web","calculate",sWebLanguage)%>"/>
                
                <%
                    if(popup){
                        %><input type="button" class="button" name="closeButton" value='<%=getTranNoLink("web","close",sWebLanguage)%>' onclick="closeWindow();"><%
                    }
                    else{
                    	%><input type="button" class="button" name="backButton" value='<%=getTranNoLink("web","back",sWebLanguage)%>' onclick="doBack();"><%
                    }
                %>
            </td>
        </tr>
    </table>
    <br>
    
<%
    
    //*** CALCULATE *******************************************************************************
    if(request.getParameter("calculate")!=null){
    	java.util.SortedSet diags = new TreeSet();
        DStats mainStats = null;
		try{
        if(bGroups){
            mainStats = new DiagnosisGroupStats(codetype,checkString(request.getParameter("code"))+"%",ScreenHelper.parseDate(fromdate),ScreenHelper.parseDate(todate),service,sortorder,contacttype);
        }
        else{
            mainStats = new DiagnosisStats(codetype,checkString(request.getParameter("code"))+"%",ScreenHelper.parseDate(fromdate),ScreenHelper.parseDate(todate),service,sortorder,contacttype);
        }
		}
		catch(Exception e){
			e.printStackTrace();
		}

        int totalDead = mainStats.calculateTotalDead(ScreenHelper.parseDate(fromdate),ScreenHelper.parseDate(todate));
        if(showCalculations.length()==0){
            %>
                <table width="100%" class='list' cellspacing="1" cellpadding="0">
                    <tr height="60">
                        <td class="admin2" width="5%"><b><%=getTran(request,"web","code",sWebLanguage)%></b></td>
                        <td class="admin2" width="35%"><b><%=getTran(request,"web","codename",sWebLanguage)%></b></td>
                        <td class="admin2" width="10%"><b><%=getTran(request,"web","numberofdiagnoses",sWebLanguage)%> (<%=getTran(request,"web","numberofcases",sWebLanguage)%>=<%=mainStats.getTotalContacts()%>)</b></td>
                        <td class="admin2" width="5%"><b>%</b></td>
                        <td class="admin2" width="10%"><b><%=getTran(request,"web","totalduration",sWebLanguage)%> (<%=getTran(request,"web","durationofcases",sWebLanguage)%>=<%=mainStats.getTotalDuration()%>)</b></td>
                        <td class="admin2" width="5%"><b>%</b></td>
                        <td class="admin2" width="10%"><b><%=getTran(request,"web","dead",sWebLanguage)%> (<%=getTran(request,"web","numberofdead",sWebLanguage)%>=<%=totalDead%>=<%=deciComma.format(new Double(totalDead).doubleValue()*100.0/mainStats.getTotalContacts())%>%)</b></td>
                        <td class="admin2" width="10%"><b><%=getTran(request,"web","relativenumberofdead",sWebLanguage)%></b></td>
                        <td class="admin2" width="10%"><b><%=getTran(request,"web","globalrelativenumberofdead",sWebLanguage)%></b></td>
                    </tr>
            <%
        }

        DStats diagnosisStats = null;
        if(request.getParameter("codedetails")!=null){
            if(bGroups){
                diags = DiagnosisGroupStats.calculateSubStats(codetype, checkString(request.getParameter("code"))+"%", ScreenHelper.parseDate(fromdate), ScreenHelper.parseDate(todate),service,sortorder,detail,contacttype);
            }
            else{
                diags = DiagnosisStats.calculateSubStats(codetype, checkString(request.getParameter("code"))+"%", ScreenHelper.parseDate(fromdate), ScreenHelper.parseDate(todate),service,sortorder,detail,contacttype);
            }
        }
        diags.add(mainStats);

        Vector d = new Vector(diags);
        Collections.reverse(d);
        Iterator iterator = d.iterator();
        while(iterator.hasNext()){
            diagnosisStats = (DStats)iterator.next();
            
            if(showCalculations.length() > 0){

            %>
                <br>
                
                <table width="100%" class='list' cellspacing="1" cellpadding="0">
                    <tr class="admin">
                        <td width="10%"><%=getTran(request,"web","code",sWebLanguage)%></td>
                        <td width="30%"><%=getTran(request,"web","codename",sWebLanguage)%></td>
                        <td width="30%"><%=getTran(request,"web","numberofdiagnoses",sWebLanguage)%> (<%=getTran(request,"web","numberofcases",sWebLanguage)%>=<%=mainStats.getTotalContacts()%>)</td>
                        <td width="30%"><%=getTran(request,"web","totalduration",sWebLanguage)%> (<%=getTran(request,"web","durationofcases",sWebLanguage)%>=<%=mainStats.getTotalDuration()%>)</td>
                    </tr>
                    <tr>
                        <td><%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%></td>
                        <%
                            String codeLabel=diagnosisStats.getCode().replaceAll("%","").length()<0?diagnosisStats.getCodeType().replaceAll("%","").toUpperCase()+" "+diagnosisStats.getCode().replaceAll("%",""):MedwanQuery.getInstance().getCodeTran(diagnosisStats.getCodeType()+"code"+(diagnosisStats.getCodeType().equalsIgnoreCase("icpc")?ScreenHelper.padRight(diagnosisStats.getCode().replaceAll("%",""),"0",5):diagnosisStats.getCode().replaceAll("%","")),sWebLanguage);
                            codeLabel=codeLabel.replaceAll(diagnosisStats.getCodeType()+"code","");
                        %>
                        <td><b><%=codeLabel%></b></td>
                        <td>
                            <a href="javascript:listcasesall('<%=diagnosisStats.getCodeType()%>','<%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%>','<%=codeLabel%>');">
                               <%=diagnosisStats.getDiagnosisAllCases()+(diagnosisStats.equals(mainStats)?"":" ("+deciComma.format(new Double(diagnosisStats.getDiagnosisAllCases()).doubleValue()*100.0/diagnosisStats.getTotalContacts())+"%)")%>
                            </a>
                        </td>
                        <%
                            if(!diagnosisStats.equals(mainStats)){
                                %><td><%=diagnosisStats.getDiagnosisTotalDuration()+" ("+deciComma.format(new Double(diagnosisStats.getDiagnosisTotalDuration().intValue()).doubleValue()*100.0/diagnosisStats.getTotalDuration())+"%)"%></td><%
                            }
                        %>
                    </tr>
                    <%
                        if(!diagnosisStats.equals(mainStats)){
                    %>
                        <tr>
                            <td colspan="4">
                                <table width="100%" cellspacing="1" cellpadding="0">
                                    <tr class="gray">
                                        <td>&nbsp;</td>
                                        <td><%=getTran(request,"web","outcome",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","numberofcases",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","admissionduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","meanduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","medianduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","standarddeviationduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","minimumduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","maximumduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","comorbidity",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","correctedtotalduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","correctedmeanduration",sWebLanguage)%></td>
                                        <td><%=getTran(request,"web","correctedmedianduration",sWebLanguage)%></td>
                                    </tr>
                                    
                                    <%
                                        Iterator iterator2 = diagnosisStats.getOutcomeStats().iterator();
                                        while(iterator2.hasNext()){
                                            DStats.OutcomeStat outcomeStat = (DStats.OutcomeStat)iterator2.next();
                                            double[] q;
                                            if(bGroups){
                                                q = DiagnosisGroupStats.getMedianDuration(diagnosisStats.getCode().replaceAll("%",""),diagnosisStats.getCodeType(), diagnosisStats.getStart(),diagnosisStats.getEnd(),outcomeStat.getOutcome(),service,contacttype);
                                            }
                                            else {
                                                q = DiagnosisStats.getMedianDuration(diagnosisStats.getCode().replaceAll("%",""),diagnosisStats.getCodeType(), diagnosisStats.getStart(),diagnosisStats.getEnd(),outcomeStat.getOutcome(),service,contacttype);
                                            }
                                            
                                            double median = q[1];
                                            double sd = outcomeStat.getStandardDeviationDuration();
                                            
                                            out.print("<tr>"+
                                                       "<td width='2%'>&nbsp;</td>"+
                                                       "<td width='9%'>"+getTran(request,"outcome",outcomeStat.getOutcome(),sWebLanguage)+" ("+deciComma.format(new Double(outcomeStat.getDiagnosisCases()).doubleValue()*100.0/diagnosisStats.getDiagnosisAllCases())+"%)</td>"+
                                                       "<td><a href=\"javascript:listcases('"+diagnosisStats.getCodeType()+"','"+diagnosisStats.getCode().replaceAll("%","").toUpperCase()+"','"+codeLabel+"','"+outcomeStat.getOutcome()+"');\">"+new DecimalFormat("#0").format(outcomeStat.getDiagnosisCases())+"</a></td>"+
                                                       "<td>"+deciComma.format(new Double(outcomeStat.getMeanDuration()*outcomeStat.getDiagnosisCases()))+" "+getTran(request,"web","days",sWebLanguage)+"</td>"+
                                                       "<td>"+deciComma.format(outcomeStat.getMeanDuration())+" "+getTran(request,"web","days",sWebLanguage)+"</td>"+
                                                       "<td><b>"+deciComma.format(median)+" "+getTran(request,"web","days",sWebLanguage)+"</b></br>(Q1="+q[0]+",Q3="+q[2]+")</td>"+
                                                       "<td>"+deciComma.format(sd)+" "+getTran(request,"web","days",sWebLanguage)+"</td>" +
                                                       "<td"+(outcomeStat.getMinDuration()<outcomeStat.getMeanDuration()-3*sd?" style='color: red'":"")+">"+deciComma.format(outcomeStat.getMinDuration())+" "+getTran(request,"web","days",sWebLanguage)+"</td>"+
                                                       "<td"+(outcomeStat.getMaxDuration()>outcomeStat.getMeanDuration()+3*sd?" style='color: red'":"")+">"+deciComma.format(outcomeStat.getMaxDuration())+" "+getTran(request,"web","days",sWebLanguage)+"</td>"+
                                                       "<td><a href=\"javascript:listcomorbidity('"+diagnosisStats.getCodeType()+"','"+diagnosisStats.getCode().replaceAll("%","").toUpperCase()+"','"+outcomeStat.getOutcome()+"','"+outcomeStat.getDiagnosisCases()+"');\">"+deciComma.format(outcomeStat.getCoMorbidityScore())+"</a></td>"+
                                                       "<td>"+deciComma.format(new Double(outcomeStat.getMeanDuration()*outcomeStat.getDiagnosisCases()/outcomeStat.getCoMorbidityScore()))+"</td>"+
                                                       "<td>"+deciComma.format(outcomeStat.getMeanDuration()/outcomeStat.getCoMorbidityScore())+" (+-"+deciComma.format(outcomeStat.getStandardDeviationDuration()/outcomeStat.getCoMorbidityScore())+") "+getTran(request,"web","days",sWebLanguage)+"</td>"+
                                                       "<td><b>"+deciComma.format(median/outcomeStat.getCoMorbidityScore())+" (+-"+deciComma.format(outcomeStat.getStandardDeviationDuration()/outcomeStat.getCoMorbidityScore())+") "+getTran(request,"web","days",sWebLanguage)+"</b></td>"+
                                                      "<tr>");
                                        }
                                    %>
                                </table>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                </table>
            <%

        }
        else{

            %>
                <tr>
                    <td><%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%></td>
                    <%
                        // if we have a full code, show the label, else only show the code
                        String codeLabel = diagnosisStats.getCode().replaceAll("%","").length()<0?diagnosisStats.getCodeType().replaceAll("%","").toUpperCase()+" "+diagnosisStats.getCode().replaceAll("%",""):MedwanQuery.getInstance().getCodeTran(diagnosisStats.getCodeType()+"code"+(diagnosisStats.getCodeType().equalsIgnoreCase("icpc")?ScreenHelper.padRight(diagnosisStats.getCode().replaceAll("%",""),"0",5):diagnosisStats.getCode().replaceAll("%","")),sWebLanguage);
                        codeLabel = codeLabel.replaceAll(diagnosisStats.getCodeType()+"code","");
                    %>
                    <td><b><%=codeLabel%></b></td>
                    <td>
                        <a href="javascript:listcasesall('<%=diagnosisStats.getCodeType()%>','<%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%>','<%=codeLabel%>');">
                            <%=diagnosisStats.getDiagnosisAllCases()%>
                        </a>
                    </td>
                    <%
                	int dead = 0;
                	try{
                		dead=diagnosisStats.getDiagnosisDead();
                	}
                	catch(Exception e){e.printStackTrace();};
                        if(!diagnosisStats.equals(mainStats)){
                            %>
                            <td><%=deciComma.format(new Double(diagnosisStats.getDiagnosisAllCases()).doubleValue()*100.0/diagnosisStats.getTotalContacts())%>%</td>
                            <td><%=(contacttype.equalsIgnoreCase("visit")?"</td><td>":diagnosisStats.getDiagnosisTotalDuration()+"</td><td>"+deciComma.format(new Double(diagnosisStats.getDiagnosisTotalDuration().intValue()).doubleValue()*100.0/diagnosisStats.getTotalDuration()))%>%</td>
                            <td><%=(contacttype.equalsIgnoreCase("visit")?"</td><td>":dead+"</td><td>"+deciComma.format(new Double(dead).doubleValue()*100.0/diagnosisStats.getDiagnosisAllCases())+"%</td><td>"+deciComma.format(new Double(dead).doubleValue()*100.0/totalDead))%>%</td>
                            <%
                        }
                        else{
                            %>
                            <td colspan="3"></td>
                            <td><%=(contacttype.equalsIgnoreCase("visit")?"":dead+"</td><td>"+deciComma.format(new Double(dead).doubleValue()*100.0/diagnosisStats.getDiagnosisAllCases()) )%>%</td>
                            <%
                        }
                    %>
                </tr>
            <%
        }
    }  
}

if(showCalculations.length()==0){
    %></table><%
    
    %><%=ScreenHelper.alignButtonsStart()%><%
	    if(popup){
	        %><input type="button" class="button" name="closeButton" value='<%=getTranNoLink("web","close",sWebLanguage)%>' onclick="closeWindow();"><%
	    }
	    else{
	    	%><input type="button" class="button" name="backButton" value='<%=getTranNoLink("web","back",sWebLanguage)%>' onclick="doBack();"><%
	    }
    %><%=ScreenHelper.alignButtonsStop()%><%
}
%>
</form>
	
<script>
  function listcasesall(codeType,code,codeLabel){
    window.open("<c:url value='/popup.jsp'/>?Page=medical/manageDiagnosesPop.jsp&PopupHeight=600&ts=<%=getTs()%>&selectrecord=1&Action=SEARCH&FindDiagnosisFromDate=<%=fromdate%>&FindDiagnosisToDate=<%=todate%>&FindDiagnosisCode="+code+"&FindDiagnosisCodeType="+codeType+"&FindDiagnosisCodeLabel="+code+" "+codeLabel+"&ServiceID=<%=service%>&contacttype=<%=contacttype%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width-800)/2,(screen.height-600)/2);
  }
  
  function listcases(codeType,code,codeLabel,outcome){
    if(outcome=='') outcome = "null";
    window.open("<c:url value='/popup.jsp'/>?Page=medical/manageDiagnosesPop.jsp&PopupHeight=600&ts=<%=getTs()%>&selectrecord=1&Action=SEARCH&FindDiagnosisFromDate=<%=fromdate%>&FindDiagnosisToDate=<%=todate%>&FindDiagnosisCode="+code+"&FindDiagnosisCodeType="+codeType+"&FindDiagnosisCodeLabel="+code+" "+codeLabel+"&FindEncounterOutcome="+outcome+"&ServiceID=<%=service%>&contacttype=<%=contacttype%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width-800)/2,(screen.height-600)/2);
  }
  
  function listcomorbidity(codeType,code,outcome,totalcases){
    if(outcome=='') outcome = "null";
    window.open("<c:url value='/popup.jsp'/>?Page=statistics/showComorbidity.jsp&PopupHeight=600&ts=<%=getTs()%>&Start=<%=fromdate%>&End=<%=todate%>&DiagnosisCode="+code+"&DiagnosisCodeType="+codeType+"&Outcome="+outcome+"&TotalCases="+totalcases+"&ServiceID=<%=service%>&contacttype=<%=contacttype%>&PopupWidth=500&PopupHeight=500&groupcodes=<%=bGroups?"yes":"no"%>","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=300, height=400, menubar=no").moveTo((screen.width-300)/2,(screen.height-400)/2);
  }
  
  function searchService(serviceUidField,serviceNameField){
    openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
    document.getElementsByName(serviceNameField)[0].focus();
  }
  
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
  
  function closeWindow(){
    window.opener = null;
    window.close();
  }

  <%-- VALIDATE CONTACT TYPE --%>
  function validateContactType(){
    if(document.getElementById("contacttype").value=="visit"){
       document.getElementById("showCalculations").checked=false;
       document.getElementById("showCalculations").disabled=true;
    }
    else{
      document.getElementById("showCalculations").disabled=false;
    }
  }
  
  validateContactType();
</script>