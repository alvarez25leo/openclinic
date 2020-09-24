<%@include file="/includes/validateUser.jsp"%>
<%
    String lastname=checkString(request.getParameter("lastname"));
    String firstname=checkString(request.getParameter("firstname"));
    String dateofbirth=checkString(request.getParameter("dateofbirth"));

    String sQuery="select count(*) as total from Admin where 1=1";
    if(lastname.length()>0){
        sQuery+=" and lastname like '"+lastname+"%'";
    }
    if(firstname.length()>0){
        sQuery+=" and firstname like '"+firstname+"%'";
    }
    if(dateofbirth.length()>0){
        sQuery+=" and dateofbirth = ?";
    }
  	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    PreparedStatement ps = ad_conn.prepareStatement(sQuery);
    if(dateofbirth.length()>0){
        ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(dateofbirth).getTime()));
    }
    ResultSet rs = ps.executeQuery();
    if(rs.next()){
	    if(rs.getInt("total")>0){
	        %>
	        <script>
	        if(window.showModalDialog?yesnoDialog("web","statistics.patientexists"):yesnoDialogDirectText('<%=getTran(null,"web","statistics.patientexists",sWebLanguage)%>')){
	            window.opener.document.getElementsByName('newPatient')[0].value='1';
	            window.opener.document.getElementsByName('EditPatientForm')[0].submit();
	          }
	          window.close();
	        </script>
	        <%
	    }
	    else {
	        out.println("<script>window.opener.document.getElementsByName('newPatient')[0].value='1';window.opener.document.getElementsByName('EditPatientForm')[0].submit();window.close();</script>");
	    }
    }
	rs.close();
	ps.close();
	ad_conn.close();

%>