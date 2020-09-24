package be.openclinic.medical;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.hl7.HL7Server;
import be.openclinic.system.Config;








import java.sql.*;
import java.sql.Date;
import java.util.*;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

import com.itextpdf.text.Font;
import com.itextpdf.text.pdf.PdfPCell;

import net.admin.User;

public class RequestedLabAnalysis {

    // variables
    private String serverId, transactionId, patientId, analysisCode, comment,
                   resultValue, resultUnit, resultModifier, resultComment,
                   resultRefMax, resultRefMin, resultUserId, requestUserId, resultProvisional,labgroup;
    private java.util.Date resultDate,requestDate;
    private int technicalvalidation;
    private java.util.Date technicalvalidationdatetime;
    private int finalvalidation;
    private java.util.Date finalvalidationdatetime;
    private java.util.Date sampletakendatetime;
    private java.util.Date samplereceptiondatetime;
    private java.util.Date worklisteddatetime;
    private java.util.Date updatetime;
    private int sampler;
    private int objectid;
    private String tag;

	public String getTag() {
		return tag;
	}

	public void setTag(String tag) {
		this.tag = tag;
	}

	public int getObjectid() {
		return objectid;
	}

	public void setObjectid(int objectid) {
		this.objectid = objectid;
	}

	private String extractResistance(String arvs,String arv){
		String resistance="";
		String[] arvlist = arvs.split(";");
		for(int n=0;n<arvlist.length;n++){
			if(arvlist[n].split("=")[0].equalsIgnoreCase(arv) && arvlist[n].split("=").length>1){
				return arvlist[n].split("=")[1];
			}
		}
		return resistance;
	}

    public java.util.Date getUpdatetime() {
		return updatetime;
	}

	public void setUpdatetime(java.util.Date updatetime) {
		this.updatetime = updatetime;
	}

	public java.util.Date getWorklisteddatetime() {
        return worklisteddatetime;
    }

    public void setWorklisteddatetime(java.util.Date worklisteddatetime) {
        this.worklisteddatetime = worklisteddatetime;
    }

    public java.util.Date getSampletakendatetime() {
        return sampletakendatetime;
    }

    public void setSampletakendatetime(java.util.Date sampletakendatetime) {
        this.sampletakendatetime = sampletakendatetime;
    }

    public java.util.Date getSamplereceptiondatetime() {
        return samplereceptiondatetime;
    }

    public void setSamplereceptiondatetime(java.util.Date samplereceptiondatetime) {
        this.samplereceptiondatetime = samplereceptiondatetime;
    }

    public int getSampler() {
        return sampler;
    }

    public void setSampler(int sampler) {
        this.sampler = sampler;
    }

    public String getLabgroup() {
        return labgroup==null?"":labgroup;
    }

    public void setLabgroup(String labgroup) {
        this.labgroup = labgroup;
    }

    public int getTechnicalvalidation() {
        return technicalvalidation;
    }

    public void setTechnicalvalidation(int technicalvalidation) {
        this.technicalvalidation = technicalvalidation;
    }

    public java.util.Date getTechnicalvalidationdatetime() {
        return technicalvalidationdatetime;
    }

    public void setTechnicalvalidationdatetime(java.util.Date technicalvalidationdatetime) {
        this.technicalvalidationdatetime = technicalvalidationdatetime;
    }

    public int getFinalvalidation() {
        return finalvalidation;
    }

    public void setFinalvalidation(int finalvalidation) {
        this.finalvalidation = finalvalidation;
    }

    public java.util.Date getFinalvalidationdatetime() {
        return finalvalidationdatetime;
    }

    public void setFinalvalidationdatetime(java.util.Date finalvalidationdatetime) {
        this.finalvalidationdatetime = finalvalidationdatetime;
        
    }//--- CONSTRUCTOR 1 ---------------------------------------------------------------------------
    public RequestedLabAnalysis(){
        serverId      = "";
        objectid      = -1;
        transactionId = "";
        patientId     = "";
        analysisCode  = "";
        comment       = "";

        // result..
        resultValue    = "";
        resultUnit     = "";
        resultModifier = "";
        resultComment  = "";
        resultRefMax   = "";
        resultRefMin   = "";
        resultUserId   = "";
        requestUserId  = "";
        resultDate     = new java.util.Date();
        resultProvisional    = "";
    }
    
    public static RequestedLabAnalysis fromXMLElement(Element analysis) {
    	RequestedLabAnalysis requestedLabAnalysis = new RequestedLabAnalysis();
    	requestedLabAnalysis.serverId=analysis.elementText("serverId");
    	requestedLabAnalysis.transactionId=analysis.elementText("transactionId");
    	requestedLabAnalysis.patientId=analysis.elementText("patientId");
    	requestedLabAnalysis.analysisCode=analysis.elementText("analysisCode");
    	requestedLabAnalysis.comment=analysis.elementText("comment");
    	requestedLabAnalysis.resultValue=analysis.elementText("resultValue");
    	requestedLabAnalysis.resultUnit=analysis.elementText("resultUnit");
    	requestedLabAnalysis.resultModifier=analysis.elementText("resultModifier");
    	requestedLabAnalysis.resultComment=analysis.elementText("resultComment");
    	requestedLabAnalysis.resultRefMax=analysis.elementText("resultRefMax");
    	requestedLabAnalysis.resultRefMin=analysis.elementText("resultRefMin");
    	requestedLabAnalysis.resultUserId=analysis.elementText("resultUserId");
    	requestedLabAnalysis.finalvalidation=Integer.parseInt(analysis.elementText("finalvalidation"));
    	requestedLabAnalysis.requestUserId=analysis.elementText("requestUserId");
    	try {
        	requestedLabAnalysis.resultDate=new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(analysis.elementText("resultDate"));
    	} catch(Exception e) {}
    	try {
        	requestedLabAnalysis.finalvalidationdatetime=new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(analysis.elementText("finalvalidationdatetime"));
    	} catch(Exception e) {}
    	return requestedLabAnalysis;
    }

    public Element toXmlElement() {
    	Element analysis = DocumentHelper.createElement("RequestedLabAnalysis");
    	analysis.addElement("serverId").setText(serverId);
    	analysis.addElement("transactionId").setText(transactionId);
    	analysis.addElement("patientId").setText(patientId);
    	analysis.addElement("analysisCode").setText(analysisCode);
    	analysis.addElement("comment").setText(comment);
    	analysis.addElement("resultValue").setText(resultValue);
    	analysis.addElement("resultUnit").setText(resultUnit);
    	analysis.addElement("resultModifier").setText(resultModifier);
    	analysis.addElement("resultComment").setText(resultComment);
    	analysis.addElement("resultRefMax").setText(resultRefMax);
    	analysis.addElement("resultRefMin").setText(resultRefMin);
    	analysis.addElement("resultUserId").setText(resultUserId);
    	analysis.addElement("finalvalidation").setText(finalvalidation+"");
    	analysis.addElement("requestUserId").setText(requestUserId);
    	if(resultDate!=null) {
    		analysis.addElement("resultDate").setText(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(resultDate));
    	}
    	if(finalvalidationdatetime!=null) {
    		analysis.addElement("finalvalidationdatetime").setText(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(finalvalidationdatetime));
    	}
    	return analysis;
    }
    
    //--- CONSTRUCTOR 2 ---------------------------------------------------------------------------
    public RequestedLabAnalysis(String serverId, String transactionId, String patientId, String analysisCode,
                                String comment, String resultValue, String resultUnit, String resultModifier,
                                String resultComment, String resultRefMax, String resultRefMin,
                                String resultUserId, java.util.Date resultDate, String resultProvisional){
        // lab analysis..
        this.serverId      = serverId;
        this.transactionId = transactionId;
        this.patientId     = patientId;
        this.analysisCode  = analysisCode;
        this.comment       = comment;

        // lab result..
        this.resultValue    = resultValue;
        this.resultUnit     = resultUnit;
        this.resultModifier = resultModifier;
        this.resultComment  = resultComment;
        this.resultRefMax   = resultRefMax;
        this.resultRefMin   = resultRefMin;
        this.resultUserId   = resultUserId;
        this.resultDate     = resultDate;
        this.resultProvisional = resultProvisional;
    }

    //--- CONSTRUCTOR 3 ---Includes: finalvalidationdatetime -------------------------------------------
    public RequestedLabAnalysis(String serverId, String transactionId, String patientId, String analysisCode,
                                String comment, String resultValue, String resultUnit, String resultModifier,
                                String resultComment, String resultRefMax, String resultRefMin,
                                String resultUserId, java.util.Date resultDate, String resultProvisional,java.util.Date finalvalidationdatetime){
        // lab analysis..
        this.serverId      = serverId;
        this.transactionId = transactionId;
        this.patientId     = patientId;
        this.analysisCode  = analysisCode;
        this.comment       = comment;

        // lab result..
        this.resultValue    = resultValue;
        this.resultUnit     = resultUnit;
        this.resultModifier = resultModifier;
        this.resultComment  = resultComment;
        this.resultRefMax   = resultRefMax;
        this.resultRefMin   = resultRefMin;
        this.resultUserId   = resultUserId;
        this.resultDate     = resultDate;
        this.resultProvisional = resultProvisional;
        this.finalvalidationdatetime = finalvalidationdatetime;
    }

    public java.util.Date getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(Date requestDate) {
        this.requestDate = requestDate;
    }

    public String getRequestUserId() {
        return requestUserId;
    }

    public void setRequestUserId(String requestUserId) {
        this.requestUserId = requestUserId;
    }//--- SERVER ID -------------------------------------------------------------------------------
    public void setServerId(String value){
        this.serverId = value;
    }

    public String getServerId(){
        return this.serverId;
    }

    //--- TRANSACTION ID --------------------------------------------------------------------------
    public void setTransactionId(String value){
        this.transactionId = value;
    }

    public String getTransactionId(){
        return this.transactionId;
    }

    //--- PATIENT ID ------------------------------------------------------------------------------
    public void setPatientId(String value){
        this.patientId = value;
    }

    public String getPatientId(){
        return this.patientId;
    }

    //--- ANALYSIS CODE ---------------------------------------------------------------------------
    public void setAnalysisCode(String value){
        this.analysisCode = value;
    }

    public String getAnalysisCode(){
        return this.analysisCode;
    }

    //--- COMMENT ---------------------------------------------------------------------------------
    public void setComment(String value){
        this.comment = value;
    }

    public String getComment(){
        return this.comment;
    }

    //--- RESULT VALUE ----------------------------------------------------------------------------
    public void setResultValue(String value){
        this.resultValue = value;
    }

    public String getResultValue(){
        return this.resultValue;
    }

    //--- RESULT UNIT -----------------------------------------------------------------------------
    public void setResultUnit(String value){
        this.resultUnit = value;
    }

    public String getResultUnit(){
        return RequestedLabAnalysis.getAnalysisUnit(this.analysisCode);
    }

    //--- RESULT MODIFIER -------------------------------------------------------------------------
    public void setResultModifier(String value){
        this.resultModifier = value;
    }

    public String getResultModifier(){
    	if(getResultValue().length()>0 && (this.resultModifier==null || this.resultModifier.length()==0)){
    		calculateModifier();
    	}
        return this.resultModifier;
    }
    
    public String getUnverifiedResultModifier(){
        return this.resultModifier;
    }
    
    public void calculateModifier(){
   		setResultModifier("");
		LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(getAnalysisCode());
		if(analysis!=null && analysis.getEditor().contains("numeric")){
        	//We proberen na te gaan of de waarde buiten de grenzen valt
        	try{
                double iResult = Double.parseDouble(getResultValue().replaceAll(",", "\\."));
                double iMin = Double.parseDouble(getResultRefMin().replaceAll(",", "\\."));
                double iMax = Double.parseDouble(getResultRefMax().replaceAll(",", "\\."));

                String normal="";
                
                if ((iResult >= iMin)&&(iResult <= iMax)){
                    normal = "n";
                }
                else {
                    double iAverage = (iMax-iMin);

                    if (iResult > iMax+iAverage*2){
                        normal = "+++";
                    }
                    else if (iResult > iMax + iAverage){
                        normal = "++";
                    }
                    else if (iResult > iMax){
                        normal = "+";
                    }
                    else if (iResult < iMin - iAverage*2){
                        normal = "---";
                    }
                    else if (iResult < iMin - iAverage){
                        normal = "--";
                    }
                    else if (iResult < iMin){
                        normal = "-";
                    }
                }
                setResultModifier(normal);
                this.store();
        	}
        	catch(Exception e2){
        		//e2.printStackTrace();
        	}
		}
	
    }
    
    public void calculateModifier(boolean bExists,Connection conn){
   		setResultModifier("");
		LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(getAnalysisCode(),conn);
		if(analysis!=null && analysis.getEditor().contains("numeric")){
        	//We proberen na te gaan of de waarde buiten de grenzen valt
        	try{
                double iResult = Double.parseDouble(getResultValue().replaceAll(",", "\\."));
                double iMin = Double.parseDouble(getResultRefMin(conn).replaceAll(",", "\\."));
                double iMax = Double.parseDouble(getResultRefMax(conn).replaceAll(",", "\\."));
                String normal="";
                
                if ((iResult >= iMin)&&(iResult <= iMax)){
                    normal = "n";
                }
                else {
                    double iAverage = (iMax-iMin);

                    if (iResult > iMax+iAverage*2){
                        normal = "+++";
                    }
                    else if (iResult > iMax + iAverage){
                        normal = "++";
                    }
                    else if (iResult > iMax){
                        normal = "+";
                    }
                    else if (iResult < iMin - iAverage*2){
                        normal = "---";
                    }
                    else if (iResult < iMin - iAverage){
                        normal = "--";
                    }
                    else if (iResult < iMin){
                        normal = "-";
                    }
                }
                setResultModifier(normal);
                this.store(bExists,conn);
        	}
        	catch(Exception e2){
        		e2.printStackTrace();
        	}
		}
	
    }
    
    //--- RESULT PROVISIONAK -------------------------------------------------------------------------
    public void setResultProvisional(String value){
        this.resultProvisional = value;
    }

    public String getResultProvisional(){
        return this.resultProvisional;
    }

    //--- RESULT COMMENT --------------------------------------------------------------------------
    public void setResultComment(String value){
        this.resultComment = value;
    }

    public String getResultComment(){
        return this.resultComment;
    }
    
    public String getResultCommentPart(String part){
    	String s ="";
    	if(part!=null){
	    	String[] parts = getResultComment().split(";");
	    	for(int n = 0;n<parts.length;n++){
	    		if(part.equalsIgnoreCase(parts[n].split("=")[0]) && parts[n].split("=").length>1){
	    			s=parts[n].split("=")[1];
	    		}
	    	}
    	}
    	return s;
    }
    
    public static String getAntibioticNew(String id, String sPrintLanguage){
    	if(id.equalsIgnoreCase("1")){
    		return ScreenHelper.getTranNoLink("antibiotics","pen",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("2")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","oxa",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("3")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","amp",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("4")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","amc",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("5")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","czo",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("6")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","mec",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("7")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","ctx",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("8")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","gen",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("9")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","amk",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("10")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","chl",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("11")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","tcy",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("12")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","col",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("13")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","ery",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("14")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","lin",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("15")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","pri",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("16")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","sxt",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("17")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","nit",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("18")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","nal",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("19")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","cip",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("20")){
    		return MedwanQuery.getInstance().getLabel("antibiotics","ipm",sPrintLanguage);
    	}
    	else {
    		try{
    			int abid = Integer.parseInt(id);
    			if(abid>20){
    				return MedwanQuery.getInstance().getLabel("antibiotics",MedwanQuery.getInstance().getConfigString("extraAntibiotics","").split(";").length>Integer.parseInt(id)-20?MedwanQuery.getInstance().getConfigString("extraAntibiotics","").split(";")[Integer.parseInt(id)-20]:"",sPrintLanguage);
    			}
    	    	else {
    	    		return "?";
    	    	}
    		}
    		catch(Exception e){
	    		return "?";
    		}
    	}
    }
    
    //--- GET ANTIBIOTIC --------------------------------------------------------------------------
    private String getAntibiotic(String id, String sPrintLanguage){
    	if(id.equalsIgnoreCase("1")){
    		return MedwanQuery.getInstance().getLabel("web","penicillineg",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("2")){
    		return MedwanQuery.getInstance().getLabel("web","oxacilline",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("3")){
    		return MedwanQuery.getInstance().getLabel("web","ampicilline",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("4")){
    		return MedwanQuery.getInstance().getLabel("web","amoxicacclavu",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("5")){
    		return MedwanQuery.getInstance().getLabel("web","cefalotine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("6")){
    		return MedwanQuery.getInstance().getLabel("web","mecillinam",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("7")){
    		return MedwanQuery.getInstance().getLabel("web","cefotaxime",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("8")){
    		return MedwanQuery.getInstance().getLabel("web","gentamicine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("9")){
    		return MedwanQuery.getInstance().getLabel("web","amikacine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("10")){
    		return MedwanQuery.getInstance().getLabel("web","chloramphenicol",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("11")){
    		return MedwanQuery.getInstance().getLabel("web","tetracycline",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("12")){
    		return MedwanQuery.getInstance().getLabel("web","colistine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("13")){
    		return MedwanQuery.getInstance().getLabel("web","erythromycine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("14")){
    		return MedwanQuery.getInstance().getLabel("web","lincomycine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("15")){
    		return MedwanQuery.getInstance().getLabel("web","pristinamycine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("16")){
    		return MedwanQuery.getInstance().getLabel("web","cotrimoxazole",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("17")){
    		return MedwanQuery.getInstance().getLabel("web","nitrofurane",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("18")){
    		return MedwanQuery.getInstance().getLabel("web","acnalidixique",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("19")){
    		return MedwanQuery.getInstance().getLabel("web","ciprofloxacine",sPrintLanguage);
    	}
    	else if(id.equalsIgnoreCase("20")){
    		return MedwanQuery.getInstance().getLabel("web","imipenem",sPrintLanguage);
    	}
    	else {
    		try{
    			int abid = Integer.parseInt(id);
    			if(abid>20){
    	    		return MedwanQuery.getInstance().getLabel("web","ab"+(Integer.parseInt(id)-20),sPrintLanguage);
    			}
    	    	else {
    	    		return "?";
    	    	}
    		}
    		catch(Exception e){
	    		return "?";
    		}
    	}
    }
    
    public Vector getResultsHistory(User user){
    	Vector history = new Vector();
    	LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(getAnalysisCode());
    	if(labAnalysis!=null && labAnalysis.getHistoryvalues()>0 && labAnalysis.getHistorydays()>0){
        	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
            try {
                PreparedStatement ps=conn.prepareStatement("select * from RequestedLabAnalyses where patientid=? and analysiscode=? and requestdatetime<? and finalvalidationdatetime is not null order by requestdatetime desc");
                ps.setInt(1,Integer.parseInt(getPatientId()));
                ps.setString(2, getAnalysisCode());
                ps.setTimestamp(3, new java.sql.Timestamp(getRequestDate().getTime()));
                ResultSet rs = ps.executeQuery();
                int values=0;
                while(rs.next()){
            		long day = 24*3600*1000;
            		java.util.Date limitdate = new java.util.Date(new java.util.Date().getTime()-day*labAnalysis.getHistorydays());
            		java.util.Date date = rs.getTimestamp("requestdatetime");
            		if(date.before(limitdate)){
            			break;
            		}

            		if(labAnalysis.getEditor().equalsIgnoreCase("antibiogram")){
                    	Map ab = RequestedLabAnalysis.getAntibiogrammes(rs.getString("serverid")+"."+rs.getString("transactionid")+"."+getAnalysisCode());
                    	String result="";
                    	String result2="";
                    	if(labAnalysis.getLimitedVisibility()>0 && !user.getAccessRight("labos.limitedvisibility.select")){
                    		result=MedwanQuery.getInstance().getLabel("web","invisible",user.person.language);                	}
                    	else {
    	                	if(ab.get("germ1")!=null && !(ab.get("germ1")+"").equalsIgnoreCase("")){
    	                		result+=ab.get("germ1")+"\n";
    	                		result2+="\n";
    	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME1");
    	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
    	                			String[] tests = antibiotics.split(",");
    	                			for(int n=0;n<tests.length;n++){
    	                				if(tests[n].split("=").length==2){
    	                					result+="\t"+getAntibiotic(tests[n].split("=")[0],user.person.language)+"\n";
    	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], user.person.language)+"\n";
    	                				}
    	                			}
    	                		}
    	                	}
    	                	if(ab.get("germ2")!=null && !(ab.get("germ2")+"").equalsIgnoreCase("")){
    	                		if(result.length()>0){
    	                			result+="\n";
    	                    		result2+="\n";
    	                		}
    	                		result2+="\n";
    	                		result+=ab.get("germ2")+"\n";
    	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME2");
    	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
    	                			String[] tests = antibiotics.split(",");
    	                			for(int n=0;n<tests.length;n++){
    	                				if(tests[n].split("=").length==2){
    	                					result+="\t"+getAntibiotic(tests[n].split("=")[0],user.person.language)+"\n";
    	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], user.person.language)+"\n";
    	                				}
    	                			}
    	                		}
    	                	}
    	                	if(ab.get("germ3")!=null && !(ab.get("3")+"").equalsIgnoreCase("")){
    	                		if(result.length()>0){
    	                			result+="\n";
    	                    		result2+="\n";
    	                		}
    	                		result2+="\n";
    	                		result+=ab.get("germ3")+"\n";
    	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME3");
    	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
    	                			String[] tests = antibiotics.split(",");
    	                			for(int n=0;n<tests.length;n++){
    	                				if(tests[n].split("=").length==2){
    	                					result+="\t"+getAntibiotic(tests[n].split("=")[0],user.person.language)+"\n";
    	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], user.person.language)+"\n";
    	                				}
    	                			}
    	                		}
    	                	}
                    	}
                		history.add(ScreenHelper.formatDate(date)+"|"+result+"|"+result2);
                	}
                	else if(labAnalysis.getEditor().equalsIgnoreCase("antibiogramnew")){
                    	Map ab = RequestedLabAnalysis.getAntibiogrammes(rs.getString("serverid")+"."+rs.getString("transactionid")+"."+getAnalysisCode());
                    	String result="";
                    	String result2="";
                    	if(labAnalysis.getLimitedVisibility()>0 && !user.getAccessRight("labos.limitedvisibility.select")){
                    		result=MedwanQuery.getInstance().getLabel("web","invisible",user.person.language);                	}
                    	else {
    	                	if(ab.get("germ1")!=null && !(ab.get("germ1")+"").equalsIgnoreCase("")){
    	                		result+=ab.get("germ1")+"\n";
    	                		result2+="\n";
    	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME1");
    	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
    	                			String[] tests = antibiotics.split(",");
    	                			for(int n=0;n<tests.length;n++){
    	                				if(tests[n].split("=").length==2){
    	                					result+="\t"+getAntibioticNew(tests[n].split("=")[0],user.person.language)+"\n";
    	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], user.person.language)+"\n";
    	                				}
    	                			}
    	                		}
    	                	}
    	                	if(ab.get("germ2")!=null && !(ab.get("germ2")+"").equalsIgnoreCase("")){
    	                		if(result.length()>0){
    	                			result+="\n";
    	                    		result2+="\n";
    	                		}
    	                		result2+="\n";
    	                		result+=ab.get("germ2")+"\n";
    	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME2");
    	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
    	                			String[] tests = antibiotics.split(",");
    	                			for(int n=0;n<tests.length;n++){
    	                				if(tests[n].split("=").length==2){
    	                					result+="\t"+getAntibioticNew(tests[n].split("=")[0],user.person.language)+"\n";
    	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], user.person.language)+"\n";
    	                				}
    	                			}
    	                		}
    	                	}
    	                	if(ab.get("germ3")!=null && !(ab.get("3")+"").equalsIgnoreCase("")){
    	                		if(result.length()>0){
    	                			result+="\n";
    	                    		result2+="\n";
    	                		}
    	                		result2+="\n";
    	                		result+=ab.get("germ3")+"\n";
    	                		String antibiotics = (String)ab.get("ANTIBIOGRAMME3");
    	                		if(antibiotics!=null && !antibiotics.replaceAll(",","").equalsIgnoreCase("")){
    	                			String[] tests  = antibiotics.split(",");
    	                			for(int n=0;n<tests.length;n++){
    	                				if(tests[n].split("=").length==2){
    	                					result+="\t"+getAntibioticNew(tests[n].split("=")[0],user.person.language)+"\n";
    	                					result2+=MedwanQuery.getInstance().getLabel("antibiogramme.sensitivity", tests[n].split("=")[1], user.person.language)+"\n";
    	                				}
    	                			}
    	                		}
    	                	}
                    	}
                		history.add(ScreenHelper.formatDate(date)+"|"+result+"|"+result2);
                	}
                	else if(labAnalysis.getEditor().equalsIgnoreCase("antivirogram")){
                		String arva="",arvb="",arvc="";
                		String resultvalue=rs.getString("resultvalue");
    	                for(int i=0;i<MedwanQuery.getInstance().getConfigInt("maxARVlines",12);i++){
    	                	String resistance = extractResistance(resultvalue, "a."+i);
    	                	if(resistance.length()>0){
    	                		//Voeg toe aan arvlijst A
    	                		if(arva.length()>0){
    	                			arva+=";";
    	                		}
    	                		arva+=i+"="+resistance;
    	                	}
    	                	resistance = extractResistance(resultvalue, "b."+i);
    	                	if(resistance.length()>0){
    	                		//Voeg toe aan arvlijst B
    	                		if(arvb.length()>0){
    	                			arvb+=";";
    	                		}
    	                		arvb+=i+"="+resistance;
    	                	}
    	                	resistance = extractResistance(resultvalue, "c."+i);
    	                	if(resistance.length()>0){
    	                		//Voeg toe aan arvlijst C
    	                		if(arvc.length()>0){
    	                			arvc+=";";
    	                		}
    	                		arvc+=i+"="+resistance;
    	                	}
    	                }
                		history.add(ScreenHelper.formatDate(date)+"|"+arva+"|"+arvb+"|"+arvc);
                	}
                	else {
                		history.add(ScreenHelper.formatDate(date)+"|"+rs.getString("resultvalue"));
                	}
            		values++;
            		if(values>=labAnalysis.getHistoryvalues()){
            			break;
            		}
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
            try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    	}
    	return history;
    }
    
    public String getResultRefMax() {
        if((patientId!=null)&&((resultRefMax==null || resultRefMax.length()==0))){
            //Find age and gender of person
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                PreparedStatement ps=ad_conn.prepareStatement("select dateofbirth,gender from Admin where personid=?");
                ps.setInt(1,Integer.parseInt(patientId));
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    setResultRefMax(getResultRefMax(rs.getString("gender"),new Double(MedwanQuery.getInstance().getNrMonths(rs.getDate("dateofbirth"), new java.util.Date())).intValue()));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
            try {
				ad_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

        }
        return resultRefMax;
    }

    public String getResultRefMax(Connection ad_conn) {
        if((patientId!=null)&&((resultRefMax==null || resultRefMax.length()==0))){
            //Find age and gender of person
            try {
                PreparedStatement ps=ad_conn.prepareStatement("select dateofbirth,gender from AdminView where personid=?");
                ps.setInt(1,Integer.parseInt(patientId));
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    setResultRefMax(getResultRefMax(rs.getString("gender"),new Double(getNrMonths(rs.getDate("dateofbirth"), new java.util.Date())).intValue(),ad_conn));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
        }
        return resultRefMax;
    }

    public void setResultRefMax(String resultRefMax) {
    	this.resultRefMax=resultRefMax;
        try{
            this.resultRefMax = new DecimalFormat("#.#####").format(Double.parseDouble(resultRefMax));
        }
        catch (Exception e){

        }
    }

    public String getResultRefMin() {
        if((patientId!=null)&&((resultRefMin==null || resultRefMin.length()==0))){
            //Find age and gender of person
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                PreparedStatement ps=ad_conn.prepareStatement("select dateofbirth,gender from Admin where personid=?");
                ps.setInt(1,Integer.parseInt(patientId));
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    int ageInMonths=new Double(MedwanQuery.getInstance().getNrMonths(rs.getDate("dateofbirth"), new java.util.Date())).intValue();
                    if(ageInMonths<0){
                    	Debug.println("Cannot determine age for lab reference values for personid "+patientId);
                    }
                	setResultRefMin(getResultRefMin(rs.getString("gender"),ageInMonths));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
            try {
				ad_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
        return resultRefMin;
    }

    public double getNrMonths(java.util.Date startDate, java.util.Date endDate){
    	if(startDate==null || endDate==null){
    		return -1;
    	}
    	long millis = endDate.getTime()-startDate.getTime();
    	long month=(365/12)*24*3600;
    	month*=1000;
    	double age =millis/month;
    	return age;
    }
    
    public String getResultRefMin(Connection ad_conn) {
        if((patientId!=null)&&((resultRefMin==null || resultRefMin.length()==0))){
            //Find age and gender of person
            try {
                PreparedStatement ps=ad_conn.prepareStatement("select dateofbirth,gender from AdminView where personid=?");
                ps.setInt(1,Integer.parseInt(patientId));
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    int ageInMonths=new Double(getNrMonths(rs.getDate("dateofbirth"), new java.util.Date())).intValue();
                    if(ageInMonths<0){
                    	Debug.println("Cannot determine age for lab reference values for personid "+patientId);
                    }
                	setResultRefMin(getResultRefMin(rs.getString("gender"),ageInMonths,ad_conn));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
        }
        return resultRefMin;
    }

    public String getUnverifiedResultRefMin() {
        return resultRefMin;
    }

    public void setResultRefMin(String resultRefMin) {
        this.resultRefMin=resultRefMin;
        try{
            this.resultRefMin = new DecimalFormat("#.#####").format(Double.parseDouble(resultRefMin));
        }
        catch(Exception e){
        	
        }
    }

    public String getResultRefMax(String gender, double age){
        String ref = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3, LabAnalysis.idForCode(getAnalysisCode()));
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                ref=rs.getString("tolerance");
                if(ref==null){
                    ref="";
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        return ref;
    }

    public String getResultRefMax(String gender, double age,Connection oc_conn){
        String ref = "";
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3, LabAnalysis.idForCode(getAnalysisCode(),oc_conn));
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                ref=rs.getString("tolerance");
                if(ref==null){
                    ref="";
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        return ref;
    }

    public String getUnverifiedResultRefMax(){
        return resultRefMax;
    }

    //--- RESULT REF MIN --------------------------------------------------------------------------
    public String getResultRefMin(String gender, int age){
        String ref = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3,LabAnalysis.idForCode(getAnalysisCode()));
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                ref=rs.getString("frequency");
                if(ref==null){
                    ref="";
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return ref;
    }

    public String getResultRefMin(String gender, int age, Connection oc_conn){
        String ref = "";
        try {
        	PreparedStatement ps = oc_conn.prepareStatement("select * from AgeGenderControl where type='LabAnalysis' and gender like '%"+gender+"%' and minAge<=? and maxAge>=? and id=?");
            ps.setDouble(1,age);
            ps.setDouble(2,age);
            ps.setString(3,LabAnalysis.idForCode(getAnalysisCode(),oc_conn));
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                ref=rs.getString("frequency");
                if(ref==null){
                    ref="";
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        return ref;
    }

   //--- RESULT USER ID --------------------------------------------------------------------------
    public void setResultUserId(String value){
        this.resultUserId = value;
    }

    public String getResultUserId(){
        return this.resultUserId;
    }

    //--- RESULT DATE -----------------------------------------------------------------------------
    public void setResultDate(java.util.Date value){
        this.resultDate = value;
    }

    public java.util.Date getResultDate(){
        return this.resultDate;
    }

    //--- GET LAB ANALYSIS TYPE -------------------------------------------------------------------
    public static String getAnalysisType(String analysisCode, String sWebLanguage){
        String type = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String select = "SELECT labtype FROM LabAnalysis WHERE labcode = ? and deletetime is null";
            ps = oc_conn.prepareStatement(select);
            ps.setString(1,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                type = ScreenHelper.checkString(rs.getString("labtype"));

                // translate labtype
                     if(type.equals("1")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.blood",sWebLanguage);
                else if(type.equals("2")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.urine",sWebLanguage);
                else if(type.equals("3")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.other",sWebLanguage);
                else if(type.equals("4")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.stool",sWebLanguage);
                else if(type.equals("5")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.sputum",sWebLanguage);
                else if(type.equals("6")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.smear",sWebLanguage);
                else if(type.equals("7")) type = MedwanQuery.getInstance().getLabel("Web.occup","labanalysis.type.liquid",sWebLanguage);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return type;
    }

    //--- GET LAB ANALYSIS TYPE -------------------------------------------------------------------
    public static String getAnalysisUnit(String analysisCode){
        String unit = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String select = "SELECT unit FROM LabAnalysis WHERE labcode = ? and deletetime is null";
            ps = oc_conn.prepareStatement(select);
            ps.setString(1,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                unit = ScreenHelper.checkString(rs.getString("unit"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return unit;
    }

    //--- GET LAB ANALYSIS MONSTER ----------------------------------------------------------------
    public static String getAnalysisMonster(String analysisCode){
        String type = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String select = "SELECT monster FROM LabAnalysis WHERE labcode = ? and deletetime is null";
            ps = oc_conn.prepareStatement(select);
            ps.setString(1,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                type = ScreenHelper.checkString(rs.getString("monster"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return type;
    }

    //--- GET LABANALYSES FOR REQUEST -------------------------------------------------------------
    public static Hashtable getLabAnalysesForLabRequest(int serverId, int transactionId){
        Hashtable labAnalyses = new Hashtable();
        RequestedLabAnalysis labAnalysis;

        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId,b.updateTime FROM RequestedLabAnalyses a,Transactions b where a.serverid=b.serverid and a.transactionId=b.transactionId "+
                             " and a.serverid = ? AND a.transactionid = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            rs = ps.executeQuery();

            // get data from DB
            while(rs.next()){
                labAnalysis = new RequestedLabAnalysis();
                labAnalysis.setServerId(serverId+"");
                labAnalysis.setObjectid(rs.getInt("objectid"));
                labAnalysis.setTransactionId(transactionId+"");

                labAnalysis.patientId    = ScreenHelper.checkString(rs.getString("patientid"));
                labAnalysis.analysisCode = ScreenHelper.checkString(rs.getString("analysiscode"));
                labAnalysis.comment      = ScreenHelper.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId  = ScreenHelper.checkString(rs.getString("userId"));
                labAnalysis.updatetime  =  rs.getTimestamp("updatetime");
                labAnalysis.resultProvisional    = ScreenHelper.checkString(rs.getString("resultprovisional"));
                labAnalysis.finalvalidation = rs.getInt("finalvalidator");

                // result date
                java.util.Date tmpDate = rs.getTimestamp("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getDate("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;

                labAnalyses.put(labAnalysis.analysisCode,labAnalysis);
            }
        }
        catch(Exception e){

            if(e.getMessage().endsWith("NOT FOUND")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalyses;
    }

    //--- GET LABANALYSES FOR REQUEST -------------------------------------------------------------
    public static Hashtable getLabAnalysesForLabRequest(int serverId, int transactionId, String editor){
        Hashtable labAnalyses = new Hashtable();
        RequestedLabAnalysis labAnalysis;

        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId,b.updateTime,c.editorparameters FROM RequestedLabAnalyses a,Transactions b, Labanalysis c where a.serverid=b.serverid and a.transactionId=b.transactionId "+
                             " and a.serverid = ? AND a.transactionid = ? and a.analysiscode=c.labcode and c.editor=?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3, editor);
            rs = ps.executeQuery();

            // get data from DB
            while(rs.next()){
                labAnalysis = new RequestedLabAnalysis();
                labAnalysis.setServerId(serverId+"");
                labAnalysis.setObjectid(rs.getInt("objectid"));
                labAnalysis.setTransactionId(transactionId+"");

                labAnalysis.patientId    = ScreenHelper.checkString(rs.getString("patientid"));
                labAnalysis.analysisCode = ScreenHelper.checkString(rs.getString("analysiscode"));
                labAnalysis.comment      = ScreenHelper.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId  = ScreenHelper.checkString(rs.getString("userId"));
                labAnalysis.updatetime  =  rs.getTimestamp("updatetime");
                labAnalysis.resultProvisional    = ScreenHelper.checkString(rs.getString("resultprovisional"));
                labAnalysis.finalvalidation = rs.getInt("finalvalidator");
                labAnalysis.tag = ScreenHelper.checkString(rs.getString("editorparameters"));

                // result date
                java.util.Date tmpDate = rs.getTimestamp("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getTimestamp("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;

                labAnalyses.put(labAnalysis.analysisCode,labAnalysis);
            }
        }
        catch(Exception e){

            if(e.getMessage().endsWith("NOT FOUND")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalyses;
    }

    //--- DELETE LABANALYSES IN LABREQUEST --------------------------------------------------------
    public static void deleteLabAnalysesInLabRequest(int serverId, int transactionId){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM RequestedLabAnalyses"+
                             " WHERE serverid = ?"+
                             "  AND transactionid = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- REQUIRED DATA SET -----------------------------------------------------------------------
    public boolean requiredDataSet() throws Exception {
        if(this.serverId.length()==0 || this.transactionId.length()==0 ||
           this.patientId.length()==0 || this.analysisCode.length()==0){
            Debug.println("// INFO ////////////////////////////////////////////////");
            Debug.println("*** sServerId      : "+ScreenHelper.checkString(this.serverId));
            Debug.println("*** sTransactionId : "+ScreenHelper.checkString(this.transactionId));
            Debug.println("*** sPatientId     : "+ScreenHelper.checkString(this.patientId));
            Debug.println("*** sPatientId     : "+ScreenHelper.checkString(this.analysisCode)+"\n");

            throw new Exception("RequestedLabAnalysis : store : not all required data is set");
        }

        return true;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        boolean objectExists = exists(Integer.parseInt(this.getServerId()),
                                      Integer.parseInt(this.getTransactionId()),
                                      this.getAnalysisCode());
        store(objectExists);
    }
    
    public static void setScanResultForReference(String sReference){
		if(sReference.split("\\.").length>3){
			Hashtable hAnalyses = RequestedLabAnalysis.getLabAnalysesForLabRequest(Integer.parseInt(sReference.split("\\.")[0]), Integer.parseInt(sReference.split("\\.")[1]), "scan");
			Enumeration eAnalyses = hAnalyses.keys();
			while(eAnalyses.hasMoreElements()){
				RequestedLabAnalysis analysis =(RequestedLabAnalysis)(hAnalyses.get(eAnalyses.nextElement()));
				if(analysis.getFinalvalidationdatetime()==null && analysis.getTag().equals("TP:"+sReference.split("\\.")[3])){
					//This analysis must be updated (value=scan)
					RequestedLabAnalysis.updateValue(Integer.parseInt(sReference.split("\\.")[0]), Integer.parseInt(sReference.split("\\.")[1]), analysis.getAnalysisCode(), "scan");
					RequestedLabAnalysis.setFinalValidation(Integer.parseInt(sReference.split("\\.")[0]), Integer.parseInt(sReference.split("\\.")[1]), MedwanQuery.getInstance().getConfigInt("defaultLabValidator",4));
				}
			}
		}
    }

    public void store(boolean objectExists){
    	PreparedStatement ps = null;
        String sSelect;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            requiredDataSet();

            // must be a positive transactionid, indicating the transaction to which this analysis belongs allready exists
            if(Integer.parseInt(this.transactionId) < 0  && MedwanQuery.getInstance().getConfigInt("enableSlaveServer",0)==0){
                throw new Exception("RequestedLabAnalysis : store : transactionId can not be negative ("+this.transactionId+")");
            }

            if(objectExists){
                //***** UPDATE ********************************************************************
                Debug.println("@@@ RequestedLabAnalysis update @@@");

                sSelect = "UPDATE RequestedLabAnalyses"+
                          " SET serverid=?, transactionid=?, patientid=?, analysiscode=?, "+
                          "  comment=?, resultvalue=?, resultunit=?, resultmodifier=?, resultcomment=?, "+
                          "  resultrefmax=?, resultrefmin=?, resultdate=?, resultuserid=?, resultprovisional=?, updatetime=?, objectid=?"
                          + " WHERE"
                          + " serverid=? and transactionid=? and analysiscode=?";

                ps = oc_conn.prepareStatement(sSelect);

                ps.setInt(1,Integer.parseInt(this.serverId));
                ps.setInt(2,Integer.parseInt(this.transactionId));
                ps.setInt(3,Integer.parseInt(this.patientId));
                ps.setString(4,this.analysisCode);
                ps.setString(5,this.comment);

                // result..
                ps.setString(6,this.resultValue);
                ps.setString(7,this.resultUnit);
                ps.setString(8,this.resultModifier);
                ps.setString(9,this.resultComment);
                ps.setString(10,getResultRefMax());
                ps.setString(11,getResultRefMin());

                // date begin
                if(this.resultDate!=null) ps.setTimestamp(12,new java.sql.Timestamp(this.resultDate.getTime()));
                else                      ps.setNull(12,Types.TIMESTAMP);

                // result userid
                if(this.resultUserId!=null && this.resultUserId.length() > 0) ps.setInt(13,Integer.parseInt(this.resultUserId));
                else                               ps.setNull(13,Types.INTEGER);

                ps.setString(14,this.resultProvisional==""?"1":"0");
                ps.setTimestamp(15, new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setInt(16,this.getObjectid());
                ps.setInt(17,Integer.parseInt(this.serverId));
                ps.setInt(18,Integer.parseInt(this.transactionId));
                ps.setString(19,this.analysisCode);
                ps.executeUpdate();
            }
            else{
                //***** INSERT ****************************************************************
                Debug.println("@@@ RequestedLabAnalysis insert @@@");

                sSelect = "INSERT INTO RequestedLabAnalyses (serverid,transactionid,patientid,analysiscode,"+
                          "  comment,resultvalue,resultunit,resultmodifier,resultcomment,resultrefmax,"+
                          "  resultrefmin,resultdate,resultuserid, resultprovisional,requestdatetime,updatetime,objectid)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);

                ps.setInt(1,Integer.parseInt(this.serverId));
                ps.setInt(2,Integer.parseInt(this.transactionId));
                ps.setInt(3,Integer.parseInt(this.patientId));
                ps.setString(4,this.analysisCode);
                ps.setString(5,this.comment);

                // result..
                ps.setString(6,this.resultValue);
                ps.setString(7,this.resultUnit);
                ps.setString(8,this.resultModifier);
                ps.setString(9,this.resultComment);
                ps.setString(10,getResultRefMax());
                ps.setString(11,getResultRefMin());
                // date begin
                if(this.resultDate!=null) ps.setTimestamp(12,new java.sql.Timestamp(this.resultDate.getTime()));
                else                      ps.setNull(12,Types.TIMESTAMP);

                // result userid
                if(this.resultUserId.length() > 0) ps.setInt(13,Integer.parseInt(this.resultUserId));
                else                               ps.setNull(13,Types.INTEGER);

                ps.setString(14,this.resultProvisional.equalsIgnoreCase("")?"1":"0");
                ps.setTimestamp(15,new Timestamp(new java.util.Date().getTime()));
                ps.setTimestamp(16, new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setInt(17, this.getObjectid());
                ps.executeUpdate();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    public void store(boolean objectExists, Connection oc_conn){
    	PreparedStatement ps = null;
        String sSelect;

        try{
            requiredDataSet();

            // must be a positive transactionid, indicating the transaction to which this analysis belongs allready exists
            if(Integer.parseInt(this.transactionId) < 0){
                throw new Exception("RequestedLabAnalysis : store : transactionId can not be negative ("+this.transactionId+")");
            }

            if(objectExists){
                //***** UPDATE ********************************************************************
                Debug.println("@@@ RequestedLabAnalysis update @@@");

                sSelect = "UPDATE RequestedLabAnalyses"+
                          " SET serverid=?, transactionid=?, patientid=?, analysiscode=?, "+
                          "  comment=?, resultvalue=?, resultunit=?, resultmodifier=?, resultcomment=?, "+
                          "  resultrefmax=?, resultrefmin=?, resultdate=?, resultuserid=?, resultprovisional=?, updatetime=?, objectid=?"
                          + " WHERE"
                          + " serverid=? and transactionid=? and analysiscode=?";

                ps = oc_conn.prepareStatement(sSelect);

                ps.setInt(1,Integer.parseInt(this.serverId));
                ps.setInt(2,Integer.parseInt(this.transactionId));
                ps.setInt(3,Integer.parseInt(this.patientId));
                ps.setString(4,this.analysisCode);
                ps.setString(5,this.comment);

                // result..
                ps.setString(6,this.resultValue);
                ps.setString(7,this.resultUnit);
                ps.setString(8,this.resultModifier);
                ps.setString(9,this.resultComment);
                ps.setString(10,getResultRefMax());
                ps.setString(11,getResultRefMin());

                // date begin
                if(this.resultDate!=null) ps.setTimestamp(12,new java.sql.Timestamp(this.resultDate.getTime()));
                else                      ps.setNull(12,Types.TIMESTAMP);

                // result userid
                if(this.resultUserId.length() > 0) ps.setInt(13,Integer.parseInt(this.resultUserId));
                else                               ps.setNull(13,Types.INTEGER);

                ps.setString(14,this.resultProvisional==""?"1":"0");
                ps.setTimestamp(15, new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setInt(16,this.getObjectid());
                ps.setInt(17,Integer.parseInt(this.serverId));
                ps.setInt(18,Integer.parseInt(this.transactionId));
                ps.setString(19,this.analysisCode);
                ps.executeUpdate();
            }
            else{
                //***** INSERT ****************************************************************
                Debug.println("@@@ RequestedLabAnalysis insert @@@");

                sSelect = "INSERT INTO RequestedLabAnalyses (serverid,transactionid,patientid,analysiscode,"+
                          "  comment,resultvalue,resultunit,resultmodifier,resultcomment,"+
                          "  resultdate,resultuserid, resultprovisional,requestdatetime,updatetime,objectid)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);

                ps.setInt(1,Integer.parseInt(this.serverId));
                ps.setInt(2,Integer.parseInt(this.transactionId));
                ps.setInt(3,Integer.parseInt(this.patientId));
                ps.setString(4,this.analysisCode);
                ps.setString(5,this.comment);

                // result..
                ps.setString(6,this.resultValue);
                ps.setString(7,this.resultUnit);
                ps.setString(8,this.resultModifier);
                ps.setString(9,this.resultComment);
                // date begin
                if(this.resultDate!=null) ps.setTimestamp(10,new java.sql.Timestamp(this.resultDate.getTime()));
                else                      ps.setNull(10,Types.TIMESTAMP);

                // result userid
                if(this.resultUserId.length() > 0) ps.setInt(11,Integer.parseInt(this.resultUserId));
                else                               ps.setNull(11,Types.INTEGER);

                ps.setString(12,this.resultProvisional.equalsIgnoreCase("")?"1":"0");
                ps.setTimestamp(13,new Timestamp(new java.util.Date().getTime()));
                ps.setTimestamp(14, new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setInt(15, this.getObjectid());
                ps.executeUpdate();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- STORE COMMENT (only comment) ------------------------------------------------------------
    public void storeComment(){
        PreparedStatement ps = null;
        String sSelect;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "UPDATE RequestedLabAnalyses SET comment = ?"+
                      " WHERE serverid = ?"+
                      "  AND transactionid = ?"+
                      "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);

            ps.setString(1,this.comment);
            ps.setInt(2,Integer.parseInt(this.serverId));
            ps.setInt(3,Integer.parseInt(this.transactionId));
            ps.setString(4,this.analysisCode);

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- GET -------------------------------------------------------------------------------------
    public static RequestedLabAnalysis get(int serverId, int transactionId, String analysisCode){
        // create LabRequest and initialize
        RequestedLabAnalysis labAnalysis = new RequestedLabAnalysis();
        labAnalysis.setServerId(serverId+"");
        labAnalysis.setTransactionId(transactionId+"");
        labAnalysis.setAnalysisCode(analysisCode);

        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId,b.updateTime FROM RequestedLabAnalyses a,Transactions b where a.serverid=b.serverid and a.transactionid=b.transactionId "+
                             "  AND a.serverid = ?"+
                             "  AND a.transactionid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                labAnalysis.patientId = ScreenHelper.checkString(rs.getString("patientid"));
                labAnalysis.comment   = ScreenHelper.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId   = ScreenHelper.checkString(rs.getString("userId"));
                labAnalysis.updatetime = rs.getTimestamp("updatetime");
                labAnalysis.objectid = rs.getInt("objectid");
                labAnalysis.resultProvisional   = ScreenHelper.checkString(rs.getString("resultprovisional"));

                // result date
                java.util.Date tmpDate = rs.getTimestamp("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getTimestamp("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;
            }
            else{
                throw new Exception("INFO : REQUESTED LABANALYSIS "+serverId+"."+transactionId+"."+analysisCode+" NOT FOUND");
            }
        }
        catch(Exception e){
            labAnalysis = null;

            if(e.getMessage().startsWith("INFO")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalysis;
    }

    public static RequestedLabAnalysis get(int serverId, int transactionId, String analysisCode,Connection oc_conn){
        // create LabRequest and initialize
        RequestedLabAnalysis labAnalysis = new RequestedLabAnalysis();
        labAnalysis.setServerId(serverId+"");
        labAnalysis.setTransactionId(transactionId+"");
        labAnalysis.setAnalysisCode(analysisCode);

        PreparedStatement ps = null;
        ResultSet rs = null;

        try{
            String sSelect = "SELECT a.*,b.userId,b.updateTime FROM RequestedLabAnalyses a,Transactions b where a.serverid=b.serverid and a.transactionid=b.transactionId "+
                             "  AND a.serverid = ?"+
                             "  AND a.transactionid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                labAnalysis.patientId = HL7Server.checkString(rs.getString("patientid"));
                labAnalysis.comment   = HL7Server.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = HL7Server.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = HL7Server.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = HL7Server.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = HL7Server.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = HL7Server.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = HL7Server.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = HL7Server.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId   = HL7Server.checkString(rs.getString("userId"));
                labAnalysis.updatetime = rs.getTimestamp("updatetime");
                labAnalysis.objectid = rs.getInt("objectid");
                labAnalysis.resultProvisional   = HL7Server.checkString(rs.getString("resultprovisional"));

                // result date
                java.util.Date tmpDate = rs.getTimestamp("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getTimestamp("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;
            }
            else{
                throw new Exception("INFO : REQUESTED LABANALYSIS "+serverId+"."+transactionId+"."+analysisCode+" NOT FOUND");
            }
        }
        catch(Exception e){
            labAnalysis = null;

            if(e.getMessage().startsWith("INFO")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalysis;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static RequestedLabAnalysis getByObjectid(int objectId, String analysisCode){
        // create LabRequest and initialize
        RequestedLabAnalysis labAnalysis = new RequestedLabAnalysis();
        labAnalysis.setAnalysisCode(analysisCode);
        if(objectId<0){
        	return labAnalysis;
        }

        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId,b.updateTime FROM RequestedLabAnalyses a,Transactions b where a.serverid=b.serverid and a.transactionid=b.transactionId "+
                             "  AND a.objectid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,objectId);
            ps.setString(2,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                labAnalysis.serverId = ScreenHelper.checkString(rs.getString("serverid"));
                labAnalysis.transactionId = ScreenHelper.checkString(rs.getString("transactionid"));
                labAnalysis.patientId = ScreenHelper.checkString(rs.getString("patientid"));
                labAnalysis.comment   = ScreenHelper.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId   = ScreenHelper.checkString(rs.getString("userId"));
                labAnalysis.updatetime = rs.getTimestamp("updatetime");
                labAnalysis.objectid = rs.getInt("objectid");
                labAnalysis.resultProvisional   = ScreenHelper.checkString(rs.getString("resultprovisional"));

                // result date
                java.util.Date tmpDate = rs.getTimestamp("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getTimestamp("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;
            }
            else{
                throw new Exception("INFO : REQUESTED LABANALYSIS "+objectId+"."+analysisCode+" NOT FOUND");
            }
        }
        catch(Exception e){
            labAnalysis = null;

            if(e.getMessage().startsWith("INFO")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalysis;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static RequestedLabAnalysis getByPersonid(int personid, String analysisCode){
        // create LabRequest and initialize
        RequestedLabAnalysis labAnalysis = new RequestedLabAnalysis();
        labAnalysis.setAnalysisCode(analysisCode);
        if(personid<0){
        	return labAnalysis;
        }

        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM RequestedLabAnalyses where "+
                             "  patientid = ?"+
                             "  AND analysiscode = ? order by updatetime desc";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,personid);
            ps.setString(2,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                labAnalysis.serverId = ScreenHelper.checkString(rs.getString("serverid"));
                labAnalysis.transactionId = ScreenHelper.checkString(rs.getString("transactionid"));
                labAnalysis.patientId = ScreenHelper.checkString(rs.getString("patientid"));
                labAnalysis.comment   = ScreenHelper.checkString(rs.getString("comment"));

                // result..
                labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.requestUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                labAnalysis.updatetime = rs.getTimestamp("updatetime");
                labAnalysis.objectid = rs.getInt("objectid");
                labAnalysis.resultProvisional   = ScreenHelper.checkString(rs.getString("resultprovisional"));

                // result date
                java.util.Date tmpDate = rs.getTimestamp("resultdate");
                if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                tmpDate = rs.getTimestamp("updateTime");
                if(tmpDate!=null) labAnalysis.requestDate = tmpDate;
            }
            else{
                throw new Exception("INFO : REQUESTED LABANALYSIS "+personid+"."+analysisCode+" NOT FOUND");
            }
        }
        catch(Exception e){
            labAnalysis = null;

            if(e.getMessage().startsWith("INFO")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return labAnalysis;
    }

    //--- EXISTS ----------------------------------------------------------------------------------
    public static boolean exists(int serverId, int transactionId, String analysisCode){
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean objectExists = false;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT 1 FROM RequestedLabAnalyses"+
                             " WHERE serverid = ?"+
                             "  AND transactionid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3,analysisCode);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                objectExists = true;
            }
            else{
                throw new Exception("INFO : REQUESTED LABANALYSIS "+serverId+"."+transactionId+"."+analysisCode+" NOT FOUND");
            }
        }
        catch(Exception e){
            if(e.getMessage().startsWith("INFO")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return objectExists;
    }

    //--- FIND ------------------------------------------------------------------------------------

    public static Vector find(String serverId, String transactionId, String patientId, String analysisCode,
                              String comment, String resultValue, String resultUnit, String resultModifier,
                              String resultComment, String resultRefMax, String resultRefMin, String resultUserId,
                              String resultDateMin, String resultDateMax, String sSortCol, String sSortDir, boolean openAnalysesOnly,String sRequestUserId){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        if(sSortCol==null || sSortCol.length()==0){
        	sSortCol="resultdate";
        }
        
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT a.*,b.userId FROM RequestedLabAnalyses a,Transactions b";

            if(serverId.length()>0 || transactionId.length()>0 || patientId.length()>0 || analysisCode.length()>0 ||
               comment.length()>0 || resultValue.length()>0 || resultUnit.length()>0 || resultModifier.length()>0 ||
               resultComment.length()>0 || resultRefMax.length()>0 || resultRefMin.length()>0 ||
               resultUserId.length()>0 || sRequestUserId.length()>0 || resultDateMin.length()>0 || resultDateMax.length()>0){
                sSelect+= " WHERE a.transactionId=b.transactionId and a.serverid=b.serverid and ";

                String lowerComment       = ScreenHelper.getConfigParam("lowerCompare","comment"),
                       lowerResultComment = ScreenHelper.getConfigParam("lowerCompare","resultcomment");

                if(serverId.length()>0)      sSelect+= "a.serverid = ? AND ";
                if(transactionId.length()>0) sSelect+= "a.transactionid = ? AND ";
                if(patientId.length()>0)     sSelect+= "a.patientid = ? AND ";
                if(analysisCode.length()>0)  sSelect+= "a.analysiscode LIKE ? AND ";
                if(comment.length()>0)       sSelect+= lowerComment+" LIKE ? AND ";
                if(resultValue.length()>0)   sSelect+= "a.resultvalue = ? AND ";
                if(resultUnit.length()>0)    sSelect+= "a.resultunit LIKE ? AND ";

                if(openAnalysesOnly){
                    sSelect+= "(a.resultvalue is null or "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(a.resultValue)=0) AND ";
                }
                else{
                    if(resultModifier.length()>0) sSelect+= "a.resultmodifier = ? AND ";
                }

                if(resultComment.length()>0) sSelect+= lowerResultComment+" LIKE ? AND ";
                if(resultRefMax.length()>0)  sSelect+= "a.resultrefmax = ? AND ";
                if(resultRefMin.length()>0)  sSelect+= "a.resultrefmin = ? AND ";
                if(resultUserId.length()>0)  sSelect+= "a.resultuserid = ? AND ";
                if(sRequestUserId.length()>0)  sSelect+= "b.userId = ? AND ";
                if(resultDateMin.length()>0)    sSelect+= "a.resultdate >= ? AND ";
                if(resultDateMax.length()>0)    sSelect+= "a.resultdate <= ? AND ";

                // remove last AND if any
                if(sSelect.indexOf("AND ")>-1){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            // order by selected col or default col
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if(serverId.length()>0)       ps.setInt(questionMarkIdx++,Integer.parseInt(serverId));
            if(transactionId.length()>0 ) ps.setInt(questionMarkIdx++,Integer.parseInt(transactionId));
            if(patientId.length()>0)      ps.setInt(questionMarkIdx++,Integer.parseInt(patientId));
            if(analysisCode.length()>0)   ps.setString(questionMarkIdx++,analysisCode);
            if(comment.length()>0)        ps.setString(questionMarkIdx++,comment.toLowerCase());
            if(resultValue.length()>0)    ps.setString(questionMarkIdx++,resultValue);
            if(resultUnit.length()>0)     ps.setString(questionMarkIdx++,resultUnit);
            if(resultModifier.length()>0) ps.setString(questionMarkIdx++,resultModifier);
            if(resultComment.length()>0)  ps.setString(questionMarkIdx++,resultComment.toLowerCase());
            if(resultRefMax.length()>0)   ps.setString(questionMarkIdx++,resultRefMax);
            if(resultRefMin.length()>0)   ps.setString(questionMarkIdx++,resultRefMin);
            if(resultUserId.length()>0)   ps.setInt(questionMarkIdx++,Integer.parseInt(resultUserId));
            if(sRequestUserId.length()>0)   ps.setInt(questionMarkIdx++,Integer.parseInt(sRequestUserId));
            if(resultDateMin.length()>0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(resultDateMin));
            if(resultDateMax.length()>0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(resultDateMax));

            // execute
            rs = ps.executeQuery();

            RequestedLabAnalysis labAnalysis;
            while(rs.next()){
                    labAnalysis = new RequestedLabAnalysis();
                    labAnalysis.setServerId(rs.getString("serverid"));
                    labAnalysis.setObjectid(rs.getInt("objectid"));
                    labAnalysis.setTransactionId(rs.getString("transactionid"));
                    labAnalysis.setAnalysisCode(rs.getString("analysiscode"));
                    labAnalysis.patientId = ScreenHelper.checkString(rs.getString("patientid"));
                    labAnalysis.comment   = ScreenHelper.checkString(rs.getString("comment"));

                    // result..
                    labAnalysis.resultValue    = ScreenHelper.checkString(rs.getString("resultvalue"));
                    labAnalysis.resultUnit     = ScreenHelper.checkString(rs.getString("resultunit"));
                    labAnalysis.resultModifier = ScreenHelper.checkString(rs.getString("resultmodifier"));
                    labAnalysis.resultComment  = ScreenHelper.checkString(rs.getString("resultcomment"));
                    labAnalysis.resultRefMax   = ScreenHelper.checkString(rs.getString("resultrefmax"));
                    labAnalysis.resultRefMin   = ScreenHelper.checkString(rs.getString("resultrefmin"));
                    labAnalysis.resultUserId   = ScreenHelper.checkString(rs.getString("resultuserid"));
                    labAnalysis.requestUserId   = ScreenHelper.checkString(rs.getString("userId"));
                    labAnalysis.updatetime = rs.getTimestamp("updatetime");
                    labAnalysis.requestDate   = rs.getTimestamp("requestdatetime");
                    labAnalysis.finalvalidationdatetime   = rs.getTimestamp("finalvalidationdatetime");
                    labAnalysis.resultProvisional   = ScreenHelper.checkString(rs.getString("resultprovisional"));

                    // result date
                    java.util.Date tmpDate = rs.getTimestamp("resultdate");
                    if(tmpDate!=null) labAnalysis.resultDate = tmpDate;
                    
                    foundObjects.add(labAnalysis);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundObjects;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(int serverId, int transactionId, String analysisCode){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM RequestedLabAnalyses"+
                             " WHERE serverid = ?"+
                             "  AND transactionid = ?"+
                             "  AND analysiscode = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,transactionId);
            ps.setString(3,analysisCode);
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- GET LAB REQUEST URGENCY -----------------------------------------------------------------
    // stored as an item of the belonging transaction (labRequest)
    //---------------------------------------------------------------------------------------------
    public static String getLabRequestUrgency(String serverId, String transactionId){
        String urgency = "";

        TransactionVO labRequest = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(serverId),Integer.parseInt(transactionId));
        ItemVO urgencyItem = labRequest.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_URGENCY");
        if(urgencyItem!=null) urgency = urgencyItem.getValue();

        return urgency;
    }

    //--- GET LAB REQUEST DATE --------------------------------------------------------------------
    // stored as an item of the belonging transaction (labRequest)
    //---------------------------------------------------------------------------------------------
    public static java.util.Date getLabRequestDate(String serverId, String transactionId){
        TransactionVO labRequest = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(serverId),Integer.parseInt(transactionId));
        return labRequest.getUpdateTime();
    }

    public void update(String sServerId, String sTransactionId, String sAnalysisCode){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE RequestedLabAnalyses"+
                         " SET comment=?, resultvalue=?, resultunit=?, resultmodifier=?, resultcomment=?,"+
                         " resultrefmax=?, resultrefmin=?, resultdate=?, resultuserid=?, resultprovisional=?, updatetime=?, objectid=?"+
                         " WHERE serverid = ? AND transactionid = ? AND analysiscode = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setString(1,ScreenHelper.checkString(this.getComment()));
            ps.setString(2,ScreenHelper.checkString(this.getResultValue()));
            ps.setString(3,ScreenHelper.checkString(this.getResultUnit()));
            ps.setString(4,ScreenHelper.checkString(this.getResultModifier()));
            ps.setString(5,ScreenHelper.checkString(this.getResultComment()));
            ps.setString(6,ScreenHelper.checkString(this.getResultRefMax()));
            ps.setString(7,ScreenHelper.checkString(this.getResultRefMin()));
            ps.setDate(8,new java.sql.Date(this.getResultDate().getTime()));
            ps.setInt(9,Integer.parseInt(this.getResultUserId()));
            ps.setString(10,ScreenHelper.checkString(this.getResultProvisional()));
            ps.setTimestamp(11, new java.sql.Timestamp(new java.util.Date().getTime()));
            ps.setInt(12,this.getObjectid());
            // where
            ps.setInt(13,Integer.parseInt(sServerId));
            ps.setInt(14,Integer.parseInt(sTransactionId));
            ps.setString(15,sAnalysisCode);
            ps.executeUpdate();

            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void updateValue(int serverid,int transactionid, String analysiscode, String value){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultvalue=?,resultdate=?,updatetime=? where serverid=? and transactionid=? and analysiscode=? and resultvalue<>?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,value);
            ps.setTimestamp(2, new java.sql.Timestamp(new java.util.Date().getTime()));
            ps.setTimestamp(3, new java.sql.Timestamp(new java.util.Date().getTime()));
            ps.setInt(4,serverid);
            ps.setInt(5,transactionid);
            ps.setString(6,analysiscode);
            ps.setString(7,value);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static int updateValue(int serverid,int transactionid, String analysiscode, String value, int userid){
        int rows=0;
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultvalue=?,resultdate=?,updatetime=?,resultuserid=? where serverid=? and transactionid=? and analysiscode=? and resultvalue<>?";
	        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,value);
            ps.setTimestamp(2, new java.sql.Timestamp(new java.util.Date().getTime()));
            ps.setTimestamp(3, new java.sql.Timestamp(new java.util.Date().getTime()));
            ps.setInt(4,userid);
            ps.setInt(5,serverid);
            ps.setInt(6,transactionid);
            ps.setString(7,analysiscode);
            ps.setString(8,value);
            rows=ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return rows;
    }

    public static void updateResultComment(int serverid,int transactionid, String analysiscode, String comment){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultcomment=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,comment);
            ps.setInt(2,serverid);
            ps.setInt(3,transactionid);
            ps.setString(4,analysiscode);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setConfirmed(int serverid,int transactionid, boolean confirmed,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultprovisional=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+")";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,confirmed?"":"1");
            ps.setInt(2,serverid);
            ps.setInt(3,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setTechnicalValidation(int serverid,int transactionid, int technicalvalidator,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set technicalvalidator=?,technicalvalidationdatetime=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and technicalvalidator is null and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,technicalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setWorklisted(int serverid,int transactionid,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set worklisteddatetime=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and worklisteddatetime is null";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(2,serverid);
            ps.setInt(3,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and finalvalidator is null and not (resultvalue is null or resultvalue='') ";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses,String value){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and finalvalidator is null and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setModifiedFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses,String value){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setForcedFinalValidation(int serverid,int transactionid, int finalvalidator,String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set resultuserid=?,finalvalidator=?,finalvalidationdatetime=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+") and (finalvalidator is null or resultuserid is null)";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setInt(2,finalvalidator);
            ps.setTimestamp(3,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(4,serverid);
            ps.setInt(5,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void unvalidate(int serverid,int transactionid, String worklistAnalyses){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=null,finalvalidationdatetime=null,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and analysiscode in ("+worklistAnalyses+")";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setFinalValidation(int serverid,int transactionid, int finalvalidator){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set finalvalidator=?,finalvalidationdatetime=?,updatetime="+MedwanQuery.getInstance().getConfigString("dateFunction","getdate()")+" where serverid=? and transactionid=? and finalvalidator is null and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,finalvalidator);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void setObjectid(int serverid,int transactionid, int objectid){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="update RequestedLabAnalyses set objectid=?,updatetime=? where serverid=? and transactionid=? and (objectid is null or objectid<0)";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,objectid);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(3,serverid);
            ps.setInt(4,transactionid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static String findUnvalidatedAnalyses(){
        String result="";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct a.analysiscode from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and (finalvalidator='' or finalvalidator is null) and worklisteddatetime>? and not (resultvalue is null or resultvalue='')";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            long hour=3600*1000;
            long day = 24*hour;
            ps.setDate(1, new Date(new java.util.Date().getTime()-90*day));
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                if(result.length()>0){
                    result+=",";
                }
                result+="'"+rs.getString("analysiscode")+"'";
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return result;
}

    public static String findUntreatedAnalyses(int personid){
        String result="";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct a.analysiscode from RequestedLabAnalyses a, Transactions b, AdminView d where a.serverid=b.serverid and a.transactionId=b.transactionId and a.patientid=d.personid and finalvalidator is null and patientid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                if(result.length()>0){
                    result+=",";
                }
                result+="'"+rs.getString("analysiscode")+"'";
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return result;
    }

    public static String findRequestedAnalysis(String requests){
        String result="",serverids="",transactionids="";
        Hashtable hServerids = new Hashtable();
        Hashtable hTransactionids = new Hashtable();
        String[] requestids = requests.split(",");
        for(int n=0;n<requestids.length;n++){
            hServerids.put(requestids[n].split("\\.")[0],"1");
            hTransactionids.put(requestids[n].split("\\.")[1],"1");
        }
        Enumeration enumeration = hServerids.keys();
        while(enumeration.hasMoreElements()){
            if(serverids.length()>0){
                serverids+=",";
            }
            serverids+=(String)enumeration.nextElement();
        }
        enumeration = hTransactionids.keys();
        while(enumeration.hasMoreElements()){
            if(transactionids.length()>0){
                transactionids+=",";
            }
            transactionids+=(String)enumeration.nextElement();
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct a.analysiscode,b.labgroup from RequestedLabAnalyses a, LabAnalysis b where a.analysiscode=b.labcode and b.deletetime is null and serverid in ("+serverids+") and transactionid in ("+transactionids+") order by labgroup,analysiscode";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                if(result.length()>0){
                    result+=",";
                }
                result+=rs.getString("labgroup")+"."+rs.getString("analysiscode");
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return result;
    }
    public Map getAntiVirogrammes(String sUid){
       Map map = new LinkedHashMap();
       String[] arvs=getResultValue().split(";");
       for(int n=0;n<arvs.length;n++){
    	   if(arvs[n].split("=").length>1){
    		   map.put(arvs[n].split("=")[0], arvs[n].split("=")[1]);
    	   }
       }
       return map;

    }
    public static Map getAntibiogrammes(String sUid){
        Map map = new LinkedHashMap();
          PreparedStatement ps = null;
          ResultSet rs = null;
          Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // delete all items
            String sSelect = "SELECT * FROM OC_ANTIBIOGRAMS"+
                             " WHERE OC_AB_REQUESTEDLABANALYSISUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sUid);

            rs = ps.executeQuery();
           if(rs.next()){
              map.put("germ1",rs.getString("OC_AB_GERM1"));
              map.put("germ2",rs.getString("OC_AB_GERM2"));
              map.put("germ3",rs.getString("OC_AB_GERM3")); 
              map.put("ANTIBIOGRAMME1",rs.getString("OC_AB_ANTIBIOGRAMME1"));
              map.put("ANTIBIOGRAMME2",rs.getString("OC_AB_ANTIBIOGRAMME2"));
              map.put("ANTIBIOGRAMME3",rs.getString("OC_AB_ANTIBIOGRAMME3"));
           }
           rs.close();
           ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

       return map;

    }
    public static void setAntibiogrammes(String sName,String sValue,String userUid){
         PreparedStatement ps = null;

         Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String[] tName = sName.split("\\.");
            if(existsAntibiogrammesByUid(tName[1]+"."+tName[2]+"."+tName[3])){
               String sSelect = "UPDATE OC_ANTIBIOGRAMS SET OC_AB_UPDATETIME = ?,OC_AB_UPDATEUID = ?";
                sSelect+= ",OC_AB_"+tName[4].toUpperCase()+" = ? WHERE OC_AB_REQUESTEDLABANALYSISUID = ?";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()));
                ps.setString(2,userUid);
                ps.setString(3,sValue);
                ps.setString(4,tName[1]+"."+tName[2]+"."+tName[3]);
                ps.executeUpdate();

            }else{
                String sSelect = "INSERT INTO OC_ANTIBIOGRAMS (OC_AB_REQUESTEDLABANALYSISUID,OC_AB_CREATETIME,OC_AB_UPDATEUID";
                sSelect+= ",OC_AB_"+tName[4].toUpperCase()+")";
                sSelect+=" VALUES(?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,tName[1]+"."+tName[2]+"."+tName[3]);
                ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
                ps.setString(3,userUid);
                ps.setString(4,sValue);
                ps.executeUpdate();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

    }
      public static boolean existsAntibiogrammesByUid(String uid){
         PreparedStatement ps = null;
          ResultSet rs = null;
         boolean exists = false;
         Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_AB_REQUESTEDLABANALYSISUID FROM OC_ANTIBIOGRAMS"+
                             " WHERE OC_AB_REQUESTEDLABANALYSISUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,uid);

            rs = ps.executeQuery();
           if(rs.next()){
              exists = true; 
           }
           rs.close();
           ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

       return exists;
    }
      public boolean existsNonEmptyAntibiogrammesByUid(String uid){
    	  boolean exists=false;
          PreparedStatement ps = null;
          ResultSet rs = null;
          Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
          try{
        	  String sql="select * from OC_ANTIBIOGRAMS where OC_AB_REQUESTEDLABANALYSISUID=? AND" +
        	  		" "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(OC_AB_GERM1)+"+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(OC_AB_GERM2)+"+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(OC_AB_GERM3)>0";
        	  ps=oc_conn.prepareStatement(sql);
        	  ps.setString(1, uid);
        	  rs = ps.executeQuery();
        	  exists = rs.next();
        	  rs.close();
        	  ps.close();
          }
          catch(Exception e){
        	  e.printStackTrace();
          }
          try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	  
    	  return exists;
      }
      public static List getAntibiogrammesGerm(String s){
         List l = new LinkedList();
         PreparedStatement ps = null;
          ResultSet rs = null;
          Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_GERM_CODE,OC_GERM_NAME FROM OC_GERMS"+
                             " WHERE OC_GERM_NAME like '%"+s+"%' or OC_GERM_CODE='"+s.split(",")[0]+"'";
            ps = oc_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();
            String sResult = "";
           while(rs.next()){
               sResult = rs.getString("OC_GERM_CODE")+", "+rs.getString("OC_GERM_NAME");
               l.add(sResult);
           }
           rs.close();
           ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

       return l;
    }
      
      public String getNotifyBySMS(){
      //public static String getNotifyBySMS(){
    	  //transactieitem ophalen dat SMS nummer zou kunnen bevatten
    	  ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(this.getServerId()), Integer.parseInt(this.getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS");
    	  //ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(getServerId()), Integer.parseInt(getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS");
    	  if(itemVO!=null){
    		  if(itemVO.getValue().trim().length()>0){
    			  return itemVO.getValue();
    		  }
    	  }
    	  return null;
      }

      public String getNotifyByEmail(){
    	  //transactieitem ophalen dat Email adres zou kunnen bevatten
    	  ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(this.getServerId()), Integer.parseInt(this.getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EMAIL");
    	  if(itemVO!=null){
    		  if(itemVO.getValue().indexOf("@")>-1){
    			  return itemVO.getValue();
    		  }
    	  }
    	  return null;
      }
      
      public boolean getNotifyByEmailAbnormalOnly(){
    	  //transactieitem ophalen dat Email adres zou kunnen bevatten
    	  ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(this.getServerId()), Integer.parseInt(this.getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EMAIL_ABNORMALONLY");
    	  if(itemVO!=null){
  			  return itemVO.getValue().equalsIgnoreCase("medwan.common.true");
    	  }
    	  return false;
      }
      
      public boolean getNotifyBySMSAbnormalOnly(){
    	  //transactieitem ophalen dat Email adres zou kunnen bevatten
    	  ItemVO itemVO = MedwanQuery.getInstance().getItem(Integer.parseInt(this.getServerId()), Integer.parseInt(this.getTransactionId()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS_ABNORMALONLY");
    	  if(itemVO!=null){
    		  return itemVO.getValue().equalsIgnoreCase("medwan.common.true");
    	  }
    	  return false;
      }
      
      
}
