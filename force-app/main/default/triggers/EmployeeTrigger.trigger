trigger EmployeeTrigger on Employee__c (after Insert, before delete, after delete, after undelete) {
    if(Trigger.isInsert) {
        if(Trigger.isAfter)    {
			EmployeeTriggerHandler.afterInsert(Trigger.new);
        }
    }
    if(Trigger.isDelete) {
        if(Trigger.isBefore)    {

        }
        if(Trigger.isDelete)    {
            EmployeeTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
    }
    if(Trigger.isUndelete) {
        if(Trigger.isAfter) {
            EmployeeTriggerHandler.afterUndelete(Trigger.new);
        }
    }
}