trigger TriggerCourseEnrollment on CourseEnrollment__c (after insert) {
    if (Trigger.isAfter){
        if (Trigger.isInsert){
            Set<Id> schedCourseIds = new Set<Id>();
            for (CourseEnrollment__c ce : Trigger.new){
                if (!String.isEmpty(ce.ScheduledCourseId__c))
                    schedCourseIds.add(ce.ScheduledCourseId__c);
            }
            Map<Id, ScheduledCourse__c> schedCourses = new Map<Id, ScheduledCourse__c>([select Id, (select Id from ScheduledCourseDays__r order by ScheduledDate__c) from ScheduledCourse__c where Id =: schedCourseIds]);
            
            List<CourseAttendance__c> cas = new List<CourseAttendance__c>();
            for (CourseEnrollment__c ce : Trigger.new){
                for (ScheduledCourseDay__c day : schedCourses.get(ce.ScheduledCourseId__c).ScheduledCourseDays__r){
                	cas.add(new CourseAttendance__c(CourseAttendeeEnrollmentId__c = ce.Id, ScheduledCourseDayId__c = day.Id));
                }
            }
            
            insert cas;
        }
    }
}