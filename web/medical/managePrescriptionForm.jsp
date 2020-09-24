<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%" border="0" cellpadding="1" cellspacing="1">
    <tr>
        <%-- COLUMN 1 ---------------------------------------------------------------------------%>
        <td width="50%">
            <table width="100%" border="0" cellpadding="1" cellspacing="1">
                <%-- FIND --%>
                <tr>
                    <td nowrap>
                        <input type="text" class="text" name="findproduct" id="findproduct" size="40" onKeyDown="if(enterEvent(event,13)){document.getElementById('findproductbutton').onclick();}">
                        <input align="right" type="button" class="button" name="findproductbutton" id="findproductbutton" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="findProduct();">
                    </td>
                </tr>
                
                <%-- FOUND --%>
                <tr>
                    <td width="1%">
                        <div class="searchResults" id="foundproducts" style="width:340;height:100;border-style: solid;border-width: 1px;border-color: lightgray;">&nbsp;</div>
                    </td>
                </tr>
                
                <%-- A - CHRONIC --%>
                <tr>
                    <td width="1%">
                        <b><%=getTran(request,"web","chronicmedication",sWebLanguage)%></b>
                        <div class="searchResults" id="chronicproducts" style="width:340;height:50;border-style: solid;border-width: 1px;border-color: lightgray;">&nbsp;</div>
                    </td>
                </tr>
                
                <%-- B - ACTIVE --%>
                <tr>
                    <td width="1%">
                        <b><%=getTran(request,"web","activeprescriptions",sWebLanguage)%></b>
                        <div class="searchResults" id="todaysproducts" style="width:340;height:50;border-style: solid;border-width: 1px;border-color: lightgray;">&nbsp;</div>
                    </td>
                </tr>
                
                <%-- INFO --%>
                <tr>
                    <td>
                        <textarea class="text" name="prescriptioninfo" id="prescriptioninfo" rows="5" cols="60"></textarea>
                        <input type="hidden" name="productuid" id="productuid"/>
                    </td>
                    <td style="vertical-align:top;">
                        <img src="<c:url value='/_img/themes/default/next.gif'/>" class="link" border="0" onClick="copyfoundproduct();" alt="<%=getTranNoLink("web","copy",sWebLanguage)%>"/>
                    </td>
                </tr>
            </table>
        </td>
        
        <%-- COLUMN 2 ---------------------------------------------------------------------------%>
        <td width="50%" style="vertical-align:top;">
            <table width="100%" border="0" cellpadding="1" cellspacing="1">
                <tr>
                    <td>
                        <form name="printPrescriptionForm" method="post" action="<c:url value='/'/>medical/createPrescriptionPdf.jsp">
                            <textarea class="text" name="prescription" id="prescription" rows="22" cols="40" onkeyup="cleanRxNormCodes();"></textarea><br/>
                            <%=getTran(request,"web","date",sWebLanguage)%>
                            <input type="text" class="text" size="10" maxLength="10" name="prescriptiondate" value="<%=ScreenHelper.stdDateFormat.format(new java.util.Date())%>" id="prescriptiondate" OnBlur='checkDate(this)'>
                            <script>writeMyDate("prescriptiondate");</script>
                            <input type="hidden" name="personid" id="personid" value="<%=activePatient.personid%>"/>
                            <input type="hidden" name="rxnormcodes" id="rxnormcodes" value=""/>
                            <input type="hidden" name="rxnormnames" id="rxnormnames" value=""/>
                        </form>
                    </td>
                </tr>
                <tr>
                	<td id='interactionswarning' style='display: none'>
                		<a href='javascript:findInteractions();'>
                		<img src="<c:url value='/_img/icons/icon_warning.gif'/>" title='<%=getTranNoLink("web","prescription_has_interactions",sWebLanguage)%>'/>
                		<%=getTran(request,"web","prescription_has_interactions",sWebLanguage)%>!</a>
                	</td>
                </tr>	
            </table>
        </td>
    </tr>
    
    <%-- BUTTONS --%>
    <tr>
        <td>
            &nbsp;<input type="button" class="button" name="updateprescriptioninfo" value="<%=getTranNoLink("web","update",sWebLanguage)%>" onclick="updatecontent();"/>
            <input type="button" class="button" name="copytochronicmedication" value="<%=getTranNoLink("web","copytochronic",sWebLanguage)%>" onclick="copytochronic();"/>
            <input type="button" class="button" name="add" value="+ <%=getTranNoLink("web","list",sWebLanguage)%>" onclick="addcontent();"/>
        </td>
        <td>
            &nbsp;<input type="button" class="button" name="print" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onclick="printprescription();"/>
        </td>
    </tr>
</table>

<script>
  function copytochronic(){
    var url = "<c:url value=''/>medical/ajax/addChronicPrescription.jsp";
    new Ajax.Request(url,{
      method: "POST",
      postBody: "productuid="+document.getElementById("productuid").value,
      onSuccess: function(resp){
        findchronicproducts();
      }
    });
  }
  
  function findProduct(){
    var url = "<c:url value=''/>medical/ajax/findPrescriptionProduct.jsp";
    var params = "productname="+document.getElementById("findproduct").value;

    new Ajax.Request(url,{
      method: "POST",
      parameters: params,
      onSuccess: function(resp){
        $('foundproducts').innerHTML = resp.responseText;
      },
      onFailure: function(){
        $('foundproducts').innerHTML = "Problem with ajax request";
      }
    });
  }

  function findtodaysproducts(){
    var url = "<c:url value=''/>medical/ajax/findPrescriptionTodayProducts.jsp";
    new Ajax.Request(url,{
      method: "POST",
      onSuccess: function(resp){
        $('todaysproducts').innerHTML = resp.responseText;
      },
      onFailure: function(){
        $('todaysproducts').innerHTML = "Problem with ajax request";
      }
    });
  }

  function findchronicproducts(){
    var url = "<c:url value=''/>medical/ajax/findPrescriptionChronicProducts.jsp";

    new Ajax.Request(url,{
      method: "POST",
      onSuccess: function(resp){
        $('chronicproducts').innerHTML = resp.responseText;
      },
      onFailure: function(){
        $('chronicproducts').innerHTML = "Problem with ajax request";
      }
    });
  }

  function copyfoundproduct(){
    $('prescription').value += $('prescriptioninfo').value+"\n";
  }

  function copyproduct(productuid){
    var url = "<c:url value=''/>medical/ajax/findPrescriptionProductContent.jsp";
    var params = "productuid="+productuid;
    document.getElementById("productuid").value=productuid;

    new Ajax.Request(url,{
      method: "POST",
      parameters: params,
      onSuccess: function(resp){
        var prescriptioninfo = resp.responseText.split("$");
        if(prescriptioninfo[1].length>0){
          $('prescription').value+= prescriptioninfo[1]+"\n";
    		$('rxnormnames').value+=prescriptioninfo[1]+"="+prescriptioninfo[3]+";";
        }
        else{
          $('prescription').value+= prescriptioninfo[2]+"\n";
    		$('rxnormnames').value+=prescriptioninfo[2]+"="+prescriptioninfo[3]+";";
        }
  		$('rxnormcodes').value+=prescriptioninfo[3]+";";
  	  <%
	    	if(MedwanQuery.getInstance().getConfigInt("enableRxNorm",0)==1){
	    %>
	    		checkForInteractions();
	    <%
	    	}
	    %>
      }
    });
  }

  function copycontent(productuid){
    var url = "<c:url value=''/>medical/ajax/findPrescriptionProductContent.jsp";
    var params = "productuid="+productuid;
    document.getElementById("productuid").value=productuid;

    new Ajax.Request(url,{
      method: "POST",
      parameters: params,
      onSuccess: function(resp){
        var prescriptioninfo = resp.responseText.split("$");
        if(prescriptioninfo[1].length>0){
          $('prescriptioninfo').value = prescriptioninfo[1];
        }
        else {
          $('prescriptioninfo').value = prescriptioninfo[2];
        }
      }
    });
  }

  function updatecontent(){
    var url = "<c:url value=''/>medical/ajax/updatePrescriptionProductContent.jsp";
      new Ajax.Request(url,{
        method: "POST",
        postBody: "productuid="+document.getElementById("productuid").value+
                  "&prescriptioninfo="+document.getElementById("prescriptioninfo").value,
        onSuccess: function(resp){
      }
    });
  }

  function addcontent(){
    if(yesnoDialogDirectText('<%=getTran(request,"web","areyousure",sWebLanguage)%>')){
      var url = "<c:url value=''/>medical/ajax/addPrescriptionProductContent.jsp";
      new Ajax.Request(url,{
        method: "POST",
        postBody: "findproduct="+document.getElementById("findproduct").value+"&prescriptioninfo="+document.getElementById("prescriptioninfo").value,
        onSuccess: function(resp){
        }
      });
    }
  }

  function checkForInteractions(){
    var url = "<c:url value=''/>pharmacy/popups/findRxNormDrugDrugInteractionsBoolean.jsp";
    var params = "key="+document.getElementById("rxnormcodes").value;
    new Ajax.Request(url,{
      method: "POST",
      parameters: params,
      onSuccess: function(resp){
        var interactions =  eval('('+resp.responseText+')');
        if(interactions.interactionsexist=='1'){
        	document.getElementById("interactionswarning").style.display='';
        }
        else {
        	document.getElementById("interactionswarning").style.display='none';
        }
      }
    });
  }
  
  function cleanRxNormCodes(){
	var rxnormnames=document.getElementById("rxnormnames").value.split(";");
	for(n=0;n<rxnormnames.length;n++){
		if(document.getElementById("prescription").value.indexOf(rxnormnames[n].split("=")[0])<0){
			document.getElementById("rxnormcodes").value=document.getElementById("rxnormcodes").value.replace(rxnormnames[n].split("=")[1],"");
		}
	}
  <%
  	if(MedwanQuery.getInstance().getConfigInt("enableRxNorm",0)==1){
  %>
  		checkForInteractions();
  <%
  	}
  %>
  }
  function findInteractions(){
	    openPopup("/pharmacy/popups/findRxNormDrugDrugInteractions.jsp&ts=<%=getTs()%>&key="+document.getElementById("rxnormcodes").value,800,600);
 }
	  
  function printprescription(){
    printPrescriptionForm.submit();
  }

  findtodaysproducts();
  findchronicproducts();
  window.setTimeout("document.getElementById('findproduct').focus();",300);
</script>