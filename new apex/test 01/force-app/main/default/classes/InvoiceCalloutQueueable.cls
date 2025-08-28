public class InvoiceCalloutQueueable implements Queueable, Database.AllowsCallouts {
    
    String action;
    private Id invoiceId;

    public InvoiceCalloutQueueable(String action, Id invoiceId) {
        this.action = action; // bisa bikin enum untuk action, atau pisah class untuk create dan update
        this.invoiceId = invoiceId;
    }

    String externalId;
    public InvoiceCalloutQueueable(String action, Id invoiceId, String externalId) {
        this.action = action;
        this.invoiceId = invoiceId;
        this.externalId = externalId;
    }

    public void execute(QueueableContext context) {
        System.debug('Executing InvoiceCalloutQueueable with action: ' + action + ' for invoice ID: ' + invoiceId);

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
        req.setTimeout(120000);

        if (action == 'create') {
            System.debug('Creating new payment for invoice ID: ' + invoiceId);

            req.setEndpoint('https://b80fe75a974b.ngrok-free.app/payments');
            req.setMethod('POST');
            req.setBody(JSON.serialize(paymentData));

            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                if (res.getStatusCode() == 201) {
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
        } else if (action == 'update') {
            System.debug('Updating payment for invoice ID: ' + invoiceId + ' with External_Id__c: ' + invoice.External_Id__c);

            req.setEndpoint('https://b80fe75a974b.ngrok-free.app/payments/' + invoice.External_Id__c);
            req.setMethod('PATCH');
            req.setBody(JSON.serialize(paymentData));

            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                if (res.getStatusCode() == 200) {
                    System.debug('Payment updated successfully: ' + res.getBody());

                    // Update the field sesuai dengan inputan user di salesforce
                } else {
                    System.debug('Failed to update payment: ' + res.getBody());
                    throw new CalloutException('Failed to update payment: ' + res.getBody());
                }
            } catch (Exception e) {
                System.debug('Error updating payment: ' + e.getMessage());
                throw new CalloutException('Failed to update payment: ' + e.getMessage());
            }
        } else if (action == 'delete') {
            System.debug('Delete payment for invoice ID: ' + invoiceId + ' with External_Id__c: ' + invoice.External_Id__c);

            req.setEndpoint('https://b80fe75a974b.ngrok-free.app/payments/' + invoice.External_Id__c);
            req.setMethod('DELETE');

            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                if (res.getStatusCode() == 204 || res.getStatusCode() == 404) {
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
}