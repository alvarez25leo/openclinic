package be.openclinic.finance;

import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Vector;

import net.admin.Service;
import net.admin.User;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import com.itextpdf.text.pdf.PdfPTable;

public class CsvInvoiceCCBRTA {
    static DecimalFormat priceFormatInsurar = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatInsurar","#,##0.00"));

	public static String getOutput(javax.servlet.http.HttpServletRequest request){
		double pageTotalAmount=0,pageTotalAmount85=0,pageTotalAmount100=0;
		String invoiceuid=request.getParameter("invoiceuid");
        int coverage=85;
		InsurarInvoice invoice = InsurarInvoice.get(invoiceuid);
		if(invoice!=null){
			Insurar insurar=invoice.getInsurar();
	        if(insurar!=null && insurar.getInsuraceCategories()!=null && insurar.getInsuraceCategories().size()>0){
	        	try{
	        		coverage=100-Integer.parseInt(((InsuranceCategory)insurar.getInsuraceCategories().elementAt(0)).getPatientShare());
	        	}
	        	catch(Exception e){
	        		e.printStackTrace();
	        	}
	        }
		}
		String sOutput="";
		if(invoiceuid!=null){
	        Vector debets = InsurarInvoice.getDebetsForInvoiceSortByServiceAndDate(invoiceuid);
	        if(debets.size() > 0){
	            // print debets
	            Debet debet;
	            String sPatientName="", sPrevPatientName = "",sPatientId="",sPatientGender="",sPatientDateOfBirth="",sPatientAge="",sUser="",sPreviousInvoiceUID="",beneficiarynr="",beneficiaryage="",beneficiarysex="",affiliatecompany="";
	            Date date=null,prevdate=null;
	            boolean displayPatientName=false,displayDate=false;
	            SortedMap categories = new TreeMap(), totalcategories = new TreeMap();
	            double total100pct=0,total85pct=0,totalcomp=0,generaltotal100pct=0,generaltotal85pct=0,generaltotalcomp=0,daytotal100pct=0,daytotal85pct=0,daytotalcomp=0;
	            String invoiceid="",adherent="",recordnumber="",insurarreference="",status="",sService="",sServiceUid,sPrevService="";
	            int linecounter=1;
	            boolean initialized=false;
            	int debetcount=0;
	            for(int i=0; i<debets.size(); i++){
	                debet = (Debet)debets.get(i);
	                if(!initialized){
			            //Eerst consultaties
			            sOutput+="\r\n\r\n"+ScreenHelper.getTran(null,"hospital.statistics", "visits", "fr");
			            sOutput+="\r\n#;RECEIPT;PATIENTID;NAME_FIRSTNAME;AGE;GENDER;DEPARTMENT;USER;TOTAL;PATIENT;INSURER;COMPL_INSURER;DATE\r\n";
	                }
	                initialized=true;
	                date = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(debet.getDate()));

	                sServiceUid=debet.getServiceUid();
	                if(sServiceUid!=null && sServiceUid.length()>0){
	                	Service service = Service.getService(sServiceUid);
	                	if(service !=null){
	                		sService=service.getLabel("en");
	                	}
	                }
	                else {
	                	Service service = debet.getEncounter().getService();
	                	if(service !=null){
	                		sService=service.getLabel("en");
	                	}
	                }
	                displayDate = !date.equals(prevdate);
	                sPatientName = debet.getPatientName()+";"+debet.getEncounter().getPatientUID();
	                sPatientId=debet.getPatientid();
	                sPatientGender=debet.getPatientgender();
	                sPatientDateOfBirth=debet.getPatientbirthdate();
	                sPatientAge="?";
	                try{
	                	java.util.Date dBirth = ScreenHelper.getSQLDate(sPatientDateOfBirth);
	                	long day = 24*3600*1000;
	                	long year = 365*day;
	                	sPatientAge=""+((new java.util.Date().getTime()-dBirth.getTime())/year);
	                }
	                catch(Exception z){
	                	z.printStackTrace();
	                }
	                sUser = "?";
	                try{
	                	if(debet.getUpdateUser()!=null){
	                		sUser=User.getFullUserName(debet.getUpdateUser());
	                	}
	                }
	                catch(Exception z){
	                	z.printStackTrace();
	                }
	                displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName) || (debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0 && invoiceid.length()>0);
	                if(debetcount>0 && (displayDate || displayPatientName)){
	                	//Print the line
	                	sOutput+=linecounter+";";
	                	sOutput+=invoiceid+";";
	                	sOutput+=sPatientId+";";
	                	sOutput+=sPrevPatientName.split(";")[0]+";";
	                	sOutput+=sPatientAge+";";
	                	sOutput+=sPatientGender+";";
	                	sOutput+=sService+";";
	                	sOutput+=sUser+";";
	                	sOutput+=total100pct+";";
	                	sOutput+=(total100pct-total85pct-totalcomp)+";";
	                	sOutput+=total85pct+";";
	                	sOutput+=totalcomp+";";
	                	sOutput+=(prevdate!=null?ScreenHelper.stdDateFormat.format(prevdate):ScreenHelper.stdDateFormat.format(date))+"\r\n";
	                	categories = new TreeMap();
	                	total100pct=0;
	                	total85pct=0;
	                	totalcomp=0;
	                	daytotal100pct=0;
	                	daytotal85pct=0;
	                	daytotalcomp=0;
	                	invoiceid="";
	                	adherent="";
	                	recordnumber="";
	                	insurarreference="";
	                	beneficiarynr="";
	                	beneficiaryage="";
	                	beneficiarysex="";
	                	affiliatecompany="";
	                	sService="";
	                	status="";
	                	linecounter++;
	                }
	                if(debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0){
	                	if(invoiceid.length()>0){
	                		invoiceid+="\n";
	                	}
	                	invoiceid+=debet.getPatientInvoiceUid().split("\\.")[1];
	                	if(insurarreference.equalsIgnoreCase("")){
		                	PatientInvoice patientInvoice = PatientInvoice.get(debet.getPatientInvoiceUid());
		                	if(patientInvoice!=null){
		                		insurarreference=patientInvoice.getInsurarreference();
		                	}
	                	}
	                }
	                if(debet.getInsuranceUid()!=null){
	                	Insurance insurance = Insurance.get(debet.getInsuranceUid());
	                	debet.setInsurance(insurance);
	                	beneficiarynr=insurance.getInsuranceNr();
	                	affiliatecompany=insurance.getMemberEmployer();
	                }
	                if(debet.getInsurance()!=null && debet.getInsurance().getStatus()!=null){
	                	status=ScreenHelper.getTranNoLink("insurance.status",debet.getInsurance().getStatus(),"fr");
	                }
	                if(debet.getInsurance()!=null && debet.getInsurance().getMember()!=null && adherent.indexOf(debet.getInsurance().getMember().toUpperCase())<0){
	                	if(adherent.length()>0){
	                		adherent+="\n";
	                	}
	                	adherent+=debet.getInsurance().getMember().toUpperCase();
	                }
	                if(debet.getInsurance()!=null && debet.getInsurance().getMemberImmat()!=null && recordnumber.indexOf(debet.getInsurance().getMemberImmat())<0){
	                	if(recordnumber.length()>0){
	                		recordnumber+="\n";
	                	}
	                	recordnumber+=debet.getInsurance().getMemberImmat();
	                }
	                Prestation prestation = debet.getPrestation();
	                double rAmount = debet.getAmount();
	                double rInsurarAmount = debet.getInsurarAmount();
	                double rExtraInsurarAmount = debet.getExtraInsurarAmount();
	                int rTotal=(int)(rAmount+rInsurarAmount+rExtraInsurarAmount);
	                total100pct+=rTotal;
	                total85pct+=rInsurarAmount;
	                totalcomp+=rExtraInsurarAmount;
	                generaltotal100pct+=rTotal;
	                generaltotal85pct+=rInsurarAmount;
	                generaltotalcomp+=rExtraInsurarAmount;
	                prevdate = date;
	                sPrevPatientName = sPatientName;
	                debetcount++;
	                initialized=true;
	            }
	            if(initialized){
	            	//Print the line
                	sOutput+=linecounter+";";
                	sOutput+=invoiceid+";";
                	sOutput+=sPatientId+";";
                	sOutput+=sPrevPatientName.split(";")[0]+";";
                	sOutput+=sPatientAge+";";
                	sOutput+=sPatientGender+";";
                	sOutput+=sService+";";
                	sOutput+=sUser+";";
                	sOutput+=total100pct+";";
                	sOutput+=(total100pct-total85pct-totalcomp)+";";
                	sOutput+=total85pct+";";
                	sOutput+=totalcomp+";";
                	sOutput+=(prevdate!=null?ScreenHelper.stdDateFormat.format(prevdate):ScreenHelper.stdDateFormat.format(date))+"\r\n";
	            	//Print totals
	            	sOutput+=";";
	            	sOutput+=ScreenHelper.getTran(null,"web", "total", "fr")+";";
	            	sOutput+=";";
	            	sOutput+=";";
	            	sOutput+=";";
	            	sOutput+=";";
	            	sOutput+=";";
	            	sOutput+=";";
	            	sOutput+=generaltotal100pct+";";
	            	sOutput+=(generaltotal100pct-generaltotal85pct-generaltotalcomp)+";";
	            	sOutput+=generaltotal85pct+";";
	            	sOutput+=generaltotalcomp+";";
	            	sOutput+="\r\n";
	            }
	        }
		}
		return sOutput;
	}
	
    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private static String printDebet2(SortedMap categories, boolean displayDate, Date date, String invoiceid,String adherent,String beneficiary,double total100pct,double total85pct,String recordnumber,int linecounter,String insurarreference,String beneficiarynr,String beneficiaryage,String beneficiarysex,String affiliatecompany){
    	String sOutput="";
        sOutput+=linecounter+";";
        sOutput+=ScreenHelper.stdDateFormat.format(date)+";";
        sOutput+=insurarreference+";";
        sOutput+=invoiceid+";";
        sOutput+=beneficiarynr+";";
        sOutput+=beneficiaryage+";";
        sOutput+=beneficiarysex+";";
        sOutput+=beneficiary+";";
        sOutput+=adherent+";";
        sOutput+=affiliatecompany+";";
        String amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A"));
        sOutput+=amount==null?"0;":amount+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C"));
        sOutput+=amount==null?"0;":amount+";";
        String otherprice="+0";
        String allcats=	"*"+MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M")+"*";
        Iterator iterator = categories.keySet().iterator();
        while (iterator.hasNext()){
        	String cat = (String)iterator.next();
        	if(allcats.indexOf("*"+cat+"*")<0 && ((String)categories.get(cat)).length()>0){
        		otherprice+="+"+(String)categories.get(cat);
        	}
        }
        sOutput+=otherprice+";";
        amount = (String)categories.get(MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M"));
        sOutput+=amount==null?"0;":amount+";";
        sOutput+=priceFormatInsurar.format(total100pct)+";";
        sOutput+=priceFormatInsurar.format(total85pct)+"\r\n";
        return sOutput;
    }

}
