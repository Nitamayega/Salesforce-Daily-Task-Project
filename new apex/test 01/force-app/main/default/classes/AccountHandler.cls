public class AccountHandler {
    public static Account insertNewAccount(String accountName) {
        // Jika input kosong, langsung return null
        if (String.isBlank(accountName)) {
            return null;
        }

        try {
            Account acc = new Account(Name = accountName);
            insert acc;
            return acc;
        } catch (DmlException e) {
            return null;
        }
    }
}