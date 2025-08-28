({
    /**
     * Fetch latest Invoices from Apex Controller
     * Show spinner while loading and populate table if success
     */
    fetchInvoices: function (component) {
        // Show loading spinner
        component.set('v.isLoading', true);

        // Apex method call
        var actionFetchInvoice = component.get('c.getPayments');

        // Set callback for success/error handling
        actionFetchInvoice.setCallback(this, function (response) {
            // Get response state
            let state = response.getState();

            if (state === 'SUCCESS') {
                try {
                    var jsonBody = response.getReturnValue();
                    var parsed = JSON.parse(jsonBody); // <- JSON parsing disini

                    console.log("Invoice records:", parsed);
                    component.set("v.invoices", parsed.data); // Pastikan ini sesuai nama variabel

                } catch (error) {
                    console.error("Failed to parse JSON:", error.message);
                }
            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    let errorMessage = errors[0].message;
                }
            }

            component.set('v.isLoading', false);
        });

        // Enqueue the action to execute it
        $A.enqueueAction(actionFetchInvoice);
    },

    fetchInvoiceDetail: function (component, invoiceId) {
        // Show loading spinner
        component.set('v.isLoadingModal', true);

        // Apex method call
        var fetchInvoiceDetail = component.get('c.getPaymentById');

        // Set parameters for Apex method
        fetchInvoiceDetail.setParams({
            'payment_id': invoiceId
        });
        console.log('Fetching invoice details for ID:', invoiceId);

        // Handle response dari server
        fetchInvoiceDetail.setCallback(this, function (response) {
            // Get response state
            let state = response.getState();

            if (state === 'SUCCESS') {
                try {
                    // Mendapatkan isi JSON dari Apex
                    var jsonBody = response.getReturnValue();

                    // Mengubah string JSON menjadi object JS
                    var parsed = JSON.parse(jsonBody); // <- JSON parsing disini
                    console.log("Invoice records:", parsed);

                    // Set selected invoice data into component attributes for editing
                    component.set("v.selectedInvoice", parsed);
                    component.set("v.paymentMethod", parsed.payment_type);
                    if (parsed.va_numbers && parsed.va_numbers.length > 0) {
                        const va = parsed.va_numbers[0];
                        component.set("v.paymentDetails", va.bank.toUpperCase() + ' - ' + va.va_number);
                    } else {
                        component.set("v.paymentDetails", '');
                    }
                    component.set("v.status", parsed.transaction_status);
                    component.set("v.currency", parsed.currency);
                    component.set("v.amount", parsed.gross_amount);
                    component.set("v.paymentDate", parsed.transaction_time);
                    component.set("v.expiredDate", parsed.due_date);
                    component.set("v.paymentMethodDetail", parsed.fraud_status);

                } catch (error) { // Handle jika parsing gagal
                    console.error("Failed to parse JSON:", error.message);
                }
            } else if (state === 'ERROR') { // Handle jika response dari server error
                let errors = response.getError();
                if (errors) {
                    let errorMessage = errors[0].message;
                }
            }

            component.set('v.isLoadingModal', false);

        });

        // Enqueue the action to execute it
        $A.enqueueAction(fetchInvoiceDetail);
    },

    fetchFilteredInvoices: function (component, status) {
        const actionFetchFilteredInvoices = component.get("c.getPaymentFilteredbyStatus");

        // ????????????????????????????????????????????????????????????????????????????
        actionFetchFilteredInvoices.setParams({
            status: status.toLowerCase()
        });

        actionFetchFilteredInvoices.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                const jsonBody = response.getReturnValue();
                console.log("Fetched filtered invoices:", jsonBody);

                const parsed = JSON.parse(jsonBody);
                console.log('Filtered result:', parsed);
                console.log('Filtered result:', parsed.length);

                component.set("v.invoices", parsed);
            } else {
                console.error("Failed to fetch filtered invoices");
            }
        });

        $A.enqueueAction(actionFetchFilteredInvoices);
    },

    fetchFilteredInvoicesMethod: function (component, method) {
        console.log('Fetching filtered invoices by method:', method);
        const fetchFilteredInvoicesMethod = component.get("c.getPaymentFilteredbyMethod");

        fetchFilteredInvoicesMethod.setParams({
            method: method.toLowerCase()
        });

        fetchFilteredInvoicesMethod.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                const jsonBody = response.getReturnValue();
                console.log("Fetched filtered invoices:", jsonBody);

                const parsed = JSON.parse(jsonBody);
                console.log('Filtered result:', parsed);
                console.log('Filtered result:', parsed.length);

                component.set("v.invoices", parsed);
            } else {
                console.error("Failed to fetch filtered invoices");
            }
        });

        $A.enqueueAction(fetchFilteredInvoicesMethod);
    },

    /**
     * Save new Invoice record using Apex
     */
    saveRecord: function (component) {
        try {
            // Apex method to save Invoice
            var actionSave = component.get('c.createNewPayment');

            // Prepare JSON data from component attributes
            var jsonData = {
                'payment_method': component.get('v.paymentMethod'),
                'payment_details': component.get('v.paymentDetails'),
                'transaction_detail': {
                    'amount': component.get('v.amount'),
                },
                'customer': {
                    "fullName": component.get('v.account')
                },
            };
            console.log('Saving invoice with:', jsonData);

            actionSave.setParams({
                'data': JSON.stringify(jsonData)
            });

            // Set callback for success/error handling
            actionSave.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    console.log('Record saved successfully');
                    this.showToast('Success', '🎉 Boom! New invoice just dropped.', 'success');

                    // Close modal, clear fields, and refresh invoices
                    component.set('v.showFormNew', false);
                    this.clearFields(component);
                    this.fetchInvoices(component);
                } else if (response.getState() === 'ERROR') {
                    let errors = response.getError();
                    if (errors && errors.length > 0) {
                        console.error('Save error:', errors[0].message);
                    } else {
                        console.error('Unknown error:', JSON.stringify(errors));
                    }
                }
            });

            // Enqueue the action to execute it
            $A.enqueueAction(actionSave);
        } catch (error) {
            console.error('Error in Saving Record:', error);
        }
    },

    /**
     * Update existing Invoice record
     */
    updateRecord: function (component) {
        try {

            const selected = component.get('v.selectedInvoice');
            const actionUpdate = component.get('c.updatePayment');

            const jsonData = {
                'id': selected.id,
                'transaction_status': component.get('v.status'),
                'amount': component.get('v.amount')
            };
            console.log('Updating invoice with:', jsonData);

            actionUpdate.setParams({
                'data': JSON.stringify(jsonData)
            });

            actionUpdate.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    console.log('Record updated successfully');
                    this.showToast('Success', '🛠️ Invoice updated successfully!', 'success');

                    // Close modal, clear fields, and refresh invoices
                    component.set('v.showFormNew', false);
                    component.set('v.isEditMode', false);
                    this.clearFields(component);
                    this.fetchInvoices(component);
                } else if (response.getState() === 'ERROR') {
                    let errors = response.getError();
                    if (errors && errors.length > 0) {
                        console.error('Update error:', errors[0].message);
                    } else {
                        console.error('Unknown error:', JSON.stringify(errors));
                    }
                }
            });

            // Enqueue the action to execute it
            $A.enqueueAction(actionUpdate);
        } catch (error) {
            console.error('Error in Updating Record:', error);
        }
    },

    /**
     * Delete selected Invoice record
     */
    deleteRecord: function (component) {
        try {
            // Get selected invoice data from component
            const selected = component.get('v.selectedInvoice');
            console.log('Selected Invoice:', selected);
            console.log('Deleting invoice with ID:', selected.id);

            // Ensure a invoice is selected
            if (!selected || !selected.id) {
                console.error('No invoice selected for deletion');
                return;
            }

            // Confirm deletion
            if (!confirm('Are you sure you want to delete this invoice? This cannot be undone.')) {
                return;
            }

            // Apex method to delete Invoice
            var actionDelete = component.get('c.deletePayment');

            // Set parameters for Apex method
            actionDelete.setParams({
                'payment_id': selected.id
            });

            // Set callback for success/error handling
            actionDelete.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    console.log('Record deleted successfully');
                    this.showToast('Success', '👋 Bye-bye invoice, won’t miss ya!', 'success');

                    // Close modal, clear fields, and refresh invoices
                    component.set('v.showFormNew', false);
                    component.set('v.isEditMode', false);
                    this.clearFields(component);
                    this.fetchInvoices(component);
                } else if (response.getState() === 'ERROR') {
                    let errors = response.getError();
                    if (errors && errors.length > 0) {
                        console.error('Update error:', errors[0].message);
                    } else {
                        console.error('Unknown error:', JSON.stringify(errors));
                    }
                }
            });

            // Enqueue the action to execute it
            $A.enqueueAction(actionDelete);
        } catch (error) {
            console.error('Error in Deleting Record:', error);
        }
    },

    /**
     * Clear input fields in modal
     */
    clearFields: function (component) {
        component.set("v.selectedInvoice", '');
        component.set("v.account", '');
        component.set("v.paymentMethod", '');
        component.set("v.paymentDetails", '');
        component.set("v.status", '');
        component.set("v.currency", '');
        component.set("v.amount", '');
        component.set("v.paymentDate", '');
        component.set("v.expiredDate", '');
        component.set("v.paymentMethodDetail", '');
    },

    /**
     * Validate required input fields
     */
    // validateInputs: function (component) {
    //     // Set initial validity to true
    //     let isValid = true;

    //     // Account
    //     const account = component.find("txtAccount");
    //     if (!account.get("v.value")) {
    //         account.setCustomValidity("Account is required.");
    //         account.reportValidity();
    //         isValid = false;
    //     } else {
    //         account.setCustomValidity("");
    //     }

    //     // Amount
    //     const amount = component.find("txtAmount");
    //     const amountVal = amount.get("v.value");
    //     if (!amountVal || isNaN(amountVal) || Number(amountVal) < 1) {
    //         amount.setCustomValidity("Amount must be a number greater than 0.");
    //         amount.reportValidity();
    //         isValid = false;
    //     } else {
    //         amount.setCustomValidity("");
    //     }

    //     // Dropdown
    //     const method = component.get("v.paymentMethod");
    //     const status = component.get("v.status");
    //     const currency = component.get("v.currency");
    //     if (!method || method === "-- Please select the payment method --") {
    //         this.showToast("Error", "Please select a Payment Method", "error");
    //         isValid = false;
    //     }
    //     if (!status || status === "-- Please select the status --") {
    //         this.showToast("Error", "Please select a Status", "error");
    //         isValid = false;
    //     }
    //     if (!currency || currency === "-- Please select the currency --") {
    //         this.showToast("Error", "Please select a Currency", "error");
    //         isValid = false;
    //     }

    //     // Optional Date Logic
    //     const payDate = component.get("v.paymentDate");
    //     const expDate = component.get("v.expiredDate");
    //     if (payDate && expDate && new Date(expDate) < new Date(payDate)) {
    //         this.showToast("Error", "Expired Date can't be earlier than Payment Date", "error");
    //         isValid = false;
    //     }

    //     return isValid;
    // },

    /**
     * Show toast notification
     */
    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type,
                "mode": "dismissible"
            });
            toastEvent.fire();
        }
    }

})