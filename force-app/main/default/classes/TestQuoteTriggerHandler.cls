@isTest(seealldata=true)
public class TestQuoteTriggerHandler {

    @isTest
    public static void testQuote() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        RecordType rt = [select Id, Name from RecordType where Name = 'Training Sales'];
        
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.RecordTypeId = rt.Id;
        o.StageName = 'Planning';
        o.Name = 'Test Oppty';
        o.CloseDate = Date.today();
        insert o;
        
        Pricebook2 pb = [select Id from Pricebook2 where Name = 'DLENM - PD'];
        
        User u = [select Id from User where IsActive = true limit 1];
        
        User u2 = [select Id from User where IsActive = true and Id <>: u.Id limit 1];
        
        ProjectFacilitator__c pf = new ProjectFacilitator__c();
        pf.Name = 'Test Test';
        pf.Type__c = 'Staff';
        insert pf;
        
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.OpportunityId = o.Id;
        q.Pricebook2Id = pb.Id;
        q.PrimaryFacilitator__c = pf.Id;
        insert q;
        
        ProjectSupporter__c ps = new ProjectSupporter__c();
        ps.ProjectFacilitator__c = pf.Id;
        ps.Quote__c = q.Id;
        insert ps;
        
        PricebookEntry pbe = [select Id from PricebookEntry where Pricebook2Id =: pb.Id order by CreatedDate desc limit 1];
    
        QuoteLineItem ql = new QuoteLineItem();
        ql.QuoteId = q.Id;
        ql.PricebookEntryId = pbe.Id;
        ql.Quantity = 1;
        ql.UnitPrice = 1.00;
        ql.ServiceDate = Date.today().addDays(5);
        insert ql;
        
        Test.startTest();
        
        q.Status = 'Approved';
        update q;
        
        q.Status = 'Draft';
        update q;
                
        ql.ServiceDate = Date.today().addDays(10);
        update ql;
        
        q.Status = 'Approved';
        update q;
        
        q.Status = 'Accepted';
        update q;
        
        Test.stopTest();
    }
    
}