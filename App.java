import java.nio.*;
import java.util.*;
import java.net.*;
import java.io.*;
import org.apache.http.*;

public class App 
{
    public static void main(String[] args) throws IOException {
        //String apiUrl = "https://apps.learnwebservices.com/services/hello"; // Your api/http link
        //String userName = "admin"; // Your username
        //String password = "adminpro"; // Your password
    
        //sendRequest(apiUrl, userName, password);
        //fileWriter("test");
        //System.out.println(args[0]);
        //System.out.println(args[1]);
        //HTTPGet(args[0],args[1]);
        //try{
        //   TestNTLMConnection (args[0]);
        //}catch (Exception e){
        //   System.out.println(e);
        //   System.out.println("Failed successfully");
        //}
        System.out.println("123: ");
         
        String url = args[0];
        String login = args[1];
        String password = args[2];

        CredentialsProvider credsProvider = new BasicCredentialsProvider();
        credsProvider.setCredentials(
            new AuthScope(AuthScope.ANY),
            new UsernamePasswordCredentials(login, password)
        );

        CloseableHttpClient client = HttpClients.custom()
            .setDefaultCredentialsProvider(credsProvider)
            .build();

        StringBuilder sb = new StringBuilder();
        sb.append("<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:obj=\"urn:microsoft-dynamics-schemas/codeunit/ObjectDesignAPI\" xmlns:x98=\"urn:microsoft-dynamics-nav/xmlports/x98902\">");
        sb.append("<soapenv:Header/>");
        sb.append("<soapenv:Body>");
        sb.append("<obj:GetObjectPermissions>");
        sb.append("<obj:objectPermissionApiP>");
        sb.append("<ObjectsList>");
        sb.append("<EntryID>1</EntryID>");
        sb.append("<ObjectID>36</ObjectID>");
        sb.append("<ObjectType>1</ObjectType>");
        sb.append("<PermissionStatus>0</PermissionStatus>");
        sb.append("</ObjectsList>");
        sb.append("</obj:objectPermissionApiP>");
        sb.append("</obj:GetObjectPermissions>");
        sb.append("</soapenv:Body>");
        sb.append("</soapenv:Envelope>");

        String soapXml = sb.toString();

        HttpPost httpPost = new HttpPost(url);
        httpPost.addHeader("Content-Type", "text/xml");
        httpPost.addHeader("SOAPAction", "urn:microsoft-dynamics-schemas/codeunit/ObjectDesignAPI:GetObjectPermissions");
        httpPost.setEntity(new StringEntity(soapXml, StandardCharsets.UTF_8));

        HttpResponse response = client.execute(httpPost);

        if (response.getStatusLine().getStatusCode() == 200) {
            HttpEntity entity = response.getEntity();
            String responseContent = EntityUtils.toString(entity);
            System.out.println(responseContent);    
        } else {
            System.out.println("Error: " + response.getStatusLine().getStatusCode());
        }
       
    }
  


    @Override
    public String toString() {
        return "App []";
    }
    
}

    

