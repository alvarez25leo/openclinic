/**
 * 
 */
package ocdhis2;

import java.net.SocketTimeoutException;
import java.security.NoSuchAlgorithmException;

import javax.net.ssl.SSLContext;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.glassfish.jersey.SslConfigurator;
import org.glassfish.jersey.client.ClientProperties;
import org.glassfish.jersey.client.authentication.HttpAuthenticationFeature;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.dhis2.Util;

/**
 * @author loic
 * Stores information about the DHIS2 server.
 * One instance of OpenClinic might have to send information to several different
 * DHIS2 servers (national server and vertical programs, backup servers...).
 * The XML definition file will have to define for each dataset which server(s) 
 * has (have) to be contacted.
 */


public class DHIS2Server
{
   
    // Connection information
    
    private String baseURL;                             // ex: "https://dhis.snis.bi"
    private String baseAPI;                             // ex: "api"
    private String port;                                // ex: "80"

    
    // User information.  A specific user should be created on the DHIS2
    // instance for the Health Information System of the health structure.
    
    private String userName;                    // ex: "Hopital_Central_OpenClinic"
    private String userPassword;                // ex: "oJgUE9WuxHoNkt3"
    
    
    // User-friendly name internally given inside OC for this DHIS2 server.
    
    private String serverName;                  // ex: "DHIS2 Burundi"

    
    
    public String getUrl()
    {
        return this.baseURL + ":" + this.port + this.baseAPI;
    }
    
    /**
     * @param baseURL
     * @param baseAPI
     * @param port
     */
    public DHIS2Server(String baseURL, String baseAPI, String port)
    {
        super();
        this.baseURL = baseURL;
        this.baseAPI = baseAPI;
        this.port = port;
    }
    
    public String getBaseURL()
    {
        return baseURL;
    }

    public void setBaseURL(String baseURL)
    {
        this.baseURL = baseURL;
    }

    public String getBaseAPI()
    {
        return baseAPI;
    }

    public void setBaseAPI(String baseAPI)
    {
        this.baseAPI = baseAPI;
    }

    public String getPort()
    {
        return port;
    }

    public void setPort(String port)
    {
        this.port = port;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public String getUserPassword()
    {
        return userPassword;
    }

    public void setUserPassword(String userPassword)
    {
        this.userPassword = userPassword;
    }

    public String getServerName()
    {
        return serverName;
    }

    public void setServerName(String serverName)
    {
        this.serverName = serverName;
    }
    
    // Send data to the server, and obtain a Response from the server.
    // If the server gave a useful payload in its response (not a 404 or 500 case for example),
    // then the Response.Entity is processed and deserialized into an ImportSummary, 
    // which matches the type of answers from the DHIS2 server.
    public Response sendToServer(DataValueSet dataValueSet) throws SocketTimeoutException, NoSuchAlgorithmException
    {
    	//Make sure we've got all the certificates on board
    	String host = baseURL.replaceAll("https://", "").replaceAll("http://", "").split(":")[0].split("/")[0];
    	try {
			Util.importCertificate(host, Integer.parseInt(port), MedwanQuery.getInstance().getConfigString("dhis2_truststore","/temp/keystore"), MedwanQuery.getInstance().getConfigString("dhis2_truststore_pass","changeme"));
		} catch (Exception e) {
			e.printStackTrace();
		}
     
        // preparing the SSL connection
        SslConfigurator sslConfig = SslConfigurator.newInstance();
        sslConfig.trustStoreFile(MedwanQuery.getInstance().getConfigString("dhis2_truststore","/temp/keystore"));
        sslConfig.trustStorePassword(MedwanQuery.getInstance().getConfigString("dhis2_truststore_pass","changeme"));
        sslConfig.keyStoreFile(MedwanQuery.getInstance().getConfigString("dhis2_truststore","/temp/keystore"));
        sslConfig.keyPassword(MedwanQuery.getInstance().getConfigString("dhis2_truststore_pass","changeme"));
     
        SSLContext sslContext = sslConfig.createSSLContext();
        
        Client client = ClientBuilder.newBuilder().sslContext(sslContext).build();
        client.property(ClientProperties.CONNECT_TIMEOUT, 10000);
        client.property(ClientProperties.READ_TIMEOUT, 60000);
        
        // authentication
        // see jersey.java.net/apidocs/2.17/jersey/org/glassfish/jersey/client/authentication/HttpAuthenticationFeature.html
        HttpAuthenticationFeature feature = HttpAuthenticationFeature.basic(this.getUserName(), this.getUserPassword());
        client.register(feature);
        
        WebTarget target = client.target(this.getUrl()).path("dataValueSets");
        System.out.println("URL="+this.getUrl());  // to check where it was sent
        
        // see stackoverflow.com/questions/27284046/

        Response postResponse = target.request(MediaType.APPLICATION_XML).post(Entity.xml(dataValueSet));
        
        return postResponse;
    }
    
}
