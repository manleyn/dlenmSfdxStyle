public with sharing class ControllerRegistrantList {
    private String scheduledCourseId {
        get { return getParam('id'); }
    }
    
    public String getParam(String paramName) {
        String param = System.currentPageReference().getParameters().get(paramName);
        if (param == null) return null;
        else return String.escapeSingleQuotes(param);
    }

    public List<String> registrants {
        get {
            if (registrants == null){ 
                registrants = new List<String>();
                List<CourseEnrollment__c> ces = [select Id, ScheduledCourseId__c, ScheduledCourseId__r.Location__c,
                                ContactId__r.FirstName, ContactId__r.LastName, ContactId__r.Email, ContactId__r.Phone, ContactId__r.ProgramType__c,ContactId__r.Grade__c,ContactId__r.Role__c, 
                                ContactId__r.Account.Name, ContactId__r.Account.Website, ContactId__r.Account.BillingStreet, ContactId__r.Account.BillingCity, ContactId__r.Account.BillingState, ContactId__r.Account.BillingPostalCode,
                                CoursePaymentInfoId__r.AdministratorName__c, CoursePaymentInfoId__r.AdministratorEmail__c, CoursePaymentInfoId__r.PaymentMethod__c,CoursePaymentInfoId__r.InvoiceInfo__c,
                                (Select Name, ScheduledDate__c from Course_Attendance__r order by ScheduledDate__c)                 
                                from CourseEnrollment__c 
                                where RegistrationStatus__c = 'Registered' and ScheduledCourseId__c =: scheduledCourseId];
                
               	//first output the csv header labels
               	String hdr = '';
                hdr += getValueForCSV('Status', false); //a
                hdr += getValueForCSV('First Name', false); //b
                hdr += getValueForCSV('Last Name', false); //c
                hdr += getValueForCSV('Phone', false); //d
                hdr += getValueForCSV('Email', false); //e
                hdr += getValueForCSV('Organization', false); //f
                hdr += getValueForCSV('Street', false); //g - h
                hdr += getValueForCSV('City', false); //i
                hdr += getValueForCSV('State', false); //j
                hdr += getValueForCSV('Zip Code', false); //k
                hdr += getValueForCSV('Web Site', false); //l
                hdr += getValueForCSV('District Code', false); //m
                hdr += getValueForCSV('Institution Code', false); //n
                hdr += getValueForCSV('Position', false); //o
                hdr += getValueForCSV('Grade', false); //p
                hdr += getValueForCSV('Program Type', false); //q
                hdr += getValueForCSV('District', false); //r
                hdr += getValueForCSV('Administrator', false); //s
                hdr += getValueForCSV('Admin Email', false); //t
                hdr += getValueForCSV('Location', false); //u
                hdr += getValueForCSV('Dates', false); //v

                Integer d = 1;
                for (CourseAttendance__c day : ces[0].Course_Attendance__r){
                    hdr += getValueForCSV('Day ' + d, false); //w - ab
                    d++;
                }

                hdr += getValueForCSV('Certified', false); //ac
                hdr += getValueForCSV('Notes', false); //ad
                hdr += getValueForCSV('Invoice #', false); //ae
                hdr += getValueForCSV('Payment Method', true); //af
                
                registrants.add(hdr);
                
                // second add items for each registrant
                for (CourseEnrollment__c ce : ces){
                    String s = '';
                    s += getValueForCSV('', false); //a
                    s += getValueForCSV(ce.ContactId__r.FirstName, false); //b
                    s += getValueForCSV(ce.ContactId__r.LastName, false); //c
                    s += getValueForCSV(ce.ContactId__r.Phone, false); //d                    
                    s += getValueForCSV(ce.ContactId__r.Email, false); //e
                    s += getValueForCSV(ce.ContactId__r.Account.Name, false); //f
                    s += getValueForCSV(ce.ContactId__r.Account.BillingStreet, false); //g- h
                    s += getValueForCSV(ce.ContactId__r.Account.BillingCity, false); //i
                    s += getValueForCSV(ce.ContactId__r.Account.BillingState, false); //j
                    s += getValueForCSV(ce.ContactId__r.Account.BillingPostalCode, false); //k
                    s += getValueForCSV(ce.ContactId__r.Account.Website, false); //l
                    s += getValueForCSV('', false); //m
                    s += getValueForCSV('', false); //n
                    s += getValueForCSV(ce.ContactId__r.Role__c, false); //o
                    s += getValueForCSV(ce.ContactId__r.Grade__c, false); //p
                    s += getValueForCSV(ce.ContactId__r.ProgramType__c, false); //q
                    s += getValueForCSV('', false); //r
                    s += getValueForCSV(ce.CoursePaymentInfoId__r.AdministratorName__c, false); //s
                    s += getValueForCSV(ce.CoursePaymentInfoId__r.AdministratorEmail__c, false); //t
                    s += getValueForCSV(ce.ScheduledCourseId__r.Location__c, false); //u
                    s += getValueForCSV('Dates', false); //v

                    for (CourseAttendance__c day : ce.Course_Attendance__r){
                        s += getValueForCSV('', false); //w - ab
                    }
                    
                    s += getValueForCSV('', false); //ac
                    s += getValueForCSV('', false); //ad
                    s += getValueForCSV(ce.CoursePaymentInfoId__r.InvoiceInfo__c, false); //ae
                    s += getValueForCSV(ce.CoursePaymentInfoId__r.PaymentMethod__c, true); //af    
                    
                    registrants.add(s);
                }
            }
            return registrants;
        }
        private set;
    }
    
    private String getValueForCSV(String s, Boolean lastValue){
		String v = (String.isEmpty(s)) ? '' : s;
        String r = '"' + v.replace('"','""') + '"';
        if (!lastValue){
            r += ',';
        }
        return r;
    }
}