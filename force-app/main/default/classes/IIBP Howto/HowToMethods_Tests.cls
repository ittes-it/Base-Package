@istest
public with sharing class HowToMethods_Tests {
    @TestSetup
    static void makeData(){
        GraylogSettings__c testGraylogSettings = new GraylogSettings__c();
		testGraylogSettings.Name = 'default';
		testGraylogSettings.Endpoint__c = 'http://ergens';
		testGraylogSettings.Hostname__c = 'IIBP Tests';
        testGraylogSettings.Debug__c = true;
		insert testGraylogSettings;

        LogSettings__c testLogSettings = new LogSettings__c();
        testLogSettings.Name = 'default';
        testLogSettings.Debug__c = true;
        testLogSettings.AutoLogDebug__c = false;
        testLogSettings.AutoLogError__c = false;
        testLogSettings.AutoLogWarn__c = false;

        insert testLogSettings;
    }

    @istest
    static void addLogLine2RecordWithMock(){
        //ByPass Triggers, we don't want to test them now
        HowToTriggerhandler.bypassTrigger = true;
        //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().withMocks.RepoFactory.getAccountRepo();
        
        HowTo__c howTo = new HowTo__c();
        howTo.TekstVeld__c = 'test';

        system.assertEquals(null, howTo.Id, 'Should not have an Id at this point!');

        
        //insert the records
        repo.doInsert(howTo);

        //record should have an ID now
        system.assertNotEquals(null, howTo.Id, 'No ID found');

        //to check the records, get them from DMLMock
        List<HowTo__c> ihowTos = (List<HowTo__c>)DMLMock.InsertedRecords;
        Debuglog.LogDebug(ihowTos.size());

        //the howTo record is also updated, so you can also use this instead of retrieving it.
        system.assertEquals(ihowTos[0].Id, howTo.Id, 'No ID match');

        //process the records with the addLog Method
        HowTo__c chowTo = HowToMethods.addLog(ihowTos[0], 'tis nen uitleg gelijk een ander');

        //update the records
        repo.doUpdate(chowTo);

        //get the updated records
        List<HowTo__c> uhowTos = (List<HowTo__c>)DMLMock.UpdatedRecords;
        Debuglog.LogDebug(uhowTos.size());

        //check if the logtext is found in the updted records.
        system.assert(uhowTos[0].LogVeld__c.contains('tis nen uitleg gelijk een ander'), uhowTos[0].LogVeld__c + ' bevat niet de juiste tekst');

        system.assertEquals(ihowTos[0].Id, uhowTos[0].Id, 'No ID match');

        //Turn Triggers back on
        HowToTriggerhandler.bypassTrigger = false;
    }


    //test om te zien of ik de repo's kan doorgronden.
    @IsTest
    static void repoTestWithChildrenAndParent() {
        //ByPass Triggers, we don't want to test them now
        HowToTriggerhandler.bypassTrigger = true;
        //create a repo
        IRepository repo = new HowToRepo();

        //add a parent field
        repo.addParentFields(new List<Schema.SObjectField>{ HowTo__c.Account__c }, new List<Schema.SObjectField>{ Account.Id, Account.Name });
        //add a child
        repo.addChildFields(HowToChild__c.HowTo__c, new List<Schema.SObjectField>{ HowToChild__c.HowTo__c, HowToChild__c.TekstVeld__c });

        //create parent
        Account acc = new Account(Name = 'Parent');
        insert acc;

        //create record
        HowTo__c howTo = new HowTo__c();
        howTo.TekstVeld__c = 'test';
        howTo.Account__c = acc.Id;
        insert howTo;

        //create child
        HowToChild__c howChild = new HowToChild__c();
        howChild.TekstVeld__c = 'test kind';
        howChild.HowTo__c = howTo.Id;
        insert howChild;
    
        //get all records
        List<HowTo__c> howTos = repo.getAll();
        Debuglog.LogDebug('dump:' + howTos);
        System.assertEquals(1, howTos.size());
        
        System.assertEquals('test', howTos[0].TekstVeld__c);

        //check if parent is linked
        System.assertEquals(acc.Id, howTos[0].Account__r.Id);
        System.assertEquals('Parent', howTos[0].Account__r.Name);

        //check if child is linked
        //NOTE the link is based on the link api name on the parent object
        System.assertEquals(howChild.Id, howTos[0].HowToChildren__r[0].id);
        System.assertEquals(1, howTos[0].HowToChildren__r.size());
        System.assertEquals(1, howTos.get(0).HowToChildren__r.size());
        HowToChild__c returnedChild = howTos.get(0).HowToChildren__r.get(0);

        Debuglog.LogDebug('dump:' + returnedChild);
        System.assertEquals(howChild, returnedChild);

        //Turn Triggers back on
        HowToTriggerhandler.bypassTrigger = false;
    }

    @IsTest
    static void repoTest() {
        //ByPass Triggers, we don't want to test them now
        HowToTriggerhandler.bypassTrigger = true;
        //create a repo
        IRepository repo = new HowToRepo();

        //create record
        HowTo__c howTo = new HowTo__c();
        howTo.TekstVeld__c = 'test';
        insert howTo;

        HowTo__c howTo2 = new HowTo__c();
        howTo2.TekstVeld__c = 'test2';
        insert howTo2;

        //get all records
        List<HowTo__c> howTos = repo.getAll();
        Debuglog.LogDebug('dump:' + howTos);
        System.assertEquals(2, howTos.size());
        
        System.assertEquals('test', howTos[0].TekstVeld__c);
        System.assertEquals('test2', howTos[1].TekstVeld__c);
        //Turn Triggers back on
        HowToTriggerhandler.bypassTrigger = false;
    }

    //nieuwe custom repo voor HowTo Object
    private class HowToRepo extends Repository {
        public HowToRepo() {
          super(HowTo__c.SObjectType, 
            new List<Schema.SObjectField>{
            HowTo__c.TekstVeld__c
            }, 
            new RepoFactoryMock()
            );
        }
      }

    @istest
    static void aggregatedHowTo(){
        //ByPass Triggers, we don't want to test them now
        HowToTriggerhandler.bypassTrigger = true;
        //create record
        HowTo__c howTo = new HowTo__c();
        howTo.TekstVeld__c = 'test';
        insert howTo;

        HowTo__c howTo2 = new HowTo__c();
        howTo2.TekstVeld__c = 'test2';
        insert howTo2;

        //create children
        HowToChild__c howChild = new HowToChild__c();
        howChild.TekstVeld__c = 'groep1';
        howChild.HowTo__c = howTo.Id;
        howChild.GetalVeld__c = 1.0;
        insert howChild;

        HowToChild__c howChild2 = new HowToChild__c();
        howChild2.TekstVeld__c = 'groep1';
        howChild2.HowTo__c = howTo.Id;
        howChild2.GetalVeld__c = 1.0;
        insert howChild2;

        HowToChild__c howChild3 = new HowToChild__c();
        howChild3.TekstVeld__c = 'groep2';
        howChild3.HowTo__c = howTo2.Id;
        howChild3.GetalVeld__c = 1.0;
        insert howChild3;

        HowToChild__c howChild4 = new HowToChild__c();
        howChild4.TekstVeld__c = 'groep2';
        howChild4.HowTo__c = howTo2.Id;
        howChild4.GetalVeld__c = 0.0;
        insert howChild4;

        //alias (childsum etc) is een alias die enkel nodig is voor de query op te bouwen, zelf ga je die niet meer actief nodig hebben.
        //set up an aggregation for a sum
        Aggregation sum = Aggregation.sum(HowToChild__c.GetalVeld__c, 'childSum');
        //set up an aggregation for a count
        Aggregation count = Aggregation.count(HowToChild__c.GetalVeld__c, 'childcount');
        //set up an aggregation for a average
        Aggregation average = Aggregation.average(HowToChild__c.GetalVeld__c, 'childaverage');
        //set up an aggregation for a min
        Aggregation min = Aggregation.min(HowToChild__c.GetalVeld__c, 'childmin');
        //set up an aggregation for a max
        Aggregation max = Aggregation.max(HowToChild__c.GetalVeld__c, 'childmax');

        //create an aggregation repo
        IAggregateRepository repo = new AggregateRepository(
            HowToChild__c.SObjectType,
            new List<SObjectField>{ HowToChild__c.Id, HowToChild__c.TekstVeld__c, HowToChild__c.GetalVeld__c },
            new RepoFactory()
        );
        //repo.addParentFields(new List<Schema.SObjectField>{ HowToChild__c.HowTo__c }, new List<Schema.SObjectField>{ HowTo__c.Id, HowTo__c.TekstVeld__c });

        //set the group by
        repo.groupBy(HowToChild__c.HowTo__c);

        //Collect the results of the sum aggregation
        List<AggregateRecord> sumResults = repo.aggregate(sum);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, sumResults?.size());
        //loop through results to check if sum was done correctly
        for (AggregateRecord res : sumResults) {
            if (res.get('HowTo__c') == howTo.Id) {
                System.assertEquals(2, res.get(sum.getAlias()));
            } else {
                System.assertEquals(1, res.get(sum.getAlias()));
            }
        }

        //Collect the results of the count aggregation
        List<AggregateRecord> countResults = repo.aggregate(count);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, countResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : countResults) {
            System.assertEquals(2, res.get(count.getAlias()));
        }

        //Collect the results of the count aggregation
        List<AggregateRecord> averageResults = repo.aggregate(average);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, averageResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : averageResults) {
            if(res.get('HowTo__c') == howTo.Id){
                System.assertEquals(1, res.get(average.getAlias()));
            }
            else{
                System.assertEquals(0.5, res.get(average.getAlias()));
            }
        }

        //Collect the results of the min aggregation
        List<AggregateRecord> minResults = repo.aggregate(min);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, minResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : minResults) {
            if(res.get('HowTo__c') == howTo.Id){
                System.assertEquals(1, res.get(min.getAlias()));
            }
            else{
                System.assertEquals(0, res.get(min.getAlias()));
            }
            
        }

        //Collect the results of the max aggregation
        List<AggregateRecord> maxResults = repo.aggregate(max);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, maxResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : maxResults) {
            System.assertEquals(1, res.get(max.getAlias()));
        }


        //Turn Triggers back on
        HowToTriggerhandler.bypassTrigger = false;
    }

    @istest
    static void aggregatedHowToNoAlias(){
        //ByPass Triggers, we don't want to test them now
        HowToTriggerhandler.bypassTrigger = true;
        //create record
        HowTo__c howTo = new HowTo__c();
        howTo.TekstVeld__c = 'test';
        insert howTo;

        HowTo__c howTo2 = new HowTo__c();
        howTo2.TekstVeld__c = 'test2';
        insert howTo2;

        //create children
        HowToChild__c howChild = new HowToChild__c();
        howChild.TekstVeld__c = 'groep1';
        howChild.HowTo__c = howTo.Id;
        howChild.GetalVeld__c = 1.0;
        insert howChild;

        HowToChild__c howChild2 = new HowToChild__c();
        howChild2.TekstVeld__c = 'groep1';
        howChild2.HowTo__c = howTo.Id;
        howChild2.GetalVeld__c = 1.0;
        insert howChild2;

        HowToChild__c howChild3 = new HowToChild__c();
        howChild3.TekstVeld__c = 'groep2';
        howChild3.HowTo__c = howTo2.Id;
        howChild3.GetalVeld__c = 1.0;
        insert howChild3;

        HowToChild__c howChild4 = new HowToChild__c();
        howChild4.TekstVeld__c = 'groep2';
        howChild4.HowTo__c = howTo2.Id;
        howChild4.GetalVeld__c = 0.0;
        insert howChild4;

        //set up an aggregation for a sum
        Aggregation sum = Aggregation.sum(HowToChild__c.GetalVeld__c);
        //set up an aggregation for a count
        Aggregation count = Aggregation.count(HowToChild__c.GetalVeld__c);
        //set up an aggregation for a average
        Aggregation average = Aggregation.average(HowToChild__c.GetalVeld__c);
        //set up an aggregation for a min
        Aggregation min = Aggregation.min(HowToChild__c.GetalVeld__c);
        //set up an aggregation for a max
        Aggregation max = Aggregation.max(HowToChild__c.GetalVeld__c);

        //create an aggregation repo
        IAggregateRepository repo = new AggregateRepository(
            HowToChild__c.SObjectType,
            new List<SObjectField>{ HowToChild__c.Id, HowToChild__c.TekstVeld__c, HowToChild__c.GetalVeld__c },
            new RepoFactory()
        );
        //repo.addParentFields(new List<Schema.SObjectField>{ HowToChild__c.HowTo__c }, new List<Schema.SObjectField>{ HowTo__c.Id, HowTo__c.TekstVeld__c });

        //set the group by
        repo.groupBy(HowToChild__c.HowTo__c);

        //Collect the results of the sum aggregation
        List<AggregateRecord> sumResults = repo.aggregate(sum);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, sumResults?.size());
        //loop through results to check if sum was done correctly
        for (AggregateRecord res : sumResults) {
            if (res.get('HowTo__c') == howTo.Id) {
                System.assertEquals(2, res.get(sum.getAlias()));
            } else {
                System.assertEquals(1, res.get(sum.getAlias()));
            }
        }

        //Collect the results of the count aggregation
        List<AggregateRecord> countResults = repo.aggregate(count);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, countResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : countResults) {
            System.assertEquals(2, res.get(count.getAlias()));
        }

        //Collect the results of the count aggregation
        List<AggregateRecord> averageResults = repo.aggregate(average);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, averageResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : averageResults) {
            if(res.get('HowTo__c') == howTo.Id){
                System.assertEquals(1, res.get(average.getAlias()));
            }
            else{
                System.assertEquals(0.5, res.get(average.getAlias()));
            }
        }

        //Collect the results of the min aggregation
        List<AggregateRecord> minResults = repo.aggregate(min);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, minResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : minResults) {
            if(res.get('HowTo__c') == howTo.Id){
                System.assertEquals(1, res.get(min.getAlias()));
            }
            else{
                System.assertEquals(0, res.get(min.getAlias()));
            }
            
        }

        //Collect the results of the max aggregation
        List<AggregateRecord> maxResults = repo.aggregate(max);

        //check if 2 results are found for the two parent records on which we sorted
        System.assertEquals(2, maxResults?.size());
        //loop through results to check if count was done correctly
        for (AggregateRecord res : maxResults) {
            System.assertEquals(1, res.get(max.getAlias()));
        }


        //Turn Triggers back on
        HowToTriggerhandler.bypassTrigger = false;
    }
}