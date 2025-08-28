public class AccountManager {
    
    // 1. Buat method untuk input Account dengan urutan parameter sebagai berikut : (accName, accSource, industry, externalId)
    public static void createAccount(String accName, String accSource, String industry, String externalId) {
        Account newAccount = new Account();
        newAccount.Name = accName;
        newAccount.AccountSource = accSource;
        newAccount.Industry = industry;
        newAccount.externalId__c = externalId;
        insert newAccount;

        System.debug('Account created: ' + newAccount.Id + ', Name: ' + newAccount.Name + ', Source: ' + newAccount.AccountSource + ', Industry: ' + newAccount.Industry);
    }

    // 2. Buat method untuk update Account dengan urutan parameter sebagai berikut : (accName, accSource, industry, externalId)
    public static void updateAccount(String accName, String accSource, String industry, String externalId) {
        List<Account> accountsToUpdate = [SELECT Id FROM Account WHERE externalId__c = :externalId];
        if (!accountsToUpdate.isEmpty()) {
            Account accToUpdate = accountsToUpdate[0];
            accToUpdate.Name = accName;
            accToUpdate.AccountSource = accSource;
            accToUpdate.Industry = industry;
            update accToUpdate;

            System.debug('Account updated: ' + accToUpdate.Id + ', Name: ' + accToUpdate.Name + ', Source: ' + accToUpdate.AccountSource + ', Industry: ' + accToUpdate.Industry);
        } else {
            System.debug('No account found with externalId: ' + externalId);
        }

    }

    // 3. Buat method untuk input Account dan Contact dengan urutan parameter sebagai berikut : (accName, accSource, industry, contactName, phone, mail)
    public static void createAccountAndContact(String accName, String accSource, String industry, String contactName, String phone, String mail) {

        Account newAccount = new Account(
            Name = accName,
            AccountSource = accSource,
            Industry = industry
        );
        
        insert newAccount;
    
        Contact newContact = new Contact(
            LastName = contactName,
            Phone = phone,
            Email = mail,
            AccountId = newAccount.Id
        );
        
        insert newContact;

        System.debug('Contact created: ' + newContact.Id + ', Name: ' + newContact.LastName + ', Phone: ' + newContact.Phone + ', Email: ' + newContact.Email);
    }

    // 4. Buat method untuk menghitung jumlah Contact yang ada di account dan update field 'Contact Count' di account (buat dulu fieldnya)
    public static List<Integer> updateContactCount() {
        List<Integer> countCon = new List<Integer>();
        List<Account> accountsToUpdate = [SELECT Id, (SELECT Id FROM Contacts) FROM Account];
        for (Account acc : accountsToUpdate) {
            Integer contactCount = acc.Contacts.size();
            acc.Contact_Count__c = contactCount;
            countCon.add(contactCount);
        }
        update accountsToUpdate;
        return countCon;
        
    }
    
    // 5. Buat 3 account dengan nama 'Spv A', 'Spv B', 'Spv C', 'SPV None'. Spv A, Spv B, dan Spv C memiliki Industry, SPV None kosong.
    // (Pastikan account lain tidak memiliki source yg sama). Buat object dengan nama 'Account Mapping' yang memiliki field Account (lookup),
    // industry (picklist kaya yg di account). Buat method untuk mengisi lookup Account saat insert Account Mapping berdasarkan field Industry. 
    // Jika tidak ketemu, lookup dengan SPV None.
    public static void createSampleAccounts() {
        List<Account> sampleAccounts = new List<Account>{
            new Account(Name='Spv A', Industry='Technology'),
            new Account(Name='Spv B', Industry='Finance'),
            new Account(Name='Spv C', Industry='Healthcare'),
            new Account(Name='SPV None')
        };
        insert sampleAccounts;

        System.debug('Sample accounts created: ' + sampleAccounts);
    }

    public static void mapAccountLookupByIndustry() {
        List<Account_Mapping__c> mappings = [SELECT Id, Industry__c, Account__c FROM Account_Mapping__c WHERE Account__c = null];
        List<Account> accounts = [SELECT Id, Industry, Name FROM Account WHERE Name IN ('Spv A', 'Spv B', 'Spv C', 'SPV None')];

        Map<String, Id> industryToAccount = new Map<String, Id>();
        Id spvNoneAccountId;
        
        for (Account acc : accounts) {
            if (acc.Industry != null) {
                industryToAccount.put(acc.Industry, acc.Id);
            }
            if (acc.Name == 'SPV None') {
                spvNoneAccountId = acc.Id;
            }
        }

        for (Account_Mapping__c m : mappings) {
            m.Account__c = industryToAccount.containsKey(m.Industry__c)
                ? industryToAccount.get(m.Industry__c)
                : spvNoneAccountId;
        }

        update mappings;
    }
    
    
    public static void assignAccounts(List<Account_Mapping__c> mappings) {
        Set<String> industries = new Set<String>();

        for (Account_Mapping__c m : mappings) {
            if (m.Industry__c != null && m.Account__c == null) {
                industries.add(m.Industry__c);
            }
        }

        List<Account> accounts = [
            SELECT Id, Name, Industry 
            FROM Account 
            WHERE Industry IN :industries OR Name = 'SPV None'
        ];

        Map<String, Id> industryToAccount = new Map<String, Id>();
        Id spvNoneId;

        for (Account acc : accounts) {
            if (acc.Industry != null) {
                industryToAccount.put(acc.Industry, acc.Id);
            }
            if (acc.Name == 'SPV None') {
                spvNoneId = acc.Id;
            }
        }

        for (Account_Mapping__c m : mappings) {
            if (m.Account__c == null && m.Industry__c != null) {
                m.Account__c = industryToAccount.containsKey(m.Industry__c)
                    ? industryToAccount.get(m.Industry__c)
                    : spvNoneId;
            }
        }
    }

    // 6. Buat method untuk memanggil data Account berdasarkan Source, return field Name, Source, Industry.
    // Munculkan data tersebut menggunakan System Debug
    public static void debugAccountsBySource(String source) {
        List<Account> accounts = [SELECT Name, AccountSource, Industry FROM Account WHERE AccountSource = :source];
        for (Account acc : accounts) {
            System.debug('Name: ' + acc.Name + ', Source: ' + acc.AccountSource + ', Industry: ' + acc.Industry);
        }

        if (accounts.isEmpty()) {
            System.debug('No accounts found with source: ' + source);
        }
    }

    // 7. Buat method untuk memanggil data Contact berdasarkan Account Source. Return field name, phone, mail.
    // Munculkan data tersebut menggunakan System Debug
    public static void debugContactsByAccountSource(String source) {
        List<Contact> contacts = [SELECT Name, Phone, Email FROM Contact WHERE Account.AccountSource = :source];
        for (Contact con : contacts) {
            System.debug('Name: ' + con.Name + ', Phone: ' + con.Phone + ', Email: ' + con.Email);
        }

        if (contacts.isEmpty()) {
            System.debug('No contacts found for accounts with source: ' + source);
        }
    }
}

    // Notes : Buat semua method hanya dalam 1 apex class saja. Buat field External Id di account, buat unique.