/**
 * Created by triciaigoe on 2019-11-15.
 */
@IsTest
public with sharing class VTMig_CloneOrder_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        insert newAccount;

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


        Job__c newOrder = new Job__c();
        newOrder.Account__c = newAccount.Id;
        newOrder.RecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Master Order').getRecordTypeId();
        newOrder.Name = 'New Order';
        insert newOrder;

        Job_Product__c newJobProduct = new Job_Product__c();
        newJobProduct.Name = newProduct.Name;
        newJobProduct.Job__c = newOrder.Id;
        insert newJobProduct;

        Job_Rate_Plan__c newJobPlan = new Job_Rate_Plan__c();
        newJobPlan.Name = newProductRatePlan.Name;
        newJobPlan.Job_Product__c = newJobProduct.Id;
        newJobPlan.Product_Rate_Plan__c = newProductRatePlan.Id;
        insert newJobPlan;

        Job_Rate_Plan_Charge__c newCharge = new Job_Rate_Plan_Charge__c();
        newCharge.Product_Rate_Plan_Charge__c = newProductRatePlanCharge.Id;
        newCharge.Order__c = newOrder.Id;
        newCharge.Name = newProductRatePlanCharge.Name;
        newCharge.Job_Rate_Plan__c = newJobPlan.Id;
        newCharge.Quantity__c = 1;
        newCharge.Unit_Price__c = newProductRatePlanCharge.Unit_Price__c;
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