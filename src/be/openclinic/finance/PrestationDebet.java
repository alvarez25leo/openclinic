package be.openclinic.finance;
import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.openclinic.adt.Encounter;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;

import java.util.Date;
import java.util.Hashtable;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
public class PrestationDebet extends OC_Object implements Comparable {
    private Date date;
    private double amount;
    private double insurarAmount;
    private String insuranceUid;
    private Insurance insurance;
    private String prestationUid;
    private Prestation prestation;
    private String encounterUid;
    private Encounter encounter;
    private String supplierUid;
    private String patientInvoiceUid;
    private String insurarInvoiceUid;
    private String comment;
    private int credited;
    private String patientName;
    private double quantity;
    private String extraInsurarUid;
    private String extraInsurarInvoiceUid;
    private double extraInsurarAmount;
    private int renewalInterval;
    private java.util.Date renewalDate;
    private String patientid;
    private String patientgender;
    private String patientbirthdate;
    
    public String getPatientid() {
		return patientid;
	}
	public void setPatientid(String patientid) {
		this.patientid = patientid;
	}
	public String getPatientgender() {
		return patientgender;
	}
	public void setPatientgender(String patientgender) {
		this.patientgender = patientgender;
	}
	public String getPatientbirthdate() {
		return patientbirthdate;
	}
	public void setPatientbirthdate(String patientbirthdate) {
		this.patientbirthdate = patientbirthdate;
	}
	public double getTotalAmount(){
    	return getAmount()+getInsurarAmount()+getExtraInsurarAmount();
    }
    public double getExtraInsurarAmount() {
        return extraInsurarAmount;
    }
    public java.util.Date getRenewalDate() {
		return renewalDate;
	}
	public void setRenewalDate(java.util.Date renewalDate) {
		this.renewalDate = renewalDate;
	}
	public int getRenewalInterval() {
		return renewalInterval;
	}
	public void setRenewalInterval(int renewalInterval) {
		this.renewalInterval = renewalInterval;
	}
	public void setExtraInsurarAmount(double extraInsurarAmount) {
        this.extraInsurarAmount = extraInsurarAmount;
    }
    public String getExtraInsurarUid() {
        return extraInsurarUid;
    }
    public void setExtraInsurarUid(String extraInsurarUid) {
        this.extraInsurarUid = extraInsurarUid;
    }
    public String getExtraInsurarInvoiceUid() {
        return extraInsurarInvoiceUid;
    }
    public void setExtraInsurarInvoiceUid(String extraInsurarInvoiceUid) {
        this.extraInsurarInvoiceUid = extraInsurarInvoiceUid;
    }
    public double getQuantity() {
        return quantity;
    }
    public void setQuantity(double quantity) {
        this.quantity = quantity;
    }
    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o) {
        int comp;
        if (o.getClass().isInstance(this)) {
            comp = this.date.compareTo(((PrestationDebet) o).date);
        } else {
            throw new ClassCastException();
        }
        return comp;
    }
    public PrestationDebet() {
    }
    public PrestationDebet(Date date, double amount, String insuranceUid, String prestationUid, String encounterUid) {
        this.date = date;
        this.amount = amount;
        this.insuranceUid = insuranceUid;
        this.prestationUid = prestationUid;
        this.encounterUid = encounterUid;
    }
    public int getCredited() {
        return credited;
    }
    public void setCredited(int credited) {
        this.credited = credited;
        if (credited == 1) {
            this.amount = 0;
        }
    }
    public double getInsurarAmount() {
        if (credited == 1) {
            return 0;
        }
        return insurarAmount;
    }
    public void setInsurarAmount(double amount) {
        this.insurarAmount = amount;
    }
    public double getAmount() {
        if (credited == 1) {
            return 0;
        }
        return amount;
    }
    public void setAmount(double amount) {
        this.amount = amount;
    }
    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }
    public String getPatientName() {
        return patientName;
    }
    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }
    public String getInsuranceUid() {
        return insuranceUid;
    }
    public void setInsuranceUid(String insuranceUid) {
        this.insuranceUid = insuranceUid;
    }
    public String getCoveragePlanUid(){
    	String uid=null;
    	if(getInsuranceUid()!=null && getInsuranceUid().split(";").length>0){
    		uid=getInsuranceUid().split(";")[0];
    	}
    	return uid;
    }
    public Insurar getCoveragePlan(){
    	Insurar plan = null;
    	if(getCoveragePlanUid()!=null){
    		plan = Insurar.get(getCoveragePlanUid());
    	}
    	return plan;
    }
    public String getCoverageCategoryLetter(){
    	String letter="";
    	if(getInsuranceUid()!=null && getInsuranceUid().split(";").length>1){
    		letter=getInsuranceUid().split(";")[1];
    	}    	
    	return letter;
    }
    public Insurance getInsurance() {
    	if(this.insurance==null){
    		insurance=Insurance.get(this.insuranceUid);
    	}
        return insurance;
    }
    public void setInsurance(Insurance insurance) {
        this.insurance = insurance;
    }
    public String getPrestationUid() {
        return prestationUid;
    }
    public void setPrestationUid(String prestationUid) {
        this.prestationUid = prestationUid;
    }
    public Prestation getPrestation() {
        if (this.prestation == null) {
            if (ScreenHelper.checkString(this.prestationUid).length() > 0) {
                this.setPrestation(Prestation.get(this.prestationUid,this.date));
            } else {
                this.prestation = null;
            }
        }
        return prestation;
    }
    public void setPrestation(Prestation prestation) {
        this.prestation = prestation;
    }
    public String getEncounterUid() {
        return encounterUid;
    }
    public void setEncounterUid(String encounterUid) {
        this.encounterUid = encounterUid;
    }
    public Encounter getEncounter() {
        if (this.encounter == null) {
            if (ScreenHelper.checkString(this.encounterUid).length() > 0) {
                this.setEncounter(Encounter.get(this.encounterUid));
            } else {
                this.encounter = null;
            }
        }
        return encounter;
    }
    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
    }
    public String getSupplierUid() {
        return supplierUid;
    }
    public void setSupplierUid(String supplierUid) {
        this.supplierUid = supplierUid;
    }
    public String getPatientInvoiceUid() {
        return patientInvoiceUid;
    }
    public void setPatientInvoiceUid(String patientInvoiceUid) {
        this.patientInvoiceUid = patientInvoiceUid;
    }
    public String getInsurarInvoiceUid() {
        return insurarInvoiceUid;
    }
    public void setInsurarInvoiceUid(String insurarInvoiceUid) {
        this.insurarInvoiceUid = insurarInvoiceUid;
    }
    public String getComment() {
        return comment;
    }
    public void setComment(String comment) {
        this.comment = comment;
    }
    public static PrestationDebet get(String uid) {
        PrestationDebet debet = (PrestationDebet) MedwanQuery.getInstance().getObjectCache().getObject("prestationdebet", uid);
        if (debet != null && debet.getUid().equalsIgnoreCase(uid)) {
            return debet;
        }
        debet = new PrestationDebet();
        if ((uid != null) && (uid.length() > 0)) {
            String[] ids = uid.split("\\.");
            if (ids.length == 2) {
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_PRESTATIONDEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try {
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        debet.setUid(uid);
                        debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                        debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                        debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                        debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                        debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                        debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                        debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                        debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                        debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                        debet.comment = rs.getString("OC_DEBET_COMMENT");
                        debet.credited = rs.getInt("OC_DEBET_CREDITED");
                        debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                        debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                        debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                        debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                        debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                        debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                        debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                        debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                        debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                        debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                    }
                }
                catch (Exception e) {
                    Debug.println("OpenClinic => PrestationDebet.java => get => " + e.getMessage());
                    e.printStackTrace();
                }
                finally {
                    try {
                        if (rs != null) rs.close();
                        if (ps != null) ps.close();
                        oc_conn.close();
                    }
                    catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
        return debet;
    }
    
    public boolean store() {
        boolean bStored = true;
        String ids[];
        int iVersion = 1;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (this.getUid() != null && this.getUid().length() > 0) {
                ids = this.getUid().split("\\.");
                if (ids.length == 2) {
                    sSelect = "SELECT OC_DEBET_VERSION FROM OC_PRESTATIONDEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        iVersion = rs.getInt("OC_DEBET_VERSION") + 1;
                    }
                    rs.close();
                    ps.close();
                    sSelect = "INSERT INTO OC_PRESTATIONDEBETS_HISTORY(OC_DEBET_SERVERID,OC_DEBET_OBJECTID,OC_DEBET_AMOUNT,OC_DEBET_BALANCEUID,OC_DEBET_DATE,OC_DEBET_DESCRIPTION,OC_DEBET_ENCOUNTERUID,OC_DEBET_PRESTATIONUID,OC_DEBET_SUPPLIERTYPE,OC_DEBET_SUPPLIERUID,OC_DEBET_REFTYPE,OC_DEBET_REFUID,OC_DEBET_CREATETIME,OC_DEBET_UPDATETIME,OC_DEBET_UPDATEUID,OC_DEBET_VERSION,OC_DEBET_CREDITED,OC_DEBET_INSURANCEUID,OC_DEBET_PATIENTINVOICEUID,OC_DEBET_INSURARINVOICEUID,OC_DEBET_COMMENT,OC_DEBET_EXTRAINSURARUID,OC_DEBET_EXTRAINSURARINVOICEUID,OC_DEBET_EXTRAINSURARAMOUNT,OC_DEBET_RENEWALINTERVAL,OC_DEBET_RENEWALDATE) SELECT OC_DEBET_SERVERID,OC_DEBET_OBJECTID,OC_DEBET_AMOUNT,OC_DEBET_BALANCEUID,OC_DEBET_DATE,OC_DEBET_DESCRIPTION,OC_DEBET_ENCOUNTERUID,OC_DEBET_PRESTATIONUID,OC_DEBET_SUPPLIERTYPE,OC_DEBET_SUPPLIERUID,OC_DEBET_REFTYPE,OC_DEBET_REFUID,OC_DEBET_CREATETIME,OC_DEBET_UPDATETIME,OC_DEBET_UPDATEUID,OC_DEBET_VERSION,OC_DEBET_CREDITED,OC_DEBET_INSURANCEUID,OC_DEBET_PATIENTINVOICEUID,OC_DEBET_INSURARINVOICEUID,OC_DEBET_COMMENT,OC_DEBET_EXTRAINSURARUID,OC_DEBET_EXTRAINSURARINVOICEUID,OC_DEBET_EXTRAINSURARAMOUNT,OC_DEBET_RENEWALINTERVAL,OC_DEBET_RENEWALDATE FROM OC_PRESTATIONDEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                    sSelect = " DELETE FROM OC_PRESTATIONDEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                } else {
                    ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESTATIONDEBETS") + ""};
                    this.setUid(ids[0] + "." + ids[1]);
                }
            } else {
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESTATIONDEBETS") + ""};
                this.setUid(ids[0] + "." + ids[1]);
            }
            if (ids.length == 2) {
                sSelect = " INSERT INTO OC_PRESTATIONDEBETS (" +
                        " OC_DEBET_SERVERID," +
                        " OC_DEBET_OBJECTID," +
                        " OC_DEBET_DATE," +
                        " OC_DEBET_AMOUNT," +
                        " OC_DEBET_INSURANCEUID," +
                        " OC_DEBET_PRESTATIONUID," +
                        " OC_DEBET_ENCOUNTERUID," +
                        " OC_DEBET_SUPPLIERUID," +
                        " OC_DEBET_PATIENTINVOICEUID," +
                        " OC_DEBET_INSURARINVOICEUID," +
                        " OC_DEBET_COMMENT," +
                        " OC_DEBET_CREDITED," +
                        " OC_DEBET_CREATETIME," +
                        " OC_DEBET_UPDATETIME," +
                        " OC_DEBET_UPDATEUID," +
                        " OC_DEBET_VERSION," +
                        " OC_DEBET_INSURARAMOUNT," +
                        " OC_DEBET_QUANTITY," +
                        " OC_DEBET_EXTRAINSURARUID," +
                        " OC_DEBET_EXTRAINSURARINVOICEUID," +
                        " OC_DEBET_EXTRAINSURARAMOUNT," +
                        " OC_DEBET_RENEWALINTERVAL," +
                        " OC_DEBET_RENEWALDATE" +
                        ") " +
                        " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                while (!MedwanQuery.getInstance().validateNewOpenclinicCounter("OC_PRESTATIONDEBETS", "OC_DEBET_OBJECTID", ids[1])) {
                    ids[1] = MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESTATIONDEBETS") + "";
                }
                ps.setInt(1, Integer.parseInt(ids[0]));
                ps.setInt(2, Integer.parseInt(ids[1]));
                ps.setTimestamp(3, new Timestamp(this.getDate().getTime()));
                ps.setDouble(4, this.getAmount());
                if (this.insuranceUid != null) {
                    ps.setString(5, this.insuranceUid);
                } else if (this.getInsurance() != null) {
                    ps.setString(5, this.getInsurance().getUid());
                } else {
                    ps.setString(5, "");
                }
                if (this.prestationUid != null) {
                    ps.setString(6, this.prestationUid);
                } else if (this.getPrestation() != null) {
                    ps.setString(6, this.getPrestation().getUid());
                } else {
                    ps.setString(6, "");
                }
                if (this.encounterUid != null) {
                    ps.setString(7, this.encounterUid);
                } else if (this.getEncounter() != null) {
                    ps.setString(7, this.getEncounter().getUid());
                } else {
                    ps.setString(7, "");
                }
                ps.setString(8, this.getSupplierUid());
                ps.setString(9, this.getPatientInvoiceUid());
                ps.setString(10, this.getInsurarInvoiceUid());
                ps.setString(11, this.getComment());
                ps.setInt(12, this.getCredited());
                ps.setTimestamp(13, new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(14, new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(15, this.getUpdateUser());
                ps.setInt(16, iVersion);
                ps.setDouble(17, this.getInsurarAmount());
                ps.setDouble(18, this.getQuantity());
                ps.setString(19, this.getExtraInsurarUid());
                ps.setString(20, this.getExtraInsurarInvoiceUid());
                ps.setDouble(21, this.getExtraInsurarAmount());
                ps.setInt(22, this.getRenewalInterval());
                ps.setTimestamp(23, this.getRenewalDate()==null?null:new java.sql.Timestamp(this.getRenewalDate().getTime()));
                ps.executeUpdate();
                ps.close();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            bStored = false;
            Debug.println("OpenClinic => PrestationDebet.java => store => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", this);
        return bStored;
    }
    public static Vector getUnassignedPatientDebets(String sPatientId) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_ENCOUNTERS e, OC_PRESTATIONDEBETS d WHERE e.OC_ENCOUNTER_PATIENTUID = ? AND d.OC_DEBET_CREDITED=0"
                    + " AND e.oc_encounter_objectid=" + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") 
                    + " order by OC_DEBET_DATE DESC";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sPatientId);
            rs = ps.executeQuery();
            while (rs.next()) {
            	if(ScreenHelper.checkString(rs.getString("OC_DEBET_PATIENTINVOICEUID")).trim().length()==0){
            		vUnassignedDebets.add(rs.getInt("OC_DEBET_SERVERID") + "." + rs.getInt("OC_DEBET_OBJECTID"));
            	}
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getUnassignedPatientDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    public static Vector getPatientDebetsViaInvoiceUid(String sPatientId, String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT d.* FROM OC_ENCOUNTERS e, OC_PRESTATIONDEBETS d, OC_PRESTATIONS p WHERE e.OC_ENCOUNTER_PATIENTUID = '" + sPatientId
                    + "' AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND d.OC_DEBET_PATIENTINVOICEUID = '" + sInvoiceUid +
                    "' AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID" +
                    " ORDER BY OC_PRESTATION_REFTYPE,OC_DEBET_DATE";
            ps = loc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getPatientDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getPatientDebetsViaInvoiceUid(String sPatientId, String sInvoiceUid, String serviceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT d.* FROM OC_ENCOUNTERS_VIEW e, OC_PRESTATIONDEBETS d, OC_PRESTATIONS p WHERE e.OC_ENCOUNTER_PATIENTUID = '" + sPatientId
                    + "' AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND d.OC_DEBET_PATIENTINVOICEUID = '" + sInvoiceUid 
                    + " AND e.OC_ENCOUNTER_SERVICEUID = '" + serviceUid +
                    "' AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID" +
                    " ORDER BY OC_PRESTATION_REFTYPE,OC_DEBET_DATE";
            ps = loc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getPatientDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getUnassignedInsurarDebets(String sInsurarUid) {
        return getUnassignedInsurarDebets(sInsurarUid, new Date(0), new Date());
    }
    public static Hashtable getUnassignedInsurarDebetsPerService(String sInsurarUid, Date begin, Date end){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Hashtable vUnassignedDebets = new Hashtable();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	sSelect="select OC_ENCOUNTER_SERVICEUID,sum(OC_DEBET_INSURARAMOUNT) AS TOTAL from OC_PRESTATIONDEBETS a,OC_ENCOUNTERS_VIEW b"+
        			" where"+
        			" b.OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+serverid+"','') AND"+
                    " a.OC_DEBET_DATE>=? AND"+
                    " a.OC_DEBET_DATE<=? AND"+
        			" (a.OC_DEBET_INSURARINVOICEUID IS NULL OR a.OC_DEBET_INSURARINVOICEUID='') AND"+
        			" a.OC_DEBET_INSURANCEUID like '"+sInsurarUid+";%'"+
        			" GROUP BY OC_ENCOUNTER_SERVICEUID"+
        			" ORDER BY OC_ENCOUNTER_SERVICEUID";
        	ps=loc_conn.prepareStatement(sSelect);
            ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
            ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
            rs=ps.executeQuery();
            while(rs.next()){
            	vUnassignedDebets.put(rs.getString("OC_ENCOUNTER_SERVICEUID"),rs.getDouble("TOTAL"));
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    
    public static Vector getUnassignedInsurarDebets(String sInsurarUid, Date begin, Date end) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT d.*,e.*,p.*,a.* FROM OC_PRESTATIONDEBETS d, OC_ENCOUNTERS_VIEW e, adminview a, OC_PRESTATIONS p"
                    + " WHERE d.OC_DEBET_INSURANCEUID  like ?"
                    + " AND d.OC_DEBET_CREDITED=0"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND (d.OC_DEBET_INSURARINVOICEUID = ' ' or d.OC_DEBET_INSURARINVOICEUID is null)"
                    + " AND d.OC_DEBET_DATE>=?"
                    + " AND d.OC_DEBET_DATE<=?"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID"
                    + " AND " + MedwanQuery.getInstance().convert("int", "e.OC_ENCOUNTER_PATIENTUID") + "=a.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInsurarUid+";%");
            ps.setDate(2, new java.sql.Date(begin.getTime()));
            ps.setDate(3, new java.sql.Date(end.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
                encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                encounter.setServiceUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVICEUID")));
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vUnassignedDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    
    public static Vector getServicesForCoveragePlanInvoice(String invoiceUid){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	sSelect="select DISTINCT OC_ENCOUNTER_SERVICEUID from OC_PRESTATIONDEBETS a,OC_ENCOUNTERS_VIEW b"+
        			" where"+
        			" b.OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+serverid+"','') AND"+
        			" a.OC_DEBET_INSURARINVOICEUID =?";
        	ps=loc_conn.prepareStatement(sSelect);
        	ps.setString(1, invoiceUid);
            rs=ps.executeQuery();
            while(rs.next()){
            	vUnassignedDebets.add(rs.getString("OC_ENCOUNTER_SERVICEUID"));
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    
    public static Vector getUnassignedInsurarDebets(String sInsurarUid, Date begin, Date end, String serviceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT d.*,e.*,p.*,a.* FROM OC_PRESTATIONDEBETS d, OC_ENCOUNTERS_VIEW e, adminview a, OC_PRESTATIONS p"
                    + " WHERE d.OC_DEBET_INSURANCEUID  like ?"
                    + " AND d.OC_DEBET_CREDITED=0"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND (d.OC_DEBET_INSURARINVOICEUID = ' ' or d.OC_DEBET_INSURARINVOICEUID is null)"
                    + " AND d.OC_DEBET_DATE>=?"
                    + " AND d.OC_DEBET_DATE<=?"
                    + " AND e.OC_ENCOUNTER_SERVICEUID=?"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID"
                    + " AND " + MedwanQuery.getInstance().convert("int", "e.OC_ENCOUNTER_PATIENTUID") + "=a.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInsurarUid+";%");
            ps.setDate(2, new java.sql.Date(begin.getTime()));
            ps.setDate(3, new java.sql.Date(end.getTime()));
            ps.setString(4, serviceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
                encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                encounter.setServiceUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVICEUID")));
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vUnassignedDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    
    public static Vector getUnassignedExtraInsurarDebets(String sInsurarUid) {
        return getUnassignedExtraInsurarDebets(sInsurarUid, new Date(0), new Date());
    }
    public static Vector getUnassignedExtraInsurarDebets(String sInsurarUid, Date begin, Date end) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
        	sSelect = "SELECT * FROM OC_PRESTATIONDEBETS d, OC_ENCOUNTERS e, adminview a, OC_PRESTATIONS p"
                    + " WHERE d.OC_DEBET_CREDITED=0"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + " = e.oc_encounter_objectid"
                    + " AND (d.OC_DEBET_EXTRAINSURARINVOICEUID = '' or d.OC_DEBET_EXTRAINSURARINVOICEUID is null)"
                    + " AND (d.OC_DEBET_PATIENTINVOICEUID is not NULL and d.OC_DEBET_PATIENTINVOICEUID <> '')"
                    + " AND d.OC_DEBET_EXTRAINSURARUID=? AND NOT d.OC_DEBET_EXTRAINSURARUID=''"
                    + " AND d.OC_DEBET_DATE>=?"
                    + " AND d.OC_DEBET_DATE<=?"
                    + " AND " + MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=p.OC_PRESTATION_OBJECTID"
                    + " AND " + MedwanQuery.getInstance().convert("int", "e.OC_ENCOUNTER_PATIENTUID") + "=a.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInsurarUid);
            ps.setDate(2, new java.sql.Date(begin.getTime()));
            ps.setDate(3, new java.sql.Date(end.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
                encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vUnassignedDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getUnassignedInsurarDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    public static Vector getInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_PRESTATIONDEBETS WHERE OC_DEBET_INSURARINVOICEUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getFullInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c,AdminView d WHERE " +
                    " a.OC_DEBET_INSURARINVOICEUID = ? AND " +
                    MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + "=b.oc_encounter_objectid AND " +
                    MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=c.oc_prestation_objectid AND " +
                    MedwanQuery.getInstance().convert("int", "b.OC_ENCOUNTER_PATIENTUID") + "=d.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
                encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getFullExtraInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c,AdminView d WHERE " +
                    " a.OC_DEBET_EXTRAINSURARINVOICEUID = ? AND" +
                    " " + MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + "=b.oc_encounter_objectid AND" +
                    " " + MedwanQuery.getInstance().convert("int", "replace(a.OC_DEBET_PRESTATIONUID,'" + serverid + "','')") + "=c.oc_prestation_objectid AND" +
                    " " + MedwanQuery.getInstance().convert("int", "b.OC_ENCOUNTER_PATIENTUID") + "=d.personid";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));
                encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);
                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                debet.setPrestation(prestation);

                //*********************
                //add Patient name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getExtraInsurarDebetsViaInvoiceUid(String sInvoiceUid) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_PRESTATIONDEBETS WHERE OC_DEBET_EXTRAINSURARINVOICEUID = ?";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1, sInvoiceUid);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setUid(rs.getString("OC_DEBET_SERVERID") + "." + rs.getString("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.insuranceUid = rs.getString("OC_DEBET_INSURANCEUID");
                debet.prestationUid = rs.getString("OC_DEBET_PRESTATIONUID");
                debet.encounterUid = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.supplierUid = rs.getString("OC_DEBET_SUPPLIERUID");
                debet.patientInvoiceUid = rs.getString("OC_DEBET_PATIENTINVOICEUID");
                debet.insurarInvoiceUid = rs.getString("OC_DEBET_INSURARINVOICEUID");
                debet.comment = rs.getString("OC_DEBET_COMMENT");
                debet.credited = rs.getInt("OC_DEBET_CREDITED");
                debet.quantity = rs.getDouble("OC_DEBET_QUANTITY");
                debet.extraInsurarUid = rs.getString("OC_DEBET_EXTRAINSURARUID");
                debet.extraInsurarInvoiceUid = rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID");
                debet.extraInsurarAmount = rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
                debet.setRenewalDate(rs.getTimestamp("OC_DEBET_RENEWALDATE"));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getInsurarDebetsViaInvoiceUid => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                loc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    
    public static Vector getActiveContributions(String sPatientId){
    	Vector contributions = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps=null;
        ResultSet rs = null;
        try{
        	String sSelect="select c.OC_PRESTATION_SERVERID,c.OC_PRESTATION_OBJECTID from OC_PRESTATIONDEBETS a,OC_ENCOUNTERS b,OC_PRESTATIONS c where " +
        			"b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_OBJECTID=replace(a.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and " +
        			"c.OC_PRESTATION_TYPE='con.openinsurance' and " +
        			"b.OC_ENCOUNTER_PATIENTUID=? and " +
        			MedwanQuery.getInstance().dateadd("a.OC_DEBET_DATE","MONTH","c.OC_PRESTATION_RENEWALINTERVAL")+">=now()";
        	ps=oc_conn.prepareStatement(sSelect);
        	ps.setString(1, sPatientId);
        	rs=ps.executeQuery();
        	while(rs.next()){
        		contributions.add(Prestation.get(rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID")));
        	}
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    	return contributions;
    }
    
    public static Vector getPatientDebets(String sPatientId, String sDateBegin, String sDateEnd, String sAmountMin, String sAmountMax) {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "SELECT * FROM OC_ENCOUNTERS e, OC_PRESTATIONDEBETS d WHERE e.OC_ENCOUNTER_PATIENTUID = ? "
                    + " AND e.OC_ENCOUNTER_OBJECTID=replace(d.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') ";
            if (sDateBegin.length() > 0) {
                sSelect += " AND d.OC_DEBET_DATE >= ?  ";
            }
            if (sDateEnd.length() > 0) {
                sSelect += " AND d.OC_DEBET_DATE <= ?  ";
            }
            if ((sAmountMin.length() > 0) && (sAmountMax.length() > 0)) {
                sSelect += " AND d.OC_DEBET_AMOUNT >= ? AND OC_DEBET_AMOUNT <= ? ";
            } else if (sAmountMin.length() > 0) {
                sSelect += " AND d.OC_DEBET_AMOUNT >= ?  ";
            } else if (sAmountMax.length() > 0) {
                sSelect += " AND d.OC_DEBET_AMOUNT <= ?  ";
            }
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sPatientId);
            int iIndex = 2;
            if (sDateBegin.length() > 0) {
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(sDateBegin));
            }
            if (sDateEnd.length() > 0) {
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(sDateEnd));
            }
            if ((sAmountMin.length() > 0) && (sAmountMax.length() > 0)) {
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMin));
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMax));
            } else if (sAmountMin.length() > 0) {
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMin));
            } else if (sAmountMax.length() > 0) {
                ps.setDouble(iIndex++, Double.parseDouble(sAmountMax));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                vUnassignedDebets.add(rs.getInt("OC_DEBET_SERVERID") + "." + rs.getInt("OC_DEBET_OBJECTID"));
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getPatientDebets => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
    public static Vector getPatientDebetsToInvoice() {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "SELECT SUM(d.OC_DEBET_AMOUNT) as somme,count(OC_DEBET_OBJECTID) as nb,a.lastname,a.firstname,a.personid,a.gender,a.dateofbirth FROM  OC_PRESTATIONDEBETS d,OC_ENCOUNTERS b,adminview a WHERE OC_DEBET_AMOUNT >0 AND " +
                    MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_ENCOUNTERUID,'" + serverid + "','')") + "=b.OC_ENCOUNTER_OBJECTID AND " + MedwanQuery.getInstance().convert("int", "b.OC_ENCOUNTER_PATIENTUID") + "=a.personid GROUP BY a.lastname,a.firstname,a.personid,a.gender,a.dateofbirth ORDER BY a.lastname,a.firstname";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
            	if(ScreenHelper.checkString(rs.getString("OC_DEBET_PATIENTINVOICEUID")).trim().length()==0){
	                PrestationDebet debet = new PrestationDebet();
	                debet.setAmount(rs.getDouble("somme"));
	                debet.setComment(rs.getInt("nb") + "");
	                //*********************
	                //add Patient name
	                //*********************
	                debet.setPatientName(ScreenHelper.checkString(rs.getString("lastname")) + " " + ScreenHelper.checkString(rs.getString("firstname")));
	                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
	                debet.setPatientgender(rs.getString("gender"));
	                debet.setPatientid(rs.getString("personid"));
	                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
	                vDebets.add(debet);
            	}
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getPatientDebetsToInvoice => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getInsurarDebetsToInvoice() {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "SELECT SUM(d.OC_DEBET_INSURARAMOUNT) as somme,count(OC_DEBET_OBJECTID) as nb,a.OC_INSURAR_NAME FROM  OC_PRESTATIONDEBETS d,OC_INSURANCES b,OC_INSURARS a WHERE OC_DEBET_INSURARAMOUNT >0 AND (OC_DEBET_INSURARINVOICEUID IS NULL OR OC_DEBET_INSURARINVOICEUID = '0') AND " +
                    MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_INSURANCEUID,'" + serverid + "','')") + "=b.OC_INSURANCE_OBJECTID AND " + MedwanQuery.getInstance().convert("int", "replace(b.OC_INSURANCE_INSURARUID,'" + serverid + "','')") + "=a.OC_INSURAR_OBJECTID GROUP BY a.OC_INSURAR_NAME ORDER BY a.OC_INSURAR_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setAmount(rs.getDouble("somme"));
                debet.setComment(rs.getInt("nb") + "");
                //*********************
                //add Insurar name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("OC_INSURAR_NAME")));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getInsurarDebetsToInvoice => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    public static Vector getExtraInsurarDebetsToInvoice() {
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vDebets = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "SELECT SUM("+MedwanQuery.getInstance().convert("float", "d.OC_DEBET_EXTRAINSURARAMOUNT")+") as somme,count(OC_DEBET_OBJECTID) as nb,a.OC_INSURAR_NAME FROM  OC_PRESTATIONDEBETS d,OC_INSURARS a WHERE "+MedwanQuery.getInstance().convert("float", "d.OC_DEBET_EXTRAINSURARAMOUNT")+" >0 AND (d.OC_DEBET_EXTRAINSURARINVOICEUID IS NULL OR d.OC_DEBET_EXTRAINSURARINVOICEUID = '0') AND " +
                    MedwanQuery.getInstance().convert("int", "replace(d.OC_DEBET_EXTRAINSURARUID,'" + serverid + "','')") + "=a.OC_INSURAR_OBJECTID GROUP BY a.OC_INSURAR_NAME ORDER BY a.OC_INSURAR_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while (rs.next()) {
                PrestationDebet debet = new PrestationDebet();
                debet.setAmount(rs.getDouble("somme"));
                debet.setComment(rs.getInt("nb") + "");
                //*********************
                //add extrainsurance name
                //*********************
                debet.setPatientName(ScreenHelper.checkString(rs.getString("OC_INSURAR_NAME")));
                MedwanQuery.getInstance().getObjectCache().putObject("prestationdebet", debet);
                vDebets.add(debet);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => PrestationDebet.java => getExtraInsurarDebetsToInvoice => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vDebets;
    }
    
    public static int renewExpiredContributions(java.util.Date date,String userid,boolean renew){
    	int totalRenewed = 0;
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String serverid = MedwanQuery.getInstance().getConfigString("serverId") + ".";
            sSelect = "select a.* from OC_DEBETS a, OC_INSURANCES b, OC_PRESTATIONS c where " +
            		" c.OC_PRESTATION_OBJECTID=replace(a.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') AND " +
            		" b.OC_INSURANCE_OBJECTID=replace(a.OC_DEBET_INSURANCEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') AND " +
            		" (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=?) AND OC_PRESTATION_RENEWALINTERVAL > 0 AND OC_DEBET_RENEWALDATE IS NULL AND "+MedwanQuery.getInstance().dateadd("a.OC_DEBET_DATE","MONTH","c.OC_PRESTATION_RENEWALINTERVAL*a.OC_DEBET_QUANTITY")+"<?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setTimestamp(1, new java.sql.Timestamp(date.getTime()));
            ps.setTimestamp(2, new java.sql.Timestamp(date.getTime()));
            rs=ps.executeQuery();
            while(rs.next()){
            	totalRenewed++;
            	if(renew){
	            	//Insert een nieuwe debet met als startdatum de vervaldatum
	            	Debet debet = new Debet();
	            	debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
	            	debet.setComment(rs.getString("OC_DEBET_COMMENT"));
	            	debet.setCreateDateTime(new java.util.Date());
	            	debet.setCredited(0);
	            	debet.setDate(date);
	            	debet.setEncounterUid(rs.getString("OC_DEBET_ENCOUNTERUID"));
	            	debet.setExtraInsurarAmount(rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT"));
	            	debet.setExtraInsurarUid(rs.getString("OC_DEBET_EXTRAINSURARUID"));
	            	debet.setInsuranceUid(rs.getString("OC_DEBET_INSURANCEUID"));
	            	debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
	            	debet.setPrestationUid(rs.getString("OC_DEBET_PRESTATIONUID"));
	            	debet.setQuantity(rs.getDouble("OC_DEBET_QUANTITY"));
	            	debet.setRenewalInterval(rs.getInt("OC_DEBET_RENEWALINTERVAL"));
	                debet.setServiceUid(rs.getString("OC_DEBET_SERVICEUID"));
	            	debet.setUpdateDateTime(new java.util.Date());
	            	debet.setUpdateUser(userid);
	            	debet.setVersion(1);
	            	debet.store();
	            	//Update de oude debet
	            	debet = Debet.get(rs.getInt("OC_DEBET_SERVERID")+"."+rs.getInt("OC_DEBET_OBJECTID"));
	            	debet.setRenewalDate(new java.util.Date());
	            	debet.store();
            	}
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Debug.println("OpenClinic => RenewExpiredContributions => " + e.getMessage() + " = " + sSelect);
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return totalRenewed;
    }
}
