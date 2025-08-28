public class RandomContactFactory {

    // Method to generate a list of random contacts
    public static List<Contact> generateRandomContacts(Integer numberOfContacts, String lastName) {
        List<Contact> contacts = new List<Contact>();

        // Loop to create unique first names
        for (Integer i = 0; i < numberOfContacts; i++) {
            Contact con = new Contact(
                FirstName = 'Test ' + i,
                LastName = lastName
            );
            contacts.add(con);
        }

        return contacts;
    }
}