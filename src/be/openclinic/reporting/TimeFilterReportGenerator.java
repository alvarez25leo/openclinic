package be.openclinic.reporting;

import java.io.File;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.tools.sendHtmlMail;
import uk.org.primrose.pool.PoolException;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class TimeFilterReportGenerator {
	
	static public boolean sendEmailWithImages(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sImage) throws Exception{      		    	
    	// * * The browser accesses these images just as if it were displaying an image in a Web page. Unfortunately, spammers have used this mechanism as a sneaky way to record who visits their site (and mark your email as valid). To protect your privacy, many Web-based (and other) email clients don't display images in HTML emails.
		//	An alternative to placing absolute URLs to images in your HTML is to include the images as attachments to the email. The HTML can reference the image in an attachment by using the protocol prefix cid: plus the content-id of the attachment.      		       
	    boolean bSuccess = false;    
		try{
			final String username = MedwanQuery.getInstance(false).getConfigString("mailbot.user","openclinic.mailrobot@ict4d.be");
			final String password = MedwanQuery.getInstance(false).getConfigString("mailbot.password","Bigo4ever");

			Properties props = new Properties();
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.host", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));
			props.put("mail.smtp.port", MedwanQuery.getInstance(false).getConfigString("mailbot.port","587"));
	        props.put("mail.smtp.user", username);
	        props.put("mail.smtp.password", password);

	        Session mailSession = Session.getInstance(props);

	        mailSession.setDebug(MedwanQuery.getInstance(false).getConfigString("Debug").equalsIgnoreCase("On"));
	        Transport transport = mailSession.getTransport("smtp");
	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(sSubject);
	        message.setFrom(new InternetAddress(sFrom,MedwanQuery.getInstance(false).getConfigString("mailbot.fromname","OpenClinic Mailbot")));	  
	        message.setReplyTo(new InternetAddress[] {new InternetAddress(MedwanQuery.getInstance(false).getConfigString("mailbot.replyto","openclinic.mailrobot@ict4d.be"))});
	        message.setSentDate(new java.util.Date());
	        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));
	
	        // This HTML mail have to 2 part, the BODY and the embedded image       
	        MimeMultipart multipart = new MimeMultipart("related");
	
	        // first part  (the html)
	        BodyPart messageBodyPart = new MimeBodyPart();		
	        String htmlText = sMessage;	    
	        message.setHeader("content-type", "text/html; charset=ISO-8859-1"); 
	        messageBodyPart.setContent(htmlText, "text/html");
	
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	        
	        if(new java.io.File(sImage).exists()){
		        // second part (the image)
		        messageBodyPart = new MimeBodyPart();
		        DataSource fds = new FileDataSource(sImage);
		        messageBodyPart.setDataHandler(new DataHandler(fds));
		        messageBodyPart.setHeader("Content-ID","<image_logo>");
		
		        // add it
		        multipart.addBodyPart(messageBodyPart);
	        }
	
	        // put everything together
	        message.setContent(multipart);
	
	        transport.connect(MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"),username,password);
	        transport.sendMessage(message,
	        message.getRecipients(Message.RecipientType.TO));
	        transport.close();
	        bSuccess=true;
	    }
	    catch(Exception e){
	    	Debug.print(e.getMessage());
	    }
		return bSuccess;
	}
	
	public static void main(String[] args) {
    	try {
			PrimroseLoader.load(args[0], true);
		}
    	catch (Exception e) {
			e.printStackTrace();
		}
		StringBuffer sb=run(args[1]);
		if(sb!=null && sb.toString().length()>0){
			try {
				String[] destinations= args[4].split(";");
				for(int n=0;n<destinations.length;n++){
					if(destinations[n].length()>0){
						String sLogo = MedwanQuery.getInstance(false).getConfigString("reportLogo","/var/tomcat/webapps/openclinic/_img/projectlogo.jpg");	
						sendEmailWithImages(args[2], args[3], destinations[n], MedwanQuery.getInstance(false).getConfigString("quickStatsMailSubject","OpenClinic GA QuickStats"), sb.toString(),sLogo);
						Debug.println("Message sent");
					}
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		Debug.println("End of TimeFilter procedure");
		System.exit(0);
	}
	
	public static StringBuffer run(String template){
		String begin="",end="";
		StringBuffer output=new StringBuffer("");
		output.append("<table style='border:1px solid black;'><tr><td colspan='2'><center><img width='120px' src=\"cid:image_logo\"></center></td></tr>");
		try{
			long day=24*3600*1000;
			StringBuffer csvResults = new StringBuffer();
			String reportTemplate = MedwanQuery.getInstance(false).getConfigString("templateDirectory")+"/"+ScreenHelper.checkString(template);
			Connection conn = MedwanQuery.getInstance(false).getOpenclinicConnection();
			PreparedStatement ps = null;
			ResultSet rs = null;
			SAXReader reader = new SAXReader(false);
			Document document = reader.read(new File(reportTemplate));
			Element root = document.getRootElement();
			Element schedule = root.element("schedule");
			String period="";
			if(schedule.attributeValue("type").equalsIgnoreCase("daily")){
				begin=ScreenHelper.formatDate(new java.util.Date(new java.util.Date().getTime()-day));
				end=ScreenHelper.formatDate(new java.util.Date());
				period=begin;
			}
			else if(schedule.attributeValue("type").equalsIgnoreCase("weekly")){
				begin=ScreenHelper.formatDate(new java.util.Date(new java.util.Date().getTime()-7*day));
				end=ScreenHelper.formatDate(new java.util.Date());
				period=begin+" - "+end;
			}
			else if(schedule.attributeValue("type").equalsIgnoreCase("monthly")){
				Calendar calendar = new GregorianCalendar();
				calendar.add(Calendar.MONTH, -1);
				begin=new SimpleDateFormat("01/MM/yyyy").format(calendar.getTime());
				end=new SimpleDateFormat("01/MM/yyyy").format(new java.util.Date());
				period=begin+" - "+end;
			}
			else{
				return null;
			}
			Iterator results = root.elementIterator("result");
			while(results.hasNext()){
				SortedMap rows = new TreeMap();
				Element result = (Element)results.next();
				if(result.attributeValue("type").equalsIgnoreCase("maintitle")){
					output.append("<tr><td colspan='2' style='background-color: black; color: white'>"+result.element("label").getText()+" "+period+"</td></tr>");
				}
				else if(result.attributeValue("type").equalsIgnoreCase("title")){
					output.append("<tr><td colspan='2' style='background-color: black; color: white'>"+result.element("label").getText()+"</td></tr>");
				}
				else if(result.attributeValue("type").equalsIgnoreCase("subtitle")){
					output.append("<tr><td colspan='2' style='background-color: lightgray; color: black; border:1px solid lightgray;'>"+result.element("label").getText()+"</td></tr>");
				}
				else if(result.attributeValue("type").equalsIgnoreCase("configvalue")){
					output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+MedwanQuery.getInstance(false).getConfigString(result.element("label").getText(),result.element("label").attributeValue("default"))+"</td></tr>");
				}
				else if(result.attributeValue("type").equalsIgnoreCase("value")){
					Element filter = result.element("filter");
					if(filter.attributeValue("type").equalsIgnoreCase("encounter")){
						//We must create a select query
						String sSelect="select sum("+MedwanQuery.getInstance(false).datediff("day", "oc_encounter_begindate", "oc_encounter_enddate")+") as duration from oc_encounters_view2"+
									   " where 1=1";
						Vector parameters = new Vector();
						if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
							sSelect+=" AND OC_ENCOUNTER_STARTDATE>=?"+
									" AND OC_ENCOUNTER_STARTDATE<?"+
									" AND OC_ENCOUNTER_BEGINDATE>=?"+
									" AND OC_ENCOUNTER_BEGINDATE<?"
									;
							parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
							parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
							parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
							parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
						}
						//Also add extra select criteria
						Element selectElement = filter.element("select");
						Iterator selectfields = selectElement.elementIterator("field");
						while(selectfields.hasNext()){
							Element selectField = (Element)selectfields.next();
							if(selectField.attributeValue("name").equalsIgnoreCase("encountertype")){
								Element value = selectField.element("value");
								sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_TYPE", value.getText());
							}
							else if(selectField.attributeValue("name").equalsIgnoreCase("situation")){
								Element value = selectField.element("value");
								sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_SITUATION", value.getText());
							}
							else if(selectField.attributeValue("name").equalsIgnoreCase("outcome")){
								Element value = selectField.element("value");
								sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_OUTCOME", value.getText());
							}
							else if(selectField.attributeValue("name").equalsIgnoreCase("serviceuid")){
								Element value = selectField.element("value");
								sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_SERVICEUID", value.getText());
							}
							else if(selectField.attributeValue("name").equalsIgnoreCase("duration")){
								Element value = selectField.element("value");
								sSelect=setSelectInt(value, sSelect, parameters, MedwanQuery.getInstance(false).datediff("day", "OC_ENCOUNTER_BEGINDATE", "OC_ENCOUNTER_ENDDATE"), Integer.parseInt(value.getText()));
							}
							else if(selectField.attributeValue("name").equalsIgnoreCase("origin")){
								Element value = selectField.element("value");
								sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_ORIGIN", value.getText());
							}
						}
						ps=conn.prepareStatement(sSelect);
						for(int n=0;n<parameters.size();n++){
							Object p = parameters.elementAt(n);
							setParameter(p, ps, n);
						}
						rs=ps.executeQuery();
						if(rs.next()){
							if(filter.elementText("outputvalue").equalsIgnoreCase("duration")){
								output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+rs.getInt("duration")+"</td></tr>");
							}
						}
						rs.close();
						ps.close();
					}
					else if(filter.attributeValue("type").equalsIgnoreCase("income")){
						//We must create a select query
						String sSelect="select count(distinct oc_debet_encounteruid) total, sum(oc_debet_amount) as patientincome,"+
									   " sum(oc_debet_insuraramount) as insurerincome, "+
									   " sum(oc_debet_extrainsuraramount) as extrainsurerincome "+
									   " from oc_patientinvoices, oc_debets, oc_insurances "+
								       " where "+
									   " oc_patientinvoice_status='closed'"+
									   " and oc_insurance_objectid=replace(oc_debet_insuranceuid,'"+MedwanQuery.getInstance(false).getConfigString("serverId")+".','')"+
									   " and oc_debet_patientinvoiceuid='"+MedwanQuery.getInstance(false).getConfigString("serverId")+".'"+MedwanQuery.getInstance(false).concatSign()+"OC_PATIENTINVOICE_OBJECTID";
						Vector parameters = new Vector();
						if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
							sSelect+=" AND OC_PATIENTINVOICE_DATE>=?"+
									" AND OC_PATIENTINVOICE_DATE<?";
							parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
							parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
						}
						Element selectElement = filter.element("select");
						if(selectElement!=null){
							Iterator fields = selectElement.elementIterator("field");
							while(fields.hasNext()){
								Element field = (Element)fields.next();
								if(field.attributeValue("name").equalsIgnoreCase("insureruid")){
									Element value = field.element("value");
									sSelect=setSelectString(value, sSelect, parameters, "oc_insurance_insuraruid", value.getText());
								}
								else if(field.attributeValue("name").equalsIgnoreCase("extrainsureruid")){
									Element value = field.element("value");
									sSelect=setSelectString(value, sSelect, parameters, "oc_debet_extrainsuraruid", value.getText());
								}
								else if(field.attributeValue("name").equalsIgnoreCase("insureramount")){
									Element value = field.element("value");
									sSelect=setSelectInt(value, sSelect, parameters, "oc_debet_insuraramount", Integer.parseInt(value.getText()));
								}
								else if(field.attributeValue("name").equalsIgnoreCase("serviceuid")){
									Element value = field.element("value");
									sSelect=setSelectString(value, sSelect, parameters, "oc_debet_serviceuid", ScreenHelper.checkString(value.getText()));
								}
								else if(field.attributeValue("name").equalsIgnoreCase("patientamount")){
									Element value = field.element("value");
									sSelect=setSelectInt(value, sSelect, parameters, "oc_debet_amount", Integer.parseInt(value.getText()));
								}
							}
						}
						ps=conn.prepareStatement(sSelect);
						for(int n=0;n<parameters.size();n++){
							Object p = parameters.elementAt(n);
							setParameter(p, ps, n);
						}
						rs=ps.executeQuery();
						if(rs.next()){
							if(filter.elementText("outputvalue").equalsIgnoreCase("patientincome")){
								String income=new DecimalFormat(MedwanQuery.getInstance(false).getConfigString("priceFormat","#.00")).format(rs.getDouble("patientincome"));
								output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+income+"</td></tr>");
							}
							else if(filter.elementText("outputvalue").equalsIgnoreCase("insurerincome")){
								String income=new DecimalFormat(MedwanQuery.getInstance(false).getConfigString("priceFormat","#.00")).format(rs.getDouble("insurerincome"));
								output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+income+"</td></tr>");
							}
							else if(filter.elementText("outputvalue").equalsIgnoreCase("extrainsurerincome")){
								String income=new DecimalFormat(MedwanQuery.getInstance(false).getConfigString("priceFormat","#.00")).format(rs.getDouble("extrainsurerincome"));
								output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+income+"</td></tr>");
							}
							else if(filter.elementText("outputvalue").equalsIgnoreCase("totalincome")){
								String income=new DecimalFormat(MedwanQuery.getInstance(false).getConfigString("priceFormat","#.00")).format(rs.getDouble("patientincome")+rs.getDouble("insurerincome")+rs.getDouble("extrainsurerincome"));
								output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+income+"</td></tr>");
							}
							else if(filter.elementText("outputvalue").equalsIgnoreCase("count")){
								output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+rs.getString("total")+"</td></tr>");
							}
						}
						rs.close();
						ps.close();
					}
				}
				else if(result.attributeValue("type").equalsIgnoreCase("counter")){
					//Run through the different filters
					boolean bFirstFilter=true;
					Iterator filters = result.elementIterator("filter");
					while(filters.hasNext()){
						Element filter = (Element)filters.next();
						///////////////////////////////////////////////
						// Encounter filter
						///////////////////////////////////////////////
						if(filter.attributeValue("type").equalsIgnoreCase("encounter")){
							if(bFirstFilter){
								bFirstFilter=false;
								HashSet uniques = new HashSet();
								//We must create a select query
								String sSelect="select * from OC_ENCOUNTERS_VIEW where 1=1";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=" AND OC_ENCOUNTER_STARTDATE>=?"+
											" AND OC_ENCOUNTER_STARTDATE<?"+
											" AND OC_ENCOUNTER_BEGINDATE>=?"+
											" AND OC_ENCOUNTER_BEGINDATE<?"
											;
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								//Also add extra select criteria
								Element selectElement = filter.element("select");
								Iterator selectfields = selectElement.elementIterator("field");
								while(selectfields.hasNext()){
									Element selectField = (Element)selectfields.next();
									if(selectField.attributeValue("name").equalsIgnoreCase("encountertype")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_TYPE", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("situation")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_SITUATION", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("outcome")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_OUTCOME", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("serviceuid")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_SERVICEUID", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("duration")){
										Element value = selectField.element("value");
										sSelect=setSelectInt(value, sSelect, parameters, MedwanQuery.getInstance(false).datediff("day", "OC_ENCOUNTER_BEGINDATE", "OC_ENCOUNTER_ENDDATE"), Integer.parseInt(value.getText()));
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("origin")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_ORIGIN", value.getText());
									}
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String unique="";
									if(ScreenHelper.checkString(filter.attributeValue("unique")).equalsIgnoreCase("encounteruid")){
										unique = rs.getInt("OC_ENCOUNTER_SERVERID")+"."+rs.getInt("OC_ENCOUNTER_OBJECTID");
										if(uniques.contains(unique)){
											continue;
										}
									}
									else if(ScreenHelper.checkString(filter.attributeValue("unique")).equalsIgnoreCase("patientuid")){
										unique = rs.getString("OC_ENCOUNTER_PATIENTUID");
										if(uniques.contains(unique)){
											continue;
										}
									}
									String uid = rs.getInt("OC_ENCOUNTER_SERVERID")+"."+rs.getInt("OC_ENCOUNTER_OBJECTID")+"."+rs.getString("OC_ENCOUNTER_SERVICEUID");
									boolean bMatch = true;
									//First we evaluate the criteria on each resulting row
									Iterator fields = filter.elementIterator("field");
									while(fields.hasNext()){
										Element field = (Element)fields.next();
										if(field.attributeValue("name").equalsIgnoreCase("encountertype")){
											if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_TYPE"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("outcome")){
											if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_OUTCOME"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("serviceuid")){
											if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_SERVICEUID"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("situation")){
											if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_SITUATION"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("duration")){
											if(!evaluateDuration(field.element("value"),rs.getDate("OC_ENCOUNTER_BEGINDATE"),rs.getDate("OC_ENCOUNTER_ENDDATE"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("origin")){
											if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_ORIGIN"),rows,uid)){
												bMatch=false;
												break;
											}
										}
									}
									if(bMatch){
										if(unique.length()>0){
											uniques.add(unique);
										}
										if(rows.get(uid)==null){
											rows.put(uid,new Hashtable());
										}
										Hashtable variables = (Hashtable)rows.get(uid);
										Iterator outputs = filter.elementIterator("output");
										while(outputs.hasNext()){
											Element outputElement = (Element)outputs.next();
											if(outputElement.getText().equalsIgnoreCase("encounteruid")){
												variables.put("encounteruid",rs.getString("OC_ENCOUNTER_SERVERID")+"."+rs.getString("OC_ENCOUNTER_OBJECTID"));
											}
											else if(outputElement.getText().equalsIgnoreCase("patientuid")){
												variables.put("patientuid",rs.getString("OC_ENCOUNTER_PATIENTUID"));
											}
											else if(outputElement.getText().equalsIgnoreCase("serviceuid")){
												variables.put("serviceuid",rs.getString("OC_ENCOUNTER_SERVICEUID"));
											}
										}
									}
								}
								rs.close();
								ps.close();
							}
							else{
								//This is not a first filter, we have to base ourselves on the remaining rows
								Vector rowsToRemove = new Vector();
								Iterator iRows = rows.keySet().iterator();
								while(iRows.hasNext()){
									Object uid = iRows.next();
									Hashtable variables = (Hashtable)rows.get(uid);
									//We must create a select query
									String sSelect="select * from OC_ENCOUNTERS_VIEW where 1=1";
									Vector parameters = new Vector();
									if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
										sSelect+=" AND OC_ENCOUNTER_STARTDATE>=?"+
												" AND OC_ENCOUNTER_STARTDATE<?"+
												" AND OC_ENCOUNTER_BEGINDATE>=?"+
												" AND OC_ENCOUNTER_BEGINDATE<?"
												;
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
									}
									//Also add extra select criteria
									Element selectElement = filter.element("select");
									Iterator selectfields = selectElement.elementIterator("field");
									while(selectfields.hasNext()){
										Element selectField = (Element)selectfields.next();
										Element value = selectField.element("value");
										Object v = value.getText();
										if(value.attributeValue("type").equalsIgnoreCase("variable")){
											v=variables.get(value.getText());
										}
										else if(value.attributeValue("type").equalsIgnoreCase("config")){
											v=MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default")));
										}
										if(selectField.attributeValue("name").equalsIgnoreCase("encountertype")){
											sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_TYPE", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("outcome")){
											sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_OUTCOME", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("serviceuid")){
											sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_SERVICEUID", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("situation")){
											sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_SITUATION", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("duration")){
											sSelect=setSelectInt(value, sSelect, parameters, MedwanQuery.getInstance(false).datediff("day", "OC_ENCOUNTER_BEGINDATE", "OC_ENCOUNTER_ENDDATE"), Integer.parseInt((String)v));
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("patientuid")){
											sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_PATIENTUID", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("origin")){
											sSelect=setSelectString(value, sSelect, parameters, "OC_ENCOUNTER_ORIGIN", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("encounteruid")){
											sSelect=setSelectObjectId(value, sSelect, parameters, "OC_ENCOUNTER_OBJECTID", (String)v);
										}
									}
									ps=conn.prepareStatement(sSelect);
									for(int n=0;n<parameters.size();n++){
										Object p = parameters.elementAt(n);
										setParameter(p, ps, n);
									}
									rs=ps.executeQuery();
									boolean bNoMatch=true;
									while(rs.next()){
										bNoMatch=false;
										boolean bMatch = true;
										//First we evaluate the criteria on each resulting row
										Iterator fields = filter.elementIterator("field");
										while(fields.hasNext()){
											Element field = (Element)fields.next();
											if(field.attributeValue("name").equalsIgnoreCase("encountertype")){
												if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_TYPE"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("situation")){
												if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_SITUATION"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("outcome")){
												if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_OUTCOME"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("duration")){
												if(!evaluateDuration(field.element("value"),rs.getDate("OC_ENCOUNTER_BEGINDATE"),rs.getDate("OC_ENCOUNTER_ENDDATE"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("serviceuid")){
												if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_SERVICEUID"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("origin")){
												if(!evaluateString(field.element("value"),rs.getString("OC_ENCOUNTER_ORIGIN"),rows,uid)){
													bMatch=false;
													break;
												}
											}
										}
										if(!bMatch){
											//This filter does not match the criteria, remove the row
											rowsToRemove.add(uid);
										}
										else {
											break;
										}
									}
									rs.close();
									ps.close();
									if(bNoMatch){
										//This filter does not match the criteria, remove the row
										rowsToRemove.add(uid);
									}
								}
								for(int n=0;n<rowsToRemove.size();n++){
									rows.remove(rowsToRemove.elementAt(n));
								}
							}
						}
						///////////////////////////////////////////////
						// Admin filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("admin")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select a.*,b.sector from AdminView a,PrivateView b where a.personid=b.personid";
								Vector parameters = new Vector();
								//Add select criteria
								Element selectElement = filter.element("select");
								Iterator selectfields = selectElement.elementIterator("field");
								while(selectfields.hasNext()){
									Element selectField = (Element)selectfields.next();
									if(selectField.attributeValue("name").equalsIgnoreCase("patientuid")){
										Element value = selectField.element("value");
										sSelect=setSelectInt(value, sSelect, parameters, "a.personid", Integer.parseInt(value.getText()));
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("sector")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "sector", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("gender")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "gender", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("age")){
										Element value = selectField.element("value");
										java.util.Date birthdate = Miscelaneous.addMonthsToDate(new java.util.Date(), -Integer.parseInt(value.getText()));
										sSelect=setSelectDateReverse(value, sSelect, parameters, "dateofbirth", birthdate);
									}
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("personid");
									boolean bMatch = true;
									//First we evaluate the criteria on each resulting row
									Iterator fields = filter.elementIterator("field");
									while(fields.hasNext()){
										Element field = (Element)fields.next();
										if(field.attributeValue("name").equalsIgnoreCase("patientuid")){
											if(!evaluateInt(field.element("value"),rs.getString("personid"),rows,Integer.parseInt(uid))){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("gender")){
											if(!evaluateString(field.element("value"),rs.getString("gender"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("sector")){
											if(!evaluateString(field.element("value"),rs.getString("sector"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("age")){
											java.util.Date birthdate = Miscelaneous.addMonthsToDate(new java.util.Date(), -Integer.parseInt(field.element("value").getText()));
											if(!evaluateDateReverse(field.element("value"),rs.getDate("dateofbirth"),rows,uid,birthdate)){
												bMatch=false;
												break;
											}
										}
									}
									if(bMatch){
										if(rows.get(uid)==null){
											rows.put(uid,new Hashtable());
										}
										Hashtable variables = (Hashtable)rows.get(uid);
										Iterator outputs = filter.elementIterator("output");
										while(outputs.hasNext()){
											Element outputElement = (Element)outputs.next();
											if(outputElement.getText().equalsIgnoreCase("patientuid")){
												variables.put("patientuid",uid);
											}
											else if(outputElement.getText().equalsIgnoreCase("gender")){
												variables.put("gender",rs.getString("gender"));
											}
											else if(outputElement.getText().equalsIgnoreCase("sector")){
												variables.put("sector",rs.getString("sector"));
											}
										}
									}
								}
								rs.close();
								ps.close();
							}
							else{
								//This is not a first filter, we have to base ourselves on the remaining rows
								Vector rowsToRemove = new Vector();
								Iterator iRows = rows.keySet().iterator();
								while(iRows.hasNext()){
									Object uid = iRows.next();
									Hashtable variables = (Hashtable)rows.get(uid);
									//We must create a select query
									String sSelect="select a.*,b.sector from AdminView a,PrivateView b where a.personid=b.personid";
									Vector parameters = new Vector();
									//Add select criteria
									Element selectElement = filter.element("select");
									Iterator selectfields = selectElement.elementIterator("field");
									while(selectfields.hasNext()){
										Element selectField = (Element)selectfields.next();
										Element value = selectField.element("value");
										Object v = value.getText();
										if(value.attributeValue("type").equalsIgnoreCase("variable")){
											v=variables.get(value.getText());
										}
										else if(value.attributeValue("type").equalsIgnoreCase("config")){
											v=MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default")));
										}
										if(selectField.attributeValue("name").equalsIgnoreCase("patientuid")){
											sSelect=setSelectInt(value, sSelect, parameters, "a.personid", Integer.parseInt((String)v));
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("gender")){
											sSelect=setSelectString(value, sSelect, parameters, "gender", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("sector")){
											sSelect=setSelectString(value, sSelect, parameters, "sector", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("age")){
											java.util.Date birthdate = Miscelaneous.addMonthsToDate(new java.util.Date(), -Integer.parseInt((String)v));
											sSelect=setSelectDateReverse(value, sSelect, parameters, "dateofbirth", birthdate);
										}
									}
									ps=conn.prepareStatement(sSelect);
									for(int n=0;n<parameters.size();n++){
										Object p = parameters.elementAt(n);
										setParameter(p, ps, n);
									}
									rs=ps.executeQuery();
									boolean bNoMatch=true;
									while(rs.next()){
										boolean bMatch = true;
										bNoMatch=false;
										//First we evaluate the criteria on each resulting row
										Iterator fields = filter.elementIterator("field");
										while(fields.hasNext()){
											Element field = (Element)fields.next();
											if(field.attributeValue("name").equalsIgnoreCase("patientuid")){
												if(!evaluateInt(field.element("value"),rs.getString("personid"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("gender")){
												if(!evaluateString(field.element("value"),rs.getString("gender"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("sector")){
												if(!evaluateString(field.element("value"),rs.getString("sector"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("age")){
												java.util.Date birthdate = Miscelaneous.addMonthsToDate(new java.util.Date(), -Integer.parseInt(field.element("value").getText()));
												if(!evaluateDateReverse(field.element("value"),rs.getDate("dateofbirth"),rows,uid,birthdate)){
													bMatch=false;
													break;
												}
											}
										}
										if(!bMatch){
											//This filter does not match the criteria, remove the row
											rowsToRemove.add(uid);
										}
										else {
											break;
										}
									}
									rs.close();
									ps.close();
									if(bNoMatch){
										//This filter does not match the criteria, remove the row
										rowsToRemove.add(uid);
									}
								}
								for(int n=0;n<rowsToRemove.size();n++){
									rows.remove(rowsToRemove.elementAt(n));
								}
							}
						}
						///////////////////////////////////////////////
						// Transaction filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("transaction")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select * from Healthrecord h,Transactions t where h.healthrecordid=t.healthrecordid";
								//If there are also item criteria in the select, then we have to adapt the query
								if(filter.element("select")!=null && filter.element("select").element("item")!=null){
									sSelect="select * from Healthrecord h,Transactions t,Items i where h.healthrecordid=t.healthrecordid and t.serverid=i.serverid and t.transactionid=i.transactionid";
								}
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=" AND t.updatetime>=?"+
											" AND t.updatetime<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								//Add select criteria
								Element selectElement = filter.element("select");
								Iterator selectfields = selectElement.elementIterator("field");
								while(selectfields.hasNext()){
									Element selectField = (Element)selectfields.next();
									if(selectField.attributeValue("name").equalsIgnoreCase("patientuid")){
										Element value = selectField.element("value");
										sSelect=setSelectInt(value, sSelect, parameters, "personid", Integer.parseInt(value.getText()));
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("transactiontype")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "transactiontype", value.getText());
									}
								}
								Iterator itemfields = selectElement.elementIterator("item");
								while(itemfields.hasNext()){
									Element itemfield = (Element)itemfields.next();
									if(ScreenHelper.checkString(itemfield.attributeValue("type")).length()>0){
										sSelect=setSelectItemType(itemfield.attributeValue("type"), sSelect,parameters);
									}
									Element value = itemfield.element("value");
									if(value!=null){
										sSelect=setSelectItemValue(value, sSelect,parameters,rows,null);
									}
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("transactionid");
									boolean bMatch = true;
									//First we evaluate the criteria on each resulting row
									Iterator fields = filter.elementIterator("field");
									while(fields.hasNext()){
										Element field = (Element)fields.next();
										if(field.attributeValue("name").equalsIgnoreCase("patientuid")){
											if(!evaluateInt(field.element("value"),rs.getString("personid"),rows,Integer.parseInt(uid))){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("transactiontype")){
											if(!evaluateString(field.element("value"),rs.getString("transactiontype"),rows,uid)){
												bMatch=false;
												break;
											}
										}
									}
									if(filter.element("item")!=null){
										//We must now load all items from the transaction
										TransactionVO transaction = MedwanQuery.getInstance(false).loadTransaction(MedwanQuery.getInstance(false).getConfigInt("serverId"), rs.getInt("transactionid"));
										Iterator items = filter.elementIterator("item");
										while(items.hasNext()){
											Element itemelement = (Element)items.next();
											if(ScreenHelper.checkString(itemelement.attributeValue("type")).length()>0){
												ItemVO itemVO = transaction.getItem(itemelement.attributeValue("type"));
												if(itemVO==null){
													bMatch=false;
													break;
												}
												else{
													Element value = itemelement.element("value");
													if(value!=null && !evaluateString(value,itemVO.getValue(), rows, uid)){
														bMatch=false;
														break;
													}
												}
											}
										}
									}
									if(bMatch){
										if(rows.get(uid)==null){
											rows.put(uid,new Hashtable());
										}
										Hashtable variables = (Hashtable)rows.get(uid);
										Iterator outputs = filter.elementIterator("output");
										while(outputs.hasNext()){
											Element outputElement = (Element)outputs.next();
											if(outputElement.getText().equalsIgnoreCase("patientuid")){
												variables.put("patientuid",rs.getString("personid"));
											}
											else if(outputElement.getText().equalsIgnoreCase("transactionid")){
												variables.put("transactionid",uid);
											}
											else if(outputElement.getText().equalsIgnoreCase("transactiontype")){
												variables.put("transactiontype",rs.getString("transactiontype"));
											}
											else if(outputElement.getText().equalsIgnoreCase("itemvalue")){
												variables.put("itemvalue",rs.getString("value"));
											}
										}
									}
								}
								rs.close();
								ps.close();
							}
							else{
								//This is not a first filter, we have to base ourselves on the remaining rows
								Vector rowsToRemove = new Vector();
								Iterator iRows = rows.keySet().iterator();
								while(iRows.hasNext()){
									Object uid = iRows.next();
									Hashtable variables = (Hashtable)rows.get(uid);
									//We must create a select query
									String sSelect="select * from Healthrecord h,Transactions t where h.healthrecordid=t.healthrecordid";
									//If there are also item criteria in the select, then we have to adapt the query
									if(filter.element("select")!=null && filter.element("select").element("item")!=null){
										sSelect="select * from Healthrecord h,Transactions t,Items i where h.healthrecordid=t.healthrecordid and t.serverid=i.serverid and t.transactionid=i.transactionid";
									}
									Vector parameters = new Vector();
									if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
										sSelect+=" AND t.updatetime>=?"+
												" AND t.updatetime<?";
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
									}
									//Add select criteria
									Element selectElement = filter.element("select");
									Iterator selectfields = selectElement.elementIterator("field");
									while(selectfields.hasNext()){
										Element selectField = (Element)selectfields.next();
										Element value = selectField.element("value");
										Object v = value.getText();
										if(value.attributeValue("type").equalsIgnoreCase("variable")){
											v=variables.get(value.getText());
										}
										else if(value.attributeValue("type").equalsIgnoreCase("config")){
											v=MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default")));
										}
										if(selectField.attributeValue("name").equalsIgnoreCase("patientuid")){
											sSelect=setSelectInt(value, sSelect, parameters, "personid", Integer.parseInt((String)v));
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("transactiontype")){
											sSelect=setSelectString(value, sSelect, parameters, "transactiontype", (String)v);
										}
									}
									Iterator itemfields = selectElement.elementIterator("item");
									while(itemfields.hasNext()){
										Element itemfield = (Element)itemfields.next();
										if(ScreenHelper.checkString(itemfield.attributeValue("type")).length()>0){
											sSelect=setSelectItemType(itemfield.attributeValue("type"), sSelect,parameters);
										}
										Element value = itemfield.element("value");
										if(value!=null){
											sSelect=setSelectItemValue(value, sSelect,parameters, rows, uid);
										}
									}
									ps=conn.prepareStatement(sSelect);
									for(int n=0;n<parameters.size();n++){
										Object p = parameters.elementAt(n);
										setParameter(p, ps, n);
									}
									rs=ps.executeQuery();
									boolean bNoMatch=true;
									while(rs.next()){
										boolean bMatch = true;
										bNoMatch=false;
										//First we evaluate the criteria on each resulting row
										Iterator fields = filter.elementIterator("field");
										while(fields.hasNext()){
											Element field = (Element)fields.next();
											if(field.attributeValue("name").equalsIgnoreCase("patientuid")){
												if(!evaluateInt(field.element("value"),rs.getString("personid"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("transactiontype")){
												if(!evaluateString(field.element("value"),rs.getString("transactiontype"),rows,uid)){
													bMatch=false;
													break;
												}
											}
										}
										if(filter.element("item")!=null){
											//We must now load all items from the transaction
											TransactionVO transaction = MedwanQuery.getInstance(false).loadTransaction(MedwanQuery.getInstance(false).getConfigInt("serverId"), rs.getInt("transactionid"));
											Iterator items = filter.elementIterator("item");
											while(items.hasNext()){
												Element itemelement = (Element)items.next();
												if(ScreenHelper.checkString(itemelement.attributeValue("type")).length()>0){
													ItemVO itemVO = transaction.getItem(itemelement.attributeValue("type"));
													if(itemVO==null){
														bMatch=false;
														break;
													}
													else{
														Element value = itemelement.element("value");
														if(value!=null && !evaluateString(value,itemVO.getValue(), rows, uid)){
															bMatch=false;
															break;
														}
													}
												}
											}
										}
										if(!bMatch){
											//This filter does not match the criteria, remove the row
											rowsToRemove.add(uid);
										}
										else {
											break;
										}
									}
									rs.close();
									ps.close();
									if(bNoMatch){
										//This filter does not match the criteria, remove the row
										rowsToRemove.add(uid);
									}
								}
								for(int n=0;n<rowsToRemove.size();n++){
									rows.remove(rowsToRemove.elementAt(n));
								}
							}
						}
						///////////////////////////////////////////////
						// RFE filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("rfe")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select * from OC_RFE where 1=1";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=" AND oc_rfe_date>=?"+
											" AND oc_rfe_date<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								//Add select criteria
								Element selectElement = filter.element("select");
								Iterator selectfields = selectElement.elementIterator("field");
								while(selectfields.hasNext()){
									Element selectField = (Element)selectfields.next();
									if(selectField.attributeValue("name").equalsIgnoreCase("encounteruid")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_encounteruid", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("rfeflags")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_flags", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("rfecodetype")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_codetype", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("rfecode")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_code", value.getText());
									}
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("oc_rfe_serverid")+"."+rs.getString("oc_rfe_objectid");
									boolean bMatch = true;
									//First we evaluate the criteria on each resulting row
									Iterator fields = filter.elementIterator("field");
									while(fields.hasNext()){
										Element field = (Element)fields.next();
										if(field.attributeValue("name").equalsIgnoreCase("encounteruid")){
											if(!evaluateString(field.element("value"),rs.getString("oc_rfe_encounteruid"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("rfeflags")){
											if(!evaluateString(field.element("value"),rs.getString("oc_rfe_flags"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("rfecodetype")){
											if(!evaluateString(field.element("value"),rs.getString("oc_rfe_codetype"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("rfecode")){
											if(!evaluateString(field.element("value"),rs.getString("oc_rfe_code"),rows,uid)){
												bMatch=false;
												break;
											}
										}
									}
									if(bMatch){
										if(rows.get(uid)==null){
											rows.put(uid,new Hashtable());
										}
										Hashtable variables = (Hashtable)rows.get(uid);
										Iterator outputs = filter.elementIterator("output");
										while(outputs.hasNext()){
											Element outputElement = (Element)outputs.next();
											if(outputElement.getText().equalsIgnoreCase("encounteruid")){
												variables.put("encounteruid",rs.getString("oc_rfe_encounteruid"));
											}
											else if(outputElement.getText().equalsIgnoreCase("rfeuid")){
												variables.put("rfeuid",uid);
											}
											else if(outputElement.getText().equalsIgnoreCase("rfeflags")){
												variables.put("rfeflags",rs.getString("oc_rfe_flags"));
											}
											else if(outputElement.getText().equalsIgnoreCase("rfecodetype")){
												variables.put("rfecodetype",rs.getString("oc_rfe_codetype"));
											}
											else if(outputElement.getText().equalsIgnoreCase("rfecode")){
												variables.put("rfecode",rs.getString("oc_rfe_code"));
											}
										}
									}
								}
								rs.close();
								ps.close();
							}
							else{
								//This is not a first filter, we have to base ourselves on the remaining rows
								Vector rowsToRemove = new Vector();
								Iterator iRows = rows.keySet().iterator();
								while(iRows.hasNext()){
									Object uid = iRows.next();
									Hashtable variables = (Hashtable)rows.get(uid);
									//We must create a select query
									String sSelect="select * from OC_RFE where 1=1";
									Vector parameters = new Vector();
									if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
										sSelect+=" AND oc_rfe_date>=?"+
												" AND oc_rfe_date<?";
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
									}
									//Add select criteria
									Element selectElement = filter.element("select");
									Iterator selectfields = selectElement.elementIterator("field");
									while(selectfields.hasNext()){
										Element selectField = (Element)selectfields.next();
										Element value = selectField.element("value");
										Object v = value.getText();
										if(value.attributeValue("type").equalsIgnoreCase("variable")){
											v=variables.get(value.getText());
										}
										else if(value.attributeValue("type").equalsIgnoreCase("config")){
											v=MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default")));
										}
										if(selectField.attributeValue("name").equalsIgnoreCase("encounteruid")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_encounteruid", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("rfeflags")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_flags", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("rfecodetype")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_codetype", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("rfecode")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_rfe_code", (String)v);
										}
									}
									ps=conn.prepareStatement(sSelect);
									for(int n=0;n<parameters.size();n++){
										Object p = parameters.elementAt(n);
										setParameter(p, ps, n);
									}
									rs=ps.executeQuery();
									boolean bNoMatch=true;
									while(rs.next()){
										boolean bMatch = true;
										bNoMatch=false;
										//First we evaluate the criteria on each resulting row
										Iterator fields = filter.elementIterator("field");
										while(fields.hasNext()){
											Element field = (Element)fields.next();
											if(field.attributeValue("name").equalsIgnoreCase("encounteruid")){
												if(!evaluateString(field.element("value"),rs.getString("oc_rfe_encounteruid"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("rfeflags")){
												if(!evaluateString(field.element("value"),rs.getString("oc_rfe_flags"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("rfecodetype")){
												if(!evaluateString(field.element("value"),rs.getString("oc_rfe_codetype"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("rfecode")){
												if(!evaluateString(field.element("value"),rs.getString("oc_rfe_code"),rows,uid)){
													bMatch=false;
													break;
												}
											}
										}
										if(!bMatch){
											//This filter does not match the criteria, remove the row
											rowsToRemove.add(uid);
										}
										else {
											break;
										}
									}
									rs.close();
									ps.close();
									if(bNoMatch){
										//This filter does not match the criteria, remove the row
										rowsToRemove.add(uid);
									}
								}
								for(int n=0;n<rowsToRemove.size();n++){
									rows.remove(rowsToRemove.elementAt(n));
								}
							}
						}
						///////////////////////////////////////////////
						// Diagnosis filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("diagnosis")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select * from OC_DIAGNOSES where 1=1";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=" AND oc_diagnosis_date>=?"+
											" AND oc_diagnosis_date<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								//Add select criteria
								Element selectElement = filter.element("select");
								Iterator selectfields = selectElement.elementIterator("field");
								while(selectfields.hasNext()){
									Element selectField = (Element)selectfields.next();
									if(selectField.attributeValue("name").equalsIgnoreCase("encounteruid")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_encounteruid", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("diagnosisflags")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_flags", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("diagnosiscodetype")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_codetype", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("diagnosiscode")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_code", value.getText());
									}
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("oc_diagnosis_serverid")+"."+rs.getString("oc_diagnosis_objectid");
									boolean bMatch = true;
									//First we evaluate the criteria on each resulting row
									Iterator fields = filter.elementIterator("field");
									while(fields.hasNext()){
										Element field = (Element)fields.next();
										if(field.attributeValue("name").equalsIgnoreCase("encounteruid")){
											if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_encounteruid"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("diagnosisflags")){
											if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_flags"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("diagnosiscodetype")){
											if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_codetype"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("diagnosiscode")){
											if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_code"),rows,uid)){
												bMatch=false;
												break;
											}
										}
									}
									if(bMatch){
										if(rows.get(uid)==null){
											rows.put(uid,new Hashtable());
										}
										Hashtable variables = (Hashtable)rows.get(uid);
										Iterator outputs = filter.elementIterator("output");
										while(outputs.hasNext()){
											Element outputElement = (Element)outputs.next();
											if(outputElement.getText().equalsIgnoreCase("encounteruid")){
												variables.put("encounteruid",rs.getString("oc_diagnosis_encounteruid"));
											}
											else if(outputElement.getText().equalsIgnoreCase("diagnosisuid")){
												variables.put("diagnosisuid",uid);
											}
											else if(outputElement.getText().equalsIgnoreCase("diagnosisflags")){
												variables.put("diagnosisflags",rs.getString("oc_diagnosis_flags"));
											}
											else if(outputElement.getText().equalsIgnoreCase("rfecodetype")){
												variables.put("diagnosiscodetype",rs.getString("oc_rfe_codetype"));
											}
											else if(outputElement.getText().equalsIgnoreCase("rfecode")){
												variables.put("diagnosiscode",rs.getString("oc_diagnosis_code"));
											}
										}
									}
								}
								rs.close();
								ps.close();
							}
							else{
								//This is not a first filter, we have to base ourselves on the remaining rows
								Vector rowsToRemove = new Vector();
								Iterator iRows = rows.keySet().iterator();
								while(iRows.hasNext()){
									Object uid = iRows.next();
									Hashtable variables = (Hashtable)rows.get(uid);
									//We must create a select query
									String sSelect="select * from OC_DIAGNOSES where 1=1";
									Vector parameters = new Vector();
									if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
										sSelect+=" AND oc_diagnosis_date>=?"+
												" AND oc_diagnosis_date<?";
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
									}
									//Add select criteria
									Element selectElement = filter.element("select");
									Iterator selectfields = selectElement.elementIterator("field");
									while(selectfields.hasNext()){
										Element selectField = (Element)selectfields.next();
										Element value = selectField.element("value");
										Object v = value.getText();
										if(value.attributeValue("type").equalsIgnoreCase("variable")){
											v=variables.get(value.getText());
										}
										else if(value.attributeValue("type").equalsIgnoreCase("config")){
											v=MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default")));
										}
										if(selectField.attributeValue("name").equalsIgnoreCase("encounteruid")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_encounteruid", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("diagnosisflags")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_flags", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("diagnosiscodetype")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_codetype", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("diagnosiscode")){
											sSelect=setSelectString(value, sSelect, parameters, "oc_diagnosis_code", (String)v);
										}
									}
									ps=conn.prepareStatement(sSelect);
									for(int n=0;n<parameters.size();n++){
										Object p = parameters.elementAt(n);
										setParameter(p, ps, n);
									}
									rs=ps.executeQuery();
									boolean bNoMatch=true;
									while(rs.next()){
										boolean bMatch = true;
										bNoMatch=false;
										//First we evaluate the criteria on each resulting row
										Iterator fields = filter.elementIterator("field");
										while(fields.hasNext()){
											Element field = (Element)fields.next();
											if(field.attributeValue("name").equalsIgnoreCase("encounteruid")){
												if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_encounteruid"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("diagnosisflags")){
												if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_flags"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("diagnosiscodetype")){
												if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_codetype"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("diagnosiscode")){
												if(!evaluateString(field.element("value"),rs.getString("oc_diagnosis_code"),rows,uid)){
													bMatch=false;
													break;
												}
											}
										}
										if(!bMatch){
											//This filter does not match the criteria, remove the row
											rowsToRemove.add(uid);
										}
										else {
											break;
										}
									}
									rs.close();
									ps.close();
									if(bNoMatch){
										//This filter does not match the criteria, remove the row
										rowsToRemove.add(uid);
									}
								}
								for(int n=0;n<rowsToRemove.size();n++){
									rows.remove(rowsToRemove.elementAt(n));
								}
							}
						}
						///////////////////////////////////////////////
						// Labanalysis filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("labanalysis")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select * from requestedlabanalyses where 1=1";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=" AND resultdate>=?"+
											" AND resultdate<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								//Add select criteria
								Element selectElement = filter.element("select");
								Iterator selectfields = selectElement.elementIterator("field");
								while(selectfields.hasNext()){
									Element selectField = (Element)selectfields.next();
									if(selectField.attributeValue("name").equalsIgnoreCase("transactionid")){
										Element value = selectField.element("value");
										sSelect=setSelectInt(value, sSelect, parameters, "transactionid", Integer.parseInt(value.getText()));
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("patientuid")){
										Element value = selectField.element("value");
										sSelect=setSelectInt(value, sSelect, parameters, "patientid", Integer.parseInt(value.getText()));
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("analysiscode")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "analysiscode", value.getText());
									}
									else if(selectField.attributeValue("name").equalsIgnoreCase("analysisresult")){
										Element value = selectField.element("value");
										sSelect=setSelectString(value, sSelect, parameters, "resultvalue", value.getText());
									}
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("serverid")+"."+rs.getString("transactionid")+"."+rs.getString("analysiscode");
									boolean bMatch = true;
									//First we evaluate the criteria on each resulting row
									Iterator fields = filter.elementIterator("field");
									while(fields.hasNext()){
										Element field = (Element)fields.next();
										if(field.attributeValue("name").equalsIgnoreCase("transactionid")){
											if(!evaluateString(field.element("value"),rs.getString("transactionid"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("patientuid")){
											if(!evaluateString(field.element("value"),rs.getString("patientid"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("analysiscode")){
											if(!evaluateString(field.element("value"),rs.getString("analysiscode"),rows,uid)){
												bMatch=false;
												break;
											}
										}
										else if(field.attributeValue("name").equalsIgnoreCase("analysisresult")){
											if(!evaluateString(field.element("value"),rs.getString("resultvalue"),rows,uid)){
												bMatch=false;
												break;
											}
										}
									}
									if(bMatch){
										if(rows.get(uid)==null){
											rows.put(uid,new Hashtable());
										}
										Hashtable variables = (Hashtable)rows.get(uid);
										Iterator outputs = filter.elementIterator("output");
										while(outputs.hasNext()){
											Element outputElement = (Element)outputs.next();
											if(outputElement.getText().equalsIgnoreCase("transactionid")){
												variables.put("transactionid",rs.getString("transactionid"));
											}
											else if(outputElement.getText().equalsIgnoreCase("labanalysisuid")){
												variables.put("labanalysisuid",uid);
											}
											else if(outputElement.getText().equalsIgnoreCase("patientuid")){
												variables.put("patientuid",rs.getString("patientid"));
											}
											else if(outputElement.getText().equalsIgnoreCase("analysiscode")){
												variables.put("analysiscode",rs.getString("analysiscode"));
											}
										}
									}
								}
								rs.close();
								ps.close();
							}
							else{
								//This is not a first filter, we have to base ourselves on the remaining rows
								Vector rowsToRemove = new Vector();
								Iterator iRows = rows.keySet().iterator();
								while(iRows.hasNext()){
									Object uid = iRows.next();
									Hashtable variables = (Hashtable)rows.get(uid);
									//We must create a select query
									String sSelect="select * from requestedlabanalyses where 1=1";
									Vector parameters = new Vector();
									if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
										sSelect+=" AND resultdate>=?"+
												" AND resultdate<?";
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
										parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
									}
									//Add select criteria
									Element selectElement = filter.element("select");
									Iterator selectfields = selectElement.elementIterator("field");
									while(selectfields.hasNext()){
										Element selectField = (Element)selectfields.next();
										Element value = selectField.element("value");
										Object v = value.getText();
										if(value.attributeValue("type").equalsIgnoreCase("variable")){
											v=variables.get(value.getText());
										}
										else if(value.attributeValue("type").equalsIgnoreCase("config")){
											v=MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default")));
										}
										if(selectField.attributeValue("name").equalsIgnoreCase("transactionid")){
											sSelect=setSelectInt(value, sSelect, parameters, "transactionid", Integer.parseInt((String)v));
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("patientuid")){
											sSelect=setSelectInt(value, sSelect, parameters, "patientid", Integer.parseInt((String)v));
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("analysiscode")){
											sSelect=setSelectString(value, sSelect, parameters, "analysiscode", (String)v);
										}
										else if(selectField.attributeValue("name").equalsIgnoreCase("analysisresult")){
											sSelect=setSelectString(value, sSelect, parameters, "resultvalue", value.getText());
										}
									}
									ps=conn.prepareStatement(sSelect);
									for(int n=0;n<parameters.size();n++){
										Object p = parameters.elementAt(n);
										setParameter(p, ps, n);
									}
									rs=ps.executeQuery();
									boolean bNoMatch=true;
									while(rs.next()){
										boolean bMatch = true;
										bNoMatch=false;
										//First we evaluate the criteria on each resulting row
										Iterator fields = filter.elementIterator("field");
										while(fields.hasNext()){
											Element field = (Element)fields.next();
											if(field.attributeValue("name").equalsIgnoreCase("transactionid")){
												if(!evaluateInt(field.element("value"),rs.getString("transactionid"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("patientuid")){
												if(!evaluateInt(field.element("value"),rs.getString("patientid"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("analysiscode")){
												if(!evaluateString(field.element("value"),rs.getString("analysiscode"),rows,uid)){
													bMatch=false;
													break;
												}
											}
											else if(field.attributeValue("name").equalsIgnoreCase("analysisresult")){
												if(!evaluateString(field.element("value"),rs.getString("resultvalue"),rows,uid)){
													bMatch=false;
													break;
												}
											}
										}
										if(!bMatch){
											//This filter does not match the criteria, remove the row
											rowsToRemove.add(uid);
										}
										else {
											break;
										}
									}
									rs.close();
									ps.close();
									if(bNoMatch){
										//This filter does not match the criteria, remove the row
										rowsToRemove.add(uid);
									}
								}
								for(int n=0;n<rowsToRemove.size();n++){
									rows.remove(rowsToRemove.elementAt(n));
								}
							}
						}
						///////////////////////////////////////////////
						// PACS filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("pacs")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select * from OC_PACS where 1=1";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=	" AND OC_PACS_UPDATETIME>=?"+
												" AND OC_PACS_UPDATETIME<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("oc_pacs_filename");
									if(rows.get(uid)==null){
										rows.put(uid,new Hashtable());
									}
								}
								rs.close();
								ps.close();
							}
						}
						///////////////////////////////////////////////
						// PACS filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("pacspatients")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select distinct healthrecordid from OC_PACS,items i,transactions t where 1=1 AND value=oc_pacs_studyuid and i.transactionid=t.transactionid";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=	" AND OC_PACS_UPDATETIME>=?"+
												" AND OC_PACS_UPDATETIME<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("healthrecordid");
									if(rows.get(uid)==null){
										rows.put(uid,new Hashtable());
									}
								}
								rs.close();
								ps.close();
							}
						}
						///////////////////////////////////////////////
						// PACS STUDY filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("pacsstudy")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select distinct oc_pacs_studyuid from OC_PACS where 1=1";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=	" AND OC_PACS_UPDATETIME>=?"+
												" AND OC_PACS_UPDATETIME<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("oc_pacs_studyuid");
									if(rows.get(uid)==null){
										rows.put(uid,new Hashtable());
									}
								}
								rs.close();
								ps.close();
							}
						}
						///////////////////////////////////////////////
						// PACS SERIES filter
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("pacsseries")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String sSelect="select distinct oc_pacs_studyuid,oc_pacs_series from OC_PACS where 1=1";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=	" AND OC_PACS_UPDATETIME>=?"+
												" AND OC_PACS_UPDATETIME<?";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("oc_pacs_studyuid")+"."+rs.getString("oc_pacs_series");
									if(rows.get(uid)==null){
										rows.put(uid,new Hashtable());
									}
								}
								rs.close();
								ps.close();
							}
						}
						///////////////////////////////////////////////
						// DRUGS DISPENSING FILTER
						///////////////////////////////////////////////
						else if(filter.attributeValue("type").equalsIgnoreCase("drugdispensing")){
							if(bFirstFilter){
								bFirstFilter=false;
								//We must create a select query
								String pharmacies = "''";
								String[] par = ScreenHelper.checkString(filter.attributeValue("pharmacies")).split(",");
								for(int n=0;n<par.length;n++){
									pharmacies+=",'"+par[n]+"'";
								}
								String sSelect="select * from oc_productstockoperations,oc_productstocks where oc_operation_description = 'medicationdelivery.1' and oc_operation_srcdesttype = 'patient' and oc_stock_objectid=replace(oc_operation_productstockuid,'1.','')";
								Vector parameters = new Vector();
								if(filter.attributeValue("periodfilter").equalsIgnoreCase("true")){
									sSelect+=	" AND OC_OPERATION_DATE>=?"+
												" AND OC_OPERATION_DATE<?"+
												" AND OC_STOCK_SERVICESTOCKUID in ("+pharmacies+")";
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(begin).getTime()));
									parameters.add(new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
								}
								ps=conn.prepareStatement(sSelect);
								for(int n=0;n<parameters.size();n++){
									Object p = parameters.elementAt(n);
									setParameter(p, ps, n);
								}
								rs=ps.executeQuery();
								while(rs.next()){
									String uid = rs.getString("oc_operation_encounteruid");
									if(rows.get(uid)==null){
										rows.put(uid,new Hashtable());
									}
								}
								rs.close();
								ps.close();
							}
						}
					}
					//This is the end of the counter result, output the counter
					int counter=rows.size();
					if(ScreenHelper.checkString(result.attributeValue("count")).length()>0){
						//We must count distinct values from the result rows
						HashSet hRows = new HashSet();
						Iterator iRows = rows.keySet().iterator();
						while(iRows.hasNext()){
							Object uid = iRows.next();
							Object value = ((Hashtable)rows.get(uid)).get(result.attributeValue("count"));
							if(value!=null){
								hRows.add(value);
							}
							counter=hRows.size();
						}
					}
					if(ScreenHelper.checkString(result.element("label").attributeValue("style")).equalsIgnoreCase("bold")){
						output.append("<tr><td><b>"+result.element("label").getText()+"</b></td><td><b>"+counter+"</b></td></tr>");
					}
					else if(ScreenHelper.checkString(result.element("label").attributeValue("style")).equalsIgnoreCase("italic")){
						output.append("<tr><td><i>"+result.element("label").getText()+"</i></td><td><i>"+counter+"</i></td></tr>");
					}
					else if(ScreenHelper.checkString(result.element("label").attributeValue("style")).equalsIgnoreCase("underline")){
						output.append("<tr><td><u>"+result.element("label").getText()+"</u></td><td><u>"+counter+"</u></td></tr>");
					}
					else{
						output.append("<tr><td>"+result.element("label").getText()+"</td><td>"+counter+"</td></tr>");
					}
				}
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
			}
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		output.append("</table>");
		return output;	
	}
	
	static boolean evaluateString(Element value,String s,SortedMap rows,Object rowid){
		s=ScreenHelper.checkString(s);
		if(value.attributeValue("compare").equalsIgnoreCase("equals")){
			if(value.attributeValue("type").equalsIgnoreCase("constant")){
				return s.equalsIgnoreCase(value.getText());
			}
			else if(value.attributeValue("type").equalsIgnoreCase("config")){
				return s.equalsIgnoreCase(MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				return s.equalsIgnoreCase((String)((Hashtable)rows.get(rowid)).get(value.getText()));
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
			if(value.attributeValue("type").equalsIgnoreCase("constant")){
				return !s.equalsIgnoreCase(value.getText());
			}
			else if(value.attributeValue("type").equalsIgnoreCase("config")){
				return !s.equalsIgnoreCase(MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				return !s.equalsIgnoreCase((String)((Hashtable)rows.get(rowid)).get(value.getText()));
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("contains")){
			if(value.attributeValue("type").equalsIgnoreCase("constant")){
				return s.contains(value.getText());
			}
			else if(value.attributeValue("type").equalsIgnoreCase("config")){
				return s.contains(MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				return s.contains((String)((Hashtable)rows.get(rowid)).get(value.getText()));
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notcontains")){
			if(value.attributeValue("type").equalsIgnoreCase("constant")){
				return !s.contains(value.getText());
			}
			else if(value.attributeValue("type").equalsIgnoreCase("config")){
				return !s.contains(MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				return !s.contains((String)((Hashtable)rows.get(rowid)).get(value.getText()));
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("in")){
			boolean bReturn = false;
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				String elements[] = MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))).split(";");
				for(int n=0;n<elements.length;n++){
					if(elements[n].equalsIgnoreCase(s)){
						bReturn = true;
						break;
					}
				}
			}
			else{
				Iterator elements = value.elementIterator("element");
				while(elements.hasNext()){
					Element element = (Element)elements.next();
					if(element.getText().equalsIgnoreCase(s)){
						bReturn = true;
						break;
					}
				}
			}
			return bReturn;
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notin")){
			boolean bReturn = true;
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				String elements[] = MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))).split(";");
				for(int n=0;n<elements.length;n++){
					if(elements[n].equalsIgnoreCase(s)){
						bReturn = false;
						break;
					}
				}
			}
			else{
				Iterator elements = value.elementIterator("element");
				while(elements.hasNext()){
					Element element = (Element)elements.next();
					if(element.getText().equalsIgnoreCase(s)){
						bReturn = false;
						break;
					}
				}
			}
			return bReturn;
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("inlike")){
			boolean bReturn = false;
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				String elements[] = MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))).split(";");
				for(int n=0;n<elements.length;n++){
					if(s.startsWith(elements[n])){
						bReturn = true;
						break;
					}
				}
			}
			else{
				Iterator elements = value.elementIterator("element");
				while(elements.hasNext()){
					Element element = (Element)elements.next();
					if(s.startsWith(element.getText())){
						bReturn = true;
						break;
					}
				}
			}
			return bReturn;
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notinlike")){
			boolean bReturn = true;
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				String elements[] = MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))).split(";");
				for(int n=0;n<elements.length;n++){
					if(s.startsWith(elements[n])){
						bReturn = false;
						break;
					}
				}
			}
			else{
				Iterator elements = value.elementIterator("element");
				while(elements.hasNext()){
					Element element = (Element)elements.next();
					if(s.startsWith(element.getText())){
						bReturn = false;
						break;
					}
				}
			}
			return bReturn;
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notincontains")){
			boolean bReturn = true;
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				String elements[] = MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))).split(";");
				for(int n=0;n<elements.length;n++){
					if(s.contains(elements[n])){
						bReturn = false;
						break;
					}
				}
			}
			else{
				Iterator elements = value.elementIterator("element");
				while(elements.hasNext()){
					Element element = (Element)elements.next();
					if(s.contains(element.getText())){
						bReturn = false;
						break;
					}
				}
			}
			return bReturn;
		}
		else{
			return true;
		}
	}

	static boolean evaluateInt(Element value,String s,SortedMap rows,Object rowid){
		s=ScreenHelper.checkString(s);
		try{
			if(value.attributeValue("compare").equalsIgnoreCase("equals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return Integer.parseInt(s)==Integer.parseInt(value.getText());
				}
				else if(value.attributeValue("type").equalsIgnoreCase("config")){
					return Integer.parseInt(s)==MedwanQuery.getInstance(false).getConfigInt(value.getText(),Integer.parseInt(value.attributeValue("default")));
				}
				else{
					return Integer.parseInt(s)==Integer.parseInt(((String)((Hashtable)rows.get(rowid)).get(value.getText())));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return Integer.parseInt(s)!=Integer.parseInt(value.getText());
				}
				else if(value.attributeValue("type").equalsIgnoreCase("config")){
					return Integer.parseInt(s)!=MedwanQuery.getInstance(false).getConfigInt(value.getText(),Integer.parseInt(value.attributeValue("default")));
				}
				else{
					return Integer.parseInt(s)!=Integer.parseInt(((String)((Hashtable)rows.get(rowid)).get(value.getText())));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return Integer.parseInt(s)>Integer.parseInt(value.getText());
				}
				else if(value.attributeValue("type").equalsIgnoreCase("config")){
					return Integer.parseInt(s)>MedwanQuery.getInstance(false).getConfigInt(value.getText(),Integer.parseInt(value.attributeValue("default")));
				}
				else{
					return Integer.parseInt(s)>Integer.parseInt(((String)((Hashtable)rows.get(rowid)).get(value.getText())));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return Integer.parseInt(s)<Integer.parseInt(value.getText());
				}
				else if(value.attributeValue("type").equalsIgnoreCase("config")){
					return Integer.parseInt(s)<MedwanQuery.getInstance(false).getConfigInt(value.getText(),Integer.parseInt(value.attributeValue("default")));
				}
				else{
					return Integer.parseInt(s)<Integer.parseInt(((String)((Hashtable)rows.get(rowid)).get(value.getText())));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return Integer.parseInt(s)<=Integer.parseInt(value.getText());
				}
				else if(value.attributeValue("type").equalsIgnoreCase("config")){
					return Integer.parseInt(s)<=MedwanQuery.getInstance(false).getConfigInt(value.getText(),Integer.parseInt(value.attributeValue("default")));
				}
				else{
					return Integer.parseInt(s)<=Integer.parseInt(((String)((Hashtable)rows.get(rowid)).get(value.getText())));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return Integer.parseInt(s)>=Integer.parseInt(value.getText());
				}
				else if(value.attributeValue("type").equalsIgnoreCase("config")){
					return Integer.parseInt(s)>=MedwanQuery.getInstance(false).getConfigInt(value.getText(),Integer.parseInt(value.attributeValue("default")));
				}
				else{
					return Integer.parseInt(s)>=Integer.parseInt(((String)((Hashtable)rows.get(rowid)).get(value.getText())));
				}
			}
			else{
				return true;
			}
		}
		catch(Exception e){
			//e.printStackTrace();
			return false;
		}
	}
	
	static boolean evaluateDate(Element value,java.util.Date d,SortedMap rows,Object rowid,java.util.Date dateConstant){
		try{
			if(value.attributeValue("compare").equalsIgnoreCase("equals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.equals(dateConstant);
				}
				else{
					return d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.equals(dateConstant);
				}
				else{
					return !d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.after(dateConstant);
				}
				else{
					return d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.before(dateConstant);
				}
				else{
					return d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.after(dateConstant);
				}
				else{
					return !d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.before(dateConstant);
				}
				else{
					return !d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else{
				return true;
			}
		}
		catch(Exception e){
			//e.printStackTrace();
			return false;
		}
	}
	
	static boolean evaluateDuration(Element value,java.util.Date dBegin,java.util.Date dEnd,SortedMap rows,Object rowid){
		long day = 24*3600*1000;
		try{
			if(value.attributeValue("compare").equalsIgnoreCase("equals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return dEnd.getTime()-dBegin.getTime()==Integer.parseInt(value.getText());
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return dEnd.getTime()-dBegin.getTime()!=Integer.parseInt(value.getText());
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return dEnd.getTime()-dBegin.getTime()>Integer.parseInt(value.getText());
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return dEnd.getTime()-dBegin.getTime()<Integer.parseInt(value.getText());
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return dEnd.getTime()-dBegin.getTime()<=Integer.parseInt(value.getText());
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return dEnd.getTime()-dBegin.getTime()>=Integer.parseInt(value.getText());
				}
			}
			else{
				return true;
			}
		}
		catch(Exception e){
			//e.printStackTrace();
			return false;
		}
		return true;
	}
	
	static boolean evaluateDateReverse(Element value,java.util.Date d,SortedMap rows,Object rowid,java.util.Date dateConstant){
		try{
			if(value.attributeValue("compare").equalsIgnoreCase("equals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.equals(dateConstant);
				}
				else{
					return d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.equals(dateConstant);
				}
				else{
					return !d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.after(dateConstant);
				}
				else{
					return !d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.before(dateConstant);
				}
				else{
					return !d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.after(dateConstant);
				}
				else{
					return d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.before(dateConstant);
				}
				else{
					return d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else{
				return true;
			}
		}
		catch(Exception e){
			//e.printStackTrace();
			return false;
		}
	}
	
	static boolean evaluateDate(Element value,java.util.Date d,SortedMap rows,Object rowid){
		try{
			if(value.attributeValue("compare").equalsIgnoreCase("equals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.equals(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.equals(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return !d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.after(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.before(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.after(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return !d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.before(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return !d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else{
				return true;
			}
		}
		catch(Exception e){
			//e.printStackTrace();
			return false;
		}
	}
	
	static boolean evaluateDateReverse(Element value,java.util.Date d,SortedMap rows,Object rowid){
		try{
			if(value.attributeValue("compare").equalsIgnoreCase("equals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.equals(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.equals(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return !d.equals((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.after(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return !d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return !d.before(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return !d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.after(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return d.after((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
				if(value.attributeValue("type").equalsIgnoreCase("constant")){
					return d.before(ScreenHelper.parseDate(value.getText()));
				}
				else{
					return d.before((java.util.Date)((Hashtable)rows.get(rowid)).get(value.getText()));
				}
			}
			else{
				return true;
			}
		}
		catch(Exception e){
			//e.printStackTrace();
			return false;
		}
	}
	
	static void addParameter(Element value, Vector parameters, Hashtable variables){
		if(value.attributeValue("type").equalsIgnoreCase("constant")){
			parameters.add(value.getText());
		}
		else if(value.attributeValue("type").equalsIgnoreCase("config")){
			parameters.add(MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))));
		}
		else{
			parameters.add(variables.get(value.getText()));
		}
	}
	
	static void setParameter(Object p, PreparedStatement ps, int n){
		try{
			if(p.getClass().getName().equalsIgnoreCase("java.sql.Date")){
				ps.setDate(n+1,(java.sql.Date)p);
			}
			else if(p.getClass().getName().equalsIgnoreCase("java.util.Date")){
				ps.setDate(n+1,new java.sql.Date(((java.util.Date)p).getTime()));
			}
			else if(p.getClass().getName().equalsIgnoreCase("java.lang.String")){
				ps.setString(n+1,(java.lang.String)p);
			}
			else if(p.getClass().getName().equalsIgnoreCase("java.lang.Integer")){
				ps.setInt(n+1,(java.lang.Integer)p);
			}
			else if(p.getClass().getName().equalsIgnoreCase("java.lang.Float")){
				ps.setFloat(n+1,(java.lang.Float)p);
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	static String setSelectDate(Element value,String sSelect,Vector parameters,String fieldname,java.util.Date fieldvalue){
		if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
			sSelect+=" AND "+fieldname+" >= ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
			sSelect+=" AND "+fieldname+" <= ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
			sSelect+=" AND "+fieldname+" > ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
			sSelect+=" AND "+fieldname+" < ?";
			parameters.add(fieldvalue);
		}
		return sSelect;
	}
	
	static String setSelectDateReverse(Element value,String sSelect,Vector parameters,String fieldname,java.util.Date fieldvalue){
		if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
			sSelect+=" AND "+fieldname+" < ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
			sSelect+=" AND "+fieldname+" > ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
			sSelect+=" AND "+fieldname+" <= ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
			sSelect+=" AND "+fieldname+" >= ?";
			parameters.add(fieldvalue);
		}
		return sSelect;
	}
	
	static String setSelectInt(Element value,String sSelect,Vector parameters,String fieldname,Integer fieldvalue){
		if(value.attributeValue("compare").equalsIgnoreCase("equals")){
			sSelect+=" AND "+fieldname+" = ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
			sSelect+=" AND "+fieldname+" <> ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("equalsorgreaterthan")){
			sSelect+=" AND "+fieldname+" >= ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("equalsorsmallerthan")){
			sSelect+=" AND "+fieldname+" <= ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("greaterthan")){
			sSelect+=" AND "+fieldname+" > ?";
			parameters.add(fieldvalue);
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("smallerthan")){
			sSelect+=" AND "+fieldname+" < ?";
			parameters.add(fieldvalue);
		}
		return sSelect;
	}
	
	static String setSelectString(Element value,String sSelect,Vector parameters,String fieldname,String fieldvalue){
		if(value.attributeValue("compare").equalsIgnoreCase("equals")){
			sSelect+=" AND "+fieldname+" = ?";
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				parameters.add(MedwanQuery.getInstance(false).getConfigString(fieldvalue,ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				parameters.add(fieldvalue);
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("like")){
			sSelect+=" AND "+fieldname+" like ?"+MedwanQuery.getInstance(false).concatSign()+"'%'";
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				parameters.add(MedwanQuery.getInstance(false).getConfigString(fieldvalue,ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				parameters.add(fieldvalue);
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("contains")){
			sSelect+=" AND "+fieldname+" collate "+MedwanQuery.getInstance(false).getConfigString("collateCaseSensitive","Latin1_General_cs")+" like '%'"+MedwanQuery.getInstance(false).concatSign()+"?"+MedwanQuery.getInstance(false).concatSign()+"'%'";
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				parameters.add(MedwanQuery.getInstance(false).getConfigString(fieldvalue,ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				parameters.add(fieldvalue);
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notcontains")){
			sSelect+=" AND "+fieldname+" collate "+MedwanQuery.getInstance(false).getConfigString("collateCaseSensitive","Latin1_General_cs")+" not like '%'"+MedwanQuery.getInstance(false).concatSign()+"?"+MedwanQuery.getInstance(false).concatSign()+"'%'";
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				parameters.add(MedwanQuery.getInstance(false).getConfigString(fieldvalue,ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				parameters.add(fieldvalue);
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notequals")){
			sSelect+=" AND "+fieldname+" <> ?";
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				parameters.add(MedwanQuery.getInstance(false).getConfigString(fieldvalue,ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				parameters.add(fieldvalue);
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("in")||value.attributeValue("compare").equalsIgnoreCase("inlike")||value.attributeValue("compare").equalsIgnoreCase("incontains")){
			sSelect+=" AND "+fieldname+" in ";
			String values = "";
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				String elements[] = MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))).split(";");
				for(int n=0;n<elements.length;n++){
					if(values.length()>0){
						values+=",";
					}
					values+="'"+elements[n]+"'";
				}
			}
			else{
				Iterator elements = value.elementIterator("element");
				while(elements.hasNext()){
					Element element = (Element)elements.next();
					if(values.length()>0){
						values+=",";
					}
					values+="'"+element.getText()+"'";
				}
			}
			sSelect+="("+values+")";
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("notin")||value.attributeValue("compare").equalsIgnoreCase("notinlike")||value.attributeValue("compare").equalsIgnoreCase("notincontains")){
			sSelect+=" AND "+fieldname+" not in ";
			String values = "";
			if(value.attributeValue("type").equalsIgnoreCase("config")){
				String elements[] = MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))).split(";");
				for(int n=0;n<elements.length;n++){
					if(values.length()>0){
						values+=",";
					}
					values+="'"+elements[n]+"'";
				}
			}
			else{
				Iterator elements = value.elementIterator("element");
				while(elements.hasNext()){
					Element element = (Element)elements.next();
					if(values.length()>0){
						values+=",";
					}
					values+="'"+element.getText()+"'";
				}
			}
			sSelect+="("+values+")";
		}
		return sSelect;
	}
	
	static String setSelectObjectId(Element value,String sSelect,Vector parameters,String fieldname,String fieldvalue){
		if(value.attributeValue("compare").equalsIgnoreCase("equals")){
			sSelect+=" AND "+fieldname+" = replace(?,'"+MedwanQuery.getInstance(false).getConfigString("serverId")+".','')";
			parameters.add(fieldvalue);
		}
		return sSelect;
	}
	
	static String setSelectItemType(String type,String sSelect,Vector parameters){
		sSelect+=" AND type=?";
		parameters.add(type);
		return sSelect;
	}

	static String setSelectItemValue(Element value,String sSelect,Vector parameters,SortedMap rows,Object rowid){
		if(value.attributeValue("compare").equalsIgnoreCase("equals")){
			sSelect+=" AND value=?";
			if(value.attributeValue("type").equalsIgnoreCase("constant")){
				parameters.add(value.getText());
			}
			else if(value.attributeValue("type").equalsIgnoreCase("config")){
				parameters.add(MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				parameters.add(((Hashtable)rows.get(rowid)).get(value.getText()));
			}
		}
		else if(value.attributeValue("compare").equalsIgnoreCase("like")){
			sSelect+=" AND value like '%'"+MedwanQuery.getInstance(false).concatSign()+"?"+MedwanQuery.getInstance(false).concatSign()+"'%'";
			if(value.attributeValue("type").equalsIgnoreCase("constant")){
				parameters.add(value.getText());
			}
			else if(value.attributeValue("type").equalsIgnoreCase("config")){
				parameters.add(MedwanQuery.getInstance(false).getConfigString(value.getText(),ScreenHelper.checkString(value.attributeValue("default"))));
			}
			else{
				parameters.add(((Hashtable)rows.get(rowid)).get(value.getText()));
			}
		}
		return sSelect;
	}
}
