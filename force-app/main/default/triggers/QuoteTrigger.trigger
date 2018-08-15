trigger QuoteTrigger on Quote (after update, before insert, before update) {
    if (Trigger.isUpdate && Trigger.isAfter){

        // check for approved quotes in this update
        Set<Id> approvedQuotes = new Set<Id>();
        for (Quote q : Trigger.new){
            if (q.Status == 'Approved')
                approvedQuotes.add(q.Id);
        }
        //if (approvedQuotes.size() > 0) QuoteTriggerHandler.createPendingEvents(approvedQuotes);

        // check for accepted quotes in this update
        Set<Id> acceptedQuotes = new Set<Id>();
        for (Quote q : Trigger.new){
            if (q.Status == 'Accepted')
                acceptedQuotes .add(q.Id);
        }
        //if (acceptedQuotes .size() > 0) QuoteTriggerHandler.updatePendingToConfirmed(acceptedQuotes);

    }

    if ((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore){
        Map<Id, Program_Goal_Template__c > ts = new Map<Id, Program_Goal_Template__c >([select Id, Goals__c from Program_Goal_Template__c]);

        for (Quote q : Trigger.new){
            if ( (q.ProgramGoalTemplate__c != null && Trigger.isInsert) || (Trigger.isUpdate && q.ProgramGoalTemplate__c != Trigger.oldMap.get(q.Id).ProgramGoalTemplate__c) ){
                if (ts.containsKey(q.ProgramGoalTemplate__c)) {
                    q.ProgramGoal__c = ts.get(q.ProgramGoalTemplate__c).Goals__c;
                }
            }
        }

        Map<Id, GrantUsage__c> gus =  new Map<Id, GrantUsage__c >([select Id, QuoteId__c, QuoteId__r.Status, QuoteStatus__c from GrantUsage__c where QuoteId__c in: Trigger.new]);
        List<GrantUsage__c> guUpdates = new List<GrantUsage__c>();
        for (GrantUsage__c gu : gus.values()){
            gu.QuoteStatus__c = gu.QuoteId__r.Status;
        }
    }
}