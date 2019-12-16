/**
 * Created by triciaigoe on 2019-11-25.
 */

trigger VTMig_OrderInvoiceITTrigger on Job__c (before update, before insert, after update,after insert,after delete) {

    if(Trigger.isBefore && Trigger.isUpdate) {
        VTMig_OrderInvoiceITTriggerClass.beforeInsertUpdate(Trigger.newMap,Trigger.oldMap);
    }

    if(Trigger.isUpdate){
        VTMig_OrderInvoiceITTriggerClass.ExecuteUpdateEvents(Trigger.new,Trigger.newMap,Trigger.oldMap);
    }

    if(trigger.isInsert  &&  VTMig_OrderInvoiceITTriggerClass.dontRunAgain && trigger.isAfter){
        VTMig_OrderInvoiceITTriggerClass.dontRunAgain = false;
        VTMig_OrderInvoiceITTriggerClass.CloneOrderCommisions(Trigger.New);
    }

}