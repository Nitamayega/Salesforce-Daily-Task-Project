public class AccountTriggerHandler extends TriggerHandler {
    
    protected override void beforeInsert() {
        
        beforeUpdsert();
        
    }
    
    protected override void beforeUpdate() {
        
        beforeUpdsert();
        
    }
    
    protected override void afterInsert() {
        
        for (Account account : (List<Account>) Trigger.new) {
            if (account.Type == 'Prospect') {
                Opportunity newOpportunity = new Opportunity(
                    Name = account.Name + ' Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = System.today().addDays(30),
                    AccountId = account.Id
                );
                insert newOpportunity;
            }
        }
        
    }
    
    private void beforeUpdsert() {
        for (Account account : (List<Account>) Trigger.new) {
            if (String.isBlank(account.Industry) || account.Industry == '--None--') {
                account.addError('Industry cannot be empty.');
            }
            
            List<Account> existingAccounts = [SELECT Id FROM Account WHERE Industry = :account.Industry AND Id != :account.Id];
            if (existingAccounts.size() > 0) {
                account.addError('An account with this Industry already exists.');
            }
            
            if (String.isBlank(account.Phone)) {
                account.addError('Phone number cannot be empty.');
            }
            
            Account existingAccount = null;
            if (account.AccountNumber != null) {
                List<Account> matches = [
                    SELECT Id
                    FROM Account
                    WHERE AccountNumber = :account.AccountNumber
                    LIMIT 1
                ];
                if (!matches.isEmpty()) existingAccount = matches[0];
            }
    
            if (existingAccount != null && existingAccount.Id != account.Id) {
                account.ParentId = existingAccount.Id;
            }
            
        }
    }
}