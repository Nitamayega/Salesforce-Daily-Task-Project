global class InvoiceCallout {

    @future(callout=true)
    public static void createNewPayment(String invoiceId) {
        System.debug('Creating new payment for invoice ID: ' + invoiceId);

        Invoice__c invoice = [
            SELECT Id, External_Id__c, Amount__c, CurrencyIsoCode,
                Status__c, Payment_Method__c, Payment_Method_Detail__c,
                Account__r.Name, Account__r.Phone, Account__r.Fax,
                Payment_Date__c, Expired_Date__c
            FROM Invoice__c
            WHERE Id = :invoiceId
            LIMIT 1
        ];

        System.debug('Invoice details: ' + invoice);

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

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://b80fe75a974b.ngrok-free.app/payments');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setBody(JSON.serialize(paymentData));

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode().toString().startsWith('2')) {
                System.debug('Payment created successfully: ' + res.getBody());

                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                invoice.External_Id__c = (String) responseBody.get('id');
                Database.update(invoice, false);

                System.debug('Invoice updated with External_Id__c: ' + invoice.External_Id__c);
                } else {
                System.debug('Failed to create payment: ' + res.getBody());
                throw new CalloutException('Failed to create payment: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error creating new payment: ' + e.getMessage());
            throw new CalloutException('Failed to create new payment: ' + e.getMessage());
        }
    }

    @future(callout=true)
    public static void updatePayment(String invoiceId) {
        System.debug('Updating payment for invoice ID: ' + invoiceId);

        Invoice__c invoice = [
            SELECT Id, External_Id__c, Amount__c, CurrencyIsoCode,
                Status__c, Payment_Method__c, Payment_Method_Detail__c,
                Account__r.Name, Account__r.Phone, Account__r.Fax,
                Payment_Date__c, Expired_Date__c
            FROM Invoice__c
            WHERE Id = :invoiceId
            LIMIT 1
        ];

        System.debug('Invoice details: ' + invoice);

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

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://b80fe75a974b.ngrok-free.app/payments/' + invoice.External_Id__c);
        req.setMethod('PATCH');
        req.setTimeout(120000);
        req.setBody(JSON.serialize(paymentData));

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode().toString().startsWith('2')) {
                System.debug('Payment updated successfully: ' + res.getBody());
            } else {
                System.debug('Failed to update payment: ' + res.getBody());
                throw new CalloutException('Failed to update payment: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error updating payment: ' + e.getMessage());
            throw new CalloutException('Failed to update payment: ' + e.getMessage());
        }
    }

    @future(callout=true)
    public static void deletePayment(String externalId) {
        System.debug('Deleting payment with External_Id__c: ' + externalId);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://b80fe75a974b.ngrok-free.app/payments/' + externalId);
        req.setMethod('DELETE');
        req.setTimeout(120000);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode().toString().startsWith('2')) {
                System.debug('Payment deleted or not found: ' + res.getBody());
            } else {
                System.debug('Failed to delete payment: ' + res.getBody());
                throw new CalloutException('Failed to delete payment: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error deleting payment: ' + e.getMessage());
            throw new CalloutException('Failed to delete payment: ' + e.getMessage());
        }
    }
}