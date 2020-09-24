package be.openclinic.finance;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import be.openclinic.common.ObjectReference;

import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Vector;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Statement;

public class ExtraInsurarInvoice extends Invoice {
    private String insurarUid;
    private Insurar insurar;
    private String number;
    protected String modifiers; 

	public String getModifiers() {
		return modifiers;
	}
	
	public void setModifiers(String modifiers) {
		this.modifiers = modifiers;
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

	public String getSAPExport(){
		String s="";
		if(getModifiers()!=null){
			try{
				s=getModifiers().split(";")[0];
			}
			catch(Exception e){
				//e.printStackTrace();
			}
		}
		return s;
	}

	public void setSAPExport(String s){
		setModifier(0,s);
	}


	public String getInvoiceNumber() {
        if(number==null || number.equalsIgnoreCase("")){
        	if(invoiceUid.split("\\.").length>1){
        		return invoiceUid.split("\\.")[1];
        	}
        	else{
        		return invoiceUid;
        	}
        }
        else {
        	return number+"";
        }
    }
	public static String getPatientInvoiceNumber(String uid){
		String s=uid;
        String sSelect = "SELECT OC_INSURARINVOICE_NUMBER FROM OC_EXTRAINSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID=? and OC_INSURARINVOICE_OBJECTID = ? ";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        ResultSet rs=null;
        PreparedStatement ps=null;
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(uid.split("\\.")[0]));
            ps.setInt(2,Integer.parseInt(uid.split("\\.")[1]));
            rs = ps.executeQuery();
            
            if(rs.next()){
            	String sNumber = ScreenHelper.checkString(rs.getString("OC_INSURARINVOICE_NUMBER"));
            	if(sNumber.length()>0){
            		s=sNumber;
            	}
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

		return s;
	}


    public String getNumber() {
		return number;
	}

	public void setNumber(String number) {
		this.number = number;
	}

	//--- S/GET INSURAR UID -----------------------------------------------------------------------
    public void setInsurarUid(String insurarUid) {
        this.insurarUid = insurarUid;
    }

    public String getInsurarUid() {
        return insurarUid;
    }

    //--- S/GET INSURAR ---------------------------------------------------------------------------
    public void setInsurar(Insurar insurar) {
        this.insurar = insurar;
    }

    public Insurar getInsurar() {
        if(insurar==null){
            if(ScreenHelper.checkString(insurarUid).length()>0){
                insurar=Insurar.get(insurarUid);
            }
        }
        return insurar;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static ExtraInsurarInvoice get(String uid){
        ExtraInsurarInvoice insurarInvoice = new ExtraInsurarInvoice();

        if(uid!=null && uid.length()>0){
            String [] ids = uid.split("\\.");

            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_EXTRAINSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        insurarInvoice.setUid(uid);
                        insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                        insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                        insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                        insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                        insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                        insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                        insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                        insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                        insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                        insurarInvoice.setNumber(rs.getString("OC_INSURARINVOICE_NUMBER"));
                        insurarInvoice.setModifiers(rs.getString("OC_INSURARINVOICE_MODIFIERS"));
                    }
                    rs.close();
                    ps.close();

                    insurarInvoice.debets = Debet.getFullExtraInsurarDebetsViaInvoiceUid(insurarInvoice.getUid());
                    insurarInvoice.credits = InsurarCredit.getInsurarCreditsViaInvoiceUID(insurarInvoice.getUid());
                }
                catch(Exception e){
                    Debug.println("OpenClinic => InsurarInvoice.java => get => "+e.getMessage());
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
            }
        }
        return insurarInvoice;
    }

    public static double getDebetAmount(String insurarInvoiceUid){
    	double total=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sql = 	" select sum(oc_debet_extrainsuraramount) total from oc_debets where oc_debet_extrainsurarinvoiceuid=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sql);
    		ps.setString(1,insurarInvoiceUid);
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			total = rs.getDouble("total");
    		}
    		else {
                rs.close();
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
    	return total;
    }

    public static double getCreditAmount(String insurarInvoiceUid){
    	double total=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sql = 	"select sum(oc_insurarcredit_amount) total from oc_insurarcredits where oc_insurarcredit_invoiceuid=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sql);
    		ps.setString(1,insurarInvoiceUid);
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			total = rs.getDouble("total");
    		}
    		else {
                rs.close();
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
    	return total;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static ExtraInsurarInvoice getWithoutDebetsOrCredits(String uid){
        ExtraInsurarInvoice insurarInvoice = new ExtraInsurarInvoice();

        if(uid!=null && uid.length()>0){
            String [] ids = uid.split("\\.");

            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_EXTRAINSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        insurarInvoice.setUid(uid);
                        insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                        insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                        insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                        insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                        insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                        insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                        insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                        insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                        insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                        insurarInvoice.setNumber(rs.getString("OC_INSURARINVOICE_NUMBER"));
                        insurarInvoice.setModifiers(rs.getString("OC_INSURARINVOICE_MODIFIERS"));
                    }
                    rs.close();
                    ps.close();

                }
                catch(Exception e){
                    Debug.println("OpenClinic => InsurarInvoice.java => get => "+e.getMessage());
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
            }
        }
        return insurarInvoice;
    }

    public static ExtraInsurarInvoice getViaInvoiceUID(String sInvoiceID){
        ExtraInsurarInvoice insurarInvoice = new ExtraInsurarInvoice();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "SELECT * FROM OC_EXTRAINSURARINVOICES WHERE OC_INSURARINVOICE_ID = ? ";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sInvoiceID));
            rs = ps.executeQuery();

            if(rs.next()){
                insurarInvoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                insurarInvoice.setNumber(rs.getString("OC_INSURARINVOICE_NUMBER"));
                insurarInvoice.setModifiers(rs.getString("OC_INSURARINVOICE_MODIFIERS"));
            }
            rs.close();
            ps.close();

            insurarInvoice.debets = Debet.getExtraInsurarDebetsViaInvoiceUid(insurarInvoice.getUid());
            insurarInvoice.credits = InsurarCredit.getInsurarCreditsViaInvoiceUID(insurarInvoice.getUid());
        }
        catch(Exception e){
            Debug.println("OpenClinic => InsurarInvoice.java => getViaInvoiceUID => "+e.getMessage());
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
        return insurarInvoice;
    }

    public boolean store(){
        boolean bStored = true;
        String ids[];
        int iVersion = 1;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");

                if(ids.length == 2){
                    sSelect = "SELECT OC_INSURARINVOICE_VERSION FROM OC_EXTRAINSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()) {
                        iVersion = rs.getInt("OC_INSURARINVOICE_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sSelect = "INSERT INTO OC_EXTRAINSURARINVOICES_HISTORY SELECT * FROM OC_EXTRAINSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sSelect = " DELETE FROM OC_EXTRAINSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
                else{
                    ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES")+""};
                    this.setUid(ids[0]+"."+ids[1]);
                    this.setInvoiceUid(ids[1]);
                   	this.setNumber(getInvoiceNumberCounter("ExtraInsurerInvoice"));
                }
            }
            else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES")+""};
                this.setUid(ids[0]+"."+ids[1]);
                this.setInvoiceUid(ids[1]);
               	this.setNumber(getInvoiceNumberCounter("ExtraInsurerInvoice"));
            }

            if(ids.length == 2){
               sSelect = " INSERT INTO OC_EXTRAINSURARINVOICES (" +
                          " OC_INSURARINVOICE_SERVERID," +
                          " OC_INSURARINVOICE_OBJECTID," +
                          " OC_INSURARINVOICE_DATE," +
                          " OC_INSURARINVOICE_ID," +
                          " OC_INSURARINVOICE_INSURARUID," +
                          " OC_INSURARINVOICE_CREATETIME," +
                          " OC_INSURARINVOICE_UPDATETIME," +
                          " OC_INSURARINVOICE_UPDATEUID," +
                          " OC_INSURARINVOICE_VERSION," +
                          " OC_INSURARINVOICE_BALANCE," +
                          " OC_INSURARINVOICE_NUMBER," +
                          " OC_INSURARINVOICE_STATUS," +
                          " OC_INSURARINVOICE_MODIFIERS" +
                        ") " +
                         " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setTimestamp(3,new Timestamp(this.getDate().getTime()));
                ps.setInt(4,Integer.parseInt(this.getInvoiceUid()));
                ps.setString(5,this.getInsurarUid());
                if(this.getCreateDateTime()==null){
                    this.setCreateDateTime(new Date());
                }
                ps.setTimestamp(6,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(7,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(8,this.getUpdateUser());
                ps.setInt(9,iVersion);
                ps.setDouble(10,this.getBalance());
                ps.setString(11, this.getNumber());
                ps.setString(12,this.getStatus());
                ps.setString(13,this.getModifiers());
                ps.executeUpdate();
                ps.close();

                sSelect = "UPDATE OC_DEBETS SET OC_DEBET_EXTRAINSURARINVOICEUID = NULL WHERE OC_DEBET_EXTRAINSURARINVOICEUID = ? ";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getUid());
                ps.executeUpdate();
                ps.close();
                Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                Statement st= loc_conn.createStatement();
                boolean hasqueries=false;
                if (this.debets!=null){
                    String sDebetUID;
                    String[] aDebetUID;
                    String UIDs="";
                    int counter=0;
                    for (int i=0;i<this.debets.size();i++){
                        sDebetUID = ScreenHelper.checkString(((Debet)this.debets.elementAt(i)).getUid());
                        if (sDebetUID.length()>0){
                            aDebetUID = sDebetUID.split("\\.");
                            if (aDebetUID.length==2){
                                hasqueries=true;
                                if(UIDs.length()>0){
                                    UIDs+=",";
                                }
                                UIDs+=aDebetUID[1];
                                counter++;
                            }
                        }
                        if(counter>=250){
                            st.addBatch("UPDATE OC_DEBETS SET OC_DEBET_EXTRAINSURARINVOICEUID = '"+this.getUid()+"' WHERE OC_DEBET_OBJECTID in ("+UIDs+")");
                            UIDs="";
                            counter=0;
                        }
                    }
                    if(counter>0){
                        st.addBatch("UPDATE OC_DEBETS SET OC_DEBET_EXTRAINSURARINVOICEUID = '"+this.getUid()+"' WHERE OC_DEBET_OBJECTID in ("+UIDs+")");
                    }
                }
                if(hasqueries){
                    st.executeBatch();
                }
                st.close();
                loc_conn.close();

                sSelect = "UPDATE OC_INSURARCREDITS SET OC_INSURARCREDIT_INVOICEUID = NULL WHERE OC_INSURARCREDIT_INVOICEUID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getUid());
                ps.executeUpdate();
                ps.close();

                if (this.credits!=null){
                    String sCreditUID;
                    String[] aCreditUID;

                    for (int i=0;i<this.credits.size();i++){
                        sCreditUID = ScreenHelper.checkString((String)this.credits.elementAt(i));

                        if (sCreditUID.length()>0){
                            aCreditUID = sCreditUID.split("\\.");

                            if (aCreditUID.length==2){
                                sSelect = "UPDATE OC_INSURARCREDITS SET OC_INSURARCREDIT_INVOICEUID = ? WHERE OC_INSURARCREDIT_SERVERID = ? AND OC_INSURARCREDIT_OBJECTID = ? ";
                                ps = oc_conn.prepareStatement(sSelect);
                                ps.setString(1,this.getUid());
                                ps.setInt(2,Integer.parseInt(aCreditUID[0]));
                                ps.setInt(3,Integer.parseInt(aCreditUID[1]));
                                ps.executeUpdate();
                                ps.close();
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
            bStored = false;
            Debug.println("OpenClinic => InsurarInvoice.java => store => "+e.getMessage()+" = "+sSelect);
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
        return bStored;
    }

    //--- SEARCH INVOICES -------------------------------------------------------------------------
    public static Vector searchInvoices(String sInvoiceDate, String sInvoiceNr, String sInvoicePatientUid, String sInvoiceStatus){
        return searchInvoices(sInvoiceDate,sInvoiceNr,sInvoicePatientUid,sInvoiceStatus,"","");
    }

    public static Vector searchInvoices(String sInvoiceDate, String sInvoiceNr, String sInvoiceInsurarUid,
                                        String sInvoiceStatus, String sAmountMin, String sAmountMax){
        Vector invoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_EXTRAINSURARINVOICES WHERE ";
            if(sInvoiceDate.length() > 0){
                sSql+= " OC_INSURARINVOICE_DATE = ? AND";
            }
            if(sInvoiceNr.length() > 0){
                sSql+= " OC_INSURARINVOICE_OBJECTID = ? AND";
            }
            if(sInvoiceInsurarUid.length() > 0){
                sSql+= " OC_INSURARINVOICE_INSURARUID = ? AND";
            }
            if(sInvoiceStatus.length() > 0){
                sSql+= " OC_INSURARINVOICE_STATUS = ? AND";
            }

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                sSql+= " OC_INSURARINVOICE_BALANCE BETWEEN ? AND ?";
            }
            else if (sAmountMin.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE >= ?";
            }
            else if (sAmountMax.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE <= ?";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY OC_INSURARINVOICE_DATE DESC";

            ps = oc_conn.prepareStatement(sSql);

            // set question marks
            int qmIdx = 1;
            if(sInvoiceNr.length() > 0) ps.setInt(qmIdx++,Integer.parseInt(sInvoiceNr));
            if(sInvoiceDate.length() > 0) ps.setDate(qmIdx++,new java.sql.Date(ScreenHelper.parseDate(sInvoiceDate).getTime()));
            if(sInvoiceInsurarUid.length() > 0) ps.setString(qmIdx++,sInvoiceInsurarUid);
            if(sInvoiceStatus.length() > 0) ps.setString(qmIdx++,sInvoiceStatus);

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMin));
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }
            else if (sAmountMin.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMin));
            }
            else if (sAmountMax.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }

            rs = ps.executeQuery();

            ExtraInsurarInvoice invoice;
            while(rs.next()){
                invoice = new ExtraInsurarInvoice();

                invoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                invoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                invoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                invoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                invoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                invoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                invoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                invoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                invoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                invoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                invoice.setNumber(rs.getString("OC_INSURARINVOICE_NUMBER"));
                invoice.setModifiers(rs.getString("OC_INSURARINVOICE_MODIFIERS"));

                invoices.add(invoice);
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

        return invoices;
    }

    public static Vector searchInvoices(String sInvoiceDateBegin, String sInvoiceDateEnd, String sInvoiceNr, String sAmountMin, String sAmountMax){
        Vector invoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_EXTRAINSURARINVOICES WHERE ";
            if(sInvoiceDateBegin.length() > 0){
                sSql+= " OC_INSURARINVOICE_DATE >= ? AND";
            }

            if(sInvoiceDateEnd.length() > 0){
                sSql+= " OC_INSURARINVOICE_DATE >= ? AND";
            }

            if(sInvoiceNr.length() > 0){
            	if(sInvoiceNr.contains(".")){
            		sSql+= " OC_INSURARINVOICE_NUMBER = ? AND";
            		
            	}
            	else {
            		sSql+= " (OC_INSURARINVOICE_NUMBER = '"+sInvoiceNr+"' OR OC_INSURARINVOICE_OBJECTID = ?) AND";
            	}
            }
            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                sSql+= " OC_INSURARINVOICE_BALANCE BETWEEN ? AND ? AND";
            }
            else if (sAmountMin.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE >= ? AND";
            }
            else if (sAmountMax.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE <= ? AND";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY OC_INSURARINVOICE_DATE DESC";

            ps = oc_conn.prepareStatement(sSql);

            // set question marks
            int qmIdx = 1;
            if(sInvoiceNr.length() > 0){
            	if(sInvoiceNr.contains(".")){
            		ps.setString(qmIdx++,sInvoiceNr);
            	}
            	else {
            		ps.setInt(qmIdx++,Integer.parseInt(sInvoiceNr));
            	}
            }
            if(sInvoiceDateBegin.length() > 0) ps.setDate(qmIdx++,ScreenHelper.getSQLDate(sInvoiceDateBegin));
            if(sInvoiceDateEnd.length() > 0) ps.setDate(qmIdx++,ScreenHelper.getSQLDate(sInvoiceDateEnd));

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMin));
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }
            else if (sAmountMin.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMin));
            }
            else if (sAmountMax.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }

            rs = ps.executeQuery();

            ExtraInsurarInvoice invoice;
            while(rs.next()){
                invoice = new ExtraInsurarInvoice();

                invoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                invoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                invoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                invoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                invoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                invoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                invoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                invoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                invoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                invoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                invoice.setNumber(rs.getString("OC_INSURARINVOICE_NUMBER"));
                invoice.setModifiers(rs.getString("OC_INSURARINVOICE_MODIFIERS"));

                invoices.add(invoice);
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

        return invoices;
    }

    public static Vector getInsurarInvoicesWhereDifferentStatus(String sStatus){
        Vector vInsurarInvoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_EXTRAINSURARINVOICES WHERE  OC_INSURARINVOICE_STATUS not in ("+sStatus+")";
            ps = oc_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();
            ExtraInsurarInvoice insurarInvoice;
            while(rs.next()){
                insurarInvoice = new ExtraInsurarInvoice();

                insurarInvoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                insurarInvoice.setNumber(rs.getString("OC_INSURARINVOICE_NUMBER"));
                insurarInvoice.setModifiers(rs.getString("OC_INSURARINVOICE_MODIFIERS"));

                vInsurarInvoices.add(insurarInvoice);
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarInvoice.java => getInsurarInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
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

        return vInsurarInvoices;
    }

    //--- GET DEBETS FOR INVOICE ------------------------------------------------------------------
    public static Vector getDebetsForInvoice(String sInvoiceUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector debets = new Vector();
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT a.lastname, a.firstname,a.personid,a.gender,a.dateofbirth, d.*,e.* ,c.* "+
            " FROM OC_DEBETS d, OC_EXTRAINSURARINVOICES i, OC_ENCOUNTERS e, AdminView a, OC_PRESTATIONS c"+
            "  WHERE d.OC_DEBET_EXTRAINSURARINVOICEUID = ?"+
            "   AND i.OC_INSURARINVOICE_OBJECTID = replace(d.OC_DEBET_EXTRAINSURARINVOICEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
            "   AND e.OC_ENCOUNTER_OBJECTID = replace(d.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
            "   AND c.OC_PRESTATION_OBJECTID = replace(d.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
            "   AND e.OC_ENCOUNTER_PATIENTUID = a.personid"+
            " ORDER BY lastname, firstname, OC_DEBET_DATE";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sInvoiceUid);

            rs = ps.executeQuery();
            Debet debet;
            while(rs.next()){
                debet = new Debet();

                debet.setUid(rs.getInt("OC_DEBET_SERVERID")+"."+rs.getInt("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.setInsuranceUid(rs.getString("OC_DEBET_INSURANCEUID"));
                debet.setPrestationUid(rs.getString("OC_DEBET_PRESTATIONUID"));
                debet.setEncounterUid(rs.getString("OC_DEBET_ENCOUNTERUID"));
                debet.setSupplierUid(rs.getString("OC_DEBET_SUPPLIERUID"));
                debet.setPatientInvoiceUid(rs.getString("OC_DEBET_PATIENTINVOICEUID"));
                debet.setInsurarInvoiceUid(rs.getString("OC_DEBET_INSURARINVOICEUID"));
                debet.setComment(rs.getString("OC_DEBET_COMMENT"));
                debet.setCredited(rs.getInt("OC_DEBET_CREDITED"));
                debet.setQuantity(rs.getDouble("OC_DEBET_QUANTITY"));
                debet.setExtraInsurarAmount(rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT"));
                debet.setExtraInsurarInvoiceUid(rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID"));
                debet.setExtraInsurarUid(rs.getString("OC_DEBET_EXTRAINSURARUID"));
                debet.setServiceUid(rs.getString("OC_DEBET_SERVICEUID"));
                debet.setPatientName(rs.getString("lastname")+", "+rs.getString("firstname"));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));

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
                encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));

                //Now find the most recent service for this encounter
                Encounter.EncounterService encounterService = encounter.getLastEncounterService();
                if (encounterService != null) {
                    encounter.setServiceUID(encounterService.serviceUID);
                    encounter.setManagerUID(encounterService.managerUID);
                    encounter.setBedUID(encounterService.bedUID);
                }
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

                debets.add(debet);
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarInvoice.java => getInsurarInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
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

        return debets;
    }

    //--- GET DEBETS FOR INVOICE ------------------------------------------------------------------
    public static Vector getDebetsForInvoiceSortByServiceAndDate(String sInvoiceUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector debets = new Vector();
        
        SortedMap sortedDebets = new TreeMap();
        String sSelect = "";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT a.lastname, a.firstname,a.personid,a.gender,a.dateofbirth, d.*,e.*,c.*"+
                      " FROM OC_DEBETS d, OC_EXTRAINSURARINVOICES i, OC_ENCOUNTERS e, AdminView a, OC_PRESTATIONS c"+
                      "  WHERE d.OC_DEBET_EXTRAINSURARINVOICEUID = ?"+
                      "   AND i.OC_INSURARINVOICE_OBJECTID = replace(d.OC_DEBET_EXTRAINSURARINVOICEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND e.OC_ENCOUNTER_OBJECTID = replace(d.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND c.OC_PRESTATION_OBJECTID = replace(d.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND e.OC_ENCOUNTER_PATIENTUID = a.personid"+
                      " ORDER BY OC_DEBET_SERVICEUID,OC_DEBET_DATE,lastname,firstname,OC_DEBET_PATIENTINVOICEUID";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,sInvoiceUid);

            rs = ps.executeQuery();
            Debet debet;
            while(rs.next()){
                debet = new Debet();

                debet.setUid(rs.getInt("OC_DEBET_SERVERID")+"."+rs.getInt("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.setInsuranceUid(rs.getString("OC_DEBET_INSURANCEUID"));
                debet.setExtraInsurarAmount(rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT"));
                debet.setExtraInsurarUid(rs.getString("OC_DEBET_EXTRAINSURARUID"));
                debet.setPrestationUid(rs.getString("OC_DEBET_PRESTATIONUID"));
                debet.setEncounterUid(rs.getString("OC_DEBET_ENCOUNTERUID"));
                debet.setSupplierUid(rs.getString("OC_DEBET_SUPPLIERUID"));
                debet.setPatientInvoiceUid(rs.getString("OC_DEBET_PATIENTINVOICEUID"));
                debet.setInsurarInvoiceUid(rs.getString("OC_DEBET_INSURARINVOICEUID"));
                debet.setComment(rs.getString("OC_DEBET_COMMENT"));
                debet.setCredited(rs.getInt("OC_DEBET_CREDITED"));
                debet.setQuantity(rs.getDouble("OC_DEBET_QUANTITY"));
                debet.setServiceUid(rs.getString("OC_DEBET_SERVICEUID"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setPatientName(rs.getString("lastname")+", "+rs.getString("firstname"));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));

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
                encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));

                //Now find the most recent service for this encounter
                Encounter.EncounterService encounterService = encounter.getLastEncounterService();
                if (encounterService != null) {
                    encounter.setServiceUID(encounterService.serviceUID);
                    encounter.setManagerUID(encounterService.managerUID);
                    encounter.setBedUID(encounterService.bedUID);
                }
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
                
                sortedDebets.put(new SimpleDateFormat("yyyyMMdd").format(debet.getDate())+"."+debet.getPatientName()+"."+debet.getPatientInvoiceUid()+"."+debet.getUid(), debet);
                
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarInvoice.java => getInsurarInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        Iterator iDebets = sortedDebets.keySet().iterator();
        while(iDebets.hasNext()){
        	debets.add(sortedDebets.get(iDebets.next()));
        }
        
        return debets;
    }
    
    //--- GET DEBETS FOR INVOICE ------------------------------------------------------------------
    public static Vector getDebetsForInvoiceSortByDate(String sInvoiceUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        SortedMap sortedDebets = new TreeMap();
        Vector debets = new Vector();
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT a.lastname, a.firstname,a.personid,a.gender,a.dateofbirth, d.*,e.*,c.*"+
            " FROM OC_DEBETS d, OC_EXTRAINSURARINVOICES i, OC_ENCOUNTERS e, AdminView a, OC_PRESTATIONS c"+
            "  WHERE d.OC_DEBET_EXTRAINSURARINVOICEUID = ?"+
            "   AND i.OC_INSURARINVOICE_OBJECTID = replace(d.OC_DEBET_EXTRAINSURARINVOICEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
            "   AND e.OC_ENCOUNTER_OBJECTID = replace(d.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
            "   AND c.OC_PRESTATION_OBJECTID = replace(d.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
            "   AND e.OC_ENCOUNTER_PATIENTUID = a.personid"+
            " ORDER BY OC_DEBET_DATE,lastname,firstname,OC_DEBET_PATIENTINVOICEUID";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sInvoiceUid);

            rs = ps.executeQuery();
            Debet debet;
            while(rs.next()){
                debet = new Debet();

                debet.setUid(rs.getInt("OC_DEBET_SERVERID")+"."+rs.getInt("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.setInsuranceUid(rs.getString("OC_DEBET_INSURANCEUID"));
                debet.setPrestationUid(rs.getString("OC_DEBET_PRESTATIONUID"));
                debet.setEncounterUid(rs.getString("OC_DEBET_ENCOUNTERUID"));
                debet.setSupplierUid(rs.getString("OC_DEBET_SUPPLIERUID"));
                debet.setPatientInvoiceUid(rs.getString("OC_DEBET_PATIENTINVOICEUID"));
                debet.setInsurarInvoiceUid(rs.getString("OC_DEBET_INSURARINVOICEUID"));
                debet.setComment(rs.getString("OC_DEBET_COMMENT"));
                debet.setCredited(rs.getInt("OC_DEBET_CREDITED"));
                debet.setQuantity(rs.getDouble("OC_DEBET_QUANTITY"));
                debet.setExtraInsurarAmount(rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT"));
                debet.setExtraInsurarInvoiceUid(rs.getString("OC_DEBET_EXTRAINSURARINVOICEUID"));
                debet.setExtraInsurarUid(rs.getString("OC_DEBET_EXTRAINSURARUID"));
                debet.setServiceUid(rs.getString("OC_DEBET_SERVICEUID"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setPatientName(rs.getString("lastname")+", "+rs.getString("firstname"));
                debet.setPatientbirthdate(ScreenHelper.formatDate(rs.getDate("dateofbirth")));
                debet.setPatientgender(rs.getString("gender"));
                debet.setPatientid(rs.getString("personid"));

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
                encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));

                //Now find the most recent service for this encounter
                Encounter.EncounterService encounterService = encounter.getLastEncounterService();
                if (encounterService != null) {
                    encounter.setServiceUID(encounterService.serviceUID);
                    encounter.setManagerUID(encounterService.managerUID);
                    encounter.setBedUID(encounterService.bedUID);
                }
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

                sortedDebets.put(new SimpleDateFormat("yyyyMMdd").format(debet.getDate())+"."+debet.getPatientName()+"."+debet.getPatientInvoiceUid()+"."+debet.getUid(), debet);
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarInvoice.java => getInsurarInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
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

        Iterator iDebets = sortedDebets.keySet().iterator();
        while(iDebets.hasNext()){
        	debets.add(sortedDebets.get(iDebets.next()));
        }

        return debets;
    }
     public static boolean setStatusOpen(String sInvoiceID,String UserId){

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean okQuery = false;
        String sSelect = "update OC_EXTRAINSURARINVOICES SET OC_INSURARINVOICE_STATUS ='open',OC_INSURARINVOICE_UPDATETIME=?,OC_INSURARINVOICE_UPDATEUID=? WHERE OC_INSURARINVOICE_OBJECTID = ? ";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime())); // now
            ps.setString(2,UserId);
            ps.setInt(3,Integer.parseInt(sInvoiceID));

            okQuery = (ps.executeUpdate()>0);

      }
        catch(Exception e){
            Debug.println("OpenClinic => ExtraInsurarInvoice.java => setStatusOpen => "+e.getMessage());
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
        return okQuery;
    }
}