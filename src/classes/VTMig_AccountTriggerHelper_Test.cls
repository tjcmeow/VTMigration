/**
 * Created by triciaigoe on 2020-01-01.
 */
@IsTest
public without sharing class VTMig_AccountTriggerHelper_Test {

    @TestSetup
    public static void setupData(){

        Account newAccount = VTMig_TestUtilities.createKVProspect();
        insert newAccount;

        Opportunity newOpportunity = VTMig_TestUtilities.createOpportunity(newAccount.Id);
        insert newOpportunity;
    }

    @IsTest
    public static void testDelete(){

        Account theAccount = [SELECT Id FROM Account];
        Boolean deleted = true;
        try{
            delete theAccount;
        } catch (Exception e) {
            deleted = false;
        }

        System.assertEquals(deleted, false, 'Account was deleted');
    }

}