@isTest
public class AccountManagerTest {
    
    // 1
    @isTest
    static void testCreateAccount() {
        AccountManager.createAccount('Test Account', 'Web', 'Technology', 'externalId123');
        
        // Assert
        Account createdAccount = [SELECT Name, AccountSource, Industry, externalId__c FROM Account LIMIT 1];
        System.assertEquals('Test Account', createdAccount.Name);
        System.assertEquals('Web', createdAccount.AccountSource);
        System.assertEquals('Technology', createdAccount.Industry);
        System.assertEquals('externalId123', createdAccount.externalId__c);
    }
    
    // 2
    @isTest
    static void testUpdateAccount() {
        AccountManager.createAccount('Test Account', 'Web', 'Technology', 'externalId123');
        AccountManager.updateAccount('Updated Account', 'Phone', 'Finance', 'externalId123');
        
        // Assert
        Account updatedAccount = [SELECT Name, AccountSource, Industry FROM Account WHERE externalId__c = 'externalId123'];
        System.assertEquals('Updated Account', updatedAccount.Name);
        System.assertEquals('Phone', updatedAccount.AccountSource);
        System.assertEquals('Finance', updatedAccount.Industry);
    }
    
    // 3
    @isTest
    static void testCreateAccountAndContact() {
        AccountManager.createAccountAndContact('Test Account', 'Web', 'Technology', 'Test Contact', '1234567890', 'test@example.com');
        
        // Assert
        Account createdAccount = [SELECT Id, Name, AccountSource, Industry FROM Account LIMIT 1];
        System.assertEquals('Test Account', createdAccount.Name);
        System.assertEquals('Web', createdAccount.AccountSource);
        System.assertEquals('Technology', createdAccount.Industry);
        
        Contact createdContact = [SELECT Id, LastName, Phone, Email, AccountId FROM Contact LIMIT 1];
        System.assertEquals(createdAccount.Id, createdContact.AccountId);
        System.assertEquals('Test Contact', createdContact.LastName);
        System.assertEquals('1234567890', createdContact.Phone);
        System.assertEquals('test@example.com', createdContact.Email);
    }
    
    // 4
    @isTest
    static void testUpdateContactCount() {
        Account acc = new Account(Name='Test Account', Industry='Technology');
        insert acc;

        Contact con1 = new Contact(LastName='Contact 1', Phone='1234567890', Email='contact1@example.com', AccountId=acc.Id);
        Contact con2 = new Contact(LastName='Contact 2', Phone='0987654321', Email='contact2@example.com', AccountId=acc.Id);
        insert new List<Contact>{con1, con2};

        List<Integer> count = AccountManager.updateContactCount();
        System.assertEquals(2, count[0]);
        
    }
    
    // 5
    @isTest
    static void testCreateSampleAccounts() {
        AccountManager.createSampleAccounts();
        System.assertEquals(4, [SELECT COUNT() FROM Account WHERE Name IN ('Spv A', 'Spv B', 'Spv C', 'SPV None')]);
    }
    
    @isTest
    static void testMapAccountLookupByIndustry() {
        AccountManager.createSampleAccounts();
        Account_Mapping__c mapping1 = new Account_Mapping__c(Industry__c='Technology');
        Account_Mapping__c mapping2 = new Account_Mapping__c(Industry__c='Finance');
        Account_Mapping__c mapping3 = new Account_Mapping__c(Industry__c='Healthcare');
        insert new List<Account_Mapping__c>{mapping1, mapping2, mapping3};
            
            AccountManager.mapAccountLookupByIndustry();
        
        System.assertNotEquals(null, [SELECT Account__c FROM Account_Mapping__c WHERE Industry__c = 'Technology' LIMIT 1].Account__c);
    }
    
    // 6
    @isTest
    static void testDebugAccountsBySource() {
        AccountManager.createAccount('Test Account A', 'Web', 'Technology', 'externalIdA');
        AccountManager.createAccount('Test Account B', 'Phone', 'Finance', 'externalIdB');
        
        System.assertEquals(2, [SELECT COUNT() FROM Account WHERE AccountSource IN ('Web', 'Phone')]);
        
        AccountManager.debugAccountsBySource('Web');
        AccountManager.debugAccountsBySource('Phone');
    }
    
    // 7
    @isTest
    static void testDebugContactsByAccountSource() {
        Account acc = new Account(Name='Test Account', AccountSource='Web', Industry='Technology');
        insert acc;
        
        Contact con1 = new Contact(LastName='Contact 1', Phone='1234567890', Email='contact1@example.com', AccountId=acc.Id);
        Contact con2 = new Contact(LastName='Contact 2', Phone='0987654321', Email='contact2@example.com', AccountId=acc.Id);
        insert new List<Contact>{con1, con2};
            
            AccountManager.debugContactsByAccountSource('Web');
    }
}