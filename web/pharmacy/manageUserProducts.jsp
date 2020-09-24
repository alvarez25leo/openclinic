<%@page import="be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.UserProduct,
                java.util.Vector,
                java.util.Collections" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission(out,"pharmacy.manageuserproducts","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage){
        StringBuffer html = new StringBuffer();
        String sClass = "1", sUnit = "", sUnitPrice = "", sSupplierUid, sSupplierName = "",
               sProductGroup = "", sProductStockUid, sProductName;
        DecimalFormat deci = new DecimalFormat("0.00");
        UserProduct userProduct;
        Product product;
        double dUnitPrice;

        // frequently used translations
        String deleteTran = getTranNoLink("Web","delete",sWebLanguage);
        String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","�");

        // run thru objects
        for(int i=0; i<objects.size(); i++){
            userProduct = (UserProduct)objects.get(i);
            product = userProduct.getProduct();

            if(product!=null){
                sProductName = product.getName();

                // translate unit
                sUnit = checkString(product.getUnit());
                if(sUnit.length() > 0){
                    sUnit = getTran(null,"product.unit",sUnit,sWebLanguage);
                }

                // line unit price out
                sUnitPrice = product.getUnitPrice()+"";
                if(sUnitPrice.length() > 0){
                    dUnitPrice = Double.parseDouble(sUnitPrice);
                    sUnitPrice = deci.format(dUnitPrice);
                }

                //*** supplier ***
                sProductStockUid = checkString(userProduct.getProductStockUid());

                if(sProductStockUid.length() > 0){
                    // processing product from product-catalog, productStock available
                    sSupplierUid = checkString(product.getSupplierUid());
                    if(sSupplierUid.length() > 0){
                        sSupplierName = getTran(null,"service",sSupplierUid,sWebLanguage);
                    }
                    else{
                        sSupplierUid = checkString(product.getSupplierUid());
                        if(sSupplierUid.length() > 0){
                            sSupplierName = getTran(null,"service",sSupplierUid,sWebLanguage);
                        }
                        else{
                            sSupplierUid = checkString(userProduct.getProductStock().getServiceStock().getDefaultSupplierUid());
                            if(sSupplierUid.length() > 0){
                                sSupplierName = getTran(null,"service",sSupplierUid,sWebLanguage);
                            }
                            else{
                                sSupplierName = "";
                            }
                        }
                    }
                }
                else{
                    // processing product from product-catalog, NO productStock available
                    sSupplierUid = checkString(product.getSupplierUid());
                    if(sSupplierUid.length() > 0){
                        sSupplierName = getTran(null,"service",sSupplierUid,sWebLanguage);
                    }
                    else{
                        sSupplierName = "";
                    }
                }

                // product group
                sProductGroup = checkString(product.getProductGroup());
                if(sProductGroup.length() > 0){
                    sProductGroup = getTran(null,"product.productgroup",sProductGroup,sWebLanguage);
                }
            }
            else{
                sProductName = "<font color='red'>"+getTran(null,"web.manage","unexistingproduct",sWebLanguage)+"</font>";
            }

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            //*** display product in one row ***
            html.append("<tr class='list"+sClass+"' >")
                 .append("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' class='link' title='"+deleteTran+"' onclick=\"doDeleteProduct('"+userProduct.getProductUid()+"');\">&nbsp;</td>")
                 .append("<td>"+sProductName+"</td>")
                 .append("<td>"+sUnit+"</td>")
                 .append("<td style='text-align:right;'>"+sUnitPrice+"&nbsp;"+sCurrency+"&nbsp;</td>")
                 .append("<td>"+sSupplierName+"</td>")
                 .append("<td>"+(userProduct.getProductStock()==null?"":userProduct.getProductStock().getServiceStock().getName())+"</td>")
                 .append("<td>"+sProductGroup+"</td>")
                .append("</tr>");
        }

        return html;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "find"; // display all userproducts by default

    // retreive form data
    String sEditProductUid      = checkString(request.getParameter("EditProductUid")),
           sEditProductName     = checkString(request.getParameter("EditProductName")),
           sEditProductStockUid = checkString(request.getParameter("EditProductStockUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** pharmacy/manageUserProducts.jsp ******************");
        Debug.println("sAction              : "+sAction);
        Debug.println("sEditProductUid      : "+sEditProductUid);
        Debug.println("sEditProductName     : "+sEditProductName);
        Debug.println("sEditProductStockUid : "+sEditProductStockUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String saveMsg = "", searchMsg = "", sSelectedProductName = "", sSelectedProductUid = "",
           sSelectedProductStockUid = "";
    int foundProductCount = 0;
    StringBuffer userProductsHtml = null;


    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditProductUid.length() > 0){
        // create new userProduct
        UserProduct userProduct = new UserProduct();
        userProduct.setUserId(activeUser.userid);
        userProduct.setProductUid(sEditProductUid);
        userProduct.setProductStockUid(sEditProductStockUid);

        // does userProduct exist ?
        String existingUserProductUid = userProduct.exists();
        boolean userProductExists = existingUserProductUid.length() > 0;

        //***** update existing product *****
        if(!userProductExists){
            userProduct.store(false);

            // show saved data
            sAction = "findShowOverview";
            saveMsg = getTran(request,"web","dataissaved",sWebLanguage);
        }
        else {
            // store anyway, to update productStockUid that might not be saved yet.
            userProduct.store();

            // display product exists-message
            sAction = "findShowOverview";
            saveMsg = getTran(request,"web.manage","productexists",sWebLanguage);

            sSelectedProductUid = sEditProductUid;
            sSelectedProductName = sEditProductName;
            sSelectedProductStockUid = sEditProductStockUid;
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditProductUid.length() > 0){
        UserProduct.delete(activeUser.userid,sEditProductUid);

        saveMsg = getTran(request,"web","dataisdeleted",sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //-- FIND -------------------------------------------------------------------------------------
    if(sAction.startsWith("find")){
        Vector userProducts = UserProduct.find(activeUser.userid);
        Collections.sort(userProducts);
        userProductsHtml = objectsToHtml(userProducts,sWebLanguage);
        foundProductCount = userProducts.size();
    }
%>

<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doAddProduct();return false;}" onClick="clearMessage();">
    <%=writeTableHeader("web.manage","manageUserProducts",sWebLanguage,"")%>
    
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(foundProductCount > 0){            
            %>
                <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                    <%-- header --%>
                    <tr class="admin">
                        <td width="30"/>
                        <td width="25%"><%=getTran(request,"Web","productName",sWebLanguage)%></td>
                        <td width="10%"><%=getTran(request,"Web","Unit",sWebLanguage)%></td>
                        <td width="10%" style="text-align:right;"><%=getTran(request,"Web","unitprice",sWebLanguage)%>&nbsp;</td>
                        <td width="20%"><%=getTran(request,"Web","supplier",sWebLanguage)%></td>
                        <td width="20%"><%=getTran(request,"Web","ServiceStock",sWebLanguage)%></td>
                        <td width="15%"><%=getTran(request,"Web","productGroup",sWebLanguage)%></td>
                    </tr>
                    <%=userProductsHtml%>
                </table>
                
                <%-- number of records found --%>
                <span style="width:49%;text-align:left;">
                    <%=foundProductCount%> <%=getTran(request,"web","recordsfound",sWebLanguage)%>
                </span>
                
                <%
                    if(foundProductCount > 20){
                        // link to top of page
                        %>
                            <span style="width:51%;text-align:right;">
                                <a href="#topp" class="topbutton">&nbsp;</a>
                            </span>
                            <br>
                        <%
                    }
                %>
                <br><br>
            <%
        }
        else{
            // no records found
            %><%=getTran(request,"web","norecordsfound",sWebLanguage)%><br><br><%
        }
    %>
    
    <%-- ADD PRODUCT FIELD ----------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1">
        <%-- sub-title --%>
        <tr class="admin">
            <td colspan="2">&nbsp;&nbsp;<%=getTran(request,"web.manage","AddUserProducts",sWebLanguage)%></td>
        </tr>
        
        <%-- product --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran(request,"Web","product",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="EditProductUid" value="<%=sSelectedProductUid%>">
                <input type="hidden" name="EditProductStockUid" value="<%=sSelectedProductStockUid%>">
                <input class="text" type="text" name="EditProductName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">

                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProductInServiceStock('EditProductUid','EditProductName','','','','EditProductStockUid');">
                <img src="<c:url value="/_img/icons/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="doAddProduct();">
            </td>
        </tr>
    </table>
    
    <%-- display message --%>
    <span id="saveMsgArea"><%=saveMsg%></span>
    
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%-- DO ADD PRODUCT --%>
  function doAddProduct(){
    if(checkProductFields()){
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      transactionForm.EditProductName.focus();
    }
  }

  <%-- CHECK PRODUCT FIELDS --%>
  function checkProductFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditProductUid.value.length>0 || !transactionForm.EditProductName.value.length>0){
      maySubmit = false;
      alertDialog("web.manage","dataMissing");
    }

    return maySubmit;
  }

  <%-- DO DELETE PRODUCT --%>
  function doDeleteProduct(productUid){
    if(yesnoDeleteDialog()){
      transactionForm.EditProductUid.value = productUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditProductUid.value = "";
    transactionForm.EditProductName.value = "";
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(searchMsg.length() > 0){
            %>document.getElementById('searchMsgArea').innerHTML = "";<%
        }

        if(saveMsg.length() > 0){
            %>document.getElementById('saveMsgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value="/main.do"/>?Page=pharmacy/manageUserProducts.jsp&ts=<%=getTs()%>";
  }

  <%-- popup : search product in service stock --%>
  function searchProductInServiceStock(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField){
    var url = "/_common/search/searchProductInStock.jsp&ts=<%=getTs()%>"+
              "&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField+
              "&DisplaySearchUserProductsLink=false"+
              "&DisplayProductsOfDoctorService=true"+
              "&DisplayProductsOfPatientService=false";

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    openPopup(url);
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>"+
              "&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField+
              "&DisplaySearchProductInStockLink=true"+
              "&DisplaySearchUserProductsLink=false";

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    openPopup(url);
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>