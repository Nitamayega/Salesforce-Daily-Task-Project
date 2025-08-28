({
    /**
     * Fetch latest Leads from Apex Controller
     * Show spinner while loading and populate table if success
     */
    fetchLeads: function (component) {
        // Show loading spinner
        component.set('v.isLoading', true);

        // Apex method call
        var actionFetchLead = component.get('c.getLeads');

        // Set callback for success/error handling
        actionFetchLead.setCallback(this, function (response) {
            // Get response state
            let state = response.getState();

            if (state === 'SUCCESS') {
                // Get lead list from Apex
                let leads = response.getReturnValue();

                // Populate component attribute with leads
                if (leads.length > 0) {
                    component.set('v.leads', leads);
                }
            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    let errorMessage = errors[0].message;
                }
            }

            // Hide loading spinner
            window.setTimeout(function () {
                component.set('v.isLoading', false);
            }, 250);
        });

        // Enqueue the action to execute it
        $A.enqueueAction(actionFetchLead);
    },

    /**
     * Save new Lead record using Apex
     */
    saveRecord: function (component) {
        try {
            // Apex method to save Lead
            var actionSave = component.get('c.saveLead');

            // Prepare JSON data from component attributes
            var jsonData = {
                'firstName': component.get('v.firstName'),
                'lastName': component.get('v.lastName'),
                'email': component.get('v.email'),
                'company': component.get('v.company')
            };

            console.log('Saving lead with:', jsonData);

            // Set parameters for Apex method
            actionSave.setParams({
                'data': JSON.stringify(jsonData)
            });

            // Set callback for success/error handling
            actionSave.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    console.log('Record saved successfully');
                    this.showToast('Success', '🎉 Boom! New lead just dropped.', 'success');

                    // Close modal, clear fields, and refresh leads
                    component.set('v.showFormNew', false);
                    this.clearFields(component);
                    this.fetchLeads(component);
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
     * Update existing Lead record
     */
    updateRecord: function (component) {
        try {
            // Get selected lead data from component
            const selected = component.get('v.selectedLead');

            // Apex method to update Lead
            var actionUpdate = component.get('c.updateLead');

            // Prepare JSON data from component attributes
            var jsonData = {
                'id': selected.Id,
                'firstName': component.get('v.firstName'),
                'lastName': component.get('v.lastName'),
                'email': component.get('v.email'),
                'company': component.get('v.company')
            };

            console.log('Updating lead with:', jsonData);

            // Set parameters for Apex method
            actionUpdate.setParams({
                'data': JSON.stringify(jsonData)
            });

            // Set callback for success/error handling
            actionUpdate.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    console.log('Record updated successfully');
                    this.showToast('Success', '🛠️ That lead got a mini makeover.', 'success');

                    // Close modal, clear fields, and refresh leads
                    component.set('v.showFormNew', false);
                    component.set('v.isEditMode', false);
                    this.clearFields(component);
                    this.fetchLeads(component);
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
     * Delete selected Lead record
     */
    deleteRecord: function (component) {
        try {
            // Get selected lead data from component
            const selected = component.get('v.selectedLead');

            // Ensure a lead is selected
            if (!selected || !selected.Id) {
                console.error('No lead selected for deletion');
                return;
            }

            // Confirm deletion
            if (!confirm('Are you sure you want to delete this lead? This cannot be undone.')) {
                return;
            }

            // Apex method to delete Lead
            var actionDelete = component.get('c.deleteLead');

            // Set parameters for Apex method
            actionDelete.setParams({
                'leadId': selected.Id
            });

            // Set callback for success/error handling
            actionDelete.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    console.log('Record deleted successfully');
                    this.showToast('Success', '👋 Bye-bye lead, won’t miss ya!', 'success');

                    // Close modal, clear fields, and refresh leads
                    component.set('v.showFormNew', false);
                    component.set('v.isEditMode', false);
                    this.clearFields(component);
                    this.fetchLeads(component);
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
        component.set('v.firstName', '');
        component.set('v.lastName', '');
        component.set('v.email', '');
        component.set('v.company', '');
    },

    /**
     * Validate required input fields
     */
    validateInputs: function (component) {
        // Set initial validity to true
        let isValid = true;

        // Validate Last Name
        const lastName = component.find("txtLastName");
        if (!lastName.get("v.value")) {
            lastName.setCustomValidity("Last Name is required.");
            lastName.reportValidity();
            isValid = false;
        } else {
            lastName.setCustomValidity("");
        }

        // Validate Company
        const company = component.find("txtCompany");
        if (!company.get("v.value")) {
            company.setCustomValidity("Company is required.");
            company.reportValidity();
            isValid = false;
        } else {
            company.setCustomValidity("");
        }

        // Validate Email format if filled
        const email = component.find("txtEmail");
        const emailVal = email.get("v.value");
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (emailVal && !emailRegex.test(emailVal)) {
            email.setCustomValidity("Invalid email format.");
            email.reportValidity();
            isValid = false;
        } else {
            email.setCustomValidity("");
        }

        return isValid;
    },

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