/**
 * Created by triciaigoe on 2019-11-20.
 */
@IsTest
public with sharing class VTMig_UpdateOrderStatus_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        insert newAccount;

        Job__c newOrder = new Job__c();
        newOrder.Account__c = newAccount.Id;
        newOrder.Name = 'New Order';
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

    }

    @IsTest
    static void testOpenList(){

        Job__c theOrder = [SELECT Id FROM Job__c];

        Test.startTest();

        PageReference pageRef = Page.VTMig_UpdateOrderStatus;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',theOrder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(theOrder);
        VTMig_UpdateOrderStatus controller = new VTMig_UpdateOrderStatus(sc);

        controller.order.Despatch_Date__c = System.today();
        controller.saveOrder();

        Job__c theUpdatedOrder = [SELECT Id, Despatch_Date__c FROM Job__c];
        System.assertEquals(theUpdatedOrder.Despatch_Date__c, System.today());

        Test.stopTest();
    }

}