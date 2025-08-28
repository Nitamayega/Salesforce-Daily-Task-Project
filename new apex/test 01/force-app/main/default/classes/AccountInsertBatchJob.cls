global class AccountInsertBatchJob implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accountsToInsert = new List<Account>();

        for (Integer i = 0; i < 10; i++) {
            accountsToInsert.add(new Account(
                Name = 'New Batch Account ' + Datetime.now().getTime() + '-' + i,
                Industry = 'Super Technology',
                Phone = '0813' + String.valueOf(10000000 + i)
            ));
        }

        insert accountsToInsert;
        System.debug('Processed ' + accountsToInsert.size() + ' accounts.');
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job finished successfully.');
    }
}