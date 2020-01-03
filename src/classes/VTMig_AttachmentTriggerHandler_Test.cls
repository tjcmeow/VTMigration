/**
 * Created by triciaigoe on 2020-01-02.
 */
@IsTest
public with sharing class VTMig_AttachmentTriggerHandler_Test {

    @IsTest
    public static void testAttachment(){

        Account acc = VTMig_TestUtilities.createKVCustomer();
        insert acc;

        Job__c order = VTMig_TestUtilities.createMasterOrder(acc.Id);
        insert order;

        Contract_Addendum__c contractAddendum = new Contract_Addendum__c();
        contractAddendum.Order__c = order.Id;
        insert contractAddendum;

        List<Attachment> attachments = new List<Attachment>();
        Attachment newAttachment = new Attachment();
        newAttachment.ParentId = contractAddendum.Id;
        newAttachment.Body = Blob.valueOf('123');
        newAttachment.Name = '123';
        attachments.add(newAttachment);

        Attachment newAttachment2 = new Attachment();
        newAttachment2.ParentId = contractAddendum.Id;
        newAttachment2.Body = Blob.valueOf('123');
        newAttachment2.Name = '123';
        attachments.add(newAttachment2);

        insert attachments;

        Contract_Addendum__c contractAddendum2 = [SELECT Id, Attachment_Name__c FROM Contract_Addendum__c LIMIT 1];
        System.assertNotEquals(null, contractAddendum2.Attachment_Name__c);
    }

}