public class InvoiceTriggerHandler extends TriggerHandler {
    protected override void afterInsert() {
        for (Invoice__c invoice : (List<Invoice__c>) Trigger.new) {
            // InvoiceCallout.createNewPayment(invoice.Id);
            // System.enqueueJob(new InvoiceCalloutQueueable(invoice.Id));
            // System.enqueueJob(new InvoiceCalloutQueueable('create', invoice.Id));
            InvoiceCalloutController.createPaymentFuture(invoice.Id);
        }
    }

    // protected override void afterUpdate() {
    //     for (Invoice__c invoice : (List<Invoice__c>) Trigger.new) {
    //         System.enqueueJob(new InvoiceCalloutQueueable('update', invoice.Id));
    //     }
    //     // InvoiceCallout.updatePayment(invoice.Id);
    // }

    protected override void afterUpdate() {
        List<Invoice__c> newList = (List<Invoice__c>) Trigger.new;
        List<Invoice__c> oldList = (List<Invoice__c>) Trigger.old;

        for (Integer i = 0; i < newList.size(); i++) {
            Invoice__c newInv = newList[i];
            Invoice__c oldInv = oldList[i];

            if (
                oldInv.Status__c != newInv.Status__c ||
                oldInv.Amount__c != newInv.Amount__c ||
                oldInv.Payment_Method__c != newInv.Payment_Method__c ||
                oldInv.Payment_Method_Detail__c != newInv.Payment_Method_Detail__c ||
                oldInv.Payment_Date__c != newInv.Payment_Date__c ||
                oldInv.Expired_Date__c != newInv.Expired_Date__c
            ) {
                InvoiceCalloutController.updatePaymentFuture(newInv.Id);
            }
        }
    }


    protected override void afterDelete() {
        for (Invoice__c invoice : (List<Invoice__c>) Trigger.old) {
            // System.enqueueJob(new InvoiceCalloutQueueable('delete', invoice.Id, invoice.External_Id__c));
            // InvoiceCallout.deletePayment(invoice.External_Id__c);
            InvoiceCalloutController.deletePaymentFuture(invoice.External_Id__c);
        }
    }
}