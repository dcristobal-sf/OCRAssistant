public with sharing class AuthHelper 
{
    private static String BASE_URL = 'https://api.einstein.ai/v2';
    private static String OAUTH2 = BASE_URL + '/oauth2/token';
    
	public static String getAccessToken() 
    {
        EinsteinAI_Settings__c settings = EinsteinAI_Settings__c.getOrgDefaults();
        string email = settings.Einstein_EMail__c;
        List<ContentVersion> items = [SELECT Title, VersionData, CreatedBy.Email FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title];   
        
        if(!items.isEmpty())
        {
            ContentVersion base64Content = items.get(0);
            String keyContents = base64Content.VersionData.tostring();
            
            keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
            keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
            keyContents = keyContents.replace('\n', '');
            
            // Get a new token
            JWT jwt = new JWT('RS256');
            jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
            jwt.iss = 'developer.force.com';
            jwt.sub = email;
            jwt.aud = OAUTH2;
            jwt.exp = '3600';
            String accessToken = '';
            
            if (!Test.isRunningTest()) {
                accessToken = getAccessToken(OAUTH2, jwt);
            }
            
            return accessToken;    
        }
        
        return null;
    }
    
    public static String getAccessToken(String tokenEndpoint, JWT jwt) {
    
        String access_token = null;        
        String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt.issue();        
        
        HttpRequest req = new HttpRequest();                                   
        req.setMethod('POST');        
        req.setEndpoint(tokenEndpoint);        
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');        
        req.setBody(body);        
        
        Http http = new Http();                      
        HTTPResponse res = http.send(req);               
        if ( res.getStatusCode() == 200 ) 
        {            
            System.JSONParser parser = System.JSON.createParser(res.getBody());           
            while (parser.nextToken() != null) 
            {                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) 
                {                    
                    parser.nextToken();                    
                    access_token = parser.getText();                    
                    break;                
                }            
            }        
        }        
        return access_token;
    }
}