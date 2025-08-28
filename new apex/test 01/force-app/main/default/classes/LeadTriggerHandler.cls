public class LeadTriggerHandler extends TriggerHandler {
    
    protected override void beforeInsert() {
        
        concatField();

    }
    
    protected override void beforeUpdate() {
        
        concatField();
        
        for (Lead lead : (List<Lead>)Trigger.new) {            
            Lead oldLead = (Lead)Trigger.oldMap.get(lead.Id);
            if (oldLead.Status == 'Open - Not Contacted' && lead.Status == 'Working - Contacted') {
                lead.Rating = 'Warm';
            } else if (oldLead.Status == 'Working - Contacted' && lead.Status == 'Closed - Not Converted') {
                lead.Rating = 'Cold';
            }
        }
    }
    
    protected override void afterInsert() {
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'New_Lead_Notification' LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Lead ld : (List<Lead>)Trigger.new) {
            if (!ld.IsConverted) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templateId);
                email.setTargetObjectId(UserInfo.getUserId());
                email.setSaveAsActivity(false);
                email.setToAddresses(new String[] { 'nitamygaa@gmail.com' });
                emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    protected override void afterUpdate() {
        /* --------------- */
    }   
    
    private void concatField() {
        for (Lead lead : (List<Lead>)Trigger.new) {
            if (lead.Industry != null && lead.LeadSource != null) {
                lead.Concat_Field__c = lead.Industry + ' - ' + lead.LeadSource;
            }
        }
    }    
    
}