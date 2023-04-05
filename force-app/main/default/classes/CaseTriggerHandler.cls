public class CaseTriggerHandler { 
    public static void afterInsert(List<Case> newCases) {
        setLatestCaseNumber(newCases);
        totalNumbersOnRecordCases(newCases);
    }
    
    private static void setLatestCaseNumber(List<Case> newCases) {
        Set<Id> accountIds = new Set<Id>();
        System.debug('CaseTriggerHandler.setLatestCaseNumber.newCases '+newCases);
        System.debug('CaseTriggerHandler.setLatestCaseNumber.accountIds '+accountIds);
        for(Case caseObj : newCases) {
            accountIds.add(caseObj.AccountId);
        }
        System.debug('CaseTriggerHandler.setLatestCaseNumber.accountIds '+accountIds);
        List<Account> updatedAccountList = new List<Account>();
        List<Account> accounts = [SELECT Id, Latest_Case_Number__c, (SELECT Id, CaseNumber FROM Cases ORDER BY CreatedDate Desc LIMIT 1) FROM
                               Account WHERE Id IN :accountIds];
        System.debug('CaseTriggerHandler.setLatestCaseNumber.accounts '+accounts);
        System.debug('CaseTriggerHandler.setLatestCaseNumber.accounts Serialize '+JSON.serialize(accounts));
        for(Account account : accounts) {
            if(account.Cases != null && account.Cases.size() > 0){
                Account acc = new Account(Id = account.Id, Latest_Case_Number__c =  account.Cases.get(0)?.CaseNumber);
                updatedAccountList.add(acc);
            }
        }
        if(!updatedAccountList.isEmpty()){
            System.debug('CaseTriggerHandler.setLatestCaseNumber.updatedAccountList Serialize '+JSON.serialize(updatedAccountList));
            update updatedAccountList;
        }
    }
    
    private static void totalNumbersOnRecordCases(List<Case> newList) {
        Set<Id> caseIds = new Set<Id>();
        for(Case recCase : newList) {
            caseIds.add(recCase.AccountId);
        }
        List<Account> accounts = new List<Account>();
        //Map<Id, Account> idAccountMap = new Map<Id, Account>();
        for(Account account : [SELECT Id, Name, Partner_Case_Total_Numbers__c, Customer_Case_Total_Numbers__c, (SELECT Id, RecordType.DeveloperName, AccountId 
                               FROM Cases) FROM Account WHERE ID IN : caseIds]) {
                                   System.debug('account.Partner_Case_Total_Numbers__c' +account.Partner_Case_Total_Numbers__c);
                                   System.debug('account.Customer_Case_Total_Numbers__c' +account.Customer_Case_Total_Numbers__c);
            Integer partner = 0,customer =0;
            for(Case reCase : account.Cases) {
                
                if(reCase.RecordType.DeveloperName == 'Partner_Case') {
                    if(account.Partner_Case_Total_Numbers__c == null) {
                        account.Partner_Case_Total_Numbers__c = 0;
                    }
                    partner++;
                    //account.Partner_Case_Total_Numbers__c += 1;
                }
                if(reCase.RecordType.DeveloperName == 'Customer_Case') {
                    if(account.Customer_Case_Total_Numbers__c == null) {
                        account.Customer_Case_Total_Numbers__c =0;
                    }
                    customer++;
                    //account.Customer_Case_Total_Numbers__c += 1;
                }
                //idAccountMap.put(account.Id, account);
            }
            account.Partner_Case_Total_Numbers__c = partner;
            account.Customer_Case_Total_Numbers__c = customer;
            accounts.add(account);
            System.debug(accounts);

        }      
        if(!accounts.isEmpty()) {
            update accounts;
        }
    }
}