package be.mxs.common.util.io.WHONet;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.StringBufferInputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPClientConfig;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Internet;
import be.mxs.common.util.system.Mail;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.medical.RequestedLabAnalysis;

public class WHONetUtils {
	
	public static String getAntibioticCode(String id){
		return MedwanQuery.getInstance().getConfigString("WHONetMap."+id,id);
	}
	
	public static StringBuffer getWHONetFile(java.util.Date start, boolean bUpdateExportDate){
		return createWHONetFile(start, bUpdateExportDate);
	}
	
	public static String ftpSendWHONetFile(java.util.Date start, boolean bUpdateExportDate,String sWebLanguage){
		String message=ScreenHelper.getTran(null,"web","error.sending.file",sWebLanguage);
		StringBuffer file = createWHONetFile(start, bUpdateExportDate);
		if(file.length()==0){
			message=ScreenHelper.getTran(null,"web","nothing.to.send",sWebLanguage);
		}
		else {
			String ftpurl=MedwanQuery.getInstance().getConfigString("WHONetDestinationFtpServer","");
			try{
				FTPClient ftp = new FTPClient();
				ftp.connect(ftpurl.split("@")[1]);
				ftp.user(ftpurl.split("@")[0].split(":")[0]);
				ftp.pass(ftpurl.split("@")[0].split(":")[1]);
				if(ftp.isConnected()){
					ftp.storeFile("OpenClinicWHONet."+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".csv", new StringBufferInputStream(file.toString()));
					message=ScreenHelper.getTran(null,"web","file.sent.to",sWebLanguage)+" "+ftpurl.split("@")[1];
				}
				ftp.disconnect();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return message;
	}
	
	public static String smtpSendWHONetFile(java.util.Date start, boolean bUpdateExportDate,String sWebLanguage){
		String message=ScreenHelper.getTran(null,"web","error.sending.file",sWebLanguage);
		StringBuffer file = createWHONetFile(start, bUpdateExportDate);
		if(file.length()==0){
			message=ScreenHelper.getTran(null,"web","nothing.to.send",sWebLanguage);
		}
		else {
			String smtpurl=MedwanQuery.getInstance().getConfigString("WHONetDestinationSmtpServer","");
			try{
				Mail.sendMail(MedwanQuery.getInstance().getConfigString("DefaultMailServerAddress"), MedwanQuery.getInstance().getConfigString("DefaultFromMailAddress"), smtpurl, "OpenClinicWHONet."+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".csv", file.toString(),null,null);
				message=ScreenHelper.getTran(null,"web","file.sent.to",sWebLanguage)+" "+smtpurl;
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return message;
	}
	
	public static String copyWHONetFile(java.util.Date start, boolean bUpdateExportDate,String sWebLanguage){
		String message=ScreenHelper.getTran(null,"web","error.sending.file",sWebLanguage);
		StringBuffer file = createWHONetFile(start, bUpdateExportDate);
		if(file.length()==0){
			message=ScreenHelper.getTran(null,"web","nothing.to.send",sWebLanguage);
		}
		else {
			try{
				String filename=MedwanQuery.getInstance().getConfigString("WHONetDestinationDirectory")+"/"+"OpenClinicWHONet."+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".csv";
				BufferedWriter bw = new BufferedWriter(new FileWriter(filename));
				bw.write(file.toString());
				bw.flush();
				bw.close();
				message=ScreenHelper.getTran(null,"web","file.sent.to",sWebLanguage)+" "+filename;
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		return message;
	}
	
	private static StringBuffer createWHONetFile(java.util.Date start, boolean bUpdateExportDate){
		StringBuffer exportstring = new StringBuffer("SampleID;PatientID;Firstname;Lastname;DateOfBirth;Gender;OrderDate;ResultDateTime;SpecimenType;SpecimenDate;OrganismCode;Organism;AntibioticCode;Antibiotic;Sensitivity\n\r");
		int startlength=exportstring.length();
		try{
			java.util.Date maxdate = new SimpleDateFormat("yyyyMMddHHmmss").parse("19000101000000");
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			PreparedStatement ps = conn.prepareStatement("select * from oc_antibiograms where oc_ab_updatetime>? order by oc_ab_updatetime");
			ps.setTimestamp(1, new Timestamp(start.getTime()));
			ResultSet rs = ps.executeQuery();
			while (rs.next()){
				String sampleid=rs.getString("oc_ab_requestedlabanalysisuid");
				if(sampleid.split("\\.").length>2){
					String header="";
					String transactionserverid=sampleid.split("\\.")[0];
					String transactionid=sampleid.split("\\.")[1];
					String labcode=sampleid.split("\\.")[2];
					//First retrieve transaction
					PreparedStatement ps2 = conn.prepareStatement("select a.personid,a.firstname,a.lastname,a.dateofbirth,a.gender,t.updatetime from adminview a, healthrecord h, transactions t where a.personid=h.personid and h.healthrecordid=t.healthrecordid and t.serverid=? and t.transactionid=?");
					ps2.setInt(1,Integer.parseInt(transactionserverid));
					ps2.setInt(2,Integer.parseInt(transactionid));
					ResultSet rs2 = ps2.executeQuery();
					if(rs2.next()){
						header=(sampleid+";");
						header+=(rs2.getString("personid")+";");
						header+=(rs2.getString("firstname")+";");
						header+=(rs2.getString("lastname")+";");
						header+=(rs2.getDate("dateofbirth")==null?";":new SimpleDateFormat("yyyyMMdd").format(rs2.getDate("dateofbirth"))+";");
						header+=(rs2.getString("gender")+";");
						header+=(new SimpleDateFormat(MedwanQuery.getInstance().getConfigString("WHONetDateFormat","yyyyMMdd")).format(rs2.getDate("updatetime"))+";");
						java.util.Date updatetime=new java.util.Date(rs.getTimestamp("oc_ab_updatetime").getTime());
						if(updatetime.after(maxdate)){
							maxdate=updatetime;
						}
						header+=new SimpleDateFormat(MedwanQuery.getInstance().getConfigString("WHONetDateTimeFormat","yyyyMMddHHmmss")).format(updatetime)+";";
					}
					rs2.close();
					ps2.close();
					//find labanalysis data
					RequestedLabAnalysis analysis = RequestedLabAnalysis.get(Integer.parseInt(transactionserverid), Integer.parseInt(transactionid), labcode);
					if(analysis!=null){
						String specimentype = RequestedLabAnalysis.getAnalysisMonster(labcode);
						String specimendate = analysis.getSampletakendatetime()!=null?new SimpleDateFormat(MedwanQuery.getInstance().getConfigString("WHONetDateTimeFormat","yyyyMMddHHmmss")).format(analysis.getSampletakendatetime()):new SimpleDateFormat(MedwanQuery.getInstance().getConfigString("WHONetDateTimeFormat","yyyyMMddHHmmss")).format(analysis.getResultDate());
						//Now loop through germs
						String germ = rs.getString("oc_ab_germ1");
						if(germ!=null && germ.length()>0 && !germ.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("antibiogrammeNogrowthLabel", "NEGATIVE"))){
							//Loop through antibiotics
							String antibiotics[] = ScreenHelper.checkString(rs.getString("oc_ab_antibiogramme1")).split(",");
							for(int n=0;n<antibiotics.length;n++){
								if(antibiotics[n].split("=").length==2){
									String code=getAntibioticCode(antibiotics[n].split("=")[0]);
									String sensitivity="";
									if(antibiotics[n].split("=")[1].equalsIgnoreCase("1")){
										sensitivity="S";
									}
									else if(antibiotics[n].split("=")[1].equalsIgnoreCase("2")){
										sensitivity="I";
									}
									else if(antibiotics[n].split("=")[1].equalsIgnoreCase("3")){
										sensitivity="R";
									}
									if(sensitivity.length()>0){
										exportstring.append(header);
										exportstring.append(specimentype+";");
										exportstring.append(specimendate+";");
										exportstring.append(MedwanQuery.getInstance().getGermCode(germ.split(",").length>1?germ.split(",")[1].trim():germ.trim())+";");
										exportstring.append((germ.split(",").length>1?germ.split(",")[1].trim():germ.trim())+";");
										exportstring.append(code+";");
										exportstring.append(RequestedLabAnalysis.getAntibioticNew(code, "en")+";");
										exportstring.append(sensitivity+"\n");
									}
								}
							}
						}
						germ = rs.getString("oc_ab_germ2");
						if(germ!=null && germ.length()>0 && !germ.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("antibiogrammeNogrowthLabel", "NEGATIVE"))){
							//Loop through antibiotics
							String antibiotics[] = ScreenHelper.checkString(rs.getString("oc_ab_antibiogramme2")).split(",");
							for(int n=0;n<antibiotics.length;n++){
								if(antibiotics[n].split("=").length==2){
									String code=getAntibioticCode(antibiotics[n].split("=")[0]);
									String sensitivity="";
									if(antibiotics[n].split("=")[1].equalsIgnoreCase("1")){
										sensitivity="S";
									}
									else if(antibiotics[n].split("=")[1].equalsIgnoreCase("2")){
										sensitivity="I";
									}
									else if(antibiotics[n].split("=")[1].equalsIgnoreCase("3")){
										sensitivity="R";
									}
									if(sensitivity.length()>0){
										exportstring.append(header);
										exportstring.append(specimentype+";");
										exportstring.append(specimendate+";");
										exportstring.append(MedwanQuery.getInstance().getGermCode(germ)+";");
										exportstring.append(germ+";");
										exportstring.append(code+";");
										exportstring.append(ScreenHelper.getTranNoLink("antibiotics", code, "en")+";");
										exportstring.append(sensitivity+"\n");
									}
								}
							}
						}
						germ = rs.getString("oc_ab_germ3");
						if(germ!=null && germ.length()>0 && !germ.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("antibiogrammeNogrowthLabel", "NEGATIVE"))){
							//Loop through antibiotics
							String antibiotics[] = ScreenHelper.checkString(rs.getString("oc_ab_antibiogramme1")).split(",");
							for(int n=0;n<antibiotics.length;n++){
								if(antibiotics[n].split("=").length==2){
									String code=getAntibioticCode(antibiotics[n].split("=")[0]);
									String sensitivity="";
									if(antibiotics[n].split("=")[1].equalsIgnoreCase("1")){
										sensitivity="S";
									}
									else if(antibiotics[n].split("=")[1].equalsIgnoreCase("2")){
										sensitivity="I";
									}
									else if(antibiotics[n].split("=")[1].equalsIgnoreCase("3")){
										sensitivity="R";
									}
									if(sensitivity.length()>0){
										exportstring.append(header);
										exportstring.append(specimentype+";");
										exportstring.append(specimendate+";");
										exportstring.append(MedwanQuery.getInstance().getGermCode(germ)+";");
										exportstring.append(germ+";");
										exportstring.append(code+";");
										exportstring.append(ScreenHelper.getTranNoLink("antibiotics", code, "en")+";");
										exportstring.append(sensitivity+"\n");
									}
								}
							}
						}
					}
				}
			}
			if(bUpdateExportDate && maxdate.after(start)){
				MedwanQuery.getInstance().setConfigString("lastWHONetExport", new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date(maxdate.getTime()+1)));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		if(startlength==exportstring.length()){
			exportstring=new StringBuffer("");
		}
		return exportstring;
	}
	

}
