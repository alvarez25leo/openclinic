<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"occup.vaccinations","select",activeUser)%>

<form name="vaccinationForm" method="POST" action='/healthrecord/updateTransaction.do?ts=<%=getTs()%>' focus='type'>

<%--- 1 - GIVEN VACCINATIONS --------------------------------------------------------------------%>
<%=writeTableHeader("Web.Occup","be.mxs.healthrecord.vaccination.vaccination-card",sWebLanguage,sCONTEXTPATH+"/main.do?Page=curative/index.jsp&ts="+getTs())%>
<table width="100%" align="center" cellspacing="1" cellpadding="0" class="list">
  <tr>
    <td>
      <table class="list" width="100%" cellspacing="0">
        <%--- header ---%>
        <tr class="gray">
          <td width="5%"><%=getTran(request,"Web.Occup","be.mxs.healthrecord.vaccination.administer",sWebLanguage)%>&nbsp;</td>
          <td width="*"><%=getTran(request,"Web.Occup","be.mxs.healthrecord.vaccination.Vaccination",sWebLanguage)%>&nbsp;</td>
          <td width="15%"><%=getTran(request,"Web.Occup","be.mxs.healthrecord.vaccination.status",sWebLanguage)%>&nbsp;</td>
          <td width="5%"><%=getTran(request,"Web","info",sWebLanguage)%>&nbsp;</td>
          <td width="15%"><%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>&nbsp;</td>
          <td width="15%"><%=getTran(request,"Web.Occup","be.mxs.healthrecord.vaccination.next-status",sWebLanguage)%>&nbsp;</td>
          <td width="15%"><%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>&nbsp;</td>
        </tr>
        
        <%--- RUN THRU VACCINATIONS IN SESSION ---%>
        <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="personalVaccinationsInfoVO">
          <logic:iterate id="vaccinationInfoVO" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="personalVaccinationsInfoVO.vaccinationsInfoVO">
            <tr class="list">
              <%--- NEEDLE ---%>
              <td align="center">
                <logic:notEqual name="vaccinationInfoVO" scope="page" property="nextStatus" value="-">
                  <a href="<c:url value='/healthrecord/manageNextVaccination.do'/>?ts=<%=getTs()%>&status=<bean:write name="vaccinationInfoVO" scope="page" property="nextStatus"/>&vaccination=<mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" translate="false" property="value"/><logic:present name="vaccinName"><logic:notEqual name="vaccinName" scope="page" value="">&vaccination_name=<bean:write name="vaccinName" scope="page"/></logic:notEqual></logic:present>"  title="<%=getTranNoLink("Web.Occup","be.mxs.healthrecord.vaccination.administer",sWebLanguage)%>" onMouseOver="window.status='';return true;"><img border="0" src='<c:url value="/_img/icons/icon_needle.gif"/>'></a>
                </logic:notEqual>
              </td>

              <%--- VACCINATION NAME ---%>
              <td>
                <a href="<c:url value='/healthrecord/showVaccinationHistory.do'/>?VaccinType=<mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value" translate="false"/>&vaccination=<mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" translate="false" property="value"/>&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value"/></a>
                <mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" output="false" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME" property="value" translate="false" toBean="vaccinName" toScope="page"/>
                <logic:present name="vaccinName">
                  <logic:notEqual name="vaccinName" scope="page" value="">
                   (<bean:write name="vaccinName" scope="page"/>)
                  </logic:notEqual>
                </logic:present>

                <mxs:propertyAccessorI18N name="vaccinationInfoVO" output="false" scope="page" property="profile" translate="false" toBean="inProfile" toScope="page"/>
                <logic:present name="inProfile">
                  -
                  <logic:equal name="inProfile" scope="page" value="true">
                    *
                  </logic:equal>
                </logic:present>
              </td>
              
              <%--- STATUS ---%>
              <td>
                <mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" output="false" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="value" translate="false" toBean="vaccinationCurrentStatus" toScope="page"/>
                <logic:notEqual name="vaccinationCurrentStatus" scope="page" value="be.mxs.healthrecord.vaccination.status-none">
                  <bean:define id="tranid" name="vaccinationInfoVO" property="transactionVO"/>
                  <a href="<c:url value='/healthrecord/manageVaccination.do'/>?vaccination=<mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" translate="false" property="value"/>&be.mxs.healthrecord.transaction_id=<bean:write name="tranid" scope="page" property="transactionId"/>&be.mxs.healthrecord.server_id=<bean:write name="tranid" scope="page" property="serverId"/>&ts=<%=getTs()%>" onMouseOver="window.status='';return true;">
                </logic:notEqual>
                <mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="value"/>
                <logic:notEqual name="vaccinationCurrentStatus" scope="page" value="be.mxs.healthrecord.vaccination.status-none">
                  </a>
                </logic:notEqual>
              </td>
              
              <%--- INFO ---%>
              <td>
                <mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" output="false" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="value" translate="true" toBean="comment" toScope="page"/>
                <logic:present name="comment">
                  <logic:notEqual name="comment" scope="page" value="">
                    <img border="0" src='<c:url value="/_img/icons/icon_info.gif"/>' alt="<bean:write name="comment" scope="page"/>" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                  </logic:notEqual>
                </logic:present>
              </td>
              
              <%--- DATE ---%>
              <td>
                <mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" output="false" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="value" translate="false" toBean="date" toScope="page"/>
                <logic:present name="date">
                  <logic:notEqual name="date" scope="page" value="">
                    <bean:write name="date" scope="page"/>
                  </logic:notEqual>
                </logic:present>
              </td>
              
              <logic:notEqual name="vaccinationInfoVO" scope="page" property="nextStatus" value="-">
                <mxs:propertyAccessorI18N name="vaccinationInfoVO.transactionVO.items" output="false" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="value" translate="false" toBean="nextdate" toScope="page"/>
                <logic:present name="nextdate">
                  <logic:notEqual name="nextdate" scope="page" value="">
                    <%--- NEXT STATUS ---%>
                    <td style="padding-left:3px;" bgcolor="<bean:write name="vaccinationInfoVO" scope="page" property="color"/>">
                      <mxs:beanTranslator name="vaccinationInfoVO" scope="page" property="nextStatus"/>
                    </td>
                    <%--- NEXT DATE ---%>
                    <td bgcolor="<bean:write name="vaccinationInfoVO" scope="page" property="color"/>">
                      <bean:write name="nextdate" scope="page"/>
                    </td>
                  </logic:notEqual>
                  <logic:equal name="nextdate" scope="page" value="">
                    <td colspan="2"/>
                  </logic:equal>
                </logic:present>
              </logic:notEqual>
            </tr>
          </logic:iterate>
        </logic:present>
      </table>
    </td>
  </tr>
</table>
<br>
  
<%-- 2 - OTHER VACCINATIONS ---------------------------------------------------------------------%>
<% int vaccIdx = 0; %>
  
<%=writeTableHeader("web.occup","be.mxs.healthrecord.vaccination.autres-vaccins",sWebLanguage,sCONTEXTPATH+"/main.do?Page=curative/index.jsp&ts="+getTs())%>
<table width="100%" align="center" cellspacing="1" cellpadding="0" class="list"> 
  <tr>
    <td>
      <table class="list" width="100%" cellspacing="0">
        <%-- header --%>
        <tr class="gray">
          <td width="5%"><%=getTran(request,"Web.Occup","be.mxs.healthrecord.vaccination.administer",sWebLanguage)%>&nbsp;</td>
          <td width="*"><%=getTran(request,"Web.Occup","be.mxs.healthrecord.vaccination.Vaccination",sWebLanguage)%>&nbsp;</td>
        </tr>
        <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="personalVaccinationsInfoVO">
          <logic:iterate id="examinationVO" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="personalVaccinationsInfoVO.otherVaccinations">
            <tr class="list<%=(vaccIdx++%2==0?"1":"0")%>">
              <td align="center">
                <a href="<c:url value='/healthrecord/manageVaccination.do'/>?vaccination=<bean:write name='examinationVO' scope='page' property='messageKey'/>&ts=<%=getTs()%>"  onMouseOver="window.status='';return true;" title="<%=getTranNoLink("Web.Occup","be.mxs.healthrecord.vaccination.administer",sWebLanguage)%>"><img border="0" src='<c:url value="/_img/icons/icon_needle.gif"/>'></a>
              </td>
              <td><mxs:beanTranslator name="examinationVO" scope="page" property="messageKey"/></td>
            </tr>
          </logic:iterate>
        </logic:present>
      </table>
    </td>
  </tr>
</table>
<br>
  
<%-- 3 - LINKS ----------------------------------------------------------------------------------%>
<table width="100%" align="center" cellspacing="1" cellpadding="0">
  <tr>
    <bean:define id="flags" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="flags"/>
    <td>
      <img src="<c:url value='/_img/themes/default/pijl.gif'/>">
      <a href="<c:url value='/healthrecord/managePeriodicExaminations.do?be.medwan.context.department=context.department.occup&be.medwan.context.context='/><mxs:propertyAccessorI18N name="flags" scope="page" translate="false" property="context"/>&ts=<%=getTs()%>"  onMouseOver="window.status='';return true;"><%=getTran(request,"Web.Occup","medwan.healthrecord.periodic-examinations",sWebLanguage)%></a>
    </td>
  </tr>
  <tr>
    <td>
      <img src="<c:url value='/_img/themes/default/pijl.gif'/>">
      <a href="<c:url value='/main.jsp'/>?Page=curative/index.jsp&ts=<%=getTs()%>"  onMouseOver="window.status='';return true;"><%=getTran(request,"Web.Occup","medwan.recruitment.view-recruitment-examinations-summary",sWebLanguage)%></a>
    </td>
  </tr>
</table>
</form>