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
            List<Opportunity> opportunities = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN : prospectIds];
            List<Id> accountIds = new List<Id>();
            for(Opportunity opp: opportunities) {
                accountIds.add(opp.AccountId);
            }

            for(Account theAccount : theAccounts.values()) {
                if(accountIds.contains(theAccount.Id)) {
                    theAccount.addError('Prospect accounts with opportunities cannot be deleted.');
                }
            }
        }

    }

}