<%@page import="java.util.*,
                be.openclinic.adt.Encounter,
                java.text.DecimalFormat,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.finance.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- ADD UNASSIGNED CREDITS ------------------------------------------------------------------
    private String addUnassignedCredits(Vector vCredits, String sWebLanguage, User activeUser){
        DecimalFormat priceFormat = new DecimalFormat("#,##0.00"),
        	          deciLong    = new DecimalFormat("###,###,###,###");
        String sHtml = "", sClass = "";

        if(vCredits != null){
            PatientCredit credit;
            Encounter encounter;
            String sEncounterName, sCreditUid, sCreditType, sCreditCategory;
            Hashtable hSort = new Hashtable();
            String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","�");
            
            for(int i=0; i<vCredits.size(); i++){
                sCreditUid = checkString((String)vCredits.elementAt(i));

                if(sCreditUid.length() > 0){
                    credit = PatientCredit.get(sCreditUid);

                    if(credit!=null){
                        // type
                        if(credit.getType()!=null && checkString(credit.getType()).length() > 0){
                            sCreditType = getTranNoLink("credit.type",credit.getType(),sWebLanguage);
                        }
                        else{
                            sCreditType = "";
                        }

                        // get encounter
                        sEncounterName = "";
                        if(credit.getEncounterUid()!=null && checkString(credit.getEncounterUid()).length() > 0){
                            encounter = credit.getEncounter();
                            if(encounter!=null){
                                sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
                            }
                        }
                        
                        String invoiceref = "-";
                        if(credit.getInvoiceUid()!=null && ScreenHelper.checkString(credit.getInvoiceUid()).length() > 0 && !ScreenHelper.checkString(credit.getInvoiceUid()).equalsIgnoreCase("0")) {
                            PatientInvoice invoice = PatientInvoice.get(credit.getInvoiceUid());
                            if(invoice!=null && invoice.getUid()!=null){
                                invoiceref = invoice.getUid().split("\\.")[1]+" ("+deciLong.format(-invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")";
                            }
                        }
                        
                        String wicketUid = "", wicketName = "";
                        WicketCredit wicketCredit = WicketCredit.getByReferenceUid(credit.getUid(),"PatientCredit");
                        if(wicketCredit!=null && wicketCredit.getUid()!=null && wicketCredit.getUid().length()>1){
                            wicketUid = wicketCredit.getWicketUID();
                            Wicket wicket = Wicket.get(wicketUid);
                            if(wicket!=null && wicket.getService()!=null){
                            	wicketName = checkString(wicket.getService().getLabel(sWebLanguage));
                            }
                        }

                        hSort.put(credit.getDate().getTime()+"="+credit.getUid(),
                        		   (!credit.getType().equalsIgnoreCase("reduction") || activeUser.getAccessRight("financial.invoicereduction.select")?
                                   " onclick=\"selectCredit('"+credit.getUid()+"','"+ScreenHelper.formatDate(credit.getDate())+"','"+credit.getAmount()+"','"+credit.getType()+"','"+credit.getEncounterUid()+"','"+HTMLEntities.htmlentities(sEncounterName)+"','"+HTMLEntities.htmlentities(ScreenHelper.checkString(credit.getComment()).replaceAll("'","�").replaceAll("\r\n","<br>"))+"','"+checkString(credit.getInvoiceUid())+"','"+wicketUid+"','"+checkString(credit.getCurrency())+"','"+checkString(credit.getCategory())+"');\">":
                                   " onclick='alert(\""+ScreenHelper.getTranNoLink("web","nopermission",sWebLanguage)+"\")'>")+
                                   "<td><b>"+credit.getUid().split("\\.")[1]+"</b>&nbsp;</td>"+
                                   "<td>"+ScreenHelper.formatDate(credit.getDate())+"</td>"+
                                   "<td>"+HTMLEntities.htmlentities(sEncounterName)+"</td>"+
                                   "<td align='right'>"+HTMLEntities.htmlentities(priceFormat.format(credit.getAmount()))+"&nbsp;"+sCurrency+"&nbsp;&nbsp;</td>"+
                                   "<td>"+HTMLEntities.htmlentities(sCreditType)+"</td>"+
                                   "<td>"+HTMLEntities.htmlentities(invoiceref)+"</td>"+
                                   "<td>"+HTMLEntities.htmlentities(ScreenHelper.checkString(credit.getComment()).replaceAll("'","�").replaceAll("\r\n","<br>"))+"</td>"+
                                   "<td>"+HTMLEntities.htmlentities(wicketName)+"</td>"+
                                  "</tr>"
                        );

                    }
                }
            }

            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            Iterator iter = keys.iterator();

            while(iter.hasNext()){
                // alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                sHtml+= "<tr class='list"+sClass+"' "+hSort.get(iter.next());
            }
        }

        return sHtml;
    }
%>

<%
    String sEncounterUID = ScreenHelper.checkString(request.getParameter("encounterUID"));

    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd   = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** financial/getEncounterCredits.jsp ****************");
    	Debug.println("sEncounterUID  : "+sEncounterUID);
    	Debug.println("sFindDateBegin : "+sFindDateBegin);
    	Debug.println("sFindDateEnd   : "+sFindDateEnd);
    	Debug.println("sFindAmountMin : "+sFindAmountMin);
    	Debug.println("sFindAmountMax : "+sFindAmountMax+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    Vector vCredits = new Vector();
    if(sEncounterUID.length() > 0){
        if(sFindDateBegin.length()==0 && sFindDateEnd.length()==0 && sFindAmountMin.length()==0 && sFindAmountMax.length()==0){
            vCredits = PatientCredit.getEncounterCredits(sEncounterUID);
        }
        else{
            vCredits = PatientCredit.getPatientCredits(activePatient.personid,sFindDateBegin,sFindDateEnd,sFindAmountMin,sFindAmountMax);
        }
    }

    if(vCredits.size() > 0){
        %>
            <table width="100%" class="list" cellspacing="0" style="border:none;">
                <%-- header --%>
                <tr class="admin">
                    <td colspan="8"><%=HTMLEntities.htmlentities(getTran(request,"web","paymentsforencounter",sWebLanguage))+" #"+sEncounterUID%></td>
                </tr>
                <tr>
                    <td class="admin" width="20">#</td>
                    <td class="admin" width="80"><%=HTMLEntities.htmlentities(getTran(request,"web","date",sWebLanguage))%></td>
                    <td class="admin" width="20%"><%=HTMLEntities.htmlentities(getTran(request,"web.finance","encounter",sWebLanguage))%></td>
                    <td class="admin" width="90" align="right"><%=HTMLEntities.htmlentities(getTran(request,"web","amount",sWebLanguage))%>&nbsp;&nbsp;</td>
                    <td class="admin" width="160"><%=HTMLEntities.htmlentities(getTran(request,"web","type",sWebLanguage))%></td>
                    <td class="admin" width="160"><%=HTMLEntities.htmlentities(getTran(request,"web","invoice",sWebLanguage))%></td>
                    <td class="admin" width="*"><%=HTMLEntities.htmlentities(getTran(request,"web","description",sWebLanguage))%></td>
                    <td class="admin" width="120"><%=HTMLEntities.htmlentities(getTran(request,"web","wicket",sWebLanguage))%></td>
                </tr>

                <tbody class="hand">
                    <%=addUnassignedCredits(vCredits,sWebLanguage,activeUser)%>
                </tbody>
            </table>
        <%
    }
    else{
        %><%=HTMLEntities.htmlentities(getTranNoLink("web","noRecordsFound",sWebLanguage))%><%
    }
%>