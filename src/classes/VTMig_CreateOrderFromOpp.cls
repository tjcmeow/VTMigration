/**
 * Created by triciaigoe on 2019-11-22.
 */

public with sharing class VTMig_CreateOrderFromOpp {

    public Opportunity OpportunityObj;
    public createOrder(ApexPages.StandardController controller) {
        OpportunityObj = new Opportunity();
        OpportunityObj = (Opportunity) controller.getRecord();
        OpportunityObj  = [SELECT ID, IsWon FROM Opportunity WHERE ID =: OpportunityObj.Id];
        if(!OpportunityObj.IsWon) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.Info, 'Opportunity is not Close won. This will not create Order');
            Apexpages.addMessage(errorMessage);
        }
    }

    public pagereference createOrder() {

        try {
            if(OpportunityObj.IsWon) {
                creatingTheOrder();
            }

            pagereference pg = new pagereference('/'+OpportunityObj.Id);
            return pg;
        } catch(exception ex) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, 'An excepection has occurred ' + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            Apexpages.addMessage(errorMessage);

        }
        return null;
    }

    public void creatingTheOrder() {
        Job__c newOrder = new Job__c();
        newOrder
    }

}