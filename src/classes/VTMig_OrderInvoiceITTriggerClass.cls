/**
 * Created by triciaigoe on 2019-11-24.
 */

public with sharing class VTMig_OrderInvoiceITTriggerClass {

    Public Static Boolean dontRunAgain = true;

    Public static void ExecuteUpdateEvents(List<Job__c> invoiceOrderJob,Map<ID,Job__c> newInvoiceJobs,Map<ID,Job__c> oldInvoiceJobs){

        Set<ID> vodOrderProducts         = New Set<ID>();
        Set<ID> caseVODOrder             = new Set<ID>();
        Set<ID> webOrderProducts         = New Set<ID>();

        //following variable used for creating Commision Dealer
        Map<ID,List<ID>> invoicejobsITProducts = New Map<ID,List<ID>>();

        List<Job_Product__c> invoiceITOrderProduct = [SELECT ID,NAME,Job__c,Product__c FROM Job_Product__c WHERE Job__c=:newInvoiceJobs.keySet()];
        for(Job_Product__c validateVODName:invoiceITOrderProduct){
            String Orderstatus = validateVODName.Name;
            if(Orderstatus.contains('VOD')){
                vodOrderProducts.add(validateVODName.Job__c);
            }
            if(Orderstatus.contains('webFTA') || Orderstatus.contains('webFSA')){
                webOrderProducts.add(validateVODName.Job__c);
            }
            //Commision Delear Requirement
            if(invoicejobsITProducts.containsKey(validateVODName.Job__c)) {
                list<Id> ItProductsIds = invoicejobsITProducts.get(validateVODName.Job__c);
                ItProductsIds.add(validateVODName.Product__c);
                invoicejobsITProducts.put(validateVODName.Job__c, ItProductsIds);
            } else {
                invoicejobsITProducts.put(validateVODName.Job__c, new list<Id> { validateVODName.Product__c});
            }
        }

        LIST<Case> findVODservice = [SELECT id,Order__c FROM CASE WHERE (Order__c=:vodOrderProducts AND Case_Symptom__c =:'New VOD Order')];
        for(Case validateVod:findVODservice){
            caseVODOrder.add(validateVod.Order__c);
        }

        List<Case> vodCases = New List<Case>();
        List<Task> taskCreation = New List<Task>();

        List<Messaging.SingleEmailMessage> caseEmails = New List<Messaging.SingleEmailMessage>();
        for(Job__c iotJob:invoiceOrderJob){
            if(iotJob.Status__c == 'Ready for Fulfillment' && vodOrderProducts.contains(iotJob.id) && !caseVODOrder.contains(iotJob.id)){
                Case newVODCase = New Case();
                newVODCase.Subject = 'New VOD Order';
                //newVODCase.Product_or_Service__c = 'VOD'; 
                newVODCase.Product_or_Service_Detail__c = 'VOD Order';
                newVODCase.Type = 'Add or change a Video / Training Service';
                newVODCase.Order__c = iotJob.id;
                newVODCase.Case_Symptom__c = 'New VOD Order';
                newVODCase.Status = 'New';
                newVODCase.Origin = 'Web';
                newVODCase.RecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KV Production Support').getRecordTypeId();
                newVODCase.AccountId = iotJob.Account__c;
                newVODCase.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'VOD Production Team'].Id;
                newVODCase.Platform_Asset_Account__c = iotJob.Shipping_Account__c;
                vodCases.add(newVODCase);
            }

            if(iotJob.Status__c == 'Ready for Fulfillment' && (newInvoiceJobs.get(iotJob.id).Status__c!=oldInvoiceJobs.get(iotJob.id).Status__c) && webOrderProducts.contains(iotJob.id)){
                Task t = new Task();
                t.OwnerId = system.label.Jon_Buttler_UserID;
                t.Subject = 'Provision webFSA / webFTA - Reference Order';
                t.Status = 'Open';
                t.Priority = 'High';
                t.ActivityDate = system.today()+2;
                t.WhatId = iotJob.id;
                taskCreation.add(t);
            }
        }

        if(vodCases.size()>0){
            insert vodCases;
        }

        if(taskCreation.size()>0){
            insert taskCreation;
        }
        //Commision Dealer Creation
        if(dontRunAgain){
            dontRunAgain = false;
            CommisionDealerCreationMethod(invoiceOrderJob,newInvoiceJobs,oldInvoiceJobs,invoicejobsITProducts);
        }
        List<Job__c> ordersToRecalc = new List<Job__c>();
        for(Job__c order : oldInvoiceJobs.values()){

            if(order.Recalculate__c != newInvoiceJobs.get(order.Id).Recalculate__c && newInvoiceJobs.get(order.Id).Recalculate__c) {
                ordersToRecalc.add(order);
            }
        }

        if(ordersToRecalc.size() > 0) {
            recalcOrder(ordersToRecalc);
        }
    }

    public static void CommisionDealerCreationMethod(List<Job__c> invoiceOrderJob,Map<ID,Job__c> newInvoiceJobs,Map<ID,Job__c> oldInvoiceJobs,Map<ID,list<ID>> invoicejobsITProducts){

        List<Id> partnerIds = New List<Id>();
        Set<ID> cloneMasterIds = New Set<ID>();

        Map<ID,Map<ID,Partner_Commission_Rates__c>> ProductPcrs = New Map<ID,Map<ID,Partner_Commission_Rates__c>>();
        for(Job__c invoiceJobsCommisionCreation:invoiceOrderJob){
            if(invoiceJobsCommisionCreation.Partner__c!=null){
                partnerIds.add(invoiceJobsCommisionCreation.Partner__c);
            }
            if(invoiceJobsCommisionCreation.Master_Order__c!=null && invoiceJobsCommisionCreation.recordTypeID==Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Child Order').getRecordTypeId()){
                cloneMasterIds.add(invoiceJobsCommisionCreation.Master_Order__c);
            }
        }
        Map<Id,Partner_Commission_Rates__c> salesOrderType = New Map<Id,Partner_Commission_Rates__c>();

        List<Partner_Commission_Rates__c> PCR = [Select Id,Commission_Type__c,Partner_Agent_Account__c,Product__c,Standard_Comm__c,Year1_Commission__c FROM Partner_Commission_Rates__c WHERE (Partner_Agent_Account__c=:partnerIds)];
        for(Partner_Commission_Rates__c pcrProducts:PCR){
            if(ProductPcrs.containsKey(pcrProducts.Partner_Agent_Account__c)) {
                Map<Id,Partner_Commission_Rates__c> exitsPcr = ProductPcrs.get(pcrProducts.Partner_Agent_Account__c);
                exitsPcr.put(pcrProducts.Product__c,pcrProducts);
                ProductPcrs.put(pcrProducts.Partner_Agent_Account__c,exitsPcr);
            }else{
                ProductPcrs.put(pcrProducts.Partner_Agent_Account__c,new Map<Id,Partner_Commission_Rates__c>{pcrProducts.Product__c => pcrProducts});
            }
            if(pcrProducts.Commission_Type__c == 'Sale'){
                salesOrderType.put(pcrProducts.Partner_Agent_Account__c,pcrProducts);
            }
        }
        Map<ID,ID> validateProductExits = new Map<ID,ID>();
        set<ID> salesAgentsIds = New set<ID>();
        List<Order_Commissions__c> exitsOC = [Select Id,Order_for_Commission__c,Order_Product__c,Sales_Agent__c From Order_Commissions__c WHERE (Order_for_Commission__c=:newInvoiceJobs.keyset() OR Order_for_Commission__c=:cloneMasterIds)];
        for(Order_Commissions__c oc:exitsOC){
            validateProductExits.put(oc.Order_for_Commission__c,oc.Order_Product__c);
            salesAgentsIds.add(oc.Sales_Agent__c);
        }

        List<Order_Commissions__c> orderCommisions = New List<Order_Commissions__c>();
        for(Job__c invoiceJobsCommisionCreation:invoiceOrderJob){
            if(invoiceJobsCommisionCreation.recordTypeID==Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Master Order').getRecordTypeId() || invoiceJobsCommisionCreation.recordTypeID==Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Child Order').getRecordTypeId()){
                if(invoiceJobsCommisionCreation.Partner__c!=null){
                    if(ProductPcrs.containsKey(invoiceJobsCommisionCreation.Partner__c)){
                        Map<ID,Partner_Commission_Rates__c> showPCRData = ProductPcrs.get(invoiceJobsCommisionCreation.Partner__c);
                        if(invoicejobsITProducts.containsKey(invoiceJobsCommisionCreation.id)){
                            List<Id> productIds = invoicejobsITProducts.get(invoiceJobsCommisionCreation.id);
                            Set<String> salesAgentPartner = New Set<String>();

                            for(integer i=0;i<productIds.size();i++){
                                if(showPCRData.containsKey(productIds[i])){
                                    if(!validateProductExits.containsKey(invoiceJobsCommisionCreation.id)){
                                        if(validateProductExits.get(invoiceJobsCommisionCreation.id)!=productIds[i]){
                                            salesAgentPartner.add(showPCRData.get(productIds[i]).Partner_Agent_Account__c+'-'+productIds[i]+'-'+invoiceJobsCommisionCreation.Id);
                                            Order_Commissions__c oc = New Order_Commissions__c();
                                            oc.Order_for_Commission__c = invoiceJobsCommisionCreation.Id;
                                            oc.Sales_Agent__c    = showPCRData.get(productIds[i]).Partner_Agent_Account__c;
                                            oc.Order_Product__c = productIds[i];
                                            oc.Subsequent_Years_Commission_Rate__c  = showPCRData.get(productIds[i]).Standard_Comm__c;
                                            oc.Year1_Commission__c  = showPCRData.get(productIds[i]).Year1_Commission__c;
                                            orderCommisions.add(oc);
                                        }
                                    }
                                    if((newInvoiceJobs.get(invoiceJobsCommisionCreation.id).Partner__c!=oldInvoiceJobs.get(invoiceJobsCommisionCreation.id).Partner__c)&& !salesAgentPartner.contains(showPCRData.get(productIds[i]).Partner_Agent_Account__c+'-'+productIds[i]+'-'+invoiceJobsCommisionCreation.Id)){

                                        Order_Commissions__c oc = New Order_Commissions__c();
                                        oc.Order_for_Commission__c = invoiceJobsCommisionCreation.Id;
                                        oc.Sales_Agent__c    = showPCRData.get(productIds[i]).Partner_Agent_Account__c;
                                        oc.Order_Product__c = productIds[i];
                                        oc.Subsequent_Years_Commission_Rate__c  = showPCRData.get(productIds[i]).Standard_Comm__c;
                                        oc.Year1_Commission__c  = showPCRData.get(productIds[i]).Year1_Commission__c;
                                        orderCommisions.add(oc);
                                    }
                                }
                            }
                        }
                    }
                }
            }else
            {
                if(invoiceJobsCommisionCreation.recordTypeID==Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Sale Order').getRecordTypeId()){
                    if(!salesAgentsIds.contains(invoiceJobsCommisionCreation.Partner__c)){
                        if(salesOrderType.containsKey(invoiceJobsCommisionCreation.Partner__c)){
                            Order_Commissions__c oc = New Order_Commissions__c();
                            oc.Order_for_Commission__c = invoiceJobsCommisionCreation.Id;
                            oc.Sales_Agent__c    = salesOrderType.get(invoiceJobsCommisionCreation.Partner__c).Partner_Agent_Account__c;
                            oc.Order_Product__c = salesOrderType.get(invoiceJobsCommisionCreation.Partner__c).Product__c;
                            oc.Subsequent_Years_Commission_Rate__c  = salesOrderType.get(invoiceJobsCommisionCreation.Partner__c).Standard_Comm__c;
                            oc.Year1_Commission__c  = salesOrderType.get(invoiceJobsCommisionCreation.Partner__c).Year1_Commission__c;
                            orderCommisions.add(oc);
                        }
                    }
                }
            }
        }
        if(orderCommisions.size()>0){
            try{
                insert orderCommisions;
            }Catch(Exception e){
                //throw e;
            }
        }
    }

    Public static void CloneOrderCommisions(List<Job__c> invoiceOrderJob){

        Set<ID> cloneMasterIds = New Set<ID>();
        Map<ID,List<ID>> childOrderIds = New Map<ID,List<ID>>();

        for(Job__c orderCommisionCreation:invoiceOrderJob){
            if(orderCommisionCreation.Master_Order__c!=null && orderCommisionCreation.recordTypeID==Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Child Order').getRecordTypeId()){
                cloneMasterIds.add(orderCommisionCreation.Master_Order__c);

                if(childOrderIds.containsKey(orderCommisionCreation.Master_Order__c)) {
                    list<Id> masterOrderIds = childOrderIds.get(orderCommisionCreation.Master_Order__c);
                    masterOrderIds.add(orderCommisionCreation.Id);
                    childOrderIds.put(orderCommisionCreation.Master_Order__c, masterOrderIds);
                } else {
                    childOrderIds.put(orderCommisionCreation.Master_Order__c, new list<Id> {orderCommisionCreation.Id});
                }
            }
        }


        List<Order_Commissions__c> exitsOC = [Select Id,Custom_Order_Commissions__c,Year1_Commission__c,Subsequent_Years_Commission_Rate__c,Order_for_Commission__c,Order_Product__c,Sales_Agent__c From Order_Commissions__c WHERE Order_for_Commission__c=:cloneMasterIds];

        List<Order_Commissions__c> ClonedRecords = new List<Order_Commissions__c>();
        set<String> uniqueCode = New set<String>();

        for(Order_Commissions__c updateChildIds:exitsOC){
            if(childOrderIds.containsKey(updateChildIds.Order_for_Commission__c)){
                for(ID childOrder:childOrderIds.get(updateChildIds.Order_for_Commission__c)){
                    if(!uniqueCode.contains(updateChildIds.Order_for_Commission__c+'-'+updateChildIds.Order_Product__c+'-'+updateChildIds.Sales_Agent__c)){
                        Order_Commissions__c cloneNew = updateChildIds.clone();
                        cloneNew.Order_for_Commission__c = childOrder;
                        ClonedRecords.add(cloneNew);
                        uniqueCode.add(updateChildIds.Order_for_Commission__c+'-'+updateChildIds.Order_Product__c+'-'+updateChildIds.Sales_Agent__c);
                    }
                }
            }
        }
        if(ClonedRecords.size()>0)
            insert ClonedRecords;
    }

    public static void recalcOrder(List<Job__c> orders) {

        List<Id> orderIds = new List<Id>();
        Map<Id, Job__c> orderMap = new Map<Id, Job__c>();
        for(Job__c order : orders) {
            orderIds.add(order.Id);
            orderMap.put(order.Id, order);
        }

        List<Job_Rate_Plan_Charge__c> orpcs = [
                SELECT Quantity__c, Unit_Price__c, Row_Total__c, Id, Order__c, Price__c, Discount_Value__c,
                        Net_Total__c, VAT__c, Tax__c
                FROM Job_Rate_Plan_Charge__c WHERE Order__c IN : orderIds
        ];

        Map<Id, List<Job_Rate_Plan_Charge__c>> orpcMap = new Map<Id, List<Job_Rate_Plan_Charge__c>>();

        for(Job_Rate_Plan_Charge__c orpc: orpcs) {
            List<Job_Rate_Plan_Charge__c> tempCharges = new List<Job_Rate_Plan_Charge__c>();
            if(orpcMap.keySet().contains(orpc.Order__c)) {
                tempCharges = orpcMap.get(orpc.Order__c);
            }
            tempCharges.add(orpc);
            orpcMap.put(orpc.Order__c, tempCharges);
        }

        for(Job__c order : orders) {

            List<Job_Rate_Plan_Charge__c> charges = new List<Job_Rate_Plan_Charge__c>();
            Decimal total = 0;
            Decimal discount = 0;
            Decimal vat = 0;
            Decimal tax = 0;
            Decimal subtotal = 0;
            Decimal netTotal = 0;

            if(orpcMap.keySet().contains(order.Id)) {
                charges = orpcMap.get(order.Id);
                for(Job_Rate_Plan_Charge__c charge : charges) {
                    if(charge.Row_Total__c != null) {
                        total += charge.Row_Total__c;
                    }
                    if(charge.Discount_Value__c != null) {
                        discount += charge.Discount_Value__c;
                    }
                    if(charge.VAT__c != null) {
                        vat += charge.VAT__c;
                    }
                    if(charge.Tax__c != null) {
                        tax += charge.Tax__c;
                    }
                    if(charge.Price__c != null) {
                        subtotal += charge.Price__c;
                    }
                    if(charge.Net_Total__c != null) {
                        netTotal += charge.Net_Total__c;
                    }
                }
            }

            order.Net_Total__c = netTotal;
            order.Sub_total__c = subtotal;
            order.VAT__c = vat;
            order.Tax__c = tax;
            order.Discount_Value__c = discount;
            order.Total__c = total;
            order.Recalculate__c = false;
        }

        update orders;
    }
}