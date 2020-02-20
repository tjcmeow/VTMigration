/**
 * Created by triciaigoe on 2019-12-31.
 */

public without sharing class VTMig_AccountTriggerHelper {

    public static void beforeDeleteProspect(Map<Id, Account> theAccounts) {

        Id prospectRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Prospect').getRecordTypeId();

        List<Id> prospectIds = new List<Id>();
        for(Account theAccount : theAccounts.values()) {
            if(theAccount.RecordTypeId == prospectRecordType) {
                prospectIds.add(theAccount.Id);
            }
        }

        if(prospectIds.size() > 0) {
            Id masterRecordType = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Master Order').getRecordTypeId();
            List<Opportunity> opportunities = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN : prospectIds];
            List<Job__c> orders = [SELECT Id, Account__c FROM Job__c WHERE Account__c IN : prospectIds AND RecordTypeId = : masterRecordType];
            List<Id> oppAccountIds = new List<Id>();
            List<Id> orderAccountIds = new List<Id>();
            for(Opportunity opp: opportunities) {
                oppAccountIds.add(opp.AccountId);
            }

            for(Job__c singleOrder : orders) {
                orderAccountIds.add(singleOrder.Account__c);
            }

            for(Account theAccount : theAccounts.values()) {
                if(oppAccountIds.contains(theAccount.Id)) {
                    theAccount.addError('Prospect accounts with opportunities cannot be deleted.');
                } else if(orderAccountIds.contains(theAccount.Id)) {
                    theAccount.addError('Prospect accounts with master orders cannot be deleted.');
                }
            }
        }

    }

    public static void beforeUpdateInsert(List<Account> newAccounts) {

        Map<String, String> labelValue = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Account.Reporting_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            labelValue.put(pickListVal.getValue(), pickListVal.getLabel());
        }

        for(Account newAccount : newAccounts) {
            newAccount.BillingCountry = labelValue.get(newAccount.Reporting_Country__c);
            newAccount.BillingState = newAccount.New_Main_State_County__c;
            newAccount.BillingCity = newAccount.New_Main_City_Town__c;
            newAccount.BillingPostalCode = newAccount.New_Main_Postcode__c;
            newAccount.BillingStreet = newAccount.New_Main_Street__c;
        }

    }

}