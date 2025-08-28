public with sharing class InvoiceExpiryService {

    public static void updateExpiredInvoices() {
        String query = 'SELECT Id, Payment_Date__c, Expired_Date__c, Status__c ' +
                       'FROM Invoice__c ' +
                       'WHERE Payment_Date__c > Expired_Date__c ' +
                       'AND Status__c != \'Expired\'';

        List<Invoice__c> expiredInvoices = Database.query(query);

        for (Invoice__c inv : expiredInvoices) {
            inv.Status__c = 'Expired';
        }

        if (!expiredInvoices.isEmpty()) {
            update expiredInvoices;
            System.debug('Updated ' + expiredInvoices.size() + ' invoice(s) to status "Expired".');
        } else {
            System.debug('No expired invoices found.');
        }
    }
}