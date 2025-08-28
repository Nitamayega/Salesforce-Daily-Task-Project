@isTest
public class LeadTriggerTestCase {

    @isTest
    static void testIndustryAndLeadSourceConcatenation() {
        Lead testLead = new Lead(LastName = 'TriggerLead 01', Company = 'Test Company', Industry = 'Technology', LeadSource = 'Web');
        insert testLead;

        Lead insertedLead = [SELECT Concat_Field__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Technology - Web', insertedLead.Concat_Field__c);
    }

    @isTest
    static void testRatingToWarm() {
        Lead testLead = new Lead(LastName = 'TriggerLead 02', Company = 'Test Company', Status = 'Open - Not Contacted');
        insert testLead;

        Lead insertedLead = [SELECT Id, Status, Rating FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Open - Not Contacted', insertedLead.Status);

        testLead.Status = 'Working - Contacted';
        update testLead;

        Lead updatedLead = [SELECT Id, Status, Rating FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Working - Contacted', updatedLead.Status);
        System.assertEquals('Warm', updatedLead.Rating);
    }

    @isTest
    static void testRatingToCold() {
        Lead testLead = new Lead(LastName = 'TriggerLead 03', Company = 'Test Company', Status = 'Working - Contacted');
        insert testLead;

        Lead insertedLead = [SELECT Id, Status, Rating FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Working - Contacted', insertedLead.Status);

        testLead.Status = 'Closed - Not Converted';
        update testLead;

        Lead updatedLead = [SELECT Rating FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Closed - Not Converted', updatedLead.Status);
        System.assertEquals('Cold', updatedLead.Rating);
    }

}