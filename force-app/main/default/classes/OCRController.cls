public with sharing class OCRController 
{
    @AuraEnabled(cacheable=false)
    public static OCRResult performOCRFromUpload(string name, string documentId) 
    {
        return EinsteinOCRHelper.getDownloadUrl(name, documentId);
    }
}