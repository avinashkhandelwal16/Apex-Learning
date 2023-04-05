trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete) {
    switch on Trigger.operationType{
        when BEFORE_INSERT {
            ContactTriggerHandler.beforeInsert(Trigger.New);
        }
        when AFTER_INSERT {
            ContactTriggerHandler.afterInsert(Trigger.New);
        }
    }
}