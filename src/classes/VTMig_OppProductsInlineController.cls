/**
 * Created by triciaigoe on 2019-10-27.
 */

public with sharing class VTMig_OppProductsInlineController {

    public List<Opportunity_Rate_Plan_Charge__c> charges {get;set;}

    public VTMig_OppProductsInlineController(ApexPages.StandardController ctrlr){
        Opportunity newOpportunity = new Opportunity();
        newOpportunity = (Opportunity) ctrlr.getRecord();
        newOpportunity = [SELECT Name FROM Opportunity WHERE Id =: newOpportunity.Id];
        charges = [
                SELECT Opportunity_Rate_Plan__c, Name, Id, Row_Total__c, Tax__c, VAT__c,
                        Net_Total__c, Discount_Value__c, Price__c, Unit_Price__c,
                        Status__c, Price_Type__c, Quantity__c,
                        Opportunity_Rate_Plan__r.Product_Rate_Plan__r.Product__c
                FROM Opportunity_Rate_Plan_Charge__c
                WHERE Opportunity__c = : newOpportunity.Id
        ];
    }

}