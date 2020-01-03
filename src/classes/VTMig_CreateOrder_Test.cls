/**
 * Created by triciaigoe on 2019-11-19.
 */
@IsTest
public with sharing class VTMig_CreateOrder_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = VTMig_TestUtilities.createKVCustomer();
        insert newAccount;

        Account newPartner = VTMig_TestUtilities.createKVPartner();
        insert newPartner;

        Contact newContact = VTMig_TestUtilities.createContact(newAccount.Id);
        insert newContact;

        Opportunity newOpp = VTMig_TestUtilities.createOpportunity(newAccount.Id);
        insert newOpp;

        Currency__c curr = new Currency__c();
        curr.Currency_Name__c = 'USD';
        curr.Currency_Symbol__c = '$';
        insert curr;

        Opportunity newOpp2 = new Opportunity();
        newOpp2.Name = 'New Opportunity2';
        newOpp2.CloseDate = System.today();
        newOpp2.StageName = 'Qualification';
        newOpp2.AccountId = newAccount.Id;
        newOpp2.Billing_Contact__c = newContact.Id;
        newOpp2.Partner_Agent_Account__c = newPartner.Id;
        newOpp2.Legal_Entity__c = 'VMI';
        newOpp2.CurrencyL__c = curr.Id;
        insert newOpp2;

        Product__c newProduct = VTMig_TestUtilities.createProduct();
        insert newProduct;

        Product_Rate_Plan__c newProductRatePlan = VTMig_TestUtilities.createRatePlan(newProduct.Id);
        insert newProductRatePlan;

        Product_Rate_Plan_Charge__c newProductRatePlanCharge = VTMig_TestUtilities.createProductCharge(newProductRatePlan.Id);
        insert newProductRatePlanCharge;

        Opportunity_Product__c opportunityProduct = new Opportunity_Product__c();
        opportunityProduct.Opportunity__c = newOpp2.Id;
        opportunityProduct.Product__c = newProduct.Id;
        insert opportunityProduct;

        Opportunity_Rate_Plan__c opportunityRatePlan = new Opportunity_Rate_Plan__c();
        opportunityRatePlan.Product_Rate_Plan__c = newProductRatePlan.Id;
        opportunityRatePlan.Opportunity_Product__c = opportunityProduct.Id;
        insert opportunityRatePlan;

        Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge = new Opportunity_Rate_Plan_Charge__c();
        opportunityRatePlanCharge.Opportunity__c = newOpp2.Id;
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

        Opportunity newOpp = [SELECT Id FROM Opportunity WHERE Name = 'New Opportunity2'];
        Account newAcc = [SELECT Id FROM Account WHERE Name = 'New Account'];
        newOpp.AccountId = newAcc.Id;
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

        Opportunity newOpp = [SELECT Id FROM Opportunity WHERE Name = 'New Opportunity'];

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