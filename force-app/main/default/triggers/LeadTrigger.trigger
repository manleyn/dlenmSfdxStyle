trigger LeadTrigger on Lead (after update) {
    if (Trigger.isAfter){
        if (Trigger.isUpdate){
            // build set of converted leads
            Set<Id> convertedLeads = new Set<Id>();
            for (Lead l : Trigger.new){
                // compare this lead against old lead and ensure this is the conversion update
                if (l.isConverted && !Trigger.oldMap.get(l.Id).isConverted)
                    convertedLeads.add(l.Id);
            }
            
            // check for CourseEnrollemnts
            Boolean updateCEs = false;
            List<CourseEnrollment__c> ces = [select Id, LeadId__c from CourseEnrollment__c where LeadId__c =: convertedLeads];
            for (CourseEnrollment__c ce : ces){
                if (Trigger.newMap.containsKey(ce.LeadId__c)) {
                	ce.ContactId__c = Trigger.newMap.get(ce.LeadId__c).ConvertedContactId;
                    updateCEs = true;
                }
            }
            
            if (updateCEs)
                update ces;
        }
    }
}