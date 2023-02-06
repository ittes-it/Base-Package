/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* HowToMethods
*
* Example class with functions and methods.
*   - Make sure methods accept lists or overload the methods to accomodate records or lists
*   - Methods should not have as few as possible database commits, you should work in records and lists 
*       and only commit to the db in the end. This reduces the testing complexity of different components
* 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Nick Verschueren <Nick.Verschueren@ittesit.be>
* @version        0.0
* @created        10JAN2023
* @modified       10JAN2023
* @systemLayer    Utility 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v0.0            Nick.Verschueren@ittesit.be
* 10JAN2023       First Draft
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class HowToMethods {

    //How to insert a record;
    public static List<Account> AddTestAccounts(Integer Aantal){
        List<Account> accs = new List<Account>();
        for(Integer i = 0;i < Aantal;i++){
            Account acc = new Account();
            acc.Name = 'TestAccount ' + i;
            // acc.NumberofLocations__c = 1;

            accs.add(acc);
        }

        DML mock = DMLMock.getMock();
        mock.doInsert(accs);
        return accs;
    }

    //How to update a record
    public static void ChangeTestAccountName(Account acc){
        acc.Name = 'Jelle VV nv';


        DML mock = DMLMock.getMock();
        mock.doUpdate(acc);
    }

    //How to delete a record
    public static void deleteTestAccount(Account acc){
        DML mock = DMLMock.getMock();
        mock.doDelete(acc);
    }
    

    //method to add a logline to one record, will be overloaded to a methed that uses lists.
    public static HowTo__c addLog(HowTo__c record, String logLine){
        //create list, and call overloaded method, returns first listitem
        return addLog(new List<HowTo__c>{ record }, logLine)[0];
    }

    //method to add a logline to a list of records
    public static list<HowTo__c> addLog(list<HowTo__c> recordList, String logLine){
        //loop throuh list
        for (HowTo__c record : recordList) {
            if(record.LogVeld__c == null){
                record.LogVeld__c = Datetime.now() + ': ' + logLine;
            }
            else{
                record.LogVeld__c = record.LogVeld__c + '\n' + Datetime.now() + ': ' + logLine;
            }
            //add logline to Field
            
            system.debug(record.LogVeld__c);
        }
        //return updated list
        return recordList;
    }

    //method that creates
    public static void createChildRecord(List<HowTo__c> insertedHowTos, IRepository aggHowToRepo) {
        List<HowToChild__c> childrenToInsert = new List<HowToChild__c>();
        for (HowTo__c insertedHowTo : insertedHowTos) {
            childrenToInsert.add(
            new HowToChild__c(
                TekstVeld__c = 'Aangemaakt door trigger',
                HowTo__c = insertedHowTo.Id
            )
          );
        }
        aggHowToRepo.doInsert(childrenToInsert);
    }
}