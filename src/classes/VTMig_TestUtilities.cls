/**
 * Created by triciaigoe on 2019-12-24.
 */
@IsTest
public without sharing class VTMig_TestUtilities {

    public static Account createKVCustomer(){
        Id customerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Customers').getRecordTypeId();
        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        newAccount.BillingCountry = 'United Kingdom';
        newAccount.BillingStreet = '123 Test Lane';
        newAccount.BillingCity = 'Some City';
        newAccount.RecordTypeId = customerRecordType;
        return newAccount;
    }

    public static Account createKVProspect(){
        Id prospectRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Prospect').getRecordTypeId();
        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        newAccount.BillingCountry = 'United Kingdom';
        newAccount.BillingStreet = '123 Test Lane';
        newAccount.BillingCity = 'Some City';
        newAccount.RecordTypeId = prospectRecordType;
        return newAccount;
    }

    public static Account createKVPartner(){
        Id partnerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Partner').getRecordTypeId();
        Account newPartner = new Account();
        newPartner.Name = 'New Partner';
        newPartner.RecordTypeId = partnerRecordType;
        return newPartner;
    }

    public static Contact createContact(Id accountId){
        Contact newContact = new Contact();
        newContact.AccountId = accountId;
        newContact.LastName = 'Test';
        newContact.FirstName = 'Test';
        return newContact;
    }

    public static Opportunity createOpportunity(Id accountId){
        Opportunity newOpp = new Opportunity();
        newOpp.Name = 'New Opportunity';
        newOpp.CloseDate = System.today();
        newOpp.StageName = 'Qualification';
        newOpp.AccountId = accountId;
        return newOpp;
    }

    public static Job__c createMasterOrder(Id accountId){
        Id masterRecordType = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Master Order').getRecordTypeId();
        Job__c newOrder = new Job__c();
        newOrder.Account__c = accountId;
        newOrder.Name = 'New Order';
        return newOrder;
    }

    public static Product__c createProduct(){
        Product__c newProduct = new Product__c();
        newProduct.Name = 'New Product';
        newProduct.Valid_From_Date__c = System.today();
        return newProduct;
    }

    public static Product2 createStandardProduct(){
        Product2 newProduct = new Product2();
        newProduct.Name = 'New Product';
        return newProduct;
    }

    public static Product_Rate_Plan__c createRatePlan(Id productId){
        Product_Rate_Plan__c newProductRatePlan = new Product_Rate_Plan__c();
        newProductRatePlan.Name = 'New Product Rate Plan';
        newProductRatePlan.Valid_From_Date__c = System.today();
        newProductRatePlan.Product__c = productId;
        return newProductRatePlan;
    }

    public static Product_Rate_Plan_Charge__c createProductCharge(Id ratePlanId){
        Product_Rate_Plan_Charge__c newProductRatePlanCharge = new Product_Rate_Plan_Charge__c();
        newProductRatePlanCharge.Name = 'New Product Rate Plan Charge';
        newProductRatePlanCharge.Product_Rate_Plan__c = ratePlanId;
        newProductRatePlanCharge.Unit_Price__c = 100;
        return newProductRatePlanCharge;
    }

    public static Job_Product__c createOrderProduct(Id orderId, Id productId){
        Job_Product__c orderProduct = new Job_Product__c();
        orderProduct.Job__c = orderId;
        orderProduct.Product__c = productId;
        return orderProduct;
    }

    public static Job_Rate_Plan__c createOrderRatePlan(Id productRatePlanId, Id orderProductId) {
        Job_Rate_Plan__c orderRatePlan = new Job_Rate_Plan__c();
        orderRatePlan.Product_Rate_Plan__c = productRatePlanId;
        orderRatePlan.Job_Product__c = orderProductId;
        return orderRatePlan;
    }

    public static Job_Rate_Plan_Charge__c createORPC(Id orderId, Id prodChargeId, Id ratePlanId){
        Job_Rate_Plan_Charge__c orderRatePlanCharge = new Job_Rate_Plan_Charge__c();
        orderRatePlanCharge.Job_Rate_Plan__c = ratePlanId;
        orderRatePlanCharge.Quantity__c = 1;
        orderRatePlanCharge.Order__c = orderId;
        orderRatePlanCharge.Product_Rate_Plan_Charge__c = prodChargeId;
        orderRatePlanCharge.Unit_Price__c = 100;
        orderRatePlanCharge.Name = 'New Opp Rate Plan Charge';
        orderRatePlanCharge.Price__c = 100;
        orderRatePlanCharge.Discount_Value__c = 0;
        orderRatePlanCharge.Discount_Percent__c = 0;
        return orderRatePlanCharge;
    }

    public static Opportunity_Product__c createOpportunityProduct(Id productId, Id opportunityId) {
        Opportunity_Product__c opportunityProduct = new Opportunity_Product__c();
        opportunityProduct.Opportunity__c = opportunityId;
        opportunityProduct.Product__c = productId;
        return opportunityProduct;
    }

    public static Opportunity_Rate_Plan__c createOpportunityRatePlan(Id prodRatePlanId, Id oppProductId) {
        Opportunity_Rate_Plan__c opportunityRatePlan = new Opportunity_Rate_Plan__c();
        opportunityRatePlan.Product_Rate_Plan__c = prodRatePlanId;
        opportunityRatePlan.Opportunity_Product__c = oppProductId;
        return opportunityRatePlan;
    }

    public static Opportunity_Rate_Plan_Charge__c createOpportunityRatePlanCharge(Id oppRatePlanId, Id opportunityId, Id prodChargeId){
        Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = new Opportunity_Rate_Plan_Charge__c();
        oppRatePlanCharge.Opportunity_Rate_Plan__c = oppRatePlanId;
        oppRatePlanCharge.Quantity__c = 1;
        oppRatePlanCharge.Opportunity__c = opportunityId;
        oppRatePlanCharge.Product_Rate_Plan_Charge__c = prodChargeId;
        oppRatePlanCharge.Unit_Price__c = 100;
        oppRatePlanCharge.Name = 'New Opp Rate Plan Charge';
        oppRatePlanCharge.Price__c = 100;
        oppRatePlanCharge.Discount_Value__c = 0;
        oppRatePlanCharge.Discount_Percent__c = 0;
        return oppRatePlanCharge;
    }
}