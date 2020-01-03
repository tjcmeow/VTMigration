/**
 * Created by triciaigoe on 2020-01-02.
 */

trigger VTMig_AttachmentTrigger on Attachment (after insert) {

    if(Trigger.isAfter && Trigger.isInsert) {
        VTMig_AttachmentTriggerHandler.updateContactAddendum(Trigger.newMap);
    }

}