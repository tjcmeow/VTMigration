/**
 * Created by triciaigoe on 2019-11-13.
 */
@isTest
public with sharing class OrderCommissionTriggerTest {

    @TestSetup
    public static void OrderCommisionTrigger() {

        //Partner Creation
        Account acc = VTMig_TestUtilities.createKVPartner();
        insert acc;

        //Customer Creation
        Account acc2 = VTMig_TestUtilities.createKVCustomer();
        insert acc2;

        //Master order Creation
        Job__c masterOrder = VTMig_TestUtilities.createMasterOrder(acc2.Id);
        masterOrder.Sub_total__c = 100;
        masterOrder.IITIntended_Use__c = 'LOCAL UK WATERS';
        masterOrder.Withholding_Tax_Percentage__c = 10;
        masterOrder.BMS_Contract_Year__c = 1;
        insert masterOrder;


        //Child Order Creation
        Job__c childOrder = VTMig_TestUtilities.createMasterOrder(acc2.Id);
        childOrder.Sub_total__c = 100;
        childOrder.IITIntended_Use__c = 'LOCAL UK WATERS';
        childOrder.Withholding_Tax_Percentage__c = 10;
        childOrder.BMS_Contract_Year__c = 1;
        childOrder.Mid_Term_Order__c = true;
        childOrder.Master_Order__c = masterOrder.Id;
        childOrder.RecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Child Order').getRecordTypeId();
        insert childOrder;


        //Product Creation
        Product__c invoiceProduct = VTMig_TestUtilities.createProduct();
        insert invoiceProduct;

        //Partner Commission Record Creation
        Partner_Commission_Rates__c pcr = New Partner_Commission_Rates__c();
        pcr.Partner_Agent_Account__c = acc.Id;
        pcr.Product__c = invoiceProduct.id;
        pcr.Standard_Comm__c = 1.0;
        pcr.Year1_Commission__c = 1.0;
        insert pcr;

    }

    @IsTest
    public static void testInsert() {

        Product__c invoiceProduct = [SELECT Id FROM Product__c];
        Account acc = [SELECT Id FROM Account WHERE RecordType.Name = 'KV Partner'];
        Job__c childOrder = [SELECT Id FROM Job__c WHERE RecordType.Name = 'Child Order'];
        Job__c masterOrder = [SELECT Id FROM Job__c WHERE RecordType.Name = 'Master Order'];


        //OrderCommision Creation
        list<Order_Commissions__c> orderCommissions = New list<Order_Commissions__c>();
        Order_Commissions__c oc = New Order_Commissions__c();
        oc.Order_Product__c = invoiceProduct.id;
        oc.Sales_Agent__c = acc.id;
        oc.Order_for_Commission__c = childOrder.id;
        orderCommissions.add(oc);

        Order_Commissions__c oc1 = New Order_Commissions__c();
        oc1.Order_Product__c = invoiceProduct.id;
        oc1.Sales_Agent__c = acc.id;
        oc1.Order_for_Commission__c = masterOrder.id;
        oc1.Commission_Basis__c = 'Master Order';
        orderCommissions.add(oc1);

        Order_Commissions__c oc2 = New Order_Commissions__c();
        oc2.Order_Product__c = invoiceProduct.id;
        oc2.Sales_Agent__c = acc.id;
        oc2.Order_for_Commission__c = masterOrder.id;
        orderCommissions.add(oc2);

        insert orderCommissions;

    }

    @IsTest
    public static void testUpdate(){
        Job__c childOrder = [SELECT Id FROM Job__c WHERE RecordType.Name = 'Child Order'];
        Product__c invoiceProduct = [SELECT Id FROM Product__c];
        Account acc = [SELECT Id FROM Account WHERE RecordType.Name = 'KV Partner'];
        Order_Commissions__c oc = New Order_Commissions__c();
        oc.Order_Product__c = invoiceProduct.id;
        oc.Sales_Agent__c = acc.id;
        oc.Order_for_Commission__c = childOrder.id;
        insert oc;

        update oc;
    }

}