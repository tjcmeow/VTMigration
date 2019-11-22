/**
 * Created by triciaigoe on 2019-11-15.
 */
@IsTest
public with sharing class VTMig_OrderProductsInlineController_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        insert newAccount;

        Job__c newOrder = new Job__c();
        newOrder.Name = 'New Opportunity';
        newOrder.Account__c = newAccount.Id;
        insert newOrder;

        Product__c newProduct = new Product__c();
        newProduct.Name = 'New Product';
        newProduct.Valid_From_Date__c = System.today();
        insert newProduct;

        Product_Rate_Plan__c newProductRatePlan = new Product_Rate_Plan__c();
        newProductRatePlan.Name = 'New Product Rate Plan';
        newProductRatePlan.Valid_From_Date__c = System.today();
        newProductRatePlan.Product__c = newProduct.Id;
        insert newProductRatePlan;

        Product_Rate_Plan_Charge__c newProductRatePlanCharge = new Product_Rate_Plan_Charge__c();
        newProductRatePlanCharge.Name = 'New Product Rate Plan Charge';
        newProductRatePlanCharge.Product_Rate_Plan__c = newProductRatePlan.Id;
        newProductRatePlanCharge.Unit_Price__c = 100;
        insert newProductRatePlanCharge;

        Job_Product__c orderProduct = new Job_Product__c();
        orderProduct.Job__c = newOrder.Id;
        orderProduct.Product__c = newProduct.Id;
        insert orderProduct;

        Job_Rate_Plan__c orderRatePlan = new Job_Rate_Plan__c();
        orderRatePlan.Product_Rate_Plan__c = newProductRatePlan.Id;
        orderRatePlan.Job_Product__c = orderProduct.Id;
        insert orderRatePlan;

        Job_Rate_Plan_Charge__c orderRatePlanCharge = new Job_Rate_Plan_Charge__c();
        orderRatePlanCharge.Order__c = newOrder.Id;
        orderRatePlanCharge.Quantity__c = 1;
        orderRatePlanCharge.Job_Rate_Plan__c = orderRatePlan.Id;
        orderRatePlanCharge.Product_Rate_Plan_Charge__c = newProductRatePlanCharge.Id;
        orderRatePlanCharge.Unit_Price__c = 100;
        orderRatePlanCharge.Name = 'New Opp Rate Plan Charge';
        orderRatePlanCharge.Price__c = 100;
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