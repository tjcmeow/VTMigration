/**
 * Created by triciaigoe on 2019-11-27.
 */

global with sharing class VTMig_IITBatchProcessForRecalculateOrder implements Database.Batchable<sObject>{

    global string squery;
    global Job__c OrderObj;
    global set<Id> orderIds = new set<Id>();

    global VTMig_IITBatchProcessForRecalculateOrder(set<Id> orderIds) {
        this.orderIds.addAll(orderIds);
    }

    // this method would return the count of batch execution
    public Database.QueryLocator start(Database.BatchableContext BC) {
        squery = 'SELECT Id FROM Job__c WHERE Id in:orderIds ';
        return Database.getQueryLocator(squery);
    }

    // Hard coding zero beacuse batch size will be always 1
    global void execute(Database.BatchableContext BC, List<Job__c > listOfOrder) {
        try {
            Job__c  orderObj = new Job__c(Id = listOfOrder[0].Id, Recalculate__c = true);
            update orderObj;
        } catch(exception ex) {
            System.debug(ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}