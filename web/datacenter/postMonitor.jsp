<%@page import="be.openclinic.system.SystemInfo"%>
<%@include file="/includes/helper.jsp"%>
<%@page import="be.mxs.common.util.system.*"%>
<%!
	String notNull(String value, String defaultValue){
		if(value==null || value.length()==0){
			return defaultValue;
		}
		else{
			return value;
		}
	}
%>
<%
	String msg="";
	String centerUid = notNull(request.getParameter("centerUid"),"");
	Debug.println("Receiving ping from "+centerUid);
	String centerName = HTMLEntities.unhtmlentities(notNull(request.getParameter("centerName"),notNull(request.getHeader("X-Forwarded-For"),request.getRemoteAddr())));
	String centerCountry = notNull(request.getParameter("centerCountry"),"");
	String centerCity = HTMLEntities.unhtmlentities(notNull(request.getParameter("centerCity"),""));
	String centerEmail = notNull(request.getParameter("centerEmail"),"");
	String centerContact = HTMLEntities.unhtmlentities(notNull(request.getParameter("centerContact"),""));
	String centerType = notNull(request.getParameter("centerType"),"");
	String centerLevel = notNull(request.getParameter("centerLevel"),"");
	String centerBeds = notNull(request.getParameter("centerBeds"),"");
	String softwareVersion = notNull(request.getParameter("softwareVersion"),"");
	java.util.Date date = new SimpleDateFormat("yyyyMMdd").parse(notNull(request.getParameter("date"),"19000101"));
	int patientCount = Integer.parseInt(notNull(request.getParameter("patientCount"),"0"));
	int visitCount = Integer.parseInt(notNull(request.getParameter("visitCount"),"0"));
	int admissionCount = Integer.parseInt(notNull(request.getParameter("admissionCount"),"0"));
	int transactionCount = Integer.parseInt(notNull(request.getParameter("transactionCount"),"0"));
	int labAnalysisCount = Integer.parseInt(notNull(request.getParameter("labAnalysisCount"),"0"));
	int patientInvoiceCount = Integer.parseInt(notNull(request.getParameter("patientInvoiceCount"),"0"));
	int debetCount = Integer.parseInt(notNull(request.getParameter("debetCount"),"0"));
	
	String messageType = notNull(request.getParameter("messageType"),"");
	Debug.println("Message type = *"+messageType+"*");
	if(messageType.equalsIgnoreCase("systeminfo")){
		Debug.println("Storing system info");
		//systeminfo messageType
		SystemInfo systemInfo = new SystemInfo();
		systemInfo.setVpnDomain(notNull(request.getParameter("vpnDomain"),"?"));
		systemInfo.setVpnAddress(notNull(request.getParameter("vpnAddress"),"?"));
		systemInfo.setVpnName(notNull(request.getParameter("vpnName"),"?"));
		systemInfo.setVpnPort(notNull(request.getParameter("vpnPort"),"80"));
		systemInfo.setUpTime(notNull(request.getParameter("upTime"),"-1"));
		systemInfo.setDiskSpace(notNull(request.getParameter("diskSpace"),""));
		systemInfo.setUsersConnected(notNull(request.getParameter("usersConnected"),""));
		systemInfo.setOpenclinicVersion(notNull(request.getParameter("usersConnected"),"0"));
		Debug.println("Opening db connection");
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		String sSql = "select * from dc_monitorparameters where dc_monitorparameter_serveruid=? and dc_monitorparameter_parameter='systeminfo' and DC_MONITORPARAMETER_VALUE not like '%"+request.getParameter("vpnName")+"%'";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setString(1,centerUid);
		ResultSet rs = ps.executeQuery();
		if(rs.next()){
			System.out.println("Duplicate record detected! ["+centerUid+"]");
			msg="<DUPLICATE>";
		}
		rs.close();
		ps.close();
		sSql="delete from dc_monitorparameters where dc_monitorparameter_serveruid=? and dc_monitorparameter_parameter='systeminfo'";
		ps = conn.prepareStatement(sSql);
		ps.setString(1,centerUid);
		ps.execute();
		ps.close();
		java.sql.Timestamp updatetime = new java.sql.Timestamp(new java.util.Date().getTime());
		sSql="insert into dc_monitorparameters(DC_MONITORPARAMETER_SERVERUID,DC_MONITORPARAMETER_UPDATETIME,DC_MONITORPARAMETER_PARAMETER,DC_MONITORPARAMETER_VALUE) values(?,?,'systeminfo',?)";
		ps = conn.prepareStatement(sSql);
		ps.setString(1,centerUid);
		ps.setTimestamp(2,updatetime);
		ps.setString(3,systemInfo.serialize());
		ps.execute();
		ps.close();
		conn.close();
	}
	else if(centerUid.length()>0){
		System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>> SoftwareVersion="+softwareVersion);
		try{
			//First update/create server data
			int serverid=0;
			String oldCenterCountry="",oldCenterCity="";
			Connection conn = MedwanQuery.getInstance().getStatsConnection();
			String sSql="select * from dc_monitorservers where dc_monitorserver_serveruid=?";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setString(1,centerUid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				serverid=rs.getInt("dc_monitorserver_serverid");
				oldCenterCountry=notNull(rs.getString("dc_monitorserver_country"),"");
				oldCenterCity=notNull(rs.getString("dc_monitorserver_city"),"");
				//Update existing data
				rs.close();
				ps.close();
				sSql="update dc_monitorservers set dc_monitorserver_name=?,dc_monitorserver_country=?,dc_monitorserver_city=?,dc_monitorserver_contact=?,dc_monitorserver_email=?,dc_monitorserver_type=?,dc_monitorserver_level=?,dc_monitorserver_beds=?,dc_monitorserver_updatetime=?,dc_monitorserver_softwareversion=? where dc_monitorserver_serveruid=?";
				ps=conn.prepareStatement(sSql);
				ps.setString(1,centerName);
				ps.setString(2,centerCountry.length()>0?centerCountry.toUpperCase():oldCenterCountry.toUpperCase());
				ps.setString(3,centerCity.length()>0?centerCity.toUpperCase():oldCenterCity.toUpperCase());
				ps.setString(4,centerContact);
				ps.setString(5,centerEmail);
				ps.setString(6,centerType);
				ps.setString(7,centerLevel);
				ps.setString(8,centerBeds);
				ps.setTimestamp(9,new java.sql.Timestamp(new java.util.Date().getTime()));
				ps.setString(10,softwareVersion);
				ps.setString(11,centerUid);
				int n= ps.executeUpdate();
				ps.close();
			}
			else {
				//Create server
				rs.close();
				ps.close();
				sSql="insert into dc_monitorservers(dc_monitorserver_serverid,dc_monitorserver_serveruid,dc_monitorserver_name,dc_monitorserver_country,dc_monitorserver_city,dc_monitorserver_contact,dc_monitorserver_email,dc_monitorserver_type,dc_monitorserver_level,dc_monitorserver_beds,dc_monitorserver_updatetime,dc_monitorserver_softwareversion) values(?,?,?,?,?,?,?,?,?,?,?,?)";
				ps=conn.prepareStatement(sSql);
				serverid=MedwanQuery.getInstance().getOpenclinicCounter("DC_MONITORSERVER_SERVERID");
				ps.setInt(1,serverid);
				ps.setString(2,centerUid);
				ps.setString(3,centerName);
				ps.setString(4,centerCountry.toUpperCase());
				ps.setString(5,centerCity.toUpperCase());
				ps.setString(6,centerContact);
				ps.setString(7,centerEmail);
				ps.setString(8,centerType);
				ps.setString(9,centerLevel);
				ps.setString(10,centerBeds);
				ps.setTimestamp(11,new java.sql.Timestamp(new java.util.Date().getTime()));
				ps.setString(12,softwareVersion);
				ps.execute();
				ps.close();
			}
			//Now insert the received values
			sSql="insert into dc_monitorvalues(dc_monitorvalue_serverid,dc_monitorvalue_date,dc_monitorvalue_patientcount,dc_monitorvalue_visitcount,dc_monitorvalue_admissioncount,dc_monitorvalue_transactioncount,dc_monitorvalue_labanalysescount,dc_monitorvalue_patientinvoicecount,dc_monitorvalue_debetcount,dc_monitorvalue_updatetime) values(?,?,?,?,?,?,?,?,?,?)";
			ps=conn.prepareStatement(sSql);
			ps.setInt(1,serverid);
			ps.setTimestamp(2,new java.sql.Timestamp(date.getTime()));
			ps.setInt(3,patientCount);
			ps.setInt(4,visitCount);
			ps.setInt(5,admissionCount);
			ps.setInt(6,transactionCount);
			ps.setInt(7,labAnalysisCount);
			ps.setInt(8,patientInvoiceCount);
			ps.setInt(9,debetCount);
			ps.setTimestamp(10,new java.sql.Timestamp(new java.util.Date().getTime()));
			ps.execute();
			ps.close();
			
			conn.close();
			msg="<OK>";
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<%=msg%>
