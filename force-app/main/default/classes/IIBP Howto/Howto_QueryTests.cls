@isTest
public with sharing class Howto_QueryTests {

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
    static void addAccountCommit(){
        Account acc = new Account();
        acc.Name = 'TestAccount';

        //Creation of a DML interface object so we can perform DML statements
        IDML idml = new DML();
        //Insert account into the database, returns the inserted record or list but has
        //to be typecasted
        Account acc2 = (Account)idml.doInsert(acc);

        System.assertEquals(acc.Name, acc2.Name);
        System.assertNotEquals(null, acc2.Id, 'Account has no Id');
        
        //checking if the returned record is really found in the database
        Account acc3 = [SELECT Id, Name FROM Account WHERE name =:acc.name LIMIT 1];
        System.assertEquals(acc2.Id, acc3.Id);
    }

    @isTest
    static void addAccountCommitShort(){
        Account acc = new Account();
        acc.Name = 'TestAccount';
        
        //you can also directly call the DML class, the acc variable will
        //be updated
        new DML().doInsert(acc);
        
        System.assertNotEquals(null, acc.Id, 'Account has no Id');
    }

    @istest
    static void repotest(){
        IRepository repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();

        Account acc = new Account();
        acc.name = 'test';
        List<Account> accs = new List<Account>{ acc };

        repo.doInsert(acc);
        //repo.doInsert(accs);
        System.assertNotEquals(null, acc.Id, 'Account has no Id');
        //System.assertEquals(acc, DMLMock.Inserted.Accounts.firstOrDefault);

    }

    @istest
    static void doQuery(){
        //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();

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

        system.assertEquals(accs.size(), taccs.size());
    }

    @IsTest
    static void whereClauseWithAndQuery() {
        //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();

        Account acc = new Account();
        acc.name = 'test';
        acc.NumberOfEmployees = 200;
        Account acc2 = new Account();
        acc2.name = 'test 2';
        List<Account> accs = new List<Account>{ acc , acc2};

        //insert the accounts
        repo.doInsert(accs);
        //create an AND query and retrieve a list of the account with numberofemployees 
        list<Query> queries = new list<Query>();
        queries.add(new Query(
            'name',
            Query.operator.ALIKE,
            'test%'
        ));
        queries.add(new Query(
            'NumberOfEmployees',
            Query.operator.EQUALS,
            200
        ));
    
        //excecute the query
        List<Account> taccs2 = (list<Account>)repo.get( queries );
    
        system.assertEquals(taccs2.size(), 1);
    }

    @IsTest
    static void whereClauseWithOrQuery() {
        //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();

        Account acc = new Account();
        acc.name = 'test';
        acc.NumberOfEmployees = 200;
        Account acc2 = new Account();
        acc2.name = 'test 2';
        List<Account> accs = new List<Account>{ acc , acc2};

        //insert the accounts
        repo.doInsert(accs);
        //Create OR WHERE-clause
        Query query = Query.orQuery(
            new List<Query>{
                new Query(
                    Account.NumberOfEmployees,
                    Query.Operator.GREATER_THAN_OR_EQUAL,
                    150
                ),
                new Query(
                    Account.Name,
                    Query.operator.EQUALS,
                    'test 2'
                )
            });

        //Execute Query
        List<Account> taccs = (List<Account>) repo.get(query);
        System.assertEquals(taccs.size(), 2);
    }

    @istest
    static void inDevelopment(){
        //create empty interface
        IRepository repo = null;

        //check if test is running and create a factory with mock if test is running
        if(test.isRunningTest()){
            //always true here since we are running tests...
            repo = Factory.getFactory().withMocks.RepoFactory.getAccountAggregateRepo();
        }
        else{
            repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();
        }
        
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

    @istest
    static void doQueryWithLimit(){
        //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();

        Account acc = new Account();
        acc.name = 'test';
        acc.NumberOfEmployees = 200;
        Account acc2 = new Account();
        acc2.name = 'test 2';
        acc2.NumberOfEmployees = 200;
        List<Account> accs = new List<Account>{ acc , acc2};

        //insert the accounts
        repo.doInsert(accs);

        //create a query and retrieve a list of the created accounts
        list<Query> queries = new list<Query>();
        queries.add(new Query(
            'name',
            Query.operator.ALIKE,
            'test%'
        ));
        queries.add(new Query(
            'NumberOfEmployees',
            Query.operator.EQUALS,
            200
        ));
        repo.setLimit(1);

        List<Account> taccs = (list<Account>)repo.get(queries);

        system.assertEquals(1, taccs.size());
    }

    @IsTest
    static void whereClauseWithOrAndQuery() {
        //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();

        Account acc = new Account();
        acc.name = 'test';
        acc.NumberOfEmployees = 200;
        Account acc2 = new Account();
        acc2.name = 'test 2';
        acc2.NumberOfEmployees = 400;
        List<Account> accs = new List<Account>{ acc , acc2};

        //insert the accounts
        repo.doInsert(accs);
        //Create OR WHERE-clause
        Query query = Query.orAndQuery(
                new Query(
                    Account.NumberOfEmployees,
                    Query.Operator.EQUALS,
                    200
                ),
                new List<Query>{
                    new Query(
                        Account.Name,
                        Query.operator.ALIKE,
                        'test%'),
                    new Query(
                        Account.NumberOfEmployees,
                        Query.operator.EQUALS,
                        400)
                });

        //Execute Query
        List<Account> taccs = (List<Account>) repo.get(query);
        System.assertEquals(taccs.size(), 2);
    }

    @istest
    static void doQueryWithOrder(){
        //create a repo
        //find out how to decide which one, this is not realy clear atm
        IRepository repo = Factory.getFactory().RepoFactory.getAccountAggregateRepo();

        Account acc = new Account();
        acc.name = 'test';
        acc.NumberOfEmployees = 200;
        Account acc2 = new Account();
        acc2.name = 'test 2';
        acc2.NumberOfEmployees = 100;
        List<Account> accs = new List<Account>{ acc , acc2};

        //insert the accounts
        repo.doInsert(accs);

        //create a query and retrieve a list of the created accounts
        list<Query> queries = new list<Query>();
        queries.add(new Query(
            'name',
            Query.operator.ALIKE,
            'test%'
        ));
        repo.setLimit(1);
        repo.setOrderBy('NumberOfEmployees', 'ASC');

        List<Account> taccs = (list<Account>)repo.get(queries);

        system.assertEquals(1, taccs.size());
        system.assertEquals(100, taccs[0].NumberOfEmployees);
    }

}