public with sharing class OCRResult 
{
    @AuraEnabled
    public string imageBase64 { get; set; }

    @AuraEnabled
    public string imageType { get; set; }

    @AuraEnabled
    public string result { get; set; }

}
