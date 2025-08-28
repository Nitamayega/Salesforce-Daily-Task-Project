/**
 * BootcampSalesforceLeadsController
 * ---------------------------------
 * Custom Apex controller for managing Salesforce Leads in Aura/LWC.
 * Handles CRUD operations (get, save, update, delete) for Lead objects.
 * 
 * @author  Geu
 * @date    2025-08-06
 */

 public with sharing class BootcampSalesforceLeadsController {
    
    /**
     * Retrieve latest 10 leads, ordered by last modified date.
     * @AuraEnabled: Exposed to Lightning Components.
     */
    @AuraEnabled
    public static List<Lead> getLeads() {
        return [
            SELECT Id, FirstName, LastName, Email, Company
            FROM Lead 
            ORDER BY LastModifiedDate DESC
            LIMIT 10
        ];
    }

    /**
     * Create a new Lead record from JSON string data.
     * @param data JSON string representing a Lead.
     * @return Success/error message.
     * @throws AuraHandledException on failure.
     */
    @AuraEnabled
    public static string saveLead(String data) {
        System.debug('Data received for saveLead: ' + data);

        String message = '';

        try {
            // Parse input data
            Map<String, Object> dataLead = (Map<String, Object>) JSON.deserializeUntyped(data);
            System.debug('Parsed Map: ' + dataLead);

            // Validate required fields
            if (String.isBlank((String) dataLead.get('lastName'))) {
                throw new AuraHandledException('Last Name is required.   123');
            }

            if (String.isBlank((String) dataLead.get('company'))) {
                throw new AuraHandledException('Company is required.   123');
            }

            // Create new Lead instance
            Lead newLead = new Lead(
                FirstName = (String) dataLead.get('firstName'),
                LastName = (String) dataLead.get('lastName'),
                Email = (String) dataLead.get('email'),
                Company = (String) dataLead.get('company')
            );
            
            // Insert new Lead
            Database.insert(newLead, true);

            message = 'Lead saved successfully';
        } catch (Exception e) {
            message = 'Error saving lead: ' + e.getMessage();
            throw new AuraHandledException(message);
        }

        return message;
    }

    /**
     * Update an existing Lead record from JSON string data.
     * @param data JSON string representing a Lead (must contain Id).
     * @return Success/error message.
     * @throws AuraHandledException on failure.
     */
    @AuraEnabled
    public static string updateLead(String data) {
        System.debug('Data received for updateLead: ' + data);

        String message = '';

        try {
            // Parse input data
            Map<String, Object> dataLead = (Map<String, Object>) JSON.deserializeUntyped(data);
            System.debug('Parsed Map: ' + dataLead);
            
            // Ensure Lead Id is present
            String leadId = (String) dataLead.get('id');
            System.debug('Lead Id: ' + leadId);

            // Validate Lead Id
            if (String.isBlank(leadId)) {
                throw new AuraHandledException('Missing Lead Id for update.');
            }

            // Validate required fields
            if (String.isBlank((String) dataLead.get('lastName'))) {
                throw new AuraHandledException('Last Name is required.');
            }

            if (String.isBlank((String) dataLead.get('company'))) {
                throw new AuraHandledException('Company is required.');
            }

            // Retrieve existing Lead
            Lead updatedLead = new Lead(
                Id = leadId,
                FirstName = (String) dataLead.get('firstName'),
                LastName = (String) dataLead.get('lastName'),
                Email = (String) dataLead.get('email'),
                Company = (String) dataLead.get('company')
            );

            // Update existing Lead
            Database.update(updatedLead, true);

            message = 'Lead updated successfully';
        } catch (Exception e) {
            message = 'Error updating lead: ' + e.getMessage();
            throw new AuraHandledException(message);
        }

        return message;
    }

    /**
     * Delete a Lead record by Id.
     * @param leadId Salesforce Id of the Lead.
     * @return Success/error message.
     * @throws AuraHandledException on failure.
     */
    @AuraEnabled
    public static string deleteLead(Id leadId) {
        String message = '';

        try {
            // Query Lead by Id
            Lead leadToDelete = [SELECT Id FROM Lead WHERE Id = :leadId LIMIT 1];
            System.debug('Lead to delete: ' + leadToDelete);
            
            // Delete Lead
            Database.delete(leadToDelete, true);
            message = 'Lead deleted successfully';
        } catch (Exception e) {
            message = 'Error deleting lead: ' + e.getMessage();
            throw new AuraHandledException(message);
        }

        return message;
    }

}