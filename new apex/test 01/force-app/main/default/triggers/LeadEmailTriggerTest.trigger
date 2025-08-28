trigger LeadEmailTriggerTest on Lead (after insert) {
    /*
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'New_Lead_Notification' LIMIT 1].Id;

    for (Lead lead : Trigger.new) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(templateId);
        email.setTargetObjectId(lead.Id);
        email.setSaveAsActivity(false);
        email.setToAddresses(new String[] { 'nitamygaa@gmail.com' });
        emails.add(email);
    }
    
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
    */
}