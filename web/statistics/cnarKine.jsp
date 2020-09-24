<%@page import="sun.print.resources.serviceui"%>
<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"statistics","select",activeUser)%>
<%!
	class Equipment{
		int	male;
		int female;
		int i0to5;
		int i5to15;
		int i15plus;
	}
%><%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	
	java.util.Date dBegin = ScreenHelper.parseDate(begin);
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(end).getTime()+24*3600*1000-1);
	
	
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select gender,dateofbirth,t.updatetime from transactions t,healthrecord h, adminview a where t.healthrecordid=h.healthrecordid and h.personid=a.personid and t.updatetime>=? and t.updatetime<? and t.transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNAR_KINECONSULTATION'";
	SortedMap genderages = new TreeMap();
	int total=0;
	long day = 24*3600*1000;
	long year = 365 * day;
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ResultSet rs = ps.executeQuery();
	SortedMap prestations = new TreeMap();
	while(rs.next()){
		String gender = rs.getString("gender");
		java.util.Date dateofbirth=rs.getDate("dateofbirth");
		java.util.Date encounterdate=rs.getDate("updatetime");
		try{
			int age = new Long((encounterdate.getTime()-dateofbirth.getTime())/year).intValue();
			if(age<5){
				age=0;
			}
			else if (age<15){
				age=5;
			}
			else {
				age=15;
			}
			if("m".equalsIgnoreCase(rs.getString("gender")) || "f".equalsIgnoreCase(rs.getString("gender"))){
				String code =age+"."+gender.toUpperCase();
				total=1;
				if((Integer)genderages.get(code)!=null){
					total=(Integer)genderages.get(code)+1;
				}
				genderages.put(code,total);
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	rs.close();
	ps.close();
	%>
		<table width="100%">
			<tr class='admin'><td colspan='5'><%=getTran(request,"cnar","statistics.kine.title1.0",sWebLanguage)%></td></tr>
			<tr class='admin'>
				<td rowspan="2"><%=getTran(request,"cnar","statistics.agecategory",sWebLanguage)%></td>
				<td colspan="4"><%=getTran(request,"web","total",sWebLanguage)%></td>
			</tr>
			<tr class='admin'>
				<td><%=getTran(request,"web","male",sWebLanguage)%></td>
				<td>%</td>
				<td><%=getTran(request,"web","female",sWebLanguage)%></td>
				<td>%</td>
			</tr>
			<%
				int m0 = genderages.get("0.M")!=null?(Integer)genderages.get("0.M"):0;
				int f0 = genderages.get("0.F")!=null?(Integer)genderages.get("0.F"):0;
				int m5 = genderages.get("5.M")!=null?(Integer)genderages.get("5.M"):0;
				int f5 = genderages.get("5.F")!=null?(Integer)genderages.get("5.F"):0;
				int m15 = genderages.get("15.M")!=null?(Integer)genderages.get("15.M"):0;
				int f15 = genderages.get("15.F")!=null?(Integer)genderages.get("15.F"):0;
				total = m0+f0+m5+f5+m15+f15;
				int male = m0+m5+m15;
				int female = f0+f5+f15;
			%>
			<tr>
				<td class='admin' >0 - 5</td>
				<td class='admin2'><%=m0 %></td>
				<td class='admin2'><%=total>0?m0*100/(total):0 %>%</td>
				<td class='admin2'><%=f0 %></td>
				<td class='admin2'><%=total>0?f0*100/(total):0 %>%</td>
			</tr>
			<tr>
				<td class='admin' >5 - 15</td>
				<td class='admin2'><%=m5 %></td>
				<td class='admin2'><%=total>0?m5*100/(total):0 %>%</td>
				<td class='admin2'><%=f5 %></td>
				<td class='admin2'><%=total>0?f5*100/(total):0 %>%</td>
			</tr>
			<tr>
				<td class='admin' >15+</td>
				<td class='admin2'><%=m15 %></td>
				<td class='admin2'><%=total>0?m15*100/(total):0 %>%</td>
				<td class='admin2'><%=f15 %></td>
				<td class='admin2'><%=total>0?f15*100/(total):0 %>%</td>
			</tr>
			<tr class='admin'>
				<td><%=getTran(request,"web","total",sWebLanguage)%></td>
				<td><%=male %></td>
				<td><%=total>0?male*100/(total):0 %>%</td>
				<td><%=female %></td>
				<td><%=total>0?female*100/(total):0 %>%</td>
			</tr>
		</table>
	<br/><hr/><br/>
<%
	sQuery="select count(*) total,oc_prestation_objectid,oc_prestation_description from oc_debets d,oc_encounters e, oc_prestations p where p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_prestation_class='"+MedwanQuery.getInstance().getConfigString("cnarKineClass","kine")+"' and d.oc_debet_date>=? and d.oc_debet_date<=? group by oc_prestation_objectid,oc_prestation_description";
	ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	rs = ps.executeQuery();
	prestations = new TreeMap();
	total=0;
	while(rs.next()){
		String prestation=rs.getString("oc_prestation_objectid")+";"+rs.getString("oc_prestation_description");
		int count = rs.getInt("total");
		total+=count;
		prestations.put(prestation,count);
	}
	rs.close();
	ps.close();
%>
<table width="100%">
	<tr class='admin'><td colspan='3'><%=getTran(request,"cnar","statistics.kine.title1",sWebLanguage)%></td></tr>
	<tr class='admin'>
		<td rowspan="2"><%=getTran(request,"cnar","statistics.prestation.kine",sWebLanguage)%></td>
		<td colspan="2"><%=getTran(request,"web","total",sWebLanguage)%></td>
	</tr>
	<tr class='admin'>
		<td><%=getTran(request,"web","numberofcases",sWebLanguage)%></td>
		<td>%</td>
	</tr>
<%
	Iterator i = prestations.keySet().iterator();
	while(i.hasNext()){
		String prestation=(String)i.next();
		out.println("<tr><td class='admin'>"+prestation.split(";")[1]+"</td><td class='admin2'>"+prestations.get(prestation)+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format((new Double((Integer)prestations.get(prestation)))*100/total)+"</td></tr>");
	}
%>
	<tr class='admin'><td><%=getTran(request,"web","total",sWebLanguage)%></td><td><%=total %></td><td>100%</td></tr>
</table>
<%
	sQuery="select count(*) total,oc_prestation_objectid,oc_prestation_description,gender from oc_debets d,oc_encounters e, oc_prestations p, adminview a where e.oc_encounter_patientuid=a.personid and p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_prestation_class='"+MedwanQuery.getInstance().getConfigString("cnarKineClass","kine")+"' and d.oc_debet_date>=? and d.oc_debet_date<=? group by oc_prestation_objectid,oc_prestation_description,gender";
	ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	rs = ps.executeQuery();
	SortedMap equipments=new TreeMap();
	String equipment="";
	int totalfemale = 0, totalmale=0;
	while(rs.next()){
		int count = rs.getInt("total");
		equipment = checkString(rs.getString("oc_prestation_objectid")+";"+rs.getString("oc_prestation_description"));
		Equipment e = new Equipment();
		if(equipments.get(equipment)!=null){
			e=(Equipment)equipments.get(equipment);
		}
		if("fv".indexOf(checkString(rs.getString("gender")).toLowerCase())>-1){
			e.female+=count;
			totalfemale+=count;
		}
		else {
			e.male+=count;
			totalmale+=count;
		}
		equipments.put(equipment,e);
	}
	rs.close();
	ps.close();
%>
	<br/><hr/><br/>
	<table width="100%">
		<tr class='admin'><td colspan='6'><%=getTran(request,"cnar","statistics.kine.title2",sWebLanguage)%></td></tr>
		<tr class='admin'>
			<td rowspan='2'><%=getTran(request,"cnar","statistics.prestation.kine",sWebLanguage)%></td>
			<td colspan='2'><%= getTran(request,"web","male",sWebLanguage)%></td><td colspan='2'><%= getTran(request,"web","female",sWebLanguage)%></td><td rowspan='2'><%= getTran(request,"web","total",sWebLanguage)%></td></tr>
		<tr class='admin'>
			<td><%= getTran(request,"web","number.of.cases",sWebLanguage)%></td>
			<td>%</td>
			<td><%= getTran(request,"web","number.of.cases",sWebLanguage)%></td>
			<td>%</td>
		</tr>
			<%
				i = equipments.keySet().iterator();
				while(i.hasNext()){
					equipment=(String)i.next();
					Equipment e = (Equipment)equipments.get(equipment);
					out.println("<tr><td class='admin'>"+equipment.split(";")[1]+"</td><td class='admin2'>"+e.male+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.male*100/(e.male+e.female))+"%</td><td class='admin2'>"+e.female+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.female*100/(e.male+e.female))+"%</td><td class='admin2'>"+(e.male+e.female)+"</tr>");
				}
			%>
		<tr class='admin'>
			<td><%=getTran(request,"web","totals",sWebLanguage)%></td>
			<td><%=new Double(totalmale).intValue()+"" %></td>
			<td><%=totalmale+totalfemale==0?"-":new DecimalFormat("#0.00").format(totalmale*100/(totalmale+totalfemale))%>%</td>
			<td><%=new Double(totalfemale).intValue()+"" %></td>
			<td><%=totalmale+totalfemale==0?"-":new DecimalFormat("#0.00").format(totalfemale*100/(totalmale+totalfemale))%>%</td>
			<td><%=new Double(totalfemale+totalmale).intValue()+"" %></td>
		</tr>
	</table>
<%
	sQuery="select count(*) total,oc_prestation_objectid,oc_prestation_description,year(now())-year(dateofbirth) as age from oc_debets d,oc_encounters e, oc_prestations p, adminview a where e.oc_encounter_patientuid=a.personid and p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_prestation_class='"+MedwanQuery.getInstance().getConfigString("cnarKineClass","kine")+"' and d.oc_debet_date>=? and d.oc_debet_date<=? group by oc_prestation_objectid,oc_prestation_description,year(now())-year(dateofbirth)";
	ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	rs = ps.executeQuery();
	equipments=new TreeMap();
	double total0to5 = 0, total5to15=0, total15plus=0;
	while(rs.next()){
		int count = rs.getInt("total");
		equipment = checkString(rs.getString("oc_prestation_objectid")+";"+rs.getString("oc_prestation_description"));
		Equipment e = new Equipment();
		if(equipments.get(equipment)!=null){
			e=(Equipment)equipments.get(equipment);
		}
		if(rs.getInt("age")<=5){
			e.i0to5+=count;
			total0to5+=count;
		}
		else if(rs.getInt("age")<=15){
			e.i5to15+=count;
			total5to15+=count;
		}
		else {
			e.i15plus+=count;
			total15plus+=count;
		}
		equipments.put(equipment,e);
	}
	rs.close();
	ps.close();
%>
	<br/><hr/><br/>
	<table width="100%">
		<tr class='admin'><td colspan='8'><%=getTran(request,"cnar","statistics.kine.title3",sWebLanguage)%></td></tr>
		<tr class='admin'>
			<td rowspan='2'><%=getTran(request,"cnar","statistics.prestation.kine",sWebLanguage)%></td>
			<td colspan='2'><%= getTran(request,"web","0to5",sWebLanguage)%></td><td colspan='2'><%= getTran(request,"web","5to15",sWebLanguage)%></td><td colspan='2'><%= getTran(request,"web","15plus",sWebLanguage)%></td><td rowspan='2'><%= getTran(request,"web","total",sWebLanguage)%></td></tr>
		<tr class='admin'>
			<td><%= getTran(request,"web","number.of.cases",sWebLanguage)%></td>
			<td>%</td>
			<td><%= getTran(request,"web","number.of.cases",sWebLanguage)%></td>
			<td>%</td>
			<td><%= getTran(request,"web","number.of.cases",sWebLanguage)%></td>
			<td>%</td>
		</tr>
			<%
				i = equipments.keySet().iterator();
				while(i.hasNext()){
					equipment=(String)i.next();
					Equipment e = (Equipment)equipments.get(equipment);
					out.println("<tr><td class='admin'>"+equipment.split(";")[1]+"</td><td class='admin2'>"+e.i0to5+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.i0to5*100/(e.i0to5+e.i5to15+e.i15plus))+"%</td><td class='admin2'>"+e.i5to15+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.i5to15*100/(e.i0to5+e.i5to15+e.i15plus))+"%</td><td class='admin2'>"+e.i15plus+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.i15plus*100/(e.i0to5+e.i5to15+e.i15plus))+"%</td><td class='admin2'>"+(e.i0to5+e.i5to15+e.i15plus)+"</tr>");
				}
			%>
		<tr class='admin'>
			<td><%=getTran(request,"web","totals",sWebLanguage)%></td>
			<td><%=new Double(total0to5).intValue()+"" %></td>
			<td><%=total0to5+total5to15+total15plus==0?"-":new DecimalFormat("#0.00").format(total0to5*100/(total0to5+total5to15+total15plus))%>%</td>
			<td><%=new Double(total5to15).intValue()+"" %></td>
			<td><%=total0to5+total5to15+total15plus==0?"-":new DecimalFormat("#0.00").format(total5to15*100/(total0to5+total5to15+total15plus))%>%</td>
			<td><%=new Double(total15plus).intValue()+"" %></td>
			<td><%=total0to5+total5to15+total15plus==0?"-":new DecimalFormat("#0.00").format(total15plus*100/(total0to5+total5to15+total15plus))%>%</td>
			<td><%=new Double(total0to5+total5to15+total15plus).intValue()+"" %></td>
		</tr>
	</table>

<%
	conn.close();
%>