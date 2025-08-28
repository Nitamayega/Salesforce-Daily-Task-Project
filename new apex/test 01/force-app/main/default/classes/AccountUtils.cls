public class AccountUtils {

    public static List<Account> accountsByState(String stateAbbreviation) {
        List<Account> accounts = [SELECT Id, Name FROM Account 
            WHERE BillingState = :stateAbbreviation];
        return accounts;
    }
}