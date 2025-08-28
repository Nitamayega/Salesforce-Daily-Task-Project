trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List<Task> tasksToInsert = new List<Task>();
    Map<Id, Opportunity> oldMap = Trigger.isUpdate ? Trigger.oldMap : null;

    for (Opportunity opp : Trigger.new) {
        Boolean isClosedWon = (opp.StageName == 'Closed Won');

        // Hindari duplikasi saat update: hanya ketika berubah menjadi Closed Won
        Boolean justBecameClosedWon = !Trigger.isUpdate 
                                      || (oldMap.get(opp.Id).StageName != 'Closed Won' && isClosedWon);

        if (isClosedWon && justBecameClosedWon) {
            tasksToInsert.add(new Task(
                Subject = 'Follow Up Test Task',
                WhatId  = opp.Id,           // associate ke Opportunity
                Status  = 'Not Started',
                Priority= 'Normal'
            ));
        }
    }

    if (!tasksToInsert.isEmpty()) {
        insert tasksToInsert;
    }
}