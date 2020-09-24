<%@ page import="be.openclinic.adt.Planning,
                 be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission(out,"planning.user", "select", activeUser)%>

<%!
    private int testItemMargin(List l, Planning a) {
        for (int i = 0; i < l.size(); i++) {
            Planning tempA = (Planning) l.get(i);
            long actualBegin = a.getPlannedDate().getTime();
            long actualEnd = a.getPlannedEndDate().getTime();
            long tempBegin = tempA.getPlannedDate().getTime();
            long tempEnd = tempA.getPlannedEndDate().getTime();
            if ((actualBegin < tempEnd && actualBegin > tempBegin) || (actualEnd > tempBegin && actualEnd < tempEnd)) {
                if (a.getMargin() == tempA.getMargin()) {
                    a.setMargin((tempA.getMargin() - 10));
                }
            }
        }
        return a.getMargin();
    }
%>

<%
    String sYear = checkString(request.getParameter("year"));
    String sUserId = checkString(request.getParameter("FindUserUID"));
    String sServiceUid = checkString(request.getParameter("FindServiceUID"));
    boolean bUseServiceUid = checkString(request.getParameter("FindServiceDisplay")).length()==0;
    String sPatientId = checkString(request.getParameter("PatientID"));
    String sMonth = checkString(request.getParameter("month"));
    String sDay = checkString(request.getParameter("day"));
    SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat,
            fullDateFormat = ScreenHelper.fullDateFormat;
    String sBegin = checkString(activeUser.getParameter("PlanningFindFrom"));
    if (sBegin.length() == 0) {
        sBegin = 8 + "";
    }
    String sEnd = checkString(activeUser.getParameter("PlanningFindUntil"));
    if (sEnd.length() == 0) {
        sEnd = 20 + "";
    }
    Date startOfWeek = ScreenHelper.parseDate(sDay + "/" + sMonth + "/" + sYear);
    long week=604800000;
    Date endOfWeek = new Date(startOfWeek.getTime()+week);
    // display all registered appointments for the active User
    StringBuffer sHtml = new StringBuffer();
    String appointmentDate, visitDate;
    Planning appointment;
    String sUserName, sOnClick;
    String sTranViewDossier = getTranNoLink("web", "viewDossier", sWebLanguage);
    List userAppointments = new LinkedList();
    boolean bPatientAgenda = false;
    if(bUseServiceUid){
        userAppointments = Planning.getServicePlannings(sServiceUid, startOfWeek, endOfWeek);
        session.setAttribute("activePlanningServiceUid", sServiceUid);
    }
    else if (sUserId.length() > 0 && sPatientId.length() <= 0) {
        userAppointments = Planning.getUserPlannings(sUserId, startOfWeek, endOfWeek);
    } else if (sPatientId.length() > 0) {
        if(sUserId.trim().equals("-1")){
            sUserId = "";
        }
        userAppointments = Planning.getPatientPlannings(sPatientId,"", startOfWeek, endOfWeek);
        bPatientAgenda=true;
    }
    for (int i = 0; i < userAppointments.size(); i++) {
        appointment = (Planning) userAppointments.get(i);
        // margin left
        appointment.setMargin(0);

        //If hidden appointment
        String hidden = "";
        Date plannedStart=appointment.getPlannedDate();
        Date plannedEnd=appointment.getPlannedEndDate();

        int startHourOfWeekPlanner = Double.valueOf(Math.floor(Float.parseFloat(sBegin.replace(",",".")))).intValue();    // Start hour of week planner
		
        if (Integer.parseInt(new SimpleDateFormat("HH").format(plannedStart)) < startHourOfWeekPlanner || (Integer.parseInt(new SimpleDateFormat("HH").format(plannedEnd)) > (Float.parseFloat(sEnd.replace(",",".")) + 1) || ((Integer.parseInt(new SimpleDateFormat("HH").format(plannedEnd)) == (Float.parseFloat(sEnd) + 1)) && Integer.parseInt(new SimpleDateFormat("mm").format(plannedEnd)) > 0))) {
            hidden = fullDateFormat.format(plannedStart.getTime()) + " -> " + fullDateFormat.format(plannedEnd.getTime());
        }
        // user names
        sUserName = appointment.getUserUID();
        if (appointment.getUserUID().length() > 0) {
            sUserName += " <b>&</b> " + appointment.getUserUID();
        }
        // display one appointment
        sHtml.append(">");
         sHtml.append(">");
        String sToDisplay = "<ul>";
        if (!appointment.getPatientUID().equals("")) {
        	if(bPatientAgenda ){
        		sToDisplay += "<li><span class='info "+(appointment.getConfirmationDate()!=null?"personwhite":"person")+"'>" + ((appointment.getUser()!=null)?HTMLEntities.htmlentities(appointment.getUser().lastname + " " + appointment.getUser().firstname):"") + "</li>";
        	}
        	else{
        		sToDisplay += "<li><span class='info "+(appointment.getConfirmationDate()!=null?"personwhite":"person")+"'>" + ((appointment.getPatient()!=null)?HTMLEntities.htmlentities(appointment.getPatient().lastname + " " + appointment.getPatient().firstname):"") + "</li>";
        	}
        }
        else if(appointment.getDescription()!=null && appointment.getDescription().length()>0){
            sToDisplay += "<li><span class='info person'>" + HTMLEntities.htmlentities(appointment.getDescription()) + "</li>";
        }
        if(appointment.getContextID().length()>0){
            sToDisplay+="<li><span class='info'>"+getTran(request,"Web.Occup", appointment.getContextID(), sWebLanguage)+"</li>";
        }
        sToDisplay+="</ul>";
        // appointment info
        sHtml.append("\n\n<item>");
        sHtml.append("\n<id>" + appointment.getUid() + "</id>");
        if(MedwanQuery.getInstance().getConfigInt("enableCalendarServiceTypeColors",0)==1){
			Service service = Service.getService(appointment.getServiceUid());
			if(service!=null && service.code3!=null && service.code3.length()>0){
				sHtml.append("\n<color>" + MedwanQuery.getInstance().getConfigString("serviceTypeColor."+service.code3,"") + "</color>");
			}
			else{
				sHtml.append("\n<color></color>");
			}
        }
		else{
			sHtml.append("\n<color></color>");
		}
        sHtml.append("\n<description>" + sToDisplay + "</description>");
        sHtml.append("\n<eventStartDate>" + new SimpleDateFormat("MMM dd, yyyy HH:mm:ss",new java.util.Locale("en","US")).format(appointment.getPlannedDate()) + "</eventStartDate>");
        sHtml.append("\n<eventEndDate>" + new SimpleDateFormat("MMM dd, yyyy HH:mm:ss",new java.util.Locale("en","US")).format(appointment.getPlannedEndDate()) + "</eventEndDate>");
        sHtml.append("\n<marginleft>" + testItemMargin(userAppointments, appointment) + "</marginleft>");
        sHtml.append("\n<hidden>" + hidden + "</hidden>");
        sHtml.append("\n<provisional>" + ((appointment.getConfirmationDate()!=null)?"1":"") + "</provisional>");
        sHtml.append("\n<effective>" + ((appointment.getEffectiveDate()!=null)?"1":"") + "</effective>");
        sHtml.append("\n<noshow>" + checkString(appointment.getNoshow()) + "</noshow>");
        sHtml.append("\n</item>");
    }
    out.print(sHtml);%>




