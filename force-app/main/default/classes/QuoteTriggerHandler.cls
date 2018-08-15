public with sharing class QuoteTriggerHandler {
    /*
    public static void updatePendingToConfirmed(Set<Id> acceptedQuotes){
        Map<Id,Event> eventsToUpdate = new Map<Id,Event>();
    
        for (QuoteLineItem qli : [select Id, EventId__c, ServiceDate from QuoteLineItem where QuoteId =: acceptedQuotes]){
            if (qli.EventId__c != null){
                DateTime serviceDateTime = qli.ServiceDate;
                serviceDateTime = serviceDateTime.addHours(8);
                Event e = new Event(Id=qli.EventId__c);
                e.StartDateTime = serviceDateTime;
                e.IsAllDayEvent = true;             
                eventsToUpdate.put(qli.EventId__c, e);
            }
        }
        
        if (eventsToUpdate.size() > 0){
            // get list of events to get the subjects that need to updated to confirmed
            Map<Id,Event> events = new Map<Id,Event>([select Id, Subject from Event where Id =: eventsToUpdate.keySet()]);
            
            for(Event e : eventsToUpdate.values()){
                e.Subject = events.get(e.Id).Subject.replace('Pending', 'Confirmed');
            }
            
            update eventsToUpdate.values();
        }
    }
    
    public static void createPendingEvents(Set<Id> approvedQuotes){
        // Create a map to hold the event we will be creating for each QuoteLineItem
        Map<QuoteLineItem, Event> eventMap = new Map<QuoteLineItem, Event>();
        List<Event> purgeEvents = new List<Event>();
        for (QuoteLineItem qli : [select Id, LineNumber, PriceBookEntry.Product2.Name, ServiceDate, EventId__c, Quote.ContactId, QuoteId, Quote.Opportunity.AccountId, Quote.Name, Quote.Primary_Facilitator__c from QuoteLineItem where QuoteId =: approvedQuotes and ServiceDate != null]){
            if (!String.IsBlank(qli.EventId__c)){
                Event del = new Event(Id=qli.EventId__c);
                purgeEvents.add(del);
            }
            
            eventMap.put(qli, new Event());
        }
        
        // check if there were events to delete
        if (purgeEvents.size() > 0){
            delete purgeEvents;
        }
        
        // loop thru quote lines and create the event object to be created for each QuoteLineItem
        Boolean haveEventsToCreate = false;
        for (QuoteLineItem qli : eventMap.keySet()){
            
            Event e1 = eventMap.get(qli);
            
            e1.WhatId = qli.QuoteId;
            e1.WhoId = qli.Quote.ContactId;
            system.debug('service date'+qli.servicedate);
            e1.StartDateTime = qli.ServiceDate;
                e1.StartDateTime = e1.StartDateTime.addHours(8);
            
            e1.OwnerId = '023A00000039NSGIA2';
            //e1.DurationInMinutes = 60;
            e1.IsAllDayEvent = true;
            e1.Subject = 'Pending [' + qli.PriceBookEntry.Product2.Name + ']' + qli.Quote.Name;
            
            haveEventsToCreate = true;
            
        }
        
        // if we have Events created then insert them
        if (haveEventsToCreate){
            insert eventMap.values();
            
            // update the quote lines with a pointer to the Event we created
            for (QuoteLineItem qli : eventMap.keySet()){
                qli.EventId__c = eventMap.get(qli).Id;
            }
            update new List<QuoteLineItem>(eventMap.keySet());
            
            // create the relationship object that is used to effectively create an 'attendee'
            // attendees = the primary facilitator and anyone in the ProjectSupporter__c object in the AdditionalStaffMember__c user lookup field
            List<ProjectSupporter__c> projSupporters = [select AdditionalStaffMember__c, Quote__c from ProjectSupporter__c where Quote__c =: approvedQuotes and AdditionalStaffMember__c <> null];
            
            List<EventRelation> ers = new List<EventRelation>();
            for (QuoteLineItem qli : eventMap.keySet()){
                EventRelation er1 = new EventRelation();
                er1.EventId = qli.EventId__c;
                er1.RelationId = qli.Quote.Primary_Facilitator__c;
                er1.Status = 'New';
                
                ers.add(er1);
                
                for (ProjectSupporter__c ps : projSupporters) {
                    if (ps.Quote__c == qli.QuoteId) {
                        EventRelation er2 = new EventRelation();
                        er2.EventId = qli.EventId__c;
                        er2.RelationId = ps.AdditionalStaffMember__c;
                        er2.Status = 'New';
                        
                        ers.add(er2);        
                    }
                }
            }
            
            insert ers;
        }
        
    }
*/
}