trigger HowToTrigger on HowTo__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    if(Trigger.isBefore){
        // Call Before Insert methods.
        if(Trigger.isInsert){
            Factory.getFactory()
                .getHowToHandler()
                .beforeInsert(Trigger.new, Trigger.newMap);

        }
        
        // Call Before Update methods.
        if(Trigger.isUpdate){
            Factory.getFactory()
                .getHowToHandler()
                .beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }

        // Call Before Delete methods.
        if(Trigger.isDelete){
            Factory.getFactory()
                .getHowToHandler()
                .beforeDelete(Trigger.new, Trigger.newMap);
        }
    }
    
    if(Trigger.isAfter){
        // Call After Insert methods.
        if(Trigger.isInsert){
            Factory.getFactory()
                .getHowToHandler()
                .afterInsert(Trigger.new, Trigger.newMap);
        }
        
        // Call After Update methods.
        if(Trigger.isUpdate){
            Factory.getFactory()
                .getHowToHandler()
                .afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }

        // Call After Delete methods.
        if(Trigger.isDelete){
            Factory.getFactory()
                .getHowToHandler()
                .afterDelete(Trigger.new, Trigger.newMap);
        }

        // Call After Undelete methods.
        if(Trigger.isUndelete){
            Factory.getFactory()
                .getHowToHandler()
                .afterUnDelete(Trigger.new, Trigger.newMap);
        }
        
    }
}