<%@page import="be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.Product,
                java.util.Calendar,
                java.util.GregorianCalendar"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<%=sJSSORTTABLE%>

<%
    // retreive data
    String monthIdx        = checkString(request.getParameter("monthIdx")),
           year            = checkString(request.getParameter("year")),
           serviceStockUid = checkString(request.getParameter("serviceStockUid")),
           productStockUid = checkString(request.getParameter("productStockUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("***************** pharmacy/popups/unitOverviewPerMonth.jsp ***************");
        Debug.println("monthIdx        : "+monthIdx);
        Debug.println("year            : "+year);
        Debug.println("serviceStockUid : "+serviceStockUid);
        Debug.println("productStockUid : "+productStockUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sSelectedServiceStockName = "", sSelectedProductStockName = "";
    ProductStock productStock = ProductStock.get(productStockUid);

    if(productStock!=null){
        sSelectedServiceStockName = productStock.getServiceStock().getName();

        Product product = productStock.getProduct();
        if(product!=null){
            sSelectedProductStockName = product.getName();
        }
        else{
            sSelectedProductStockName = "<font color='red'>"+getTran(request,"web","nonexistingProduct",sWebLanguage)+"</font>";
        }
    }
%>

<%=writeTableHeader("Web.manage","unitOverviewPerMonth",sWebLanguage," window.close();")%>
<table width="100%" cellspacing="1">
    <%-- MONTH --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;<%=getTran(request,"web","month",sWebLanguage)%></td>
        <td class="admin2"><%=getTran(request,"web","month"+(Integer.parseInt(monthIdx)+1),sWebLanguage)%> <%=year%></td>
    </tr>
    <%-- SERVICE STOCK --%>
    <tr>
        <td class="admin">&nbsp;<%=getTran(request,"web","serviceStock",sWebLanguage)%></td>
        <td class="admin2"><%=sSelectedServiceStockName%></td>
    </tr>
    <%-- PRODUCT STOCK --%>
    <tr>
        <td class="admin">&nbsp;<%=getTran(request,"web","productStock",sWebLanguage)%></td>
        <td class="admin2"><%=sSelectedProductStockName%></td>
    </tr>
</table>
<br>

<center>
<%-- HEADER ---------------------------------------------------------------------------------%>
<div class="search" style="width:98%">
    <table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
        <%-- HEADER --%>
        <tr class="admin">
            <td></td>
            <td style="text-align:right;">&nbsp;<%=getTran(request,"web","in",sWebLanguage)%>&nbsp;</td>
            <td style="text-align:right;">&nbsp;<%=getTran(request,"web","out",sWebLanguage)%>&nbsp;</td>
            <td style="text-align:right;">&nbsp;<%=getTran(request,"web","netto",sWebLanguage)%>&nbsp;</td>
            <td style="text-align:right;">&nbsp;<%=getTran(request,"web","level",sWebLanguage)%>&nbsp;</td>
        </tr>
        
        <%-- DISPLAY MONTHS --%>
        <tbody>
            <%
                // days in specified month
                Calendar calendar = new GregorianCalendar();
                calendar.set(Integer.parseInt(year),Integer.parseInt(monthIdx),0,0,0,0);
                int daysInMonth = calendar.getMaximum(Calendar.DAY_OF_MONTH);

                String sClass = "list1";
                int dayOfWeek, unitsIn, unitsOut, unitsDiff;
                int oldday = 0;
                for(int i=0; i<daysInMonth; i++){
                    calendar.add(Calendar.DATE,1);
                    if(oldday > calendar.get(Calendar.DATE)){
                        break;
                    }
                    else{
                        oldday = calendar.get(Calendar.DATE);
                    }

                    // convert day of week
                    dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK) - 1;
                    if(dayOfWeek==0) dayOfWeek = 7;

                    // weekend
                    if(dayOfWeek==6 || dayOfWeek==7){
                        sClass = "gray";
                    }
                    else{
                        sClass = "list1";
                    }

                    // count units
                    unitsIn = productStock.getTotalUnitsInForDate(ScreenHelper.stdDateFormat.parse(ScreenHelper.formatDate(calendar.getTime())));
                    unitsOut = productStock.getTotalUnitsOutForDate(ScreenHelper.stdDateFormat.parse(ScreenHelper.formatDate(calendar.getTime())));
                    unitsDiff = unitsIn - unitsOut;

                    // alternate row-style
                    String onclick = "";
                    if(unitsIn>0 || unitsOut>0){
                        onclick = "onclick=\"showUnitsForDay('"+ScreenHelper.formatDate(calendar.getTime())+"','"+productStockUid+"');\""+
                                  " onmouseover=\"this.style.cursor='hand';\""+
                                  " onmouseout=\"this.style.cursor='default';\"";
                    }

                    %>
                        <tr <%=onclick%> class="<%=sClass%>">
                            <td>&nbsp;<%=getTran(request,"web","weekday"+dayOfWeek,sWebLanguage)%> <%=calendar.get(Calendar.DATE)%></td>
                            <td style="text-align:right;"><%=unitsIn%>&nbsp;</td>
                            <td style="text-align:right;"><%=unitsOut%>&nbsp;</td>
                            <td style="text-align:right;"><%=(unitsDiff<0?unitsDiff+"":(unitsDiff==0?unitsDiff+"":"+"+unitsDiff))%>&nbsp;</td>
                            <td style="text-align:right;"><%=productStock.getLevel(calendar.getTime())%>&nbsp;</td>
                        </tr>
                    <%
                }
            %>
        </tbody>
        <%
            // count units
            unitsIn   = productStock.getTotalUnitsInForMonth(calendar.getTime());
            unitsOut  = productStock.getTotalUnitsOutForMonth(calendar.getTime());
            unitsDiff = unitsIn - unitsOut;
        %>
        <tr class="admin">
            <td>&nbsp;<%=getTran(request,"web","total",sWebLanguage)%></td>
            <td style="text-align:right;"><%=unitsIn%>&nbsp;</td>
            <td style="text-align:right;"><%=unitsOut%>&nbsp;</td>
            <td style="text-align:right;"><%=(unitsDiff<0?unitsDiff+"":(unitsDiff==0?unitsDiff+"":"+"+unitsDiff))%>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
    </table>
</div>
</center>

<script>
  <%-- SHOW UNITS FOR DAY --%>
  function showUnitsForDay(date,productStockUid){
    openPopup("pharmacy/popups/unitOverviewForDay.jsp&date="+date+"&productStockUid="+productStockUid+"&ts="+new Date(),900,550);
  }
</script>