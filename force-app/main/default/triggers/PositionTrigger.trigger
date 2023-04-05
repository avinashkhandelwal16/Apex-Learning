trigger PositionTrigger on Position__c (before insert) {
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            PositionTriggerHandler.insertNewPosition(Trigger.New);
        }
    }
}