public with sharing class EinsteinOCRHelper 
{
    private static string AccountId = '';
    private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';
    private final static string RESULTADO = 'result';
    private final static string POSITIVO = 'positiv';
    private final static string NEGATIVO = 'negativ';
    private final static string PCR = 'pcr';
    private final static string ANTIGENO = 'antigen';
    private final static string VACUNA = 'vacuna';
    private final static string NA = 'N/A';
    

    public static OCRResult getDownloadUrl(string documentId, string covidRecordId)
    {
        List<ContentVersion> versions = [SELECT VersionData, FileType FROM ContentVersion WHERE ContentDocumentId =: documentId];

        if(!versions.isEmpty())
        {
			/*create ContentDocumentLink  record 
			ContentDocumentLink conDocLink = New ContentDocumentLink();
			conDocLink.LinkedEntityId = covidRecordId;
			conDocLink.ContentDocumentId = documentId;
			conDocLink.shareType = 'V';
			insert conDocLink;*/
            System.debug('Record: '+covidRecordId);
            return ContructHttpRequest(versions.get(0), documentId, covidRecordId);
        }

        return null;
    }

    //public static 
    
    public static OCRResult ContructHttpRequest(ContentVersion contentVersion, string documentId, string covidRecordId) 
    {
        string authToken = AuthHelper.getAccessToken();
        OCRResult res = new OCRResult();
        
        System.debug(authToken);
        
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + authToken);
        request.setHeader('Cache-Control', 'no-cache');
        request.setHeader('Content-Type', GetContentType());
        request.setBodyAsblob(build(contentVersion));
        request.setMethod('POST');
        
        request.setEndpoint('https://api.einstein.ai/v2/vision/ocr');
        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        
        res.imageBase64 = EncodingUtil.base64Encode(contentVersion.VersionData);
        res.imageType = contentVersion.FileType;
        
        List<Probability> keyWords = scanKeywords(response.getBody());
        
        //res.result = response.getBody();
        TestResult testResult = debugResult(keyWords);
        res.result = testResult.toString();
        res.text = resultBoundaries(keyWords);
        
        setTestStatus (covidRecordId, documentId, testResult.resultType, testResult.resultText);

        if(!string.isBlank(AccountId))
        {
            Attachment sr = new Attachment();
            sr.Body = response.getBodyAsBlob();
            sr.Name = 'einstein_response' + DateTime.Now().format('MM-dd-yyyy-HH-mm-ss-ssss') + '.json';
            sr.ParentId = AccountId;
            insert sr;
        }

        return res;
    }
    
    public static Blob build(ContentVersion contentVersion) {
        String body = '';
        body += WriteBoundary();
        body += WriteBodyParameter('modelId', 'OCRModel');
        body += WriteBoundary();
        //body += WriteBodyParameter('sampleLocation', filename);

        body += WriteBodyParameter('sampleBase64Content', EncodingUtil.base64Encode(contentVersion.VersionData));
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
    
    @future 
    public static void setTestStatus (string recordId, String documentId, String testType, String testResult) {
        
        List<COVID_Doc__c> docs = [SELECT Id, Status__c, Test_Type__c , Test_Result__c FROM COVID_Doc__c WHERE Id =: recordId];
        COVID_Doc__c ourDoc= docs.get(0);
        if(!testType.equals(NA)) {
            if(testType.equals(ANTIGENO)) {
                ourDoc.Test_Type__c = 'Antígeno';
            } else if(testType.equals(PCR)) {
                ourDoc.Test_Type__c = 'PCR';
            }
            if(testResult.equals(POSITIVO)) {
                ourDoc.Test_Result__c = 'Positivo';
                ourDoc.Status__c = 'Processed';
            } else if(testResult.equals(NEGATIVO)) {
                ourDoc.Test_Result__c = 'Negativo';
                ourDoc.Status__c = 'Processed';
            } else {
                ourDoc.Status__c = 'Review Needed';
            }
        } else {
            ourDoc.Status__c = 'Review Needed';
        }
        update ourDoc;
        
        //Create ContentDocumentLink
		ContentDocumentLink cDe = new ContentDocumentLink();
		cDe.ContentDocumentId = documentId;
		cDe.LinkedEntityId = ourDoc.Id; // you can use objectId,GroupId etc
		cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
		cDe.Visibility = 'InternalUsers';
		insert cDe;
    }
    
    public static List<Probability> scanKeywords (string result) {
        JSONParser parser = JSON.createParser(result);
        boolean takeNext = true;
        List<Probability> probabilityList = new List<Probability>();
        Probability prob = null;
        while (parser.nextToken() != null) {
        	if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
            		if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    	prob = (Probability)parser.readValueAs(Probability.class);
                    	// For debugging purposes, serialize again to verify what was parsed.
                    	//String s = JSON.serialize(prob);
                    	//system.debug('Serialized probability: ' + prob);
                        if(prob.label.containsIgnoreCase(RESULTADO)) {
                            prob.label = RESULTADO;
                            probabilityList.add(prob);
                        }
                        else if(prob.label.containsIgnoreCase(POSITIVO)) {
                            prob.label = POSITIVO;
                            probabilityList.add(prob);
                        }
                        else if(prob.label.containsIgnoreCase(NEGATIVO)) {
                            prob.label = NEGATIVO;
                            probabilityList.add(prob);
                        }
                        else if(prob.label.containsIgnoreCase(PCR)) {
                            prob.label = PCR;
                            probabilityList.add(prob);
                        }
                        else if(prob.label.containsIgnoreCase(ANTIGENO)) {
                            prob.label = ANTIGENO;
                            probabilityList.add(prob);
                        }
                        else if(prob.label.containsIgnoreCase(VACUNA)) {
                            prob.label = VACUNA;
                            probabilityList.add(prob);
                        }
                    	// Skip the child start array and start object markers.
                    	parser.skipChildren();
                    }
                }
            }
        }
        return probabilityList;
    }
    
    public static TestResult debugResult (List<Probability> interestWords) {
        TestResult testResult = new TestResult();
        testResult.resultType = NA;
        integer result = 0;
        integer i = 0;
        
        for (Probability aProbability : interestWords) {
            if(aProbability.label.equals(PCR)) {
                if(testResult.resultType.equals(NA)) {
                    testResult.resultType = PCR;
                }
                integer internalResult = findPosNeg(aProbability.boundingBox,interestWords,i);
                if(internalResult != 0) {
                    testResult.resultType = PCR;
                }
                result = 20 * internalResult;
            } else if(aProbability.label.equals(ANTIGENO)) {
                if(testResult.resultType.equals(NA)) {
                    testResult.resultType = ANTIGENO;
                }
                integer internalResult = findPosNeg(aProbability.boundingBox,interestWords,i);
                if(internalResult != 0) {
                    testResult.resultType = ANTIGENO;
                }
                result = 20 * internalResult;
            }
            /*else if(aProbability.label.equals(VACUNA)) {
                if(type.equals(NA)) {
                    type = VACUNA;
                }
            }*/
            BoundingBox aBox = getBoundingBox(RESULTADO,interestWords);
            if(aBox != null) {
                //System.debug('**** find RESULTADO index: '+i);
           		result = result + findPosNeg(aBox,interestWords,i);
            }
            i = i+1;
		}
        if(result >0) {
            testResult.resultText = POSITIVO;
        } else if (result < 0) {
            testResult.resultText = NEGATIVO;
        }

        return testResult;
    }
        
    public static integer findPosNeg(BoundingBox boundingBox, List<Probability> interestWords, integer notThis) {
        integer i = 0;
        for (Probability aProbability : interestWords) {
            if(i != notThis) {
                if(aProbability.label.equals(POSITIVO)) {
                	if(sameRegion(boundingBox, aProbability.boundingBox)) {
                        //System.debug('Same region: '+aProbability.label);
                        return 1;
                	}
                } else if(aProbability.label.equals(NEGATIVO)) {
                    if(sameRegion(boundingBox, aProbability.boundingBox)) {
                        //System.debug('Same region: '+aProbability.label);
                        return -1;
                	}
                }
            }
            i=i+1;
        }
        //System.debug('Not same region');
        return 0;
    }
    
    
    public static BoundingBox getBoundingBox (string keyword, List<Probability> interestWords) {
        for (Probability aProbability : interestWords) {
            if(aProbability.label.equals(keyword)) {
               return aProbability.boundingBox;
            }
        }
        return null;
    }
    
    public static boolean sameRegion (BoundingBox boxA, BoundingBox boxB) {
        
        Integer midYA = (boxA.maxY-boxA.minY)/2+boxA.minY;  
        if(inLine(midYA, boxB)) {
            return true;
        } else {
            Integer midXA = (boxA.maxX-boxA.minX)/2+boxA.minX;
            if(piledUp (midXA, boxA, boxB)) {
            	return true;
            }
        }
        return false;
    }
    
    public static boolean piledUp (integer midX, BoundingBox containerUp, BoundingBox containerDown) {
        if(midX > containerDown.minX && midX < containerDown.maxX) {
            if((containerDown.minY - containerUp.maxY) < (3 * (containerUp.maxY - containerUp.minY))) {
                return true;
            }
        }
        return false;
    }
    
    public static boolean inLine (integer midY, BoundingBox containerRight) {
        if(midY > containerRight.minY && midY < containerRight.maxY) {
            return true;
        }
        return false;
    }
    
    public static string resultBoundaries(List<Probability> interestWords) {
        
        String reducedResult = '{"object":"predictresponse","probabilities":' + JSON.serialize(interestWords) + ',"task":"text"}';
        
        return reducedResult;
        
    }
    
    public class Probability {
    	public Double probability;
    	public String label;
    	BoundingBox boundingBox;
    
    	public Probability(Double probability, String label, BoundingBox boundingBox) {
        	probability = probability;
        	label = label;
        	boundingBox = boundingBox;
    	}
	}  
 
	public class BoundingBox {
    	public Integer minX;
        public Integer minY;
    	public Integer maxX;
        public Integer maxY;
	}
    
    public class TestResult {
        public string resultType;
        public string resultText;
        public override string toString() {
            return resultType + ' : ' + resultText;
        }
    }
}