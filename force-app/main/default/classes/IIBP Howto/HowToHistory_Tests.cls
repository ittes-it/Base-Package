//mag geen testklasse zijn omdat field history niet werkt in test
public with sharing class HowToHistory_Tests {
    //nieuwe custom repo voor HowTo Object
    private class HowToRepo extends FieldLevelHistoryRepo {
        public HowToRepo() {
          super(HowTo__c.SObjectType, 
            new List<Schema.SObjectField>{
            HowTo__c.TekstVeld__c,
            HowTo__c.LogVeld__c
            }, 
            new RepoFactory()
            );
        }
    }

    


    public static void repoTest() {
        //ByPass Triggers, we don't want to test them now
        HowToTriggerhandler.bypassTrigger = true;
        //create a repo
        IHistoryRepository repo = new HowToRepo();

        //create record
        HowTo__c howTo = new HowTo__c();
        howTo.TekstVeld__c = 'test';
        insert howTo;

        HowTo__c howTo2 = new HowTo__c();
        howTo2.TekstVeld__c = 'test2';
        insert howTo2;

        howTo.TekstVeld__c = 'Aangepaste test';
        update howTo;

        //get all records
        List<HowTo__c> howTos = repo.getAll();

        //deze lijn werpt een error want deze klasse heeft geen history actief
        List<FieldLevelHistory> histories = repo.getAllHistory();

        System.assertNotEquals(null, histories);

    
        Debuglog.LogDebug('dump:' + howTos);
        System.assertEquals(2, howTos.size());
        
        System.assertEquals('test', howTos[0].TekstVeld__c);
        System.assertEquals('test2', howTos[1].TekstVeld__c);

        /*

        IHistoryRepository historyRepo = new FieldLevelHistoryRepo(
            HowToFieldHistory.TekstVeld__c,
            HowToFieldHistory.LogVeld__c,
            new RepoFactory()
            );
        List<FieldLevelHistory> histories = historyRepo.getAllHistory();

*/
        //Turn Triggers back on
        HowToTriggerhandler.bypassTrigger = false;
    }
}