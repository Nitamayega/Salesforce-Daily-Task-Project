public class AccountUtility {
    public static void viewAnnualRevenue() {
        // Query Account Name dan AnnualRevenue
        List<Account> accountsList = [
            SELECT Name, AnnualRevenue
            FROM Account
        ];

        // Loop dan cetak ke debug log
        for (Account acc : accountsList) {
            String acctRev = acc.Name + ' : ' + acc.AnnualRevenue;
            System.debug(acctRev);
        }
    }
}