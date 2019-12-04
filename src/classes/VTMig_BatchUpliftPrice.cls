/**
 * Created by triciaigoe on 2019-11-27.
 */

global without sharing class VTMig_BatchUpliftPrice implements Database.Batchable<sObject>,Database.Stateful{

    global String query;
    global set<Id> orderIds;
    Date dateToday = system.today();
    Batch_Job__c batchJob;
    global string errorLog = null;
    string currentBatchDetails = '';
    global Id chargeId = 'a20190000008yP9';

    global VTMig_BatchUpliftPrice(String query, boolean useInternalQuery) {
        this.query = query;
        orderIds = new set<Id>();

        if(useInternalQuery == true || useInternalQuery == null) {
            this.query = 'SELECT BMS_Contract_Year__c, AnnualRentYear2__c, AnnualRentYear3__c, AnnualRentYear4__c, Net_Total__c, ' +
                    'Unit_Price_2nd_Year__c, Unit_Price_3rd_Year__c, Unit_Price_4th_Year__c, Quantity__c, Discount_Value__c, ' +
                    'Uplift__c, Uplift_Frequency__c, Price_Type__c,Order__c, Legacy_Orders__c, Next_Uplift_Date__c, ' +
                    'Unit_Price__c, Order__r.BMS_Contract_Year__c FROM Job_Rate_Plan_Charge__c ' +
                    'WHERE (Uplift__c > 0 OR Legacy_Orders__c = true) ' +
                    'AND (Service_End_Date__c = null ' +
                    'OR Service_End_Date__c >=:dateToday) ' +
                    'AND Next_Uplift_Date__c!= null ' +
                    'AND Next_Uplift_Date__c <=:dateToday';
        } else {
            this.query = query;
        }

        batchJob = new Batch_Job__c(Name = 'BatchUpliftPrice - ' + system.today(), Type__c = 'BatchUpliftPrice', Start_Date_and_Time__c = system.now(), Status__c = 'Processing');
        insert batchJob;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        SavePoint sp;
        try {
            list<Job_Rate_Plan_Charge__c> charges = scope;
            list<Job__c> ordersToUpdate = new list<Job__c>();

            currentBatchDetails = '\n' + '\n' + '\n';
            for(Job_Rate_Plan_Charge__c charge : charges) {
                currentBatchDetails = currentBatchDetails + charge.Id + '\n';
            }

            sp = DataBase.SetSavePoint();
            for(Job_Rate_Plan_Charge__c charge : charges) {
                decimal newPrice = null;
                // check if its a legacy charge
                if(charge.Legacy_Orders__c) {
                    if(charge.BMS_Contract_Year__c != null) {
                        ++charge.BMS_Contract_Year__c;

                        // just assgin the unit price, in case if the annualrentyr is null then we will use the unit price
                        newPrice = charge.Unit_Price__c;
                        if(charge.BMS_Contract_Year__c == 2) {
                            if(charge.AnnualRentYear2__c != null)
                                newPrice = charge.AnnualRentYear2__c;
                        } else if(charge.BMS_Contract_Year__c == 3) {
                            if(charge.AnnualRentYear3__c != null)
                                newPrice = charge.AnnualRentYear3__c;
                        } else if(charge.AnnualRentYear4__c != null) {
                            newPrice = charge.AnnualRentYear4__c;
                        }
                    }
                } else {
                    if(charge.Uplift__c == null)
                        charge.Uplift__c = 0;

                    if(charge.Unit_Price__c != null) {
                        newPrice = (charge.Unit_Price__c * (charge.Uplift__c/100)) + charge.Unit_Price__c;
                    }
                }

                if(newPrice != null) {
                    // update the price
                    charge.Unit_Price__c = newPrice;
                    charge.Price__c = charge.Quantity__c * charge.Unit_Price__c;
                    charge.Net_Total__c = charge.Price__c - charge.Discount_Value__c;

                    system.debug('Next_Uplift_Date__c is ' + charge.Next_Uplift_Date__c);

                    // populate the next uplift date
                    charge.Last_Uplift_Date__c = charge.Next_Uplift_Date__c;
                    charge.Next_Uplift_Date__c = charge.Next_Uplift_Date__c.addMonths(12);
                    charge.Price_Format__c = 'Default';
                    charge.BMS_Contract_Year__c = charge.BMS_Contract_Year__c;

                    system.debug('Id is ' +charge.Id+ 'Next date' +charge.Next_Uplift_Date__c);
                    system.debug('New Price is ' + charge.Unit_Price__c);

                    if(!orderIds.contains(charge.Order__c)) {
                        orderIds.add(charge.Order__c);

                        /*if(charge.Legacy_Orders__c) {
                            ordersToUpdate.add(new Job__c(Id = charge.Order__c));
                        }*/
                    }
                }
            }

            // unit price will be updated
            update charges;

            // we need to update the contract terms for legacy data
            //update ordersToUpdate;

            currentBatchDetails = '';
        } catch(exception ex) {
            system.debug('exception getMessage is : ' + ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString() );
            database.rollback(sp);

            errorLog += '\n' + 'An exception has occured, exception type is ' + ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
            errorLog += ': ' + currentBatchDetails;
        }
    }

    global void finish(Database.BatchableContext BC) {

        batchJob.Completed_Date_and_Time__c = system.now();
        if(errorLog == null) {
            batchJob.Status__c = 'Completed';
        } else {
            batchJob.Status__c = 'Completed with Errors';

            if(errorLog.Length() < 32768) {
                batchJob.Exception_Log__c = errorLog;
            } else {
                Attachment attachment = new Attachment();
                attachment.Body = Blob.valueOf(errorLog);
                attachment.Name = 'ErrorLog.txt';
                attachment.ParentId = batchJob.Id;
                insert attachment;

                batchJob.Exception_Log__c = 'Error log is attached and the same can be found attachement releated list';
            }
        }
        update batchJob;


        if(!Test.isRunningTest()) {
            VTMig_IITBatchProcessForRecalculateOrder batchProcessForRecalculateOrder = new VTMig_IITBatchProcessForRecalculateOrder(orderIds);
            Database.executeBatch(batchProcessForRecalculateOrder,1);
        }
    }

}