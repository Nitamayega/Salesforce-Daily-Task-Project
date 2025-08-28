trigger LeadTriggerTest on Lead (before insert, before update) {

    // Ini cobain dari vscode 
    // 
    // ini dari dev console loh
    
    /*
    for (Lead lead : Trigger.new) {
        // 1a. Concatenate industry and lead source
        if (Trigger.isInsert && lead.Industry != null && lead.LeadSource != null) {
            lead.Concat_Field__c = lead.Industry + ' - ' + lead.LeadSource;
        }
        
        // 1b. Update rating to WARM when status changes from Open to Working - Contacted
        if (Trigger.isUpdate && Trigger.oldMap.get(lead.Id).Status == 'Open - Not Contacted' && lead.Status == 'Working - Contacted') {
            lead.Rating = 'Warm';
        }
        
        // 1c. Update rating to COLD when status changes from Working - Contacted to Closed
        if (Trigger.isUpdate && Trigger.oldMap.get(lead.Id).Status == 'Working - Contacted' && lead.Status == 'Closed - Not Converted') {
            lead.Rating = 'Cold';
        }
    } */
}