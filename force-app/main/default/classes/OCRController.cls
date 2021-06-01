public with sharing class OCRController 
{
    @AuraEnabled(cacheable=false)
    public static OCRResult performOCRFromUpload(string name, string documentId, string recordId) 
    {
        return EinsteinOCRHelper.getDownloadUrl(documentId, recordId);
    }
}