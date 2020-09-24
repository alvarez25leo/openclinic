package be.openclinic.finance;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.common.OC_Object;
import net.admin.AdminPerson;
import pe.gob.sis.Acreditacion;
import pe.gob.sis.SIS_Object;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Vector;
import java.util.Hashtable;

public class Insurance extends OC_Object {
    private String insuranceNr;
    private String insurarUid;
    private String type;
    private String member;
    private String memberImmat;
    private String memberEmployer;
    private String status;
    private Timestamp start;
    private Timestamp stop;
    private StringBuffer comment;
    private AdminPerson patient;
    private String patientUID;
    private String insuranceCategoryLetter;
    private InsuranceCategory insuranceCategory;
    private Insurar insurar,extrainsurar;
    private int patientShare;
    private String extraInsurarUid;
    private String extraInsurarUid2;
    private int defaultInsurance;
    private String membercategory;
    private String familycode;

    public String getMembercategory() {
		return membercategory;
	}

	public void setMembercategory(String membercategory) {
		this.membercategory = membercategory;
	}

	public String getFamilycode() {
		return familycode;
	}

	
	public void setFamilycode(String familycode) {
		this.familycode = familycode;
	}

	public int getDefaultInsurance(){
		return defaultInsurance;
	}

	public void setDefaultInsurance(int defaultInsurance){
		this.defaultInsurance = defaultInsurance;
	}

	public String getExtraInsurarUid(){
		String underfiveinsurance=MedwanQuery.getInstance().getConfigString("CCBRTUnderFiveComplementaryInsurance","");
		String[] underfiveexcludedclinictypes=MedwanQuery.getInstance().getConfigString("CCBRTUnderFiveExcludeServiceTypes","privateclinic").split(";");
		double age = MedwanQuery.getInstance().getAgeDecimal(Integer.parseInt(getPatientUID()));
		boolean bAcceptableClinic=true;
		Encounter e = Encounter.getActiveEncounter(getPatientUID());
		if(e!=null && e.getService()!=null){
			for(int n=0;n<underfiveexcludedclinictypes.length;n++){
				if(e.getService().code3.contentEquals(underfiveexcludedclinictypes[n])){
					bAcceptableClinic=false;
					break;
				}
			}
		}
		else{
			bAcceptableClinic=false;
		}
		if(age<=MedwanQuery.getInstance().getConfigInt("CCBRTUnderFiveAgeLimitInYears",5) && underfiveinsurance.length()>0 && bAcceptableClinic){
			return underfiveinsurance;
		}
		return extraInsurarUid;
	}

	public Insurar getExtraInsurar(){
        if(extrainsurar==null){
            if(ScreenHelper.checkString(getExtraInsurarUid()).length()>0){
            	extrainsurar = Insurar.get(getExtraInsurarUid());
            }
        }
        return extrainsurar;
	}

	//--- IS AUTHORIZED ---------------------------------------------------------------------------
    public boolean isAuthorized(){
    	boolean bAuthorized = false;
    	if(MedwanQuery.getInstance().getConfigString("InsuranceAgentAuthorizationNeededFor","").indexOf("*"+this.getInsurarUid()+"*")<=-1){
    		bAuthorized= true;
    	}
    	else if(MedwanQuery.getInstance().getConfigInt("peruEnabled",0)==1){
    		long day = 24*3600*1000;
    		SIS_Object acreditacion = Acreditacion.getLast(Integer.parseInt(this.getPatientUID()));
    		if(acreditacion!=null){
    			SimpleDateFormat deci = new SimpleDateFormat("yyyyMMddHHmmss");
    			java.util.Date dValidUntil = new java.util.Date(acreditacion.getValueTimestamp(32).getTime()+day);
    			if(dValidUntil.after(new java.util.Date())){
    				bAuthorized = true;
    			}
    			else if(MedwanQuery.getInstance().getConfigInt("enableAccreditationValidityPerEncounter",0)==1){
    				Encounter activeEncounter = Encounter.getActiveEncounter(this.getPatientUID());
    				if(activeEncounter!=null){
    					bAuthorized = dValidUntil.after(activeEncounter.getBegin());
    				}
    			}
    		}
    	}
    	else{
			Vector pointers = Pointer.getPointers("AUTH."+this.getInsurarUid()+"."+this.getPatientUID()+"."+new SimpleDateFormat("yyyyMM").format(new java.util.Date()));
	    	for(int n=0; n<pointers.size() && !bAuthorized; n++){
	    		String pointer = (String)pointers.elementAt(n);
	    		java.util.Date dValidUntil=new java.util.Date();
				try{
					dValidUntil = new SimpleDateFormat("yyyyMMddHHmmss").parse(pointer.split(";")[0]);
				} 
				catch(ParseException e){
					e.printStackTrace();
				}
				
	    		if(dValidUntil.after(new java.util.Date())){
	    			// Still valid!
	    			bAuthorized=true;
	    		}
	    		else if(MedwanQuery.getInstance().getConfigInt("enableAccreditationValidityPerEncounter",0)==1){
	    			Encounter activeEncounter = Encounter.getActiveEncounter(this.getPatientUID());
	    			if(activeEncounter!=null){
	    				bAuthorized = dValidUntil.after(activeEncounter.getBegin());
	    			}
	    		}
	    	}
    	}
    	if(bAuthorized && MedwanQuery.getInstance().getConfigString("lookupInsuranceBeneficiaries","").contains(getInsurarUid())){
			try {
	    		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	    		PreparedStatement ps;
				ps = conn.prepareStatement("select * from oc_beneficiaries where oc_beneficiary_id=?");
	    		ps.setString(1,getInsuranceNr());
	    		ResultSet rs = ps.executeQuery();
	    		bAuthorized=rs.next();
	    		rs.close();
	    		ps.close();
	    		conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    	}

    	return bAuthorized;
    }
    
	public void setExtraInsurarUid(String extraInsurarUid){
		this.extraInsurarUid = extraInsurarUid;
	}

	public String getExtraInsurarUid2(){
		return extraInsurarUid2;
	}

	public void setExtraInsurarUid2(String extraInsurarUid2){
		this.extraInsurarUid2 = extraInsurarUid2;
	}

	public String getMemberImmat(){
		return memberImmat;
	}

	public void setMemberImmat(String memberImmat){
		this.memberImmat = memberImmat;
	}

	public String getMemberEmployer(){
		return memberEmployer;
	}

	public void setMemberEmployer(String memberEmployer){
		this.memberEmployer = memberEmployer;
	}

	public String getStatus(){
		return status;
	}

	public void setStatus(String status){
		this.status = status;
	}

	public String getInsuranceCategoryLetter(){
        return insuranceCategoryLetter;
    }

    public void setInsuranceCategoryLetter(String insuranceCategoryLetter){
        this.insuranceCategoryLetter = insuranceCategoryLetter;
    }

    //--- GET ACTIVE COVERAGE PLANS ---------------------------------------------------------------
    public static Vector getActiveCoveragePlans(String sPatientId){
    	Vector coverageplans=new Vector();
    	Vector contributions = Debet.getActiveContributions(sPatientId);
    	String coverageplan;
    	
    	for(int n=0;n<contributions.size();n++){
    		Prestation contribution = (Prestation)contributions.elementAt(n);
    		if(contribution.getCoveragePlan()!=null && contribution.getCoveragePlan().length()>0){
    			Insurar insurar = Insurar.get(contribution.getCoveragePlan());
    			
    			if(insurar!=null && contribution.getCoveragePlanCategory()!=null && contribution.getCoveragePlanCategory().length()>0){
    				coverageplan = contribution.getCoveragePlan()+";"+contribution.getCoveragePlanCategory();
    				coverageplans.add(coverageplan);
    			}
    		}
    	}
    	return coverageplans;
    }
    
    //--- GET BEST ACTIVE COVERAGE PLAN -----------------------------------------------------------
    public static String getBestActiveCoveragePlan(String sPatientId){
    	Vector contributions = Debet.getActiveContributions(sPatientId);
    	double patientshare = 100;
    	String coverageplan = null;
    	
    	for(int n=0; n<contributions.size(); n++){
    		Prestation contribution = (Prestation)contributions.elementAt(n);
    		if(contribution.getCoveragePlan()!=null && contribution.getCoveragePlan().length()>0){
    			Insurar insurar = Insurar.get(contribution.getCoveragePlan());
    			
    			if(insurar!=null && contribution.getCoveragePlanCategory()!=null && contribution.getCoveragePlanCategory().length()>0){
    				InsuranceCategory category = insurar.getInsuranceCategory(contribution.getCoveragePlanCategory());
    				try{
        				if(category!=null && Double.parseDouble(category.getPatientShare())<=patientshare){
        					coverageplan = contribution.getCoveragePlan()+";"+contribution.getCoveragePlanCategory();
        				}
    				}
    				catch(Exception e){
    					// empty
    				}
    			}
    		}
    	}
    	return coverageplan;
    }
    
    //--- GET INSURAR -----------------------------------------------------------------------------
    public Insurar getInsurar(){
        if(insurar==null){
            if(ScreenHelper.checkString(insurarUid).length()>0){
                insurar = Insurar.get(insurarUid);
            }
        }
        return insurar;
    }

    //--- GET INSURANCE CATEGORY ------------------------------------------------------------------
    public InsuranceCategory getInsuranceCategory(){
        if(insuranceCategory==null){
            if(ScreenHelper.checkString(insurarUid).length()>0 && ScreenHelper.checkString(insuranceCategoryLetter).length()>0){
                insuranceCategory = InsuranceCategory.get(insurarUid,insuranceCategoryLetter);
            }
        }
        return insuranceCategory;
    }

    public String getInsuranceNr(){
        return insuranceNr;
    }

    public void setInsuranceNr(String insuranceNr){
        this.insuranceNr = insuranceNr;
    }

    public String getInsurarUid(){
        return insurarUid;
    }

    public void setInsurarUid(String insurarUid){
        this.insurarUid = insurarUid;
    }

    public String getType(){
        return type;
    }

    public void setType(String type){
        this.type = type;
    }

     public String getMember(){
        return member;
    }

    public void setMember(String member){
        this.member = member;
    }

    public Timestamp getStart(){
        return start;
    }

    public void setStart(Timestamp start){
        this.start = start;
    }

    public Timestamp getStop(){
        return stop;
    }

    public void setStop(Timestamp stop){
        this.stop = stop;
    }

    public StringBuffer getComment(){
        return comment;
    }

    public void setComment(StringBuffer comment){
        this.comment = comment;
    }

    //--- GET PATIENT -----------------------------------------------------------------------------
    public AdminPerson getPatient(){
        if(this.patient==null){
            if(this.patientUID !=null && this.patientUID.length() > 0){
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setPatient(AdminPerson.getAdminPerson(ad_conn,this.patientUID));
                try {
					ad_conn.close();
				} 
                catch (SQLException e){
					e.printStackTrace();
				}
            }
            else{
                return null;
            }
        }
        
        return patient;
    }

    public void setPatient(AdminPerson patient){
        this.patient = patient;
    }

    public String getPatientUID(){
        return patientUID;
    }

    public void setPatientUID(String patientUID){
        this.patientUID = patientUID;
    }

    public int setPatientShare(int patientShare){
        return this.patientShare = patientShare;
    }

    public int getPatientShare(){
        return this.patientShare;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Insurance get(String uid){
        Insurance insurance = new Insurance();
        PreparedStatement ps = null;
        ResultSet rs = null;

        if(uid != null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = "SELECT * FROM OC_INSURANCES"+
                                     " WHERE OC_INSURANCE_SERVERID = ? AND OC_INSURANCE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));
                    rs = ps.executeQuery();
                    
                    if(rs.next()){
                        insurance.setUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID")));

                        insurance.setInsuranceNr(ScreenHelper.checkString(rs.getString("OC_INSURANCE_NR")));
                        insurance.setInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURARUID")));
                        insurance.setType(ScreenHelper.checkString(rs.getString("OC_INSURANCE_TYPE")));
                        insurance.setMember(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER")));
                        insurance.setMemberImmat(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_IMMAT")));
                        insurance.setMemberEmployer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_EMPLOYER")));
                        insurance.setStatus(ScreenHelper.checkString(rs.getString("OC_INSURANCE_STATUS")));
                        insurance.setStart(rs.getTimestamp("OC_INSURANCE_START"));
                        if(rs.getTimestamp("OC_INSURANCE_STOP")!=null){
                            insurance.setStop(rs.getTimestamp("OC_INSURANCE_STOP"));
                        }
                        insurance.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_COMMENT"))));

                        insurance.setCreateDateTime(rs.getTimestamp("OC_INSURANCE_CREATETIME"));
                        insurance.setUpdateDateTime(rs.getTimestamp("OC_INSURANCE_UPDATETIME"));
                        insurance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_INSURANCE_UPDATEUID")));
                        insurance.setVersion(rs.getInt("OC_INSURANCE_VERSION"));
                        insurance.setPatientUID(ScreenHelper.checkString(rs.getString("OC_INSURANCE_PATIENTUID")));
                        insurance.setInsuranceCategoryLetter(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER")));

                        insurance.setExtraInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID")));
                        insurance.setExtraInsurarUid2(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID2")));
                        insurance.setDefaultInsurance(rs.getInt("OC_INSURANCE_DEFAULT"));
                        insurance.setMembercategory(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBERCATEGORY")));
                        insurance.setFamilycode(ScreenHelper.checkString(rs.getString("OC_INSURANCE_FAMILYCODE")));

                        if(insurance.getInsuranceCategory()!=null && insurance.getInsuranceCategory().getPatientShare()!=null && insurance.getInsuranceCategory().getPatientShare().length()>0){
                        	insurance.setPatientShare(Integer.parseInt(insurance.getInsuranceCategory().getPatientShare()));
                        }
                    }
                }
                catch(Exception e){
                    Debug.printStackTrace(e);
                }
                finally{
                    try{
                        if(rs!= null) rs.close();
                        if(ps!= null) ps.close();
                        oc_conn.close();
                    }
                    catch(Exception e){
                        e.printStackTrace();
                    }
                }
            }
        }
        
        return insurance;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect,sInsert,sDelete;
        int iVersion = 1;
        String ids[];
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                	// check existence
                    sSelect = " SELECT * FROM OC_INSURANCES "+
                              " WHERE OC_INSURANCE_SERVERID = ? "+
                              " AND OC_INSURANCE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if(rs.next()){
                        iVersion = rs.getInt("OC_INSURANCE_VERSION")+1;
                    }
                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_INSURANCES_HISTORY("+
                                " OC_INSURANCE_SERVERID,"+
                                " OC_INSURANCE_OBJECTID,"+
                                " OC_INSURANCE_NR,"+
                                " OC_INSURANCE_INSURARUID,"+
                                " OC_INSURANCE_TYPE,"+
                                " OC_INSURANCE_START,"+
                                " OC_INSURANCE_STOP,"+
                                " OC_INSURANCE_COMMENT,"+
                                " OC_INSURANCE_CREATETIME,"+
                                " OC_INSURANCE_UPDATETIME,"+
                                " OC_INSURANCE_UPDATEUID,"+
                                " OC_INSURANCE_VERSION,"+
                                " OC_INSURANCE_PATIENTUID,"+
                                " OC_INSURANCE_INSURANCECATEGORYLETTER,"+
                                " OC_INSURANCE_MEMBER_IMMAT,"+
                                " OC_INSURANCE_MEMBER_EMPLOYER,"+
                                " OC_INSURANCE_STATUS,"+
                                " OC_INSURANCE_MEMBER,"+
                                " OC_INSURANCE_EXTRAINSURARUID,"+
                                " OC_INSURANCE_EXTRAINSURARUID2,"+
                                " OC_INSURANCE_DEFAULT,"+
                                " OC_INSURANCE_MEMBERCATEGORY,"+
                                " OC_INSURANCE_FAMILYCODE"+
                                ")"+

                              " SELECT OC_INSURANCE_SERVERID,"+
                                     " OC_INSURANCE_OBJECTID,"+
                                     " OC_INSURANCE_NR,"+
                                     " OC_INSURANCE_INSURARUID,"+
                                     " OC_INSURANCE_TYPE,"+
                                     " OC_INSURANCE_START,"+
                                     " OC_INSURANCE_STOP,"+
                                     " OC_INSURANCE_COMMENT,"+
                                     " OC_INSURANCE_CREATETIME,"+
                                     " OC_INSURANCE_UPDATETIME,"+
                                     " OC_INSURANCE_UPDATEUID,"  +
                                     " OC_INSURANCE_VERSION,"+
                                     " OC_INSURANCE_PATIENTUID,"+
                                     " OC_INSURANCE_INSURANCECATEGORYLETTER,"+
                                     " OC_INSURANCE_MEMBER_IMMAT,"+
                                     " OC_INSURANCE_MEMBER_EMPLOYER,"+
                                     " OC_INSURANCE_STATUS,"+
                                     " OC_INSURANCE_MEMBER,"+
                                     " OC_INSURANCE_EXTRAINSURARUID,"+
                                     " OC_INSURANCE_EXTRAINSURARUID2,"+
                                     " OC_INSURANCE_DEFAULT,"+
                                     " OC_INSURANCE_MEMBERCATEGORY,"+
                                     " OC_INSURANCE_FAMILYCODE"+
                              " FROM OC_INSURANCES "+
                              " WHERE OC_INSURANCE_SERVERID = ?"+
                              " AND OC_INSURANCE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_INSURANCES "+
                              " WHERE OC_INSURANCE_SERVERID = ? "+
                              " AND OC_INSURANCE_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_INSURANCES")+""};
            }
            
            if(ids.length == 2){
                sInsert = " INSERT INTO OC_INSURANCES"+
                                      "("+
                                      " OC_INSURANCE_SERVERID,"+
                                      " OC_INSURANCE_OBJECTID,"+
                                      " OC_INSURANCE_NR,"+
                                      " OC_INSURANCE_INSURARUID,"+
                                      " OC_INSURANCE_TYPE,"+
                                      " OC_INSURANCE_START,"+
                                      " OC_INSURANCE_STOP,"+
                                      " OC_INSURANCE_COMMENT,"+
                                      " OC_INSURANCE_CREATETIME,"+
                                      " OC_INSURANCE_UPDATETIME,"+
                                      " OC_INSURANCE_UPDATEUID,"  +
                                      " OC_INSURANCE_VERSION,"+
                                      " OC_INSURANCE_PATIENTUID,"+
                                      " OC_INSURANCE_INSURANCECATEGORYLETTER,"+
                                      " OC_INSURANCE_MEMBER_IMMAT,"+
                                      " OC_INSURANCE_MEMBER_EMPLOYER,"+
                                      " OC_INSURANCE_STATUS,"+
                                      " OC_INSURANCE_MEMBER,"+
                                      " OC_INSURANCE_EXTRAINSURARUID,"+
                                      " OC_INSURANCE_EXTRAINSURARUID2,"+
                                      " OC_INSURANCE_DEFAULT,"+
                                      " OC_INSURANCE_MEMBERCATEGORY,"+
                                      " OC_INSURANCE_FAMILYCODE"+
                                      ") "+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));

                ps.setString(3,this.getInsuranceNr());
                ps.setString(4,this.getInsurarUid());
                ps.setString(5,this.getType());
                ps.setTimestamp(6,this.getStart());
                ps.setTimestamp(7,this.getStop());
                ps.setString(8,this.getComment()==null?"":this.getComment().toString());

                ps.setTimestamp(9,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(10,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(11,this.getUpdateUser());
                ps.setInt(12,iVersion);
                if(this.getPatient() != null){
                    ps.setString(13,this.getPatient().personid);
                }else{
                    ps.setString(13,"");
                }
                ps.setString(14,this.getInsuranceCategoryLetter());
                ps.setString(15,this.getMemberImmat());
                ps.setString(16,this.getMemberEmployer());
                ps.setString(17,this.getStatus());
                ps.setString(18,this.getMember());
                ps.setString(19,this.getExtraInsurarUid());
                ps.setString(20,this.getExtraInsurarUid2());
                ps.setInt(21, this.getDefaultInsurance());
                ps.setString(22, this.getMembercategory());
                ps.setString(23, this.getFamilycode());
                ps.executeUpdate();
                ps.close();
                
                this.setUid(ids[0]+"."+ids[1]);
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- FIND INSURANCES -------------------------------------------------------------------------
    public static Vector findInsurances(String sFindStart, String sFindStop, String sFindType,
    		                            String sFindNr, String sSortColumn, String sPatientUID){
        Vector vInsurance = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_INSURANCES ";
        String sConditions  = " OC_INSURANCE_PATIENTUID = ? AND";

        if(sFindStart.length() > 0){sConditions+= " OC_INSURANCE_START > ? AND";}
        if(sFindStop.length()  > 0){sConditions+= " (OC_INSURANCE_STOP > ? OR OC_INSURANCE_STOP IS NULL) AND";}
        if(sFindType.length()  > 0){sConditions+= " OC_INSURANCE_TYPE = ? AND";}
        if(sFindNr.length()    > 0){sConditions+= " OC_INSURANCE_NR LIKE ? AND";}

        if(sConditions.length() > 0){
            sConditions = " WHERE "+sConditions.substring(0,sConditions.length() - 3);
            sSelect+= sConditions;
        }

        if(sSortColumn.length() > 0){
            sSelect+= " "+sSortColumn+" DESC";
        }

        int i = 1;
        Insurance insurance;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(i++,sPatientUID);
            if(sFindStart.length() > 0){ps.setString(i++,sFindStart);}
            if(sFindStop.length()  > 0){ps.setString(i++,sFindStop);}
            if(sFindType.length()  > 0){ps.setString(i++,sFindType);}
            if(sFindNr.length()    > 0){ps.setString(i++,"%"+sFindNr+"%");}

            rs = ps.executeQuery();

            while(rs.next()){
                insurance = new Insurance();
                insurance.setUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID")));

                insurance.setInsuranceNr(ScreenHelper.checkString(rs.getString("OC_INSURANCE_NR")));
                insurance.setInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURARUID")));
                insurance.setType(ScreenHelper.checkString(rs.getString("OC_INSURANCE_TYPE")));
                insurance.setMember(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER")));
                insurance.setMemberImmat(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_IMMAT")));
                insurance.setMemberEmployer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_EMPLOYER")));
                insurance.setStatus(ScreenHelper.checkString(rs.getString("OC_INSURANCE_STATUS")));
                insurance.setStart(rs.getTimestamp("OC_INSURANCE_START"));
                insurance.setStop(rs.getTimestamp("OC_INSURANCE_STOP"));
                insurance.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_COMMENT"))));
                insurance.setInsuranceCategoryLetter(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER")));

                insurance.setCreateDateTime(rs.getTimestamp("OC_INSURANCE_CREATETIME"));
                insurance.setUpdateDateTime(rs.getTimestamp("OC_INSURANCE_UPDATETIME"));
                insurance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_INSURANCE_UPDATEUID")));
                insurance.setVersion(rs.getInt("OC_INSURANCE_VERSION"));

                insurance.setExtraInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID")));
                insurance.setExtraInsurarUid2(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID2")));
                insurance.setDefaultInsurance(rs.getInt("OC_INSURANCE_DEFAULT"));
                insurance.setMembercategory(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBERCATEGORY")));
                insurance.setFamilycode(ScreenHelper.checkString(rs.getString("OC_INSURANCE_FAMILYCODE")));

                vInsurance.addElement(insurance);
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vInsurance;
    }

    public static Vector findInsurances(String sFindStart, String sFindStop, String sFindInsurarUid,
            String sFindNr){
		Vector vInsurance = new Vector();
		PreparedStatement ps = null;
		ResultSet rs = null;
		
		String sSelect = "SELECT * FROM OC_INSURANCES ";
		String sConditions  = "";
		
		if(sFindStart.length() > 0){sConditions+= " OC_INSURANCE_START > ? AND";}
		if(sFindStop.length()  > 0){sConditions+= " (OC_INSURANCE_STOP > ? OR OC_INSURANCE_STOP IS NULL) AND";}
		if(sFindInsurarUid.length()  > 0){sConditions+= " OC_INSURANCE_INSURARUID = ? AND";}
		if(sFindNr.length()    > 0){sConditions+= " OC_INSURANCE_NR LIKE ? AND";}
		
		if(sConditions.length() > 0){
		sConditions = " WHERE "+sConditions.substring(0,sConditions.length() - 3);
		sSelect+= sConditions;
		}
		
		int i = 1;
		Insurance insurance;
		
		Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			ps = oc_conn.prepareStatement(sSelect);
			if(sFindStart.length() > 0){ps.setString(i++,sFindStart);}
			if(sFindStop.length()  > 0){ps.setString(i++,sFindStop);}
			if(sFindInsurarUid.length()  > 0){ps.setString(i++,sFindInsurarUid);}
			if(sFindNr.length()    > 0){ps.setString(i++,"%"+sFindNr+"%");}
			
			rs = ps.executeQuery();
			
			while(rs.next()){
				insurance = new Insurance();
				insurance.setUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID")));
				
				insurance.setPatientUID(ScreenHelper.checkString(rs.getString("OC_INSURANCE_PATIENTUID")));
				insurance.setInsuranceNr(ScreenHelper.checkString(rs.getString("OC_INSURANCE_NR")));
				insurance.setInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURARUID")));
				insurance.setType(ScreenHelper.checkString(rs.getString("OC_INSURANCE_TYPE")));
				insurance.setMember(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER")));
				insurance.setMemberImmat(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_IMMAT")));
				insurance.setMemberEmployer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_EMPLOYER")));
				insurance.setStatus(ScreenHelper.checkString(rs.getString("OC_INSURANCE_STATUS")));
				insurance.setStart(rs.getTimestamp("OC_INSURANCE_START"));
				insurance.setStop(rs.getTimestamp("OC_INSURANCE_STOP"));
				insurance.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_COMMENT"))));
				insurance.setInsuranceCategoryLetter(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER")));
				
				insurance.setCreateDateTime(rs.getTimestamp("OC_INSURANCE_CREATETIME"));
				insurance.setUpdateDateTime(rs.getTimestamp("OC_INSURANCE_UPDATETIME"));
				insurance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_INSURANCE_UPDATEUID")));
				insurance.setVersion(rs.getInt("OC_INSURANCE_VERSION"));
				
				insurance.setExtraInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID")));
				insurance.setExtraInsurarUid2(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID2")));
				insurance.setDefaultInsurance(rs.getInt("OC_INSURANCE_DEFAULT"));
				insurance.setMembercategory(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBERCATEGORY")));
				insurance.setFamilycode(ScreenHelper.checkString(rs.getString("OC_INSURANCE_FAMILYCODE")));
				
				vInsurance.addElement(insurance);
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null)rs.close();
				if(ps!=null)ps.close();
				oc_conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		
		return vInsurance;
    }
    
    public static String getActiveInsurance(String sPatientUID,String sInsurarUID){
    	if(sInsurarUID!=null && sInsurarUID.length()>0){
	    	Vector activeInsurances = getCurrentInsurances(sPatientUID);
	    	for(int n=0;n<activeInsurances.size();n++){
	    		Insurance insurance = (Insurance)activeInsurances.elementAt(n);
	    		if(insurance.getInsurarUid().equalsIgnoreCase(sInsurarUID)){
	    			return insurance.getUid();
	    		}
	    	}
    	}
    	return null;
    }
    
    //--- GET CURRENT INSURANCES ------------------------------------------------------------------
    public static Vector getCurrentInsurances(String sPatientUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vInsurances = new Vector();
        Insurance currentInsurance;
        String sUID;

        String sSelect = "SELECT OC_INSURANCE_SERVERID,OC_INSURANCE_OBJECTID"+
                         " FROM OC_INSURANCES"+
                         "  WHERE OC_INSURANCE_PATIENTUID = ?"+
                         "   AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP > ?)";

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientUID);
            ps.setTimestamp(2,new Timestamp(ScreenHelper.getSQLDate(ScreenHelper.getDate()).getTime()));
            rs = ps.executeQuery();

            while(rs.next()){
                sUID = ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID"));
                currentInsurance = Insurance.get(sUID);

                vInsurances.addElement(currentInsurance);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vInsurances;
    }

    //--- SELECT INSURANCES -----------------------------------------------------------------------
    public static Vector selectInsurances(String sPatientUID, String sSortColumn){
        return selectInsurances(sPatientUID,sSortColumn,false); // active insurances
    }

    public static Vector selectInsurances(String sPatientUID, String sSortColumn, boolean closed){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vInsurances = new Vector();
        Insurance insurance ;

        String sSortAppend = "";

        if(sSortColumn.length() > 0){
            sSortAppend = " ORDER BY "+sSortColumn;
        }

        String sSelect = "SELECT * FROM OC_INSURANCES"+
                         " WHERE OC_INSURANCE_PATIENTUID = ?";
        if(closed){
            sSelect+= " AND OC_INSURANCE_STOP<=?";	
        }
        else {
            sSelect+= " AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>?)";	
        }
        
        sSelect+= sSortAppend;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientUID);
            ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
            rs = ps.executeQuery();

            while(rs.next()){
                insurance  = new Insurance();

                insurance.setUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID")));

                insurance.setInsuranceNr(ScreenHelper.checkString(rs.getString("OC_INSURANCE_NR")));
                insurance.setInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURARUID")));
                insurance.setType(ScreenHelper.checkString(rs.getString("OC_INSURANCE_TYPE")));
                insurance.setMember(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER")));
                insurance.setMemberImmat(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_IMMAT")));
                insurance.setMemberEmployer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_EMPLOYER")));
                insurance.setStatus(ScreenHelper.checkString(rs.getString("OC_INSURANCE_STATUS")));
                insurance.setStart(rs.getTimestamp("OC_INSURANCE_START"));
                insurance.setStop(rs.getTimestamp("OC_INSURANCE_STOP"));
                insurance.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_COMMENT"))));

                insurance.setCreateDateTime(rs.getTimestamp("OC_INSURANCE_CREATETIME"));
                insurance.setUpdateDateTime(rs.getTimestamp("OC_INSURANCE_UPDATETIME"));
                insurance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_INSURANCE_UPDATEUID")));
                insurance.setVersion(rs.getInt("OC_INSURANCE_VERSION"));
                insurance.setPatientUID(ScreenHelper.checkString(rs.getString("OC_INSURANCE_PATIENTUID")));
                insurance.setInsuranceCategoryLetter(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER")));

                insurance.setExtraInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID")));
                insurance.setExtraInsurarUid2(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID2")));
                insurance.setDefaultInsurance(rs.getInt("OC_INSURANCE_DEFAULT"));
                insurance.setMembercategory(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBERCATEGORY")));
                insurance.setFamilycode(ScreenHelper.checkString(rs.getString("OC_INSURANCE_FAMILYCODE")));

                if(insurance.getInsuranceCategory()!=null && insurance.getInsuranceCategory().getPatientShare()!=null && insurance.getInsuranceCategory().getPatientShare().length()>0){
                	insurance.setPatientShare(Integer.parseInt(insurance.getInsuranceCategory().getPatientShare()));
                }

                vInsurances.addElement(insurance);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vInsurances;
    }

    public static Vector selectAllInsurances(String sPatientUID, String sSortColumn){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vInsurances = new Vector();
        Insurance insurance ;

        String sSortAppend = "";

        if(sSortColumn.length() > 0){
            sSortAppend = " ORDER BY "+sSortColumn;
        }

        String sSelect = "SELECT * FROM OC_INSURANCES"+
                         " WHERE OC_INSURANCE_PATIENTUID = ?";

        sSelect+= sSortAppend;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientUID);
            rs = ps.executeQuery();

            while(rs.next()){
                insurance  = new Insurance();

                insurance.setUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID")));

                insurance.setInsuranceNr(ScreenHelper.checkString(rs.getString("OC_INSURANCE_NR")));
                insurance.setInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURARUID")));
                insurance.setType(ScreenHelper.checkString(rs.getString("OC_INSURANCE_TYPE")));
                insurance.setMember(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER")));
                insurance.setMemberImmat(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_IMMAT")));
                insurance.setMemberEmployer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_EMPLOYER")));
                insurance.setStatus(ScreenHelper.checkString(rs.getString("OC_INSURANCE_STATUS")));
                insurance.setStart(rs.getTimestamp("OC_INSURANCE_START"));
                insurance.setStop(rs.getTimestamp("OC_INSURANCE_STOP"));
                insurance.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_COMMENT"))));

                insurance.setCreateDateTime(rs.getTimestamp("OC_INSURANCE_CREATETIME"));
                insurance.setUpdateDateTime(rs.getTimestamp("OC_INSURANCE_UPDATETIME"));
                insurance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_INSURANCE_UPDATEUID")));
                insurance.setVersion(rs.getInt("OC_INSURANCE_VERSION"));
                insurance.setPatientUID(ScreenHelper.checkString(rs.getString("OC_INSURANCE_PATIENTUID")));
                insurance.setInsuranceCategoryLetter(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER")));

                insurance.setExtraInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID")));
                insurance.setExtraInsurarUid2(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID2")));
                insurance.setDefaultInsurance(rs.getInt("OC_INSURANCE_DEFAULT"));
                insurance.setMembercategory(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBERCATEGORY")));
                insurance.setFamilycode(ScreenHelper.checkString(rs.getString("OC_INSURANCE_FAMILYCODE")));

                vInsurances.addElement(insurance);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vInsurances;
    }

    //--- COUNT PATIENTS PER CATEGORY -------------------------------------------------------------
    public static Hashtable countPatientsPerCategory(String sInsurarUid){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Hashtable patientsPerCategory = new Hashtable();

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT count(*) AS count, OC_INSURANCE_INSURANCECATEGORYLETTER"+
                          " FROM OC_INSURANCES"+
                          "  WHERE OC_INSURANCE_INSURARUID=?"+
                          "   GROUP BY OC_INSURANCE_INSURANCECATEGORYLETTER";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sInsurarUid);
            rs = ps.executeQuery();
            while(rs.next()){
                patientsPerCategory.put(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER"),rs.getInt("count")+"");
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

        return patientsPerCategory;
    }

    //--- GET DEFAULT INSURANCE FOR PATIENT -------------------------------------------------------
    public static Insurance getDefaultInsuranceForPatient(String sPatientUID){
    	Insurance defaultInsurance=null;
    	Vector insurances = Insurance.selectInsurances(sPatientUID, "");
    	for(int n=0;n<insurances.size();n++){
    		Insurance insurance = (Insurance)insurances.elementAt(n);
    		if(insurance.getDefaultInsurance()==1){
    			defaultInsurance=insurance;
    			break;
    		}
    	}
    	if(defaultInsurance==null) {
    		return getMostInterestingInsuranceForPatient(sPatientUID,false);
    	}
    	
    	return defaultInsurance;
    }
    
    //--- GET DEFAULT INSURANCE FOR PATIENT -------------------------------------------------------
    public static Insurance getDefaultInsuranceForPatientLimited(String sPatientUID){
    	Insurance defaultInsurance=null;
    	Vector insurances = Insurance.selectInsurances(sPatientUID, "");
    	for(int n=0;n<insurances.size();n++){
    		Insurance insurance = (Insurance)insurances.elementAt(n);
    		if(insurance.getDefaultInsurance()==1){
    			defaultInsurance=insurance;
    			break;
    		}
    	}
    	
    	return defaultInsurance;
    }
    
    //--- GET MOST INTERSTING INSURANCE FOR PATIENT (1) -------------------------------------------
    // active insurance for specified patient, with lowest patientshare
    public static Insurance getMostInterestingInsuranceForPatient(String sPatientUID){
    	return getMostInterestingInsuranceForPatient(sPatientUID,true);
    }
    public static Insurance getMostInterestingInsuranceForPatient(String sPatientUID, boolean checkDefault){
    	PreparedStatement ps = null;
        ResultSet rs = null;
        Insurance insurance=null;
        
        // patientshare
        if(checkDefault) {
	        insurance = getDefaultInsuranceForPatientLimited(sPatientUID);
	        if(insurance!=null){
	        	try{
		        	insurance.setPatientShare(Integer.parseInt(insurance.getInsuranceCategory().getPatientShare()));
		        	return insurance;
	        	}
	        	catch(Exception a){
	        		Debug.print(a.getMessage());
	        	}
	        }
        }
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT c.OC_INSURANCECATEGORY_PATIENTSHARE, i.*"+
                          " FROM OC_INSURANCES i, OC_INSURANCECATEGORIES c"+
                          "  WHERE i.OC_INSURANCE_PATIENTUID = ?"+
                          "   AND i.OC_INSURANCE_INSURANCECATEGORYLETTER = c.OC_INSURANCECATEGORY_CATEGORY"+
                          "   AND i.OC_INSURANCE_INSURARUID = c.OC_INSURANCECATEGORY_INSURARUID"+
                          "   AND (i.OC_INSURANCE_STOP > ? OR i.OC_INSURANCE_STOP IS NULL)"+
                          " ORDER BY c.OC_INSURANCECATEGORY_PATIENTSHARE ASC";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sPatientUID);
            ps.setDate(2,new java.sql.Date(new java.util.Date().getTime())); // now
            rs = ps.executeQuery();

            while(rs.next()){
                insurance = new Insurance();
                insurance.setUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID")));

                insurance.setInsuranceNr(ScreenHelper.checkString(rs.getString("OC_INSURANCE_NR")));
                insurance.setInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURARUID")));
                insurance.setType(ScreenHelper.checkString(rs.getString("OC_INSURANCE_TYPE")));
                insurance.setMember(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER")));
                insurance.setMemberImmat(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_IMMAT")));
                insurance.setMemberEmployer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_EMPLOYER")));
                insurance.setStatus(ScreenHelper.checkString(rs.getString("OC_INSURANCE_STATUS")));
                insurance.setStart(rs.getTimestamp("OC_INSURANCE_START"));
                insurance.setStop(rs.getTimestamp("OC_INSURANCE_STOP"));
                insurance.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_COMMENT"))));
                insurance.setCreateDateTime(rs.getTimestamp("OC_INSURANCE_CREATETIME"));
                insurance.setUpdateDateTime(rs.getTimestamp("OC_INSURANCE_UPDATETIME"));
                insurance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_INSURANCE_UPDATEUID")));
                insurance.setVersion(rs.getInt("OC_INSURANCE_VERSION"));
                insurance.setPatientUID(ScreenHelper.checkString(rs.getString("OC_INSURANCE_PATIENTUID")));
                insurance.setInsuranceCategoryLetter(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER")));
                insurance.setPatientShare(rs.getInt("OC_INSURANCECATEGORY_PATIENTSHARE"));
                insurance.setExtraInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID")));
                insurance.setExtraInsurarUid2(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID2")));
                insurance.setDefaultInsurance(rs.getInt("OC_INSURANCE_DEFAULT"));
                insurance.setMembercategory(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBERCATEGORY")));
                insurance.setFamilycode(ScreenHelper.checkString(rs.getString("OC_INSURANCE_FAMILYCODE")));
                
                if(insurance.isAuthorized()){
                	break;
                }
                else{
                	insurance = null;
                }
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

        return insurance;
    }

    //--- GET MOST INTERSTING INSURANCE FOR PATIENT (2) -------------------------------------------
    public static Insurance getMostInterestingInsuranceForPatient(String sPatientUID, java.util.Date date){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Insurance insurance = null;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT c.OC_INSURANCECATEGORY_PATIENTSHARE, i.*"+
                          " FROM OC_INSURANCES i, OC_INSURANCECATEGORIES c"+
                          "  WHERE i.OC_INSURANCE_PATIENTUID = ?"+
                          "   AND i.OC_INSURANCE_INSURANCECATEGORYLETTER = c.OC_INSURANCECATEGORY_CATEGORY"+
                          "   AND i.OC_INSURANCE_INSURARUID = c.OC_INSURANCECATEGORY_INSURARUID"+
                          "   AND i.OC_INSURANCE_START <=?"+
                          "   AND (i.OC_INSURANCE_STOP >=? OR i.OC_INSURANCE_STOP IS NULL)"+
                          " ORDER BY c.OC_INSURANCECATEGORY_PATIENTSHARE ASC";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sPatientUID);
            ps.setDate(2,new java.sql.Date(date.getTime())); 
            ps.setDate(3,new java.sql.Date(date.getTime())); 
            rs = ps.executeQuery();

            while(rs.next()){
                insurance = new Insurance();
                insurance.setUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_INSURANCE_OBJECTID")));

                insurance.setInsuranceNr(ScreenHelper.checkString(rs.getString("OC_INSURANCE_NR")));
                insurance.setInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURARUID")));
                insurance.setType(ScreenHelper.checkString(rs.getString("OC_INSURANCE_TYPE")));
                insurance.setMember(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER")));
                insurance.setMemberImmat(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_IMMAT")));
                insurance.setMemberEmployer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBER_EMPLOYER")));
                insurance.setStatus(ScreenHelper.checkString(rs.getString("OC_INSURANCE_STATUS")));
                insurance.setStart(rs.getTimestamp("OC_INSURANCE_START"));
                insurance.setStop(rs.getTimestamp("OC_INSURANCE_STOP"));
                insurance.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_INSURANCE_COMMENT"))));
                insurance.setCreateDateTime(rs.getTimestamp("OC_INSURANCE_CREATETIME"));
                insurance.setUpdateDateTime(rs.getTimestamp("OC_INSURANCE_UPDATETIME"));
                insurance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_INSURANCE_UPDATEUID")));
                insurance.setVersion(rs.getInt("OC_INSURANCE_VERSION"));
                insurance.setPatientUID(ScreenHelper.checkString(rs.getString("OC_INSURANCE_PATIENTUID")));
                insurance.setInsuranceCategoryLetter(ScreenHelper.checkString(rs.getString("OC_INSURANCE_INSURANCECATEGORYLETTER")));
                insurance.setPatientShare(rs.getInt("OC_INSURANCECATEGORY_PATIENTSHARE"));
                insurance.setExtraInsurarUid(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID")));
                insurance.setExtraInsurarUid2(ScreenHelper.checkString(rs.getString("OC_INSURANCE_EXTRAINSURARUID2")));
                insurance.setDefaultInsurance(rs.getInt("OC_INSURANCE_DEFAULT"));
                insurance.setMembercategory(ScreenHelper.checkString(rs.getString("OC_INSURANCE_MEMBERCATEGORY")));
                insurance.setFamilycode(ScreenHelper.checkString(rs.getString("OC_INSURANCE_FAMILYCODE")));
                
                if(insurance.isAuthorized()){
                	break;
                }
                else {
                	insurance = null;
                }
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

        return insurance;
    }

}
