trigger OpportunityTrigger on Opportunity (before Insert, after insert, before Update, after update, before delete, after delete) {
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            OpportunityTriggerHandler.beforeInsert(Trigger.New); 
        }
        if(Trigger.isAfter) {
            OpportunityTriggerHandler.afterInsert(Trigger.New);
        }
    }

    if(Trigger.isUpdate) {
        if(Trigger.isBefore) {
            OpportunityTriggerHandler.beforeUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isAfter) {
            OpportunityTriggerHandler.afterUpdate(Trigger.New, Trigger.oldMap);
        }
    }

    if(Trigger.isDelete) {
        if(Trigger.isBefore) {
            OpportunityTriggerHandler.beforeDelete(Trigger.old); 
        }
        if(Trigger.isAfter) {
            OpportunityTriggerHandler.afterDelete(Trigger.old);
        }
    }
}