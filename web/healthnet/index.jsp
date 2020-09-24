<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%" class="list" cellpadding="0" cellspacing="1">
     <tr>
         <td width="1%" rowspan="4"><img src="<c:url value='_img/logo_main.jpg'/>"/></td>
         <td class="admin2"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/networkstatus.jsp" target="healthnet"><%=getTran(request,"healthnet","networkstatus",sWebLanguage)%></a></td>
     </tr>
     <tr>
         <td class="admin2"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/bedutilization.jsp" target="healthnet"><%=getTran(request,"healthnet","bedutilization",sWebLanguage)%></a></td>
     </tr>
     <tr>
         <td class="admin2"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/adt.jsp" target="healthnet"><%=getTran(request,"healthnet","adt",sWebLanguage)%></a></td>
     </tr>
</table>
<div style="padding-top:5px;"/>

<table width="100%" class="list" cellpadding="0" cellspacing="1">
    <tr>
        <td class="admin"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/summary.jsp&source=hn.chuk" target="healthnet">CHUK</a></td>
        <td class="admin"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/summary.jsp&source=hn.rutongo" target="healthnet">Rutongo</a></td>
        <td class="admin">Nyamata</td>
        <td class="admin">Muhima</td>
        <td class="admin">Kibagabaga</td>
        <td class="admin">Rwamagana</td>
    </tr>
</table>
<div style="padding-top:5px;"/>
 
<table width="100%" class="list" cellpadding="0" cellspacing="1">
    <tr>
        <td class="admin">Polyclinique du Carrefour</td>
        <td class="admin"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/summary.jsp&source=hn.biennaitre" target="healthnet">Polyclinique Bien Na�tre</a></td>
        <td class="admin">Polyclinique la M�dicale</td>
        <td class="admin">Polyclinique du Bon Samaritain</td>
        <td class="admin">Polyclinique Harmony</td>
        <td class="admin">Centre Biom�dical</td>
        <td class="admin">Polyclinique du Croix du Sud</td>
    </tr>
</table>