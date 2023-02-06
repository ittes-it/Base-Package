@isTest
public with sharing class HowToTriggerhandler_Tests {

    @isTest
    public static void realinsertTest(){
        //for coverage on the trigger itself.
        HowToTriggerhandler.bypassTrigger = true;
        HowTo__c ht = new HowTo__c();
        ht.TekstVeld__c = 'Tis nen uitleg gelijk een ander';

        insert ht;
        ht.LogVeld__c = 'blabla';
        update ht;
        delete ht;
        undelete ht;

        HowToTriggerhandler.bypassTrigger = false;
    }

    @IsTest
    static void beforeInsertHandler() {
        //IRepository repo = Factory.getFactory().withMocks.RepoFactory.getAccountRepo();

        HowTo__c ht = new HowTo__c();
        ht.Id = TestingUtils.generateId(HowTo__c.SObjectType);
        ht.TekstVeld__c = 'Tis nen uitleg gelijk een ander';

        

        Factory.getFactory()
        .withMocks.getHowToHandler()
        .beforeInsert(new List<SObject>{ ht }, new Map<Id, SObject>(new List<SObject>{ ht }));

        System.assert(ht.LogVeld__c.contains('Before Insert log'));
    }

    @IsTest
    static void afterInsertHandler() {
        HowTo__c ht = new HowTo__c();
        ht.Id = TestingUtils.generateId(HowTo__c.SObjectType);
        ht.TekstVeld__c = 'Tis nen uitleg gelijk een ander';

        Factory.getFactory()
        .withMocks.getHowToHandler()
        .afterInsert(new List<SObject>{ ht }, new Map<Id, SObject>(new List<SObject>{ ht }));

        HowToChild__c child = (HowToChild__c) DMLMock.Inserted.singleOrDefault;
        
        System.assertNotEquals(null, child, 'child should have been created!');
        System.assertEquals(ht.Id, child.HowTo__c);
    }
}