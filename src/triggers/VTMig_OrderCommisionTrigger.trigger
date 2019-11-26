trigger VTMig_OrderCommisionTrigger on Order_Commissions__c (before insert,before update) {
    //Auto Populate CommisionRate Values
    if(Trigger.IsUpdate){
        VTMig_OrderCommisionTriggerHandler.AutoPopulateCommisionValues(Trigger.New,Trigger.NewMap,Trigger.OldMap,'Update');
    }
    
    if(Trigger.IsInsert){
        VTMig_OrderCommisionTriggerHandler.AutoPopulateCommisionValues(Trigger.New,Trigger.NewMap,null,'Insert');
    } 
}