/**
 * Created by triciaigoe on 1/20/20.
 */
@IsTest
public with sharing class VTMig_CreateNewAssetControllerTest {

    @IsTest
    static void testMaster(){

        Test.startTest();

        Job__c newOrder = [SELECT Id FROM Job__c];
        PageReference pageRef = Page.VTMig_CreateNewAsset;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOrder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_CloneOrder controller = new VTMig_CloneOrder(sc);
        controller.isMasterOrder = true;

        PageReference pageRef2 = controller.createCloneOrder();
        List<Job__c> newOrders = [SELECT Id FROM Job__c];
        System.assertEquals(newOrders.size(), 2);

        Test.stopTest();
    }

}