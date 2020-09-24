<%@page import="be.openclinic.pharmacy.Product,
                be.openclinic.pharmacy.ServiceStock,
                be.openclinic.pharmacy.ProductStock,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));

    // get data from form
    String sSearchStockLevel   = checkString(request.getParameter("SearchStockLevel")),
           sSearchProductUid   = checkString(request.getParameter("SearchProductUid")),
           sSearchProductName  = checkString(request.getParameter("SearchProductName")),
           sSearchServiceUid   = checkString(request.getParameter("SearchServiceUid")),
           sSearchProductLevel = checkString(request.getParameter("SearchProductLevel")),
           sSearchServiceName  = checkString(request.getParameter("SearchServiceName"));

    // get data from calling url or hidden fields in form
    String sReturnProductStockUidField   = checkString(request.getParameter("ReturnProductStockUidField")),
           sReturnProductStockNameField  = checkString(request.getParameter("ReturnProductStockNameField")),
           sReturnServiceStockUidField   = checkString(request.getParameter("ReturnServiceStockUidField")),
           sReturnServiceStockNameField  = checkString(request.getParameter("ReturnServiceStockNameField")),
           sReturnProductStockLevelField = checkString(request.getParameter("ReturnProductStockLevelField"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******** _common/search/searchByAjax/searchProductStockShow.jsp ********");
        Debug.println("sAction            : "+sAction);
        Debug.println("sSearchStockLevel  : "+sSearchStockLevel);
        Debug.println("sSearchProductUid  : "+sSearchProductUid);
        Debug.println("sSearchProductName : "+sSearchProductName);
        Debug.println("sSearchServiceUid  : "+sSearchServiceUid);
        Debug.println("sSearchServiceName : "+sSearchServiceName+"\n");

        Debug.println("sReturnProductStockUidField   : "+sReturnProductStockUidField);
        Debug.println("sReturnProductStockNameField  : "+sReturnProductStockNameField);
        Debug.println("sReturnServiceStockUidField   : "+sReturnServiceStockUidField);
        Debug.println("sReturnServiceStockNameField  : "+sReturnServiceStockNameField);
        Debug.println("sReturnProductStockLevelField : "+sReturnProductStockLevelField+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // display products of user-service by default
    String sDisplayProductStocksOfActiveUserService = checkString(request.getParameter("DisplayProductStocksOfActiveUserService"));
    boolean displayProductStocksOfActiveUserService = true; // default
    if(sDisplayProductStocksOfActiveUserService.equals("false")){
        displayProductStocksOfActiveUserService = false;
    }
    
    Debug.println("@@@ displayProductStocksOfActiveUserService : "+displayProductStocksOfActiveUserService);

    if(sAction.length()==0){
        if(sSearchServiceUid.length()==0){
            if(displayProductStocksOfActiveUserService){
                sSearchServiceUid = activeUser.activeService.code;
                sSearchServiceName = getTran(request,"service",sSearchServiceUid,sWebLanguage);
            }
        }
    }

    if(sAction.length()==0) sAction = "find"; // default action

    StringBuffer sOut = new StringBuffer();
    int iTotal = 0;

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.equals("find")){
        int stockLevel, orderLevel;
        String sClass = "1", sProductName, sServiceStockUid = "", sServiceStockName, sStockBegin = "", sServiceName;
        String chooseTran = getTranNoLink("web","choose",sWebLanguage);
        ServiceStock serviceStock;

        // header
        sOut.append("<tr class='admin'>")
             .append("<td>"+getTran(request,"web","product",sWebLanguage)+"</td>")
             .append("<td>"+getTran(request,"web","service",sWebLanguage)+"</td>")
             .append("<td>"+getTran(request,"web","servicestock",sWebLanguage)+"</td>")
             .append("<td align='right'>"+getTran(request,"web","level",sWebLanguage)+"</td>")
             .append("<td align='right'>"+getTran(request,"web","orderlevel",sWebLanguage)+" </td>")
             .append("<td>"+getTran(request,"web","begindate",sWebLanguage)+"</td>")
            .append("</tr>");

        // run thru found records
        Vector productStocks = ProductStock.find("",sSearchProductUid,sSearchStockLevel,"","","","","","","",sSearchServiceUid,"OC_PRODUCT_NAME","ASC");
        ProductStock productStock;
        Product product;
        
        for(int i=0; i<productStocks.size(); i++){
            productStock = (ProductStock) productStocks.get(i);

            // servicestock and service name
            serviceStock = productStock.getServiceStock();
            if(serviceStock==null){
                sServiceStockName = "<font color='red'>"+getTran(request,"web","nonexistingServiceStock",sWebLanguage)+"</font>";
                sServiceName = "";
            } 
            else{
                if(!serviceStock.isAuthorizedUser(activeUser.userid)){
                    continue;
                }
                sServiceStockName = serviceStock.getName();

                // service name
                if(serviceStock.getServiceUid().length() > 0){
                    sServiceName = getTran(request,"service",serviceStock.getServiceUid(),sWebLanguage);
                }
                else{
                    sServiceName = "";
                }
            }

            // only search product-name when different product-UID
            product = productStock.getProduct();
            if(product==null){
            	sProductName = "<font color='red'>"+getTran(request,"web.manage","unexistingProduct",sWebLanguage)+"</font>";
            }
            else{
            	sProductName = product.getName();
            }

            // format begin date
            java.util.Date tmpDate = productStock.getBegin();
            if(tmpDate!=null) sStockBegin = ScreenHelper.formatDate(tmpDate);

            // levels
            String sStockLevel = (productStock.getLevel()<0?"":productStock.getLevel()+"");
            if(sStockLevel.length() > 0) stockLevel = Integer.parseInt(sStockLevel);
            else                         stockLevel = -1;

            String sOrderLevel = (productStock.getOrderLevel()<0?"":productStock.getOrderLevel()+"");
            if(sOrderLevel.length() > 0) orderLevel = Integer.parseInt(sOrderLevel);
            else                         orderLevel = -1;

            // determine class
            boolean stockEnabled;
            if(sSearchProductLevel.length() > 0 && productStock.getLevel() < Integer.parseInt(sSearchProductLevel)){
                // grey row out if all required packages have been delivered or when stock is empty
                if(iTotal%2==0) sClass = "strike";
                else            sClass = "strikelist";
                
                stockEnabled = false;
            }
            else{
                // alternate row-style
                if(iTotal%2==0) sClass = "list1";
                else            sClass = "list";
                
                stockEnabled = true;
            }

            //*** display stock in one row ***
            if(stockEnabled){
                String onClick = "onClick=\"selectProductStock('"+productStock.getUid()+"','"+(sProductName.length()==0?getTranNoLink("web","nonexistingproduct",sWebLanguage):sProductName)+"','"+sServiceStockUid+"','"+sServiceStockName+"','"+stockLevel+"');\"";
                sOut.append("<tr onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\" title='"+chooseTran+"' class='"+sClass+"' "+onClick+">");
            }
            else{
                sOut.append("<tr title='"+chooseTran+"' class='"+sClass+"' height='20'>");
            }

            // non-existing productname in red
            if(sProductName.length()==0){
                sProductName = "<font color='red'>"+getTran(request,"web","nonexistingproduct",sWebLanguage)+"</font>";
            }

            sOut.append("<td><b>"+sProductName+"</b></td>")
                .append("<td>"+sServiceName+"</td>")
                .append("<td>"+sServiceStockName+"</td>");

            // if current level < orderlevel -> mark record in red
            sOut.append("<td align='center'>"+(stockLevel<orderLevel?"<font color='red'>"+stockLevel+"</font>":stockLevel+"")+"</td>")
                .append("<td align='center'>"+(orderLevel>-1?orderLevel+"":"")+"</td>");

            sOut.append("<td>"+sStockBegin+"</td>")
                .append("</tr>");

            iTotal++;
        }
    }

    // display search results
    if(sAction.equals("find")){
        if(iTotal==0){
            // 'no results' message
            %><div><%=HTMLEntities.htmlentities(getTran(request,"web","norecordsfound",sWebLanguage))%></div><%
        }
        else{
            %>
                <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                    <%=HTMLEntities.htmlentities(sOut.toString())%>
                </table>
            <%
        }
    }

    // records found message
    if(sAction.equals("find")){
        if(iTotal > 0){
            %><div><%=iTotal%> <%=HTMLEntities.htmlentities(getTran(request,"web","recordsfound",sWebLanguage))%></div><%
        }
    }
%>
<script>sortables_init();</script>