({
    /**
     * Called once when component is initialized.
     * Set up table headers and fetch initial lead data.
     */
    doInit: function (component, event, helper) {
        // Define column headers to be used in the table
        const tableHeaders = [
            {
                columnId: '1',
                columnLabel: 'First Name',
            },
            {
                columnId: '2',
                columnLabel: 'Last Name',
            },
            {
                columnId: '3',
                columnLabel: 'Email',
            },
            {
                columnId: '4',
                columnLabel: 'Company',
            }
        ];

        // Set the table headers in the component's attribute
        component.set('v.tableHeaders', tableHeaders);
        console.log('Table headers initialized.');
        console.log('Table headers set:', JSON.stringify(component.get('v.tableHeaders')));

        // Call helper method to fetch initial lead records
        helper.fetchLeads(component);
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
                // Show the form modal for creating a new lead
                component.set('v.showFormNew', true);
                break;

            case 'btnClose':
                // Close modal, clear fields, exit edit mode
                component.set('v.showFormNew', false);
                component.set('v.isEditMode', false);
                helper.clearFields(component);
                break;

            case 'btnSave':
                // Validate inputs
                if (helper.validateInputs(component)) {
                    // If in edit mode, update the record; otherwise, save a new record
                    if (component.get('v.isEditMode')) {
                        helper.updateRecord(component);
                    } else {
                        helper.saveRecord(component);
                    }
                } else {
                    helper.showToast('Error', 'Please fill in all required fields.', 'error');
                }
                break;

            case 'btnDelete':
                // Call helper method to delete the record
                helper.deleteRecord(component);
                break;
        }
    },

    /**
     * Handles row click in the table.
     * Populates the form with selected lead data for editing.
     */
    handleRowClick: function (component, event, helper) {
        // Get index of clicked row (subtract 1 for header offset)
        const index = event.currentTarget.rowIndex - 1;
        console.log('Row clicked, index:', index);

        // Get all current leads from the component
        const leads = component.get("v.leads");
        console.log('Current leads:', JSON.stringify(leads));

        // Get selected lead based on clicked index
        const selected = leads[index];
        console.log('Selected lead:', JSON.stringify(selected));

        // Set selected lead data into component attributes for editing
        component.set("v.selectedLead", selected);
        component.set("v.firstName", selected.FirstName);
        component.set("v.lastName", selected.LastName);
        component.set("v.email", selected.Email);
        component.set("v.company", selected.Company);

        // Set component state to edit mode and show the form
        component.set("v.isEditMode", true);
        component.set("v.showFormNew", true);
        console.log(`Editing lead: ${selected.Id}`);
    }
});