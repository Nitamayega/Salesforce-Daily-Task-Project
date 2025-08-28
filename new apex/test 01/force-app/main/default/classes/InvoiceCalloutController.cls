public with sharing class InvoiceCalloutController {
    
    @future(callout=true)
    public static void createPaymentFuture(Id invoiceId) {
        InvoiceCalloutService.createOrUpdatePayment(invoiceId, 'create');
    }

    @future(callout=true)
    public static void updatePaymentFuture(Id invoiceId) {
        InvoiceCalloutService.createOrUpdatePayment(invoiceId, 'update');
    }

    @future(callout=true)
    public static void deletePaymentFuture(String externalId) {
        InvoiceCalloutService.deletePayment(externalId);
    }
    
}