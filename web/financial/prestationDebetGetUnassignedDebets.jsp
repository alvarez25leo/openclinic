<%@ page import="java.util.*,be.openclinic.finance.*,be.openclinic.adt.Encounter,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private String addDebets(Vector vDebets, String sClass, String sWebLanguage) {
        String sReturn = "";

        if (vDebets != null) {
            PrestationDebet debet;
            Encounter encounter=null;
            Prestation prestation=null;	
            String sEncounterName, sPrestationDescription, sDebetUID, sPatientName;
            String sCredited;
            Hashtable hSort = new Hashtable();

            for (int i = 0; i < vDebets.size(); i++) {
                sDebetUID = checkString((String) vDebets.elementAt(i));

                if (sDebetUID.length() > 0) {
                    debet = PrestationDebet.get(sDebetUID);

                    if (debet != null) {
                        sEncounterName = "";
                        sPatientName = "";

                        if (checkString(debet.getEncounterUid()).length() > 0) {
                            encounter = debet.getEncounter();

                            if (encounter != null) {
                                sEncounterName = getTran(null,"web","insurance.coverage",sWebLanguage);
                                sPatientName = ScreenHelper.getFullPersonName(encounter.getPatientUID());
                             }
                        }

                        sPrestationDescription = "";

                        if (checkString(debet.getPrestationUid()).length() > 0) {
                            prestation = debet.getPrestation();

                            if (prestation != null) {
                                sPrestationDescription = checkString(prestation.getDescription());
                            }
                        }

                        sCredited = "";

                        if (debet.getCredited() > 0) {
                            sCredited = getTran(null,"web.occup", "medwan.common.yes", sWebLanguage);
                        }
                        hSort.put(sPatientName.toUpperCase() + "=" + debet.getDate().getTime() + "=" + debet.getUid(), " onclick=\"setDebet('" + debet.getUid() + "');\">"
                                + "<td>" + ScreenHelper.getSQLDate(debet.getDate()) + "</td>"
                                + "<td>" + HTMLEntities.htmlentities(sEncounterName) + " ("+MedwanQuery.getInstance().getUser(debet.getUpdateUser()).getPersonVO().getFullName()+")</td>"
                                + "<td nowrap>" + debet.getQuantity()+" x "+HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                + "<td>" + debet.getTotalAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "�") + "</td>"
                                + "<td>" + debet.getInsurarAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "�") + "</td>"
                                + "<td>" + sCredited + "</td>"
                                + "</tr>");
                    }
                }
            }

            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            Iterator it = keys.iterator();

            while (it.hasNext()) {
                if (sClass.equals("")) {
                    sClass = "1";
                } else {
                    sClass = "";
                }
                sReturn += "<tr class='list" + sClass
                        + "' " + hSort.get((String) it.next());
            }
        }
        return sReturn;
    }
%>
<table width="100%" cellspacing="0">
    <tr class="admin">
        <td><%=HTMLEntities.htmlentities(getTran(request,"web","date",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web.finance","encounter",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web","prestation",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web","totalamount",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web","amounttoreimburse",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web","canceled",sWebLanguage))%></td>
    </tr>
    <tbody class="hand">
<%
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));

    Vector vUnassignedDebets;
    if ((sFindDateBegin.length()==0)&&(sFindDateEnd.length()==0)&&(sFindAmountMin.length()==0)&&(sFindAmountMax.length()==0)){
        vUnassignedDebets = PrestationDebet.getUnassignedPatientDebets(activePatient.personid);
    }
    else {
        vUnassignedDebets = PrestationDebet.getPatientDebets(activePatient.personid,sFindDateBegin,sFindDateEnd,sFindAmountMin, sFindAmountMax);
    }
	String s=addDebets(vUnassignedDebets, "", sWebLanguage);
    out.print(s);
%>
    </tbody>
</table>