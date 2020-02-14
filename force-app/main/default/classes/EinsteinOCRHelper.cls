public with sharing class EinsteinOCRHelper 
{
    private static string authToken;
    private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';
    
    
    public EinsteinOCRHelper(string p_authToken)
    {
        authToken = '';
    }
    
    public static void ContructHttpRequest(string filename) 
    {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer JFITKVSDKZAU4MSRLJIVOUCTLFCEOWCOKJBDGVCZIZDEGT2MKVCFAV2PKRFTKM2YJNLU4UBSIM3UCWCWKZCFETZWJJLDINCYK42ESN2OJRMTGSKGKBLFCVKVK5CEYM2LGVHEUNKYGJAUYNBXJY2E2TJSGRDVARKTKZJES7COIE');
        request.setHeader('Cache-Control', 'no-cache');
        request.setHeader('Content-Type', GetContentType());
        request.setBodyAsblob(build('https://s.toptests.co.uk/wp-content/uploads/2017/12/uk-driving-licence.jpg'));
        request.setMethod('POST');
        
        request.setEndpoint('https://api.einstein.ai/v2/vision/ocr');
        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        
        string responseStr = response.getBody();
        system.debug(responseStr);
        
        /*Attachment sr = new Attachment();
sr.Body = body;
sr.Name = 'einstein_response.txt';
sr.ParentId = Id.valueOf('0017E000017R3FzQAK');
insert sr;*/
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
    
    public static string WriteBoundary() {
        string value = '--' + Boundary + '\r\n';
        blob valueBlob = blob.valueOf(value);
        
        return EncodingUtil.base64Encode(valueBlob);
    }
    
    public enum EndingType {
        Cr,
            CrLf,
            None
            }
    
    public static string WriteBoundary(
        EndingType ending) {
            string value = '';
            
            if (ending == EndingType.Cr) {
                //  The file's base64 was padded with a single '=',
                //  so it was replaced with '\r'. Now we have to
                //  prepend the boundary with '\n' to complete
                //  the line break.
                value += '\n';
            } else if (ending == EndingType.None) {
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
    
    public static string WriteBodyParameter(
        string key,
        string value) {
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
    
    public static String getBoundary() {
        return Boundary;
    }
    
    public static string GetContentType() {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
    }
    
    public static string SafelyPad(
        string value,
        string valueCrLf64,
        string lineBreaks) {
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