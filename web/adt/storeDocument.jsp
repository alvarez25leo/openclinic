<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.util.Hashtable,
                javazoom.upload.UploadFile,
                javazoom.upload.MultipartFormDataRequest"%>
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
    <jsp:setProperty name="upBean" property="folderstore" value='<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp")%>'/>
    <jsp:setProperty name="upBean" property="parser" value='<%=MultipartFormDataRequest.CFUPARSER%>'/>
    <jsp:setProperty name="upBean" property="parsertmpdir" value='<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp")%>'/>
</jsp:useBean>
<%
    String sFolderStore = application.getRealPath("/")+MedwanQuery.getInstance().getConfigString("documentsdir","adt/documents/");
    Debug.println("sFolderStore : "+sFolderStore);
    String sReturnField = "", sFileName = "";
    
    if(MultipartFormDataRequest.isMultipartFormData(request)){
        // Uses MultipartFormDataRequest to parse the HTTP request
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
        sReturnField = mrequest.getParameter("ReturnField");
        try{
            Hashtable files = mrequest.getFiles();
            if(files!=null && !files.isEmpty()){
                UploadFile file = (UploadFile)files.get("filename");
                sFileName = file.getFileName();
                file.setFileName(sFileName);
                if(SH.isAcceptableUploadFileExtension(sFileName)){
	                upBean.setFolderstore(sFolderStore);
	                upBean.setParsertmpdir(application.getRealPath("/")+"/"+MedwanQuery.getInstance().getConfigString("tempdir","/adt/tmp"));
	                upBean.store(mrequest,"filename");
                }
                else{
                	%>
                	<script>
                		alert("<%=getTranNoLink("web","forbiddenfiletype",sWebLanguage)%>");
                		window.close();
                	</script>
                	<%
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
%>
<script>
  window.resizeTo(1,1);
  window.opener.document.getElementsByName('<%=sReturnField%>')[0].value='<%=sFileName%>';
  window.close();
</script>