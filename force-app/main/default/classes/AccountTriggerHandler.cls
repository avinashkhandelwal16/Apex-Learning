public class AccountTriggerHandler {
    public static void beforeInsert(List<Account> accounts) {
        //copyBillingToShipping(accounts);
        copyBillingToShippingAddress(accounts, null);
        populateRatingInAccount(accounts, null);
    }

    public static void afterInsert(List<Account> accounts) {
        //createRelatedContact(accounts);
        //createRelatedOpportunity(accounts);
        createContactAndOpportunityByCheckBox(accounts);
        setOWDForAccount(accounts);
    }

    public static void beforeUpdate(List<Account> newList, Map<Id,Account> oldMap) {
        updateAccountDescription(newList, oldMap);
        copyBillingToShippingAddress(newList, oldMap);
        populateRatingInAccount(newList, oldMap);
        //preventAccountRecordFromEdited(newList, oldMap);
    }

    public static void afterUpdate(List<Account> accounts, Map<Id,Account> oldMap) {
        //populatePhoneNumberAccountContact(accounts, oldMap);
        //populatePhoneNumberAccountContactWithSOQL(accounts, oldMap);
        //updateContactMailingAddress(accounts, oldMap);
        updateContactMailingAddressWithSOQL(accounts, oldMap);
        updateAllOpportunityStage(accounts, oldMap);
    }

    public static void beforeDelete(List<Account> oldList) {
        System.debug('hyyyyyyyyyyyyyyy');
        preventdeleteAnAccount(oldList);
        checkOnlySystemAdministratorProfileUsers(oldList);
        preventDeletionAccountRelatedToOpportunity(oldList);
        preventDeletionAccountRelatedToCase(oldList);
    }

    // public static void afterDelete(List<Account> accounts, Map<Id,Account> newMap) {
       
    // }

    private static void copyBillingToShipping(List<Account> accList) {
        for(Account account : accList) {
            if(account.CopyBillingToShipping__c ) {
                account.ShippingCity = account.BillingCity;
                account.ShippingCountry = account.BillingCountry;
                account.ShippingStreet = account.BillingStreet;
                account.ShippingPostalCode = account.BillingPostalCode;
                account.ShippingState = account.BillingState;
            } 
        }
    } 
    
    private static void createRelatedContact(List<Account> accList) {
        Set<Id> accountIds = new Set<Id>();
        for(Account account : accList) {
            accountIds.add(account.Id);
            // Contact con = new Contact();
            // con.LastName = account.Name;
            // con.AccountId = account.Id;
            // contact.add(con);         
        }
        if(!accountIds.isEmpty()) {
            AccountService.createRelatedContact(accountIds);
        }
    }
    
    private static void createRelatedOpportunity(List<Account> accList) {
        List<Opportunity> opportunity = new List<Opportunity>();
        for(Account account : accList) {
            Opportunity opp = new Opportunity();
            opp.Name = account.Name;
            opp.StageName = 'Qualification';
            opp.CloseDate = System.today();
            opp.AccountId = account.Id;
            Opportunity.add(opp);         
        }
        if(!Opportunity.isEmpty()) {
            insert Opportunity;
        }
    }

    private static void createContactAndOpportunityByCheckBox(List<Account> accounts) {
        List<Contact> contact = new List<Contact>();
        List<Opportunity> opportunity = new List<Opportunity>();
        for(Account account : accounts) {
            if(account.Contact__c == true) {
                Contact con = new Contact();
                con.AccountId = account.Id;
                con.LastName = account.Name;
                contact.add(con);
            }
            if(account.Opportunity__c == true && account.Active__c == 'Yes') {
                Opportunity opp = new Opportunity();
                opp.AccountId = account.Id;
                opp.Name = account.Name;
                opp.StageName = 'Qualification';
                opp.CloseDate = System.today();
                Opportunity.add(opp);
            }
        }
        if(!contact.isEmpty()) {
            insert contact;
        }
        if(!opportunity.isEmpty()) {
            insert opportunity;
        }
    }

    private static void updateAccountDescription(List<Account> newList, Map<Id,Account> oldMap) {
        for(Account account : newList) {
            if(oldMap != null && account.Phone != oldMap.get(account.Id).Phone) {
                account.Description = 'Phone is Updated! Old Value :' +oldMap.get(account.Id).Phone +' & New Value :' +account.Phone;
            }
        }
    }

    private static void copyBillingToShippingAddress(List<Account> newList, Map<Id,Account> oldMap) {
        for(Account account : newList) {
            if(account.CopyBillingToShipping__c == true) {
                account.ShippingCity = account.BillingCity;
                account.ShippingCountry = account.BillingCountry;
                account.ShippingStreet = account.BillingStreet;
                account.ShippingPostalCode = account.BillingPostalCode;
                account.ShippingState = account.BillingState;
            }
        }
    }

    private static void populateRatingInAccount(List<Account> accounts, Map<Id,Account> oldMap) {
        for(Account account : accounts) {
            if(account.Industry != Null && account.Industry == 'Media') {
                account.Rating = 'Hot';
            }
        }
    }

    private static void populatePhoneNumberAccountContact(List<Account> accounts, Map<Id, Account> oldMap) {
        Map<Id, Account> idsAccountMap = new Map<Id, Account>();
        for(Account account : accounts) {
            idsAccountMap.put(account.Id, account);
        }
        List<Contact> conList = new List<Contact>();
        for(Contact contact : [SELECT Id, AccountId FROM Contact WHERE AccountID IN :
                                idsAccountMap.keySet()
                              ]) {
            contact.HomePhone = idsAccountMap.get(Contact.AccountId).Phone;
            conList.add(contact);
        }
    
        if(!conList.isEmpty()) {
            update conList;
        }
    }

    private static void populatePhoneNumberAccountContactWithSOQL(List<Account> accounts, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        for(Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        for(Account account : [SELECT ID, Name, Phone, (SELECT ID, NAME FROM Contacts) FROM Account WHERE Id IN : accountIds]) {
            for(Contact contact : account.Contacts) {
            contact.HomePhone = account.Phone;// idsAccountMap.get(Contact.AccountId).Phone;
            conList.add(contact);
            }
        }
        if(!conList.isEmpty()) {
            update conList;
        }
    }

    private static void updateContactMailingAddress(List<Account> accounts, Map<Id, Account> oldMap) {
        Map<Id, Account> idsAccountMap = new Map<Id, Account>();
        for(Account account : accounts) {
            idsAccountMap.put(account.Id, account);
        }
        List<Contact> conList = new List<Contact>();
        for(Contact contact : [SELECT Id, AccountId FROM Contact WHERE AccountID IN :
                                idsAccountMap.keySet()
                              ]) {
            contact.MailingStreet = idsAccountMap.get(Contact.AccountId).BillingStreet;
            contact.MailingCity = idsAccountMap.get(Contact.AccountId).BillingCity;
            contact.MailingState = idsAccountMap.get(Contact.AccountId).BillingState;
            contact.MailingPostalCode = idsAccountMap.get(Contact.AccountId).BillingPostalCode;
            contact.MailingCountry = idsAccountMap.get(Contact.AccountId).BillingCountry;
            conList.add(contact);
        }
    
        if(!conList.isEmpty()) {
            update conList;
        }
    }

    private static void updateContactMailingAddressWithSOQL(List<Account> accounts, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        for(Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        for(Account account : [SELECT ID, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                              (SELECT ID, NAME FROM Contacts) FROM Account WHERE Id IN : accountIds]) {
            for(Contact contact : account.Contacts) {
                contact.MailingStreet = account.BillingStreet;
                contact.MailingCity = account.BillingCity;
                contact.MailingState = account.BillingState;
                contact.MailingPostalCode = account.BillingPostalCode;
                contact.MailingCountry = account.BillingCountry;
                conList.add(contact);
            }
        }
        if(!conList.isEmpty()) {
            update conList;
        }
    }

    private static void updateAllOpportunityStage(List<Account> accounts, Map<Id, Account> oldMap) {
        //Map<Id, Account> idAccountMap = new Map<Id, Account>();
        Set<Id> accountsIds = new Set<Id>();
        for(Account account : accounts) {
            if(account.Active__c == 'No' && account.Active__c != oldMap.get(account.Id).Active__c) {
                accountsIds.add(account.Id);
            }
           // idAccountMap.add(account.Id, account);
        }
        List<Opportunity> opportunity = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id, Name, StageName, AccountId FROM Opportunity WHERE AccountId IN : accountsIds]) {
            if(opp.StageName != 'closed won') {
                opp.StageName = 'closed lost';
                opportunity.add(opp);
            }
        }
        if(!opportunity.isEmpty()) {
            update opportunity;
        }
    } 

    private static void preventdeleteAnAccount(List<Account> oldList) {
        for(Account account : oldList) {
            if(account.Active__c == 'Yes') {
                account.addError('Active acount can not be deleted');
            }
        }
    }

    private static void preventAccountRecordFromEdited(List<Account> newList, Map<Id, Account> oldMap) {
        for(Account account : newList) {
            if(Account.CreatedDate < System.today() - 7) {
                account.addError(' Account record cannot be edited because created date 7 days back.');
            }
        }
    }

    private static void checkOnlySystemAdministratorProfileUsers(List<Account> oldList) {
        System.debug('old>'+oldList);
        Id userProfileId = userinfo.getProfileId();
        System.debug('userProfileName'+userProfileId);
        String userProfileName = [SELECT ID, Name from Profile Where Id = : userProfileId].Name;
        Profile user1 = [SELECT ID, Name from Profile Where Id = : userProfileId];
        System.debug('userProfileName'+userProfileName);
        System.debug(user1.Id);
        for(Account account : oldList) {
            if(userProfileName != 'System Administrator') {
                account.addError('You cannot delete System Administrator');
            }
        }
    }

    private static void preventDeletionAccountRelatedToOpportunity(List<Account> accounts) {
        System.debug('accouts'+accounts);
        Set<Id> accountIds = new Set<Id>();
        for(Account account : accounts) {
            accountIds.add(account.Id);
        }
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity opp : [SELECT ID, Name, AccountId FROM Opportunity WHERE AccountId IN : accountIds]) {
            opportunityIds.add(opp.AccountId);
        }

        for(Account account : accounts) {
            if(opportunityIds.contains(account.Id)) {
            Account.addError('You cannot delete this account because this is related to opportunity');
            }
        }
    }

    private static void preventDeletionAccountRelatedToCase(List<Account> accounts) {
        System.debug('accouts'+accounts);
        Set<Id> accountIds = new Set<Id>();
        for(Account account : accounts) {
            accountIds.add(account.Id);
        }
        Set<Id> caseIds = new Set<Id>();
        for(Case caseRec : [SELECT ID, AccountId FROM Case WHERE AccountId IN : accountIds]) {
            caseIds.add(caseRec.AccountId);
        }

        for(Account account : accounts) {
            if(caseIds.contains(account.Id)) {
                Account.addError('You cannot delete this account because this is related to Case');
            }
            
        }
    }

    private static void setOWDForAccount(List<Account> accounts) {
        Id ProfileId = userinfo.getProfileId();
        Profile PName = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'];
        Group group1 = [SELECT Id, Name, DeveloperName FROM Group WHERE Name = 'Standard Users'];
        List<AccountShare> accountShareList = new List<AccountShare>();
        for(Account account : accounts) {
            for(User user :[SELECT Id, Name FROM User WHERE ProfileId =: PName.Id]) {
                AccountShare accShare = new AccountShare();
                accShare.AccountAccessLevel = 'Edit';
                accShare.CaseAccessLevel = 'Edit';
                accShare.AccountId = account.Id;
                accShare.OpportunityAccessLevel = 'Edit';
                accShare.UserOrGroupId = group1.Id;
                accountShareList.add(accShare);
            }
        }
        if(!accountShareList.isEmpty()) {
            insert accountShareList;
        }
    }
}