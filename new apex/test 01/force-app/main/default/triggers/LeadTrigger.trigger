trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    new LeadTriggerHandler().run();
    
    /*
    Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'New_Lead_Notification' LIMIT 1].Id;
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for(Lead ld: Trigger.New) {
        
        Lead oldLead = Trigger.oldMap.get(ld.Id);

        if (!oldLead.IsConverted && !ld.IsConverted) {
            // Proceed with conversion only if lead has not been converted
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(ld.Id);

            LeadStatus convertStatus = [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            leadConvert.setConvertedStatus(convertStatus.ApiName);

            try {
                Database.LeadConvertResult lcr = Database.convertLead(leadConvert);

                // Send email after successful conversion
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templateId);
                email.setTargetObjectId(UserInfo.getUserId());
                email.setSaveAsActivity(false);
                email.setToAddresses(new String[] { 'nitamygaa@gmail.com' });
                emails.add(email);

            } catch (Exception e) {
                System.debug('Lead Conversion Failed: ' + e.getMessage());
            }
        }
    }

    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    } */
}