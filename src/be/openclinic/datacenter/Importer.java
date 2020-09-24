package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;

import javax.mail.MessagingException;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.jnp.interfaces.java.javaURLContextFactory;

import com.sun.org.apache.xml.internal.security.utils.Base64;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

public class Importer {

	public static void execute(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		String parameterid,parametertype;
		try{
			int counter=0;
			ps = conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_IMPORTDATETIME is null and OC_IMPORT_ERRORCODE is null");
			ResultSet rs = ps.executeQuery();
			while(rs.next() && counter<1000){
				parameterid=rs.getString("OC_IMPORT_ID");
				parametertype=ScreenHelper.checkString((String)MedwanQuery.getInstance().getDatacenterparametertypes().get(parameterid));
				Debug.println("Using parameter type "+parametertype);
				if(parametertype.equalsIgnoreCase("simplevalue")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeSimpleValue(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("bedoccupancy")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeBedOccupancy(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("diagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDiagnosis(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("covid19")){
					Debug.println("Using covid19 import");
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeCovid19(importMessage)){
						Debug.println("Message was imported");
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						Debug.println("Message was NOT imported");
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("dhis2diagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDHIS2Diagnosis(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("dhis2deathdiagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDHIS2DeathDiagnosis(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("vaccination")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeVaccination(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("financial")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeFinancial(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
					else {
					}
				}
				else if(parametertype.equalsIgnoreCase("admissiondiagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDiagnosis(importMessage,"admission")){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("visitdiagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDiagnosis(importMessage,"visit")){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("mortality")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeMortality(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("activity")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeActivity(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("hr")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeHR(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("patient")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storePatient(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
						counter++;
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				Debug.println("Imported parameter "+parameterid);
			}
			rs.close();
			ps.close();
	        String msgid=new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
			ps = conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_IMPORTDATETIME is not null and OC_IMPORT_IMPORTACKDATETIME is null");
			rs = ps.executeQuery();
			Vector ackMessages = new Vector();
			while(rs.next()){
				Debug.println("Sent import ACK for message "+rs.getInt("OC_IMPORT_UID"));
				ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
				ackMessages.add(importMessage);
			}
			ImportMessage.sendImportAck(ackMessages);
			rs.close();
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (MessagingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static boolean storeDiagnosis(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("medical.1")){
				Element diags = root.element("diags");
				Iterator diagnoses = diags.elementIterator("diagnosis");
				while(diagnoses.hasNext()){
					Element diagnosis = (Element)diagnoses.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_CODE=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, "KPGS");
					ps.setString(3, diagnosis.attributeValue("code"));
					ps.setInt(4,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_DIAGNOSISVALUES(DC_DIAGNOSISVALUE_SERVERID,DC_DIAGNOSISVALUE_OBJECTID,DC_DIAGNOSISVALUE_CODETYPE,DC_DIAGNOSISVALUE_CODE,DC_DIAGNOSISVALUE_YEAR,DC_DIAGNOSISVALUE_MONTH,DC_DIAGNOSISVALUE_COUNT) values(?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, "KPGS");
					ps.setString(4, diagnosis.attributeValue("code"));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(6,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.setInt(7,Integer.parseInt(diagnosis.attributeValue("count")));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeCovid19(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("covid19.1")){
				Element covid19 = root.element("covid19");
				Iterator parameters = covid19.elementIterator("par");
				while(parameters.hasNext()){
					Element parameter = (Element)parameters.next();
					//First clear a possible existing value
					ps=conn.prepareStatement("DELETE FROM DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? and DC_SIMPLEVALUE_CREATEDATETIME=?");
					ps.setInt(1,importMessage.getServerId());
					ps.setString(2, parameter.attributeValue("id"));
					try {
						ps.setTimestamp(3,new java.sql.Timestamp(new SimpleDateFormat("yyyyMMdd").parse(parameter.attributeValue("date")).getTime()));
						ps.executeUpdate();
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					ps.close();
					//Then insert the newly received (updated) value
					ps=conn.prepareStatement("INSERT INTO DC_SIMPLEVALUES(DC_SIMPLEVALUE_SERVERID,DC_SIMPLEVALUE_OBJECTID,DC_SIMPLEVALUE_PARAMETERID," +
							"DC_SIMPLEVALUE_CREATEDATETIME,DC_SIMPLEVALUE_SENTDATETIME," +
							"DC_SIMPLEVALUE_RECEIVEDATETIME,DC_SIMPLEVALUE_IMPORTDATETIME,DC_SIMPLEVALUE_DATA) " +
							"values (?,?,?,?,?,?,?,?)");
					ps.setInt(1,importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, parameter.attributeValue("id"));
					try {
						ps.setTimestamp(4,new java.sql.Timestamp(new SimpleDateFormat("yyyyMMdd").parse(parameter.attributeValue("date")).getTime()));
						ps.setTimestamp(5,importMessage.getSentDateTime()==null?null:new java.sql.Timestamp(importMessage.getSentDateTime().getTime()));
						ps.setTimestamp(6,importMessage.getReceiveDateTime()==null?null:new java.sql.Timestamp(importMessage.getReceiveDateTime().getTime()));
						ps.setTimestamp(7,importMessage.getImportDateTime()==null?null:new java.sql.Timestamp(importMessage.getImportDateTime().getTime()));
						ps.setString(8, parameter.attributeValue("value"));
						ps.executeUpdate();
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					importMessage.updateErrorCode(0);
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeDHIS2Diagnosis(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("dhis2.1")){
				Element diags = root.element("dhis2diags");
				Iterator diagnoses = diags.elementIterator("diagnosis");
				while(diagnoses.hasNext()){
					Element diagnosis = (Element)diagnoses.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_DHIS2DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_SERVICEUID=? and DC_DIAGNOSISVALUE_ENCOUNTERTYPE=? and DC_DIAGNOSISVALUE_GENDER=? and DC_DIAGNOSISVALUE_AGE=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_CODE=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, diagnosis.attributeValue("serviceuid"));
					ps.setString(3, diagnosis.attributeValue("encountertype"));
					ps.setString(4, diagnosis.attributeValue("gender"));
					ps.setString(5, diagnosis.attributeValue("age"));
					ps.setString(6, "icd10");
					ps.setString(7, diagnosis.attributeValue("code"));
					ps.setInt(8,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(9,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_DHIS2DIAGNOSISVALUES(DC_DIAGNOSISVALUE_SERVERID,DC_DIAGNOSISVALUE_OBJECTID,DC_DIAGNOSISVALUE_SERVICEUID,DC_DIAGNOSISVALUE_ENCOUNTERTYPE,DC_DIAGNOSISVALUE_GENDER,DC_DIAGNOSISVALUE_AGE,DC_DIAGNOSISVALUE_CODETYPE,DC_DIAGNOSISVALUE_CODE,DC_DIAGNOSISVALUE_YEAR,DC_DIAGNOSISVALUE_MONTH,DC_DIAGNOSISVALUE_COUNT) values(?,?,?,?,?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, diagnosis.attributeValue("serviceuid"));
					ps.setString(4, diagnosis.attributeValue("encountertype"));
					ps.setString(5, diagnosis.attributeValue("gender"));
					ps.setString(6, diagnosis.attributeValue("age"));
					ps.setString(7, "icd10");
					ps.setString(8, diagnosis.attributeValue("code"));
					ps.setInt(9,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(10,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.setInt(11,Integer.parseInt(diagnosis.attributeValue("count")));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeDHIS2DeathDiagnosis(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("dhis2.2")){
				Element diags = root.element("dhis2diags");
				Iterator diagnoses = diags.elementIterator("diagnosis");
				while(diagnoses.hasNext()){
					Element diagnosis = (Element)diagnoses.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_DHIS2DEATHDIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_SERVICEUID=? and DC_DIAGNOSISVALUE_GENDER=? and DC_DIAGNOSISVALUE_AGE=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_CODE=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, diagnosis.attributeValue("serviceuid"));
					ps.setString(3, diagnosis.attributeValue("gender"));
					ps.setString(4, diagnosis.attributeValue("age"));
					ps.setString(5, "icd10");
					ps.setString(6, diagnosis.attributeValue("code"));
					ps.setInt(7,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(8,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_DHIS2DEATHDIAGNOSISVALUES(DC_DIAGNOSISVALUE_SERVERID,DC_DIAGNOSISVALUE_OBJECTID,DC_DIAGNOSISVALUE_SERVICEUID,DC_DIAGNOSISVALUE_GENDER,DC_DIAGNOSISVALUE_AGE,DC_DIAGNOSISVALUE_CODETYPE,DC_DIAGNOSISVALUE_CODE,DC_DIAGNOSISVALUE_YEAR,DC_DIAGNOSISVALUE_MONTH,DC_DIAGNOSISVALUE_COUNT) values(?,?,?,?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, diagnosis.attributeValue("serviceuid"));
					ps.setString(4, diagnosis.attributeValue("gender"));
					ps.setString(5, diagnosis.attributeValue("age"));
					ps.setString(6, "icd10");
					ps.setString(7, diagnosis.attributeValue("code"));
					ps.setInt(8,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(9,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.setInt(10,Integer.parseInt(diagnosis.attributeValue("count")));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeVaccination(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("medical.1.3")){
				Element vacs = root.element("vaccinations");
				Iterator vaccinations = vacs.elementIterator("vaccination");
				while(vaccinations.hasNext()){
					Element vaccination = (Element)vaccinations.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_VACCINATIONS where DC_VACCINATION_SERVERUID=? and DC_VACCINATION_TYPE=? and DC_VACCINATION_PATIENTUID=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, vaccination.attributeValue("type"));
					ps.setString(3, vaccination.attributeValue("patient"));
					ps.execute();
					ps.close();
					if(vaccination.attributeValue("location").startsWith("0")){
						ps = conn.prepareStatement("insert into DC_VACCINATIONS(DC_VACCINATION_SERVERUID,DC_VACCINATION_PATIENTUID,DC_VACCINATION_TYPE,DC_VACCINATION_DATE,DC_VACCINATION_UPDATETIME,DC_VACCINATION_MODEL,DC_VACCINATION_BIRTH) values(?,?,?,?,?,?,?)");
						ps.setInt(1, importMessage.getServerId());
						ps.setString(2, vaccination.attributeValue("patient"));
						ps.setString(3, vaccination.attributeValue("type"));
						ps.setTimestamp(4,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(vaccination.attributeValue("date")).getTime()));
						ps.setTimestamp(5,new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(vaccination.attributeValue("updatetime")).getTime()));
						ps.setString(6, vaccination.attributeValue("model"));
						ps.setTimestamp(7,vaccination.attributeValue("dateofbirth")==null || vaccination.attributeValue("dateofbirth").length()==0?null: new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(vaccination.attributeValue("dateofbirth")).getTime()));
						ps.execute();
						ps.close();
					}
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeBedOccupancy(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("encounter.1")){
				Element services = root.element("services");
				Iterator servs = services.elementIterator("service");
				ps = conn.prepareStatement("delete from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=? and DC_BEDOCCUPANCYVALUE_OBJECTID=?");
				ps.setInt(1, importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.executeUpdate();
				ps.close();
				while(servs.hasNext()){
					Element service = (Element)servs.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("insert into DC_BEDOCCUPANCYVALUES(DC_BEDOCCUPANCYVALUE_SERVERID,DC_BEDOCCUPANCYVALUE_OBJECTID,DC_BEDOCCUPANCYVALUE_SERVICEUID,DC_BEDOCCUPANCYVALUE_DATE,DC_BEDOCCUPANCYVALUE_TOTALBEDS,DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS) values(?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, service.attributeValue("serviceid"));
					ps.setTimestamp(4, new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(service.attributeValue("date")).getTime()));
					ps.setInt(5,Integer.parseInt(service.attributeValue("totalbeds")));
					ps.setInt(6,Integer.parseInt(service.attributeValue("occupiedbeds").equalsIgnoreCase("null")?"0":service.attributeValue("occupiedbeds")));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (ParseException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeHR(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("hr.1")){
				Element hr = root.element("hr");
				ps = conn.prepareStatement("delete from DC_HRVALUES where DC_HR_SERVERID=? and DC_HR_OBJECTID=?");
				ps.setInt(1, importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.executeUpdate();
				ps.close();
				//First clear a possible existing value
				ps = conn.prepareStatement("insert into DC_HRVALUES(DC_HR_SERVERID,DC_HR_OBJECTID,DC_HR_GROUP,DC_HR_YEAR,DC_HR_MONTH,DC_HR_COUNT) values(?,?,?,?,?,?)");
				ps.setInt(1, importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.setString(3, hr.attributeValue("group"));
				ps.setInt(4, Integer.parseInt(hr.attributeValue("month").substring(0,4)));
				ps.setInt(5, Integer.parseInt(hr.attributeValue("month").substring(4,6)));
				ps.setInt(6,Integer.parseInt(hr.attributeValue("count")));
				ps.execute();
				ps.close();
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeDiagnosis(ImportMessage importMessage,String type){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").startsWith("medical.1")){
				Element diags = root.element("diags");
				Iterator diagnoses = diags.elementIterator("diagnosis");
				while(diagnoses.hasNext()){
					Element diagnosis = (Element)diagnoses.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_ENCOUNTERDIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_CODE=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=? and DC_DIAGNOSISVALUE_ENCOUNTERTYPE=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, "KPGS");
					ps.setString(3, diagnosis.attributeValue("code"));
					ps.setInt(4,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.setString(6, type);
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_ENCOUNTERDIAGNOSISVALUES(DC_DIAGNOSISVALUE_SERVERID,DC_DIAGNOSISVALUE_OBJECTID,DC_DIAGNOSISVALUE_CODETYPE,DC_DIAGNOSISVALUE_CODE,DC_DIAGNOSISVALUE_YEAR,DC_DIAGNOSISVALUE_MONTH,DC_DIAGNOSISVALUE_COUNT,DC_DIAGNOSISVALUE_ENCOUNTERTYPE) values(?,?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, "KPGS");
					ps.setString(4, diagnosis.attributeValue("code"));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(6,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.setInt(7,Integer.parseInt(diagnosis.attributeValue("count")));
					ps.setString(8, type);
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeActivity(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").startsWith("activity.1")){
				Element diags = root.element("activities");
				Iterator diagnoses = diags.elementIterator("activity");
				while(diagnoses.hasNext()){
					Element activity = (Element)diagnoses.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_ACTIVITYVALUES where DC_ACTIVITYVALUE_SERVERID=? and DC_ACTIVITYVALUE_TYPE=? and DC_ACTIVITYVALUE_YEAR=? and DC_ACTIVITYVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, activity.attributeValue("type"));
					ps.setInt(3,Integer.parseInt(activity.attributeValue("year")));
					ps.setInt(4,Integer.parseInt(activity.attributeValue("month")));
					ps.execute();
					ps.close();
					try{
						ps = conn.prepareStatement("insert into DC_ACTIVITYVALUES(DC_ACTIVITYVALUE_SERVERID,DC_ACTIVITYVALUE_OBJECTID,DC_ACTIVITYVALUE_TYPE,DC_ACTIVITYVALUE_YEAR,DC_ACTIVITYVALUE_MONTH,DC_ACTIVITYVALUE_USERCOUNT,DC_ACTIVITYVALUE_MEAN,DC_ACTIVITYVALUE_MEDIAN,DC_ACTIVITYVALUE_MEANDEVIATION) values(?,?,?,?,?,?,?,?,?)");
						ps.setInt(1, importMessage.getServerId());
						ps.setInt(2, importMessage.getObjectId());
						ps.setString(3, activity.attributeValue("type"));
						ps.setInt(4,Integer.parseInt(activity.attributeValue("year")));
						ps.setInt(5,Integer.parseInt(activity.attributeValue("month")));
						ps.setInt(6,Integer.parseInt(activity.attributeValue("users")));
						ps.setFloat(7,Float.parseFloat(activity.attributeValue("mean").equalsIgnoreCase("infinity")?activity.attributeValue("median").replaceAll(",","."):activity.attributeValue("mean").replaceAll(",",".")));
						ps.setFloat(8,Float.parseFloat(activity.attributeValue("median").replaceAll(",",".")));
						ps.setFloat(9,Float.parseFloat(activity.attributeValue("meanDeviation").replaceAll(",",".")));
						ps.execute();
						ps.close();
					}
					catch (Exception e) {
						// TODO: handle exception
						e.printStackTrace();
					}
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeMortality(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").startsWith("mortality.1")){
				Element mortalities = root.element("mortalities");
				Iterator ms = mortalities.elementIterator();
				while (ms.hasNext()){
					Element mortality = (Element)ms.next();
					if(mortality.getName().equalsIgnoreCase("mortality")){
						//First clear a possible existing value
						ps = conn.prepareStatement("delete from DC_MORTALITYVALUES where DC_MORTALITYVALUE_SERVERID=? and DC_MORTALITYVALUE_CODETYPE is NULL and DC_MORTALITYVALUE_CODE is NULL and DC_MORTALITYVALUE_YEAR=? and DC_MORTALITYVALUE_MONTH=?");
						ps.setInt(1, importMessage.getServerId());
						ps.setInt(2,Integer.parseInt(mortality.attributeValue("year")));
						ps.setInt(3,Integer.parseInt(mortality.attributeValue("month")));
						ps.execute();
						ps.close();
						ps = conn.prepareStatement("insert into DC_MORTALITYVALUES(DC_MORTALITYVALUE_SERVERID,DC_MORTALITYVALUE_OBJECTID,DC_MORTALITYVALUE_CODETYPE,DC_MORTALITYVALUE_CODE,DC_MORTALITYVALUE_YEAR,DC_MORTALITYVALUE_MONTH,DC_MORTALITYVALUE_COUNT) values(?,?,NULL,NULL,?,?,?)");
						ps.setInt(1, importMessage.getServerId());
						ps.setInt(2, importMessage.getObjectId());
						ps.setInt(3,Integer.parseInt(mortality.attributeValue("year")));
						ps.setInt(4,Integer.parseInt(mortality.attributeValue("month")));
						ps.setInt(5,Integer.parseInt(mortality.attributeValue("deaths")));
						ps.execute();
						ps.close();
					}
					if(mortality.getName().equalsIgnoreCase("diagnosismortality")){
						//First clear a possible existing value
						ps = conn.prepareStatement("delete from DC_MORTALITYVALUES where DC_MORTALITYVALUE_SERVERID=? and DC_MORTALITYVALUE_CODETYPE=? and DC_MORTALITYVALUE_CODE=? and DC_MORTALITYVALUE_YEAR=? and DC_MORTALITYVALUE_MONTH=?");
						ps.setInt(1, importMessage.getServerId());
						ps.setString(2, "KPGS");
						ps.setString(3, mortality.attributeValue("code"));
						ps.setInt(4,Integer.parseInt(mortality.attributeValue("year")));
						ps.setInt(5,Integer.parseInt(mortality.attributeValue("month")));
						ps.execute();
						ps.close();
						ps = conn.prepareStatement("insert into DC_MORTALITYVALUES(DC_MORTALITYVALUE_SERVERID,DC_MORTALITYVALUE_OBJECTID,DC_MORTALITYVALUE_CODETYPE,DC_MORTALITYVALUE_CODE,DC_MORTALITYVALUE_YEAR,DC_MORTALITYVALUE_MONTH,DC_MORTALITYVALUE_COUNT,DC_MORTALITYVALUE_DIAGNOSISCOUNT) values(?,?,?,?,?,?,?,?)");
						ps.setInt(1, importMessage.getServerId());
						ps.setInt(2, importMessage.getObjectId());
						ps.setString(3, "KPGS");
						ps.setString(4, mortality.attributeValue("code"));
						ps.setInt(5,Integer.parseInt(mortality.attributeValue("year")));
						ps.setInt(6,Integer.parseInt(mortality.attributeValue("month")));
						ps.setInt(7,Integer.parseInt(mortality.attributeValue("deaths")));
						ps.setInt(8,Integer.parseInt(mortality.attributeValue("all")));
						ps.execute();
						ps.close();
					}
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storePatient(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").startsWith("people.patients")){
				Element patients = root.element("patients");
				Iterator ms = patients.elementIterator();
				while (ms.hasNext()){
					Element patient = (Element)ms.next();
					if(patient.getName().equalsIgnoreCase("patient")){
						//First clear a possible existing value
						ps = conn.prepareStatement("delete from DC_PATIENTRECORDS where DC_PATIENTRECORD_SERVERID=? and DC_PATIENTRECORD_PERSONID=?");
						ps.setInt(1, importMessage.getServerId());
						ps.setInt(2,Integer.parseInt(patient.attributeValue("id")));
						ps.execute();
						ps.close();
						ps = conn.prepareStatement("insert into DC_PATIENTRECORDS(DC_PATIENTRECORD_SERVERID,DC_PATIENTRECORD_PERSONID,DC_PATIENTRECORD_FIRSTNAME,DC_PATIENTRECORD_LASTNAME,DC_PATIENTRECORD_GENDER,DC_PATIENTRECORD_DATEOFBIRTH,DC_PATIENTRECORD_ARCHIVEFILE,DC_PATIENTRECORD_PICTURE,DC_PATIENTRECORD_CREATEDATETIME) values(?,?,?,?,?,?,?,?,?)");
						ps.setInt(1, importMessage.getServerId());
						ps.setInt(2, Integer.parseInt(patient.attributeValue("id")));
						ps.setString(3, patient.element("firstname").getText());
						ps.setString(4, patient.element("lastname").getText());
						ps.setString(5, patient.element("gender").getText());
						ps.setString(6, patient.element("dateofbirth").getText());
						ps.setString(7, patient.element("archivefile").getText());
						ps.setBytes(8, patient.elementText("picture")!=null?org.apache.commons.codec.binary.Base64.decodeBase64(patient.elementText("picture")):null);
						ps.setTimestamp(9, new java.sql.Timestamp(importMessage.getCreateDateTime().getTime()));
						ps.execute();
						ps.close();
					}
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeFinancial(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && ( root.attributeValue("parameterid").startsWith("financial.0") ||
					root.attributeValue("parameterid").startsWith("financial.1") ||
					root.attributeValue("parameterid").startsWith("financial.2") ||
					root.attributeValue("parameterid").startsWith("financial.3") )){
				Element financial = root.element("financial");
				//First clear a possible existing value
				ps = conn.prepareStatement("delete from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_PARAMETERID=? and DC_FINANCIALVALUE_YEAR=? and DC_FINANCIALVALUE_MONTH=?");
				ps.setInt(1, importMessage.getServerId());
				ps.setString(2, root.attributeValue("parameterid"));
				ps.setInt(3,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
				ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
				ps.execute();
				ps.close();
				ps = conn.prepareStatement("insert into DC_FINANCIALVALUES(DC_FINANCIALVALUE_SERVERID,DC_FINANCIALVALUE_OBJECTID,DC_FINANCIALVALUE_PARAMETERID,DC_FINANCIALVALUE_YEAR,DC_FINANCIALVALUE_MONTH,DC_FINANCIALVALUE_VALUE) values(?,?,?,?,?,?)");
				ps.setInt(1, importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.setString(3, root.attributeValue("parameterid"));
				ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
				ps.setInt(5,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
				ps.setString(6,financial.attributeValue("count"));
				ps.execute();
				ps.close();
				bSuccess=true;
			}
			else if(root.getName().equalsIgnoreCase("data") &&  root.attributeValue("parameterid").equalsIgnoreCase("financial.4")){
				Element financials =root.element("financials");
				Iterator fins = financials.elementIterator("financial");
				while(fins.hasNext()){
					Element financial = (Element)fins.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_PARAMETERID=? and DC_FINANCIALVALUE_CLASS=? and DC_FINANCIALVALUE_YEAR=? and DC_FINANCIALVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, root.attributeValue("parameterid"));
					ps.setString(3, financial.attributeValue("family"));
					ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
					ps.setInt(5,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_FINANCIALVALUES(DC_FINANCIALVALUE_SERVERID,DC_FINANCIALVALUE_OBJECTID,DC_FINANCIALVALUE_PARAMETERID,DC_FINANCIALVALUE_YEAR,DC_FINANCIALVALUE_MONTH,DC_FINANCIALVALUE_VALUE,DC_FINANCIALVALUE_CLASS) values(?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, root.attributeValue("parameterid"));
					ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
					ps.setInt(5,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
					ps.setString(6,financial.attributeValue("count"));
					ps.setString(7,financial.attributeValue("family"));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeSimpleValue(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
			ps=conn.prepareStatement("SELECT * from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_OBJECTID=?");
			ps.setInt(1,importMessage.getServerId());
			ps.setInt(2, importMessage.getObjectId());
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				rs.close();
				importMessage.updateErrorCode(1);
			}
			else {
				rs.close();
				ps.close();
				ps=conn.prepareStatement("DELETE FROM DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? and DC_SIMPLEVALUE_CREATEDATETIME=?");
				ps.setInt(1,importMessage.getServerId());
				ps.setString(2, importMessage.getMessageId());
				ps.setTimestamp(3,importMessage.getCreateDateTime()==null?null:new java.sql.Timestamp(importMessage.getCreateDateTime().getTime()));
				ps.executeUpdate();
				ps.close();
				if(importMessage.getData().length()>255){
					importMessage.setError(50);
					importMessage.sendError();
				}
				else {
					ps=conn.prepareStatement("INSERT INTO DC_SIMPLEVALUES(DC_SIMPLEVALUE_SERVERID,DC_SIMPLEVALUE_OBJECTID,DC_SIMPLEVALUE_PARAMETERID," +
							"DC_SIMPLEVALUE_CREATEDATETIME,DC_SIMPLEVALUE_SENTDATETIME," +
							"DC_SIMPLEVALUE_RECEIVEDATETIME,DC_SIMPLEVALUE_IMPORTDATETIME,DC_SIMPLEVALUE_DATA) " +
							"values (?,?,?,?,?,?,?,?)");
					ps.setInt(1,importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, importMessage.getMessageId());
					ps.setTimestamp(4,importMessage.getCreateDateTime()==null?null:new java.sql.Timestamp(importMessage.getCreateDateTime().getTime()));
					ps.setTimestamp(5,importMessage.getSentDateTime()==null?null:new java.sql.Timestamp(importMessage.getSentDateTime().getTime()));
					ps.setTimestamp(6,importMessage.getReceiveDateTime()==null?null:new java.sql.Timestamp(importMessage.getReceiveDateTime().getTime()));
					ps.setTimestamp(7,importMessage.getImportDateTime()==null?null:new java.sql.Timestamp(importMessage.getImportDateTime().getTime()));
					ps.setString(8, importMessage.getData());
	
					ps.executeUpdate();
					importMessage.updateErrorCode(0);
					bSuccess=true;
				}
			}
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
}
