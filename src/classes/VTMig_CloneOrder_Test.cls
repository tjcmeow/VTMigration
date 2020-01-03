/**
 * Created by triciaigoe on 2019-11-15.
 */
@IsTest
public with sharing class VTMig_CloneOrder_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = VTMig_TestUtilities.createKVCustomer();
        insert newAccount;

        Product__c newProduct = VTMig_TestUtilities.createProduct();
        insert newProduct;

        Product_Rate_Plan__c newProductRatePlan = VTMig_TestUtilities.createRatePlan(newProduct.Id);
        insert newProductRatePlan;

        Product_Rate_Plan_Charge__c newProductRatePlanCharge = VTMig_TestUtilities.createProductCharge(newProductRatePlan.Id);
        insert newProductRatePlanCharge;

        Job__c newOrder = VTMig_TestUtilities.createMasterOrder(newAccount.Id);
        insert newOrder;

        Job_Product__c newJobProduct = VTMig_TestUtilities.createOrderProduct(newOrder.Id, newProduct.Id);
        insert newJobProduct;

        Job_Rate_Plan__c newJobPlan = VTMig_TestUtilities.createOrderRatePlan(newProductRatePlan.Id, newJobProduct.Id);
        insert newJobPlan;

        Job_Rate_Plan_Charge__c newCharge = VTMig_TestUtilities.createORPC(newOrder.Id, newProductRatePlanCharge.Id, newJobPlan.Id);
        insert newCharge;

    }

    @IsTest
    static void testMaster(){

        Test.startTest();

        Job__c newOrder = [SELECT Id FROM Job__c];
        PageReference pageRef = Page.VTMig_CloneOrder;
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

    @IsTest
    static void testChild(){

        Test.startTest();

        Job__c newOrder = [SELECT Id FROM Job__c];
        PageReference pageRef = Page.VTMig_CloneOrder;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOrder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_CloneOrder controller = new VTMig_CloneOrder(sc);
        controller.isMasterOrder = false;
        controller.isChildOrder = true;
        controller.iCountOfChild = 2;

        PageReference pageRef2 = controller.createCloneOrder();
        List<Job__c> newOrders = [SELECT Id FROM Job__c];
        System.assertEquals(newOrders.size(), 3);

        Test.stopTest();
    }

    @IsTest
    static void testCancel(){

        Test.startTest();

        Job__c newOrder = [SELECT Id FROM Job__c];
        PageReference pageRef = Page.VTMig_CloneOrder;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOrder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_CloneOrder controller = new VTMig_CloneOrder(sc);

        PageReference pageRef2 = controller.cancel();
        System.assertNotEquals(pageRef2, null);

        Test.stopTest();
    }

}