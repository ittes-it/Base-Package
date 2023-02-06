@istest
public with sharing class HowTo_Async_Tests {
    @testSetup 
    static void setup() {
        Async__c AsyncSettings = new Async__c();
        AsyncSettings.Name = 'default';
        AsyncSettings.Max_BatchLimit__c = 15;
        AsyncSettings.Max_QueueLimit__c = 15;
        AsyncSettings.Max_RetryCount__c = 3;
        insert AsyncSettings;

        LogSettings__c testLogSettings = new LogSettings__c();
        testLogSettings.Name = 'default';
        testLogSettings.Debug__c = true;
        testLogSettings.AutoLogDebug__c = false;
        testLogSettings.AutoLogError__c = false;
        testLogSettings.AutoLogWarn__c = false;

        insert testLogSettings;
    }

    @istest
    static void doAsyncBatch(){
        IRepository repo = Factory.getFactory().withMocks.RepoFactory.getHowToRepo();
        
        HowTo__c howTo = new HowTo__c();
        howTo.TekstVeld__c = 'test';
        
        insert howTo;
        //insert the records
        //not sure how to run a batch with a Database.QueryLocator in a mock scenario because the 
        //batch won't run if the query doest not return anything, and not sure if I can mock that.
        //should be possible with batches with iteratable<sobject> batches.
        //repo.doInsert(howTo);
        
        //start test
        Test.startTest();
        //this is how you would start a batch normaly
        AsyncApexFramework_Helper_Batch batch = new AsyncApexFramework_Helper_Batch();
        Id jobId = Database.executeBatch(batch,2);

        Test.stopTest();
    }
}