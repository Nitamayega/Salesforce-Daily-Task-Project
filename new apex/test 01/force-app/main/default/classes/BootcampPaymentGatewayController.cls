public with sharing class BootcampPaymentGatewayController {
    // method untuk panggil BootcampPaymentGatewayService
    // melempar parameter valuenya dari parameter method ini
    // ini untuk lempar parameter value untuk nantinya BootcampPaymentGatewayService akan integrasi
    // di service ga boleh ada insert data, cukup callout api saja
    // insert invoice harus ketika status responsenya 200 OK
    // jika ada error, harus dilempar exception
    // jika responsnya 200 ok, maka insert invoice ke object di salesforce Invoice__c

    @AuraEnabled
    public static List<Invoice__c> getInvoices() {
        return [
            SELECT Id, Name, Account__c, Account__r.Name, Status__c, Amount__c
            FROM Invoice__c
            ORDER BY CreatedDate DESC
            LIMIT 10];
    }

    // ====================================

    // Apex hanya bisa mengembalikan string ke Lightning Component
    @AuraEnabled
    public static String getPayments() {
        HttpResponse res = BootcampPaymentGatewayService.getPayments();
        return res != null ? res.getBody() : null;
    }

    @AuraEnabled
    public static String getPaymentById(String payment_id) {
        HttpResponse res = BootcampPaymentGatewayService.getPaymentById(payment_id);
        return res != null ? res.getBody() : null;
    }

    @AuraEnabled
    public static String createNewPayment(String data) {
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(data);
            String body = JSON.serialize(parsed);

            HttpResponse res = BootcampPaymentGatewayService.createNewPayment(body);
            
            if (res.getStatusCode().toString().startsWith('2')) {
                return res.getBody();
            } else {
                throw new CalloutException('Failed to create invoice. Status: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Create failed: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String updatePayment(String data) {
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(data);
            String externalId = (String) parsed.get('id');
            String body = JSON.serialize(parsed);

            HttpResponse res = BootcampPaymentGatewayService.updatePayment(externalId, body);

            if (res.getStatusCode().toString().startsWith('2')) {
                return res.getBody();
            } else {
                throw new CalloutException('Failed to update invoice. Status: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Update failed: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String deletePayment(String payment_id) {
        HttpResponse res = BootcampPaymentGatewayService.deletePayment(payment_id);
        return res != null ? res.getBody() : null;
    }

    @AuraEnabled
    public static String getPaymentFilteredbyStatus(String status) {
        HttpResponse res = BootcampPaymentGatewayService.getPaymentFilteredbyStatus(status);
        return res != null ? res.getBody() : null;
    }

    @AuraEnabled
    public static String getPaymentFilteredbyMethod(String method) {
        HttpResponse res = BootcampPaymentGatewayService.getPaymentFilteredbyMethod(method);
        return res != null ? res.getBody() : null;
    }

    public static void generateDataInvoice(String extId) {
        Invoice__c inv = new Invoice__c();
        inv.Account__c = '001dM00002iYFVOQA4';
        inv.Amount__c = 100000;
        inv.Status__c = 'Pending';
        inv.Payment_Method__c = 'Bank Transfer';
        inv.Payment_Method_Detail__c = 'Payment for Bootcamp';
        inv.Expired_Date__c = Datetime.now().addDays(1);
        inv.Payment_Date__c = Datetime.now();
        inv.External_Id__c = extId;
        Database.insert(inv, false);
    }

    public static String generateDataPayment() {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeNumberField('amount', 100000);
        generator.writeStringField('currency', 'IDR');
        generator.writeStringField('status', 'Pending');
        generator.writeStringField('payment_method', 'Bank Transfer');
        generator.writeStringField('description', 'Payment for Bootcamp');
        generator.writeFieldName('customer');
        generator.writeStartObject();
        generator.writeStringField('fullName', 'Nits');
        generator.writeStringField('email', 'nits@gmail.com');
        generator.writeStringField('phone', '08123456789');
        generator.writeEndObject();
        generator.writeStringField('created_date', String.valueOf(System.now()));
        generator.writeEndObject();

        return generator.getAsString();
    }

}

/*
    Controller ini berisi handling, try catch, DML, send data ke Salesforce.
*/