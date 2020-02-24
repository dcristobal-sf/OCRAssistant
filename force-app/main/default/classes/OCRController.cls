public with sharing class OCRController 
{
    @AuraEnabled(cacheable=true)
    public static string performOCR(string url) 
    {
        return EinsteinOCRHelper.ContructHttpRequest(url);
    }
}