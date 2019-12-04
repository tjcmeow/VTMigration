/**
 * Created by triciaigoe on 2019-11-24.
 */

public with sharing class VTMig_NewOrder {

    public String recordTypeId {get; set;}
    public String recordTypeName {get; set;}
    public Job__c order {get; set;}
    public Boolean saleOrder {get; set; }
    public Boolean masterOrder {get; set; }
    public Boolean childOrder {get; set; }

    public VTMig_NewOrder(ApexPages.StandardController ctrlr){
        order = new Job__c();
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        recordTypeName = [SELECT Name FROM RecordType WHERE Id = : recordTypeId].Name;
        if(recordTypeName == 'Sale Order') {
            saleOrder = true;
        } else if(recordTypeName == 'Master Order') {
            masterOrder = true;
        } else if(recordTypeName == 'Child Order') {
            childOrder = true;
        }
    }

    public PageReference saveOrder(){
        order.RecordTypeId = recordTypeId;
        insert order;
        return new PageReference('/'+order.Id);
    }

}