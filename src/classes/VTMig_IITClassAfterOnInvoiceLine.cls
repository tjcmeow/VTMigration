/**
 * Created by triciaigoe on 2019-11-25.
 */

public with sharing class VTMig_IITClassAfterOnInvoiceLine {

    public void handleAfterOnInvoiceLine(map<Id,Invoice_Line__c > newMap, map<Id,Invoice_Line__c > oldMap) {
        if(trigger.isInsert) {
            list<Invoice_Line__c> invoiceLines;
            invoiceLines = [SELECT Id
            FROM Invoice_Line__c
            WHERE Id In : newMap.keySet()
            //AND
            //Job__r.Mid_Term_Order__c = true
            AND
            Split_Invoice__c = false
            AND
            Job_Rate_Plan_Charge__r.Price_Type__c != 'One Time'
            AND
            Job_Rate_Plan_Charge__r.Price_Type__c != 'Monthly'
            ];

            if(invoiceLines.size() > 0) {
                VTMig_IITCommonUtilClass.calculateQuantity(invoiceLines);
            }
        }
    }
}