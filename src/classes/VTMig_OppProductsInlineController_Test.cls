/**
 * Created by triciaigoe on 2019-11-15.
 */

@IsTest
public with sharing class VTMig_OppProductsInlineController_Test {


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

        Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge = VTMig_TestUtilities.createOpportunityRatePlanCharge(opportunityRatePlan.Id, newOpp.Id, newProductRatePlanCharge.Id);
        insert opportunityRatePlanCharge;

    }

    @IsTest
    static void testInlineOpp(){

        Test.startTest();

        Opportunity newOpp = [SELECT Id FROM Opportunity];
        PageReference pageRef = Page.VTMig_OppInlineProducts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOpp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOpp);
        VTMig_OppProductsInlineController controller = new VTMig_OppProductsInlineController(sc);

        System.assertEquals(controller.charges.size(), 1);

        Test.stopTest();
    }

}