/**
 * Created by triciaigoe on 2019-11-20.
 */

public with sharing class VTMig_UpdateOrderStatus {

    public Id orderId {get; set;}
    public Job__c order {get; set;}
    public List<Job_Rate_Plan_Charge__c> selectedCharges {get;set;}

    public VTMig_UpdateOrderStatus(ApexPages.StandardController ctrlr){
        orderId = ApexPages.currentPage().getParameters().get('Id');
        selectedCharges = new List<Job_Rate_Plan_Charge__c>();
        order = [
                SELECT Id, Account__c, Name, Status__c, Despatch_Date__c, Service_Activation_Date__c, Service_End_Date__c, Alignment_Date_1__c,
                        Alignment_Date_2__c, Initial_Term__c, Order_Number__c, Account__r.RecordType.DeveloperName
                FROM Job__c WHERE Id = : orderId
        ];
        selectedCharges = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Job_Rate_Plan__r.Job_Product__r.Name,
                Job_Rate_Plan__r.Job_Product__r.Product__c, Product_Rate_Plan_Charge__c, Job_Rate_Plan__r.Job_Product__r.Product_Code__c,
                Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Price_Format__c, Unit_Price__c, Uplift__c, Auto_Renew__c, Courier__c,
                Quantity__c, Job_Rate_Plan__r.Product_Rate_Plan__c, Row_Total__c, Airway_Bill_Number__c, Service_End_Date__c,
                Service_Activation_Date__c, Status__c, Discount_Value__c
        FROM Job_Rate_Plan_Charge__c WHERE Order__c = : orderId];
    }

    public PageReference saveOrder(){
        if((order.Status__c == 'Order Entry Complete')
                && order.Account__r.RecordType.DeveloperName == 'KV_Prospect') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please change account to KV Customer'));
        } else {
            Job__c newOrder = new Job__c();
            newOrder.Despatch_Date__c = order.Despatch_Date__c;
            newOrder.Service_Activation_Date__c = order.Service_Activation_Date__c;
            newOrder.Id = orderId;
            newOrder.Status__c = order.Status__c;
            newOrder.Alignment_Date_2__c = order.Alignment_Date_2__c;
            newOrder.Alignment_Date_1__c = order.Alignment_Date_1__c;
            newOrder.Initial_Term__c = order.Initial_Term__c;
            try{
                update newOrder;
                for(Job_Rate_Plan_Charge__c selectedCharge : selectedCharges) {
                    selectedCharge.Price__c = selectedCharge.Unit_Price__c * selectedCharge.Quantity__c;
                    if(selectedCharge.Discount_Value__c == null) {
                        selectedCharge.Discount_Value__c = 0;
                    }
                    selectedCharge.Net_Total__c = selectedCharge.Price__c - selectedCharge.Discount_Value__c;
                }
                update selectedCharges;
                PageReference pageRef = new PageReference('/' + orderId);
                return pageRef;
            } catch(Exception ex) {
                if(ex.getMessage().contains('Shipping Account')) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please add Shipping Account'));
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
                }

            }
        }


        return null;
    }

}