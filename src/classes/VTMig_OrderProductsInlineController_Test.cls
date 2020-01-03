/**
 * Created by triciaigoe on 2019-11-15.
 */
@IsTest
public with sharing class VTMig_OrderProductsInlineController_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = VTMig_TestUtilities.createKVCustomer();
        insert newAccount;

        Job__c newOrder = VTMig_TestUtilities.createMasterOrder(newAccount.Id);
        insert newOrder;

        Product__c newProduct = VTMig_TestUtilities.createProduct();
        insert newProduct;

        Product_Rate_Plan__c newProductRatePlan = VTMig_TestUtilities.createRatePlan(newProduct.Id);
        insert newProductRatePlan;

        Product_Rate_Plan_Charge__c newProductRatePlanCharge = VTMig_TestUtilities.createProductCharge(newProductRatePlan.Id);
        insert newProductRatePlanCharge;

        Job_Product__c orderProduct = VTMig_TestUtilities.createOrderProduct(newOrder.Id, newProduct.Id);
        insert orderProduct;

        Job_Rate_Plan__c orderRatePlan = VTMig_TestUtilities.createOrderRatePlan(newProductRatePlan.Id, orderProduct.Id);
        insert orderRatePlan;

        Job_Rate_Plan_Charge__c orderRatePlanCharge = VTMig_TestUtilities.createORPC(newOrder.Id, newProductRatePlanCharge.Id, orderRatePlan.Id);
        insert orderRatePlanCharge;

    }

    @IsTest
    static void testInlineOpp(){

        Test.startTest();

        Job__c newOrder = [SELECT Id FROM Job__c];
        PageReference pageRef = Page.VTMig_OppInlineProducts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOrder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_OrderProductsInlineController controller = new VTMig_OrderProductsInlineController(sc);

        System.assertEquals(controller.charges.size(), 1);

        Test.stopTest();
    }

}