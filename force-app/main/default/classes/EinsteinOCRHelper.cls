public with sharing class EinsteinOCRHelper 
{
    private static string AccountId = '';
    private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';

    public static string ContructHttpRequest(string filename) 
    {
        string authToken = AuthHelper.getAccessToken();
        system.debug(authToken);
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + authToken);
        request.setHeader('Cache-Control', 'no-cache');
        request.setHeader('Content-Type', GetContentType());
        request.setBodyAsblob(build(filename));
        request.setMethod('POST');
        
        request.setEndpoint('https://api.einstein.ai/v2/vision/ocr');
        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        
        string responseStr = response.getBody();
        system.debug(responseStr);

        if(!string.isNullOrEmpty(AccountId))
        {
            Attachment sr = new Attachment();
            sr.Body = response.getBodyAsBlob();
            sr.Name = 'einstein_response' + DateTime.Now().format('MM-dd-yyyy-HH-mm-ss-ssss') + '.json';
            sr.ParentId = AccountId;
            insert sr;
        }

        return responseStr;
    }
    
    public static Blob build(string filename) {
        String body = '';
        body += WriteBoundary();
        body += WriteBodyParameter('modelId', 'OCRModel');
        body += WriteBoundary();
        body += WriteBodyParameter('sampleLocation', filename);
        body += WriteBoundary(EndingType.CrLf);
        Blob bodyBlob = EncodingUtil.base64Decode(body);
        
        return bodyBlob;
    }
    
    public static string WriteBoundary() 
    {
        string value = '--' + Boundary + '\r\n';
        blob valueBlob = blob.valueOf(value);
        return EncodingUtil.base64Encode(valueBlob);
    }
    
    public enum EndingType 
    {
        Cr,
        CrLf,
        None
    }
    
    public static string WriteBoundary(EndingType ending) 
    {
        string value = '';
        
        if (ending == EndingType.Cr) 
        {
            //  The file's base64 was padded with a single '=',
            //  so it was replaced with '\r'. Now we have to
            //  prepend the boundary with '\n' to complete
            //  the line break.
            value += '\n';
        } else if (ending == EndingType.None) 
        {
            //  The file's base64 was not padded at all,
            //  so we have to prepend the boundary with
            //  '\r\n' to create the line break.
            value += '\r\n';
        }
        //  Else:
        //  The file's base64 was padded with a double '=',
        //  so they were replaced with '\r\n'. We don't have to
        //  do anything to the boundary because there's a complete
        //  line break before it.
        
        value += '--' + Boundary + '--';
        
        blob valueBlob = blob.valueOf(value);
        
        return EncodingUtil.base64Encode(valueBlob);
    }
    
    public static string WriteBodyParameter(string key, string value) 
    {
        string contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
        string contentDispositionCrLf = contentDisposition + '\r\n\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        string contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        string content = SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
        string valueCrLf = value + '\r\n';
        blob valueCrLfBlob = blob.valueOf(valueCrLf);
        string valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        
        content += SafelyPad(value, valueCrLf64, '\r\n');
        
        return content;
    }
    
    public static String getBoundary() 
    {
        return Boundary;
    }
    
    public static string GetContentType() 
    {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
    }
    
    public static string SafelyPad(string value, string valueCrLf64, string lineBreaks) 
    {
        string valueCrLf = '';
        blob valueCrLfBlob = null;
        
        while (valueCrLf64.endsWith('=')) {
            value += ' ';
            valueCrLf = value + lineBreaks;
            valueCrLfBlob = blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }
        
        return valueCrLf64;
    }
}