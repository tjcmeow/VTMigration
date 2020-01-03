/**
 * Created by triciaigoe on 2019-11-20.
 */
@IsTest
public with sharing class VTMig_UpdateOrderStatus_Test {

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

        Job_Rate_Plan_Charge__c theCharge = VTMig_TestUtilities.createORPC(newOrder.Id, newProductRatePlanCharge.Id, orderRatePlan.Id);
        theCharge.Discount_Value__c = null;
        insert theCharge;

    }

    @IsTest
    static void testSaveOrder(){ 

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