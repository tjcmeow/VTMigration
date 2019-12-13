/**
 * Created by triciaigoe on 2019-11-27.
 */
@IsTest
public with sharing class VTMig_BatchUplift_Test {

    @TestSetup
    static void setupData(){

        //IITClassAfterOnOrderRatePlanCharges.ExecuteTrigger = false;
        //system.debug('Indide');

        //
        Revenue_Recognition_Rule__c rule = new Revenue_Recognition_Rule__c(Name = 'Full Recognition - On Invoice Date');
        insert rule;

        Id kvaccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Customers').getRecordTypeId();
        Id kvPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Partner').getRecordTypeId();
        Id kvPlatformRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Platform').getRecordTypeId();

        // don't change the billing country field as VAT will be calculated based on this
        Account acc = new Account(Name = 'Test Account', BillingCountry = 'United Kingdom', recordtypeID = kvaccountRecordTypeId);
        insert acc;

        Account acc2 = new Account(Name = 'Test Partner', BillingCountry = 'United Kingdom', recordtypeID = kvPartnerRecordTypeId);
        insert acc2;

        Account acc3 = new Account(Name = 'Test Platform', BillingCountry = 'United Kingdom', recordtypeID = kvPlatformRecordTypeId);
        insert acc3;

        Product__c invoiceItProduct = new Product__c(Valid_From_Date__c = system.today(), Name = 'VOD');
        insert invoiceItProduct;

        Product_Rate_Plan__c ratePlan = new Product_Rate_Plan__c(Name = 'Full......', Valid_From_Date__c = system.today());
        ratePlan.Product__c = invoiceItProduct.Id;
        insert ratePlan;

        Currency__c currency1 = new Currency__c(Name = 'EUR', Symbol__c = '£', Currency_Symbol__c = '£', Currency_Name__c = 'EUR');
        insert currency1;

        Product_Rate_Plan_Charge__c productCharge = new Product_Rate_Plan_Charge__c(Product_Rate_Plan__c = ratePlan.Id, Name = 'Annual Subscription Fee: Full', CurrencyL__c = currency1.Id);
        insert productCharge;

        Partner_Commission_Rates__c partnerCommissionRates = new Partner_Commission_Rates__c(Commission_Type__c = 'Rental', Standard_Comm__c = .1, Year1_Commission__c = .1, Product__c = invoiceItProduct.Id, Partner_Agent_Account__c = acc2.Id);
        insert partnerCommissionRates;

        // this will cover the IITClassAfterOnOrderRatePlanCharges
        Job__c job = new Job__c(Account__c = acc.id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
        job.Account__c = acc.Id;
        job.Shipping_Account__c = acc3.Id;
        job.IITIntended_Use__c = 'LOCAL UK WATERS';
        job.Withholding_Tax_Percentage__c = 10;
        job.BMS_Contract_Year__c = 2;
        job.Status__c = 'Ready for Fulfillment';
        job.Partner__c = acc2.Id;
        job.RecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Child Order').getRecordTypeId();
        insert job;

        Job_Product__c  jobProduct= new Job_Product__c(Product__c = invoiceItProduct.Id, Name = 'VOD',Job__c = job.Id);
        insert jobProduct;

        Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Product_Rate_Plan__c = ratePlan.Id, Name = 'JobRP',Job_Product__c =jobProduct.Id);
        insert jobRP;

        list<Job_Rate_Plan_Charge__c> charges = new list<Job_Rate_Plan_Charge__c>();
        Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Product_Rate_Plan_Charge__c = productCharge.Id);
        charge.Name = 'Charge1';
        charge.Order__c = job.Id;
        charge.Job_Rate_Plan__c =jobRP.Id;
        charge.Status__c = 'Ready to be Invoiced';
        charge.Quantity__c = 1;
        charge.Price_Type__c = 'Half Yearly';
        charge.Accounting_Code__c = '12345';
        charge.Charge_Date__c = system.today();
        charge.Unit_Price__c = 100;
        charge.Service_Activation_Date__c = System.today();
        charge.Service_End_Date__c = charge.Service_Activation_Date__c.addYears(4);
        charge.Uplift__c = 2;
        charge.Next_Uplift_Date__c = System.today();
        charge.VAT_Percentage__c = 0;
        charge.Tax_Percentage__c = 0;
        charge.Tax__c = 0;
        charge.VAT_Percentage__c = 0;
        charge.Discount_Value__c = 0;
        charge.Price__c = 0;
        charge.Net_Total__c = 0;
        charges.add(charge);

        charge = new Job_Rate_Plan_Charge__c(Product_Rate_Plan_Charge__c = productCharge.Id);
        charge.Name = 'Charge2';
        charge.Order__c = job.Id;
        charge.Job_Rate_Plan__c =jobRP.Id;
        charge.Status__c = 'Ready to be Invoiced';
        charge.Quantity__c = 1;
        charge.Price_Type__c = 'Half Yearly';
        charge.Accounting_Code__c = '12345';
        charge.Charge_Date__c = system.today();
        charge.Unit_Price__c = 100;
        charge.Service_Activation_Date__c = System.today();
        charge.Service_End_Date__c = charge.Service_Activation_Date__c.addYears(4);
        charge.Uplift__c = null;
        charge.Legacy_Orders__c = true;
        charge.AnnualRentYear2__c = 105;
        charge.Next_Uplift_Date__c = system.today();
        charge.VAT_Percentage__c = 0;
        charge.Tax_Percentage__c = 0;
        charge.Tax__c = 0;
        charge.VAT_Percentage__c = 0;
        charge.Discount_Value__c = 0;
        charge.Price__c = 0;
        charge.Net_Total__c = 0;
        charges.add(charge);

        charge = new Job_Rate_Plan_Charge__c(Product_Rate_Plan_Charge__c = productCharge.Id);
        charge.Name = 'Charge3';
        charge.Order__c = job.Id;
        charge.Job_Rate_Plan__c =jobRP.Id;
        charge.Status__c = 'Ready to be Invoiced';
        charge.Quantity__c = 1;
        charge.Price_Type__c = 'Half Yearly';
        charge.Accounting_Code__c = '12345';
        charge.Charge_Date__c = system.today();
        charge.Unit_Price__c = 100;
        charge.Service_Activation_Date__c = System.today();
        charge.Service_End_Date__c = charge.Service_Activation_Date__c.addYears(4);
        charge.Uplift__c = 0;
        charge.Legacy_Orders__c = true;
        charge.AnnualRentYear3__c = 105;
        charge.AnnualRentYear3__c = 110;
        charge.Next_Uplift_Date__c = system.today();
        charge.VAT_Percentage__c = 0;
        charge.Tax_Percentage__c = 0;
        charge.Tax__c = 0;
        charge.VAT_Percentage__c = 0;
        charge.BMS_Contract_Year__c = 3;
        charge.Discount_Value__c = 0;
        charge.Price__c = 0;
        charge.Net_Total__c = 0;

        charges.add(charge);

        insert charges;
        system.assert(charge.Next_Uplift_Date__c != null);

    }

    @isTest static void test_IITBatchUpliftPrice() {


        list<Job_Rate_Plan_Charge__c> charges = new list<Job_Rate_Plan_Charge__c>();
        Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c();
        Product_Rate_Plan_Charge__c productCharge = [SELECT Product_Rate_Plan__c, Name, CurrencyL__c FROM Product_Rate_Plan_Charge__c];
        test.startTest();

        Date dateToday = system.today();
        string query = 'SELECT AnnualRentYear2__c, AnnualRentYear3__c, AnnualRentYear4__c, Unit_Price_2nd_Year__c, Unit_Price_3rd_Year__c, Unit_Price_4th_Year__c, Quantity__c, Uplift__c, Uplift_Frequency__c, Price_Type__c,Order__c, Legacy_Orders__c, Next_Uplift_Date__c, Unit_Price__c, Order__r.BMS_Contract_Year__c FROM Job_Rate_Plan_Charge__c WHERE Product_Rate_Plan_Charge__c = \'' + productCharge.Id + '\' ';

        // This is to cover class IITBatchUpliftPrice
        VTMig_BatchUpliftPrice a = new VTMig_BatchUpliftPrice(query, false);
        database.executeBatch(a);

        charges = [SELECT Name, Unit_Price__c, Uplift_Frequency__c, Next_Uplift_Date__c FROM Job_Rate_Plan_Charge__c WHERE Product_Rate_Plan_Charge__c =: productCharge.Id];

        for(Job_Rate_Plan_Charge__c chargeLoop : charges) {
            system.debug('Unit_Price__c should be updated by the uplift price by ' + chargeLoop.Unit_Price__c);
            if(chargeLoop.Name == 'Charge1') {
                //system.assert(chargeLoop.Unit_Price__c == 102);
            } else if(chargeLoop.Name == 'Charge2') {
                //system.assert(chargeLoop.Unit_Price__c == 105);
            } else if(chargeLoop.Name == 'Charge3') {
                //system.assert(chargeLoop.Unit_Price__c == 110);
            }
        }

        charge = [SELECT Id, Uplift_Frequency__c, Next_Uplift_Date__c, Discount_Value__c FROM Job_Rate_Plan_Charge__c WHERE Id =: charges[0].Id];

        system.debug('Next_Uplift_Date__c should be populated by the system');
        //system.assert(charge.Next_Uplift_Date__c != null);

        /* code for Suspension_Period__c period.
        Suspension_Period__c sp = new Suspension_Period__c();
        sp.Suspension_Start_Date__c = system.today();
        sp.Suspension_End_Date__c = sp.Suspension_Start_Date__c.addMonths(1);
        sp.Order_Rate_Plan_Charge_Suspension__c = charges[0].Id;
        insert sp;*/

        charge = charges[0];
        charge.Next_Uplift_Date__c = system.today().addMonths(6);
        charge.Discount_Value__c = 0;
        update charge;
        test.stopTest();

        // code for
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = acc.Id;
        insert invoice;

        Job__c job = [SELECT Id FROM Job__c];
        Invoice_Line__c invoiceLine = new Invoice_Line__c();
        invoiceLine.Job__c = job.Id;
        invoiceLine.Invoice__c = invoice.Id;
        invoiceline.Service_Start_Date__c = system.today()-1;
        invoiceline.Service_End_Date__c = system.today().addMonths(12);
        invoiceLine.Job_Rate_Plan_Charge__c = charges[1].Id;
        invoiceLine.Unit_Price__c = 100;
        invoiceline.Quantity__c = 1;
        invoiceline.Discount_Value__c = 1;
        invoiceline.Split_Invoice__c = false;
        insert invoiceline;

    }

    /*public static testMethod void recalcOrderTest() {


        List<Job__c> orders = [SELECT Recalculate__c, Id FROM Job__c];
        orders[0].Recalculate__c = true;
        update orders;

    }*/

    public static testMethod void testSchedulerClass() {

        VTMig_BatchUpliftSchedulable sh1 = new VTMig_BatchUpliftSchedulable();
        String sch = '0 0 23 * * ?';
        system.schedule('RunSchedulerUpdateOrders', sch, sh1);
        VTMig_BatchUpliftPrice batch=new VTMig_BatchUpliftPrice(null, true);
        ID batchprocessid = Database.executeBatch(batch, 3);

    }

    public static testMethod void testBatchUpliftOrderClass() {

        List<Job__c> jobs = [SELECT Id FROM Job__c];
        Set<Id> jobIds = new Set<Id>();
        for(Job__c job : jobs){
            jobIds.add(job.Id);
        }

        VTMig_IITBatchProcessForRecalculateOrder batch=new VTMig_IITBatchProcessForRecalculateOrder(jobIds);
        ID batchprocessid = Database.executeBatch(batch, 1);

    }

}