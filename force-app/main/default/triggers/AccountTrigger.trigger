trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            AccountTriggerHandler.beforeInsert(Trigger.New); 
        }
    
        when AFTER_INSERT {
           AccountTriggerHandler.afterInsert(Trigger.New);
        }
    
        when BEFORE_UPDATE {
            AccountTriggerHandler.beforeUpdate(Trigger.New, Trigger.oldMap);
        }
    
        when AFTER_UPDATE {
            AccountTriggerHandler.afterUpdate(Trigger.New, Trigger.oldMap);
        }
    
        when BEFORE_DELETE {
            AccountTriggerHandler.beforeDelete(Trigger.Old);
        }

        // when AFTER_DELETE {
        //     AccountTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        // }
    }
    // if(Trigger.isInsert) {
    //     if(Trigger.isBefore) {
    //       	AccountTriggerHandler.beforeInsert(Trigger.New);  
    //     }
    //     if(Trigger.isAfter) {
    //         AccountTriggerHandler.afterInsert(Trigger.New);
    //     }
    // }

    // if(Trigger.isUpdate) {
    //     if(Trigger.isBefore) {
    //         AccountTriggerHandler.beforeUpdate(Trigger.New, Trigger.oldMap);
    //     }
    //     if(Trigger.isAfter) {
    //         AccountTriggerHandler.afterUpdate(Trigger.New, Trigger.oldMap);
    //     }
    // }
    // if(Trigger.isDelete) {
    //     if(Trigger.isBefore) {
    //         AccountTriggerHandler.beforeDelete(Trigger.Old);
    //     }
    //     if(Trigger.isAfter) {
    //         AccountTriggerHandler.afterDelete(Trigger.New, Trigger.newMap);
    //     }
}