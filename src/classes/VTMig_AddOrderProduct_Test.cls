/**
 * Created by triciaigoe on 2019-11-19.
 */
@IsTest
public with sharing class VTMig_AddOrderProduct_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = VTMig_TestUtilities.createKVCustomer();
        insert newAccount;

        Job__c newOrder = VTMig_TestUtilities.createMasterOrder(newAccount.Id);
        insert newOrder;

        Product__c newProduct = VTMig_TestUtilities.createProduct();
        insert newProduct;

        Product_Rate_Plan__c newProductRatePlan = VTMig_TestUtilities.createRatePlan(newProduct.Id);
        insert newProductRatePlan;

        Product_Rate_Plan_Charge__c newProductRatePlanCharge = VTMig_TestUtilities.createProductCharge(newProductRatePlan.Id);
        insert newProductRatePlanCharge;

        Job_Product__c orderProduct = VTMig_TestUtilities.createOrderProduct(newOrder.Id, newProduct.Id);
        insert orderProduct;

        Job_Rate_Plan__c orderRatePlan = VTMig_TestUtilities.createOrderRatePlan(newProductRatePlan.Id, orderProduct.Id);
        insert orderRatePlan;

    }

    @IsTest
    static void testOpenList(){

        Job__c theOrder = [SELECT Id FROM Job__c];

        Test.startTest();

        PageReference pageRef = Page.VTMig_AddOrderProducts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',theOrder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(theOrder);
        VTMig_AddOrderProduct controller = new VTMig_AddOrderProduct(sc);

        controller.openList();
        controller.step1();
        System.assertEquals(controller.showProducts, true);

        Test.stopTest();
    }

    @IsTest
    static void testSelectPlanAndCharge(){

        Job__c newOrder = [SELECT Id FROM Job__c];

        Job_Rate_Plan__c orderRatePlan = [SELECT Id FROM Job_Rate_Plan__c];

        Product_Rate_Plan_Charge__c productRatePlanCharge = [SELECT Id FROM Product_Rate_Plan_Charge__c];

        Job_Rate_Plan_Charge__c orderRatePlanCharge = VTMig_TestUtilities.createORPC(newOrder.Id, productRatePlanCharge.Id, orderRatePlan.Id);
        insert orderRatePlanCharge;

        Test.startTest();

        PageReference pageRef = Page.VTMig_ProductSelection;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',newOrder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrder);
        VTMig_AddOrderProduct controller = new VTMig_AddOrderProduct(sc);

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
        for (VTMig_AddOrderProduct.ProdCharge prodCharge : controller.prodCharges) {
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

        PageReference pageRef2 = controller.saveProducts();

        Test.stopTest();

    }

}