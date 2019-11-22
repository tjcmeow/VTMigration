/**
 * Created by triciaigoe on 2019-11-19.
 */
@IsTest
public with sharing class VTMig_CreateOrder_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        insert newAccount;

        Opportunity newOpp = new Opportunity();
        newOpp.Name = 'New Opportunity';
        newOpp.CloseDate = System.today();
        newOpp.StageName = 'Qualification';
        newOpp.AccountId = newAccount.Id;
        insert newOpp;

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

        Opportunity_Product__c opportunityProduct = new Opportunity_Product__c();
        opportunityProduct.Opportunity__c = newOpp.Id;
        opportunityProduct.Product__c = newProduct.Id;
        insert opportunityProduct;

        Opportunity_Rate_Plan__c opportunityRatePlan = new Opportunity_Rate_Plan__c();
        opportunityRatePlan.Product_Rate_Plan__c = newProductRatePlan.Id;
        opportunityRatePlan.Opportunity_Product__c = opportunityProduct.Id;
        insert opportunityRatePlan;

        Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge = new Opportunity_Rate_Plan_Charge__c();
        opportunityRatePlanCharge.Opportunity__c = newOpp.Id;
        opportunityRatePlanCharge.Quantity__c = 1;
        opportunityRatePlanCharge.Opportunity_Rate_Plan__c = opportunityRatePlan.Id;
        opportunityRatePlanCharge.Product_Rate_Plan_Charge__c = newProductRatePlanCharge.Id;
        opportunityRatePlanCharge.Unit_Price__c = 100;
        opportunityRatePlanCharge.Name = 'New Opp Rate Plan Charge';
        opportunityRatePlanCharge.Price__c = 100;
        insert opportunityRatePlanCharge;

    }

    @IsTest
    static void testCreateOrder(){

        Opportunity newOpp = [SELECT Id FROM Opportunity];
        newOpp.StageName = 'Closed Won';
        update newOpp;

        Test.startTest();

        PageReference pageRef = Page.VTMig_ProductSelection;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOpp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOpp);
        VTMig_CreateOrder controller = new VTMig_CreateOrder(sc);

        PageReference pageRef2 = controller.createOrder();
        List<Job_Rate_Plan_Charge__c> charges = [SELECT Id FROM Job_Rate_Plan_Charge__c];
        System.assertEquals(charges.size(), 1);

        Test.stopTest();

    }

    @IsTest
    static void testError(){

        Opportunity newOpp = [SELECT Id FROM Opportunity];

        Test.startTest();

        PageReference pageRef = Page.VTMig_ProductSelection;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOpp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOpp);
        VTMig_CreateOrder controller = new VTMig_CreateOrder(sc);

        PageReference pageRef2 = controller.createOrder();
        List<Job_Rate_Plan_Charge__c> charges = [SELECT Id FROM Job_Rate_Plan_Charge__c];
        System.assertEquals(charges.size(), 0);

        Test.stopTest();

    }

}