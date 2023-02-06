public with sharing class HowToHandler {
    private final IRepository oppRepo;

    public HowToHandler(Factory factory) {
        this.oppRepo = factory.RepoFactory.getOppRepo();
    }

    public override void afterInsert(List<SObject> insertedRecords, Map<Id, SObject> unused) {
        List<HowTo__c> insertedHowTos = (List<HowTo__c>) insertedRecords;
        this.setLog(insertedHowTos);
    }

    private void setLog(List<HowTo__c> insertedHowTos) {
        for (HowTo__c insertedHowTo : insertedHowTos) {
        
            insertedHowTo.LogVeld__c = system.now() + ' created.';
        }
        
    }
}
