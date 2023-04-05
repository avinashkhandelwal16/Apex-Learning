public class OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity> Opportunities) {
        //updateOpportunityDescription(Opportunities, null);
    }

    public static void afterInsert(List<Opportunity> newOpportunity) {
        setLatestOpportunityAmount(newOpportunity);
        updateAnnualRevenueFieldOnAccount(newOpportunity, null);
    }

    public static void beforeUpdate(List<Opportunity> Opportunities, Map<Id, Opportunity> oldMap) {
        //updateOpportunityDescription(Opportunities, oldMap);
        populateClosedLostReasonOnOpportunity(Opportunities, oldMap);
        updateOpportunityStageAndDescription(Opportunities, oldMap);
    }
    public static void afterUpdate(List<Opportunity> Opportunities, Map<Id, Opportunity> oldMap) {
        createTaskOnOpportunityStageChange(Opportunities, oldMap);
        updateAnnualRevenueFieldOnAccount(Opportunities, oldMap);
    }

    public static void beforeDelete(List<Opportunity> Opportunities) {
        deleteOnlySystemAdministratorProfileOpportunity(Opportunities);
    }

    public static void afterDelete(List<Opportunity> Opportunities) {
        updateAnnualRevenueFieldOnAccount(Opportunities, NULL);
    }
    
    private static void setLatestOpportunityAmount(List<Opportunity> newOpportunity) {
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opportunity : newOpportunity) {
            accountIds.add(opportunity.AccountId);
        }
        List<Account> updatedAccountList = new List<Account>();
        for(Account account : [SELECT Id, Recent_Opportunity_Amount__c, 
                               (SELECT Id, Amount FROM Opportunities ORDER BY CreatedDate DESC LIMIT 1) 
                               FROM Account WHERE Id IN : accountIds]) {
                                   if(account.Opportunities != null && account.Opportunities.Size() > 0) {
                                       Account acc = new Account(Id = account.Id, 
                                                                Recent_Opportunity_Amount__c = account.Opportunities.get(0)?.Amount
                                                                );
                                      updatedAccountList.add(acc); 
                                   }                          
                               }  
        if(!updatedAccountList.isEmpty()) {
            update updatedAccountList;
        }
    	}

    private static void updateOpportunityDescription(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        for(Opportunity opportunity : opportunities) {   
            if(opportunity.StageName != null) {
                opportunity.Description = opportunity.StageName;
            }
            if(oldMap != NULL && opportunity.StageName != oldMap.get(opportunity.Id).StageName) {
                opportunity.Description = opportunity.StageName;
            }       
        }
    }

    private static void createTaskOnOpportunityStageChange(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        List<Task> tasks = new List<Task>();
        for(Opportunity opportunity : opportunities) {
            if(opportunity.StageName != oldMap.get(opportunity.Id).StageName) {
                Task task = new Task();
                task.WhatId = opportunity.Id;
                task.Subject = opportunity.StageName; 
                tasks.add(task);
            }
        }
        if(!tasks.isEmpty()) {
            insert tasks;
        }
    }

    private static void populateClosedLostReasonOnOpportunity(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        for(Opportunity opportunity : opportunities) {
            if(opportunity.StageName == 'Closed Lost' && Opportunity.StageName != oldMap.get(opportunity.Id).StageName) {
                opportunity.Closed_Lost_Reason__c = 'Please populate Closed Lost Reason';
            }
        }
    }

    private static void deleteOnlySystemAdministratorProfileOpportunity(List<Opportunity> opportunities) {
        Id userProfileId = UserInfo.getProfileId();
        String userProfileName = [SELECT Id, Name FROM Profile WHERE ID = : userProfileId].Name;
        for(Opportunity opportunity : opportunities) {
            if(opportunity.StageName == 'closed won' && userProfileName == 'System Administrator') {
                opportunity.addError('You cannot delete this opportunity');
            }
        }
    }

    private static void updateAnnualRevenueFieldOnAccount(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opportunity : newList) {
            oppIds.add(opportunity.AccountId);
        }
        List<Account> accounts = new List<Account>();
        for(Account account : [SELECT Id, Name, AnnualRevenue, (SELECT Id, NAME, Amount FROM Opportunities) FROM Account WHERE Id IN :oppIds]) {
            account.AnnualRevenue = 0;
            for(Opportunity opportunity : account.opportunities) {
                    account.AnnualRevenue += opportunity.Amount;
            }
            accounts.add(account);
        }
        if(!accounts.isEmpty()) {
            update accounts;
        }  
    }  

    private static void updateOpportunityStageAndDescription(List<Opportunity> oldList, Map<Id, Opportunity> oldMap) {
        for(Opportunity opportunity : oldList) {
            if(oldMap != Null && opportunity.StageName != oldMap.get(opportunity.Id).StageName) {
                opportunity.Description = 'Opportunity is '+ opportunity.StageName;
            }
        }
    }
    }