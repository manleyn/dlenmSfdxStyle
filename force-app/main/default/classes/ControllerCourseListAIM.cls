public class ControllerCourseListAIM {
    public List<ScheduledCourse__c> trainings {
        get {
            if (trainings == null){
                trainings = ControllerTrainings.getAllTrainings('AIM');
            }
            return trainings;
        }
        private set;
    }

    public Map<Id,Integer> registeredAttendees {
        get {
            if (registeredAttendees == null){
                registeredAttendees = new Map<Id,Integer>();

                for (ScheduledCourse__c c : trainings){
                    registeredAttendees.put(c.Id, 0);
                }
                List<CourseEnrollment__c> ces = ControllerTrainings.currentRegistrantList(registeredAttendees.keySet());
                for (CourseEnrollment__c c : ces){
                    if (registeredAttendees.containsKey(c.ScheduledCourseId__c)){
                        registeredAttendees.put(c.ScheduledCourseId__c, registeredAttendees.get(c.ScheduledCourseId__c) + 1);
                    } else {
                        registeredAttendees.put(c.ScheduledCourseId__c, 1);
                    }
                }
            }
            return registeredAttendees;
        }
        private set;

    }
}