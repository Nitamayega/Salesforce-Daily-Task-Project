public class ContactSearch {
    
    public static List<Contact> searchForContacts(String a, String b) {
        
        List<Contact> contact = [SELECT Id, Name FROM Contact WHERE LastName = :a AND MailingPostalCode = :b];
        return contact;
        
    }

}