import { LightningElement, api, track } from 'lwc';

import getInvoices from '@salesforce/apex/BootcampPaymentGatewayController.getInvoices';
import saveRecord from '@salesforce/apex/BootcampPaymentGatewayController.createNewPayment';
import { fetchTableHeader } from './lwcPaymentBootcampUtil';

export default class LwcPaymentBootcamp extends LightningElement {

    // Penanda variabel global
    @api
    api;

    // Form Fields
    @track account;
    @track paymentMethod;
    @track status;
    @track currency;
    @track amount;
    @track paymentDate;
    @track expiredDate;
    @track paymentMethodDetail;

    // Selected Invoice
    @track selectedInvoice;

    // Modal Control
    @track showFormNew = false;
    @track isDetailMode = false;
    @track isEditMode = false;
    @track isEditOrDetailMode
    get isEditOrDetailMode() {
        return this.isDetailMode || this.isEditMode;
    }

    // Loading State
    @track isLoading = false;
    @track isLoadingModal = false;

    connectedCallback() {
        this.getTableHeader();
        this.fetchInvoices();
    }

    disconnectedCallback() {

    }

    renderedCallback() {

    }

    // Call server side

    // Get table header
    @track tableHeaders = [];
    getTableHeader() {
        this.tableHeaders = fetchTableHeader();
        console.log('Table headers:', this.tableHeaders);
    }

    // Get all salesforce invoice records
    @track invoices;
    fetchInvoices() {
        getInvoices()
            .then((result) => {
                if (result.length > 0) {

                    // Dapatkan data Account Name


                    this.invoices = result.map((inv) => ({
                        ...inv,
                        customerName: inv.Account__r?.Name || ''
                    }));

                    console.log('Invoices fetched successfully:', result);
                    console.log('result:', JSON.stringify(result));
                    console.log('Customer Name:', result[0].Account__r?.Name);
                }
            }).catch((err) => {
                console.error('Error fetching invoices:', err);
            });
    }

    saveRecord() {
        const jsonData = {
            customer: {
                fullName: this.account
            },
            payment_method: this.paymentMethod,
            status: this.status,
            currency: this.currency,
            amount: this.amount,
            paid_date: this.paymentDate,
            due_date: this.expiredDate,
            description: this.paymentMethodDetail
        };

        console.log('Saving invoice with:', jsonData);

        createNewPayment({ data: JSON.stringify(jsonData) })
            .then((result) => {
                console.log('Record saved successfully:', result);

                // Show toast
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: '🎉 Boom! New invoice just dropped.',
                    variant: 'success'
                }));

                // Reset form/modal
                this.showFormNew = false;
                this.clearFields();
                this.fetchInvoices(); // pastikan method ini ada

            })
            .catch((error) => {
                console.error('Error saving invoice:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Something went wrong.',
                    variant: 'error'
                }));
            });
    }


    // Handle button click events
    handleClick(event) {
        const buttonName = event.target.name;
        console.log('Button clicked:', buttonName);

        switch (buttonName) {
            case 'btnNew':
                // Logic for creating a new invoice
                this.showFormNew = true;
                this.isEditMode = true;
                console.log('New invoice button clicked');
                break;

            case 'btnRefresh':
                this.fetchInvoices();
                break;

            case 'btnClose':
                // Logic for closing the modal or form
                this.showFormNew = false;
                this.isDetailMode = false;
                this.isEditMode = false;
                this.clearFields();
                console.log('Close button clicked');
                break;

            case 'btnUpdate':
                // Logic for updating an invoice
                this.showFormNew = true;
                this.isEditMode = true;
                console.log('Update invoice button clicked');
                break;

            case 'btnSave':
                // Logic for saving an invoice
                this.saveRecord();
                console.log('Save invoice button clicked');
                break;

            case 'btnDelete':
                // Logic for deleting an invoice
                console.log('Delete invoice button clicked');
                break;

            default:
                console.warn('Unknown button action:', buttonName);
        }
    }

    get modalTitle() {
        if (this.isDetailMode) {
            return 'Invoice Detail';
        } else if (this.isEditMode) {
            return 'Edit Invoice';
        }
        return 'New Invoice';
    }

    // Clear fields
    clearFields() {
        this.selectedInvoice = '';
        this.account = '';
        this.paymentMethod = '';
        this.status = '';
        this.currency = '';
        this.amount = '';
        this.paymentDate = '';
        this.expiredDate = '';
        this.paymentMethodDetail = '';
    }

}