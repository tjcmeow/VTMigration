/**
 * Created by triciaigoe on 2019-11-13.
 */

@IsTest
public with sharing class VTMig_ProductSelection_Extension_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = VTMig_TestUtilities.createKVCustomer();
        insert newAccount;

        Opportunity newOpp = VTMig_TestUtilities.createOpportunity(newAccount.Id);
        insert newOpp;

        Product__c newProduct = VTMig_TestUtilities.createProduct();
        insert newProduct;

        Product_Rate_Plan__c newProductRatePlan = VTMig_TestUtilities.createRatePlan(newProduct.Id);
        insert newProductRatePlan;

        Product_Rate_Plan_Charge__c newProductRatePlanCharge = VTMig_TestUtilities.createProductCharge(newProductRatePlan.Id);
        insert newProductRatePlanCharge;

        Opportunity_Product__c opportunityProduct = VTMig_TestUtilities.createOpportunityProduct(newProduct.Id, newOpp.Id);
        insert opportunityProduct;

        Opportunity_Rate_Plan__c opportunityRatePlan = VTMig_TestUtilities.createOpportunityRatePlan(newProductRatePlan.Id, opportunityProduct.Id);
        insert opportunityRatePlan;
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

        Opportunity_Rate_Plan__c oppRatePlan = [SELECT Id FROM Opportunity_Rate_Plan__c];

        Product_Rate_Plan_Charge__c productRatePlanCharge = [SELECT Id FROM Product_Rate_Plan_Charge__c];

        Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = VTMig_TestUtilities.createOpportunityRatePlanCharge(oppRatePlan.Id, newOpp.Id, productRatePlanCharge.Id);
        insert oppRatePlanCharge;

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

        controller.removeChargeId = 0;
        controller.removeCharge();
        controller.removeCharges();

        PageReference pageRef2 = controller.saveProducts();

        Test.stopTest();

    }


}