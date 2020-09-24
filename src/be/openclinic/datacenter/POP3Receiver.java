package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.Date;
import java.util.Iterator;
import java.util.Properties;
import java.util.Vector;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.apache.commons.io.IOUtils;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

public class POP3Receiver extends Receiver {

	public void receive(){
        String host = MedwanQuery.getInstance().getConfigString("datacenterPOP3Host","localhost");
        String username = MedwanQuery.getInstance().getConfigString("datacenterPOP3Username","");
        String password = MedwanQuery.getInstance().getConfigString("datacenterPOP3Password","");
    	Properties props=System.getProperties();
        Session session = Session.getInstance(props, null);
	    try {
	    	Store store = session.getStore("pop3");

		    Debug.println("Log in with user name "+username+" on POP3 server "+host);
			store.connect(host, username, password);
		    Folder folder = store.getFolder("INBOX");
		    Debug.println("Opening POP3 mailbox INBOX");
		    folder.open(Folder.READ_WRITE);
	
		    Message message[] = folder.getMessages();
		    Debug.println("Total number of messages: "+message.length);
		    for (int i=0, n=message.length; i<n; i++) {
			    Debug.println("Analyzing message "+i);
		    	if(message[i].getSubject().startsWith("datacenter.content")){
				    Debug.println("Message starts with datacenter.content");
			    	//Store the message in the oc_imports database here and delete it if successful
		            SAXReader reader = new SAXReader(false);
		            try{
					    String ms = new String(message[i].getContent().toString().getBytes("UTF-8"));
					    if(ms.indexOf("</message>")>-1){
					    	ms=ms.substring(0,ms.indexOf("</message>")+10);
					    }
						Document document = reader.read(new ByteArrayInputStream(ms.getBytes("UTF-8")));
						Element root = document.getRootElement();
						Iterator msgs = root.elementIterator("data");
						Vector ackMessages=new Vector();
						while(msgs.hasNext()){
							Element data = (Element)msgs.next();
					    	ImportMessage msg = new ImportMessage(data);
							msg.setType(root.attributeValue("type"));
						    Debug.println("Message type = "+root.attributeValue("type")+ " from "+message[i].getFrom()[0]);
					    	msg.setReceiveDateTime(new java.util.Date());
					    	msg.setRef("SMTP:"+message[i].getFrom()[0]);
					    	try {
								msg.store();
						    	message[i].setFlag(Flags.Flag.DELETED, true);
						    	ackMessages.add(msg);
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
				    	//Set ackDateTime for all received messages in mail
					    Debug.println("Sending ACK for received message "+i);
						ImportMessage.sendAck(ackMessages);
		            }
		            catch(MessagingException e){
		            	e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		            } catch (UnsupportedEncodingException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		    		} catch (DocumentException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		    		} catch (Exception e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		}
		    	}
		    	else if (message[i].getSubject().startsWith("datacenter.ack")){
		            SAXReader reader = new SAXReader(false);
		            try{
			            Document document = reader.read(new ByteArrayInputStream(message[i].getContent().toString().getBytes("UTF-8")));
						Element root = document.getRootElement();
						Iterator msgs = root.elementIterator("data");
						while(msgs.hasNext()){
							Element data = (Element)msgs.next();
					    	AckMessage msg = new AckMessage(data);
					    	if(msg.serverId==MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)){
					    		ExportMessage.updateAckDateTime(msg.getObjectId(), msg.getAckDateTime());
					    	}
					    	else {
					    		//TODO: send warning to system administrator 
					    		//ACK received addressed to other server!
					    		if(MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)>=0 && msg.getServerId()>0){
						    		String error="Server "+MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)+" received SMTP ACK message intended for server "+msg.getServerId();
						    		SMTPSender.sendSysadminMessage(error, msg);
					    		}
					    	}
						}
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		            }
		            catch(MessagingException e){
		            	Debug.println(e.getMessage());
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		            } catch (UnsupportedEncodingException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		    		} catch (DocumentException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		    		} catch (IOException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		}
		    	}
		    	else if (message[i].getSubject().startsWith("datacenter.importack")){
		            SAXReader reader = new SAXReader(false);
		            try{
			            Document document = reader.read(new ByteArrayInputStream(message[i].getContent().toString().getBytes("UTF-8")));
						Element root = document.getRootElement();
						Iterator msgs = root.elementIterator("data");
						while(msgs.hasNext()){
							Element data = (Element)msgs.next();
					    	ImportAckMessage msg = new ImportAckMessage(data);
					    	if(msg.serverId==MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)){
					    		ExportMessage.updateImportAckDateTime(msg.getObjectId(), msg.getImportAckDateTime());
					    		ExportMessage.updateImportDateTime(msg.getObjectId(), msg.getImportDateTime());
					    		ExportMessage.updateErrorCode(msg.getObjectId(), msg.getError());
					    	}
					    	else {
					    		//TODO: send warning to system administrator 
					    		//Import ACK received addressed to other server!
					    		if(MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)>=0 && msg.getServerId()>0){
						    		String error="Server "+MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)+" received SMTP ACK message intended for server "+msg.getServerId();
						    		SMTPSender.sendSysadminMessage(error, msg);
					    		}
					    	}
						}
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		            }
		            catch(MessagingException e){
		            	Debug.println(e.getMessage());
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		            } catch (UnsupportedEncodingException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		    		} catch (DocumentException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		    		} catch (IOException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		}
		    	}
		    	else {
		            SAXReader reader = new SAXReader(false);
		    		try {
						Multipart multipart = (Multipart) message[i].getContent();
					    for (int o = 0; o < multipart.getCount(); o++) {
					        BodyPart bodyPart = multipart.getBodyPart(i);
					        if(!Part.ATTACHMENT.equalsIgnoreCase(bodyPart.getDisposition()) &&
					               ScreenHelper.checkString(bodyPart.getFileName()).length()==0) {
					            continue; // dealing with attachments only
					        } 
			            	Document document = reader.read(bodyPart.getInputStream());
			            	Element root = document.getRootElement();
			            	if(root.attributeValue("type").equalsIgnoreCase("invoicefollowup")){
			            	}
					    }
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		    		}
					catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
				    	message[i].setFlag(Flags.Flag.DELETED, true);
					}
		    	}
		    }
	
		    // Close connection 
		    folder.close(true);
		    store.close();
		} catch (MessagingException e1) {
			// TODO Auto-generated catch block
			if(Debug.enabled) e1.printStackTrace();
		}
	}
}
