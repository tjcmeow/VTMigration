/**
 * Created by triciaigoe on 2019-10-26.
 */

public with sharing class VTMig_CreateOrder {
    public Opportunity opp {get; set;}
    public Id orderId;
    public List<Opportunity_Product__c> opportunityProducts {get; set;}
    public List<Opportunity_Rate_Plan__c> opportunityRatePlans {get; set;}
    public List<Opportunity_Rate_Plan_Charge__c> opportunityRatePlanCharges {get; set;}
    public List<Id> opportunityProductIds = new List<Id>();
    public List<Id> opportunityPlanIds = new List<Id>();
    public Map<Id, List<Opportunity_Rate_Plan_Charge__c>> opportunityChargeMap {get; set;}
    public Map<Id, List<Opportunity_Rate_Plan__c>> opportunityRatePlanMap {get; set;}

    public VTMig_CreateOrder(ApexPages.StandardController controller) {
        opp = new Opportunity();
        opp = (Opportunity) controller.getRecord();
        opp  = [
                SELECT Id, IsWon, Account.Name, Shipping_Account__c, Legal_Entity__c, Shipping_Contact__c,
                        Billing_Contact__c, IItIntended_Use__c, Platform_or_Vessel_detail__c, 
                        Wet_or_Dry_Cargo__c, Partner_Agent__c
                FROM Opportunity WHERE Id =: opp.Id
        ];
        opportunityRatePlanMap = new Map<Id, List<Opportunity_Rate_Plan__c>>();
        opportunityChargeMap = new Map<Id, List<Opportunity_Rate_Plan_Charge__c>>();
        if(!opp.IsWon) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info, 'Opportunity is not Close won. This will not create Order');
            ApexPages.addMessage(errorMessage);
        } else {
            opportunityProducts = [
                    SELECT Name, Description__c, SequenceNumber__c, Bundle_SequenceNumber__c, Product__c, Product_Code__c,
                            Product_Family__c, Product_Bundle__c
                    FROM Opportunity_Product__c WHERE Opportunity__c = : opp.Id];
            for(Opportunity_Product__c opportunityProduct : opportunityProducts) {
                opportunityProductIds.add(opportunityProduct.Id);
            }
            opportunityRatePlans = [
                    SELECT Id, Name, SequenceNumber__c, Description__c, Product_Rate_Plan__c, Opportunity_Product__c
                    FROM Opportunity_Rate_Plan__c
                    WHERE Opportunity_Product__c IN : opportunityProductIds
            ];

            for(Opportunity_Rate_Plan__c opportunityRatePlan : opportunityRatePlans) {
                opportunityPlanIds.add(opportunityRatePlan.Id);
                List<Opportunity_Rate_Plan__c> tempPlans = new List<Opportunity_Rate_Plan__c>();
                if(opportunityRatePlanMap.containsKey(opportunityRatePlan.Opportunity_Product__c)) {
                    tempPlans = opportunityRatePlanMap.get(opportunityRatePlan.Opportunity_Product__c);
                }
                tempPlans.add(opportunityRatePlan);
                opportunityRatePlanMap.put(opportunityRatePlan.Opportunity_Product__c, tempPlans);
            }

            opportunityRatePlanCharges = [
                    SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Opportunity_Rate_Plan__r.Opportunity_Product__r.Name,
                            Opportunity_Rate_Plan__r.Opportunity_Product__r.Product__c, Product_Rate_Plan_Charge__c, Price__c,
                            Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Model__c, Unit_Price__c,
                            Quantity__c, Opportunity_Rate_Plan__r.Opportunity_Product__r.Product_Code__c, Opportunity_Rate_Plan__r.Product_Rate_Plan__c,
                            VAT__c, Tax__c, Discount_Type__c, Discount_Value__c, Discount_Percent__c, Net_Total__c, Uplift__c,
                            Accounting_Code__c, Cost__c, Cost_Price__c, Committed_Quantity__c, Percentage_of_Other_Charges__c, Min_Customer_Spend__c,
                            Max_Customer_Spend__c, Profit__c, Product_Bundle_Line__c, Sequence_No__c
                    FROM Opportunity_Rate_Plan_Charge__c WHERE Opportunity_Rate_Plan__c IN : opportunityPlanIds
            ];

            for(Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge : opportunityRatePlanCharges) {

                List<Opportunity_Rate_Plan_Charge__c> tempCharges = new List<Opportunity_Rate_Plan_Charge__c>();
                if(opportunityChargeMap.containsKey(opportunityRatePlanCharge.Opportunity_Rate_Plan__c)) {
                    tempCharges = opportunityChargeMap.get(opportunityRatePlanCharge.Opportunity_Rate_Plan__c);
                }
                tempCharges.add(opportunityRatePlanCharge);
                opportunityChargeMap.put(opportunityRatePlanCharge.Opportunity_Rate_Plan__c, tempCharges);
            }


        }
    }

    public PageReference createOrder() {
        try {
            Job__c order = configOrder();
            insert order;
            orderId = order.Id;

            List<Job_Product__c> orderProducts = configProducts();
            insert orderProducts;

            List<Job_Rate_Plan__c> ratePlans = configPlans(orderProducts);
            insert ratePlans;

            List<Job_Rate_Plan_Charge__c> ratePlanCharges = configCharges(ratePlans);
            insert ratePlanCharges;

            PageReference pg = new PageReference('/'+opp.Id);
            return pg;
        } catch(Exception ex) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An exception has occurred ' + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            ApexPages.addMessage(errorMessage);

        }
        return null;
    }

    public List<Job_Rate_Plan__c> configPlans(List<Job_Product__c> orderProducts){

        List<Job_Rate_Plan__c> ratePlans = new List<Job_Rate_Plan__c>();

        for(Job_Product__c orderProduct : orderProducts) {
            List<Opportunity_Rate_Plan__c> tempPlans = opportunityRatePlanMap.get(orderProduct.Cloned_Id__c);
            for(Opportunity_Rate_Plan__c opportunityRatePlan : tempPlans) {
                Job_Rate_Plan__c newRatePlan = new Job_Rate_Plan__c();
                newRatePlan.Product_Rate_Plan__c = opportunityRatePlan.Product_Rate_Plan__c;
                newRatePlan.Name = opportunityRatePlan.Name;
                newRatePlan.Description__c = opportunityRatePlan.Description__c;
                newRatePlan.Sequence_Number__c = opportunityRatePlan.SequenceNumber__c;
                newRatePlan.Cloned_Id__c = opportunityRatePlan.Id;
                newRatePlan.Job_Product__c = orderProduct.Id;
                ratePlans.add(newRatePlan);
            }
        }

        return ratePlans;
    }

    public List<Job_Rate_Plan_Charge__c> configCharges(List<Job_Rate_Plan__c> orderPlans){

        List<Job_Rate_Plan_Charge__c> charges = new List<Job_Rate_Plan_Charge__c>();

        for(Job_Rate_Plan__c orderPlan : orderPlans) {
            List<Opportunity_Rate_Plan_Charge__c> tempCharges = opportunityChargeMap.get(orderPlan.Cloned_Id__c);
            for(Opportunity_Rate_Plan_Charge__c tempCharge : tempCharges) {
                Job_Rate_Plan_Charge__c newRatePlanCharge = new Job_Rate_Plan_Charge__c();
                newRatePlanCharge.Job_Rate_Plan__c = orderPlan.Id;
                newRatePlanCharge.Name = tempCharge.Name;
                newRatePlanCharge.Order__c = orderId;
                newRatePlanCharge.Unit_Price__c = tempCharge.Unit_Price__c;
                newRatePlanCharge.Quantity__c = tempCharge.Quantity__c;
                newRatePlanCharge.Product_Rate_Plan_Charge__c = tempCharge.Product_Rate_Plan_Charge__c;
                newRatePlanCharge.Product_Charge_Category__c = tempCharge.Product_Charge_Category__c;
                newRatePlanCharge.Subscription_Product__c = tempCharge.Subscription_Product__c;
                newRatePlanCharge.Price__c = tempCharge.Price__c;
                newRatePlanCharge.Unit_Of_Measurement__c = tempCharge.Unit_Of_Measurement__c;
                newRatePlanCharge.Price_Format__c = tempCharge.Pricing_Model__c;
                newRatePlanCharge.Price_Type__c = tempCharge.Price_Type__c;
                newRatePlanCharge.Title_Product__c = tempCharge.Title_Product__c;
                newRatePlanCharge.VAT__c = tempCharge.VAT__c;
                newRatePlanCharge.Tax__c = tempCharge.Tax__c;
                newRatePlanCharge.Discount_Percent__c = tempCharge.Discount_Percent__c;
                newRatePlanCharge.Discount_Value__c = tempCharge.Discount_Value__c;
                newRatePlanCharge.Net_Total__c = tempCharge.Net_Total__c;
                newRatePlanCharge.Uplift__c = tempCharge.Uplift__c;
                newRatePlanCharge.Accounting_Code__c = tempCharge.Accounting_Code__c;
                newRatePlanCharge.Cost_Price__c = tempCharge.Cost_Price__c;
                newRatePlanCharge.Cost__c = tempCharge.Cost__c;
                newRatePlanCharge.Committed_Quantity__c = tempCharge.Committed_Quantity__c;
                newRatePlanCharge.Discount_Type__c = tempCharge.Discount_Type__c;
                newRatePlanCharge.Percentage_of_Other_Charges__c = tempCharge.Percentage_of_Other_Charges__c;
                newRatePlanCharge.Min_Customer_Spend__c = tempCharge.Min_Customer_Spend__c;
                newRatePlanCharge.Max_Customer_Spend__c = tempCharge.Max_Customer_Spend__c;
                newRatePlanCharge.Profit__c = tempCharge.Profit__c;
                newRatePlanCharge.Product_Bundle_Line__c = tempCharge.Product_Bundle_Line__c;
                newRatePlanCharge.Sequence_No__c = tempCharge.Sequence_No__c;
                charges.add(newRatePlanCharge);
            }
        }

        return charges;
    }

    public Job__c configOrder(){
        Job__c newOrder = new Job__c();
        newOrder.Name = opp.Account.Name;
        newOrder.Status__c = 'New';
        newOrder.Account__c = opp.AccountId;
        newOrder.Shipping_Account__c = opp.Shipping_Account__c;
        newOrder.Legal_Entity__c = opp.Legal_Entity__c;
        newOrder.Shipping_Contact__c = opp.Shipping_Contact__c;
        newOrder.Billing_Contact__c = opp.Billing_Contact__c;
        newOrder.IITIntended_Use__c = opp.IItIntended_Use__c;
        newOrder.Platform_or_Vessel_detail__c = opp.Platform_or_Vessel_detail__c;
        newOrder.Wet_or_Dry_Cargo__c = opp.Wet_or_Dry_Cargo__c;
        newOrder.Partner_Agent__c = opp.Partner_Agent__c;
        return newOrder;
    }

    public List<Job_Product__c> configProducts(){
        List<Job_Product__c> newProducts = new List<Job_Product__c>();
        for(Opportunity_Product__c opportunityProduct : opportunityProducts) {
            Job_Product__c newProduct = new Job_Product__c();
            newProduct.Name = opportunityProduct.Name;
            newProduct.Description__c = opportunityProduct.Description__c;
            newProduct.SequenceNumber__c = opportunityProduct.SequenceNumber__c;
            newProduct.Bundle_SequenceNumber__c = opportunityProduct.Bundle_SequenceNumber__c;
            newProduct.Product__c = opportunityProduct.Product__c;
            newProduct.Product_Bundle__c = opportunityProduct.Product_Bundle__c;
            newProduct.Product_Family__c = opportunityProduct.Product_Family__c;
            newProduct.Product_Code__c = opportunityProduct.Product_Code__c;
            newProduct.Job__c = orderId;
            newProduct.Cloned_Id__c = opportunityProduct.Id;
            newProducts.add(newProduct);
        }
        return newProducts;
    } 
}