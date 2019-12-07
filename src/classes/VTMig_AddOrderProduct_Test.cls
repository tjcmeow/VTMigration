/**
 * Created by triciaigoe on 2019-11-19.
 */
@IsTest
public with sharing class VTMig_AddOrderProduct_Test {

    @TestSetup
    static void setUpData(){

        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        insert newAccount;

        Job__c newOrder = new Job__c();
        newOrder.Account__c = newAccount.Id;
        newOrder.Name = 'New Order';
        insert newOrder;

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

        Job_Product__c orderProduct = new Job_Product__c();
        orderProduct.Job__c = newOrder.Id;
        orderProduct.Product__c = newProduct.Id;
        insert orderProduct;

        Job_Rate_Plan__c orderRatePlan = new Job_Rate_Plan__c();
        orderRatePlan.Product_Rate_Plan__c = newProductRatePlan.Id;
        orderRatePlan.Job_Product__c = orderProduct.Id;
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

        Job_Rate_Plan_Charge__c orderRatePlanCharge = new Job_Rate_Plan_Charge__c();
        orderRatePlanCharge.Job_Rate_Plan__c = orderRatePlan.Id;
        orderRatePlanCharge.Quantity__c = 1;
        orderRatePlanCharge.Order__c = newOrder.Id;
        orderRatePlanCharge.Product_Rate_Plan_Charge__c = productRatePlanCharge.Id;
        orderRatePlanCharge.Unit_Price__c = 100;
        orderRatePlanCharge.Name = 'New Opp Rate Plan Charge';
        orderRatePlanCharge.Price__c = 100;
        orderRatePlanCharge.Discount_Value__c = 0;
        orderRatePlanCharge.Discount_Percent__c = 0;
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