trigger ContactTrigger on Contact (after insert, after update) {
    
    List<Account> accountsToUpdate = new List<Account>();
    
    for (Contact contact : Trigger.new) {
        
        if (contact.AccountId != null) {
            List<Account> relatedAccounts = [SELECT Id, (SELECT Id FROM Contacts), Contact_Count__c FROM Account WHERE Id = :contact.AccountId LIMIT 1];
            
            System.debug('Related Accounts: ' + relatedAccounts + ' Contact count __ c: ' + relatedAccounts[0].Contact_Count__c + ' contact count: ' + relatedAccounts[0].Contacts.size());
            
            if (relatedAccounts.size() > 0) {
                Account relatedAccount = relatedAccounts[0];
                Integer contactCount = relatedAccount.Contacts.size();
                relatedAccount.Contact_Count__c = contactCount;
                accountsToUpdate.add(relatedAccount);
            }
        }
    }
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}