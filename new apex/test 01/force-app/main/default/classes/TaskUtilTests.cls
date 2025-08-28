@isTest
public class TaskUtilTests {

    @isTest
    static void testGetTaskPriorityNormal() {
        String leadState = 'NY';
        
        Test.startTest();
        String result = TaskUtil.getTaskPriority(leadState);
        Test.stopTest();
        
        System.assertEquals('Normal', result, 'Expected Normal for non-CA state');
    }
    
    @isTest
    static void testGetTaskPriorityHigh() {
        String leadState = 'CA';
        
        Test.startTest();
        String result = TaskUtil.getTaskPriority(leadState);
        Test.stopTest();
        
        System.assertEquals('High', result, 'Expected High for CA state');
    }
}