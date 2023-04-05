public class EmployeeTriggerHandler {
    public static void afterInsert(List<Employee__c> newList) {
        insertEmployAndPresentEmployeeCount(newList);
    }
    public static void afterDelete(List<Employee__c> oldList, Map<Id, Employee__c> oldMap) {
        //leftEmployeeCountOnAccount(oldList, oldMap);
        insertEmployAndPresentEmployeeCount(oldList);
    }
	
    public static void afterUndelete(List<Employee__c> newList) {
        employRelatedAccountSetActiveTrue(newList);
        employRecordUndeltedUpdateLeftEmployeeCount(newList);
        insertEmployAndPresentEmployeeCount(newList);
    }
    
    private static void leftEmployeeCountOnAccount(List<Employee__c> oldList, Map<Id, Employee__c> oldMap) {
        Set<Id> employIds = new Set<Id>();
        for(Employee__c employ : oldList) {
            employIds.add(employ.Account__c);
        }
    
        List<Account> accounts = new List<Account>();
        for(Account account : [SELECT Id, Name, Left_Employee_Count__c, (SELECT Id, Name, Account__c FROM Employees__r)
                                FROM Account WHERE Id IN : employIds]) {
            account.Left_Employee_Count__c = account.Employees__r.size();
            accounts.add(account);
        }
        if(!accounts.isEmpty()) {
            update accounts;
        }
    }
    
    private static void employRelatedAccountSetActiveTrue(List<Employee__c> newList) {
        Set<Id> employIds = new Set<Id>();
        for(Employee__c employ : newList) {
            employIds.add(employ.Account__c);              
        }
        List<Account> accounts = new List<Account>();
        for(Account account : [SELECT ID, Name, Active__c, (SELECT ID, Name FROM Employees__r) FROM Account WHERE ID IN : employIds]) {
            account.Active__c = 'Yes';
            accounts.add(account);
        }
        if(!accounts.isEmpty()) {
            update accounts;
        }
    }
    
    private static void employRecordUndeltedUpdateLeftEmployeeCount(List<Employee__c> newList) {
        Set<Id> employIds = new Set<Id>();
        for(Employee__c employ : newList) {
            employIds.add(employ.Account__c);              
        }
        List<Account> accounts = new List<Account>();
        for(Account account : [SELECT Id, Name, Left_Employee_Count__c, (SELECT Id, Name, Account__c FROM Employees__r)
                               FROM Account WHERE Id IN : employIds]) {
			account.Left_Employee_Count__c = account.Employees__r.size();
            accounts.add(account);
        }
        if(!accounts.isEmpty()) {
            update accounts;
        }
    }
    
    private static void insertEmployAndPresentEmployeeCount(List<Employee__c> newList) {
        //List<Employee__c> employList = new List<Employee__c>();
        Set<Id> employIds = new Set<Id>();
        for(Employee__c employ : newList) {
            employIds.add(employ.Account__c);              
        }
        List<Account> accounts = new List<Account>();
        for(Account account : [SELECT Id, Name, Present_Employee_Count__c, (SELECT Id, Name, Account__c FROM Employees__r)
                               FROM Account WHERE Id IN : employIds]) {
			account.Present_Employee_Count__c = account.Employees__r.size();
            accounts.add(account);
        }
        if(!accounts.isEmpty()) {
            update accounts;
        }
    }
}