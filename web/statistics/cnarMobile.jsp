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
%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	
	java.util.Date dBegin = ScreenHelper.parseDate(begin);
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(end).getTime()+24*3600*1000-1);
	
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select count(*) total,oc_prestation_objectid,oc_prestation_description,gender from oc_debets d,oc_encounters e, oc_prestations p, adminview a where e.oc_encounter_patientuid=a.personid and p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_prestation_class='"+MedwanQuery.getInstance().getConfigString("cnarMobile","mob")+"' and d.oc_debet_date>=? and d.oc_debet_date<=? group by oc_prestation_objectid,oc_prestation_description,gender";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ResultSet rs = ps.executeQuery();
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
		<tr class='admin'><td colspan='6'><%=getTran(request,"cnar","statistics.mob.title1",sWebLanguage)%></td></tr>
		<tr class='admin'>
			<td rowspan='2'><%=getTran(request,"cnar","statistics.prestation.name",sWebLanguage)%></td>
			<td colspan='2'><%= getTran(request,"web","male",sWebLanguage)%></td><td colspan='2'><%= getTran(request,"web","female",sWebLanguage)%></td><td rowspan='2'><%= getTran(request,"web","total",sWebLanguage)%></td></tr>
		<tr class='admin'>
			<td><%= getTran(request,"web","number.of.cases",sWebLanguage)%></td>
			<td>%</td>
			<td><%= getTran(request,"web","number.of.cases",sWebLanguage)%></td>
			<td>%</td>
		</tr>
			<%
				Iterator i = equipments.keySet().iterator();
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
	sQuery="select count(*) total,oc_prestation_objectid,oc_prestation_description,year(now())-year(dateofbirth) as age from oc_debets d,oc_encounters e, oc_prestations p, adminview a where e.oc_encounter_patientuid=a.personid and p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_prestation_class='"+MedwanQuery.getInstance().getConfigString("cnarMobile","mob")+"' and d.oc_debet_date>=? and d.oc_debet_date<=? group by oc_prestation_objectid,oc_prestation_description,year(now())-year(dateofbirth)";
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
		<tr class='admin'><td colspan='8'><%=getTran(request,"cnar","statistics.mob.title2",sWebLanguage)%></td></tr>
		<tr class='admin'>
			<td rowspan='2'><%=getTran(request,"cnar","statistics.prestation.name",sWebLanguage)%></td>
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