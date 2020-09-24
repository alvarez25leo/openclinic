<%@page import="be.openclinic.pharmacy.*,
                be.openclinic.medical.Prescription"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"medication.medicationdelivery","all",activeUser)%>

<%
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
           sDefaultSrcDestType = "";

    // action
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "deliverMedication"; // default
    
	Hashtable availableProductStocks = new Hashtable();
    Vector availableProductStocksVector = new Vector();
    int iMaxQuantity = 99;
    int iMaxStock = 0;

    // retreive form data
    String sEditOperationUid    = checkString(request.getParameter("EditOperationUid")),
           sEditOperationDescr  = checkString(request.getParameter("EditOperationDescr")),
           sEditUnitsChanged    = checkString(request.getParameter("EditUnitsChanged")),
           sEditSrcDestType     = checkString(request.getParameter("EditSrcDestType")),
           sEditSrcDestUid      = checkString(request.getParameter("EditSrcDestUid")),
           sEditSrcDestName     = checkString(request.getParameter("EditSrcDestName")),
           sEditProductName     = checkString(request.getParameter("EditProductName")),
           sEditOperationDate   = checkString(request.getParameter("EditOperationDate")),
           sEditProductStockUid = checkString(request.getParameter("EditProductStockUid")),
           sEditProductStockDocumentUid = checkString(request.getParameter("EditProductStockDocumentUid")),
           sEditEncounterUid    = checkString(request.getParameter("EditEncounterUID")),
           sEditBatchUid        = checkString(request.getParameter("EditBatchUid")),
           sEditOrderUid        = checkString(request.getParameter("EditOrderUid")),
           sProductionOrderUid  = checkString(request.getParameter("ProductionOrderUid")),
           sEditPrescriptionUid = checkString(request.getParameter("EditPrescriptionUid"));
    
     String sEditProductStockDocumentUidText = "",
            sEditServiceStockUid = "",
            sEditServiceStockName = "";
    Prescription prescription = null;
    if(sEditUnitsChanged.length()==0 && sEditPrescriptionUid.length() > 0){
        prescription = Prescription.get(sEditPrescriptionUid);
        if(prescription!=null){
            sEditUnitsChanged = (prescription.getRequiredPackages()-prescription.getDeliveredQuantity())+"";
            iMaxQuantity = new Double(Double.parseDouble(sEditUnitsChanged)).intValue();
        }
    }
    
    // lookup available productStocks if none provided
    if(sEditProductStockUid.length() == 0 && sEditPrescriptionUid.length() > 0){
    	if(prescription!=null){
			Vector productStocks = ProductStock.find("",prescription.getProductUid(),"1","","","","","","","","","OC_STOCK_LEVEL","DESC");
			for(int n=0; n<productStocks.size(); n++){
				ProductStock productStock = (ProductStock)productStocks.elementAt(n);
	            sEditProductName = productStock.getProduct().getName()+" ("+productStock.getProduct().getPackageUnits()+" "+getTranNoLink("product.unit",productStock.getProduct().getUnit(),sWebLanguage)+")";
				
	            ServiceStock stock = ServiceStock.get(productStock.getServiceStockUid());
				if(stock.isAuthorizedUser(activeUser.userid)){
					availableProductStocksVector.add(productStock);
					availableProductStocks.put(productStock,stock);
				}
			}
        }
    }
    else if(sEditProductStockUid.length() > 0 && sEditProductName.length() == 0){
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if(productStock!=null){
            sEditProductName = productStock.getProduct().getName();
			
            ServiceStock stock = ServiceStock.get(productStock.getServiceStockUid());
			if(stock.isAuthorizedUser(activeUser.userid)){
				availableProductStocksVector.add(productStock);
				availableProductStocks.put(productStock,stock);
			}
        }
    }
    else if(sEditProductStockUid.length() > 0){
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if(productStock!=null){
			ServiceStock stock = ServiceStock.get(productStock.getServiceStockUid());
			
			if(stock.isAuthorizedUser(activeUser.userid)){
				availableProductStocksVector.add(productStock);
				availableProductStocks.put(productStock,stock);
			}
        }
    }
    Debug.println("2");    

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* pharmacy/medication/popups/deliverMedicationPopupAuto.jsp ********");
        Debug.println("sAction              : "+sAction);
        Debug.println("sEditOperationUid    : "+sEditOperationUid);
        Debug.println("sEditOperationDescr  : "+sEditOperationDescr);
        Debug.println("sEditUnitsChanged    : "+sEditUnitsChanged);
        Debug.println("sEditSrcDestType     : "+sEditSrcDestType);
        Debug.println("sEditSrcDestUid      : "+sEditSrcDestUid);
        Debug.println("sEditSrcDestName     : "+sEditSrcDestName);
        Debug.println("sEditOperationDate   : "+sEditOperationDate);
        Debug.println("sEditProductName     : "+sEditProductName);
        Debug.println("sEditProductStockUid : "+sEditProductStockUid);
        Debug.println("sEditProductStockDoc.: "+sEditProductStockDocumentUid);
        Debug.println("sEditEncounterUid    : "+sEditEncounterUid);
        Debug.println("sEditBatchUid        : "+sEditBatchUid);
        Debug.println("sEditOrderUid        : "+sEditOrderUid);
        Debug.println("sProductionOrderUid  : "+sProductionOrderUid);
        Debug.println("sEditPrescriptionUid : "+sEditPrescriptionUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String msg = "", sSelectedOperationDescr = "", sSelectedSrcDestType = "",
           sSelectedSrcDestUid = "", sSelectedSrcDestName = "", sSelectedOperationDate = "",
           sSelectedProductName = "", sSelectedUnitsChanged = "", sSelectedProductStockUid = "";

    // display options
    boolean displayEditFields = true;
    
    // default description
    if(sEditOperationDescr.length()==0){
        sEditOperationDescr = MedwanQuery.getInstance().getConfigString("defaultMedicationDeliveryType","medicationdelivery.typeb1");
    }

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE (deliver) --------------------------------------------------------------------------
    if (sAction.equals("save") && sEditOperationUid.length() > 0) {
        //*** store 4 of the used values in session for later re-use ***
        String sPrevUsedOperationDescr = checkString((String)session.getAttribute("PrevUsedDeliveryOperationDescr"));
        if(!sPrevUsedOperationDescr.equals(sEditOperationDescr)){
            session.setAttribute("PrevUsedDeliveryOperationDescr",sEditOperationDescr);
        }

        String sPrevUsedSrcDestType = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestType"));
        if(!sPrevUsedSrcDestType.equals(sEditSrcDestType)){
            session.setAttribute("PrevUsedDeliverySrcDestType",sEditSrcDestType);
        }

        String sPrevUsedSrcDestUid = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestUid"));
        if(!sPrevUsedSrcDestUid.equals(sEditSrcDestUid)){
            session.setAttribute("PrevUsedDeliverySrcDestUid",sEditSrcDestUid);
        }

        String sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestName"));
        if(!sPrevUsedSrcDestName.equals(sEditSrcDestName)){
            session.setAttribute("PrevUsedDeliverySrcDestName",sEditSrcDestName);
        }

        String sPrevUsedDocument = checkString((String)session.getAttribute("PrevUsedDocument"));
        if(!sPrevUsedDocument.equals(sEditProductStockDocumentUid)){
            session.setAttribute("PrevUsedDocument",sEditProductStockDocumentUid);
        }

        //*** create product ***
        ProductStockOperation operation = new ProductStockOperation();
        operation.setUid(sEditOperationUid);
        operation.setDescription(sEditOperationDescr);
        operation.setBatchUid(sEditBatchUid);
        operation.setDocumentUID(sEditProductStockDocumentUid);
        operation.setEncounterUID(sEditEncounterUid);
        operation.setOrderUID(sEditOrderUid);
        operation.setProductionOrderUid(sProductionOrderUid);

        // sourceDestination
        ObjectReference sourceDestination = new ObjectReference();
        sourceDestination.setObjectType(sEditSrcDestType);
        sourceDestination.setObjectUid(sEditSrcDestUid);
        operation.setSourceDestination(sourceDestination);
        if(sEditOperationDate.length() > 0){
        	operation.setDate(ScreenHelper.parseDate(sEditOperationDate));
        }
        operation.setProductStockUid(sEditProductStockUid);
        if(sEditUnitsChanged.length() > 0){
        	operation.setUnitsChanged(new Double(sEditUnitsChanged).intValue());
        }
        operation.setUpdateUser(activeUser.userid);
        operation.setPrescriptionUid(sEditPrescriptionUid);
        if(sEditProductStockUid.length() > 0){
        	ProductStock productStock = ProductStock.get(sEditProductStockUid);
        	if(productStock!=null){
        		session.setAttribute("activeServiceStockUid",productStock.getServiceStockUid());
        	}
        }
        String sResult=operation.store();
        if(sResult==null){
        	if(sEditOrderUid.length()>0){
        		//Update the order with the operation data
        		ProductOrder order = ProductOrder.get(sEditOrderUid);
        		if(order!=null){
        			order.setPackagesDelivered(order.getPackagesDelivered()+operation.getUnitsChanged());
        			if(order.getPackagesOrdered()<=order.getPackagesDelivered()){
        				order.setStatus("closed");
        				order.setDateDelivered(new java.util.Date());
        				order.setProcessed(1);
        			}
        			order.store();
        		}
        	}
        	//Now check if a blood product delivery must be registered
        	//We only do this if it has been delivered to a patient
        	if(operation.getSourceDestination().getObjectType().equalsIgnoreCase("patient")){
        		//We need a batch number, otherwise there is no link
        		if(operation.getBatchNumber()!=null && operation.getBatchNumber().length()>0){
        			int nBatchNumber=-1;
        			try{
        				nBatchNumber=Integer.parseInt(operation.getBatchNumber());
        			}
        			catch(Exception r){
        			}
        			if(nBatchNumber>-1){
			        	ProductStock productStock = operation.getProductStock();
			        	if(productStock!=null){
			        		Product product = productStock.getProduct();
			        		if(product!=null && product.getProductSubGroup()!=null && product.getProductSubGroup().toLowerCase().startsWith(MedwanQuery.getInstance().getConfigString("bloodProductsCategory","BP.").toLowerCase())){
			        			//It is a blood product delivery. Register it
			        			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
								PreparedStatement ps = conn.prepareStatement("insert into OC_BLOODDELIVERIES("+
										" OC_BLOODDELIVERY_DATE,"+
										" OC_BLOODDELIVERY_LOCATION,"+
										" OC_BLOODDELIVERY_PATIENTNAME,"+
										" OC_BLOODDELIVERY_PATIENTFIRSTNAME,"+
										" OC_BLOODDELIVERY_PATIENTGENDER,"+
										" OC_BLOODDELIVERY_PATIENTTELEPHONE,"+
										" OC_BLOODDELIVERY_PATIENTADDRESS,"+
										" OC_BLOODDELIVERY_PATIENTDATEOFBIRTH,"+
										" OC_BLOODDELIVERY_POCKETS,"+
										" OC_BLOODDELIVERY_COMMENT,"+
										" OC_BLOODDELIVERY_ID,"+
										" OC_BLOODDELIVERY_USERID,"+
										" OC_BLOODDELIVERY_PRODUCT)"+
										" values(?,?,?,?,?,?,?,?,?,?,?,?,?)"
								);
								ps.setDate(1,new java.sql.Date(operation.getDate().getTime()));
								ps.setString(2,MedwanQuery.getInstance().getConfigString("cntsDefaultLocation","CNTS"));
								String personid = operation.getSourceDestination().getObjectUid();
								AdminPerson person = AdminPerson.getAdminPerson(personid);
								ps.setString(3, person.lastname.toUpperCase());
								ps.setString(4, person.firstname);
								ps.setString(5, person.gender);
								ps.setString(6, person.getActivePrivate().telephone+ " / "+person.getActivePrivate().mobile);
								ps.setString(7, person.getActivePrivate().address);
								java.sql.Date date = null;
								try{
									date = new java.sql.Date(ScreenHelper.parseDate(person.dateOfBirth).getTime());
								}
								catch(Exception t){}
								ps.setDate(8, date);
								ps.setInt(9, operation.getUnitsChanged());
								ps.setString(10, getTran(request,"web","operation",sWebLanguage)+": "+operation.getUid());
								ps.setInt(11, nBatchNumber);
								ps.setInt(12, Integer.parseInt(activeUser.userid));
								ps.setString(13,product.getName());
								ps.execute();
								ps.close();
								conn.close();
			        		}
			        	}
        			}
	        	}
        	}
        	
	        // reload opener to see the change in level
	        %>        
			  <script>
			    if(window.opener.document.getElementById('EditServiceStockUid') && window.opener.document.getElementById('ServiceId')){
			  	  window.opener.location.href = '<c:url value="/"/>main.do?Page=pharmacy/manageProductStocks.jsp&Action=findShowOverview&hideZeroLevel=1&EditServiceStockUid='+window.opener.document.getElementById('EditServiceStockUid').value+'&DisplaySearchFields=false&ServiceId='+window.opener.document.getElementById('ServiceId').value;
			    }
			    else{
			    	window.opener.transactionForm.submit();
			    }
		        window.close();
	          </script>
	        <%
        }
        else {
	        %>
	          <script>
	            alertDialogDirectText('<%=getTranNoLink("web",sResult,sWebLanguage)%>');
	          </script>
	        <%
        	sAction = "showDetailsNew";
        }
    }

    //--- DELIVER MEDICATION ----------------------------------------------------------------------
    if(sAction.equals("deliverMedication")){
        //*** set medication delivery defaults ***

        // reuse description-value from session
        String sPrevUsedOperationDescr = checkString((String)session.getAttribute("PrevUsedDeliveryOperationDescr"));
        if(sEditOperationDescr.length()==0){
	        if(sEditPrescriptionUid.length()==0 && sPrevUsedOperationDescr.length() > 0){
	        	sEditOperationDescr = sPrevUsedOperationDescr;
	        }
	        else{
	        	sEditOperationDescr = MedwanQuery.getInstance().getConfigString("defaultMedicationDeliveryType","medicationdelivery.typeb1"); // default
	        }
        }
        // reuse srcdestType-value from session
        String sPrevUsedSrcDestType = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestType"));
        if(sEditSrcDestType.length()==0){
	        if(sEditPrescriptionUid.length() == 0 && sPrevUsedSrcDestType.length() > 0){
	        	sEditSrcDestType = sPrevUsedSrcDestType;
	        }
	        else{
	        	sEditSrcDestType = sDefaultSrcDestType; // default
	        }
        }
        
        // reuse srcdestUid-value from session
        String sPrevUsedSrcDestUid = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestUid"));
        if(sEditSrcDestUid.length()==0){
	        if(sEditPrescriptionUid.length()==0 && sPrevUsedSrcDestUid.length() > 0) sEditSrcDestUid = sPrevUsedSrcDestUid;
	        else{
	            if(activePatient!=null) sEditSrcDestUid = activePatient.personid; // default
	            else                    sEditSrcDestUid = "";
	        }
        }
        // reuse srcdestUid-value from session
        String sPrevUsedDocument = checkString((String) session.getAttribute("PrevUsedDocument"));
        /*
        if(sEditProductStockDocumentUid.length()==0 && sPrevUsedDocument.length() > 0){
        	sEditProductStockDocumentUid = sPrevUsedDocument;
        }
        if(sEditProductStockDocumentUid.length() > 0){
        	sEditProductStockDocumentUidText = getTran(request,"operationdocumenttypes",OperationDocument.get(sEditProductStockDocumentUid).getType(),sWebLanguage);
        }
		*/
        // reuse srcdestName-value from session
        String sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestName"));
        if(sEditSrcDestName.length()==0 && sEditPrescriptionUid.length() == 0 && sPrevUsedSrcDestName.length() > 0){
            sEditSrcDestName = sPrevUsedSrcDestName;
        }
        else{
            if(activePatient!=null) sEditSrcDestName = activePatient.firstname+" "+activePatient.lastname; // default
            else                    sEditSrcDestName = "";
        }

        sEditOperationDate = ScreenHelper.formatDate(new java.util.Date()); // now
        if(sEditUnitsChanged.length()==0){
            sEditUnitsChanged = "1";
        }

        sAction = "showDetailsNew";
    }
    Debug.println("4");    

    //--- SHOW DETAILS NEW ------------------------------------------------------------------------
    if(sAction.equals("showDetailsNew")){
        sSelectedOperationDescr  = sEditOperationDescr;
        sSelectedUnitsChanged    = sEditUnitsChanged;
        sSelectedSrcDestType     = sEditSrcDestType;
        sSelectedSrcDestUid      = sEditSrcDestUid;
        sSelectedSrcDestName     = sEditSrcDestName;
        sSelectedOperationDate   = sEditOperationDate;

        sSelectedProductStockUid = sEditProductStockUid;
        sSelectedProductName     = sEditProductName;
    }
%>

<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/template.jsp"/>?Page=pharmacy/medication/popups/deliverMedicationPopupAuto.jsp&ts=<%=getTs()%>' onKeyDown="if(enterEvent(event,13)){doDeliver();}" onClick="clearMessage();">
    <%=writeTableHeader("Web.manage","deliverproducts",sWebLanguage,"window.close();")%>
    <input type='hidden' name='ProductionOrderUid' id='ProductionOrderUid' value='<%=sProductionOrderUid %>'/>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- PRODUCT --%>
                    <tr>
                        <td class="admin"><%=getTran(request,"Web","product",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <b><%=sSelectedProductName%></b>
                        </td>
                    </tr>
                    
                    <%-- PHARMACY --%>
                    <tr>
                        <td class="admin"><%=getTran(request,"Web","pharmacy",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2"><table>
                            <%
	                        	int expiredQuantity = 0;
                            	String productStockBatches = "", expiredProductStockBatches = "";
                            	Iterator e = availableProductStocksVector.iterator();
                            	while(e.hasNext()){
                            		ProductStock productStock = (ProductStock)e.next();
                            		if(productStock!=null){
	                            		ServiceStock serviceStock = (ServiceStock)availableProductStocks.get(productStock);
										if(serviceStock!=null && serviceStock.getUid().equalsIgnoreCase((String)session.getAttribute("activeServiceStockUid"))||availableProductStocks.size()==1){
											iMaxStock = productStock.getLevel();
										}
										
	                            		Vector batches = Batch.getBatches(productStock.getUid());
	                        			if(productStockBatches.length() > 0){
	                        				productStockBatches+= "�";
	                        			}
	                        			if(expiredProductStockBatches.length() > 0){
	                        				expiredProductStockBatches+= "�";
	                        			}
	                        			
	                            		out.print("<tr><td><input onclick='totalStock="+(productStock.getLevel()-expiredQuantity)+";setMaxQuantityValue("+(iMaxQuantity<(productStock.getLevel()-expiredQuantity)?iMaxQuantity:(productStock.getLevel()-expiredQuantity))+");showBatches(false);' type='radio' "+(serviceStock.getUid().equalsIgnoreCase((String)session.getAttribute("activeServiceStockUid"))||availableProductStocks.size()==1?"checked":"")+" name='EditProductStockUid' value='"+productStock.getUid()+"'><font "+((productStock.getLevel()-expiredQuantity)<iMaxQuantity?"color='red'>":">")+serviceStock.getName()+" ("+(productStock.getLevel()-expiredQuantity)+")</font></td></tr>");
										
	                            		productStockBatches+= productStock.getUid();
										expiredProductStockBatches+= productStock.getUid();
										int nProductStockBatches=0,nExpiredBatches=0;
//If delivery to patient: first look for personal batches!!!!
										for(int n=0; n<batches.size(); n++){
	                            			Batch batch = (Batch)batches.elementAt(n);
	                            			if(activePatient!=null && batch!=null && batch.getType()!=null && batch.getType().equalsIgnoreCase("production") && batch.getBatchNumber()!=null && batch.getBatchNumber().equalsIgnoreCase(activePatient.personid) && (batch.getEnd()==null || !batch.getEnd().before(new java.util.Date()))){
		                            			if(batch.getEnd()==null || !batch.getEnd().before(new java.util.Date()) || MedwanQuery.getInstance().getConfigInt("enableExpiredProductsDistribution",0)>0){
		                            				if(nProductStockBatches<10){
		                            					productStockBatches+= "$"+batch.getUid()+";"+batch.getBatchNumber()+";"+batch.getLevel()+";"+(batch.getEnd()==null?"":ScreenHelper.stdDateFormat.format(batch.getEnd()))+";"+batch.getComment();
		                            					nProductStockBatches++;
		                            				}
		                            				else{
		                            					break;
		                            				}
		                            			}
		                            			else {
		                            				if(nExpiredBatches<10){
		                            					expiredProductStockBatches+="$"+batch.getUid()+";"+batch.getBatchNumber()+";"+batch.getLevel()+";"+(batch.getEnd()==null?"":ScreenHelper.stdDateFormat.format(batch.getEnd()))+";"+batch.getComment();
		                            				}
		                            				expiredQuantity+= batch.getLevel();
		                            			}
	                            			}
	                            		}
										for(int n=0; n<batches.size(); n++){
	                            			Batch batch = (Batch)batches.elementAt(n);
	                            			if(batch!=null && (batch.getType()==null || !batch.getType().equalsIgnoreCase("production"))){
		                            			if(batch.getEnd()==null || !batch.getEnd().before(new java.util.Date()) || MedwanQuery.getInstance().getConfigInt("enableExpiredProductsDistribution",0)>0){
		                            				if(nProductStockBatches<10){
		                            					productStockBatches+= "$"+batch.getUid()+";"+batch.getBatchNumber()+";"+batch.getLevel()+";"+(batch.getEnd()==null?"":ScreenHelper.stdDateFormat.format(batch.getEnd()))+";"+batch.getComment();
		                            					nProductStockBatches++;
		                            				}
		                            				else{
		                            					break;
		                            				}
		                            			}
		                            			else {
		                            				if(nExpiredBatches<10){
		                            					expiredProductStockBatches+="$"+batch.getUid()+";"+batch.getBatchNumber()+";"+batch.getLevel()+";"+(batch.getEnd()==null?"":ScreenHelper.stdDateFormat.format(batch.getEnd()))+";"+batch.getComment();
		                            				}
		                            				expiredQuantity+= batch.getLevel();
		                            			}
	                            			}
	                            		}
                            		}
                            	}

                            	out.print("<script>var batches='"+productStockBatches+"';</script>");
                            	out.print("<script>var expiredbatches='"+expiredProductStockBatches+"';</script>");
                            	out.print("<script>var expiredquantity="+expiredQuantity+";</script>");
                            %>
                            </table>
                        </td>
                    </tr>
                    
                    <%-- BATCH --%>
                    <tr>
                        <td class="admin"><%=getTran(request,"Web","batch",sWebLanguage)%>&nbsp;*
                        <%
                        	if(MedwanQuery.getInstance().getConfigString("edition").equalsIgnoreCase("bloodbank")){
                        %>
                        	<img src="<c:url value="/_img/icons/icon_person.png"/>" onclick="searchPatientBatches('batchPatientUid')" onmouseout='this.style.cursor = "default";' onmouseover='this.style.cursor = "pointer";'/>
                        	<img src="<c:url value="/_img/icons/icon_default.gif"/>" onclick="searchPatientBatches('')" onmouseout='this.style.cursor = "default";' onmouseover='this.style.cursor = "pointer";'/>
                        	<input type='hidden' name='batchPatientUid' id='batchPatientUid'/>
                        <%
                        	}
                        %>
                        </td>
                        <td class="admin2"><div id="batch" name="batch"/></td>
                    </tr>
                    
					<%
						if(prescription==null){
							%>
			                    <%-- DESCRIPTION --%>
			                    <tr>
			                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","description",sWebLanguage)%>&nbsp;*</td>
			                        <td class="admin2">
			                        	<%=getTran(request,"productstockoperation.medicationdelivery",sSelectedOperationDescr,sWebLanguage) %>
			                            <input type='hidden' name="EditOperationDescr" id="EditOperationDescr" value="<%=sSelectedOperationDescr%>">
			                        </td>
			                    </tr>
			                <%
						}
						else{
	                		%><input type="hidden" name="EditOperationDescr" value="<%=sSelectedOperationDescr%>"><%
						}
	                %>
	                
                    <%-- UNITS CHANGED --%>
                    <tr>
                        <td class="admin"><%=getTran(request,"Web","unitschanged",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditUnitsChanged" id="EditUnitsChanged" size="10" maxLength="10" value="<%=sSelectedUnitsChanged%>" onKeyUp="if(this.value=='0'){this.value='';}isNumber(this);setMaxQuantityValue(setMaxQuantity);" onblur="validateMaxFocus(this);" <%=(sAction.equals("showDetails")?"READONLY":"")%>><span id="maxquantity" name="maxquantity"/>
                        </td>
                    </tr>
                    
					<%
						if(prescription==null){
							%>			                    
		                    	<input type='hidden' class='text' name='EditProductStockDocumentUid' id='EditProductStockDocumentUid' size='10' value="<%=sEditProductStockDocumentUid %>" readonly/>
			                    <input type='hidden' name="EditSrcDestType" id="EditSrcDestType" value="servicestock"/>
                                <input type="hidden" name="EditSrcDestUid" id="EditSrcDestUid" value="<%=sEditSrcDestUid%>">
                                <input type="hidden" name="EditSrcDestName" id="EditSrcDestName" value="<%=sSelectedSrcDestName%>" >
                                <input type="hidden" name="EditOrderUid" id="EditOrderUid" value="<%=sEditOrderUid%>" >
			                    <%-- SOURCE DESTINATION TYPE --%>
			                    <tr height="23" id='destinationline'>
			                        <td class="admin" id='id1'><%=getTran(request,"web","deliveredto",sWebLanguage)%>&nbsp;*</td>
			                        <td class="admin2">
			                        	<%
			                        		ServiceStock stock = ServiceStock.get(sEditSrcDestUid);
			                        		if(stock!=null){
			                        			out.println(stock.getName());
			                        		}
											
										%>
			                            <%-- SOURCE DESTINATION SELECTOR --%>
			                            <span id="SrcDestSelector" style="visibility:hidden;">
			                                <span id="SearchSrcDestButtonDiv"><%-- filled by JS below --%></span>
			                            </span>
			                        </td>
			                    </tr>
						        
			                    <%-- OPERATION DATE --%>
			                    <tr>
			                        <td class="admin"><%=getTran(request,"Web","date",sWebLanguage)%>&nbsp;*</td>
			                        <td class="admin2"><%=writeDateField("EditOperationDate","transactionForm",sSelectedOperationDate,sWebLanguage)%></td>
			                    </tr>
			                    
			                    <%-- ENCOUNTER --%>
						        <tr id='encounterline'>
						            <td class='admin'><%=getTran(request,"web","encounter",sWebLanguage)%>&nbsp;*</td>
						            <td class='admin2'>
						                <input type="hidden" name="EditEncounterUID" id="EditEncounterUID" value="<%=sEditEncounterUid%>">
						                <%
							                Encounter encounter = Encounter.get(sEditEncounterUid);
											String sEditEncounterName = "";
							                if(encounter!=null && encounter.getEncounterDisplayName(sWebLanguage)!=null && encounter.getEncounterDisplayName(sWebLanguage).indexOf("null")==-1 ){
							                    sEditEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
							                }		
						                %>
						                <input class="text" type="text" name="EditEncounterName" id="EditEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterName%>">
						                
						                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditEncounterUID','EditEncounterName');">
						                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditEncounterUID').value='';document.getElementById('EditForm.EditEncounterName').value='';">
						            </td>
						        </tr>
			                    
			                    <%-- PRESCRIPTION --%>
			                    <tr id='prescriptionline'>
			                        <td class="admin" width="20%"><%=getTran(request,"Web","prescriptionid",sWebLanguage)%></td>
			                        <td class="admin2">
			                            <input class="text" type="text" name="EditPrescriptionUid" size="60" maxLength="60" value="<%=sEditPrescriptionUid%>" <%=(sAction.equals("showDetails")?"READONLY":"")%>>
			                        </td>
			                    </tr>	                    
			                <%
						}
						else{
							// prescription specified
	                        %>
	                            <input type="hidden" name="EditSrcDestType" id="EditSrcDestType" value="<%=sSelectedSrcDestType%>">
	                            <input type="hidden" name="EditSrcDestName" id="EditSrcDestName" value="<%=sSelectedSrcDestName%>">
	                            <input type="hidden" name="EditSrcDestUid" id="EditSrcDestUid" value="<%=sSelectedSrcDestUid%>">
	                            <input type="hidden" name="EditPrescriptionUid" id="EditPrescriptionUid" value="<%=sEditPrescriptionUid%>">
	                        <%
						}
						Debug.println("8");    

                        // get previous used values to reuse in javascript
                        String sPrevUsedSrcDestUid  = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestUid")),
                               sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestName"));
                        
                        String supplierCode = "";
                        if(sPrevUsedSrcDestUid.length()==0){
                            if(sSelectedProductStockUid.length() > 0){
                               	ProductStock productStock = ProductStock.get(sSelectedProductStockUid);
                               	
                                // get supplier service from product
                                if(productStock!=null){
                                    supplierCode = checkString(productStock.getProduct().getSupplierUid());
                                }

                                // get default-supplier from serviceStock if not specified in product
                                if(supplierCode.length()==0){
                                    supplierCode = checkString(productStock.getServiceStock().getDefaultSupplierUid());
                                }
                            }
                        }
                    %>
                </table>
                    
                <script>
                  var prevSrcDestType;

                  <%-- VALIDATE MAX FOCUS --%>
                  function validateMaxFocus(o){
                    if(o.value*1>setMaxQuantity){
                      alertDialogDirectText('<%=getTran(null,"web","maxvalueis",sWebLanguage)%> '+setMaxQuantity);
                      o.focus();
                      return false;
                    }
                    return true;
                  }

                  <%-- VALIDATE MAX --%>
                  function validateMax(o){
                    if(o.value*1>setMaxQuantity){
                      alertDialogDirectText('<%=getTran(null,"web","maxvalueis",sWebLanguage)%> '+setMaxQuantity);
                      return false;
                    }
                    return true;
                  }

                  <%-- DISPLAY SOURCE DESTINATION SELECTOR --%>
                  function displaySrcDestSelector(){
                    var srcDestType, emptyEditSrcDest, srcDestUid, srcDestName;
					document.getElementById('prescriptionline').style.visibility = "hidden";
						
					// For specific EditOperationDescr values, an EditSrcDestType value may be forced
					if('<%=MedwanQuery.getInstance().getConfigString("forceservicestockforproductstockoperations","medicationdelivery.2")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1){
					  transactionForm.EditSrcDestType.value='servicestock';
					}
					if('<%=MedwanQuery.getInstance().getConfigString("forcepatientforproductstockoperations","medicationdelivery.1")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1){
					  transactionForm.EditSrcDestType.value='patient';
					}
						
					if('<%=MedwanQuery.getInstance().getConfigString("productstockoperationswithoutdestination","medicationdelivery.3;medicationdelivery.4;medicationdelivery.5;medicationdelivery.99;")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1){
					  document.getElementById('destinationline').style.visibility = "hidden";
					  document.getElementById('EditProductStockDocumentUid').value = '';
					  
					  transactionForm.EditSrcDestType.value = "";
					  transactionForm.EditSrcDestUid.value = "";
					  transactionForm.EditSrcDestName.value = "";
					}
					else{
					  document.getElementById('destinationline').style.visibility = "visible";
					}
						
                    srcDestType = transactionForm.EditSrcDestType.value;
                    if(srcDestType.length > 0){
                      document.getElementById('SrcDestSelector').style.visibility = 'visible';

                      <%-- medic --%>
                      if(srcDestType.indexOf('user') > -1){
                        document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icons/icon_search.png"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchDoctor('EditSrcDestUid','EditSrcDestName');\">&nbsp;"+
                                                                                      "<img src='<c:url value="/_img/icons/icon_delete.png"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">";
	                    document.getElementById('prescriptionline').style.visibility = "hidden";
						document.getElementById('EditProductStockDocumentUid').value = '';
						document.getElementById('encounterline').style.visibility = "hidden";
						document.getElementById('EditProductStockEncounterUid').value = '';
 
						if('<%=sPrevUsedSrcDestUid%>'.length > 0){
                          transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
                          transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
                        }
                        else{
                          transactionForm.EditSrcDestUid.value = "<%=activeUser.userid%>";
                          transactionForm.EditSrcDestName.value = "<%=activeUser.person.firstname+" "+activeUser.person.lastname%>";
                        }
                      }
                      <%-- patient --%>
                      else if(srcDestType.indexOf('patient') > -1){
                        document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icons/icon_search.png"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchPatient('EditSrcDestUid','EditSrcDestName');\">&nbsp;"+
                                                                                      "<img src='<c:url value="/_img/icons/icon_delete.png"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">";
                        document.getElementById('prescriptionline').style.visibility = "visible";
						document.getElementById('EditProductStockDocumentUid').value = '';
						document.getElementById('encounterline').style.visibility = "visible";

                        if('<%=sEditSrcDestName%>'.length == 0 && '<%=sPrevUsedSrcDestUid%>'.length > 0){
                          transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
                          transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
                        }
                        else{
                          <%
                            if(activePatient!=null){
                              %>
                                transactionForm.EditSrcDestUid.value = "<%=activePatient.personid%>";
                                transactionForm.EditSrcDestName.value = "<%=activePatient.firstname+" "+activePatient.lastname%>";
                              <%
                            }
                            else{
                              %>
                                transactionForm.EditSrcDestUid.value = "";
                                transactionForm.EditSrcDestName.value = "";
                              <%
                            }
                          %>
                        }
                            
						// Here we have to set the patient encounter when it is active
						setPatientEncounter();
                      }
                      <%-- service --%>
                      else if(srcDestType.indexOf('servicestock') > -1 && '<%=MedwanQuery.getInstance().getConfigString("productstockoperationswithoutdestination","")%>'.indexOf(document.getElementById('EditOperationDescr').value)==-1){
						document.getElementById('encounterline').style.visibility = "hidden";
								
						<%
							if(MedwanQuery.getInstance().getConfigInt("productstockoperationdocumentmandatory",1)!=1){
							    %>
			                      document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icons/icon_search.png"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchService('EditSrcDestUid','EditSrcDestName');\">&nbsp;"+
	        		                                                                            "<img src='<c:url value="/_img/icons/icon_delete.png"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">";
	        		                                                                              
			                      if('<%=sPrevUsedSrcDestUid%>'.length > 0){
			                        transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
			                        transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
			                      }
			                      else if('<%=supplierCode%>'.length > 0){
		                            transactionForm.EditSrcDestUid.value = "<%=supplierCode%>";
		                            transactionForm.EditSrcDestName.value = "<%=getTranNoLink("service",supplierCode,sWebLanguage)%>";
		                          }
		                          else if('"<%=centralPharmacyCode%>"'.length > 0){
		                            transactionForm.EditSrcDestUid.value = "<%=centralPharmacyCode%>";
		                            transactionForm.EditSrcDestName.value = "<%=getTranNoLink("service",centralPharmacyCode,sWebLanguage)%>";
		                          }
		                          else{
		                            transactionForm.EditSrcDestUid.value = "";
		                            transactionForm.EditSrcDestName.value = "";
		                          }
		                        <%
							}
							else{
								// productstockoperationdocumentmandatory == 1
								sPrevUsedSrcDestUid = "";
								sPrevUsedSrcDestName = "";
								
								if(sEditProductStockDocumentUid.length() > 0){
									OperationDocument document = OperationDocument.get(sEditProductStockDocumentUid);
									if(document!=null){
										sPrevUsedSrcDestUid=document.getDestinationuid();
										if(sPrevUsedSrcDestUid.length() > 0){
											sPrevUsedSrcDestName = document.getDestination().getName();
										}
									}
								}
									
	                            %>
								  document.getElementById('SearchSrcDestButtonDiv').innerHTML = "";
								  
								  if(document.getElementById('EditProductStockDocumentUid').value.length==0){
								  }
								  else{
			                        transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
			                        transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
								  }
		                        <%
							}
                        %>
                      }
                    }
                    else{
                      transactionForm.EditSrcDestType.value = "<%=sDefaultSrcDestType%>";
					  document.getElementById('encounterline').style.visibility="hidden";
                      document.getElementById('SrcDestSelector').style.visibility = 'hidden';
                    }
                        
					if(document.getElementById('EditOperationDescr').value=='<%=MedwanQuery.getInstance().getConfigString("productstockoperationexpireddrugsevacuation","medicationdelivery.4")%>'){
					  showBatches(true);
					}
					else{
					  showBatches(false);
					}
						
				    prevSrcDestType = srcDestType;
                  }
                </script>
                
                <%-- indication of obligated fields --%>
                <%=getTran(request,"Web","colored_fields_are_obligate",sWebLanguage)%>

                <%-- display message --%>
                <br><span id="msgArea"><%=msg%></span>
                
                <%-- EDIT BUTTONS --%>
                <%=ScreenHelper.alignButtonsStart()%>
                    <%
                        if(sAction.equals("showDetailsNew") && availableProductStocks.size()>0 ){
                            %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","deliver",sWebLanguage)%>' onclick="doDeliver();"><%
                        }
                    %>
                    <input type="button" class="button" name="closeButton" value='<%=getTranNoLink("Web","close",sWebLanguage)%>' onclick='window.close();'>
                <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    %>
    
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditOperationUid" value="<%=sEditOperationUid%>">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
	var setMaxQuantity=<%=iMaxQuantity%>;
	var totalStock=<%=iMaxStock%>;
	window.resizeTo(700,370);

  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditOperationDescr.focus();<%
      }
  %>

  <%-- DO DELIVER --%>
  function doDeliver(){
    transactionForm.EditOperationUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
	 // alert(document.getElementById("EditSrcDestUid").value);
    if(checkStockFields() && validateMax(transactionForm.EditUnitsChanged)){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditOperationDescr.value.length==0){
        transactionForm.EditOperationDescr.focus();
      }
      else if(transactionForm.EditUnitsChanged.value.length==0){
        transactionForm.EditUnitsChanged.focus();
      }
      else if(<%=MedwanQuery.getInstance().getConfigInt("productstockoperationdocumentmandatory",1)%>==1){
        if(document.getElementById("EditProductStockDocumentUid").value.length==0){
          document.getElementById("EditProductStockDocumentUid").focus();
        }
      }
      else if(transactionForm.EditSrcDestType.value.length==0 && document.getElementById('destinationline').style.visibility!="hidden"){
        transactionForm.EditSrcDestType.focus();
      }
      else if(transactionForm.EditSrcDestUid.value.length==0){
        transactionForm.EditSrcDestName.focus();
      }
      else if(transactionForm.EditOperationDate.value.length==0){
        transactionForm.EditOperationDate.focus();
      }
      else if(transactionForm.EditEncounterName.value.length==0 && document.getElementById('encounterline').style.visibility!="hidden"){
        transactionForm.EditEncounterName.focus();
      }
    }
  }

  <%-- CHECK PRODUCT FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;
    
    <%-- required fields --%>
    var productStockChecked=transactionForm.EditProductStockUid.checked;
    for(i=0;i<transactionForm.EditProductStockUid.length; i++){
      if(transactionForm.EditProductStockUid[i].checked){
      	productStockChecked = true;
      }
    }
    if(maySubmit==true){
      if(transactionForm.EditOperationDescr.value.length==0 ||
         transactionForm.EditUnitsChanged.value.length==0 ||
         transactionForm.EditOperationDate.value.length==0 ||
         !productStockChecked){
        maySubmit = false;
      }
    }
    
    if(maySubmit==true){
      if(transactionForm.EditSrcDestType.value.indexOf("patient")>-1 && transactionForm.EditEncounterUID.value.length==0){
        maySubmit = false;
      }
    }


    if(maySubmit==true){
      if(transactionForm.EditSrcDestType.value=='servicestock' && transactionForm.EditSrcDestUid.value.length==0){
        //maySubmit = false;
      }
    }

    if(maySubmit==true){
      if(!(transactionForm.EditSrcDestType.style.visibility='hidden' || transactionForm.EditSrcDestType.value.indexOf("patient")<0 || transactionForm.EditEncounterName.value.length>0)){
        maySubmit = false;
      }
    }

    if(maySubmit==true){
      if(!(transactionForm.EditSrcDestType.style.visibility='hidden' || transactionForm.EditSrcDestType.value.length>0 || '<%=MedwanQuery.getInstance().getConfigString("productstockoperationswithoutdestination","medicationdelivery.3*medicationdelivery.4*medicationdelivery.5")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1)){
        maySubmit = false;
      }
    }
    	     
    if(maySubmit==false){
                alertDialog("web.manage","dataMissing");
    }

    return maySubmit;
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditOperationDescr.value = "";
    transactionForm.EditUnitsChanged.value = "";
    transactionForm.EditSrcDestName.value = "";
    transactionForm.EditOperationDate.value = "";
    transactionForm.EditProductStockUid.value = "";
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    <%
	    String excludeServiceUid = "";
	  	if(sEditProductStockUid.length() > 0){
	  	    ProductStock productStock = ProductStock.get(sEditProductStockUid);
	  	    if(productStock!=null){
	  	        excludeServiceUid = productStock.getServiceStockUid();
	  	    }
	  	}
    %>
    openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField="+serviceUidField+"&ReturnServiceStockNameField="+serviceNameField+"&ExcludeServiceStockUid=<%=excludeServiceUid%>");
  }

  <%-- popup : search patient --%>
  function searchPatient(patientUidField,patientNameField){
    openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+patientUidField+"&ReturnName="+patientNameField+"&ReturnFunction=setPatientEncounter()&displayImmatNew=no&isUser=no");
  }

  <%-- popup : search doctor --%>
  function searchDoctor(doctorUidField,doctorNameField){
	    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+doctorUidField+"&ReturnName="+doctorNameField+"&displayImmatNew=no");
	  }

  function searchPatientBatches(patientUidField){
	 if(patientUidField && patientUidField.length>0){
		 openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+patientUidField+"&ReturnFunction=findPatientBatches()&displayImmatNew=no&isUser=no");
	 }
	 else {
		 document.getElementById("batchPatientUid").value="";
		 findPatientBatches();
	 }
  }

  function findPatientBatches(){
      var params = 'personid='+document.getElementById("batchPatientUid").value+"&productstockuid=<%=sEditProductStockUid%>";
      var url = '<c:url value="/pharmacy/getPatientBatches.jsp"/>?ts='+new Date();
      new Ajax.Request(url,{
	  	method: "GET",
        parameters: params,
        onSuccess: function(resp){
          var label = eval('('+resp.responseText+')');
          batches = label.batches;
          showBatches(false);
        }
      });
  }
  
  <%-- popup : search document --%>
  function searchDocument(documentUidField,documentUidTextField){
	<%
		String sDocumentSource = "";
		String sDocumentSourceText = "";
		String sFindMinDate = "";
		ProductStock productStock = ProductStock.get(sEditProductStockUid);
		if(productStock!=null && productStock.getServiceStockUid()!=null){
			sDocumentSource = productStock.getServiceStockUid();
			sDocumentSourceText = productStock.getServiceStock().getName();
			sFindMinDate = ScreenHelper.stdDateFormat.format(new java.util.Date().getTime()-7*24*3600*1000);
		}		
	%>
	
    openPopup("/_common/search/searchStockOperationDocument.jsp&ts=<%=getTs()%>"+
    		  "&documentuid="+document.getElementById("EditProductStockDocumentUid").value+
    		  "&finddocumentsource=<%=sDocumentSource%>"+
    		  "&finddocumentmindate=<%=sFindMinDate%>"+
    		  "&finddocumentsourcetext=<%=sDocumentSourceText%>"+
    		  "&ReturnDocumentID="+documentUidField+
    		  "&ReturnDocumentName="+documentUidTextField+
    		  "&ReturnDestinationID=EditSrcDestUid"+
    		  "&ReturnDestinationName=EditSrcDestName");
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- SHOW BATCHES --%>
  function showBatches(expired){
	var remainingQuantity = totalStock;
    var ih = "<table>";
    var productStockUid = "";
	if(transactionForm.EditProductStockUid.checked){
	  productStockUid = transactionForm.EditProductStockUid.value;
	}
	else{
	  for(i=0; i<transactionForm.EditProductStockUid.length; i++){
	    if(transactionForm.EditProductStockUid[i].checked){
	      productStockUid = transactionForm.EditProductStockUid[i].value;
	    }
	  }
	}
	
	var bFound = false;
	if(productStockUid.length>0 && !expired){
	  var b = batches.split("�");
	  for(n=0; n<b.length; n++){
	    var c = b[n].split("$");
		if(c[0]==productStockUid){
	  	  for(q=1; q<c.length; q++){
  		    var d = c[q].split(";");
			ih+= "<tr><td><input onclick='setMaxQuantityValue("+d[2]+");' type='radio' name='EditBatchUid' value='"+d[0]+"' ";
			if(q==1){
			  bFound = true;
			  ih+= "checked";
			  setMaxQuantityValue(d[2]);
			}
			if(document.getElementById("EditUnitsChanged").value*1>d[2]*1){
			  ih+= " />"+d[1]+" (<font color='red'><b>"+d[2]+"</b></font> - exp. "+d[3]+") <i>"+d[4]+"</i><br/>";
			}
			else{
			  ih+= " />"+d[1]+" ("+d[2]+" - exp. "+d[3]+") <i>"+d[4]+"</i></td></tr>";
			}
			remainingQuantity-= d[2];
		  }
		}
      } 
	  remainingQuantity-= expiredquantity;
	  
	  if(document.getElementById("batchPatientUid") && document.getElementById("batchPatientUid").value.length>0){
		  remainingQuantity=0;
	  }
	  if(remainingQuantity > 0){
	    ih+= "<tr><td><input onclick='setMaxQuantityValue("+remainingQuantity+");' type='radio' name='EditBatchUid' value=''";
		if(!bFound){
	      ih+= "checked";
		  setMaxQuantityValue(remainingQuantity);
		}
		ih+=" />? ("+remainingQuantity+")";
	  }
    }
    else if(productStockUid.length>0 && expired){
	  var b = expiredbatches.split("�");
	  for(n=0; n<b.length; n++){
		var c = b[n].split("$");
		if(c[0]==productStockUid){
		  for(q=1; q<c.length; q++){
			var d = c[q].split(";");
			ih+= "<input onclick='setMaxQuantityValue("+d[2]+");' type='radio' name='EditBatchUid' value='"+d[0]+"' ";
			if(q==1){
			  bFound = true;
			  ih+= "checked";
			  setMaxQuantityValue(d[2]);
			}
			
			if(document.getElementById("EditUnitsChanged").value*1>d[2]*1){
			  ih+=" />"+d[1]+" (<font color='red'><b>"+d[2]+"</b></font> - exp. "+d[3]+") <i>"+d[4]+"</i><br/>";
			}
			else{
			  ih+=" />"+d[1]+" ("+d[2]+" - exp. "+d[3]+") <i>"+d[4]+"</i></td></tr>";
			}
			
			remainingQuantity-= d[2];
		  }
		}
	  } 
    }
	ih+="</table>"
    document.getElementById("batch").innerHTML = ih;
  }

  <%-- SET MAX QUANTITY VALUE --%>
  function setMaxQuantityValue(mq){
    setMaxQuantity = mq;
    if(document.getElementById("EditUnitsChanged").value*1>setMaxQuantity*1){
      document.getElementById("maxquantity").innerHTML = " <img src='<c:url value="/_img/icons/icon_warning.gif"/>'/> <font color='red'><b> &gt;"+setMaxQuantity+"</b></font>";
    }
    else{
      document.getElementById("maxquantity").innerHTML = "";
    }
  }
    
  <%-- SET PATIENT ENCOUNTER --%>
  function setPatientEncounter(){
   	if(document.getElementById("EditSrcDestUid").value.length>0){
      var params = 'personid='+document.getElementById("EditSrcDestUid").value;
      var url = '<c:url value="/pharmacy/getActivePatientEncounter.jsp"/>?ts='+new Date();
      new Ajax.Request(url,{
	  	method: "GET",
        parameters: params,
        onSuccess: function(resp){
          var label = eval('('+resp.responseText+')');
          $('EditEncounterUID').value = label.EncounterUid;
          $('EditEncounterName').value = label.EncounterName;
        }
      });
    }
  }

  <%-- SEARCH ENCOUNTER --%>
  function searchEncounter(encounterUidField,encounterNameField){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+
    		  "&FindEncounterPatient="+document.getElementById("EditSrcDestUid").value);
  }

  displaySrcDestSelector();
</script>