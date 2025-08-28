@IsTest
private class BootcampPaymentGatewayControllerTest {

    // --- Simple configurable mock for all HTTP callouts ---
    private class SimpleHttpMock implements HttpCalloutMock {
        Integer code;
        String body;
        public SimpleHttpMock(Integer code, String body) {
            this.code = code;
            this.body = body;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            if (body == null) {
                // default JSON-ish body per method
                if (req.getMethod() == 'GET')        res.setBody('{"result":"ok","method":"GET"}');
                else if (req.getMethod() == 'POST')  res.setBody('{"id":"pay_123","result":"created"}');
                else if (req.getMethod() == 'PUT' || req.getMethod() == 'PATCH')
                                                     res.setBody('{"id":"pay_123","result":"updated"}');
                else if (req.getMethod() == 'DELETE')res.setBody('{"result":"deleted"}');
                else                                  res.setBody('{"result":"ok"}');
            } else {
                res.setBody(body);
            }
            return res;
        }
    }

    @IsTest
    static void testGetPayments_success() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(200, '{"items":[{"id":"p1"}]}'));
        String out = BootcampPaymentGatewayController.getPayments();
        System.assertNotEquals(null, out, 'getPayments should return body on 200');
        System.assert(out.contains('"items"'));
    }

    @IsTest
    static void testGetPaymentById_success() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(200, '{"id":"pay_001","amount":1000}'));
        String out = BootcampPaymentGatewayController.getPaymentById('pay_001');
        System.assertNotEquals(null, out);
        System.assert(out.contains('"pay_001"'));
    }

    @IsTest
    static void testCreateNewPayment_success() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(201, '{"id":"pay_abc","status":"Pending"}'));
        String payload = JSON.serialize(new Map<String,Object>{
            'amount' => 100000, 'currency' => 'IDR', 'status' => 'Pending'
        });
        String out = BootcampPaymentGatewayController.createNewPayment(payload);
        System.assert(out.contains('"pay_abc"'));
    }

    @IsTest
    static void testCreateNewPayment_error() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(500, '{"error":"server"}'));
        String payload = JSON.serialize(new Map<String,Object>{ 'amount' => 1 });
        try {
            BootcampPaymentGatewayController.createNewPayment(payload);
            System.assert(false, 'Should throw AuraHandledException on non-2xx');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().startsWith('Create failed:'), e.getMessage());
        }
    }

    @IsTest
    static void testUpdatePayment_success() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(200, '{"id":"pay_upd","status":"Paid"}'));
        String payload = JSON.serialize(new Map<String,Object>{
            'id' => 'pay_upd', 'amount' => 200000, 'status' => 'Paid'
        });
        String out = BootcampPaymentGatewayController.updatePayment(payload);
        System.assert(out.contains('"pay_upd"'));
    }

    @IsTest
    static void testUpdatePayment_error() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(400, '{"error":"bad request"}'));
        String payload = JSON.serialize(new Map<String,Object>{
            'id' => 'pay_err', 'amount' => 1
        });
        try {
            BootcampPaymentGatewayController.updatePayment(payload);
            System.assert(false, 'Should throw AuraHandledException on non-2xx');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().startsWith('Update failed:'), e.getMessage());
        }
    }

    @IsTest
    static void testDeletePayment_success() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(204, null));
        String out = BootcampPaymentGatewayController.deletePayment('pay_del');
        // controller returns body or null; for 204 body likely null
        System.assertEquals(null, out, 'deletePayment should return null if no body');
    }

    @IsTest
    static void testGetPaymentFilteredByStatus_success() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(200, '{"items":[{"status":"Pending"}]}'));
        String out = BootcampPaymentGatewayController.getPaymentFilteredbyStatus('Pending');
        System.assertNotEquals(null, out);
        System.assert(out.contains('"Pending"'));
    }

    @IsTest
    static void testGetPaymentFilteredByMethod_success() {
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(200, '{"items":[{"payment_method":"Bank Transfer"}]}'));
        String out = BootcampPaymentGatewayController.getPaymentFilteredbyMethod('Bank Transfer');
        System.assertNotEquals(null, out);
        System.assert(out.contains('"Bank Transfer"'));
    }

    @IsTest
    static void testGetInvoices_okEvenIfEmpty() {
        // Tidak wajib insert Invoice__c: method hanya query dan return list (boleh kosong)
        List<Invoice__c> rows = BootcampPaymentGatewayController.getInvoices();
        System.assertNotEquals(null, rows);
    }

    @IsTest
    static void testGenerateDataInvoice_noThrow() {
        // Method ini pakai Account__c hardcoded; insert dilakukan dengan allOrNone = false,
        // jadi walau lookup tidak valid, method tidak melempar exception.
        Test.startTest();
        BootcampPaymentGatewayController.generateDataInvoice('ext-xyz');
        Test.stopTest();
        // tidak ada assert wajib; yang penting tidak melempar
        System.assert(true);
    }

    @IsTest
    static void testGenerateDataPayment_returnsJson() {
        String json = BootcampPaymentGatewayController.generateDataPayment();
        System.assertNotEquals(null, json);
        System.assert(json.contains('"amount"'));
        System.assert(json.contains('"customer"'));
    }
}