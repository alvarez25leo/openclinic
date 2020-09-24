<%@page import="java.util.*,
                be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sCSSNORMAL%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* healthrecord/itemHistory.jsp *********************");
    	Debug.println("no parameters");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<%!
    private class Item{
        public String id = "";
        public String type = "";
        public String modifier = "";
        public String result = "";
        public String unit = "";
        public String normal = "";
        public String comment = "";
        public String time;
        public Hashtable name = new Hashtable();
        public Hashtable unitname = new Hashtable();
    }
%>

<HEAD><TITLE><%=getTranNoLink("web","history",sWebLanguage)%></TITLE></HEAD>
<body title="<%=getTranNoLink("Web.Occup","medwan.common.click-for-graph",sWebLanguage)%>" onclick="window.location.href='<c:url value="/healthrecord/itemGraph.jsp"/>?itemType=<%=request.getParameter("itemType")%>';">
<%
    String format = "";
    if (request.getParameter("itemType").indexOf("MEDIDOC")>-1){
        format = "MEDIDOC_";
    }
    
    String itemtype="web.occup";
    Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
    PreparedStatement ps = conn.prepareStatement("select * from transactionitems where itemtypeid=?");
    ps.setString(1,request.getParameter("itemType"));
    ResultSet rs = ps.executeQuery();
    while(rs.next()){
    	if(checkString(rs.getString("modifier")).split(";").length>1){
    		itemtype=rs.getString("modifier").split(";")[1];
    		break;
    	}
    }
    rs.close();
    ps.close();
    conn.close();

    Vector items=MedwanQuery.getInstance().getItemHistory((SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() )).getHealthRecordVO().getHealthRecordId().intValue(),request.getParameter("itemType"));
    String sVal = "", sType = "", sUnits = "", sHTML = "";
    int vals = 0;

    MessageReader messageReader = new MessageReaderMedidoc();

    for (int n=0; n<items.size(); n++){
        vals++;
        sVal  = ((ItemVO)items.get(n)).getValue();
        sType = ((ItemVO)items.get(n)).getType();

        if(sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.EXT_") && sVal.indexOf("|")>-1){
            // This is Lab information
            Item labItem = new Item();
            messageReader.lastline = sVal;
            labItem.type = messageReader.readField("|");

            if (labItem.type.equalsIgnoreCase("T") || labItem.type.equalsIgnoreCase("C")){
                labItem.comment = messageReader.readField("|");
            }
            else if (labItem.type.equalsIgnoreCase("N") || labItem.type.equalsIgnoreCase("D") ||
                     labItem.type.equalsIgnoreCase("H") || labItem.type.equalsIgnoreCase("M") ||
                     labItem.type.equalsIgnoreCase("S")){
                labItem.modifier = messageReader.readField("|");
                labItem.result = messageReader.readField("|");
                labItem.unit = messageReader.readField("|");
                sUnits = labItem.unit;
                labItem.normal = messageReader.readField("|");
                labItem.time = messageReader.readField("|");
                labItem.comment = messageReader.readField("|");
            }

            sVal = labItem.result+"&nbsp;"+labItem.normal;
        }
        else if(sType.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ANAMNESE_STRESS")){
            // convert 0,1,2,3,4 to "","+","++","+++","0"
                 if(sVal.equals("0")) sVal = "";
            else if(sVal.equals("1")) sVal = "+";
            else if(sVal.equals("2")) sVal = "++";
            else if(sVal.equals("3")) sVal = "+++";
            else if(sVal.equals("4")) sVal = "0";
        }
        else {
        	String[] sValParts = sVal.split(";");
        	sVal="";
        	for(int i=0;i<sValParts.length;i++){
        		if(i>0 && sVal.trim().length()>0){
        			sVal+=", ";
        		}
        		if(sValParts[i].split("\\$").length==2){
        			sVal += getTranNoLink(sValParts[i].split("\\$")[0],sValParts[i].split("\\$")[1],sWebLanguage);
        		}
        		else{
        			sVal += getTranNoLink(itemtype,sValParts[i],sWebLanguage);
        		}
        	}
        }

        sHTML+= "<tr class='list'>"+
                 "<td class='admin' width='70'>"+ScreenHelper.stdDateFormat.format(((ItemVO)items.get(n)).getDate())+"</td>"+
                 "<td class='admin2'>"+sVal+"</td>"+
                "</tr>";
    }
%>

<table class="list" width="100%" cellspacing="1" cellpadding="0">
    <tr class="admin"><td colspan="2"><%=getTran(request,"web","history",sWebLanguage)%></td></tr>
    <%=sHTML%>
</table>
    
<%
    if (sUnits.length()>0){
        out.print(getTran(request,"TRANSACTION_TYPE_LAB_RESULT",request.getParameter("itemType"),sWebLanguage)+" ("+getTran(request,"TRANSACTION_TYPE_LAB_RESULT","be.mxs.common.model.vo.healthrecord.IConstants.EXT_"+format+"UNIT_"+sUnits,sWebLanguage)+")");
    }
    else if (vals<1){
        out.print("<div class='text'>&nbsp;"+getTran(request,"Web.Occup","medwan.common.no-measurements",sWebLanguage)+"</div>");
    }
%>
	
<br/>

<center>
    <input type="button" class="button" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close()">
</center>

<script>
  window.focus();

  if(window.opener.document.getElementById('ie5menu')){
    window.opener.document.getElementById('ie5menu').style.visibility = 'hidden';
  }
</script>
</body>
