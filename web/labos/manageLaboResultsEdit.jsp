<%@page import="be.openclinic.archiving.ArchiveDocument"%>
<%@page import="be.openclinic.medical.RequestedLabAnalysis,
                java.util.*,
                be.openclinic.archiving.*,
                be.openclinic.medical.LabRequest,
                be.openclinic.medical.LabAnalysis"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"labos.openpatientlaboresults", "select", activeUser)%><%=checkPermission(out,"labos.biologicvalidationbyrequest", "select", activeUser)%>
<%=sJSCHAR%>

<%!
    public class LabRow {
        int type;
        String tag;
        public LabRow(int type, String tag) {
            this.type = type;
            this.tag = tag;
        }
    }
	public String getComplexARVResult(String id, String arvs, String sWebLanguage,java.util.Date validationDate) {
	    String sReturn = "<input type='hidden' id='resultAntiviro."+id+"' name='resultAntiviro."+id+"' value='"+arvs+"'/>";
	    sReturn += "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexARVResult(document.getElementById(\"resultAntiviro."+id+"\").value,\""+id+"\")'>"+getTranNoLink("web", "openAntivirogramresult", sWebLanguage)+"</a>";
	    sReturn += " "+getTran(null,"web","resultcomplete",sWebLanguage)+" <input type='checkbox' "+(validationDate!=null?"checked":"")+" name='validateAntiviro."+id+"'/>";
	    return sReturn;
	}
	public String getComplexResult(String id, Map map, String sWebLanguage,java.util.Date validationDate) {
	    String sReturn = "<input type='hidden' name='result."+id+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ1' name='resultAntibio."+id+".germ1' value='"+checkString((String) map.get("germ1"))+"'/>";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ2' name='resultAntibio."+id+".germ2' value='"+checkString((String) map.get("germ2"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ3' name='resultAntibio."+id+".germ3' value='"+checkString((String) map.get("germ3"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio1' name='resultAntibio."+id+".ANTIBIOGRAMME1' value='"+checkString((String) map.get("ANTIBIOGRAMME1"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio2' name='resultAntibio."+id+".ANTIBIOGRAMME2' value='"+checkString((String) map.get("ANTIBIOGRAMME2"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio3' name='resultAntibio."+id+".ANTIBIOGRAMME3' value='"+checkString((String) map.get("ANTIBIOGRAMME3"))+"' />";
	    sReturn += "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexResult(\""+id+"\")'>"+getTranNoLink("web", "openAntibiogrameresult", sWebLanguage)+"</a>";
	    sReturn += " "+getTran(null,"web","resultcomplete",sWebLanguage)+" <input type='checkbox' "+(validationDate!=null?"checked":"")+" name='validateAntibio."+id+"'/>";
	    return sReturn;
	}
    public String getComplexResultNew(String id, Map map, String sWebLanguage,java.util.Date validationDate) {
        String sReturn = "<input type='hidden' name='result."+id+"' />";
        sReturn += "<input type='hidden' id='resultAntibio."+id+".germ1' name='resultAntibio."+id+".germ1' value='"+checkString((String) map.get("germ1"))+"'/>";
        sReturn += "<input type='hidden' id='resultAntibio."+id+".germ2' name='resultAntibio."+id+".germ2' value='"+checkString((String) map.get("germ2"))+"' />";
        sReturn += "<input type='hidden' id='resultAntibio."+id+".germ3' name='resultAntibio."+id+".germ3' value='"+checkString((String) map.get("germ3"))+"' />";
        sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio1' name='resultAntibio."+id+".ANTIBIOGRAMME1' value='"+checkString((String) map.get("ANTIBIOGRAMME1"))+"' />";
        sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio2' name='resultAntibio."+id+".ANTIBIOGRAMME2' value='"+checkString((String) map.get("ANTIBIOGRAMME2"))+"' />";
        sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio3' name='resultAntibio."+id+".ANTIBIOGRAMME3' value='"+checkString((String) map.get("ANTIBIOGRAMME3"))+"' />";
        sReturn += "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexResultNew(\""+id+"\")'>"+getTranNoLink("web", "openAntibiogrameresult", sWebLanguage)+"</a>";
        sReturn += " "+getTran(null,"web","resultcomplete",sWebLanguage)+" <input type='checkbox' "+(validationDate!=null?"checked":"")+" name='validateAntibio."+id+"'/>";
        return sReturn;
    }
%>
<script>
    function showresultparts(item){
    	partlineprefix = item.name.replace("result.","resultcommentpartline.");
    	parts=item.options[item.selectedIndex].id.split(";");
    	//First clear all resultcommentpartlines
    	var x = document.getElementsByTagName("TR");
    	for(n=0;n<x.length;n++){
    		if(x[n].id && x[n].id.indexOf(partlineprefix)>-1){
    			x[n].style.display='none';
    		}
    	}
    	for(n=0;n<parts.length;n++){
        	if(document.getElementById(partlineprefix+"."+parts[n])){
         		document.getElementById(partlineprefix+"."+parts[n]).style.display='';
        	}
    	}
    	partlineprefix = item.name.replace("result.","resultcommentpart.");
    	x = document.getElementsByTagName("INPUT");
    	for(n=0;n<x.length;n++){
    		if(x[n].id && x[n].id.indexOf(partlineprefix)>-1){
   	        	if(document.getElementById(x[n].id.replace("resultcommentpart","resultcommentpartline")).style.display=='none'){
  	    			x[n].value='';
   	        	}
    		}
    	}
    }
</script>

<%
    boolean bSaved = false;
    if (request.getParameter("submit") != null) {
        bSaved = true;
        Enumeration e = request.getParameterNames();
        Hashtable composedResults = new Hashtable();
        Hashtable resultcomments = new Hashtable();
        while (e.hasMoreElements()) {
            String name = (String) e.nextElement();
            if (name.startsWith("result.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                RequestedLabAnalysis.updateValue(Integer.parseInt(v[1]), Integer.parseInt(v[2]), v[3], value,Integer.parseInt(activeUser.userid));
                RequestedLabAnalysis.setModifiedFinalValidation(Integer.parseInt(v[1]), Integer.parseInt(v[2]), Integer.parseInt(activeUser.userid), "'"+v[3]+"'",value);
                RequestedLabAnalysis requestedLabAnalysis = RequestedLabAnalysis.get(Integer.parseInt(v[1]), Integer.parseInt(v[2]), v[3]);
                requestedLabAnalysis.calculateModifier();
            } 
            else if (name.startsWith("resultreference.")) {
            	RequestedLabAnalysis.setScanResultForReference(name.replaceAll("resultreference.", ""));
            } 
            else if (name.startsWith("resultAntiviro.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                RequestedLabAnalysis.updateValue(Integer.parseInt(v[1]), Integer.parseInt(v[2]), v[3], value,Integer.parseInt(activeUser.userid));
               	if(request.getParameter(name.replaceAll("resultAntiviro.","validateAntiviro."))!=null){
               		RequestedLabAnalysis.setModifiedFinalValidation(Integer.parseInt(v[1]), Integer.parseInt(v[2]), Integer.parseInt(activeUser.userid), "'"+v[3]+"'",value);
               	}
            } 
            else if (name.startsWith("resultmultiple.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                if(composedResults.get(v[1]+"."+v[2]+"."+v[3])==null){
                	composedResults.put(v[1]+"."+v[2]+"."+v[3],value);
                }
                else{
                	composedResults.put(v[1]+"."+v[2]+"."+v[3],(String)composedResults.get(v[1]+"."+v[2]+"."+v[3])+","+value);
                }
            } 
            else if (name.startsWith("resultcomment.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                RequestedLabAnalysis.updateResultComment(Integer.parseInt(v[1]), Integer.parseInt(v[2]), v[3], value);
            } 
            else if (name.startsWith("resultcommentpart.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                String comment = (String)resultcomments.get(v[1]+"."+v[2]+"."+v[3]);
                if(comment==null){
                	comment="";
                }
                if(comment.length()>0){
                	comment+=";";
                }
                resultcomments.put(v[1]+"."+v[2]+"."+v[3], comment+v[4]+"="+value);
            } 
            else if (name.startsWith("resultAntibio.")) {
                String[] v = name.split("\\.");
                //RequestedLabAnalysis.updateValue(Integer.parseInt(v[1]), Integer.parseInt(v[2]), v[3], value,Integer.parseInt(activeUser.userid));
                RequestedLabAnalysis.setAntibiogrammes(name, request.getParameter(name), activeUser.userid);
            } 
            else if (name.startsWith("validateAntibio.")) {
                String[] v = name.split("\\.");
                RequestedLabAnalysis.setForcedFinalValidation(Integer.parseInt(v[1]), Integer.parseInt(v[2]), Integer.parseInt(activeUser.userid), "'"+v[3]+"'");
            }
        }
        Enumeration cr = composedResults.keys();
        while(cr.hasMoreElements()){
            String name=(String)cr.nextElement();
        	String[] v = name.split("\\.");
            String value = (String)composedResults.get(name);
            RequestedLabAnalysis.updateValue(Integer.parseInt(v[0]), Integer.parseInt(v[1]), v[2], value);
            RequestedLabAnalysis.setFinalValidation(Integer.parseInt(v[0]), Integer.parseInt(v[1]), Integer.parseInt(activeUser.userid), "'"+v[2]+"'");
        }
        Enumeration rc = resultcomments.keys();
        while(rc.hasMoreElements()){
            String name=(String)rc.nextElement();
        	String[] v = name.split("\\.");
            String value = (String)resultcomments.get(name);
            RequestedLabAnalysis.updateResultComment(Integer.parseInt(v[0]), Integer.parseInt(v[1]), v[2], value);
        }
    }
    SortedMap requestList = new TreeMap();
    Vector r = LabRequest.findUntreatedRequests(sWebLanguage, Integer.parseInt(activePatient.personid));
    for (int n = 0; n < r.size(); n++) {
        LabRequest labRequest = (LabRequest) r.elementAt(n);
        if (labRequest.getRequestdate() != null) {
            requestList.put(new SimpleDateFormat("yyyyMMddHHmmss").format(labRequest.getRequestdate())+"."+labRequest.getServerid()+"."+labRequest.getTransactionid(), labRequest);
        }
    }
    SortedMap groups = new TreeMap();
    HashSet hMissingScans = new HashSet();
    Iterator iterator = requestList.keySet().iterator();
    while (iterator.hasNext()) {
        LabRequest labRequest = (LabRequest) requestList.get(iterator.next());
        Enumeration enumeration = labRequest.getAnalyses().elements();
        while (enumeration.hasMoreElements()) {
            RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) enumeration.nextElement();
            LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(requestedLabAnalysis.getAnalysisCode());
			if(analysis!=null && analysis.getEditor().equalsIgnoreCase("calculated")){
				continue;
			}
            requestedLabAnalysis.calculateModifier();
            if (groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group", requestedLabAnalysis.getLabgroup(), sWebLanguage)) == null) {
                groups.put(MedwanQuery.getInstance().getLabel("labanalysis.group", requestedLabAnalysis.getLabgroup(), sWebLanguage), new Hashtable());
            }
            ((Hashtable) groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group", requestedLabAnalysis.getLabgroup(), sWebLanguage))).put(requestedLabAnalysis.getAnalysisCode(), "1");
        }
        Vector missingScans=labRequest.getMissingScans();
        for(int n=0;n<missingScans.size();n++){
        	//We have to add a cell for each missing scan
        	hMissingScans.add(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+missingScans.elementAt(n));
            if (groups.get(" "+MedwanQuery.getInstance().getLabel("web", "scan", sWebLanguage)) == null) {
                groups.put(" "+MedwanQuery.getInstance().getLabel("web", "scan", sWebLanguage), new Hashtable());
            }
            ((Hashtable) groups.get(" "+MedwanQuery.getInstance().getLabel("web", "scan", sWebLanguage))).put("00SCAN00"+missingScans.elementAt(n), "1");
        }
    }%>
<%=writeTableHeader("Web", "openPatientLaboResults", sWebLanguage, " doBack();")%><form method='post' name='fastresults'>
    <table width="100%" cellspacing="1" cellpadding="1" class="list">
        <tr class="admin">
            <td><span id='uploadgif'>&nbsp;</span></td>
            <td width="1"/>
            <td><%=getTran(request,"web", "analysis", sWebLanguage)%></td>
            <%
                Iterator requestsIterator = requestList.keySet().iterator();
                while (requestsIterator.hasNext()) {
                    LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
                    out.print("<td>"+ScreenHelper.formatDate(labRequest.getRequestdate(),ScreenHelper.fullDateFormat)+"&nbsp;&nbsp;&nbsp; &nbsp;<a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>"+labRequest.getTransactionid()+"</b></a></td>");
                }
            %>
        </tr>
        <%
            String abnormal = MedwanQuery.getInstance().getConfigString("abnormalModifiers", "*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*");
            boolean bEditable = activeUser.getAccessRight("labos.biologicvalidationbyrequest.edit");
            Iterator groupsIterator = groups.keySet().iterator();
            int i = 0;   // for colors
            HashSet scanshandeled = new HashSet();
            Hashtable scans = new Hashtable();
            while (groupsIterator.hasNext()) {
                i++;
                String groupname = (String) groupsIterator.next();
                Hashtable analysisList = (Hashtable) groups.get(groupname);
                out.print("<tr><td class='color color"+i+"' rowspan='"+analysisList.size()+"'><b>"+MedwanQuery.getInstance().getLabel("labanalysis.groups", groupname, sWebLanguage).toUpperCase()+"</b></td>");
                SortedSet sortedSet = new TreeSet();
                sortedSet.addAll(analysisList.keySet());
                Iterator analysisEnumeration = sortedSet.iterator();
                while (analysisEnumeration.hasNext()) {
                    String analysisCode = (String) analysisEnumeration.next();
                    String c = analysisCode;
                    String u = "";
                    String refs="";
                    LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(analysisCode);
                    if (analysis != null) {
            			if(analysis.getEditor().equalsIgnoreCase("calculated")){
            				continue;
            			}
                        c = analysis.getLabId()+"";
                        refs = analysis.getResultRefMin(activePatient.gender,new Double(activePatient.getAgeInMonths()).intValue())+" - "+analysis.getResultRefMax(activePatient.gender,new Double(activePatient.getAgeInMonths()).intValue());
                        if(refs.equalsIgnoreCase(" - ")){
                        	refs="";
                        }
                        u = " ("+refs+" "+analysis.getUnit()+")";
                    }
                    if(analysisCode.startsWith("00SCAN00")){
                    	String scantype=analysisCode.replaceAll("00SCAN00", "").replaceAll("TP:", "");
	                    out.print("<td class='color color"+i+"'></td><td class='color color"+i+"' width='*'><b>"+scantype+"</b></td>");
	                    requestsIterator = requestList.keySet().iterator();
	                    while (requestsIterator.hasNext()) {
	                        String result = "";
	                        LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
	                    	if(hMissingScans.contains(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+analysisCode.replaceAll("00SCAN00", ""))){
	                    		String sReference = labRequest.getServerid()+"."+labRequest.getTransactionid()+".LAB."+scantype;
	                    		ArchiveDocument doc = ArchiveDocument.getByReference(sReference);
	                    		if(doc!=null){
		                    		//We must add an upload for this scanned document
		                    		if(MedwanQuery.getInstance().getConfigString("executeScannerCommand","").length()==0){
		                    			result="<img src='"+sCONTEXTPATH+"/_img/icons/icon_upload.gif' class='link' onclick='document.getElementById(\"fileuploadid\").value=\""+doc.udi+"\";document.getElementById(\"uploadtransactionid\").value=\""+labRequest.getServerid()+"."+labRequest.getTransactionid()+"\";document.getElementById(\"fileupload\").click();return false'/> ("+ScreenHelper.removeLeadingZeros(doc.udi)+")";
		                    		}
		                    		else{
		                    			result="<img src='"+sCONTEXTPATH+"/_img/icons/icon_uploaddirect.png' title='"+getTranNoLink("web","loadfromscanner",sWebLanguage)+"' class='link' onclick='executeLocalScannerCommand(\""+MedwanQuery.getInstance().getConfigString("localScannerOutputDirectory","c:/projects/openclinicnew/web/scan/scan/from")+"/"+doc.udi+".pdf\",\""+doc.udi+"\")'/>";
		                    		}
	                    		}
	                    	};
	                        out.print("<td class='color color"+i+"'>"+result+"</td>");
	                    }
                    	
                    }
                    else{
	                    out.print("<td class='color color"+i+"'>"+analysisCode+"</td><td class='color color"+i+"' width='*'><b>"+MedwanQuery.getInstance().getLabel("labanalysis", c, sWebLanguage)+" "+u+"</b></td>");
	                    requestsIterator = requestList.keySet().iterator();
	                    while (requestsIterator.hasNext()) {
	                        LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
	                        RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) labRequest.getAnalyses().get(analysisCode);
	                        // changed by emanuel@mxs.be
	                        String result = "";
	                        if(requestedLabAnalysis != null){
		                        if (analysis.getEditor().equals("text")){
									if(bEditable){
										result="<input class='text' type='text' size='"+analysis.getEditorparametersParameter("SZ")+"' maxlength='"+analysis.getEditorparametersParameter("SZ")+"'  name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+checkString(requestedLabAnalysis.getResultValue())+"'/>"+u;
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
		                        }
		                        else if (analysis.getEditor().equals("numeric")){
									if(bEditable){
										result="<input onKeyUp=\"if(this.value.length>0 && !isNumber(this)){alertDialog('web','notnumeric');this.value='';}\" class='text' size='"+analysis.getEditorparametersParameter("SZ")+"' maxlength='"+analysis.getEditorparametersParameter("SZ")+"' type='text' name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+checkString(requestedLabAnalysis.getResultValue())+"'/>"+u;
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
		                        }
		                        else if (analysis.getEditor().equals("scan")){
		                        	String sReference=labRequest.getServerid()+"."+labRequest.getTransactionid()+".LAB."+analysis.getEditorparametersParameter("TP");
		                        	boolean bAddReference=false;
		                        	if(!scanshandeled.contains(sReference)){
		                        		scanshandeled.add(sReference);
		                        		bAddReference=true;
		                        		ArchiveDocument doc = ArchiveDocument.getByReference(sReference);
		                        		if(doc!=null){
		                        			scans.put(sReference,doc);
		                        		}
		                        	}
		                        	ArchiveDocument doc = (ArchiveDocument)scans.get(sReference);
		                        	if(doc!=null){
		                        		if(doc.storageName!=null && doc.storageName.length()>0){
					                    	String sServer = 	MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_url","scan")+"/"+
			                    	                 			MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo","to");
			                            	result=(bAddReference?"<input type='hidden' name='resultreference."+doc.reference+"'/>":"")+"<a href='javascript:window.open(\""+sCONTEXTPATH+"/"+sServer+"/"+doc.storageName+"\",\"_new\",\"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=500,menubar=no\");void(0);' title='"+sServer+"/"+doc.storageName+"' target='_new'><img src='"+sCONTEXTPATH+"/_img/icons/icon_labo.png'/> "+ScreenHelper.removeLeadingZeros(doc.udi)+"</a>";
			                        	}
		                        		else{
		                        			result="<span title='"+ScreenHelper.removeLeadingZeros(doc.udi)+"'>?</span>";
		                        		}
		                        	}
		                        	else{
		                        		result="Error";
		                        	}
		                        }
		                        else if (analysis.getEditor().equals("numericcomment")){
									if(bEditable){
										result="<input onKeyUp=\"if(this.value.length>0 && !isNumber(this)){alertDialog('web','notnumeric');this.value='';}\" class='text' size='"+analysis.getEditorparametersParameter("SZ")+"' maxlength='"+analysis.getEditorparametersParameter("SZ")+"' type='text' name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+checkString(requestedLabAnalysis.getResultValue())+"'/>"+u;
										result+="<br/><input type='text' name='resultcomment."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
		                        }
		                        else if (analysis.getEditor().equals("listbox")){
		                        	HashSet resultcommentparts = new HashSet();
									if(bEditable){
										result="<select class='text' name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' id='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' onchange='showresultparts(this)'>";
										String[] options = analysis.getEditorparametersParameter("OP").split(",");
										for(int n=0;n<options.length;n++){
											String key=options[n];
											String label=key.split("\\$")[0];
											if(key.split("\\|").length>1){
												label=key.split("\\|")[1];
												key=key.split("\\|")[0];
											}
											String activeparts="";
											if(key.split("\\$").length>1){
												for(int j=1;j<key.split("\\$").length;j++){
													if(j>1){
														activeparts+=";";
													}
													resultcommentparts.add(key.split("\\$")[j]);
													activeparts+=key.split("\\$")[j];
												}
											}
											result+="<option id='"+activeparts+"' value='"+key.split("\\$")[0]+"' "+(key.split("\\$")[0].equals(requestedLabAnalysis.getResultValue())?"selected":"")+">"+label+"</option>";
										}
										result+="</select>"+u;
										Iterator it = resultcommentparts.iterator();
										if(it.hasNext()){
											result+="<table>";
											while(it.hasNext()){
												String part = (String)it.next();
												result+="<tr style='display: none' id='resultcommentpartline."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"' name='resultcommentpartline."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"'><td>"+part+"</td><td><input type='text' name='resultcommentpart."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"' id='resultcommentpart."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"' value='"+requestedLabAnalysis.getResultCommentPart(part)+"' class='text'/></td></tr>";
											}
											result+="</table><script>showresultparts(document.getElementById('result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"'))</script>";
										}
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
		                        }
		                        else if (analysis.getEditor().equals("listboxcomment")){
									if(bEditable){
										result="<select class='text' name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"'>";
										String[] options = analysis.getEditorparametersParameter("OP").split(",");
										for(int n=0;n<options.length;n++){
											String key=options[n];
											String label=key;
											if(key.split("\\|").length>1){
												label=key.split("\\|")[1];
												key=key.split("\\|")[0];
											}
											result+="<option value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"selected":"")+">"+label+"</option>";
										}
										result+="</select>"+u;
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
									result+="<br/><input type='text' name='resultcomment."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
		                        }
		                        else if (analysis.getEditor().equals("radiobutton")){
									if(bEditable){
										String[] options = analysis.getEditorparametersParameter("OP").split(",");
										for(int n=0;n<options.length;n++){
											String key=options[n];
											String label=key;
											if(key.split("\\|").length>1){
												label=key.split("\\|")[1];
												key=key.split("\\|")[0];
											}
											result+="<input type='radio' ondblclick='this.checked=!this.checked' name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
										}
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
		                        }
		                        else if (analysis.getEditor().equals("radiobuttoncomment")){
									if(bEditable){
										String[] options = analysis.getEditorparametersParameter("OP").split(",");
										for(int n=0;n<options.length;n++){
											String key=options[n];
											String label=key;
											if(key.split("\\|").length>1){
												label=key.split("\\|")[1];
												key=key.split("\\|")[0];
											}
											result+="<input type='radio' ondblclick='this.checked=!this.checked' name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
										}
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
									result+="<br/><input type='text' name='resultcomment."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
		                        }
		                        else if (analysis.getEditor().equals("checkbox")){
									if(bEditable){
										String[] options = analysis.getEditorparametersParameter("OP").split(",");
										for(int n=0;n<options.length;n++){
											String key=options[n];
											String label=key;
											if(key.split("\\|").length>1){
												label=key.split("\\|")[1];
												key=key.split("\\|")[0];
											}
											result+="<input type='checkbox' ondblclick='this.checked=!this.checked' name='resultmultiple."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+n+ "' value='"+key+"' "+((","+requestedLabAnalysis.getResultValue()+",").contains(","+key+",")?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
										}
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
		                        }
		                        else if (analysis.getEditor().equals("checkboxcomment")){
									if(bEditable){
										String[] options = analysis.getEditorparametersParameter("OP").split(",");
										for(int n=0;n<options.length;n++){
											String key=options[n];
											String label=key;
											if(key.split("\\|").length>1){
												label=key.split("\\|")[1];
												key=key.split("\\|")[0];
											}
											result+="<input type='checkbox' name='resultmultiple."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+n+ "' value='"+key+"' "+((","+requestedLabAnalysis.getResultValue()+",").contains(","+key+",")?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
										}
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
									result+="<br/><input type='text' name='resultcomment."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
		                        }
		                        else if(analysis.getEditor().equals("antibiogram")) {
		                        	result = getComplexResult(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()), sWebLanguage,requestedLabAnalysis.getFinalvalidationdatetime());                        	//result = getComplexResult(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()), sWebLanguage);
		                        }
		                        else if(analysis.getEditor().equals("antivirogram")) {
		                        	result = getComplexARVResult(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), requestedLabAnalysis.getResultValue(), sWebLanguage,requestedLabAnalysis.getFinalvalidationdatetime());                        	
		                        }
		                        else if(analysis.getEditor().equals("antibiogramnew")) {
		                        	result = getComplexResultNew(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()), sWebLanguage,requestedLabAnalysis.getFinalvalidationdatetime());                        	//result = getComplexResult(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()), sWebLanguage);
		                        }
		                        else {
									if(bEditable){
										result="<input class='text' type='text' name='result."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+checkString(requestedLabAnalysis.getResultValue())+"'/>"+u;
									} else {
										result=requestedLabAnalysis.getResultValue();
									}
		                        }
	                        }
	                        boolean bAbnormal = (result.length() > 0 && !result.equalsIgnoreCase("?") && abnormal.toLowerCase().indexOf("*"+checkString(requestedLabAnalysis.getResultModifier()).toLowerCase()+"*") > -1);
	                        out.print("<td class='color color"+i+"'>"+result+(bAbnormal ? " "+checkString(requestedLabAnalysis.getResultModifier().toUpperCase()) : "")+"</td>");
	                    }
                    }
                    out.print("</tr>");
                }
            }
        %>
    </table>
    <p/>
    <p style="width:100%;text-align:center;">
        <input class="button" type="submit" name="submit" value="<%=getTranNoLink("web","save",sWebLanguage)%>"/>
    </p>
</form>
<form target="_newForm" name="uploadForm" action="<c:url value='/'/>healthrecord/archiveDocumentUpload.jsp" method="post" enctype="multipart/form-data">
	<input type='hidden' name='fileuploadid' id='fileuploadid'/>
	<input type='hidden' name='uploadtransactionid' id='uploadtransactionid'/>
	<input style='display: none' class="text" id='fileupload' name="filename" type="file" title=""  onchange="uploadFile(document.getElementById('fileuploadid').value);"/>
</form>

<script>
    <%
        if(bSaved){
            out.write("closeModalbox('"+ getTranNoLink("web","saved",sWebLanguage)+"');");
        }
    %>
    function uploadFile(uid){
        if(uploadForm.filename.value.length>0){
          uploadForm.submit();
        }
        window.setTimeout('checkArchiveDocument("'+uid+'")','1000');
    }
    function checkArchiveDocument(uid){
    	document.getElementById("uploadgif").innerHTML="<img height='8px' src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";        
    	var url = "<c:url value="/"/>/util/checkLabDocument.jsp?ts="+new Date().getTime();
        new Ajax.Request(url,{
          parameters: "fileuploadid="+uid,
             onSuccess: function(resp){
            	 if(trim(resp.responseText).indexOf("true")>-1){
            		 window.location.href = "<c:url value="/"/>/main.do?Page=labos/manageLaboResultsEdit.jsp";	 
            	 }
            	 else {
           		    window.setTimeout('checkArchiveDocument("'+uid+'")','1000');
            	 }
             },
          	onFailure: function(resp){
        		document.getElementById("uploadgif").innerHTML='&nbsp';
            	alert("ERROR :\n"+resp.responseText);
          }
        });
    }
    function executeLocalScannerCommand(documentname,uid){
    	var url = "<%=MedwanQuery.getInstance().getConfigString("executeScannerCommand","http://localhost/diagnostics/scanDocument.jsp")%>?output="+documentname+"&ts="+new Date().getTime()+
    		"fileuploadid="+uid;
      	window.open(url);
	    window.setTimeout('checkArchiveDocument("'+uid+'")','1000');
    }
    function showRequest(serverid, transactionid) {
        window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1", "Popup"+new Date().getTime(), "toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
    }
    function doBack() {
        window.location.href = "<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
    openComplexResult = function(id) {
        var params = "antibiogramuid="+id+"&editable=<%=bEditable%>";
        var url = "<c:url value="/labos/ajax/getComplexResult.jsp" />?ts="+new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("web","antibiogram",sWebLanguage)%>",params:params,width:<%=MedwanQuery.getInstance().getConfigInt("antibiogramWidth",650)%>,height:<%=MedwanQuery.getInstance().getConfigInt("antibiogramHeight",600)%>});
    }
    openComplexARVResult = function(arvs,id) {
        var params = "antivirogramuid="+id+"&editable=<%=bEditable%>&arvs="+arvs;
        var url = "<c:url value="/labos/ajax/getComplexARVResult.jsp" />?ts="+new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("web","antivirogram",sWebLanguage)%>",params:params,width:<%=MedwanQuery.getInstance().getConfigInt("antibiogramWidth",650)%>,height:<%=MedwanQuery.getInstance().getConfigInt("antibiogramHeight",600)%>});
    }
    openComplexResultNew = function(id) {
        var params = "antibiogramuid="+id+"&editable=<%=bEditable%>";
        var url = "<c:url value="/labos/ajax/getComplexResultNew.jsp" />?ts="+new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("web","antibiogram",sWebLanguage)%>",params:params,width:<%=MedwanQuery.getInstance().getConfigInt("antibiogramWidth",650)%>,height:<%=MedwanQuery.getInstance().getConfigInt("antibiogramHeight",600)%>});
    }
    addObserversToAntibiogram = function(id) {
        $("germ1").value = $F("resultAntibio."+id+".germ1");
        $("germ2").value = $F("resultAntibio."+id+".germ2");
        $("germ3").value = $F("resultAntibio."+id+".germ3");
        setCheckBoxValues(id, $F("resultAntibio."+id+".antibio1").split(","), 1);
        setCheckBoxValues(id, $F("resultAntibio."+id+".antibio2").split(","), 2);
        setCheckBoxValues(id, $F("resultAntibio."+id+".antibio3").split(","), 3);
        $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
            e.parentNode.observe('click', function(event) {
                //alert(Event.element(event));
                var elem = Event.element(event);
                if (elem.tagName == "TD") {
                    if (elem.firstChild.checked) {
                        elem.firstChild.checked = false;
                    } else {
                        elem.firstChild.checked = true;
                        new Effect.Highlight(elem, { startcolor: '#FFE7DA'});
                    }
                } else {
                    new Effect.Highlight(elem.parentNode, { startcolor: '#FFE7DA'});
                }
            });
        });

    }
    setCheckBoxValues = function(id, tab, nb) {
        tab.each(function(anti) {
            if (anti.length > 0) {
                var tAnti = anti.split("=");
                try {
                    $(tAnti[0]+"_radio_"+nb+"_"+tAnti[1]).checked = true;
                } catch(e) {
                    alertDialog(tAnti[0]+"_radio_"+nb+"_"+tAnti[1]);
                }
            }
        });
    }
    setAntibiogram = function (id) {
        var s = "";
        $("resultAntibio."+id+".germ1").value = $F("germ1");
        $("resultAntibio."+id+".germ2").value = $F("germ2");
        $("resultAntibio."+id+".germ3").value = $F("germ3");
        $("resultAntibio."+id+".antibio1").value = "";
        $("resultAntibio."+id+".antibio2").value = "";
        $("resultAntibio."+id+".antibio3").value = "";
        $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
            if (e.checked) {
                s += "\n"+e.name+" -  "+e.value;
                var tab = e.name.split("_");
                $("resultAntibio."+id+".antibio"+tab[2]).value = $F("resultAntibio."+id+".antibio"+tab[2])+","+tab[0]+"="+e.value;
            }
        });
        Modalbox.hide();
    }
</script>
<script>
	function saveAntiviroGramme(id){
		var s ='';
		var x = document.getElementsByTagName("SELECT");
		for(n=0;n<x.length;n++){
			if(x[n].id.indexOf("arv")>-1 && x[n].selectedIndex>0){
				if(s.length>0){
					s+=";";
				}
				s+=x[n].id.substring(3)+"="+x[n].value;
			}
		}
		document.getElementById('resultAntiviro.'+id).value=s;
        Modalbox.hide();
	}
</script>
