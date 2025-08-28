@isTest
public class VisitCounterTest {
    
    @isTest
    static void testCountActualVisit() {
        // 1. Buat Account dummy
        Account acc1 = new Account(Name = 'Account A', Industry = 'Technology');
        Account acc2 = new Account(Name = 'Account B', Industry = 'Technology');
        Account acc3 = new Account(Name = 'Account C', Industry = 'Technology');
        insert new List<Account>{acc1, acc2, acc3};
        
        // 2. Buat Target_Visit__c untuk ketiga account
        Target_Visit__c tv1 = new Target_Visit__c(Account__c = acc1.Id, Industry__c = 'Technology');
        Target_Visit__c tv2 = new Target_Visit__c(Account__c = acc2.Id, Industry__c = 'Technology');
        Target_Visit__c tv3 = new Target_Visit__c(Account__c = acc3.Id, Industry__c = 'Technology');
        insert new List<Target_Visit__c>{tv1, tv2, tv3};

        // 3. Buat Visit__c hanya untuk acc1 dan acc2
        Visit__c v1 = new Visit__c(Account__c = acc1.Id, Visit_Status__c = 'Completed');
        Visit__c v2 = new Visit__c(Account__c = acc1.Id, Visit_Status__c = 'Completed');
        Visit__c v3 = new Visit__c(Account__c = acc2.Id, Visit_Status__c = 'Completed');
        insert new List<Visit__c>{v1, v2, v3};

        VisitCounter.countActualVisit('Technology');

        // 4. Query ulang Target_Visit__c untuk lihat hasil update
        Map<Id, Target_Visit__c> updatedTargets = new Map<Id, Target_Visit__c>(
            [SELECT Id, Account__c, Actual_Visit__c FROM Target_Visit__c WHERE Account__c IN :new List<Id>{acc1.Id, acc2.Id, acc3.Id}]
        );

        // 5. Assert
        System.assertEquals(2, updatedTargets.get(tv1.Id).Actual_Visit__c, 'acc1 should have 2 visits');
        System.assertEquals(1, updatedTargets.get(tv2.Id).Actual_Visit__c, 'acc2 should have 1 visit');
        System.assertEquals(0, updatedTargets.get(tv3.Id).Actual_Visit__c, 'acc3 should have 0 visit');
    }
}