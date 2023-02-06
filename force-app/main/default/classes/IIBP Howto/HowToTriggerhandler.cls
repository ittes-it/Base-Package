public with sharing class HowToTriggerhandler extends TriggerHandler {
    //if set to true, triggers will be bypassed.
    @TestVisible public static Boolean bypassTrigger = false;

    //private final IRepository aggHowToRepo;
    private final Factory factory;

    public HowToTriggerhandler(Factory factory) {
        this.factory = factory;      
    }

    //lijst van alle velden van dit object, indien nodig. Indien niet, kan het in comments gezet worden
    private static Set<String> objectFields = Schema.SObjectType.HowTo__c.fields.getMap().keySet();

    //////////////
    // BEFORE
    //////////////
    public override void beforeInsert(list<SObject> lstNew,  map<id, SObject> mNewRecord){
        if(bypassTrigger) return;
        ////////
        //insert logic here
        ////////
        HowToMethods.addLog(lstNew, 'Before Insert log');
    }

    public override void beforeUpdate(list<SObject> lstNew, Map<Id, SObject> mNewRecord,  list<SObject> lstOld, Map<Id, SObject> mOldRecord){
        if(bypassTrigger) return;
        ////////
        //insert logic here
        ////////
        HowToMethods.addLog(lstNew, 'Before Update log');
    } 

    public override void beforeDelete(list<SObject> lstNew,  map<id, SObject> mNewRecord){
        if(bypassTrigger) return;
        ////////
        //insert logic here
        ////////
    }

    //////////////
    // AFTER
    //////////////
    public override void afterInsert(list<SObject> lstNew,  map<id, SObject> mNewRecord){
        if(bypassTrigger) return;
        ////////
        //insert logic here
        ////////
        HowToMethods.createChildRecord(lstNew, factory.RepoFactory.aggHowTo());
        
    }
    
    public override void afterUpdate(list<SObject> lstNew, Map<Id, SObject> mNewRecord,  list<SObject> lstOld, Map<Id, SObject> mOldRecord){
        if(bypassTrigger) return;
        ////////
        //insert logic here
        ////////
    }

    public override void afterDelete(list<SObject> lstNew,  map<id, SObject> mNewRecord){
        if(bypassTrigger) return;
        ////////
        //insert logic here
        ////////
    }

    public override void afterUnDelete(list<SObject> lstNew,  map<id, SObject> mNewRecord){
        if(bypassTrigger) return;
        ////////
        //insert logic here
        ////////
    }

    


    


}