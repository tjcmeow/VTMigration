/**
 * Created by triciaigoe on 2020-01-02.
 */

public without sharing class VTMig_AttachmentTriggerHandler {

    public static void updateContactAddendum(Map<Id, Attachment> theAttachmentMap){

        List<Attachment> attachments = [
                SELECT Id, Parent.Type, ParentId, Name
                FROM Attachment
                WHERE Id IN : theAttachmentMap.keySet()
                ORDER BY CreatedDate DESC
        ];
        System.debug(attachments);
        Map<Id, List<Attachment>> contractAttachmentMap = new Map<Id, List<Attachment>>();

        for(Attachment theAttachment : attachments) {
            if(theAttachment.Parent.Type == 'Contract_Addendum__c') {
                List<Attachment> tempAttachments = new List<Attachment>();
                if(contractAttachmentMap.keySet().contains(theAttachment.ParentId)) {
                    tempAttachments = contractAttachmentMap.get(theAttachment.ParentId);
                }
                tempAttachments.add(theAttachment);
                System.debug(theAttachment);
                contractAttachmentMap.put(theAttachment.ParentId, tempAttachments);
            }
        }

        if(contractAttachmentMap.size() > 0) {

            List<Contract_Addendum__c> contractAddenda = [
                    SELECT Id, Attachment_Name__c
                    FROM Contract_Addendum__c
                    WHERE Id IN: contractAttachmentMap.keySet()
            ];
            Map<Id, Contract_Addendum__c> contractAddendumMap = new Map<Id, Contract_Addendum__c>();

            for(Contract_Addendum__c contractAddendum : contractAddenda) {
                contractAddendumMap.put(contractAddendum.Id, contractAddendum);
            }

            List<Contract_Addendum__c> contractsToUpdate = new List<Contract_Addendum__c>();
            for(Id parent : contractAttachmentMap.keySet()) {
                String filename = '';
                List<Attachment> theAttachments = contractAttachmentMap.get(parent);
                System.debug(theAttachments);
                for(Integer i = 0; i < theAttachments.size(); i++) {
                    filename += theAttachments[i].Name;
                    System.debug(filename);
                    if(!(theAttachments.size() - 1 == i)) {
                        filename += ', ';
                    }
                }
                System.debug(filename);

                // Grab the contract addemdum to update
                Contract_Addendum__c theContractAddendum = contractAddendumMap.get(parent);
                if(String.isBlank(theContractAddendum.Attachment_Name__c)) {
                    theContractAddendum.Attachment_Name__c = filename;
                } else {
                    theContractAddendum.Attachment_Name__c = theContractAddendum.Attachment_Name__c + ', ' + filename;
                }
                System.debug(theContractAddendum);
                contractsToUpdate.add(theContractAddendum);
            }
            System.debug(contractsToUpdate);
            update contractsToUpdate;
        }
    }
}