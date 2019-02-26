public with sharing class ControllerRegistrantList {
    private String scheduledCourseId {
        get { return getParam('id'); }
    }
    
    public String getParam(String paramName) {
        String param = System.currentPageReference().getParameters().get(paramName);
        if (param == null) return null;
        else return String.escapeSingleQuotes(param);
    }

    public List<CourseEnrollment__c> registrants {
        get {
            if (registrants == null){
                registrants = [select Id, ScheduledCourseId__c,
                                ContactId__r.FirstName, ContactId__r.LastName, ContactId__r.Email, ContactId__r.Phone, ContactId__r.ProgramType__c,ContactId__r.Grade__c,ContactId__r.Role__c, 
                                ContactId__r.Account.Name, ContactId__r.Account.BillingStreet, ContactId__r.Account.BillingCity, ContactId__r.Account.BillingState, ContactId__r.Account.BillingPostalCode,
                                CoursePaymentInfoId__r.AdministratorName__c 
                                from CourseEnrollment__c 
                                where RegistrationStatus__c = 'Registered' and ScheduledCourseId__c =: scheduledCourseId];
            }
            return registrants;
        }
        private set;
    }
}