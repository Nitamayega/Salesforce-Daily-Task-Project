@isTest
public class TestRestrictContactByName {

    @isTest
    static void testInsertValidContact() {
        Contact validContact = new Contact(FirstName='John', LastName='Doe');
        Test.startTest();
        insert validContact;
        Test.stopTest();
        
        System.assertNotEquals(null, validContact.Id);
    }

    @isTest
    static void testInsertInvalidContact() {
        Contact invalidContact = new Contact(FirstName='Jane', LastName='INVALIDNAME');
        
        Test.startTest();
        try {
            insert invalidContact;
            System.assert(false, 'Expected an exception for invalid LastName');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The Last Name "INVALIDNAME" is not allowed'));
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateInvalidContact() {
        Contact validContact = new Contact(FirstName='Alice', LastName='Smith');
        insert validContact;

        validContact.LastName = 'INVALIDNAME';
        Test.startTest();
        try {
            update validContact;
            System.assert(false, 'Expected an exception on update for invalid LastName');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The Last Name "INVALIDNAME" is not allowed'));
        }
        Test.stopTest();
    }
}