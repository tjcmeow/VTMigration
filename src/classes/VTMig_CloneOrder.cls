/**
 * Created by triciaigoe on 2019-11-15.
 */

public with sharing class VTMig_CloneOrder {

    public Id orderId {get; set;}
    public Job__c order {get; set;}
    public Boolean isRender {get; set;}
    public Boolean isMasterOrder {get; set;}
    public Boolean isChildOrder {get; set;}
    public Integer iCountOfChild {get;set;}
    public List<Job_Product__c> orderProducts = new List<Job_Product__c>();
    public List<Job_Rate_Plan_Charge__c> orderRatePlanCharges = new List<Job_Rate_Plan_Charge__c>();
    public List<Job_Rate_Plan__c> orderRatePlans = new List<Job_Rate_Plan__c>();
    public Map<Id, List<Job_Product__c>> orderProductsMap = new Map<Id, List<Job_Product__c>>();
    public Map<Id, List<Job_Rate_Plan__c>> orderRatePlansMap = new Map<Id, List<Job_Rate_Plan__c>>();
    public Map<Id, List<Job_Rate_Plan_Charge__c>> orderRatePlanChargesMap = new Map<Id, List<Job_Rate_Plan_Charge__c>>();


    public VTMig_CloneOrder(ApexPages.StandardController ctrlr){
        orderId = ApexPages.currentPage().getParameters().get('Id');
        isRender = false;
        order = [
                SELECT Id, Account__c, CurrencyL__c, Alignment_Date_1__c, Alignment_Date_2__c, Annual_Contract_Value_ACV__c, Auto_Renew__c, Auto_Renewal_Complete__c,
                        Billing_Account__c, Billing_and_Shipping_ACCOUNTS_the_same__c, Billing_and_Shipping_Address_the_same__c, BillingCity__c,
                        Billing_Contact__c, BillingCountry__c, Billing_Master_Account__c, Billing_Master_Order__c, BillingPostalCode__c, BillingState__c,
                        BillingStreet__c, BMS_Year_1__c, BMS_Year_2__c, BMS_Year_3__c, BMS_Year_4__c, BMS_Contract_Year__c, BMS_Initial_Invoice_Date__c,
                        BMS_Initial_Invoice_Date2__c, BMS_Invoiceevery__c, BMS_Next_Invoice_Date__c, BMS_Order_RecordID__c, BMS_ScheduleNo__c, BMS_TwoPer__c,
                        BMS_VOD_Initial_Terms__c, Candidate_Email_Address__c, Candidate_First_Name__c, Candidate_Last_Name__c, Company_Cod_from_BMS__c,
                        Contracted_MRR__c, Quote__c, Course_Authentication__c, Course_Delivery_Method__c, Current_Agreement_Date_BMS__c, CustAcctNo_BMS__c,
                        Customer_Purchase_Order_Number__c, Date_of_Birth__c, Date_Portfolio_Recieved__c, Date_Portfolio_Sent_To_Assessor__c, Despatch_Date__c,
                        Despatch_Date_Errors__c, Discount_Code__c, Discount_Value__c, Discount_Percent__c, Total__c, Has_Assets__c, Initial_Agreement_Date_BMS__c,
                        Initial_Term__c, Invoice_Batch__c, Invoice_Details__c, Is_Billing_Master_Order__c, Master_Order__c, Mid_Term_Order__c, Minimum_Next_Charge_Date_For_Product__c,
                        Name_of_Assessor__c, Nationality__c, Net_Total__c, No_Of_Child_Orders__c, Official_Termination_Given__c, Opportunity__c, Start_Date__c,
                        Order_Type__c, Order_Type_VT__c, Override_VAT_Tax__c, Partner__c, Partner_Agent__c, Partner_Text__c, Payment_Terms__c,
                        Preferred_Addressee__c, Preferred_Billing_Day__c, Product_Type__c, Recalculate__c, Regional_Format__c, Renewal_Order__c, Renewal_Terms_Months__c,
                        Renew_to__c, Scheduled_Date__c, Second_Billing_Contact__c, Service_Activation_Date__c, Service_End_Date__c, Ship_Count_BMS__c, BillingCity_Shipping__c,
                        BillingCountry_Shipping__c, BillingPostalCode_Shipping__c, BillingState_Shipping__c,
                        BillingStreet_Shipping__c, Special_Terms__c, Special_Terms_Details__c,
                        Sub_total__c, Tax__c, Tax_Calculation_Status__c, Tax_Engine__c, Number_of_Terms__c, X3rd_Billing_Contact__c, Todays_MRR__c, Todays_MRR_with_Tax__c,
                        Total_Contract_Value__c, Total_Profit__c, Total_Cost__c, TotalProfitPercent__c, VAT__c, VAT_Percentage_Applied__c, VAT_Roll_Up__c, 
                        Shipping_Contact__c, Shipping_Account__c, Legal_Entity__c, IITIntended_Use__c, VMA_Legacy_Acct_Code__c, VOD_Order__c, Withholding_Tax_Percentage__c,
                        Wet_or_Dry_Cargo__c, Platform_or_Vessel_detail__c, Name, RecordType.Name, Year_1_Net_Total__c, Year_2_Net_Total__c, Year_3_Net_Total__c, Year_4_Net_Total__c
                FROM Job__c WHERE Id = : orderId
        ];
        orderProducts = [
                SELECT Id, Bundle_SequenceNumber__c, Cloned_Id__c, Description__c, Minimum_Next_Charge_Date_For_Product__c, SequenceNumber__c,
                        Product__c, Product_Bundle__c, Product_Code__c, Product_Family__c, Name
                FROM Job_Product__c WHERE Job__c = : orderId
        ];
        orderProductsMap.put(orderId, orderProducts);
        List<Id> orderProductIds = new List<Id>();

        //Loop through order products to get Ids
        for(Job_Product__c orderProduct : orderProducts) {
            orderProductIds.add(orderProduct.Id);
        }

        orderRatePlans = [
                SELECT Id, Job_Product__c, Description__c, Sequence_Number__c, Cloned_Id__c, Product_Rate_Plan__c, Name
                FROM Job_Rate_Plan__c WHERE Job_Product__c IN: orderProductIds
        ];
        List<Id> orderRatePlanIds = new List<Id>();

        //Loop through order rate plans to create list of Ids for querying
        for(Job_Rate_Plan__c orderRatePlan : orderRatePlans) {
            orderRatePlanIds.add(orderRatePlan.Id);
            List<Job_Rate_Plan__c> tempOrderRatePlans = new List<Job_Rate_Plan__c>();
            if(orderRatePlansMap.keySet().contains(orderRatePlan.Job_Product__c)) {
                tempOrderRatePlans = orderRatePlansMap.get(orderRatePlan.Job_Product__c);
            }
            tempOrderRatePlans.add(orderRatePlan);
            orderRatePlansMap.put(orderRatePlan.Job_Product__c, tempOrderRatePlans);
        }

        orderRatePlanCharges = [
                SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Agreement__c, Airway_Bill_Number__c, Auto_Renew__c,
                        Product_Rate_Plan_Charge__c, Job_Rate_Plan__c, Billing_Group__c, Billing_Master_Grouped_Quantity__c, BMS_Contract_Year__c,
                        Bundle__c, Charge_Code__c, Committed_Quantity__c, Count_Of_Titles__c, Courier__c, Charge_Date__c, Deferred_Revenue_Accounting_Code__c,
                        Delivery__c, Discount_Percent__c, Discount_Type__c, Discount_Value__c, Dispatch__c, Error_Reason_for_Revenue_Recognition__c, Group_Id__c,
                        Grouping__c, Hardware_Delivery__c, HK_VOD__c, Included_Quantity__c, Invoice_Grouping__c, Is_Cumulative_Usage__c, Is_Product_Editable__c,
                        Last_Uplift_Date__c, Legacy_Orders__c, Max_Customer_Spend__c, Mid_Term_Status__c, Min_Customer_Spend__c, Net_Total__c, Next_Charge_Date__c,
                        Next_Uplift_Date__c, Order__c, Package__c, Previous_Charge_Date__c, Product_Bundle_Line__c, Profit__c, Quantity_Already_Dispatched__c,
                        Quantity_to_Dispatch__c, Quote_Charge_Id__c, Recalculate_Revenue_Forecasts__c, RecreateUsageMediations__c, AnnualRentYear2__c,
                        AnnualRentYear3__c, AnnualRentYear4__c, Accounting_Code__c, Revenue_Recognition_End_Date__c, Revenue_Recognition_Rule__c,
                        Revenue_Recognition_Start_Date__c, Revenue_Recognition_Status__c, Sequence_No__c, Service_End_Date__c, Service_Activation_Date__c, Status__c,
                        Subscription_Status__c, Price__c, Tax__c, Tax_City__c, Tax_Code__c, Tax_Country__c, Tax_Percentage__c, Tax_State__c,
                        Tax_Street__c, Tax_Zip_Code__c, Cost__c, Transfer_Price__c, Cost_Price__c, Unit_Price_1st_Year__c, Uplift__c, Uplift_Exception__c, Uplift_Frequency__c,
                        Usage_Frequency__c, Used_Quantity_for_Usage__c, VAT__c, VAT_Percentage__c, VSOE_Index__c, VSOE_Package_Total__c, VSOE_Pricing__c, VSOE_Total__c,
                        Year_1_Net_Total__c, Year_1_Row_Total__c, Year_1_VAT__c, Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Price_Format__c,
                        Unit_Price__c, Percentage_of_Other_Charges__c, Quantity__c
                FROM Job_Rate_Plan_Charge__c WHERE Job_Rate_Plan__c IN: orderRatePlanIds
        ];

        for(Job_Rate_Plan_Charge__c orderRatePlanCharge : orderRatePlanCharges) {
            List<Job_Rate_Plan_Charge__c> tempCharges = new List<Job_Rate_Plan_Charge__c>();
            if(orderRatePlanChargesMap.keySet().contains(orderRatePlanCharge.Job_Rate_Plan__c)) {
                tempCharges = orderRatePlanChargesMap.get(orderRatePlanCharge.Job_Rate_Plan__c);
            }
            tempCharges.add(orderRatePlanCharge);
            orderRatePlanChargesMap.put(orderRatePlanCharge.Job_Rate_Plan__c, tempCharges);
        }
        isMasterOrder = false;
        isChildOrder = false;

    }

    public PageReference cancel(){
        return returnToOrder();
    }

    public PageReference createCloneOrder(){

        List<Job__c> newOrders = createOrders();
        List<Job_Product__c> jobProducts = new List<Job_Product__c>();
        List<Job_Rate_Plan__c> jobRatePlans = new List<Job_Rate_Plan__c>();
        List<Job_Rate_Plan_Charge__c> jobRatePlanCharges = new List<Job_Rate_Plan_Charge__c>();

        for(Job__c newOrder : newOrders) {
            List<Job_Product__c> tempJobProducts = new List<Job_Product__c>();
            for(Job_Product__c orderProduct : orderProducts) {
                Job_Product__c jobProduct = orderProduct.clone(false);
                jobProduct.Name = orderProduct.Name;
                jobProduct.Job__c = newOrder.Id;
                jobProduct.Cloned_Id__c = orderProduct.Id;
                tempJobProducts.add(jobProduct);
            }
            orderProductsMap.put(newOrder.Id, tempJobProducts);
            jobProducts.addAll(tempJobProducts);
        }
        insert jobProducts;

        for(Job__c newOrder : newOrders) {
            for(Job_Product__c jobProduct : orderProductsMap.get(newOrder.Id)) {
                List<Job_Rate_Plan__c> orderRatePlansFromMap = new List<Job_Rate_Plan__c>();
                if(orderRatePlansMap.keySet().contains(jobProduct.Cloned_Id__c)) {
                    orderRatePlansFromMap = orderRatePlansMap.get(jobProduct.Cloned_Id__c);
                }
                List<Job_Rate_Plan__c> tempRatePlans = New List<Job_Rate_Plan__c>();
                for(Job_Rate_Plan__c orderRatePlan : orderRatePlansFromMap) {
                    Job_Rate_Plan__c jobRatePlan = orderRatePlan.clone(false);
                    jobRatePlan.Name = orderRatePlan.Name;
                    jobRatePlan.Job_Product__c = jobProduct.Id;
                    jobRatePlan.Cloned_Id__c = orderRatePlan.Id;
                    tempRatePlans.add(jobRatePlan);
                }
                orderRatePlansMap.put(jobProduct.Id, tempRatePlans);
                jobRatePlans.addAll(tempRatePlans);
            }
        }
        insert jobRatePlans;

        for(Job__c newOrder : newOrders) {
            for(Job_Product__c jobProduct : orderProductsMap.get(newOrder.Id)) {
                for(Job_Rate_Plan__c orderRatePlan : orderRatePlansMap.get(jobProduct.Id)) {
                    List<Job_Rate_Plan_Charge__c> tempCharges = new List<Job_Rate_Plan_Charge__c>();
                    List<Job_Rate_Plan_Charge__c> orderChargesFromMap = new List<Job_Rate_Plan_Charge__c>();
                    if(orderRatePlanChargesMap.keySet().contains(orderRatePlan.Cloned_Id__c)) {
                        orderChargesFromMap = orderRatePlanChargesMap.get(orderRatePlan.Cloned_Id__c);
                    }
                    for(Job_Rate_Plan_Charge__c orderRatePlanCharge : orderChargesFromMap) {
                        Job_Rate_Plan_Charge__c jobRatePlanCharge = orderRatePlanCharge.clone(false);
                        jobRatePlanCharge.Order__c = newOrder.Id;
                        jobRatePlanCharge.Job_Rate_Plan__c = orderRatePlan.Id;
                        jobRatePlanCharges.add(jobRatePlanCharge);
                    }
                }

            }
        }
        insert jobRatePlanCharges;
        return returnToOrder();

    }

    public List<Job__c> createOrders(){

        Id recordTypeId;
        if(isMasterOrder) {
            recordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Master Order').getRecordTypeId();
            iCountOfChild = 1;
        } else {
            recordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Child Order').getRecordTypeId();
        }

        // Insert possible list of orders that clone the original order
        List<Job__c> ordersForInsert = new List<Job__c>();
        for(Integer i = 0; i < iCountOfChild; i++) {
            Job__c newOrder = new Job__c();
            newOrder = order.clone(false, false, false, false);
            newOrder.RecordTypeId = recordTypeId;
            newOrder.CurrencyL__c = order.CurrencyL__c;
            newOrder.Start_Date__c = System.today();
            if(!isMasterOrder) {
                newOrder.Master_Order__c = orderId;
                newOrder.Service_Activation_Date__c = null;
            }
            ordersForInsert.add(newOrder);
        }
        insert ordersForInsert;
        return ordersForInsert;
    }

    public PageReference returnToOrder(){
        PageReference pageRef = new PageReference('/'+ orderId);
        return pageRef;
    }

}