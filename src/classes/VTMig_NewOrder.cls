/**
 * Created by triciaigoe on 2019-11-24.
 */

public with sharing class VTMig_NewOrder {

    public String recordTypeId {get; set;}
    public String recordTypeName {get; set;}
    public Job__c order {get; set;}

    public VTMig_NewOrder(ApexPages.StandardController ctrlr){
        order = new Job__c();
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        recordTypeName = [SELECT Name FROM RecordType WHERE Id = : recordTypeId].Name;
    }

    public PageReference saveOrder(){
        insert order;
        return new PageReference('/'+order.Id);
    }

}