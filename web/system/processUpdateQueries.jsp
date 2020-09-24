<%@ page import="be.mxs.common.util.system.Debug,java.net.MalformedURLException,org.dom4j.DocumentException" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"system.management","all",activeUser)%>
<%
    String sAction = checkString(request.getParameter("actionfield"));


    //--- PROCESS UPDATE QUERIES ------------------------------------------------------------------
    if (sAction.equals("processUpdateQueries")) {
        //*** process 'updatequeries.xml' containing queries that need to be executed at login ***
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "updatequeries.xml";
        if (Debug.enabled) Debug.println("login.jsp : processing update-queries file '" + sDoc + "'.");

      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        if (MedwanQuery.getInstance().getConfigInt("cacheDB") != 1 && ad_conn.getMetaData().getDatabaseProductName().equalsIgnoreCase("cache")) {
            MedwanQuery.getInstance().setConfigString("cacheDB", "1");
        }

        if (MedwanQuery.getInstance().getConfigInt("cacheDB") == 1) {
            ad_conn.createStatement().execute("SET OPTION SUPPORT_DELIMITED_IDENTIFIERS=TRUE");
        }
		ad_conn.close();
        if (MedwanQuery.getInstance().getConfigInt("cacheDB") != 1) {
            // read xml file
            try {
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new URL(sDoc));

                Element queryElem;
                boolean queryIsExecuted;
                String sQuery;
                PreparedStatement ps = null;
                Connection conn = null;

                Iterator queriesIter = document.getRootElement().elementIterator("Query");
                while (queriesIter.hasNext()) {
                    queryElem = (Element) queriesIter.next();

                    try {
                        queryIsExecuted = checkString(MedwanQuery.getInstance().getConfigString(queryElem.attribute("id").getValue())).length()>0;

                        if (!queryIsExecuted) {
                            // Select the right connection
                                 if (queryElem.attribute("db").getValue().equalsIgnoreCase("ocadmin"))    conn = MedwanQuery.getInstance().getAdminConnection();
                            else if (queryElem.attribute("db").getValue().equalsIgnoreCase("openclinic")) conn = MedwanQuery.getInstance().getOpenclinicConnection();

                            // execute query
                            if (conn != null) {
                                String sLocalDbType = conn.getMetaData().getDatabaseProductName();
                                if (queryElem.attribute("dbserver") == null || queryElem.attribute("dbserver").getValue().equalsIgnoreCase(sLocalDbType)) {
                                	sQuery = queryElem.getTextTrim().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin"));
                                	sQuery = queryElem.getTextTrim().replaceAll("@openclinic@", MedwanQuery.getInstance().getConfigString("openclinicdbName","openclinic"));
	
	                                if (sQuery.length() > 0) {
	                                    try {
	                                    	String[] statements = sQuery.split(";");
	                                    	for(int n=0;n<statements.length;n++){
	                                    		if(statements[n].trim().length()>0){
	    	                                        ps = conn.prepareStatement(statements[n].trim());
	    	                                        ps.execute();
	    	                                        ps.close();
	                                    		}
	                                    	}
	
	                                        // add configString query.id
	                                        MedwanQuery.getInstance().setConfigString(queryElem.attribute("id").getValue(), "executed : first time");
	
	                                        if (Debug.enabled) {
	                                            Debug.println(queryElem.attribute("id").getValue() + " : executed");
	                                        }
	                                    }
	                                    catch (Exception e) {
	                                        if (e.getMessage().indexOf("There is already an object named") > -1) {
	                                            // table allready exists in DB, add configValue query.id
	                                            MedwanQuery.getInstance().setConfigString(queryElem.attribute("id").getValue(), "executed : table allready exists");
	                                            if (Debug.enabled) {
	                                                Debug.println(queryElem.attribute("id").getValue() + " : table allready exists");
	                                            }
	                                        } else {
	                                            // display query error
	                                            if (Debug.enabled) {
	                                                Debug.println(queryElem.attribute("id").getValue() + " : ERROR : " + e.getMessage());
	                                            }
	                                        }
	                                    }
	                                    finally {
	                                        if (ps != null) ps.close();
	                                    }
	                                } else {
	                                    if (Debug.enabled) {
	                                        Debug.println(queryElem.attribute("id").getValue() + " : empty");
	                                    }
	                                }
                                }
                                conn.close();
                            } else {
                                if (Debug.enabled) {
                                    Debug.println("login.jsp : Query-element specifies an invalid database to use : " + queryElem.attribute("db").getValue());
                                }
                            }
                        } else {
                            if (Debug.enabled) {
                                Debug.println(queryElem.attribute("id").getValue() + " : allready executed");
                            }
                        }
                    }
                    catch (NullPointerException e) {
                        if (Debug.enabled) {
                            Debug.println("login.jsp : Query-element does not have all required attributes.");
                        }
                    }
                }

                // tell application that update queries are processed
                application.setAttribute("updateQueriesProcessedDateOC", new java.util.Date());
            }
            catch (Exception me) {
				me.printStackTrace();
            }
        }
    }
%>
<form name="updateForm" method="post">
    <input type="hidden" name="actionfield">
    <%=writeTableHeader("Web.manage","processUpdateQueries",sWebLanguage," doBack();")%>
    <table width="100%" align="center" cellspacing="1" cellpadding="0" class="list">
        <%-- last processing date --%>
        <tr height="30">
            <td class="admin2" colspan="2">
                <%
                    Object updateQueriesProcessedDate = application.getAttribute("updateQueriesProcessedDateOC");
                    if(updateQueriesProcessedDate!=null){
                        SimpleDateFormat fullDateFormat = ScreenHelper.fullDateFormatSS;

                        %><%=getTran(request,"web.manage","updateQueriesLastProcessedAt",sWebLanguage)%> : <%=fullDateFormat.format(updateQueriesProcessedDate)%><%
                    }
                %>
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%>
    <p align="center">
        <input type="button" class="button" name="processButton" value="<%=getTranNoLink("web.manage","processUpdateQueries",sWebLanguage)%>" onClick="doSubmit();">
        <input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onClick="doBack();">
    </p>
</form>

<script>
  function doSubmit(){
    updateForm.processButton.disabled = true;
    updateForm.backButton.disabled = true;
    updateForm.actionfield.value = "processUpdateQueries";
    updateForm.submit();
  }

  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp";
  }
</script>