package be.openclinic.finance;

import be.openclinic.common.ObjectReference;
import be.openclinic.pharmacy.ProductStock;
import be.openclinic.common.IObjectReference;
import be.openclinic.common.OC_Object;
import be.openclinic.adt.Encounter;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Vector;

import net.admin.Service;

public class Prestation extends OC_Object{
    private String description;
    private String code;
    private double price;
    private double supplement;
    private ObjectReference referenceObject; // Product, Examination
    private String automationCode;
    private String type; // (product/service)
    private String categories;
    private String invoicegroup;
    private int mfpPercentage;
    private int renewalInterval;
    private String coveragePlan;
    private String coveragePlanCategory;
    private int variablePrice;
    private int inactive;
    private String performerUid;
    private String prestationClass;
    private String serviceUid;
    private String nomenclature;
    private String dhis2code;
    private String keywords;
    public  HashSet includedPrestations;
    
    public String getKeywords() {
		return keywords;
	}

	public void setKeywords(String keywords) {
		this.keywords = keywords;
	}

	public String getDhis2code() {
		return dhis2code;
	}

    public void loadIncludedPrestations(){
		includedPrestations = new HashSet();
		//Load all prestationuids linked to this insurer
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "SELECT a.* FROM OC_FORFAITPRESTATIONS a,OC_PRESTATIONS b"+
                            " WHERE OC_FORFAITPRESTATION_FORFAITUID=? and"
                            + " OC_PRESTATION_OBJECTID=replace(OC_FORFAITPRESTATION_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"
                            		+ " ORDER by OC_PRESTATION_DESCRIPTION";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,getUid());
            rs = ps.executeQuery();
            while(rs.next()){
            	includedPrestations.add(rs.getString("OC_FORFAITPRESTATION_PRESTATIONUID"));
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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }
    
    public HashSet getIncludedPrestations(){
   		loadIncludedPrestations();
    	return includedPrestations;
    }
    
    public boolean isCoveredInEncounter(String encounterUid){
        boolean bIsCovered=false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "select count(*) total from oc_debets d,oc_forfaitprestations p where "
            		+ " p.oc_forfaitprestation_forfaituid=d.oc_debet_prestationuid and"
            		+ " d.oc_debet_encounteruid=? and"
            		+ " p.oc_forfaitprestation_prestationuid=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,encounterUid);
            ps.setString(2,getUid());
            rs = ps.executeQuery();
            if(rs.next()){
            	bIsCovered=rs.getInt("total")>0;
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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
        return bIsCovered;
    }

	public void setDhis2code(String dhis2code) {
		this.dhis2code = dhis2code;
	}

	public String getNomenclature(){
		return nomenclature;
	}

	public void setNomenclature(String nomenclature){
		this.nomenclature = nomenclature;
	}

	private String modifiers; // 0=anesthesiaPercentage, 1=mfpadmissionpercentage, 2=flag1, 3=getAnesthesiaSupplementPercentag, 4=codedhis2, 5=costcenter
    
    public String getServiceUid(){
		return serviceUid;
	}

	public void setServiceUid(String serviceUid){
		this.serviceUid = serviceUid;
	}

	public String getModifiers(){
		return modifiers;
	}

	public void setModifiers(String modifiers){
		this.modifiers = modifiers;
	}
	
	public double getAnesthesiaPercentage(){
		double pct = 0;
		if(getModifiers()!=null){
			try{
				pct =Double.parseDouble(getModifiers().split(";")[0]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return pct;
	}
	
	public void setAnesthesiaPercentage(double pct){
		setModifier(0,pct+"");
	}
	
	public double getMfpAdmissionPercentage(){
		double pct=0;
		if(getModifiers()!=null){
			try{
				pct = Double.parseDouble(getModifiers().split(";")[1]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return pct;
	}
	
	public void setMfpAdmissionPercentage(double pct){
		setModifier(1,pct+"");
	}
	
	public String getFlag1(){
		String flag = "";
		if(getModifiers()!=null){
			try{
				flag = getModifiers().split(";")[2];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return flag;
	}
	
	public void setFlag1(String flag){
		setModifier(2,flag);
	}
	
	public double getAnesthesiaSupplementPercentage(){
		double pct = 0;
		if(getModifiers()!=null){
			try{
				pct =Double.parseDouble(getModifiers().split(";")[3]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return pct;
	}
	
	public void setAnesthesiaSupplementPercentage(double pct){
		setModifier(3,pct+"");
	}
	
	public double getHideFromDefaultList(){
		int n = 0;
		if(getModifiers()!=null){
			try{
				n =Integer.parseInt(getModifiers().split(";")[4]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}
	
	public void setHideFromDefaultList(int n){
		setModifier(4,n+"");
	}

	public String getProductionOrder(){
		String order="";
		if(getModifiers()!=null){
			try{
				order = getModifiers().split(";")[5];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return order;
	}
	
	public void setProductionOrder(String order){
		setModifier(5,order);
	}

	public double getProductionOrderPaymentLevel(){
		int n = 0;
		if(getModifiers()!=null){
			try{
				n =Integer.parseInt(getModifiers().split(";")[6]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}
	
	public void setProductionOrderPaymentLevel(int n){
		setModifier(6,n+"");
	}
	
	public int getProductionOrderPrescription(){
		int n = 0;
		if(getModifiers()!=null){
			try{
				n =Integer.parseInt(getModifiers().split(";")[7]);
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return n;
	}
	
	public void setProductionOrderPrescription(int n){
		setModifier(7,n+"");
	}
	
	public String getProductionOrderProductName(){
		String name="";
		if(getProductionOrder().length()>0){
			ProductStock productStock = ProductStock.get(getProductionOrder());
			if(productStock!=null && productStock.getProduct()!=null){
				name=productStock.getProduct().getName();
			}
		}
		return name;
	}

	public void setReservedForServiceType(String s){
		setModifier(8,s+"");
	}
	
	public String getReservedForServiceType(){
		String s = "";
		if(getModifiers()!=null){
			try{
				s =getModifiers().split(";")[8];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return s;
	}
	
	public void setCostCenter(String s){
		setModifier(9,s+"");
	}
	
	public String getCostCenter(){
		String s = "";
		if(getModifiers()!=null){
			try{
				s =getModifiers().split(";")[9];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return s;
	}
	
	public void setTimeslot(String s){
		setModifier(10,s+"");
	}
	
	public String getTimeslot(){
		String s = "";
		if(getModifiers()!=null){
			try{
				s =getModifiers().split(";")[10];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return s;
	}
	
	public void setATCCode(String s){
		setModifier(11,s+"");
	}
	
	public String getATCCode(){
		String s = "";
		if(getModifiers()!=null){
			try{
				s =getModifiers().split(";")[11];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return s;
	}
	
	public void setProductionOrderRawMaterials(String s){
		setModifier(12,s+"");
	}
	
	public String getProductionOrderRawMaterials(){
		String s = "";
		if(getModifiers()!=null){
			try{
				s =getModifiers().split(";")[12];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return s;
	}
	
	public boolean isVisibleFor(Insurar insurar){
		if(insurar==null){
			return true;
		}
		return insurar.isPrestationVisible(this.getUid()) && (insurar.getUseLimitedPrestationsList()==1 || getHideFromDefaultList()==0);
	}
	
	public boolean isVisibleFor(Insurar insurar,Service service){
		if(insurar==null){
			return true;
		}
		if(getReservedForServiceType().trim().length()>0 && (service==null || !getReservedForServiceType().equalsIgnoreCase(ScreenHelper.checkString(service.code3)))){
			return false;
		}
		return insurar.isPrestationVisible(this.getUid()) && (insurar.getUseLimitedPrestationsList()==1 || getHideFromDefaultList()==0);
	}
	
	//--- SET MODIFIER ----------------------------------------------------------------------------
	public void setModifier(int index, String value){
		if(getModifiers()==null){
			setModifiers("");
		}
		
		String[] m = getModifiers().split(";");
		if(m.length <= index){
			setModifiers(getModifiers()+"; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;".substring(0,(index+1-m.length)*2));
			m = getModifiers().split(";");
		}
		m[index] = value;
		modifiers = "";
		for(int n=0; n<m.length; n++){
			modifiers+= m[n]+";";
		}
	}

	public String getPrestationClass(){
		return prestationClass;
	}

	public void setPrestationClass(String prestationClass){
		this.prestationClass = prestationClass;
	}

	public String getPerformerUid(){
		return performerUid;
	}

	public void setPerformerUid(String performerUid){
		this.performerUid = performerUid;
	}

	public int getInactive(){
		return inactive;
	}

	public void setInactive(int inactive){
		this.inactive = inactive;
	}

	public int getVariablePrice(){
		return variablePrice;
	}

	public void setVariablePrice(int variablePrice){
		this.variablePrice = variablePrice;
	}

	public String getCompanyMinWorkers(){
    	String s="";
    	if(getReferenceObject()!=null && getReferenceObject().getObjectType()!=null && getReferenceObject().getObjectUid().split(";").length>0){
    		s=getReferenceObject().getObjectUid().split(";")[0];
    	}
    	return s;
    }

    public String getCompanyMaxWorkers(){
    	String s="";
    	if(getReferenceObject()!=null && getReferenceObject().getObjectType()!=null && getReferenceObject().getObjectUid().split(";").length>1){
    		s=getReferenceObject().getObjectUid().split(";")[1];
    	}
    	return s;
    }

    public String getCompanyRiskLevel(){
    	String s="";
    	if(getReferenceObject()!=null && getReferenceObject().getObjectType()!=null && getReferenceObject().getObjectUid().split(";").length>2){
    		s=getReferenceObject().getObjectUid().split(";")[2];
    	}
    	return s;
    }

    public String getCoveragePlanCategory(){
		return coveragePlanCategory;
	}

	public void setCoveragePlanCategory(String coveragePlanCategory){
		this.coveragePlanCategory = coveragePlanCategory;
	}

	public String getInvoicegroup(){
		return invoicegroup;
	}

	public void setInvoicegroup(String invoicegroup){
		this.invoicegroup = invoicegroup;
	}

	public String getCoveragePlan(){
		return coveragePlan;
	}

	public void setCoveragePlan(String coveragePlan){
		this.coveragePlan = coveragePlan;
	}

	public int getRenewalInterval(){
		return renewalInterval;
	}

	public void setRenewalInterval(int renewalInterval){
		this.renewalInterval = renewalInterval;
	}

	public int getMfpPercentage(){
		return mfpPercentage;
	}

	public void setMfpPercentage(int mfpPercentage){
		this.mfpPercentage = mfpPercentage;
	}

	//--- GETTERS & SETTERS -----------------------------------------------------------------------
    public String getType(){
        return type;
    }
    
    public String getInvoiceGroup(){
    	return invoicegroup;
    }

    public void setInvoiceGroup(String invoiceGroup){
    	this.invoicegroup=invoiceGroup;
    }
    
    public void setType(String type){
        this.type = type;
    }

    public String getAutomationCode(){
        return automationCode;
    }

    public void setAutomationCode(String automationCode){
        this.automationCode = automationCode;
    }

    public String getCode(){
        return code;
    }

    public void setCode(String code){
        this.code = code;
    }

    public String getDescription(){
        return description;
    }

    public void setDescription(String description){
        this.description = description;
    }

    public double getPrice(){
        return price;
    }

    public String getPriceFormatted(String category){
    	String s = (getSupplement()!=0?"<b>(+"+getSupplement()+")</b>":"");
    	if (price==getPrice(category)){
            return "<b>"+ScreenHelper.getPriceFormat(price)+"</b> "+s;
        }
        else{
            return ScreenHelper.getPriceFormat(price)+s;
        }
    }

    public void setPrice(double price){
        this.price = price;
    }

    //--- SAVE INSURANCE TARIFF (1) ---------------------------------------------------------------
    public static void saveInsuranceTariff(String prestationUid, String insurarUid, String insuranceCategory, double price){
    	if(prestationUid!=null){
    		Prestation prestation = Prestation.get(prestationUid);
    		if(prestation!=null){
    			saveInsuranceTariff(prestationUid,insurarUid,insuranceCategory,price,prestation.getVersion());
    		}
    	}
    }
 
    //--- SAVE INSURANCE TARIFF (2) ---------------------------------------------------------------
    public static void saveInsuranceTariff(String prestationUid, String insurarUid, String insuranceCategory, double price, int version){
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sSql = "delete from OC_TARIFFS where OC_TARIFF_PRESTATIONUID=? and "+
    	                  " OC_TARIFF_INSURARUID=? and "+
    				      " OC_TARIFF_INSURANCECATEGORY=? and "+
    				      " OC_TARIFF_VERSION=?";
			PreparedStatement ps = oc_conn.prepareStatement(sSql);
			ps.setString(1,prestationUid);
			ps.setString(2,insurarUid);
			ps.setString(3,insuranceCategory);
			ps.setInt(4,version);
			ps.executeUpdate();
			ps.close();
			
			if(price>=0){
	    		sSql = "insert into OC_TARIFFS(OC_TARIFF_PRESTATIONUID,OC_TARIFF_INSURARUID,OC_TARIFF_INSURANCECATEGORY,"+
			            " OC_TARIFF_PRICE,OC_TARIFF_VERSION) values (?,?,?,?,?)";
				ps = oc_conn.prepareStatement(sSql);
				ps.setString(1,prestationUid);
				ps.setString(2,insurarUid);
				ps.setString(3,insuranceCategory);
				ps.setDouble(4,price);
				ps.setInt(5, version);
				ps.executeUpdate();
				ps.close();
			}
		}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	
    	try{
			oc_conn.close();
		}
    	catch(SQLException e){
			e.printStackTrace();
		}
    }
    
    public static void saveInsuranceRule(String prestationUid, String insurarUid, double quantity,double period){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sSql = "delete from OC_INSURANCERULES where OC_INSURANCERULE_PRESTATIONUID=? and " +
    				" OC_INSURANCERULE_INSURARUID=?";
			PreparedStatement ps = oc_conn.prepareStatement(sSql);
			ps.setString(1, prestationUid);
			ps.setString(2, insurarUid);
			ps.executeUpdate();
			ps.close();
			if(quantity>=0){
	    		sSql = "insert into OC_INSURANCERULES(OC_INSURANCERULE_PRESTATIONUID,OC_INSURANCERULE_INSURARUID,OC_INSURANCERULE_QUANTITY,OC_INSURANCERULE_PERIOD) values (?,?,?,?)";
				ps = oc_conn.prepareStatement(sSql);
				ps.setString(1, prestationUid);
				ps.setString(2, insurarUid);
				ps.setDouble(3, quantity);
				ps.setDouble(4, period);
				ps.executeUpdate();
				ps.close();
			}
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
    
    public static InsuranceRule getInsuranceRule(String prestationUid, String insurarUid){
    	InsuranceRule rule = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sSql = "select * from OC_INSURANCERULES where OC_INSURANCERULE_PRESTATIONUID=? and " +
    				" OC_INSURANCERULE_INSURARUID=?";
			PreparedStatement ps = oc_conn.prepareStatement(sSql);
			ps.setString(1, prestationUid);
			ps.setString(2, insurarUid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				rule = new InsuranceRule(insurarUid, prestationUid, rs.getDouble("OC_INSURANCERULE_QUANTITY"), rs.getDouble("OC_INSURANCERULE_PERIOD"));
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
    	return rule;
    }
    
    public static boolean checkMaximumReached(String patientUid,InsuranceRule rule, double quantity){
    	boolean bMaximumReached=false;
    	if(rule!=null){
	    	long time = (long)rule.getDays()*24*3600*1000;
	    	java.util.Date start = new java.util.Date(new java.util.Date().getTime()-time);
	        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	    	try{
	    		String sSql = "select SUM(OC_DEBET_QUANTITY) total from OC_DEBETS, OC_ENCOUNTERS, OC_INSURANCES where "
	    				+ " OC_ENCOUNTER_PATIENTUID=? AND"
	    				+ " OC_DEBET_ENCOUNTERUID='"+MedwanQuery.getInstance().getConfigInt("serverId")+".'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar","OC_ENCOUNTER_OBJECTID")+" AND"
	    				+ " OC_INSURANCE_OBJECTID=replace(OC_DEBET_INSURANCEUID,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')"+" AND"
	    				+ " OC_INSURANCE_INSURARUID=? AND"
	    				+ " OC_DEBET_PRESTATIONUID=? AND"
	    				+ " OC_DEBET_CREDITED<>1 AND"
	    				+ " OC_DEBET_DATE>=?"
	    				;
				PreparedStatement ps = oc_conn.prepareStatement(sSql);
				ps.setString(1, patientUid);
				ps.setString(2, rule.getInsurarUid());
				ps.setString(3, rule.getPrestationUid());
				ps.setDate(4,new java.sql.Date(start.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int total = rs.getInt("total");
					bMaximumReached=total+quantity>rule.quantity;
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
    	}
   	   	return bMaximumReached;
    }
    
    public static Vector getPrestationsByClass(String prestationClass){
        Vector prestations = new Vector();
        
    	Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sSql = "SELECT * FROM OC_PRESTATIONS WHERE OC_PRESTATION_CLASS=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sSql);
    		ps.setString(1,prestationClass);
    		ResultSet rs = ps.executeQuery();
    		while(rs.next()){
    			Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID")+"."+ rs.getString("OC_PRESTATION_OBJECTID"));
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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                prestation.setNomenclature(rs.getString("OC_PRESTATION_NOMENCLATURE"));
                prestation.setDhis2code(rs.getString("OC_PRESTATION_DHIS2CODE"));
                prestation.setKeywords(rs.getString("OC_PRESTATION_KEYWORDS"));
                prestations.add(prestation);
    		}
    		rs.close();
    		ps.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	
    	try{
			oc_conn.close();
		}
    	catch (SQLException e){
			e.printStackTrace();
		}
    	
    	return prestations;
    }
    
    //--- GET INSURANCE TARIFF --------------------------------------------------------------------
    public double getInsuranceTariff(String insurarUid, String insuranceCategory){
    	double p = -1;
    	
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
    	try {
    		String sSql = "select * from OC_TARIFFS where OC_TARIFF_PRESTATIONUID=? and "+
    		              " OC_TARIFF_INSURARUID=? and "+
    				      " OC_TARIFF_INSURANCECATEGORY=? and "+
    			          " OC_TARIFF_VERSION=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sSql);
    		ps.setString(1,this.getUid());
    		ps.setString(2,insurarUid);
    		ps.setString(3,insuranceCategory);
    		ps.setInt(4,this.getVersion());
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			p = rs.getDouble("OC_TARIFF_PRICE");
    		}
    		else{
    			// Let's try it without the insurance category
    			rs.close();
    			ps.close();
    			
        		sSql = "select * from OC_TARIFFS where OC_TARIFF_PRESTATIONUID=? and "+
				       " OC_TARIFF_INSURARUID=? and "+
				       " (OC_TARIFF_INSURANCECATEGORY is null or OC_TARIFF_INSURANCECATEGORY='') and "+
	                   " OC_TARIFF_VERSION = ?";
				ps = oc_conn.prepareStatement(sSql);
				ps.setString(1,this.getUid());
				ps.setString(2,insurarUid);
	    		ps.setInt(3,this.getVersion());
				rs = ps.executeQuery();
				if(rs.next()){
					p = rs.getDouble("OC_TARIFF_PRICE");
				}
    		}
    		rs.close();
    		ps.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	
    	try{
			oc_conn.close();
		}
    	catch(SQLException e){
			e.printStackTrace();
		}
    	
    	return p;
    }

    //--- GET PRICE -------------------------------------------------------------------------------
    public double getPrice(String category){
        double price = getPrice();
        
        if(categories!=null && categories.length()>0){
	        String[] cats = categories.split(";");
	        for(int n=0; n<cats.length; n++){
	            if(cats[n].indexOf("=")>-1 && cats[n].split("=")[0].equalsIgnoreCase(category)){
	                try{
	                    price = Double.parseDouble(cats[n].split("=")[1]);
	                    if(MedwanQuery.getInstance().getConfigInt("allowZeroCategoryPricesForHealthServices",0)==1 || price > 0){
	                        return price;
	                    }
	                }
	                catch(Exception e){
	                    // empty
	                }
	            }
	        }
        }
        
        return getPrice();
    }

    public String getCategories(){
        return categories;
    }

    //--- GET PATIENT PRICE -----------------------------------------------------------------------
    public double getPatientPrice(Insurance insurance, String category){
    	double dPatientAmount=getPrice("C")+getSupplement(),dInsurarAmount=0;
        double dPrice = getPrice(category);
        double dInsuranceMaxPrice = getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
        
        String sShare = ScreenHelper.checkString(getPatientShare(insurance)+"");
        if(sShare.length() > 0){
            dPatientAmount = dPrice * Double.parseDouble(sShare) / 100;
            dInsurarAmount = dPrice - dPatientAmount;
            if(dInsuranceMaxPrice>-1){
            	dInsurarAmount = dInsuranceMaxPrice;
           		dPatientAmount = dPrice - dInsurarAmount;
            }
            dPatientAmount+= getSupplement();
        }
        
        return dPatientAmount;
    }

    //--- GET INSURAR PRICE -----------------------------------------------------------------------
    public double getInsurarPrice(Insurance insurance, String category){
    	double dPatientAmount = getPrice("C")+getSupplement(), dInsurarAmount = 0;
        double dPrice = getPrice(category);
        double dInsuranceMaxPrice = getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
        
        String sShare = ScreenHelper.checkString(getPatientShare(insurance)+"");
        if(sShare.length() > 0){
            dPatientAmount = dPrice * Double.parseDouble(sShare) / 100;
            dInsurarAmount = dPrice - dPatientAmount;
            if(dInsuranceMaxPrice>-1){
            	dInsurarAmount=dInsuranceMaxPrice;
           		dPatientAmount=dPrice - dInsurarAmount;
            }
            
            dPatientAmount+=getSupplement();
        }
        
        return dInsurarAmount;
    }

    //--- GET PATIENT SHARE (1) -------------------------------------------------------------------
    public int getPatientShare(Insurance insurance){
        int patientShare = 100;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // Zoeken of er geen specifieke regeling bestaat voor dit artikel
            String sQuery = "select * from OC_PRESTATION_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONUID=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,insurance.getInsurarUid());
            ps.setString(2,this.getUid());
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                patientShare=rs.getInt("OC_PR_PATIENTSHARE");
            }
            else{
                rs.close();
                ps.close();
                
                // Zoeken of er geen specifieke regeling bestaat voor de familie van het artikel
                sQuery = "select * from OC_PRESTATIONFAMILY_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONTYPE=?";
                ps=oc_conn.prepareStatement(sQuery);
                ps.setString(1,insurance.getInsurarUid());
                ps.setString(2,this.getType());
                rs = ps.executeQuery();
                if(rs.next()){
                    patientShare = rs.getInt("OC_PR_PATIENTSHARE");
                }
                else {
                    patientShare = Integer.parseInt(insurance.getInsuranceCategory().getPatientShare());
                }
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return patientShare;
    }

    //--- GET PATIENT SHARE (2) -------------------------------------------------------------------
    public int getPatientShare(Insurar insurar, String category){
        int patientShare = 100;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // Zoek of er geen specifieke regeling bestaat voor dit artikel
            String sQuery="select * from OC_PRESTATION_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONUID=?";
            PreparedStatement ps=oc_conn.prepareStatement(sQuery);
            ps.setString(1,insurar.getUid());
            ps.setString(2,this.getUid());
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                patientShare = rs.getInt("OC_PR_PATIENTSHARE");
            }
            else{
                rs.close();
                ps.close();
                
                // Zoek of er geen specifieke regeling bestaat voor de familie van het artikel
                sQuery = "select * from OC_PRESTATIONFAMILY_REIMBURSEMENTS where OC_PR_INSURARUID=? and OC_PR_PRESTATIONTYPE=?";
                ps=oc_conn.prepareStatement(sQuery);
                ps.setString(1,insurar.getUid());
                ps.setString(2,this.getType());
                rs = ps.executeQuery();
                if(rs.next()){
                    patientShare = rs.getInt("OC_PR_PATIENTSHARE");
                }
                else{
                    patientShare = Integer.parseInt(insurar.getInsuranceCategory(category).getPatientShare());
                }
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return patientShare;
    }

    //--- GET CATEGORIES FORMATTED (1) ------------------------------------------------------------
    public String getCategoriesFormatted(){
        String categoriesFormatted="";
        String[] cats = categories.split(";");
        for(int n=0; n<cats.length; n++){
            if(cats[n].indexOf("=")>-1){
                if(n>0){
                    categoriesFormatted+=", ";
                }
                categoriesFormatted+=cats[n].split("=")[0].toUpperCase()+": "+cats[n].split("=")[1];
            }
        }
        return categoriesFormatted;
    }

    //--- GET CATEGORIES FORMATTED (2) ------------------------------------------------------------
    public String getCategoriesFormatted(String category){
        String categoriesFormatted = "";
        
	    if(ScreenHelper.checkString(categories).length() > 0){
            try{
	            String[] cats = ScreenHelper.checkString(categories).split(";");
	            for(int n=0; n<cats.length; n++){
	                if(cats[n].indexOf("=")>-1){
	                    if(n > 0){
	                        categoriesFormatted+=", ";
	                    }
	                    if(cats[n].split("=")[0].equalsIgnoreCase(category)){
	                        categoriesFormatted+= "<b>";
	                    }
	                    categoriesFormatted+= cats[n].split("=")[0].toUpperCase()+": "+ScreenHelper.getPriceFormat(Double.parseDouble(cats[n].split("=")[1]));
	                    if(cats[n].split("=")[0].equalsIgnoreCase(category)){
	                        categoriesFormatted+= "</b>";
	                    }
	                }
	            }
            }
            catch(Exception e){
            	// empty
            }
        }
        
        return categoriesFormatted;
    }

    public void setCategories(String categories){
        this.categories = categories;
    }

    public ObjectReference getReferenceObject(){
        return referenceObject;
    }

    public void setReferenceObject(ObjectReference referenceObject){
        this.referenceObject = referenceObject;
    }

    //--- GET DEBET TRANSACTION -------------------------------------------------------------------
    public DebetTransaction getDebetTransaction(Date date, IObjectReference balanceOwner, Encounter encounter,
    		                                    IObjectReference referenceObject, ObjectReference supplier){
        Balance balance = Balance.getActiveBalance(balanceOwner.getObjectUid());
        if(balance==null){
            balance = new Balance();
            balance.setBalance(0);
            balance.setDate(new Date());
            balance.setOwner(balanceOwner.getObjectReference());
            balance.setMinimumBalance(MedwanQuery.getInstance().getConfigInt("defaultMinimumBalance",0));
            balance.setMaximumBalance(MedwanQuery.getInstance().getConfigInt("defaultMaximumBalance",999999999));
            balance.store();
            
            balance = Balance.getActiveBalance(balanceOwner.getObjectUid());
        }
        
        DebetTransaction debetTransaction = new DebetTransaction();
        debetTransaction.setDate(date);
        debetTransaction.setAmount(this.price);
        debetTransaction.setBalance(balance);
        debetTransaction.setDescription(this.getDescription());
        debetTransaction.setEncounter(encounter);
        debetTransaction.setPrestation(this);
        debetTransaction.setReferenceObject(referenceObject.getObjectReference());
        debetTransaction.setSupplier(supplier);
        debetTransaction.store();
        
        return debetTransaction;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Prestation get(String uid){
        Prestation prestation = (Prestation)MedwanQuery.getInstance().getObjectCache().getObject("prestation",uid);
        if(prestation!=null){
            return prestation;
        }
        
        prestation = new Prestation();

        if(uid!=null && uid.length() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String[] ids = uid.split("\\.");

                if(ids.length==2){
                    String sSelect = "SELECT * FROM OC_PRESTATIONS"+
                                     " WHERE OC_PRESTATION_SERVERID = ?"+
                                     "  AND OC_PRESTATION_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        prestation.setUid(rs.getString("OC_PRESTATION_SERVERID")+"."+ rs.getString("OC_PRESTATION_OBJECTID"));
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
                        prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                        prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                        prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                        prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                        prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                        prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                        prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                        prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                        prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                        prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                        prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                        prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                        prestation.setNomenclature(rs.getString("OC_PRESTATION_NOMENCLATURE"));
                        prestation.setDhis2code(rs.getString("OC_PRESTATION_DHIS2CODE"));
                        prestation.setKeywords(rs.getString("OC_PRESTATION_KEYWORDS"));
                    }
                }
            }
            catch(Exception e){
                Debug.println("OpenClinic => Prestation.java => get => "+e.getMessage());
                e.printStackTrace();
            }
            finally{
                try{
                    if(ps!=null) ps.close();
                    if(rs!=null) rs.close();
                    oc_conn.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
        
        MedwanQuery.getInstance().getObjectCache().putObject("prestation",prestation);
        return prestation;
    }

    //--- GET (active on Date) --------------------------------------------------------------------
    public static Prestation get(String uid, java.util.Date date){
    	if(date==null){
    		return Prestation.get(uid);
    	}
    	
        Prestation prestation = Prestation.get(uid);
        if(prestation!=null && prestation.getUpdateDateTime()!=null && !prestation.getUpdateDateTime().after(date)){
            return prestation;
        }
        
        prestation = new Prestation();

        if(uid!=null && uid.length() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String[] ids = uid.split("\\.");

                if(ids.length==2){
                    String sSelect = "SELECT * FROM OC_PRESTATIONS_HISTORY"+
                                     " WHERE OC_PRESTATION_SERVERID = ?"+
                                     "  AND OC_PRESTATION_OBJECTID = ?"+
                                     "  AND OC_PRESTATION_UPDATETIME<=?"+
                                     " ORDER BY OC_PRESTATION_UPDATETIME DESC, OC_PRESTATION_VERSION DESC";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.setTimestamp(3, new java.sql.Timestamp(date.getTime()));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        prestation.setUid(rs.getString("OC_PRESTATION_SERVERID")+"."+ rs.getString("OC_PRESTATION_OBJECTID"));
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
                        prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                        prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                        prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                        prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                        prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                        prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                        prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                        prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                        prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                        prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                        prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                        prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                        prestation.setNomenclature(rs.getString("OC_PRESTATION_NOMENCLATURE"));
                        prestation.setDhis2code(rs.getString("OC_PRESTATION_DHIS2CODE"));
                        prestation.setKeywords(rs.getString("OC_PRESTATION_KEYWORDS"));
                    }
                    else{
                    	prestation = Prestation.get(uid);
                    }
                }
                else{
                	prestation = Prestation.get(uid);
                }
            }
            catch(Exception e){
                Debug.println("OpenClinic => Prestation.java => get active on date => "+e.getMessage());
                e.printStackTrace();
            }
            finally{
                try{
                    if(ps!=null) ps.close();
                    if(rs!=null) rs.close();
                    oc_conn.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
        
        return prestation;
    }

    //--- GET PRESTATION CODE ---------------------------------------------------------------------
    public static String getPrestationCode(String uid){
        return getPrestationCode(Integer.parseInt(uid.split("\\.")[0]),
        		                 Integer.parseInt(uid.split("\\.")[1]));
    }

    public static String getPrestationCode(int serverId, int objectId){
        String sPrestationCode = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_PRESTATION_CODE FROM OC_PRESTATIONS"+
                             " WHERE OC_PRESTATION_SERVERID = ?"+
                             "  AND OC_PRESTATION_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,serverId);
            ps.setInt(2,objectId);
            rs = ps.executeQuery();

            if(rs.next()){
                sPrestationCode = rs.getString("OC_PRESTATION_CODE");
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return sPrestationCode;
    }

    //--- GET ALL ---------------------------------------------------------------------------------
    public static Hashtable getAll(){
    	Hashtable allPrestations = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
            String sSelect = "SELECT * FROM OC_PRESTATIONS";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID")+"."+ rs.getString("OC_PRESTATION_OBJECTID"));
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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                prestation.setNomenclature(rs.getString("OC_PRESTATION_NOMENCLATURE"));
                prestation.setDhis2code(rs.getString("OC_PRESTATION_DHIS2CODE"));
                prestation.setKeywords(rs.getString("OC_PRESTATION_KEYWORDS"));
                allPrestations.put(prestation.getCode(),prestation);
            }
        }
        catch(Exception e){
            Debug.println("OpenClinic => Prestation.java => get => "+e.getMessage());
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    	
    	return allPrestations;
    }
    
    //--- GET BY CODE -----------------------------------------------------------------------------
    public static Prestation getByCode(String code){
        Prestation prestation = new Prestation();

        if(code!=null && code.length() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String sSelect = "SELECT * FROM OC_PRESTATIONS"+
                                 " WHERE OC_PRESTATION_CODE = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,code);
                rs = ps.executeQuery();

                if(rs.next()){
                    prestation.setUid(rs.getString("OC_PRESTATION_SERVERID")+"."+ rs.getString("OC_PRESTATION_OBJECTID"));
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
                    prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                    prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                    prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                    prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                    prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                    prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                    prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                    prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                    prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                    prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                    prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                    prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                    prestation.setNomenclature(rs.getString("OC_PRESTATION_NOMENCLATURE"));
                    prestation.setDhis2code(rs.getString("OC_PRESTATION_DHIS2CODE"));
                    prestation.setKeywords(rs.getString("OC_PRESTATION_KEYWORDS"));
                }
            }
            catch(Exception e){
                Debug.println("OpenClinic => Prestation.java => get => "+e.getMessage());
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null) rs.close();
                    if(ps!=null) ps.close();
                    oc_conn.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }

        return prestation;
    }

    //--- SET CATEGORY PRICE ----------------------------------------------------------------------
    public void setCategoryPrice(String category,String price){
        String[] prices = getCategories().split(";");
        boolean updated = false;
        
        for(int n=0; n<prices.length; n++){
            if(category.equalsIgnoreCase(prices[n].split("=")[0])){
                prices[n] = category+"="+price;
                updated = true;
            }
        }
        
        if(!updated){
            setCategories(getCategories()+category+"="+price+";");
        }
        else{
            String s = "";
            for(int n=0; n<prices.length; n++){
                s+= prices[n]+";";
            }
            setCategories(s);
        }
    }

    //--- SEARCH PRESTATIONS ----------------------------------------------------------------------
    public static Vector searchPrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice){
    	return searchPrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,"");
	}
    
    public static Vector searchActivePrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice){
    	return searchActivePrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,"");
    }
    
    public static Vector searchPrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice, String sPrestationRefUid){
    	return searchPrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,sPrestationRefUid,
    			                 "OC_PRESTATION_DESCRIPTION,OC_PRESTATION_CODE");
    }
    
    public static Vector searchActivePrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
        String sPrestationPrice, String sPrestationRefUid){
    	return searchActivePrestations(sPrestationCode,sPrestationDescr,sPrestationType,sPrestationPrice,sPrestationRefUid,
    			                       "OC_PRESTATION_DESCRIPTION,OC_PRESTATION_CODE");
    }
    
    //--- GET DEFAULT PERFORMER -------------------------------------------------------------------
    public static String getDefaultPerformer(Prestation prestation, Service service){
    	String sPerformerUid = "";
    	if(prestation.getPerformerUid()!=null && prestation.getPerformerUid().length()>0){
    		sPerformerUid = prestation.getPerformerUid();
    	}
    	
    	return sPerformerUid;
    }
    
    //--- SEARCH PRESTATIONS ----------------------------------------------------------------------
    public static Vector searchPrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
                                           String sPrestationPrice, String sPrestationRefUid, String sPrestationSort){
        Vector prestations = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_PRESTATIONS";
            if(sPrestationCode.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " (OC_PRESTATION_CODE like ? OR UPPER(OC_PRESTATION_CODE) LIKE ?) AND";
            }
            if(sPrestationDescr.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " (OC_PRESTATION_DESCRIPTION LIKE ? OR UPPER(OC_PRESTATION_DESCRIPTION) LIKE ?) AND";
            }
            if(sPrestationType.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PRESTATION_TYPE = ? AND";
            }
            if(sPrestationPrice.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PRESTATION_PRICE = ? AND";
            }
            if(sPrestationRefUid.length() > 0){
                sSql+= " OC_PRESTATION_REFUID LIKE ? AND";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY "+sPrestationSort;
            ps = oc_conn.prepareStatement(sSql);
            
            // set question marks
            int qmIdx = 1;
            if(sPrestationCode.length() > 0) ps.setString(qmIdx++,sPrestationCode+"%");
            if(sPrestationCode.length() > 0) ps.setString(qmIdx++,sPrestationCode.toUpperCase()+"%");
            if(sPrestationDescr.length() > 0){
            	ps.setString(qmIdx++,"%"+sPrestationDescr+"%");
            }
            if(sPrestationDescr.length() > 0) ps.setString(qmIdx++,"%"+sPrestationDescr.toUpperCase()+"%");
            if(sPrestationType.length() > 0) ps.setString(qmIdx++,sPrestationType);
            if(sPrestationPrice.length() > 0){
                float fPrice = 0;
                try{
                	fPrice = Float.parseFloat(sPrestationPrice.replaceAll(",","."));
                }
                catch(Exception e2){
                	e2.printStackTrace();
                }
                
            	ps.setFloat(qmIdx++,fPrice);
            }
            if(sPrestationRefUid.length() > 0) ps.setString(qmIdx,sPrestationRefUid+"%");

            // execute query
            rs = ps.executeQuery();

            Prestation prestation;
            while(rs.next()){
                prestation = new Prestation();

                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID")+"."+ rs.getString("OC_PRESTATION_OBJECTID"));
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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                prestation.setNomenclature(rs.getString("OC_PRESTATION_NOMENCLATURE"));
                prestation.setDhis2code(rs.getString("OC_PRESTATION_DHIS2CODE"));
                prestation.setKeywords(rs.getString("OC_PRESTATION_KEYWORDS"));

                prestations.add(prestation);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    //--- SEARCH ACTIVE PRESTATIONS ---------------------------------------------------------------
    public static Vector searchActivePrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
            String sPrestationPrice, String sPrestationRefUid, String sPrestationSort){
    	return searchActivePrestations(sPrestationCode, sPrestationDescr,  sPrestationType,
                 sPrestationPrice,  sPrestationRefUid,  sPrestationSort, "");
    }
    public static Vector searchActivePrestations(String sPrestationCode, String sPrestationDescr, String sPrestationType,
                                                 String sPrestationPrice, String sPrestationRefUid, String sPrestationSort, String sPrestationKeywords){
        Vector prestations = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_PRESTATIONS WHERE (OC_PRESTATION_INACTIVE IS NULL OR OC_PRESTATION_INACTIVE<>1) AND";
            if(sPrestationCode.length() > 0){
                sSql+= " (OC_PRESTATION_CODE like ? OR UPPER(OC_PRESTATION_CODE) LIKE ?) AND";
            }
            if(sPrestationDescr.length() > 0){
                sSql+= " (OC_PRESTATION_DESCRIPTION LIKE ? OR UPPER(OC_PRESTATION_DESCRIPTION) LIKE ? ) AND";
            }
            if(sPrestationType.length() > 0){
                sSql+= " OC_PRESTATION_TYPE = ? AND";
            }
            if(sPrestationPrice.length() > 0){
                sSql+= " OC_PRESTATION_PRICE = ? AND";
            }
            if(sPrestationRefUid.length() > 0){
                sSql+= " OC_PRESTATION_REFUID LIKE ? AND";
            }

            if(sPrestationKeywords.length() > 0){
                sSql+= " OC_PRESTATION_KEYWORDS = ? AND";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY "+sPrestationSort;
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            
            // set question marks
            int qmIdx = 1;
            if(sPrestationCode.length() > 0) ps.setString(qmIdx++,sPrestationCode+"%");
            if(sPrestationCode.length() > 0) ps.setString(qmIdx++,sPrestationCode.toUpperCase()+"%");
            if(sPrestationDescr.length() > 0){
            	ps.setString(qmIdx++,"%"+sPrestationDescr+"%");
            }
            if(sPrestationDescr.length() > 0) {
            	ps.setString(qmIdx++,"%"+sPrestationDescr.toUpperCase()+"%");
            }
            if(sPrestationType.length() > 0) ps.setString(qmIdx++,sPrestationType);
            if(sPrestationPrice.length() > 0){
                float fPrice = 0;
                try{
                	fPrice = Float.parseFloat(sPrestationPrice.replaceAll(",","."));
                }
                catch(Exception e2){
                	e2.printStackTrace();
                }
                
            	ps.setFloat(qmIdx++,fPrice);
            }
            if(sPrestationRefUid.length() > 0) ps.setString(qmIdx++,sPrestationRefUid+"%");
            if(sPrestationKeywords.length() > 0) ps.setString(qmIdx,sPrestationKeywords);

            // execute query
            rs = ps.executeQuery();
            Prestation prestation;
            while(rs.next()){
                prestation = new Prestation();

                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID")+"."+ rs.getString("OC_PRESTATION_OBJECTID"));
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
                prestation.setInvoiceGroup(rs.getString("OC_PRESTATION_INVOICEGROUP"));
                prestation.setMfpPercentage(rs.getInt("OC_PRESTATION_MFPPERCENTAGE"));
                prestation.setSupplement(rs.getDouble("OC_PRESTATION_SUPPLEMENT"));
                prestation.setRenewalInterval(rs.getInt("OC_PRESTATION_RENEWALINTERVAL"));
                prestation.setCoveragePlan(rs.getString("OC_PRESTATION_COVERAGEPLAN"));
                prestation.setCoveragePlanCategory(rs.getString("OC_PRESTATION_COVERAGEPLANCATEGORY"));
                prestation.setVariablePrice(rs.getInt("OC_PRESTATION_VARIABLEPRICE"));
                prestation.setInactive(rs.getInt("OC_PRESTATION_INACTIVE"));
                prestation.setPerformerUid(rs.getString("OC_PRESTATION_PERFORMERUID"));
                prestation.setPrestationClass(rs.getString("OC_PRESTATION_CLASS"));
                prestation.setModifiers(rs.getString("OC_PRESTATION_MODIFIERS"));
                prestation.setServiceUid(rs.getString("OC_PRESTATION_SERVICEUID"));
                prestation.setNomenclature(rs.getString("OC_PRESTATION_NOMENCLATURE"));
                prestation.setDhis2code(rs.getString("OC_PRESTATION_DHIS2CODE"));
                prestation.setKeywords(rs.getString("OC_PRESTATION_KEYWORDS"));

                prestations.add(prestation);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        int iVersion;
        String[] ids;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");

                if(ids.length==2){
                	//Eerst copi�ren we het bestaande record naar de history
                	sSql = "insert into OC_PRESTATIONS_HISTORY(OC_PRESTATION_CODE,OC_PRESTATION_DESCRIPTION,OC_PRESTATION_PRICE,OC_PRESTATION_REFTYPE,"+
                			"OC_PRESTATION_REFUID,OC_PRESTATION_UPDATETIME,OC_PRESTATION_UPDATEUID,OC_PRESTATION_VERSION,OC_PRESTATION_TYPE,OC_PRESTATION_CATEGORIES,"+
                			"OC_PRESTATION_MFPPERCENTAGE,OC_PRESTATION_INVOICEGROUP,OC_PRESTATION_RENEWALINTERVAL,OC_PRESTATION_COVERAGEPLAN,OC_PRESTATION_COVERAGEPLANCATEGORY,"+
                			"OC_PRESTATION_VARIABLEPRICE,OC_PRESTATION_INACTIVE,OC_PRESTATION_PERFORMERUID,OC_PRESTATION_SUPPLEMENT,OC_PRESTATION_CLASS,"+
                			"OC_PRESTATION_MODIFIERS,OC_PRESTATION_SERVICEUID,OC_PRESTATION_SERVERID,OC_PRESTATION_OBJECTID,OC_PRESTATION_CREATETIME,OC_PRESTATION_NOMENCLATURE,"+
                			"OC_PRESTATION_DHIS2CODE,OC_PRESTATION_KEYWORDS) "+
                			""+
                			"select OC_PRESTATION_CODE,OC_PRESTATION_DESCRIPTION,OC_PRESTATION_PRICE,OC_PRESTATION_REFTYPE,"+
                			"OC_PRESTATION_REFUID,OC_PRESTATION_UPDATETIME,OC_PRESTATION_UPDATEUID,OC_PRESTATION_VERSION,OC_PRESTATION_TYPE,OC_PRESTATION_CATEGORIES,"+
                			"OC_PRESTATION_MFPPERCENTAGE,OC_PRESTATION_INVOICEGROUP,OC_PRESTATION_RENEWALINTERVAL,OC_PRESTATION_COVERAGEPLAN,OC_PRESTATION_COVERAGEPLANCATEGORY,"+
                			"OC_PRESTATION_VARIABLEPRICE,OC_PRESTATION_INACTIVE,OC_PRESTATION_PERFORMERUID,OC_PRESTATION_SUPPLEMENT,OC_PRESTATION_CLASS,"+
                			"OC_PRESTATION_MODIFIERS,OC_PRESTATION_SERVICEUID,OC_PRESTATION_SERVERID,OC_PRESTATION_OBJECTID,OC_PRESTATION_CREATETIME,OC_PRESTATION_NOMENCLATURE,"+
                			"OC_PRESTATION_DHIS2CODE,OC_PRESTATION_KEYWORDS from OC_PRESTATIONS where "+
                			"OC_PRESTATION_SERVERID=? and OC_PRESTATION_OBJECTID=?";
                	ps = oc_conn.prepareStatement(sSql);
                	ps.setInt(1,Integer.parseInt(ids[0]));
                	ps.setInt(2,Integer.parseInt(ids[1]));
                	ps.execute();
                	ps.close();
                	
                	//Vervolgens copi�ren we de actieve tarieven naar de nieuwe versie
                	sSql="insert into OC_TARIFFS(OC_TARIFF_INSURARUID,OC_TARIFF_PRESTATIONUID,OC_TARIFF_INSURANCECATEGORY,OC_TARIFF_PRICE,OC_TARIFF_VERSION) "+
                			" select OC_TARIFF_INSURARUID,OC_TARIFF_PRESTATIONUID,OC_TARIFF_INSURANCECATEGORY,OC_TARIFF_PRICE,OC_TARIFF_VERSION+1 from OC_TARIFFS where"+
                			" OC_TARIFF_PRESTATIONUID=? and"+
                			" OC_TARIFF_VERSION=?";
                	ps = oc_conn.prepareStatement(sSql);
                	ps.setString(1,ids[0]+"."+ids[1]);
                	ps.setInt(2, this.getVersion());
                	ps.execute();
                	ps.close();
                	
                	//Vervolgens deleten we het bestaande record uit OC_Prestations
                	sSql = "delete from OC_PRESTATIONS where OC_PRESTATION_SERVERID=? and OC_PRESTATION_OBJECTID=?";
                	ps = oc_conn.prepareStatement(sSql);
                	ps.setInt(1,Integer.parseInt(ids[0]));
                	ps.setInt(2,Integer.parseInt(ids[1]));
                	ps.execute();
                	ps.close();
                	
                	this.setVersion(this.getVersion()+1);
                }
                else{
                    throw new Exception("EXISTING PRESTATION WITHOUT VALID UID !");
                }
            }
            else{
                ids = new String[]{
                          MedwanQuery.getInstance().getConfigString("serverId"),
                          MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESTATIONS")+""
                      };
                this.setVersion(1);
            }

            //*** INSERT ***
            sSql = "INSERT INTO OC_PRESTATIONS ("+
                   "  OC_PRESTATION_SERVERID,"+
                   "  OC_PRESTATION_OBJECTID,"+
                   "  OC_PRESTATION_CODE,"+
                   "  OC_PRESTATION_DESCRIPTION,"+
                   "  OC_PRESTATION_PRICE,"+
                   "  OC_PRESTATION_REFTYPE,"+
                   "  OC_PRESTATION_REFUID,"+
                   "  OC_PRESTATION_CREATETIME,"+
                   "  OC_PRESTATION_UPDATETIME,"+
                   "  OC_PRESTATION_UPDATEUID,"+
                   "  OC_PRESTATION_VERSION,"+
                   "  OC_PRESTATION_TYPE,"+
                   "  OC_PRESTATION_CATEGORIES,"+
                   "  OC_PRESTATION_MFPPERCENTAGE,"+
                   "  OC_PRESTATION_INVOICEGROUP,"+
                   "  OC_PRESTATION_RENEWALINTERVAL,"+
                   "  OC_PRESTATION_COVERAGEPLAN,"+
                   "  OC_PRESTATION_COVERAGEPLANCATEGORY,"+
                   "  OC_PRESTATION_VARIABLEPRICE,"+
                   "  OC_PRESTATION_INACTIVE,"+
                   "  OC_PRESTATION_PERFORMERUID,"+
                   "  OC_PRESTATION_SUPPLEMENT,"+
                   "  OC_PRESTATION_CLASS,"+
                   "  OC_PRESTATION_MODIFIERS,"+
                   "  OC_PRESTATION_SERVICEUID,"+
                   "  OC_PRESTATION_NOMENCLATURE,"+
                   "  OC_PRESTATION_DHIS2CODE,"+
                   "  OC_PRESTATION_KEYWORDS"+
                   ")"+
                   " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(ids[0]));
            ps.setInt(2,Integer.parseInt(ids[1]));
            ps.setString(3,this.getCode());
            ps.setString(4,this.getDescription());
            ps.setDouble(5,this.getPrice());
            ps.setString(6,this.getReferenceObject().getObjectType());
            ps.setString(7,this.getReferenceObject().getObjectUid());
            ps.setTimestamp(8,new Timestamp(new java.util.Date().getTime())); // now
            ps.setTimestamp(9,this.getUpdateDateTime()==null?new Timestamp(new java.util.Date().getTime()):new Timestamp(this.getUpdateDateTime().getTime())); // now
            ps.setString(10,this.getUpdateUser());
            ps.setInt(11,this.getVersion()); 
            ps.setString(12,this.getType());
            ps.setString(13,this.getCategories());
            ps.setInt(14,this.getMfpPercentage());
            ps.setString(15,this.getInvoiceGroup());
            ps.setInt(16, this.getRenewalInterval());
            ps.setString(17, this.getCoveragePlan());
            ps.setString(18, this.getCoveragePlanCategory());
            ps.setInt(19,this.getVariablePrice());
            ps.setInt(20, this.getInactive());
            ps.setString(21, this.getPerformerUid());
            ps.setDouble(22,this.getSupplement());
            ps.setString(23,this.getPrestationClass());
            ps.setString(24, this.getModifiers());
            ps.setString(25, this.getServiceUid());
            ps.setString(26, this.getNomenclature());
            ps.setString(27, this.getDhis2code());
            ps.setString(28, this.getKeywords());
            ps.executeUpdate();
            ps.close();
            
            setUid(ids[0]+"."+ids[1]);
            
            //If MfpPercentage provided, create tariff
            if(getMfpPercentage()>=0){
            	Insurar insurar = Insurar.get(MedwanQuery.getInstance().getConfigString("MFP","-1"));
            	if(insurar!=null && insurar.getUid()!=null){
            		double price = getPrice(insurar.getType());
            		
                	Vector cats = insurar.getInsuraceCategories();
                	for(int n=0; n<cats.size(); n++){
                		InsuranceCategory cat = (InsuranceCategory)cats.elementAt(n);
                		saveInsuranceTariff(getUid(), insurar.getUid(), cat.getCategory(), price*getMfpPercentage()/100,this.getVersion());
                	}
            	}
            }
            
            if(getMfpAdmissionPercentage()>=0){
            	Insurar insurar = Insurar.get(MedwanQuery.getInstance().getConfigString("MFP","-1"));
            	if(insurar!=null && insurar.getUid()!=null){
            		double price = getPrice(insurar.getType());
            		
                	Vector cats = insurar.getInsuraceCategories();
                	for(int n=0; n<cats.size(); n++){
                		InsuranceCategory cat = (InsuranceCategory)cats.elementAt(n);
                		saveInsuranceTariff(getUid(),insurar.getUid(),"*H",price*getMfpAdmissionPercentage()/100,this.getVersion());
                	}
            	}
            }
        }
        catch(Exception e){
            Debug.println("OpenClinic => Prestation.java => store => "+e.getMessage());
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        MedwanQuery.getInstance().getObjectCache().putObject("prestation",this);
    }

    //--- GET PRESTATIONS BY CODE -----------------------------------------------------------------
    public static Vector getPrestationsByCode(String prestationCode){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector prestations = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_PRESTATIONS"+
                          " WHERE "+MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(OC_PRESTATION_CODE,?)=1";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,prestationCode);
            rs = ps.executeQuery();

            while(rs.next()){
                prestations.add(Prestation.get(rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID")));
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }


    //--- GET PRESTATIONS BY CODE -----------------------------------------------------------------
    public static Vector getPrestationsByReferenceUid(String prestationCode){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector prestations = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_PRESTATIONS"+
                          " WHERE "+MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(OC_PRESTATION_REFUID,?)>1";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,prestationCode);
            rs = ps.executeQuery();

            while(rs.next()){
                prestations.add(Prestation.get(rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID")));
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    //--- GET PRESTATIONS BY CODE -----------------------------------------------------------------
    public static Vector getPrestationsByNomenclature(String prestationCode){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector prestations = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_PRESTATIONS"+
                          " WHERE OC_PRESTATION_NOMENCLATURE=?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,prestationCode);
            rs = ps.executeQuery();

            while(rs.next()){
                prestations.add(Prestation.get(rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID")));
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    //--- GET PRESTATIONS BY CODE -----------------------------------------------------------------
    public static Vector getPrestationsByCodeAlias(String prestationCode){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector prestations = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_PRESTATIONS"+
                          " WHERE OC_PRESTATION_REFUID=?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,prestationCode);
            rs = ps.executeQuery();

            while(rs.next()){
                prestations.add(Prestation.get(rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID")));
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return prestations;
    }

    //--- REGISTER PRESTATION AS DEBET TRANSACTION ------------------------------------------------
    public void registerPrestationAsDebetTransaction(String balanceuid, Date date, String encounterid, ObjectReference supplier, 
    		                                         ObjectReference ref, String userid, String patientuid){
        Balance balance;
        if(balanceuid==null){
            balance = Balance.getActiveBalance(patientuid);
        }
        else{
            balance = Balance.get(balanceuid);
        }
        
        if(balance==null){
            balance = new Balance();
            balance.setBalance(0);
            balance.setDate(new Date());
            balance.setOwner(new ObjectReference("Person",patientuid));
            balance.setMinimumBalance(MedwanQuery.getInstance().getConfigInt("defaultMinimumBalance",0));
            balance.setMaximumBalance(MedwanQuery.getInstance().getConfigInt("defaultMaximumBalance",999999999));
            balance.store();
        }
        
        DebetTransaction debetTransaction = new DebetTransaction();
        debetTransaction.setDate(date);
        debetTransaction.setAmount(this.getPrice(Insurance.getDefaultInsuranceForPatient(patientuid).getInsurar().getType()));
        debetTransaction.setBalance(balance);
        debetTransaction.setDescription(this.getDescription());
        if(encounterid==null){
            Encounter encounter = Encounter.getActiveEncounter(patientuid);
            if(encounter!=null){
                encounterid=encounter.getUid();
            }
        }
        debetTransaction.setEncounterUID(encounterid);
        debetTransaction.setPrestation(this);
        debetTransaction.setReferenceObject(ref);
        debetTransaction.setSupplier(supplier);
        debetTransaction.setUpdateUser(userid);
        debetTransaction.setCreateDateTime(new Date());
        debetTransaction.setUpdateDateTime(new Date());
        debetTransaction.storeUnique();
    }

    //--- REGISTER PRESTATIONS AS DEBET TRANSACTION -----------------------------------------------
    public static void registerPrestationsAsDebetTransactions(String prestationCode, String balanceuid,
    		                                                  Date date, String encounterid, ObjectReference supplier,
    		                                                  ObjectReference ref, String userid, String patientuid){
        Debug.println("Looking for "+prestationCode);
        Vector prestations = getPrestationsByReferenceUid(prestationCode);
        Prestation prestation;
        for(int n=0; n<prestations.size(); n++){
            prestation = (Prestation)prestations.elementAt(n);
            prestation.registerPrestationAsDebetTransaction(balanceuid,date,encounterid,supplier,ref,userid,patientuid);
        }
    }

    //--- GET ALL PRESTATIONS ---------------------------------------------------------------------
    public static Vector getAllPrestations(){
        return searchPrestations("","","","","");
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String uid){
        delete(Integer.parseInt(uid.split("\\.")[0]),Integer.parseInt(uid.split("\\.")[1]));
    }

    public static void delete(int serverId, int objectId){
        PreparedStatement ps = null;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_PRESTATIONS"+
                          " WHERE OC_PRESTATION_SERVERID = ?"+
                          "  AND OC_PRESTATION_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,serverId);
            ps.setInt(2,objectId);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }
        MedwanQuery.getInstance().getObjectCache().removeObject("prestation",serverId+"."+objectId);
    }

    //--- GET POPULAR PRESTATIONS -----------------------------------------------------------------
    public static Vector getPopularPrestations(String userid){
        Vector vPrestations = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "select "+MedwanQuery.getInstance().topFunction("10")+" count(*),OC_DEBET_PRESTATIONUID"+
                          " from oc_debets"+
            		      "  WHERE OC_DEBET_UPDATEUID=?"+
                          "   group by OC_DEBET_PRESTATIONUID"+
            		      "   order by count(*) DESC"+MedwanQuery.getInstance().limitFunction("10");
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,userid);
            rs = ps.executeQuery();

            while (rs.next()){
                vPrestations.add(rs.getString("OC_DEBET_PRESTATIONUID"));
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
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vPrestations;
    }

	public double getSupplement(){
		return supplement;
	}

	public void setSupplement(double supplement){
		this.supplement = supplement;
	}
	
}