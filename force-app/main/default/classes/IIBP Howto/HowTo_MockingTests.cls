@isTest
public with sharing class HowTo_MockingTests {
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

    @isTest
    static void isInserted_Test(){  
        HowToMethods.AddTestAccounts(1);
        DMLMock.RecordsWrapper wrapper= DMLMock.Inserted.Accounts;
        
        System.assert(wrapper.size() > 0, 'geen account gevonden');
    }
    
    @isTest
    static void isUpdated_Test(){
        HowToMethods.AddTestAccounts(1);
        DMLMock.RecordsWrapper wrapper = DMLMock.Inserted;
        Account acc = (Account)wrapper.Accounts.Records[0];
        String accountNameBefore = acc.Name;

        HowToMethods.ChangeTestAccountName(acc);

        DMLMock.RecordsWrapper updatedWrapper = DMLMock.Updated;
        Account accAfterUpdate = (Account)updatedWrapper.Accounts.Records[0];
        String accountNameAfter = accAfterUpdate.Name;

        System.assert(accountNameBefore != accountNameAfter ,'Het Account is niet gewijzigd');
    }

    @isTest
    static void isDeleted_Test(){
        HowToMethods.AddTestAccounts(1);
        DMLMock.RecordsWrapper wrapper = DMLMock.Inserted;
        Account acc = (Account)wrapper.Accounts.Records[0];

        HowToMethods.deleteTestAccount(acc);

        DMLMock.RecordsWrapper deletedWrapper = DMLMock.Deleted;
        List<SObject> accounts = deletedWrapper.Accounts.Records;
        Debuglog.LogDebug(accounts);
    }

    @isTest
    static void addAccount(){
        Account acc = new Account();
        acc.Name = 'TestAccount';

        //Aanmaken van een Mock object zodat we DML statments kunnen mocken
        DML mock = DMLMock.getMock();
        //Mock insert account with fake ID
        mock.doInsert(acc);
        //DML mock supports retrieving lists from specific objects as a wrapper 
        //that needs to be typecasted later to the correct object type
        DMLMock.RecordsWrapper wrapper= DMLMock.Inserted.Accounts;
        //Retrieving one record from the wrapper and typecasting it to the correct object type
        Account acc2 = (Account)wrapper.Records[0];

        //retrieving inserted records as a list of SObjects
        List<SObject> wrapper2 = DMLMock.InsertedRecords;
        system.assert(wrapper2.size() > 0, 'geen records gevonden');

        for (SObject obj : wrapper2) {
            Debuglog.LogDebug(obj.getSObjectType());
        }
        
        System.assertEquals(acc.Name, acc2.Name);
        System.assertNotEquals(null, acc2.Id, 'Account has no Id');
        
        System.assert(wrapper.size() > 0, 'geen account gevonden');
    }

    @isTest
    static void addAccountAndCustomObject(){
        Account acc = new Account();
        acc.Name = 'TestAccount';

        HowTo__c customObject = new HowTo__c();
        customObject.TekstVeld__c = 'nen tekst';

        //Create a mock object so we can mock inserts with a fake ID
        DML mock = DMLMock.getMock();
        //Mock insert account with fake ID
        mock.doInsert(acc);
        //Mock insert custom object with fake ID
        mock.doInsert(customObject);

        //retrieving a list of SObjects
        List<SObject> wrapper2 = DMLMock.InsertedRecords;
        system.assert(wrapper2.size() > 0, 'geen records gevonden');

        for (SObject obj : wrapper2) {
            Debuglog.LogDebug(obj.getSObjectType());
        }
        System.assertEquals('Account', String.valueOf(wrapper2[0].getSObjectType()));
        System.assertEquals('HowTo__c', String.valueOf(wrapper2[1].getSObjectType()));
   
    }

    @IsTest
    static void queriesWithMockFactory() {
         //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().withMocks.RepoFactory.getAccountRepo();

        Account acc = new Account();
        acc.name = 'test';
        acc.NumberOfEmployees = 200;
        Account acc2 = new Account();
        acc2.name = 'test 2';
        List<Account> accs = new List<Account>{ acc , acc2};

        //insert the accounts
        repo.doInsert(accs);

        //create a query and retrieve a list of the created accounts
        List<Account> taccs = (list<Account>)repo.get(new Query(
            'name',
            Query.operator.ALIKE,
            'test%'
        ));

        //since the repo has with mock on, no results will be found by the query
        system.assertEquals(0, taccs.size());

        //to check the records, get them from DMLMock
        List<Account> taccs2 =  (List<Account>)DMLMock.InsertedRecords;
        system.assertEquals(accs.size(), taccs2.size());
    }

}