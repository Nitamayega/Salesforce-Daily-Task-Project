({
    /**
     * Called once when component is initialized.
     * Set up table headers and fetch initial invoice data.
     */
    doInit: function (component, event, helper) {
        // Define column headers to be used in the table
        const tableHeaders = [
            {
                columnId: '1',
                columnLabel: 'Invoice ID',
            },
            {
                columnId: '2',
                columnLabel: 'Customer Name',
            },
            {
                columnId: '3',
                columnLabel: 'Amount',
            },
            {
                columnId: '4',
                columnLabel: 'Expired Date',
            }
        ];

        // Set the table headers in the component's attribute
        component.set('v.tableHeaders', tableHeaders);
        console.log('Table headers initialized.');
        console.log('Table headers set:', JSON.stringify(component.get('v.tableHeaders')));

        // Call helper method to fetch initial invoice records
        helper.fetchInvoices(component);
    },

    /**
     * Handles all button clicks (New, Save, Close, Delete).
     * Dispatches to the proper helper method based on button name.
     */
    handleClick: function (component, event, helper) {
        // Get the name of the button that was clicked
        var btnName = event.getSource().get('v.name');
        console.log('Button clicked:', btnName);

        // Switch case to handle different button actions
        switch (btnName) {
            case 'btnNew':
                // Show the form modal for creating a new invoice
                console.log('Ini show form new - ' + component.get('v.showFormNew'));
                console.log('Ini is new mode - ' + component.get('v.isNewMode'));
                console.log('Ini is detail mode - ' + component.get('v.isDetailMode'));
                console.log('Ini is edit mode - ' + component.get('v.isEditMode'));

                component.set('v.isNewMode', true);
                component.set('v.isEditMode', false);
                component.set('v.isDetailMode', false);
                component.set('v.showFormNew', true);

                console.log('Ini show form new - ' + component.get('v.showFormNew'));
                console.log('Ini is new mode - ' + component.get('v.isNewMode'));
                console.log('Ini is detail mode - ' + component.get('v.isDetailMode'));
                console.log('Ini is edit mode - ' + component.get('v.isEditMode'));

                break;

            case 'btnRefresh':
                // Call helper method to fetch initial invoice records
                helper.fetchInvoices(component);
                break;

            case 'btnClose':
                // Close modal, clear fields, exit edit mode
                component.set('v.showFormNew', false);
                component.set('v.isNewMode', false);
                component.set('v.isDetailMode', false);
                component.set('v.isEditMode', false);
                helper.clearFields(component);
                break;

            case 'btnUpdate':
                component.set('v.isLoadingModal', true);

                window.setTimeout(function () {
                    component.set('v.showFormNew', true);
                    component.set('v.isNewMode', false);
                    component.set('v.isDetailMode', false);
                    component.set('v.isEditMode', true);
                    component.set('v.isLoadingModal', false);

                    console.log('Ini show form new click after show form - ' + component.get('v.showFormNew'));
                    console.log('Ini is new mode click after show form - ' + component.get('v.isNewMode'));
                    console.log('Ini is detail mode click after show form - ' + component.get('v.isDetailMode'));
                    console.log('Ini is edit mode click after show form - ' + component.get('v.isEditMode'));

                }, 200);

                break;

            case 'btnSave':
                if (component.get('v.isEditMode')) {
                    console.log('Ini is edit mode - ' + component.get('v.isEditMode'));
                    helper.updateRecord(component);
                } else {
                    console.log('Ini is new mode - ' + component.get('v.isNewMode'));
                    helper.saveRecord(component);
                }
                break;

            // // Call helper method to validate inputs and save the record
            //     // Validate inputs first
            //     if (helper.validateInputs(component)) {
            //         // If in edit mode, update the record; otherwise, save a new record
            //         if (component.get('v.isEditMode')) {
            //             helper.updateRecord(component);
            //         } else {
            //             helper.saveRecord(component);
            //         }
            //     }
            //     break;

            case 'btnDelete':
                // Call helper method to delete the record
                helper.deleteRecord(component);
                break;
        }
    },

    /**
     * Handles row click in the table.
     * Populates the form with selected invoice data for editing.
     */
    handleRowClick: function (component, event, helper) {
        // Get index of clicked row (subtract 1 for header offset)
        const index = event.currentTarget.rowIndex - 1;
        console.log('Row clicked, index:', index);

        // Get all current invoices from the component
        const invoices = component.get("v.invoices");
        console.log('Current invoices:', JSON.stringify(invoices));

        // Get selected invoice based on clicked index
        const selected = invoices[index];
        console.log('Selected invoice:', JSON.stringify(selected));
        console.log('Selected invoice ID:', JSON.stringify(selected.id));

        // Hold the selected invoice ID
        const invoiceId = selected.id;
        component.set("v.selectedInvoice", selected); // opsional, kalau masih butuh cache lokal
        console.log(`Editing invoice: ${invoiceId}`);

        // Call helper method to fetch invoice details
        helper.fetchInvoiceDetail(component, invoiceId);


        console.log('Ini show form new click before show form - ' + component.get('v.showFormNew'));
        console.log('Ini is new mode click before show form - ' + component.get('v.isNewMode'));
        console.log('Ini is detail mode click before show form - ' + component.get('v.isDetailMode'));
        console.log('Ini is edit mode click before show form - ' + component.get('v.isEditMode'));

        // Set the component state
        component.set('v.isNewMode', false);
        component.set('v.isEditMode', false);
        component.set('v.isDetailMode', true);
        component.set('v.showFormNew', true);

        console.log('Ini show form new click after show form - ' + component.get('v.showFormNew'));
        console.log('Ini is new mode click after show form - ' + component.get('v.isNewMode'));
        console.log('Ini is detail mode click after show form - ' + component.get('v.isDetailMode'));
        console.log('Ini is edit mode click after show form - ' + component.get('v.isEditMode'));

    },

    handleFilterChange: function (component, event, helper) {
        // const statusFilter = component.find("filterStatus").get("v.value");
        const methodFilter = component.find("filterMethod").get("v.value");
        console.log('>> Filter method:', methodFilter);

        console.log('before helper');

        // helper.fetchFilteredInvoices(component, statusFilter);
        helper.fetchFilteredInvoicesMethod(component, methodFilter);

        console.log('after helper');

        console.log('Filters applied:', {
            status: statusFilter,
            method: methodFilter
        });
    },

});