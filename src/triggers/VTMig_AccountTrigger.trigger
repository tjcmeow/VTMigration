/**
 * Created by triciaigoe on 2019-12-31.
 */

trigger VTMig_AccountTrigger on Account (before delete, before update, before insert) {

    if(Trigger.isDelete && Trigger.isBefore) {
        VTMig_AccountTriggerHelper.beforeDeleteProspect(Trigger.oldMap);
    } else if(Trigger.isBefore) {
        VTMig_AccountTriggerHelper.beforeUpdateInsert(Trigger.new);
    }

}