/**
 * Created by triciaigoe on 2019-11-13.
 */

@IsTest
public with sharing class VTMig_ProductSelection_Extension_Test {

    @TestSetup
    static void setUpData(){

        Opportunity newOpp = new Opportunity();
        newOpp.Name = 'New Opportunity';
        newOpp.CloseDate = System.today();
        newOpp.StageName = 'Qualification';
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

        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        insert newAccount;

        Job__c newOrder = new Job__c();
        newOrder.Account__c = newAccount.Id;
        newOrder.Opportunity__c = newOpp.Id;
        newOrder.Name = 'New Order';

    }

    @IsTest
    static void testOpenList(){

        Test.startTest();

        Opportunity newOpp = [SELECT Id FROM Opportunity];
        PageReference pageRef = Page.VTMig_ProductSelection;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOpp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOpp);
        VTMig_ProductSelection_Extension controller = new VTMig_ProductSelection_Extension(sc);

        controller.openList();
        controller.step1();
        System.assertEquals(controller.showProducts, true);

        Test.stopTest();
    }

    @IsTest
    static void testSelectPlanAndCharge(){

        Opportunity newOpp = [SELECT Id FROM Opportunity];

        Opportunity_Rate_Plan__c opportunityRatePlan = [SELECT Id FROM Opportunity_Rate_Plan__c];

        Product_Rate_Plan_Charge__c productRatePlanCharge = [SELECT Id FROM Product_Rate_Plan_Charge__c];

        Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge = new Opportunity_Rate_Plan_Charge__c();
        opportunityRatePlanCharge.Opportunity__c = newOpp.Id;
        opportunityRatePlanCharge.Quantity__c = 1;
        opportunityRatePlanCharge.Opportunity_Rate_Plan__c = opportunityRatePlan.Id;
        opportunityRatePlanCharge.Product_Rate_Plan_Charge__c = productRatePlanCharge.Id;
        opportunityRatePlanCharge.Unit_Price__c = 100;
        opportunityRatePlanCharge.Name = 'New Opp Rate Plan Charge';
        opportunityRatePlanCharge.Price__c = 100;
        insert opportunityRatePlanCharge;

        Test.startTest();

        PageReference pageRef = Page.VTMig_ProductSelection;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOpp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOpp);
        VTMig_ProductSelection_Extension controller = new VTMig_ProductSelection_Extension(sc);

        controller.openList();
        controller.step1();
        System.assertEquals(controller.showProducts, true);

        Product__c newProduct = [SELECT Id FROM Product__c];
        controller.selectedProductId = newProduct.Id;
        controller.selectProduct();

        Product_Rate_Plan__c productRatePlan = [SELECT Id FROM Product_Rate_Plan__c];

        controller.selectedPlanId = productRatePlan.Id;
        controller.selectPlan();
        System.assertEquals(controller.showCharges, true);

        controller.selectedChargeId = productRatePlanCharge.Id;
        for (VTMig_ProductSelection_Extension.ProdCharge prodCharge : controller.prodCharges) {
            prodCharge.quantity = 1;
        }
        controller.selectCharge();
        System.assertEquals(controller.showChosenCharges, true);

        controller.step2();
        System.assertEquals(controller.pageStep, '2');


        Decimal total = controller.grandTotal;
        controller.overallDiscount = 10;
        controller.recalculate();
        System.assertNotEquals(controller.grandTotal, total);

        controller.removeCharge();

        PageReference pageRef2 = controller.saveProducts();

        Test.stopTest();

    }


}