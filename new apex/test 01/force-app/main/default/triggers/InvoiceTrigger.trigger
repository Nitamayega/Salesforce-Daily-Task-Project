trigger InvoiceTrigger on Invoice__c (after insert, after update, after delete) {
    new InvoiceTriggerHandler().run();
}