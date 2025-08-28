trigger AccountMappingTrigger on Account_Mapping__c (before insert) {
    if (Trigger.isInsert && Trigger.isBefore) {
        AccountManager.assignAccounts(Trigger.new);
    }
}