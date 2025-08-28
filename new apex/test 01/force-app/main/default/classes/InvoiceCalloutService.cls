public without sharing class InvoiceCalloutService {

    public static void createOrUpdatePayment(Id invoiceId, String action) {
        // Ambil Data Invoice dari Salesforce
        Invoice__c invoice = [
            SELECT Id, External_Id__c, Amount__c, CurrencyIsoCode,
                   Status__c, Payment_Method__c, Payment_Method_Detail__c,
                   Account__r.Name, Account__r.Phone, Account__r.Fax,
                   Payment_Date__c, Expired_Date__c
            FROM Invoice__c
            WHERE Id = :invoiceId
            LIMIT 1
        ];

        // paymentData sebagai payload JSON
        Map<String, Object> paymentData = new Map<String, Object>{
            'amount' => invoice.Amount__c,
            'currency' => invoice.CurrencyIsoCode,
            'status' => invoice.Status__c,
            'payment_method' => invoice.Payment_Method__c,
            'description' => invoice.Payment_Method_Detail__c,
            'customer' => invoice.Account__c != null ? new Map<String, Object>{
                'fullname' => invoice.Account__r.Name,
                'phone' => invoice.Account__r.Phone,
                'email' => invoice.Account__r.Fax
            } : null,
            'expired_date' => invoice.Expired_Date__c,
            'payment_date' => invoice.Payment_Date__c
        };

        // Set up HttpRequest
        String endpoint = 'https://b80fe75a974b.ngrok-free.app/payments';
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');

        // Set endpoint and method based on action
        if (action == 'create') {
            req.setEndpoint(endpoint);
            req.setMethod('POST');
        } else if (action == 'update') {
            req.setEndpoint(endpoint + '/' + invoice.External_Id__c);
            req.setMethod('PATCH');
        }

        req.setBody(JSON.serialize(paymentData));

        // Send the request and handle the response
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode().toString().startsWith('2')) {
                System.debug('Success: ' + res.getBody());

                if (action == 'create') {
                    // Update External_Id__c field with response ID
                    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    invoice.External_Id__c = (String) responseBody.get('id');
                    Database.update(invoice, false);
                }
            } else {
                throw new CalloutException('Failed: ' + res.getBody());
            }
        } catch (Exception e) {
            throw new CalloutException('Error: ' + e.getMessage());
        }
    }

    public static void deletePayment(String externalId) {
        // Set up HttpRequest for DELETE
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://b80fe75a974b.ngrok-free.app/payments/' + externalId);
        req.setMethod('DELETE');
        req.setTimeout(120000);

        // Send the request and handle the response
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (!res.getStatusCode().toString().startsWith('2')) {
                throw new CalloutException('Failed to delete payment: ' + res.getBody());
            }
        } catch (Exception e) {
            throw new CalloutException('Error deleting payment: ' + e.getMessage());
        }
    }
}