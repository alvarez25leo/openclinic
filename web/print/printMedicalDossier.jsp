<%@page import="java.io.FileOutputStream"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                java.io.PrintWriter,
                com.itextpdf.text.*,
                com.itextpdf.text.pdf.*,
                be.mxs.common.util.pdf.general.dossierCreators.MedicalDossierPDFCreator,
                be.mxs.common.util.pdf.PDFCreator,
                be.mxs.common.util.system.Picture,
                be.openclinic.medical.ReasonForEncounter"%>
<%=sJSSORTTABLE%>

<%!
    //--- ADD FOOTER TO PDF -----------------------------------------------------------------------
    // Like PDFFooter-class but with total pagecount
    public ByteArrayOutputStream addFooterToPdf(ByteArrayOutputStream origBaos, HttpSession session) throws Exception {
	    com.itextpdf.text.pdf.PdfReader reader = new com.itextpdf.text.pdf.PdfReader(origBaos.toByteArray());
	    int totalPageCount = reader.getNumberOfPages(); 
	    
	    ByteArrayOutputStream newBaos = new ByteArrayOutputStream();
	    com.itextpdf.text.Document document = new com.itextpdf.text.Document();
	    com.itextpdf.text.pdf.PdfCopy copy = new com.itextpdf.text.pdf.PdfCopy(document,newBaos);
	    document.open();
	
	    String sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
	    String sFooterText = MedwanQuery.getInstance().getConfigString("footer."+sProject,"OpenClinic pdf engine (c)2007-"+new SimpleDateFormat("yyyy").format(new java.util.Date())+", Post-Factum bvba");
	    
	    // Loop over the pages of the baos
	    com.itextpdf.text.pdf.PdfImportedPage pdfPage;
	    com.itextpdf.text.pdf.PdfCopy.PageStamp stamp;
	    com.itextpdf.text.Phrase phrase;

	    int fontSizePercentage = MedwanQuery.getInstance().getConfigInt("fontSizePercentage",100);
	    com.itextpdf.text.Rectangle rect = document.getPageSize();
	    for(int i=0; i<totalPageCount;){
	    	pdfPage = copy.getImportedPage(reader,++i);
	
	        //*** add footer with page numbers ***
	        stamp = copy.createPageStamp(pdfPage);
	        
	    	// footer text
	        phrase = com.itextpdf.text.Phrase.getInstance(0,sFooterText,com.itextpdf.text.FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)10*fontSizePercentage/100.0)));
            com.itextpdf.text.pdf.ColumnText.showTextAligned(stamp.getUnderContent(),1,phrase,(rect.getLeft()+rect.getRight())/2,rect.getBottom()+26,0);
	       
	        // page count
	        phrase = com.itextpdf.text.Phrase.getInstance(0,String.format("%d/%d",i,totalPageCount),com.itextpdf.text.FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)10*fontSizePercentage/100.0)));
            com.itextpdf.text.pdf.ColumnText.showTextAligned(stamp.getUnderContent(),1,phrase,(rect.getLeft()+rect.getRight())/2,rect.getBottom()+18,0);        
	   
	        stamp.alterContents();	
	        copy.addPage(pdfPage);
	    }
	
	    document.close();  
	    reader.close();
	    
	    return newBaos;
    }    
%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sSection1  = checkString(request.getParameter("section_1")),
           sSection2  = checkString(request.getParameter("section_2")),
           sSection3  = checkString(request.getParameter("section_3")),
           sSection4  = checkString(request.getParameter("section_4")),
           sSection5  = checkString(request.getParameter("section_5")),
           sSection6  = checkString(request.getParameter("section_6")),
           sSection7  = checkString(request.getParameter("section_7")),
           sSection8  = checkString(request.getParameter("section_8")),
           sSection9  = checkString(request.getParameter("section_9")),
           sSection10 = checkString(request.getParameter("section_10")),
           sSection11 = checkString(request.getParameter("section_11")),
           sSection12 = checkString(request.getParameter("section_12")),
           sSection13 = checkString(request.getParameter("section_13")),
           sSection14 = checkString(request.getParameter("section_14")),
           sSection15 = checkString(request.getParameter("section_15")),
           sSection16 = checkString(request.getParameter("section_16")),
           sSection17 = checkString(request.getParameter("section_17"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** print/printMedicalDossier.jsp ********************");
        Debug.println("sAction    : "+sAction);
        Debug.println("sSection1  : "+sSection1);       //  1 : Administratie persoonlijk (verplicht) (photo)
        Debug.println("sSection2  : "+sSection2);       //  2 : Foto
        Debug.println("sSection3  : "+sSection3);       //  3 : Administratie priv�
        Debug.println("sSection4  : "+sSection4);       //  4 : Administratie familierelaties
        Debug.println("sSection5  : "+sSection5);       //  5 : Actieve verzekeringsgegevens
        Debug.println("sSection6  : "+sSection6);       //  6 : Historiek verzekeringsgegevens
        Debug.println("sSection7  : "+sSection7);       //  7 : Actieve geneesmiddelen voorschriften
        Debug.println("sSection8  : "+sSection8);       //  8 : Actieve zorgvoorschriften
        Debug.println("sSection9  : "+sSection9);       //  9 : Vaccinaties
        Debug.println("sSection10 : "+sSection10);      // 10 : Probleemlijst
        Debug.println("sSection11 : "+sSection11);      // 11 : Lijst van gestelde diagnoses
        Debug.println("sSection12 : "+sSection12);      // 12 : Actieve afspraken
        Debug.println("sSection13 : "+sSection13);      // 13 : Actief contact 
        Debug.println("sSection14 : "+sSection14);      // 14 : Historiek oudere contacten (mogelijkheid om contacten te selecteren)
        Debug.println("sSection15 : "+sSection15);      // 15 : Waarschuwingen 
        Debug.println("sSection16 : "+sSection16);      // 16 : Onderzoeken (mogelijkheid om onderzoeken te selecteren) 
        Debug.println("sSection17 : "+sSection17+"\n"); // 17 : Handtekening
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    

    //--- PRINT PDF -------------------------------------------------------------------------------
    if(sAction.equals("print")){
        String sPrintLanguage = checkString(request.getParameter("PrintLanguage"));

        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName() );
        sessionContainerWO.verifyPerson(activePatient.personid);
        sessionContainerWO.verifyHealthRecord(null);

        ByteArrayOutputStream origBaos = null;

        try{
            PDFCreator pdfCreator = new MedicalDossierPDFCreator(sessionContainerWO,activeUser,activePatient,sAPPTITLE,sAPPDIR,sPrintLanguage);
            origBaos = pdfCreator.generatePDFDocumentBytes(request,application);
            ByteArrayOutputStream newBaos = addFooterToPdf(origBaos,session);
            
            // prevent caching
            response.setHeader("Expires","Sat, 6 May 1995 12:00:00 GMT");
            response.setHeader("Cache-Control","Cache=0, must-revalidate");
            response.addHeader("Cache-Control","post-check=0, pre-check=0");
            response.setContentType("application/pdf");

            String sFileName = "pdf_"+System.currentTimeMillis()+".pdf";
            response.setHeader("Content-disposition","inline; filename="+sFileName);
            response.setContentLength(newBaos.size());

            ServletOutputStream sos = response.getOutputStream();
            newBaos.writeTo(sos);
            sos.flush();
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            if(origBaos!=null) origBaos.reset();
        }
    }
%>

<form name="printForm" id="printForm" method="post">
    <input type="hidden" name="Action" value="print">
    
    <%=writeTableHeader("web","printMedicalDossier",sWebLanguage)%>

    <%-- SECTIONS -------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1">
        <%-- 1 : administration personal --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_1" id="section_1" value="on" class="hand" onClick="this.checked=true" <%=(sSection1.equals("on")?"CHECKED":"")%>><%=getLabel(request,"web.occup","administrationPersonal",sWebLanguage,"section_1")%>
            </td>
        </tr>
        
        <%-- 2 : photo --%>
        <tr>
            <td class="admin">
		        <%
		            if(Picture.exists(Integer.parseInt(activePatient.personid))){
		           	    %><input type="checkbox" name="section_2" id="section_2" value="on" class="hand" <%=(sSection2.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","photo",sWebLanguage,"section_2")%><%
		            }
		            else{
		                %><input type="checkbox" name="section_2" id="section_2" value="off" DISABLED>&nbsp;<%=getLabel(request,"pdf","photo",sWebLanguage,"section_2")%><%
		            }
		        %>        
            </td>
        </tr>  

        <%-- 3 : administration private --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_3" id="section_3" value="on" class="hand" <%=(sSection3.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","administrationPrivate",sWebLanguage,"section_3")%>
            </td>
        </tr>
                
        <%-- 4 : administration family-relations --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_4" id="section_4" value="on" class="hand" <%=(sSection4.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","administrationFamilyRelation",sWebLanguage,"section_4")%>
            </td>
        </tr> 
         
        <%-- 5 : active insurance data --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_5" id="section_5" value="on" class="hand" <%=(sSection5.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","activeInsuranceData",sWebLanguage,"section_5")%>
            </td>
        </tr>
        
        <%-- 6 : historical insurance data--%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_6" id="section_6" value="on" class="hand" <%=(sSection6.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","historicalInsuranceData",sWebLanguage,"section_6")%>
            </td>
        </tr>
         
        <%-- 7 : active drug prescriptions --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_7" id="section_7" value="on" class="hand" <%=(sSection7.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","activeDrugPrescriptions",sWebLanguage,"section_7")%>
            </td>
        </tr>
         
        <%-- 8 : active care prescriptions --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_8" id="section_8" value="on" class="hand" <%=(sSection8.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","activeCarePrescriptions",sWebLanguage,"section_8")%>
            </td>
        </tr>
         
        <%-- 9 : vaccinations --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_9" id="section_9" value="on" class="hand" <%=(sSection9.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","vaccinations",sWebLanguage,"section_9")%>
            </td>
        </tr>
         
        <%-- 10 : problem list --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_10" id="section_10" value="on" class="hand" <%=(sSection10.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","problemlist",sWebLanguage,"section_10")%>
            </td>
        </tr>
         
        <%-- 11 : active diagnoses --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_11" id="section_11" value="on" class="hand" <%=(sSection11.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","activeDiagnoses",sWebLanguage,"section_11")%>
            </td>
        </tr>
         
        <%-- 12 : active appointments --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_12" id="section_12" value="on" class="hand" <%=(sSection12.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","activeAppointments",sWebLanguage,"section_12")%>
            </td>
        </tr>  
         
        <%-- 13 : active encounter --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_13" id="section_13" value="on" class="hand" <%=(sSection13.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","activeEncounter",sWebLanguage,"section_13")%>
            </td>
        </tr>  
         
        <%-- 14 : encounter history --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_14" id="section_14" value="on" class="hand" <%=(sSection14.equals("on")?"CHECKED":"")%> onClick="toggleEncounterTable(this);">&nbsp;<%=getLabel(request,"pdf","encounterHistroy",sWebLanguage,"section_14")%>
            </td>
        </tr>   
            
        <%
            //************************************************************************************
	        //*** list all historical encounters as options **************************************	 
            //************************************************************************************    
           StringBuffer sOutEnc1 = new StringBuffer(),
            		     sOutEnc2 = new StringBuffer();    
            String sClass = "1";
            int cbCounter = 1;
	        //*** 1 - visits ***
		    Vector visits = (Vector)Encounter.getInactiveEncounters(activePatient.personid,"visit",new java.util.Date());
		    if(visits.size() > 0){
	            sOutEnc1.append("<tbody style='cursor:pointer;'>");

		        // subtitle		         
                sOutEnc1.append("<tr class='admin'>")
	                     .append("<td colspan='7'>&nbsp;&nbsp;"+getTran(request,"web","visits",sWebLanguage)+"</td>")
	                    .append("</tr>");
		        
		        // header
                sOutEnc1.append("<tr height='20'>")
                         .append("<td class='admin' width='30'>&nbsp;</td>")
	                     .append("<td class='admin' width='10%'>"+getTran(request,"web.occup","medwan.common.contacttype",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='10%'>"+getTran(request,"web","begin",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='10%'>"+getTran(request,"web","end",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='10%'>"+getTran(request,"openclinic.chuk","urgency.origin",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='20%'>"+getTran(request,"web","service",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='*'>"+getTran(request,"openclinic.chuk","rfe",sWebLanguage)+"&nbsp;</td>")
                        .append("</tr>");

		        Encounter encounter;
				for(int i=0; i<visits.size(); i++){
			        encounter = (Encounter)visits.get(i);

                    // alternate row-style
                    if(sClass.length()==0) sClass = "1";
                    else                   sClass = "";

					// one visit
                    sOutEnc1.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                             .append("<td align='center'>")
                              .append("<input type='checkbox' value='"+encounter.getUid()+"' name='visitUID_"+cbCounter+"'>")
                             .append("</td>")
                             .append("<td onClick=\"clickCheckBox('visitUID_"+cbCounter+"')\">&nbsp;"+getTran(request,"encountertype",encounter.getType(),sWebLanguage)+"</td>")
                             .append("<td onClick=\"clickCheckBox('visitUID_"+cbCounter+"')\">&nbsp;"+ScreenHelper.formatDate(encounter.getBegin())+"</td>")
                             .append("<td onClick=\"clickCheckBox('visitUID_"+cbCounter+"')\">&nbsp;"+ScreenHelper.formatDate(encounter.getEnd())+"</td>")
                             .append("<td onClick=\"clickCheckBox('visitUID_"+cbCounter+"')\">&nbsp;"+getTran(request,"urgency.origin",encounter.getOrigin(),sWebLanguage)+"</td>")
                             .append("<td onClick=\"clickCheckBox('visitUID_"+cbCounter+"')\">&nbsp;"+(encounter.getService()==null?"":encounter.getService().getLabel(sWebLanguage))+"</td>")
                             .append("<td onClick=\"clickCheckBox('visitUID_"+cbCounter+"')\" style='padding-left:5px;'>"+ReasonForEncounter.getReasonsForEncounterAsText(encounter.getUid(),sWebLanguage).replaceAll("\n","<br>")+"</td>")
                            .append("</tr>");

                    cbCounter++;		
			    }
		        
			    sOutEnc1.append("</tbody>");
		    }
			
			//*** 2 - admissions ***
			Vector admissions = (Vector)Encounter.getInactiveEncounters(activePatient.personid,"admission",new java.util.Date());
			if(admissions.size() > 0){
	            sOutEnc2.append("<tbody style='cursor:pointer;'>");
			    sClass = "1"; // reset
				 
		        // subtitle		         
                sOutEnc2.append("<tr class='admin'>")
	                     .append("<td colspan='7'>&nbsp;&nbsp;"+getTran(request,"web","admissions",sWebLanguage)+"</td>")
	                    .append("</tr>");
		        
		        // header
                sOutEnc2.append("<tr height='20'>")
                         .append("<td class='admin' width='30'>&nbsp;</td>")
 	                     .append("<td class='admin' width='10%'>"+getTran(request,"web.occup","medwan.common.contacttype",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='10%'>"+getTran(request,"web","begin",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='10%'>"+getTran(request,"web","end",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='10%'>"+getTran(request,"openclinic.chuk","urgency.origin",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='20%'>"+getTran(request,"web","service",sWebLanguage)+"&nbsp;</td>")
	                     .append("<td class='admin' width='*'>"+getTran(request,"openclinic.chuk","rfe",sWebLanguage)+"&nbsp;</td>")
                        .append("</tr>");

		        Encounter encounter;
				for(int i=0; i<admissions.size(); i++){
			        encounter = (Encounter)admissions.get(i);
                    // alternate row-style
                    if(sClass.length()==0) sClass = "1";
                    else                   sClass = "";

				    // one admission
                    sOutEnc2.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                             .append("<td align='center'>")
                              .append("<input type='checkbox' value='"+encounter.getUid()+"' name='admissionUID_"+cbCounter+"'>")
                             .append("</td>")
                             .append("<td onClick=\"clickCheckBox('admissionUID_"+cbCounter+"');\">&nbsp;"+getTran(request,"encountertype",encounter.getType(),sWebLanguage)+"</td>")
                             .append("<td onClick=\"clickCheckBox('admissionUID_"+cbCounter+"');\">&nbsp;"+(encounter.getBegin()==null?"":ScreenHelper.formatDate(encounter.getBegin()))+"</td>")
                             .append("<td onClick=\"clickCheckBox('admissionUID_"+cbCounter+"');\">&nbsp;"+(encounter.getEnd()==null?"":ScreenHelper.formatDate(encounter.getEnd()))+"</td>")
                             .append("<td onClick=\"clickCheckBox('admissionUID_"+cbCounter+"');\">&nbsp;"+getTran(request,"urgency.origin",encounter.getOrigin(),sWebLanguage)+"</td>")
                             .append("<td onClick=\"clickCheckBox('admissionUID_"+cbCounter+"');\">&nbsp;"+(encounter.getService()==null?"":encounter.getService().getLabel(sWebLanguage))+"</td>")
                             .append("<td onClick=\"clickCheckBox('admissionUID_"+cbCounter+"');\" style='padding-left:5px;'>"+ReasonForEncounter.getReasonsForEncounterAsText(encounter.getUid(),sWebLanguage).replaceAll("\n","<br>")+"</td>")
                            .append("</tr>");

                    cbCounter++;		
			 	}
		        
				sOutEnc2.append("</tbody>");
		    }
			 
			if(visits.size()==0 && admissions.size()==0){
		        // no records found		    	
                sOutEnc2.append("<tr>")
	                     .append("<td class='admin2' colspan='7'>"+getTran(request,"web","noRecordsFound",sWebLanguage)+"</td>")
	                    .append("</tr>");
			}
        %>      
        
        <tr id="encounterTable" style="display:none">
            <td class="admin">
		        <%-- ENCOUNTER HISTORY --%>
                <table width="100%" cellspacing="1" cellpadding="0" class="list" style="border-bottom:none;">
					<tr class="admin">
					    <td><%=getTran(request,"web","encounters",sWebLanguage)%></td>
					</tr>     
                </table>
                
                <%
	                if(sOutEnc1.length() > 0){
	                    %>
			                <table width="100%" class="sortable" id="tblEncounters1" cellspacing="1" headerRowCount="2" style="background:#fff;border-bottom:none;"> 
					            <%=sOutEnc1%>
					        </table>
		        
						    <%-- UN/CHECK ALL encounters - visits --%>
						    <table width="100%" cellspacing="1">
						        <tr>
						            <td>
						                <a href="javascript:checkAllVisits(true);"><%=getTran(request,"web.manage","CheckAll",sWebLanguage)%></a>
						                <a href="javascript:checkAllVisits(false);"><%=getTran(request,"web.manage","UncheckAll",sWebLanguage)%></a>
						            </td>
						            <td align="right">
						                <a href="#top"><img src="<c:url value='/_img'/>/themes/default/top.gif" class="link"></a>
						            </td>
						        </tr>
						    </table>
					     <%
					}

                    if(sOutEnc2.length() > 0){
                        %>
			                <table width="100%" class="sortable" id="tblEncounters2" cellspacing="1" headerRowCount="2" style="background:#fff"> 
					            <%=sOutEnc2%>
					        </table>
		        
						    <%-- UN/CHECK ALL encounters - admissions --%>
						    <table width="100%" cellspacing="1">
						        <tr>
						            <td>
						                <a href="javascript:checkAllAdmissions(true);"><%=getTran(request,"web.manage","CheckAll",sWebLanguage)%></a>
						                <a href="javascript:checkAllAdmissions(false);"><%=getTran(request,"web.manage","UncheckAll",sWebLanguage)%></a>
						            </td>
						            <td align="right">
						                <a href="#top"><img src="<c:url value='/_img'/>/themes/default/top.gif" class="link"></a>
						            </td>
						        </tr>
						    </table>
					     <%
					}
			    %>
		    </td>
		</tr>
        
        <%-- 15 : warnings
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_15" id="section_15" value="on" <%=(sSection15.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel(request,"pdf","warnings",sWebLanguage,"section_15")%>
            </td>
        </tr>
        --%> 
        <input type="hidden" name="section_15" value="off">
         
        <%-- 16 : examinations --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_16" id="section_16" value="on" <%=(sSection16.equals("on")?"CHECKED":"")%> onClick="toggleTranTable(this);">&nbsp;<%=getLabel(request,"pdf","examinations",sWebLanguage,"section_16")%>
            </td>
        </tr>  
            
        <%
            //************************************************************************************
	        //*** list all saved examination-types as options ************************************
            //************************************************************************************
	        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
	        Collection transactions = sessionContainerWO.getHealthRecordVO().getTransactions();
	        Iterator tranIter = transactions.iterator();
	        Hashtable hTrans = new Hashtable();
	        TransactionVO transaction, newTransaction;
	
	        String sSelectedTranCtxt = "allContexts";
	        StringBuffer sOut = new StringBuffer();
	        cbCounter = 1;
	        sClass = "1";
	        String sList = "1", sTransTranslation;
	        String tranID, serverID, tranType, tranUserName = "", tranCtxt, sExaminationName, sDocType;
	        Timestamp tranDate;
	        ItemVO docTypeItem;
         
            SortedSet set = new TreeSet();

            while(tranIter.hasNext()){
                transaction = (TransactionVO)tranIter.next();
                tranDate = new Timestamp(transaction.getUpdateTime().getTime());

                sTransTranslation = getTran(request,"web.occup",transaction.getTransactionType(),sWebLanguage);
                newTransaction = (TransactionVO)hTrans.get(sTransTranslation);
 
                if(newTransaction==null){
                    hTrans.put(sTransTranslation,transaction);
                    set.add(sTransTranslation);
                }
            }

            // records
            sOut.append("<tbody style='cursor:pointer;'>");

            if(hTrans.size() > 0){    	        
                // header
                sOut.append("<tr height='20'>")
                     .append("<td class='admin' width='30'>&nbsp;</td>")
                     .append("<td class='admin' width='400'>"+getTran(request,"web.occup","medwan.common.contacttype",sWebLanguage)+"</td>")
                     .append("<td class='admin' width='*'>"+getTran(request,"web.occup","medwan.common.context",sWebLanguage)+"</td>")
                    .append("</tr>");
                
                Iterator setIter = set.iterator();

                while(setIter.hasNext()){
                    transaction = (TransactionVO)hTrans.get(setIter.next().toString());
                    tranType = transaction.getTransactionType();

                    // exclude vaccinations and warnings
                    if(!tranType.endsWith("TRANSACTION_TYPE_VACCINATION") && !tranType.endsWith("TRANSACTION_TYPE_ALERT")){
                        transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(),transaction.getTransactionId().intValue());
                        boolean privateInfo = false;
                       
                        if(transaction!=null){
	                        // private info ?
                            ItemVO privateInfoItem = transaction.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_PRIVATE_INFO");
                            if(privateInfoItem!=null){
                                privateInfo = checkString(privateInfoItem.getValue()).equalsIgnoreCase("medwan.common.true");
                            }
                        }

                        if(transaction!=null && !privateInfo){ 
                            // context
                            tranCtxt = "";
                            ItemVO itemVO = transaction.getContextItem();
                            if(itemVO!=null){
                                tranCtxt = itemVO.getValue();
                            }
 
                            //*** what context-modifier ***
                            if(sSelectedTranCtxt.equals("allContexts")){
                                // alternate row-style
                                if(sClass.length()==0) sClass = "1";
                                else                   sClass = "";
 
                                sOut.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran(request,"web.occup",tranType,sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran(request,"web.occup",tranCtxt,sWebLanguage)+"</td>")
                                    .append("</tr>");
 
                                cbCounter++;
                            }
                            else if(sSelectedTranCtxt.equals("withoutContext")){
                                if(tranCtxt.length()==0){
                                    // alternate row-style
                                    if(sClass.length()==0) sClass = "1";
                                    else                   sClass = "";
 
                                    sOut.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                                         .append("<td align='center'>")
                                          .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                         .append("</td>")
                                         .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran(request,"web.occup",tranType,sWebLanguage)+"</td>")
                                         .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran(request,"web.occup",tranCtxt,sWebLanguage)+"</td>")
                                        .append("</tr>");
 
                                    cbCounter++;
                                }
                            }
                            else if(tranCtxt.equalsIgnoreCase(sSelectedTranCtxt)){
                                // alternate row-style
                                if(sClass.length()==0) sClass = "1";
                                else                   sClass = "";
 
                                sOut.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"');\">&nbsp;"+getTran(request,"web.occup",tranType,sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"');\">&nbsp;"+getTran(request,"web.occup",tranCtxt,sWebLanguage)+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                        }
                    }
                }
            }
            else{
		        // no records found		    	
                sOut.append("<tr>")
	                 .append("<td class='admin2' colspan='3'>"+getTran(request,"web","noRecordsFound",sWebLanguage)+"</td>")
	                .append("</tr>");
	        }
        
            sOut.append("</tbody>");
        %>      
        
        <tr id="tranTable" style="display:none">
            <td class="admin">
		        <%-- TRANSACTIONS --%>
                <table width="100%" cellspacing="1" cellpadding="0" class="list" style="border-bottom:none;">
					<tr class="admin">
					    <td><%=getTran(request,"web","examinationTypes",sWebLanguage)%></td>
					</tr>     
                </table>
	                
                <table width="100%" class="sortable" id="tblTransactions" cellspacing="1" style="background:#fff;">
		            <%=sOut%>
		        </table>
		        
			    <%-- UN/CHECK ALL examinationTypes --%>
			    <table width="100%" cellspacing="1">
			        <tr>
			            <td>
			                <a href="javascript:checkAllExaminationTypes(true);"><%=getTran(request,"web.manage","CheckAll",sWebLanguage)%></a>
			                <a href="javascript:checkAllExaminationTypes(false);"><%=getTran(request,"web.manage","UncheckAll",sWebLanguage)%></a>
			            </td>
			            <td align="right">
			                <a href="#top"><img src="<c:url value='/_img'/>/themes/default/top.gif" class="link"></a>
			            </td>
			        </tr>
			    </table>
		    </td>
		</tr>

        <%-- 17 : signature
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_17" id="section_17" value="on" <%=(sSection17.equals("on")?"CHECKED":"")%>><%=getLabel(request,"pdf","signature",sWebLanguage,"section_17")%>
            </td>
        </tr>
        --%> 
        <input type="hidden" name="section_17" value="on">
    </table>
            
    <%-- UN/CHECK ALL --%>
    <table width="100%" cellspacing="1">
        <tr>
            <td>
                <a href="javascript:checkAll(true);"><%=getTran(request,"web.manage","CheckAll",sWebLanguage)%></a>
                <a href="javascript:checkAll(false);"><%=getTran(request,"web.manage","UncheckAll",sWebLanguage)%></a>
            </td>
            <td align="right">
                <a href="#top"><img src="<c:url value='/_img'/>/themes/default/top.gif" class="link"></a>
            </td>
        </tr>
    </table>

    <%=ScreenHelper.alignButtonsStart()%>
        <%-- LANGUAGE SELECTOR --%>
        <select class="text" name="PrintLanguage">
            <%
               String sPrintLanguage = activePatient.language;
            
                // supported languages
                String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
                if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
                supportedLanguages = supportedLanguages.toLowerCase();
      
                // print language selector
                StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
                String tmpLang;
                while(tokenizer.hasMoreTokens()){
                    tmpLang = tokenizer.nextToken();
                    tmpLang = tmpLang.toUpperCase();

                    %><option value="<%=tmpLang%>" <%=(sPrintLanguage.equalsIgnoreCase(tmpLang)?"selected":"")%>><%=tmpLang%></option><%
                }
            %>
        </select>                                                              
    
        <%-- BUTTONS --%>
        <input class="button" type="button" name="printButton" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onClick="doPrint();">&nbsp;
        <input class="button" type="button" name="resetButton" value="<%=getTranNoLink("web","reset",sWebLanguage)%>" onclick="doReset();">&nbsp;
        <input class="button" type="button" name="backButton"  value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>
</form>

<%-- SCRIPTS --------------------------------------------------------------------%>
<script>
  checkAll(true);

  <%-- CHECK ALL --%>
  function checkAll(setchecked){
	var cbCount = 0;
	
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
    	cbCount++; // skip first section
    	
    	if(cbCount > 1){
          if(printForm.elements[i].name.startsWith("section")){
            printForm.elements[i].checked = setchecked;
          }
    	}
      }
    }

    document.getElementById("section_1").checked = true;

    <%
        // only show photo-option when a photo exists in this dossier
        if(!Picture.exists(Integer.parseInt(activePatient.personid))){
        	%>document.getElementById("section_2").checked = false;<%
        }
    %>

    toggleEncounterTable(document.getElementById("section_14"));
    toggleTranTable(document.getElementById("section_16"));
  }

  <%-- CHECK ALL VISITS --%>
  function checkAllVisits(setchecked){	
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        if(printForm.elements[i].name.startsWith("visitUID_")){
          printForm.elements[i].checked = setchecked;
        }
      }
    }
  }
  
  <%-- CHECK ALL ADMISSIONS --%>
  function checkAllAdmissions(setchecked){	
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        if(printForm.elements[i].name.startsWith("admissionUID_")){
          printForm.elements[i].checked = setchecked;
        }
      }
    }
  }
  
  <%-- CHECK ALL EXAMINATION TYPES --%>
  function checkAllExaminationTypes(setchecked){	
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        if(printForm.elements[i].name.startsWith("tranType_")){
          printForm.elements[i].checked = setchecked;
        }
      }
    }
  }

  <%-- DO PRINT --%>
  function doPrint(){
	var okToPrint = true;
	
	if(okToPrint==true){
      if(document.getElementById("section_14").checked==true && <%=visits.size()+admissions.size()>0%> && countSelectedEncounters()==0){
	    alertDialog("web","firstSelectSomeEncounters");
	    okToPrint = false;
      }
	}

	if(okToPrint==true){
	  if(document.getElementById("section_16").checked==true && countSelectedTransactions()==0){
	    alertDialog("web","firstSelectSomeTransactionTypes");
	    okToPrint = false;
	  }
	}
		
	if(okToPrint==true){
      printForm.Action.value = "print";
      printForm.target = "_new";
      printForm.action = "<c:url value='print/printMedicalDossier.jsp'/>?ts=<%=getTs()%>";
      printForm.submit();
	}
  }
  
  <%-- TOGGLE ENCOUNTER TABLE --%>
  function toggleEncounterTable(checkbox){
    if(checkbox.checked){
      document.getElementById("encounterTable").style.display = "table-row";
      checkAllEncounters(true);
    }
    else{
      document.getElementById("encounterTable").style.display = "none";
      checkAllEncounters(false);
    }
  }
  
  <%-- TOGGLE TRAN TABLE --%>
  function toggleTranTable(checkbox){
    if(checkbox.checked){
      document.getElementById("tranTable").style.display = "table-row";
      checkAllTransactions(true);
    }
    else{
      document.getElementById("tranTable").style.display = "none";
      checkAllTransactions(false);
    }
  }

  <%-- CHECK ALL ENCOUNTERS --%>
  function checkAllEncounters(checkedOrNot){
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        if(printForm.elements[i].name.startsWith("visitUID_") || printForm.elements[i].name.startsWith("admissionUID_")){
          printForm.elements[i].checked = checkedOrNot;
        }
      }
    }
  }
  
  <%-- CHECK ALL TRANSACTIONS --%>
  function checkAllTransactions(checkedOrNot){
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        if(printForm.elements[i].name.startsWith("tranType_")){
          printForm.elements[i].checked = checkedOrNot;
        }
      }
    }
  }
    
  <%-- CLICK CHECKBOX --%>
  function clickCheckBox(cbName){
    var cb = eval("printForm."+cbName);
    cb.checked = !cb.checked
  }

  <%-- COUNT SELECTED ENCOUNTERS --%>
  function countSelectedEncounters(){
	var count = 0;
	
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        if(printForm.elements[i].name.startsWith("visitUID_") || printForm.elements[i].name.startsWith("admissionUID_")){
          if(printForm.elements[i].checked==true){	
            count++;
          }
        }
      }
    }
    
    return count;
  }
  
  <%-- COUNT SELECTED TRANSACTIONS --%>
  function countSelectedTransactions(){
    var count = 0;
	
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        if(printForm.elements[i].name.startsWith("tranType_")){
          if(printForm.elements[i].checked==true){	
            count++;
          }
        }
      }
    }
    
    return count;
  }
  
  <%-- DO RESET --%>
  function doReset(){
    printForm.reset();
    checkAll(true);
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='main.jsp?Page=curative/index.jsp'/>"+
                           "&ts=<%=getTs()%>";
  }
</script>