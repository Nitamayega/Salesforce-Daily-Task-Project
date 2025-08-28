public with sharing class ButkemPaymentController {
    @AuraEnabled
    public static List<Invoice__c> getInvoice(){
        return [SELECT Id, Name, Status__c, Amount__c, Due_Date__c, Payment_Method__c 
        FROM Invoice__c
        ORDER BY CreatedDate DESC
        LIMIT 10];
    }
}