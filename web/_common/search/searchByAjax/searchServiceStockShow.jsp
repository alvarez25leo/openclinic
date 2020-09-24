<%@page import="be.openclinic.pharmacy.ServiceStock,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.pharmacy.ProductStock"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "find"; // default action

    // get data from form
    String sSearchServiceStockName = checkString(request.getParameter("SearchServiceStockName")),
           sSearchServiceUid       = checkString(request.getParameter("SearchServiceUid")),
           sSearchServiceName      = checkString(request.getParameter("SearchServiceName")),
           sSearchManagerUid       = checkString(request.getParameter("SearchManagerUid")),
           sExcludeServiceStockUid = checkString(request.getParameter("ExcludeServiceStockUid")),
           sSearchProductUid       = checkString(request.getParameter("SearchProductUid")),
           sSearchProductLevel     = checkString(request.getParameter("SearchProductLevel")),
           sSearchManagerName      = checkString(request.getParameter("SearchManagerName"));

    // get data from calling url or hidden fields in form
    String sReturnServiceStockUidField  = checkString(request.getParameter("ReturnServiceStockUidField")),
           sReturnServiceStockNameField = checkString(request.getParameter("ReturnServiceStockNameField"));

    StringBuffer sOut = new StringBuffer("");
    int iTotal = 0;
    
    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.equals("find")){
        String chooseTran = getTranNoLink("web","choose",sWebLanguage);
        String sClass = "1", sServiceName, sManagerName, sSupplyingServiceUid = "", sSupplyingServiceName = "";

        // header
        sOut.append("<tr class='admin'>")
             .append("<td>"+getTran(request,"web","name",sWebLanguage)+"</td>")
             .append("<td>"+getTran(request,"web","service",sWebLanguage)+"</td>")
             .append("<td>"+getTran(request,"web","manager",sWebLanguage)+"</td>")
            .append("</tr>");

        // tbody
        sOut.append("<tbody class='hand'>");

        Vector serviceStocks = ServiceStock.find(sSearchServiceStockName,sSearchServiceUid,"","",sSearchManagerUid,"","OC_STOCK_NAME","");

        // run thru found service stocks
        ServiceStock serviceStock;
        for(int i=0; i<serviceStocks.size(); i++){
            serviceStock = (ServiceStock)serviceStocks.get(i);
            
            if(!serviceStock.getUid().equalsIgnoreCase(sExcludeServiceStockUid)){
                sServiceName = getTranNoLink("Service", serviceStock.getServiceUid(),sWebLanguage);
                sManagerName = "";
                if(serviceStock.getStockManager()!=null){
                	sManagerName=serviceStock.getStockManager().lastname+" "+serviceStock.getStockManager().firstname;
                }

                // supplyingService

                if(serviceStock.getService()!=null){
                    if(serviceStock.getService().code!=null){
                        sSupplyingServiceUid = serviceStock.getService().code;

                        if(sSupplyingServiceUid.length() > 0) sSupplyingServiceName = getTran(request,"service",serviceStock.getService().code,sWebLanguage);
                        else                                  sSupplyingServiceName = "";

                        // alternate row-style
                        if(sClass.equals("")) sClass = "1";
                        else                  sClass = "";

                        String cellClass = "", level = "";
                        if(sSearchProductUid.length() > 0){
                            ProductStock productStock = serviceStock.getProductStock(sSearchProductUid);
                            if(productStock==null || (sSearchProductLevel.length() > 0 && productStock.getLevel() < Integer.parseInt(sSearchProductLevel))){
                                cellClass = " class='strike'";
                            }
                            if(productStock!=null){
                                level = " <i>("+getTran(request,"web","level",sWebLanguage)+" = "+productStock.getLevel()+")</i>";
                            }
                        }

                        //*** display stock in one row ***
                        sOut.append("<tr title='"+chooseTran+"' class='list"+sClass+"' onClick=\"selectServiceStock('"+serviceStock.getUid()+"','"+serviceStock.getName()+"','"+sSupplyingServiceUid+"','"+sSupplyingServiceName+"');\">")
                             .append("<td"+cellClass+"><b>"+serviceStock.getName()+level+"</b></td>")
                             .append("<td"+cellClass+">"+sServiceName+"</td>")
                             .append("<td"+cellClass+">"+sManagerName+"</td>")
                            .append("</tr>");

                        iTotal++;
                    }
                }
            }
        }

        sOut.append("</tbody>");
    }
%>

<%
    // display search results
    if(sAction.equals("find")){
        if(iTotal==0){
    	    %><%=HTMLEntities.htmlentities(getTran(request,"web","noRecordsFound",sWebLanguage))%><%
        }
        else{                    
            %>
	            <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
	                <%=HTMLEntities.htmlentities(sOut.toString())%>		        
				</table>
				
				<%=iTotal%> <%=HTMLEntities.htmlentities(getTran(request,"web","recordsFound",sWebLanguage))%>
            <%
        }
    }
%>
<script>sortables_init();</script>