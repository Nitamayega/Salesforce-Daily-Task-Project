public class VisitCounter {
    
    public static void countActualVisit(String industry) {
        List<Target_Visit__c> targetVisit = [
            SELECT Account__c, Actual_Visit__c
            FROM Target_Visit__c
            WHERE Industry__c = :industry
        ];

        if (targetVisit.isEmpty()) {
            System.debug('No target visits found for the specified industry: ' + industry);
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        for (Target_Visit__c visit : targetVisit) {
            accountIds.add(visit.Account__c);
        }

        List<Visit__c> visit = [
            SELECT Account__c
            FROM Visit__c 
            WHERE Visit_Status__c = 'Completed'
            AND Account__c IN :accountIds
        ];

        if (visit.isEmpty()) {
            System.debug('No completed visits found for the specified accounts.');
            return;
        }
        
        Map<Id, Integer> accountVisitCount = new Map<Id, Integer>();
        for (Visit__c v : visit) {
            if (accountVisitCount.containsKey(v.Account__c)) {
                accountVisitCount.put(v.Account__c, accountVisitCount.get(v.Account__c) + 1);
            } else {
                accountVisitCount.put(v.Account__c, 1);
            }
        }

        for (Target_Visit__c target : targetVisit) {
            target.Actual_Visit__c = accountVisitCount.get(target.Account__c) != null ? accountVisitCount.get(target.Account__c) : 0;
        }

        update targetVisit;

        System.debug('Actual visits updated successfully for industry: ' + industry);
        System.debug('Updated visit counts for accounts: ' + accountVisitCount + ' in industry: ' + industry + ' with total visits: ' + targetVisit.size());
    }
}