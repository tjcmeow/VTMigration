/**
 * Created by triciaigoe on 2019-11-25.
 */

trigger VTMig_OrderInvoiceITTrigger on Job__c (before update, before insert, after update,after insert,before delete) {

    if(Trigger.isBefore && Trigger.isDelete) {
        VTMig_OrderInvoiceITTriggerClass.beforeDeleteCheckRecord(Trigger.oldMap);
    }

    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        VTMig_OrderInvoiceITTriggerClass.beforeInsertUpdate(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        VTMig_OrderInvoiceITTriggerClass.beforeUpdate(Trigger.newMap,Trigger.oldMap);
    }

    if(Trigger.isUpdate){
        VTMig_OrderInvoiceITTriggerClass.ExecuteUpdateEvents(Trigger.new,Trigger.newMap,Trigger.oldMap);
    }

    if(trigger.isInsert  &&  VTMig_OrderInvoiceITTriggerClass.dontRunAgain && trigger.isAfter){
        VTMig_OrderInvoiceITTriggerClass.dontRunAgain = false;
        VTMig_OrderInvoiceITTriggerClass.CloneOrderCommisions(Trigger.New);
    }

}