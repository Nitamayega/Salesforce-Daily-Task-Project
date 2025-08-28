@isTest
private class TestVerifyDate {
    @isTest
    static void testCheckDates() {
        Date date1 = Date.newInstance(2023, 10, 1);
        Date date2Within30Days = Date.newInstance(2023, 10, 15);
        Date date2Outside30Days = Date.newInstance(2023, 11, 2);
        
        // Test case where date2 is within 30 days
        Date result1 = VerifyDate.CheckDates(date1, date2Within30Days);
        System.assertEquals(date2Within30Days, result1, 'Expected date2 to be returned as it is within 30 days.');

        // Test case to set end of month of a given date
        Date expectedEndOfMonth = Date.newInstance(2023, 10, 31);
        Date result2 = VerifyDate.CheckDates(date1, date2Outside30Days);
        System.assertEquals(expectedEndOfMonth, result2, 'Expected end of month date to be returned as date2 is outside 30 days.');
    }
    
}