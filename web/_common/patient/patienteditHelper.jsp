<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!

	private String inputRow(String sLabelType, String sLabelID, String sFieldName, String sTab, String sValue,
	        String sTypeContent, boolean bEditable, boolean bUpperCase, String sWebLanguage){
		return inputRow(null, sLabelType, sLabelID, sFieldName, sTab, sValue, sTypeContent, bEditable, bUpperCase, sWebLanguage);
	}
	private String inputRow(HttpServletRequest request,String sLabelType, String sLabelID, String sFieldName, String sTab, String sValue,
            String sTypeContent, boolean bEditable, boolean bUpperCase, String sWebLanguage){
		return inputRowOpen(request,sLabelType, sLabelID, sFieldName, sTab, sValue,
                sTypeContent, bEditable, bUpperCase, sWebLanguage) + "</td></tr>";
	}

    //--- INPUT ROW -------------------------------------------------------------------------------
    private String inputRowOpen(String sLabelType, String sLabelID, String sFieldName, String sTab, String sValue,
                            String sTypeContent, boolean bEditable, boolean bUpperCase, String sWebLanguage) {
		return inputRowOpen(null, sLabelType, sLabelID, sFieldName, sTab, sValue, sTypeContent, bEditable, bUpperCase, sWebLanguage);
    }
    
    private String inputRowOpen(HttpServletRequest request, String sLabelType, String sLabelID, String sFieldName, String sTab, String sValue,
                            String sTypeContent, boolean bEditable, boolean bUpperCase, String sWebLanguage) {
        String sReturn = normalRow(request, sLabelType,sLabelID,sFieldName,sTab,sWebLanguage);

        if(sTypeContent.toUpperCase().equals("T")){
            sReturn+= "<input class='text' type='text' name='"+sFieldName+"' id='"+sFieldName+"' value=\""+sValue.trim()+"\" size='"+sTextWidth+"' onKeyUp='denySpecialCharacters(this,false);limitLength(this,125);'";
            if(!bEditable){
                sReturn+=" readonly ";
            }

            if(bUpperCase){
                sReturn+=" style='text-transform: uppercase' ";
            }
            sReturn += ">";
        }
        else if(sTypeContent.toUpperCase().equals("TA")){
            sReturn+= "<textarea  onKeyup='resizeTextarea(this,10);limitChars(this,5000);' class='text' name='"+sFieldName+"' id='"+sFieldName+"' cols='60'";
            if(!bEditable){
                sReturn+=" readonly ";
            }

            if(bUpperCase){
                sReturn+=" style='text-transform: uppercase' ";
            }
            sReturn += ">"+sValue.trim()+"</textarea>";
        }
        else if(sTypeContent.toUpperCase().equals("N")){
            sReturn+= "<input class='text' type='text' name='"+sFieldName+"' id='"+sFieldName+"' value=\""+sValue.trim()+"\" size='"+sTextWidth+"' onKeyUp='limitLength(this,125);'";
            if(!bEditable){
                sReturn+=" readonly ";
            }

            if(bUpperCase){
                sReturn+=" style='text-transform: uppercase' ";
            }
            sReturn += ">";
        }
        else if (sTypeContent.toUpperCase().equals("D")) {
            sReturn += writeDateField(sFieldName,"PatientEditForm",sValue, sWebLanguage);
        }
        // only allow future dates
        else if (sTypeContent.equalsIgnoreCase("Df")) {
            sReturn += ScreenHelper.writeDateField(sFieldName,"PatientEditForm",sValue,false,true,sWebLanguage,sCONTEXTPATH);
        }
        // only allow past dates
        else if (sTypeContent.equalsIgnoreCase("Dp")) {
            sReturn += ScreenHelper.writeDateField(sFieldName,"PatientEditForm",sValue,true,false,sWebLanguage,sCONTEXTPATH);
        }
        else if (sTypeContent.toUpperCase().equals("D-")) {
            sReturn += ScreenHelper.writeDateFieldWithoutToday(sFieldName,"PatientEditForm",sValue, true,true,sWebLanguage,sCONTEXTPATH);
        }
        // only allow future dates
        else if (sTypeContent.equalsIgnoreCase("Df-")) {
            sReturn += ScreenHelper.writeDateFieldWithoutToday(sFieldName,"PatientEditForm",sValue,false,true,sWebLanguage,sCONTEXTPATH);
        }
        // only allow past dates
        else if (sTypeContent.equalsIgnoreCase("Dp-")) {
            sReturn += ScreenHelper.writeDateFieldWithoutToday(sFieldName,"PatientEditForm",sValue,true,false,sWebLanguage,sCONTEXTPATH);
        }
        else if (sTypeContent.toUpperCase().startsWith("S:")) {
        	sReturn += "<select class='text' name='"+sFieldName+"' id='"+sFieldName+"'><option/>";
        	sReturn += ScreenHelper.writeSelect(request, sTypeContent.substring(2), sValue, sWebLanguage);
        	sReturn += "</select>";
        }
        else if (sTypeContent.toUpperCase().equals("B")) {
            sReturn+=("<input class='text' type='text' name='"+sFieldName+"' id='"+sFieldName+"' value=\""+sValue.trim()+"\" size='12' onblur='checkBegin(this, \""+sValue.trim()+"\")'>"
                +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTPATH+"/_img/icons/icon_agenda.png' border='0' ALT='"
                +getTran(null,"Web","Select",sWebLanguage)+"' onclick='gfPop.fPopCalendar(document.getElementsByName(\""+sFieldName+"\")[0]);return false;'>"
                +"&nbsp;<img class='link' src='"+sCONTEXTPATH+"/_img/compose.gif' ALT='"
                +getTran(null,"Web","PutToday",sWebLanguage)+"' onclick=\"getToday("+sFieldName+");\">");
        }

        return sReturn;
    }
 
    //--- NORMAL ROW ------------------------------------------------------------------------------
    private String normalRow(String sLabelType, String sLabelID, String sFieldName, String sTab, String sWebLanguage){
    	return normalRow(null, sLabelType, sLabelID, sFieldName, sTab, sWebLanguage);
    }
    private String normalRow(HttpServletRequest request,String sLabelType, String sLabelID, String sFieldName, String sTab, String sWebLanguage){
        String sObligatoryFields = MedwanQuery.getInstance().getConfigString("ObligatoryFields_"+sTab);
        boolean drawAsterix = false;
        if(sObligatoryFields.toLowerCase().indexOf(sFieldName.toLowerCase()+",")>-1){
            drawAsterix = true;
        }
        return "<tr><td class='admin'>"+getTran(request,sLabelType,sLabelID,sWebLanguage)+(drawAsterix?" *":"")+"</td><td class='admin2'>";
    }

    //--- WRITE COUNTRY ---------------------------------------------------------------------------
    private String writeCountry(String sCode, String sFieldCode, String tab, String sFieldDescription,
    		                    boolean bEditable, String sCodeDescription,String sWebLanguage) {
    	return writeCountry(null, sCode, sFieldCode, tab, sFieldDescription, bEditable, sCodeDescription, sWebLanguage);
    }
    private String writeCountry(HttpServletRequest request,String sCode, String sFieldCode, String tab, String sFieldDescription,
    		                    boolean bEditable, String sCodeDescription,String sWebLanguage) {
        String sdc="";
        if (sCode.trim().length()==0) {
            sdc = "";
        }
        else {
            sdc = getTranNoLink("country",sCode,sWebLanguage);
        }

        String sReturn = ("<input type='hidden' name='"+sFieldCode+"' value='"+sCode+"'>"
            +normalRow(request,"Web",sCodeDescription,sFieldCode,tab,sWebLanguage)
            +"<input class='text' size='"+sTextWidth+"' readonly type='text' name='"+sFieldDescription+"' value='"+sdc+"'");

        if (!bEditable){
          sReturn += " readonly ";
        }

        sReturn += (">&nbsp;"
            +ScreenHelper.writeSearchButton("buttonCountry", "Country", sFieldCode, sFieldDescription, "",sWebLanguage,sCONTEXTPATH)
            +"</td></tr>");

        return sReturn;
    }
%>

<%
    String sServiceSourceID = MedwanQuery.getInstance().getConfigString("PatientEditSourceID");
    String sDefaultCountry = MedwanQuery.getInstance().getConfigString("DefaultCountry");

    if (activePatient==null) {
        activePatient = new AdminPerson();
        activePatient.nativeCountry = sDefaultCountry;
        activePatient.lastname = checkString(request.getParameter("pLastname"));
        activePatient.firstname = checkString(request.getParameter("pFirstname"));
        activePatient.dateOfBirth = checkString(request.getParameter("pDateofbirth"));
        activePatient.setID("archiveFileCode",checkString(request.getParameter("pArchiveCode")));
        activePatient.setID("natreg",checkString(request.getParameter("pNatreg")));
        activePatient.setID("immatnew",checkString(request.getParameter("pImmatnew")));
        AdminPrivateContact apc = new AdminPrivateContact();
        apc.district = checkString(request.getParameter("pDistrict"));

        activePatient.privateContacts.add(apc);

        activePatient.sourceid = sServiceSourceID;
        session.setAttribute("activePatient",activePatient);
    }
%>
<script>
function checkBegin(sObject,sBegin){
  checkDate(sObject);
  var sdate = sObject.value;
  if(sdate.length==10){
    var iDayBegin = sBegin.substring(0,2);
	var iMonthBegin = sBegin.substring(3,5);
	var iYearBegin = sBegin.substring(6,10);
    var iBegin = (iYearBegin+""+iMonthBegin+""+iDayBegin+"")*1;

	var iDayObject = sdate.substring(0,2);
	var iMonthObject = sdate.substring(3,5);
	var iYearObject = sdate.substring(6,10);
    var iObject = (iYearObject+""+iMonthObject+""+iDayObject+"")*1;

    if(iBegin > iObject){
      sObject.value = sBegin;
    }
  }
  else{
    sObject.value = sBegin;
  }
}
</script>