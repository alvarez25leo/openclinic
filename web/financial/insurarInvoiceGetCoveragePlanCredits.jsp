<%@ page import="be.openclinic.finance.InsurarCredit,java.util.Vector,be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	private String addCoveragePlanCredits(Vector vCredits, String sClass, boolean bChecked, String sWebLanguage) {
	    String sReturn = "";
	
	    if (vCredits != null) {
	        String sInsurarCreditUID;
	        InsurarCredit insurarcredit;
	        String sChecked = "";
	        if (bChecked) {
	            sChecked = " checked";
	        }
	
	        for (int i = 0; i < vCredits.size(); i++) {
	            sInsurarCreditUID = checkString((String) vCredits.elementAt(i));
	
	            if (sInsurarCreditUID.length() > 0) {
	                insurarcredit = InsurarCredit.get(sInsurarCreditUID);
	
	                if (insurarcredit != null) {
	                    if (sClass.equals((""))) {
	                        sClass = "1";
	                    } else {
	                        sClass = "";
	                    }
	
	                    sReturn += "<tr class='list" + sClass + "'>"
	                            + "<td><input type='checkbox' name='cbCoveragePlanInvoice" + insurarcredit.getUid() + "=" + insurarcredit.getAmount() + "' onclick='doBalance(this, false)'" + sChecked + "></td>"
	                            + "<td>" + ScreenHelper.getSQLDate(insurarcredit.getDate()) + "</td>"
	                            + "<td>" + HTMLEntities.htmlentities(getTran(null,"credit.type", checkString(insurarcredit.getType()), sWebLanguage)) + "</td>"
	                            + "<td>" + insurarcredit.getAmount() + "</td>"
	                            + "</tr>";
	                }
	            }
	        }
	    }
	    return sReturn;
	}

%>
 <table width="100%" cellspacing="1">
    <tr class="gray">
        <td width="50"/>
        <td width="80"><%=HTMLEntities.htmlentities(getTran(request,"web","date",sWebLanguage))%></td>
        <td width="50%"><%=HTMLEntities.htmlentities(getTran(request,"web","type",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran(request,"web", "amount", sWebLanguage))%></td>
    </tr>
<%
	String sClass = "";
    
	String sEditCoveragePlanInvoiceUID = checkString(request.getParameter("EditCoveragePlanInvoiceUID"));
	CoveragePlanInvoice coveragePlanInvoice = null;
	
	if (sEditCoveragePlanInvoiceUID.length() > 0) {
	    coveragePlanInvoice = CoveragePlanInvoice.get(sEditCoveragePlanInvoiceUID);
	    Vector vInsurarCredits = coveragePlanInvoice.getCredits();
	    out.print(addCoveragePlanCredits(vInsurarCredits, sClass, true, sWebLanguage));
	}
	
    if ((coveragePlanInvoice == null) || (!(checkString(coveragePlanInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(coveragePlanInvoice.getStatus()).equalsIgnoreCase("canceled")))) {
        String sInsurarUid = checkString(request.getParameter("InsurarUid"));
        Vector vUnassignedCredits = InsurarCredit.getUnassignedInsurarCredits(sInsurarUid);
        out.print(addCoveragePlanCredits(vUnassignedCredits, sClass, false, sWebLanguage));
    }

%>
</table>