/**
 * Created by triciaigoe on 2019-10-26.
 */

public with sharing class VTMig_CreateOrder {
    public Opportunity opp;
    public VTMig_CreateOrder(ApexPages.StandardController controller) {
        opp = new Opportunity();
        opp = (Opportunity) controller.getRecord();
        opp  = [SELECT ID, IsWon, Account.Name FROM Opportunity WHERE ID =: opp.Id];
        if(!opp.IsWon) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info, 'Opportunity is not Close won. This will not create Order');
            ApexPages.addMessage(errorMessage);
        }
    }

    public PageReference createOrder() {
        try {
            Job__c order = configOrder();
            insert order;
            List<Job_Product__c> orderProducts = configProducts(order.Id);
            List<Opportunity_Rate_Plan__c> ratePlans = [SELECT Name, Id FROM Opportunity_Rate_Plan__c];
            PageReference pg = new PageReference('/'+opp.Id);
            return pg;
        } catch(Exception ex) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An exception has occurred ' + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            ApexPages.addMessage(errorMessage);

        }
        return null;
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

    public List<Job_Product__c> configProducts(Id orderId){
        List<Opportunity_Product__c> opportunityProducts = [
                SELECT Name, Description__c, SequenceNumber__c, Bundle_SequenceNumber__c, Product__c, Product_Code__c,
                        Product_Family__c, Product_Bundle__c
                FROM Opportunity_Product__c WHERE Opportunity__c = : opp.Id];
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
            newProducts.add(newProduct);
        }
        return newProducts;
    }
}