trigger UserTrigger on User (before insert, after insert) {
    switch on Trigger.operationType{
        when AFTER_INSERT {
            UserTriggerHandler.afterInsert(Trigger.New);
        }
    }
}