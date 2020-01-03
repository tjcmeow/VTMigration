/**
 * Created by triciaigoe on 2019-11-24.
 */
@IsTest
public with sharing class VTMig_NewOrder_Test {

    @TestSetup
    public static void setupData(){
        Account newAccount = VTMig_TestUtilities.createKVCustomer();
        insert newAccount; 
    }

    @IsTest
    static void testChildOrder(){

        Test.startTest();

        PageReference pageRef = Page.VTMig_NewOrder;
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Child Order' LIMIT 1].Id;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('RecordType',recordTypeId);
        Job__c newOrder = new Job__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_NewOrder controller = new VTMig_NewOrder(sc);

        Id accountId = [SELECT Id FROM Account].Id;
        newOrder.Account__c = accountId;

        controller.saveOrder();

        List<Job__c> newOrders = [SELECT Account__c FROM Job__c];
        System.assertEquals(newOrders.size(), 1);

        Test.stopTest();
    }

    @IsTest
    static void testSaleOrder(){

        Test.startTest();

        PageReference pageRef = Page.VTMig_NewOrder;
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Sale Order' LIMIT 1].Id;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('RecordType',recordTypeId);
        Job__c newOrder = new Job__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_NewOrder controller = new VTMig_NewOrder(sc);

        Id accountId = [SELECT Id FROM Account].Id;
        newOrder.Account__c = accountId;

        controller.saveOrder();

        List<Job__c> newOrders = [SELECT Account__c FROM Job__c];
        System.assertEquals(newOrders.size(), 1);

        Test.stopTest();
    }

    @IsTest
    static void testMasterOrder(){

        Test.startTest();

        PageReference pageRef = Page.VTMig_NewOrder;
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Master Order' LIMIT 1].Id;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('RecordType',recordTypeId);
        Job__c newOrder = new Job__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_NewOrder controller = new VTMig_NewOrder(sc);

        Id accountId = [SELECT Id FROM Account].Id;
        newOrder.Account__c = accountId;

        controller.saveOrder();

        List<Job__c> newOrders = [SELECT Account__c FROM Job__c];
        System.assertEquals(newOrders.size(), 1);

        Test.stopTest();
    }

}