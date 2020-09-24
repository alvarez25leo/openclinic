<%@ page import="java.util.*,be.openclinic.finance.InsurarInvoice,be.openclinic.finance.Insurar,be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.text.DecimalFormat" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#,##0.00"));
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "�");
    Vector vOpenInsurarInvoices = InsurarInvoice.getInsurarInvoicesWhereDifferentStatus("'closed','canceled'");
    String sInsurar;
    long year=MedwanQuery.getInstance().getConfigInt("limitDaysForOpenInsurarInvoices",365)*24*3600;
    year=year*1000;
    StringBuffer sReturn=new StringBuffer();
    Hashtable hSort = new Hashtable();
    InsurarInvoice insurarInvoice;
    Insurar insurar;
    boolean bTooManyOpenInvoices=false;

    for (int i = 0; i < vOpenInsurarInvoices.size(); i++) {
        insurarInvoice = (InsurarInvoice) vOpenInsurarInvoices.elementAt(i);

        if (insurarInvoice != null) {
            sInsurar = "";
            if (checkString(insurarInvoice.getInsurarUid()).length() > 0) {
                insurar = Insurar.get(insurarInvoice.getInsurarUid());

                if (insurar != null) {
                    sInsurar = checkString(insurar.getName());
                }
            }
            hSort.put(insurarInvoice.getDate().getTime() + "=" + insurarInvoice.getUid(), " onclick=\"setInsurarInvoice('" + insurarInvoice.getInvoiceUid() + "');\">"
                    + "<td>" + ScreenHelper.getSQLDate(insurarInvoice.getDate()) + "</td>"
                    + "<td>" + insurarInvoice.getInvoiceUid() + "</td>"
                    + "<td style='text-align:right;'>" + priceFormat.format(insurarInvoice.getBalance()) + "&nbsp;</td>"
                    + "<td>" + HTMLEntities.htmlentities(sInsurar) + "</td>"
                    + "<td>" + getTran(request,"finance.patientinvoice.status", insurarInvoice.getStatus(), sWebLanguage) + "</td></tr>");
        }
        if(i>MedwanQuery.getInstance().getConfigInt("limitNumberOpenInsurarInvoices",999999) || new java.util.Date().getTime()-insurarInvoice.getDate().getTime()>year){
        	bTooManyOpenInvoices=true;
        	break;
        }
    }

    Vector keys = new Vector(hSort.keySet());
    Collections.sort(keys);
    Collections.reverse(keys);
    Iterator it = keys.iterator();
    String sClass = "";
    while (it.hasNext()) {
        if (sClass.equals("")) {
            sClass = "1";
        } else {
            sClass = "";
        }
        sReturn.append("<tr class='list" + sClass
                + "' " + hSort.get(it.next()));
    }
    if(bTooManyOpenInvoices){
    	sReturn.append("<tr><td class='red' colspan='5'>"+getTranNoLink("web","toomanyopeninsurarinvoices",sWebLanguage)+"</td></tr>");
    }

%>
<table width="100%" cellspacing="0">
    <tr class="admin">
        <td width="80" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","date",sWebLanguage))%></td>
        <td width="120" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","invoicenumber",sWebLanguage))%></td>
        <td width="150" nowrap style="text-align:right;"><%=HTMLEntities.htmlentities(getTran(request,"web","balance",sWebLanguage))%>&nbsp;<%=sCurrency%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"medical.accident","insurancecompany",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"Web.finance","patientinvoice.status",sWebLanguage))%></td>
    </tr>
    <tbody class="hand">
        <%=sReturn.toString()%>
    </tbody>
</table>