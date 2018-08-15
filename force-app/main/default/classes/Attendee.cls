public class Attendee {
    public String Id {get;set;}
    public String Name {get;set;}
    public String Email {get;set;}
    public String Status {get;set;}
    public String Notes {get;set;}
    public String Attended {get;set;}

    public Attendee(CourseAttendance__c ca){
        this.Id = ca.Id;

        this.Status = ca.CourseAttendeeEnrollmentId__r.RegistrationStatus__c;
        this.Notes = ca.AttendanceNotes__c;
        this.Attended =  String.valueOf(ca.Attended__c);

        // use contact info if we have it
        if (ca.CourseAttendeeEnrollmentId__r.ContactId__c != null) {
            this.Name = ca.CourseAttendeeEnrollmentId__r.ContactId__r.Name;
            this.Email = ca.CourseAttendeeEnrollmentId__r.ContactId__r.Email;
        } else {
            this.Name = ca.CourseAttendeeEnrollmentId__r.LeadId__r.Name;
            this.Email = ca.CourseAttendeeEnrollmentId__r.LeadId__r.Email;
        }
    }
}