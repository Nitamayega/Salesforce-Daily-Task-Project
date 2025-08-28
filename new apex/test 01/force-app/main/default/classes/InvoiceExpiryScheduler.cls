public class InvoiceExpiryScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        InvoiceExpiryService.updateExpiredInvoices();
    }
}