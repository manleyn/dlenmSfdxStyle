public class ControllerTrainings {

    @AuraEnabled
    public static List<ScheduledCourse__c> getAllTrainings(String courseType) {
        return getAllTrainings(courseType, true);
    }

    @AuraEnabled
    public static List<ScheduledCourse__c> getAllTrainings(String courseType, Boolean publishedOnly) {
        List<ScheduledCourse__c> retList = new List<ScheduledCourse__c>();
        List<ScheduledCourse__c> schedCourses = new List<ScheduledCourse__c>();
        if (publishedOnly){
            schedCourses = getPublishedTrainings();
        } else {
            schedCourses = getTrainings();
        }
        for (ScheduledCourse__c c : schedCourses){
        	if (c.CourseId__r.CourseType__c.equalsIgnoreCase(courseType))
                retList.add(c);
        }
        return retList;
    }

    @AuraEnabled
    public static ScheduledCourse__c getScheduledCourseInfo(String scheduledCourseId){
        for (ScheduledCourse__c c : getPublishedTrainings()){
        	if (c.Id.equals(scheduledCourseId))
                return c;
        }
        throw new TrainingClassException('Error finding courseinfo. No course found for :' + scheduledCourseId);
    }

    @AuraEnabled
    public static Integer currentRegistrantCount(String scheduledCourseId){
        Set<Id> cIds = new Set<Id>();
        cIds.add(scheduledCourseId);
        List<CourseEnrollment__c> ces = currentRegistrantList(cIds);
        return ces.size();
    }

    public static List<CourseEnrollment__c> currentRegistrantList(Set<Id> scheduledCourseIds){
        return [select Id, ScheduledCourseId__c from CourseEnrollment__c where RegistrationStatus__c = 'Registered' and ScheduledCourseId__c in: scheduledCourseIds];
    }

    @AuraEnabled
    public static String getRosterList(String scheduledCourseDayId){
        List<Attendee> retList = new List<Attendee>();
        for (CourseAttendance__c ca : [select Id, Attended__c, AttendanceNotes__c, CourseAttendeeEnrollmentId__r.LeadId__r.Name, CourseAttendeeEnrollmentId__r.LeadId__r.Email, CourseAttendeeEnrollmentId__r.ContactId__r.Name, CourseAttendeeEnrollmentId__r.ContactId__r.Email, CourseAttendeeEnrollmentId__r.RegistrationStatus__c from CourseAttendance__c where ScheduledCourseDayId__c =: scheduledCourseDayId and CourseAttendeeEnrollmentId__r.RegistrationStatus__c = 'Registered']){
            retList.add(new Attendee(ca));
        }
        return JSON.serialize(retList);
    }

    @AuraEnabled
    public static void updateAttendance(String caId, Boolean attended){
        CourseAttendance__c ca = new CourseAttendance__c();
        ca.Id = caId;
        ca.Attended__c = attended;
        update ca;
    }

    @AuraEnabled
    public static void updateNotesText(String caId, String notesText){
        CourseAttendance__c ca = new CourseAttendance__c();
        ca.Id = caId;
        ca.AttendanceNotes__c = notesText;
        update ca;
    }

    @AuraEnabled
    public static CoursePaymentInfo__c submitRegistration(List<Lead> l, CourseEnrollment__c ce, CoursePaymentInfo__c cpi){
        try {

            insert l;

            insert cpi;

            List<CourseEnrollment__c> cePerLead = new List<CourseEnrollment__c>();

            // iterate thru all the leads being created
            for (Lead idx : l){
                // copy the CourseEnrollment__c passed in to init a new CourseEnrollment__c
                CourseEnrollment__c newCE = ce.clone(false,false,false,false);
                // set LeadId__c and CoursePaymentInfoId__c for the new CourseEnrollment__c
                newCE.LeadId__c = idx.Id;
                newCE.CoursePaymentInfoId__c = cpi.Id;
                // add to the list of new CourseEnrollment__c to create
                cePerLead.add(newCE);
            }

            insert cePerLead;

            // query out the CPI record to get the reference number
            CoursePaymentInfo__c cpiRet = [select Id, Name from CoursePaymentInfo__c where Id =: cpi.Id];

            return cpiRet;
        }
        catch(Exception ex){
			throw new TrainingClassException('Error creating registration. Error details:' + ex.getMessage() + ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Map<String,List<String>> getFieldInfo(){
        Map<String,List<String>> retMap = new Map<String,List<String>>();
        Schema.DescribeFieldResult dfr = null;

        dfr = Lead.Role__c.getDescribe();
		retMap.put('Role__c', new List<String>());
        for (Schema.PicklistEntry v : dfr.getPicklistValues()){
            retMap.get('Role__c').add(v.getLabel());
        }

        dfr = Lead.Grade__c.getDescribe();
		retMap.put('Grade__c', new List<String>());
        for (Schema.PicklistEntry v : dfr.getPicklistValues()){
            retMap.get('Grade__c').add(v.getLabel());
        }

        dfr = Lead.ProgramType__c.getDescribe();
		retMap.put('ProgramType__c', new List<String>());
        for (Schema.PicklistEntry v : dfr.getPicklistValues()){
            retMap.get('ProgramType__c').add(v.getLabel());
        }

        return retMap;
    }

    @testVisible
    private static List<ScheduledCourse__c> getTrainings(){
        return [select Id, Name, CourseId__r.CourseName__c, CourseId__r.CourseType__c, WebCourseDescription__c, Location__c, WebCourseName__c, Cost__c, RegistreeAcknowledgement__c, MaxNoRegistrations__c, PublishedToWeb__c,
                (select Id, Name, ScheduledDate__c from ScheduledCourseDays__r order by ScheduledDate__c)
                from ScheduledCourse__c];
    }

    @testVisible
    private static List<ScheduledCourse__c> getPublishedTrainings(){
        List<ScheduledCourse__c> retList = new List<ScheduledCourse__c>();
        for (ScheduledCourse__c sc : getTrainings()){
            if (sc.PublishedToWeb__c){
                retList.add(sc);
            }
        }
        return retList;
    }
}