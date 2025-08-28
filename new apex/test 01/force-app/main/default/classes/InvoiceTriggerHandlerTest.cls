@IsTest
private class InvoiceTriggerHandlerTest {

    // Mock sederhana untuk semua HTTP callout yang mungkin dipanggil future
    private class DumbHttpMock implements HttpCalloutMock {
        Integer code; String body;
        DumbHttpMock(Integer c, String b){ code=c; body=b; }
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            res.setBody(body != null ? body : '{"id":"mock-id","result":"ok"}');
            return res;
        }
    }

    // Helper bikin Account (jaga-jaga kalau Invoice__c refer ke Account__c)
    private static Account makeAccount() {
        Account a = new Account(Name='Acct For Invoice', Industry='Technology', Phone='081234567890');
        insert a;
        return a;
    }

    // Helper bikin Invoice minimal sesuai field yang dipakai handler
    private static Invoice__c makeInvoice(Boolean withExternal) {
        Invoice__c inv = new Invoice__c();
        // Jika object Invoice__c punya lookup Account__c di org kamu, uncomment baris berikut:
        try {
            Account a = makeAccount();
            inv.put('Account__c', a.Id);
        } catch (Exception e) {
            // kalau tidak ada field Account__c, abaikan saja
        }
        inv.put('Amount__c', 100000);
        inv.put('Status__c', 'Pending');
        inv.put('Payment_Method__c', 'Bank Transfer');
        inv.put('Payment_Method_Detail__c', 'Init Payment');
        inv.put('Payment_Date__c', System.now());
        inv.put('Expired_Date__c', System.now().addDays(7));
        if (withExternal) inv.put('External_Id__c', 'ext-123');
        return inv;
    }

    @IsTest
    static void testAfterInsert_callsCreateFuture() {
        Test.setMock(HttpCalloutMock.class, new DumbHttpMock(201, '{"id":"pay-created"}'));
        Integer before = Limits.getFutureCalls();

        Test.startTest();
        insert makeInvoice(false);
        Test.stopTest();

        Integer after = Limits.getFutureCalls();
        System.assert(after > before, 'createPaymentFuture harus ter-enqueue pada afterInsert');
    }

    @IsTest
    static void testAfterUpdate_callsUpdateFutureOnChanges() {
        Test.setMock(HttpCalloutMock.class, new DumbHttpMock(200, '{"id":"pay-updated"}'));
        Invoice__c inv = makeInvoice(false);
        insert inv;

        Integer before = Limits.getFutureCalls();

        // Ubah beberapa field yang dipantau handler
        inv.put('Amount__c', 200000);
        inv.put('Status__c', 'Paid');
        update inv;

        Test.startTest();
        // tidak ada operasi tambahan; Test.stopTest akan menjalankan future yang sudah di-enqueue
        Test.stopTest();

        Integer after = Limits.getFutureCalls();
        System.assert(after > before, 'updatePaymentFuture harus ter-enqueue saat field kunci berubah');
    }

    @IsTest
    static void testAfterDelete_callsDeleteFuture() {
        Test.setMock(HttpCalloutMock.class, new DumbHttpMock(204, null));
        Invoice__c inv = makeInvoice(true);
        insert inv;

        Integer before = Limits.getFutureCalls();

        Test.startTest();
        delete inv;   // afterDelete di handler memanggil deletePaymentFuture(External_Id__c)
        Test.stopTest();

        Integer after = Limits.getFutureCalls();
        System.assert(after > before, 'deletePaymentFuture harus ter-enqueue pada afterDelete');
    }
}