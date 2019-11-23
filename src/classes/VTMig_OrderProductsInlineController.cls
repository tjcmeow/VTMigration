/**
 * Created by triciaigoe on 2019-10-20.
 */

public with sharing class VTMig_OrderProductsInlineController {
    public List<Job_Rate_Plan_Charge__c> charges {get;set;}

    public VTMig_OrderProductsInlineController(ApexPages.StandardController ctrlr){
        Job__c newOrder = new Job__c();
        newOrder = (Job__c) ctrlr.getRecord();
        newOrder = [SELECT Name FROM Job__c WHERE Id =: newOrder.Id];
        charges = [
                SELECT Job_Rate_Plan__c, Name, Id, Revenue_Recognition_Rule__c, Count_Of_Titles__c, Revenue_Recognition_Rule__r.Name,
                        Row_Total__c, Tax__c, VAT__c, Net_Total__c, Discount_Value__c, Price__c, Unit_Price__c,
                        Service_Activation_Date__c, Service_End_Date__c, Status__c, Price_Type__c, Quantity__c,
                        Job_Rate_Plan__r.Product_Rate_Plan__r.Product__c, Job_Rate_Plan__r.Product_Rate_Plan__r.Product__r.Name
                FROM Job_Rate_Plan_Charge__c
                WHERE Order__c = : newOrder.Id
        ];
    }

}