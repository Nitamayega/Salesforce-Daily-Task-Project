@IsTest
private class OtherCSVTests {

    @TestSetup
    static void setupData() {
        List<Account> rows = Test.loadData(Account.SObjectType, 'otherAccountData');
        System.assertEquals(15, rows.size());
    }

    @IsTest
    static void testLoadOtherAccountsFromStaticResource() {
        Test.startTest();
        Integer cnt = [SELECT COUNT() FROM Account];
        Test.stopTest();
        System.assertEquals(15, cnt);
    }
}