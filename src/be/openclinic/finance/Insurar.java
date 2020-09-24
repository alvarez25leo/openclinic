package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;

import java.util.HashSet;
import java.util.Hashtable;
import java.util.Vector;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class Insurar extends OC_Object {
    private String name;
    private String contact;
    private String language;
    private String contactPerson;
    private String officialName;
    private Vector insuranceCategories;
    private String type;
    private int userid;
    private String defaultPatientInvoiceModel;
    private String defaultInsurarInvoiceModel;
    private String allowedReductions;
    private String modifiers;
    private HashSet prestations;

    public boolean isPrestationVisible(String prestationUid){
    	return getUseLimitedPrestationsList()==0 || prestations.contains(prestationUid);
    }
    
    public void loadPrestations(){
		prestations = new HashSet();
    	if(getUseLimitedPrestationsList()==1){
    		//Load all prestationuids linked to this insurer
            PreparedStatement ps = null;
            ResultSet rs = null;
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String sQuery = "SELECT a.* FROM OC_INSURARPRESTATIONS a,OC_PRESTATIONS b"+
                                " WHERE OC_INSURARPRESTATION_INSURARUID=? and"
                                + " OC_PRESTATION_OBJECTID=replace(OC_INSURARPRESTATION_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"
                                		+ " ORDER by OC_PRESTATION_DESCRIPTION";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,getUid());
                rs = ps.executeQuery();
                while(rs.next()){
                    prestations.add(rs.getString("OC_INSURARPRESTATION_PRESTATIONUID"));
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            finally{
                try{
                    if(ps!=null) ps.close();
                    if(rs!=null) rs.close();
                    oc_conn.close();
                }
                catch(SQLException e){
                    e.printStackTrace();
                }
            }
    	}
    }
    
    public static void deletePrestations(String uid){
        PreparedStatement ps = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "DELETE * FROM OC_INSURARPRESTATIONS"+
                            " WHERE OC_INSURARPRESTATION_INSURARUID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,uid);
            ps.execute();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }
    
    public HashSet getPrestations() {
		return prestations;
	}

	public void setPrestations(HashSet prestations) {
		this.prestations = prestations;
	}

	public String getModifiers() {
		return modifiers;
	}

	public void setModifiers(String modifiers) {
		this.modifiers = modifiers;
	}

	public int getNoSupplements(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[0]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}
	
	public void setNoSupplements(int n){
		setModifier(0,n+"");
	}
	
	public int getCoverSupplements(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[1]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}
	
	public void setCoverSupplements(int n){
		setModifier(1,n+"");
	}
	
	public int getRequireAffiliateID(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[2]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}
	
	public void setRequireAffiliateID(int n){
		setModifier(2,n+"");
	}
	
	public int getRequireValidation(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[3]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}
	
	public void setRequireValidation(int n){
		setModifier(3,n+"");
	}
	
	public int getInactive(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[4]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setInactive(int n){
		setModifier(4,n+"");
	}
	
	public int getIncludeAllPatientInvoiceDebets(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[5]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setIncludeAllPatientInvoiceDebets(int n){
		setModifier(5,n+"");
	}
	
	public String getAccountingCode(){
		String n="";
		if(getModifiers()!=null){
			try{
				n=getModifiers().split(";")[6];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setAccountingCode(String n){
		setModifier(6,n+"");
	}
	
	public int getAllowTariffNegociations(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[7]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setAllowTariffNegociations(int n){
		setModifier(7,n+"");
	}
	
	public int getUseLimitedPrestationsList(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[8]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setUseLimitedPrestationsList(int n){
		setModifier(8,n+"");
	}
	
	public int getInsuranceReferenceNumberMandatory(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[9]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setInsuranceReferenceNumberMandatory(int n){
		setModifier(9,n+"");
	}
	
	public int getCanPrintProforma(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[10]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setCanPrintProforma(int n){
		setModifier(10,n+"");
	}
	
	public int getInvoiceCommentMandatory(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[11]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setInvoiceCommentMandatory(int n){
		setModifier(11,n+"");
	}
	
	public int getNeedsApproval(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[12]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setNeedsApproval(int n){
		setModifier(12,n+"");
	}
	
	public String getAccreditationMechanism(){
		String n="";
		if(getModifiers()!=null){
			try{
				n=getModifiers().split(";")[13];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setAccreditationMechanism(String s){
		setModifier(13,s);
	}
	
	public int getInsuranceStatusMandatory(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[14]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setInsuranceStatusMandatory(int n){
		setModifier(14,n+"");
	}
	
	public int getInsuranceMemberImmatMandatory(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[15]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setInsuranceMemberImmatMandatory(int n){
		setModifier(15,n+"");
	}
	
	public int getInsuranceMemberEmployerMandatory(){
		int n=0;
		if(getModifiers()!=null){
			try{
				n=Integer.parseInt(getModifiers().split(";")[16]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}

	public void setInsuranceMemberEmployerMandatory(int n){
		setModifier(16,n+"");
	}
	
	public void setModifier(int index,String value){
		if(getModifiers()==null){
			setModifiers("");
		}
		String[] m = getModifiers().split(";");
		if(m.length<=index){
			setModifiers(getModifiers()+"; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;".substring(0,(index+1-m.length)*2));
			m = getModifiers().split(";");
		}
		m[index]=value;
		modifiers="";
		for(int n=0;n<m.length;n++){
			modifiers+=m[n]+";";
		}
	}
	
	public String getAllowedReductions() {
		return allowedReductions;
	}

	public void setAllowedReductions(String allowedReductions) {
		this.allowedReductions = allowedReductions;
	}

	public String getDefaultPatientInvoiceModel() {
		return defaultPatientInvoiceModel;
	}

	public void setDefaultPatientInvoiceModel(String defaultPatientInvoiceModel) {
		this.defaultPatientInvoiceModel = defaultPatientInvoiceModel;
	}

	public String getDefaultInsurarInvoiceModel() {
		return defaultInsurarInvoiceModel;
	}

	public void setDefaultInsurarInvoiceModel(String defaultInsurarInvoiceModel) {
		this.defaultInsurarInvoiceModel = defaultInsurarInvoiceModel;
	}

	//--- CONSTRUCTOR ---
    public Insurar(){
        this.insuranceCategories = new Vector();
    }

    //--- GETTERS AND SETTERS ---------------------------------------------------------------------
    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setName(String name) {
        this.name = name;
    }
    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getContactPerson() {
        return contactPerson;
    }

    public void setContactPerson(String contactPerson) {
        this.contactPerson = contactPerson;
    }

    public void setOfficialName(String officialName) {
        this.officialName = officialName;
    }

    public String getOfficialName() {
        return officialName;
    }

    public Vector getInsuraceCategories() {
        return insuranceCategories;
    }

    public void setInsuraceCategories(Vector insuraceCategories) {
        this.insuranceCategories = insuraceCategories;
    }
    

    //--- GET INSURANCE CATEGORY ------------------------------------------------------------------
    public InsuranceCategory getInsuranceCategory(String category){
        InsuranceCategory insuranceCategory = new InsuranceCategory();
        for(int n=0;n<insuranceCategories.size();n++){
            InsuranceCategory insCat = (InsuranceCategory)insuranceCategories.elementAt(n);
            if(insCat.getCategory().equalsIgnoreCase(category)){
                return insCat;
            }
        }
        return insuranceCategory;
    }

    //--- ADD INSURANCE CATEGORY ------------------------------------------------------------------
    public void addInsuranceCategory(String uid,String category,String label,String patientShare){
        for(int n=0;n<insuranceCategories.size();n++){
            InsuranceCategory insCat = (InsuranceCategory)insuranceCategories.elementAt(n);
            if(insCat.getCategory().equalsIgnoreCase(category)){
                insCat.setUid(uid);
                insCat.setLabel(label);
                insCat.setPatientShare(patientShare);
                return;
            }
        }

        insuranceCategories.add(new InsuranceCategory(uid,category,label,patientShare,getUid()));
    }

    //--- GET INSURARS BY NAME --------------------------------------------------------------------
    public static Vector getInsurarsByName(String name){
        Vector insurars = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "SELECT * FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_NAME LIKE ? order by OC_INSURAR_NAME";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,name+"%");
            rs = ps.executeQuery();
            while(rs.next()){
                insurars.add(Insurar.get(rs.getInt("OC_INSURAR_SERVERID"),rs.getInt("OC_INSURAR_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
                oc_conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }

        return insurars;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Insurar get(String uid){
        if ((uid!=null)&&(uid.length()>0)){
            String [] ids = uid.split("\\.");
            if (ids.length==2){
                return get(Integer.parseInt(ids[0]),Integer.parseInt(ids[1]));
            }
        }
        return new Insurar();
    }

    public static Insurar get(Connection oc_conn,String uid){
        if ((uid!=null)&&(uid.length()>0)){
            String [] ids = uid.split("\\.");
            if (ids.length==2){
                return get(oc_conn,Integer.parseInt(ids[0]),Integer.parseInt(ids[1]));
            }
        }
        return new Insurar();
    }

    public static Insurar get(int serverid, int objectid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Insurar insurar = new Insurar();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "SELECT * FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_SERVERID=? AND OC_INSURAR_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
            rs = ps.executeQuery();

            if(rs.next()){
                insurar.setUid(serverid+"."+objectid);
                insurar.setName(rs.getString("OC_INSURAR_NAME"));
                insurar.setLanguage(rs.getString("OC_INSURAR_LANGUAGE"));
                insurar.setContact(rs.getString("OC_INSURAR_CONTACT"));
                insurar.setContactPerson(rs.getString("OC_INSURAR_CONTACTPERSON"));
                insurar.setOfficialName(rs.getString("OC_INSURAR_OFFICIAL_NAME"));
                insurar.setCreateDateTime(rs.getTimestamp("OC_INSURAR_CREATETIME"));
                insurar.setUpdateDateTime(rs.getTimestamp("OC_INSURAR_UPDATETIME"));
                insurar.setUpdateUser(rs.getString("OC_INSURAR_UPDATEUID"));
                insurar.setVersion(rs.getInt("OC_INSURAR_VERSION"));
                insurar.setType(rs.getString("OC_INSURAR_TYPE"));
                insurar.setDefaultInsurarInvoiceModel(rs.getString("OC_INSURAR_DEFAULTINSURARINVOICEMODEL"));
                insurar.setDefaultPatientInvoiceModel(rs.getString("OC_INSURAR_DEFAULTPATIENTINVOICEMODEL"));
                insurar.setAllowedReductions(rs.getString("OC_INSURAR_ALLOWEDREDUCTIONS"));
                insurar.setModifiers(rs.getString("OC_INSURAR_MODIFIERS"));
                rs.close();
                ps.close();

                // load categories
                sQuery = "SELECT * FROM OC_INSURANCECATEGORIES"+
                         " WHERE OC_INSURANCECATEGORY_INSURARUID=?"+
                         "  ORDER BY OC_INSURANCECATEGORY_CATEGORY";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,insurar.getUid());
                rs = ps.executeQuery();
                while(rs.next()){
                    insurar.addInsuranceCategory(
                        rs.getString("OC_INSURANCECATEGORY_SERVERID")+"."+rs.getString("OC_INSURANCECATEGORY_OBJECTID"),
                        rs.getString("OC_INSURANCECATEGORY_CATEGORY"),
                        rs.getString("OC_INSURANCECATEGORY_LABEL"),
                        rs.getInt("OC_INSURANCECATEGORY_PATIENTSHARE")+""
                    );
                }
                rs.close();
                ps.close();
                insurar.loadPrestations();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
                oc_conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }

        return insurar;
    }

    public static Insurar get(Connection oc_conn,int serverid, int objectid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Insurar insurar = new Insurar();

        try{
            String sQuery = "SELECT * FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_SERVERID=? AND OC_INSURAR_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
            rs = ps.executeQuery();

            if(rs.next()){
                insurar.setUid(serverid+"."+objectid);
                insurar.setName(rs.getString("OC_INSURAR_NAME"));
                insurar.setLanguage(rs.getString("OC_INSURAR_LANGUAGE"));
                insurar.setContact(rs.getString("OC_INSURAR_CONTACT"));
                insurar.setContactPerson(rs.getString("OC_INSURAR_CONTACTPERSON"));
                insurar.setOfficialName(rs.getString("OC_INSURAR_OFFICIAL_NAME"));
                insurar.setCreateDateTime(rs.getTimestamp("OC_INSURAR_CREATETIME"));
                insurar.setUpdateDateTime(rs.getTimestamp("OC_INSURAR_UPDATETIME"));
                insurar.setUpdateUser(rs.getString("OC_INSURAR_UPDATEUID"));
                insurar.setVersion(rs.getInt("OC_INSURAR_VERSION"));
                insurar.setType(rs.getString("OC_INSURAR_TYPE"));
                insurar.setDefaultInsurarInvoiceModel(rs.getString("OC_INSURAR_DEFAULTINSURARINVOICEMODEL"));
                insurar.setDefaultPatientInvoiceModel(rs.getString("OC_INSURAR_DEFAULTPATIENTINVOICEMODEL"));
                insurar.setAllowedReductions(rs.getString("OC_INSURAR_ALLOWEDREDUCTIONS"));
                insurar.setModifiers(rs.getString("OC_INSURAR_MODIFIERS"));
                rs.close();
                ps.close();

                // load categories
                sQuery = "SELECT * FROM OC_INSURANCECATEGORIES"+
                         " WHERE OC_INSURANCECATEGORY_INSURARUID=?"+
                         "  ORDER BY OC_INSURANCECATEGORY_CATEGORY";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,insurar.getUid());
                rs = ps.executeQuery();
                while(rs.next()){
                    insurar.addInsuranceCategory(
                        rs.getString("OC_INSURANCECATEGORY_SERVERID")+"."+rs.getString("OC_INSURANCECATEGORY_OBJECTID"),
                        rs.getString("OC_INSURANCECATEGORY_CATEGORY"),
                        rs.getString("OC_INSURANCECATEGORY_LABEL"),
                        rs.getInt("OC_INSURANCECATEGORY_PATIENTSHARE")+""
                    );
                }
                rs.close();
                ps.close();
                insurar.loadPrestations();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }

        return insurar;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(int userid){
        this.userid=userid;
        store();
    }

    public void store(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // check existence
            String sQuery = "SELECT * FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_SERVERID=? AND OC_INSURAR_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,Integer.parseInt(getUid().split("\\.")[0]));
            ps.setInt(2,Integer.parseInt(getUid().split("\\.")[1]));
            rs = ps.executeQuery();

            if(rs.next()){
                //*** UPDATE ***
                sQuery = "UPDATE OC_INSURARS SET"+
                         "  OC_INSURAR_UPDATETIME=?,"+
                         "  OC_INSURAR_UPDATEUID=?,"+
                         "  OC_INSURAR_VERSION=OC_INSURAR_VERSION+1,"+
                         "  OC_INSURAR_NAME=?,"+
                         "  OC_INSURAR_LANGUAGE=?,"+
                         "  OC_INSURAR_CONTACT=?,"+
                         "  OC_INSURAR_OFFICIAL_NAME=?,"+
                         "  OC_INSURAR_CONTACTPERSON=?,"+
                         "  OC_INSURAR_TYPE=?,"+
                         "  OC_INSURAR_DEFAULTINSURARINVOICEMODEL=?,"+
                         "  OC_INSURAR_DEFAULTPATIENTINVOICEMODEL=?,"+
                         "  OC_INSURAR_ALLOWEDREDUCTIONS=?," +
                         "  OC_INSURAR_MODIFIERS=?"+
                         " WHERE OC_INSURAR_SERVERID=? AND OC_INSURAR_OBJECTID=?";
                rs.close();
                ps.close();
                ps = oc_conn.prepareStatement(sQuery);
                ps.setDate(1, new java.sql.Date(new Date().getTime())); // now
                ps.setString(2,userid+"");
                ps.setString(3,getName());
                ps.setString(4,getLanguage());
                ps.setString(5,getContact());
                ps.setString(6,getOfficialName());
                ps.setString(7,getContactPerson());
                ps.setString(8,getType());
                ps.setString(9,getDefaultInsurarInvoiceModel());
                ps.setString(10,getDefaultPatientInvoiceModel());
                ps.setString(11,getAllowedReductions());
                ps.setString(12, getModifiers());
                ps.setInt(13,Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(14,Integer.parseInt(getUid().split("\\.")[1]));
                ps.execute();
                ps.close();

                // delete and re-insert categories
                sQuery = "DELETE FROM OC_INSURANCECATEGORIES"+
                         " WHERE OC_INSURANCECATEGORY_INSURARUID=?";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,getUid());
                ps.execute();
                ps.close();

                InsuranceCategory insuranceCategory;
                for(int n=0;n<insuranceCategories.size();n++){
                    insuranceCategory = (InsuranceCategory)insuranceCategories.elementAt(n);

                    sQuery = "INSERT INTO OC_INSURANCECATEGORIES("+
                             "  OC_INSURANCECATEGORY_CREATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATEUID,"+
                             "  OC_INSURANCECATEGORY_VERSION,"+
                             "  OC_INSURANCECATEGORY_SERVERID,"+
                             "  OC_INSURANCECATEGORY_OBJECTID,"+
                             "  OC_INSURANCECATEGORY_INSURARUID,"+
                             "  OC_INSURANCECATEGORY_CATEGORY,"+
                             "  OC_INSURANCECATEGORY_LABEL,"+
                             "  OC_INSURANCECATEGORY_PATIENTSHARE)"+
                             " VALUES (?,?,?,?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sQuery);
                    ps.setDate(1, new java.sql.Date(new Date().getTime()));
                    ps.setDate(2, new java.sql.Date(new Date().getTime()));
                    ps.setString(3,userid+"");
                    ps.setInt(4,1);
                    ps.setInt(5,Integer.parseInt(getUid().split("\\.")[0]));
                    ps.setInt(6,Integer.parseInt(insuranceCategory.getUid().split("\\.")[0])>-1?Integer.parseInt(insuranceCategory.getUid().split("\\.")[1]):MedwanQuery.getInstance().getOpenclinicCounter("InsuranceCategoryId"));
                    ps.setString(7,getUid());
                    ps.setString(8,insuranceCategory.getCategory());
                    ps.setString(9,insuranceCategory.getLabel());
                    ps.setInt(10,Integer.parseInt(insuranceCategory.getPatientShare()));
                    ps.execute();
                    ps.close();
                }
            }
            else{
                //*** INSERT ***
                int objectid = MedwanQuery.getInstance().getOpenclinicCounter("InsurarId");
                rs.close();
                ps.close();

                sQuery = "INSERT INTO OC_INSURARS("+
                         "  OC_INSURAR_CREATETIME,"+
                         "  OC_INSURAR_UPDATETIME,"+
                         "  OC_INSURAR_UPDATEUID,"+
                         "  OC_INSURAR_VERSION,"+
                         "  OC_INSURAR_SERVERID,"+
                         "  OC_INSURAR_OBJECTID,"+
                         "  OC_INSURAR_NAME,"+
                         "  OC_INSURAR_LANGUAGE,"+
                         "  OC_INSURAR_CONTACT,"+
                         "  OC_INSURAR_OFFICIAL_NAME,"+
                         "  OC_INSURAR_TYPE," +
                         "  OC_INSURAR_DEFAULTINSURARINVOICEMODEL," +
                         "  OC_INSURAR_DEFAULTPATIENTINVOICEMODEL,"+
                         "  OC_INSURAR_ALLOWEDREDUCTIONS,"+
                         "  OC_INSURAR_CONTACTPERSON," +
                         "  OC_INSURAR_MODIFIERS)"+
                         " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setDate(1, new java.sql.Date(new Date().getTime()));
                ps.setDate(2, new java.sql.Date(new Date().getTime()));
                ps.setString(3,userid+"");
                ps.setInt(4,1);
                ps.setInt(5,Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(6,objectid);
                ps.setString(7,getName());
                ps.setString(8,getLanguage());
                ps.setString(9,getContact());
                ps.setString(10,getOfficialName());
                ps.setString(11,getType());
                ps.setString(12,getDefaultInsurarInvoiceModel());
                ps.setString(13,getDefaultPatientInvoiceModel());
                ps.setString(14,getAllowedReductions());
                ps.setString(15,getContactPerson());
                ps.setString(16, getModifiers());
                ps.execute();
                ps.close();

                setUid(Integer.parseInt(getUid().split("\\.")[0])+"."+objectid);

                // add categories
                InsuranceCategory insuranceCategory;
                for(int n=0;n<insuranceCategories.size();n++){
                    insuranceCategory = (InsuranceCategory)insuranceCategories.elementAt(n);

                    sQuery = "INSERT INTO OC_INSURANCECATEGORIES("+
                             "  OC_INSURANCECATEGORY_CREATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATEUID,"+
                             "  OC_INSURANCECATEGORY_VERSION,"+
                             "  OC_INSURANCECATEGORY_SERVERID,"+
                             "  OC_INSURANCECATEGORY_OBJECTID,"+
                             "  OC_INSURANCECATEGORY_INSURARUID,"+
                             "  OC_INSURANCECATEGORY_CATEGORY,"+
                             "  OC_INSURANCECATEGORY_LABEL,"+
                             "  OC_INSURANCECATEGORY_PATIENTSHARE)"+
                             " VALUES (?,?,?,?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sQuery);
                    ps.setDate(1, new java.sql.Date(new Date().getTime()));
                    ps.setDate(2, new java.sql.Date(new Date().getTime()));
                    ps.setString(3,userid+"");
                    ps.setInt(4,1);
                    ps.setInt(5,Integer.parseInt(getUid().split("\\.")[0]));
                    ps.setInt(6,Integer.parseInt(insuranceCategory.getUid().split("\\.")[0])>-1?Integer.parseInt(insuranceCategory.getUid().split("\\.")[1]):MedwanQuery.getInstance().getOpenclinicCounter("InsuranceCategoryId"));
                    ps.setString(7,getUid());
                    ps.setString(8,insuranceCategory.getCategory());
                    ps.setString(9,insuranceCategory.getLabel());
                    ps.setInt(10,Integer.parseInt(insuranceCategory.getPatientShare()));
                    ps.execute();
                    ps.close();
                }
            }
            //Update all insurances that have been linked to this insurer (categoryletter)
            sQuery = "UPDATE OC_INSURANCES set OC_INSURANCE_TYPE=? where OC_INSURANCE_INSURARUID=? and OC_INSURANCE_TYPE<>?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1, this.getType());
            ps.setString(2, this.getUid());
            ps.setString(3, this.getType());
            ps.execute();
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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String uid){
        delete(Integer.parseInt(uid.split("\\.")[0]),Integer.parseInt(uid.split("\\.")[1]));
    }

    public static void delete(int serverid, int objectid){
        // delete insurar
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "DELETE FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_SERVERID=?"+
                            "  AND OC_INSURAR_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
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
            catch(SQLException e){
                e.printStackTrace();
            }
        }

        // delete its categories
        deleteCategories(serverid,objectid);
        deletePrestations(serverid,objectid);
    }

    //--- DELETE CATEGORIES -----------------------------------------------------------------------
    public static void deleteCategories(int serverid, int objectid){
        deleteCategories(serverid+"."+objectid);
    }

    public static void deletePrestations(int serverid, int objectid){
        deletePrestations(serverid+"."+objectid);
    }

    public static void deleteCategories(String insurarUid){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "DELETE FROM OC_INSURANCECATEGORIES"+
                            " WHERE OC_INSURANCECATEGORY_INSURARUID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,insurarUid);
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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }

    //--- DELETE CATEGORY -------------------------------------------------------------------------
    // first copy category to history table
    public static void deleteCategory(int serverid, int objectid, String sCategoryLetter){
        deleteCategory(serverid+"."+objectid,sCategoryLetter);
    }

    public static void deleteCategory(String sInsurarUid, String sCategoryLetter){
        PreparedStatement ps = null;
        String sQuery;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // copy to history
            sQuery = "INSERT INTO OC_INSURANCECATEGORIES_HISTORY"+
                     " SELECT * FROM OC_INSURANCECATEGORIES"+
                     "  WHERE OC_INSURANCECATEGORY_INSURARUID=?"+
                     "   AND OC_INSURANCECATEGORY_CATEGORY=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,sInsurarUid);
            ps.setString(2,sCategoryLetter);
            ps.executeUpdate();
            ps.close();

            // delete
            sQuery = "DELETE FROM OC_INSURANCECATEGORIES"+
                     " WHERE OC_INSURANCECATEGORY_INSURARUID=?"+
                     "  AND OC_INSURANCECATEGORY_CATEGORY=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,sInsurarUid);
            ps.setString(2,sCategoryLetter);
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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }

}
