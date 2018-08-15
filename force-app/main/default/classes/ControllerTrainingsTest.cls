@isTest
public class ControllerTrainingsTest {
    static Map<String,String> mockData;
    static CourseEnrollment__c mockCE;

    @isTest
    public static void getFieldInfo(){
        ControllerTrainings.getFieldInfo();
    }

    @isTest
    public static void getTrainings(){
        Map<String,String> retMap = insertMockData();
        List<ScheduledCourse__c> lst = ControllerTrainings.getAllTrainings('AIM');
        ControllerTrainings.getScheduledCourseInfo(retMap.get('sc'));
    }

    @isTest
    public static void getCurrentRegistrantCount(){
        Map<String,String> retMap = insertMockData();
        List<ScheduledCourse__c> lst = ControllerTrainings.getAllTrainings('AIM');
        ControllerTrainings.currentRegistrantCount(retMap.get('sc'));
    }

    @isTest
    public static void getRosterList(){
        Map<String,String> retMap = insertMockData();
        List<ScheduledCourse__c> lst = ControllerTrainings.getAllTrainings('AIM');
        ControllerTrainings.getRosterList(retMap.get('scd'));
    }

    @isTest
    public static void testMarkingAttended(){
        insertRegistration();
        List<ScheduledCourse__c> lst = ControllerTrainings.getAllTrainings('AIM');
		List<Attendee> attendees = (List<Attendee>)JSON.deserializeStrict(ControllerTrainings.getRosterList(mockData.get('scd')), List<Attendee>.class);
        ControllerTrainings.updateAttendance(attendees[0].Id, true);
        ControllerTrainings.updateNotesText(attendees[0].Id, 'testing');
    }

    @isTest
    public static void insertRegistration(){
        Map<String,String> retMap = insertMockData();
        List<Lead> l = new List<Lead>();
        // successful insert
        l.add((Lead)JSON.deserializeStrict('{"LeadSource":"Web","Lead_Type__c":"AIM4SCubed","FirstName":"first","LastName":"last","Email":"email@email.com","Company":"company"}', Lead.class));
        mockCE = (CourseEnrollment__c)JSON.deserializeStrict('{"ScheduledCourseId__c":"' + retMap.get('sc') + '"}', CourseEnrollment__c.class);
        CoursePaymentInfo__c cpi = (CoursePaymentInfo__c)JSON.deserializeStrict('{"BillingFirstName__c":"first"}', CoursePaymentInfo__c.class);
        ControllerTrainings.submitRegistration(l, mockCE, cpi);

        // fail insert by not providing a last name
        try {
            l[0] = ((Lead)JSON.deserializeStrict('{"LeadSource":"Web","Lead_Type__c":"AIM4SCubed","FirstName":"first","Company":"company"}', Lead.class));
            mockCE = (CourseEnrollment__c)JSON.deserializeStrict('{"ScheduledCourseId__c":"' + retMap.get('sc') + '"}', CourseEnrollment__c.class);
            cpi = (CoursePaymentInfo__c)JSON.deserializeStrict('{"BillingFirstName__c":"first"}', CoursePaymentInfo__c.class);
            ControllerTrainings.submitRegistration(l, mockCE, cpi);
        }
        catch(Exception ex){
            System.assert(ex.getMessage().startsWithIgnoreCase('Error creating registration.'));
        }
    }

    @isTest
    public static void testLeadConversionTrigger(){
        Map<String,String> retMap = insertMockData();
        List<Lead> l = new List<Lead>();
        // successful insert
        l.add((Lead)JSON.deserializeStrict('{"LeadSource":"Web","Lead_Type__c":"AIM4SCubed","FirstName":"first","LastName":"last","Email":"email@email.com","Company":"company"}', Lead.class));
        CourseEnrollment__c ce = (CourseEnrollment__c)JSON.deserializeStrict('{"ScheduledCourseId__c":"' + retMap.get('sc') + '","RegistrationStatus__c":"Registered"}', CourseEnrollment__c.class);
        CoursePaymentInfo__c cpi = (CoursePaymentInfo__c)JSON.deserializeStrict('{"BillingFirstName__c":"first"}', CoursePaymentInfo__c.class);
        ControllerTrainings.submitRegistration(l, ce, cpi);

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l[0].Id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
    }

    public static Map<String,String> insertMockData(){
        Course__c c = (Course__c)JSON.deserializeStrict('{"Name":"AIM Level 1","CourseName__c":"CourseName","CourseType__c":"AIM"}', Course__c.class);
        insert c;
        ScheduledCourse__c sc = (ScheduledCourse__c)JSON.deserializeStrict('{"CourseId__c" : "' + c.Id + '", "WebCourseDescription__c" : "description", "Location__c" : "location", "WebCourseName__c" : "courseName", "Cost__c" : 1000.00, "RegistreeAcknowledgement__c" : "acknowledgement", "PublishedToWeb__c" : true}', ScheduledCourse__c.class);
        insert sc;
        ScheduledCourseDay__c scd = (ScheduledCourseDay__c)JSON.deserializeStrict('{"ScheduledCourseId__c" : "' + sc.Id + '", "Name" : "Day1", "ScheduledDate__c" : "2018-01-10" }', ScheduledCourseDay__c.class);
        insert scd;

        mockData = new Map<String,String>();
        mockData.put('c',c.Id);
        mockData.put('sc',sc.Id);
        mockData.put('scd',scd.Id);
        return mockData;
    }
}