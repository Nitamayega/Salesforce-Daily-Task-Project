public class ContactAndLeadSearch {
    public static List<List<sObject>> searchContactsAndLeads(String nameKey) {
        // Gunakan SOSL: cari nama depan atau belakang
        List<List<sObject>> results = [FIND :nameKey IN NAME FIELDS 
                                       RETURNING Contact(Id, FirstName, LastName), 
                                                 Lead(Id, FirstName, LastName)];
        return results;
    }
}