/**
 * Created by triciaigoe on 2019-11-25.
 */

public with sharing class VTMig_IITCommonUtilClass {

    Public static void calculateQuantity(list<Invoice_Line__c> invoiceLinesFromTrigger) {
        Invoice_Line__c newInvoiceLine;
        list<Invoice_Line__c> invoiceLines;

        list<Invoice_Line__c> invoiceLinesToInsert = new list<Invoice_Line__c>();

        invoiceLines = [SELECT BillingPeriod__c, Job_Rate_Plan_Charge__c, Service_Start_Date__c, Service_End_Date__c
                , Accounting_Code__c,Calculated_Quantity__c,Charge_Date__c,Discount_Value__c,Line_Name__c,Product__c,Product_Name__c,Product_Rate_Plan_Charge__c,Quantity__c,RevenueRecognitionRuleNew__c,Status__c,Unit_of_Measurement__c
                , Invoice__c, Job__c,Price_Type__c
                ,Job_Rate_Plan_Charge__r.Legacy_Orders__c
                ,Job_Rate_Plan_Charge__r.Next_Uplift_Date__c
                ,Job_Rate_Plan_Charge__r.Quantity__c
                ,Job_Rate_Plan_Charge__r.Uplift__c
                ,Job_Rate_Plan_Charge__r.VAT_Percentage__c
                ,Job_Rate_Plan_Charge__r.Tax_Percentage__c
                ,Job_Rate_Plan_Charge__r.Unit_Price__c
                ,Job_Rate_Plan_Charge__r.AnnualRentYear2__c
                ,Job_Rate_Plan_Charge__r.AnnualRentYear3__c
                ,Job_Rate_Plan_Charge__r.AnnualRentYear4__c
                ,Job_Rate_Plan_Charge__r.Price_Type__c
                ,Job_Rate_Plan_Charge__r.Order__r.BMS_Contract_Year__c
                ,Job_Rate_Plan_Charge__r.BMS_Contract_Year__c
        FROM Invoice_Line__c
        WHERE Id In : invoiceLinesFromTrigger];

        for(Invoice_Line__c invoiceLine : invoiceLines) {
            if(invoiceLine.Service_Start_Date__c <= invoiceLine.Job_Rate_Plan_Charge__r.Next_Uplift_Date__c
                    &&
                    invoiceLine.Job_Rate_Plan_Charge__r.Next_Uplift_Date__c <= invoiceLine.Service_End_Date__c
                    )
            {
                string priceType = invoiceLine.Job_Rate_Plan_Charge__r.Price_Type__c;
                // just initialize the value same as unit price, some times legacy data may be null
                decimal upliftPrice = invoiceLine.Job_Rate_Plan_Charge__r.Unit_Price__c;
                invoiceLine.Split_Invoice__c = true;
                if(invoiceLine.Job_Rate_Plan_Charge__r.Legacy_Orders__c) {
                    decimal contractYr = invoiceLine.Job_Rate_Plan_Charge__r.BMS_Contract_Year__c;

                    if(contractYr != null) {
                        ++contractYr;

                        if(contractYr == 2) {
                            if(invoiceLine.Job_Rate_Plan_Charge__r.AnnualRentYear2__c != null)
                                upliftPrice = invoiceLine.Job_Rate_Plan_Charge__r.AnnualRentYear2__c;
                        } else if(contractYr == 3) {
                            if(invoiceLine.Job_Rate_Plan_Charge__r.AnnualRentYear3__c != null)
                                upliftPrice = invoiceLine.Job_Rate_Plan_Charge__r.AnnualRentYear3__c;
                        } else {
                            if(invoiceLine.Job_Rate_Plan_Charge__r.AnnualRentYear4__c != null)
                                upliftPrice = invoiceLine.Job_Rate_Plan_Charge__r.AnnualRentYear4__c;
                        }
                    }

                } else {
                    system.debug('Uplift percentage ' + invoiceLine.Job_Rate_Plan_Charge__r.Uplift__c);
                    if(invoiceLine.Job_Rate_Plan_Charge__r.Uplift__c == null)
                        invoiceLine.Job_Rate_Plan_Charge__r.Uplift__c = 0;

                    upliftPrice = invoiceLine.Job_Rate_Plan_Charge__r.Unit_Price__c + ((invoiceLine.Job_Rate_Plan_Charge__r.Uplift__c/100) * invoiceLine.Job_Rate_Plan_Charge__r.Unit_Price__c);
                    system.debug('Uplift percentage ' + upliftPrice);
                }

                // if uplift and unit price are same then we should not create two lines
                if(upliftPrice == invoiceLine.Job_Rate_Plan_Charge__r.Unit_Price__c) {
                    system.debug('both prices are same, so correction needed');

                    return;
                }

                // before you clone divide the discount by two
                if(invoiceLine.Discount_Value__c != null && invoiceLine.Discount_Value__c > 0) {
                    invoiceLine.Discount_Value__c = invoiceLine.Discount_Value__c/2;
                }

                system.debug('condition is true');
                newInvoiceLine = invoiceLine.clone();
                newInvoiceLine.Service_Start_Date__c = invoiceLine.Job_Rate_Plan_Charge__r.Next_Uplift_Date__c;
                newInvoiceLine.Service_End_Date__c = invoiceLine.Service_End_Date__c;
                newInvoiceLine.Sequence_No__c = 2;
                newInvoiceLine.Split_Invoice__c = true;
                //below line added by ram from steelbrick case # : 00013661 
                newInvoiceLine.Price_Type__c = invoiceLine.Job_Rate_Plan_Charge__r.Price_Type__c;
                //newInvoiceLine.Price_Type__c = invoiceLine.Job_Rate_Plan_Charge__r.Price_Type__c;BillingPeriod__c
                // call the util methods, which will return on how many months it should charge
                decimal noOfMonths = VTMig_IITCommonUtilClass.calculateDiffBetweenDatesInMonths( newInvoiceLine.Service_Start_Date__c,
                        newInvoiceLine.Service_End_Date__c.addDays(1),
                        priceType
                );
                system.debug('ipriceType ' + priceType);
                decimal newUnitPrice;
                if(priceType == 'Half Yearly') {
                    newUnitPrice = noOfMonths * (upliftPrice/6);
                    newInvoiceLine.Calculated_Quantity__c = (noOfMonths/6.0);
                } else if(priceType == 'Annual') {
                    newUnitPrice = noOfMonths * (upliftPrice/12);
                    newInvoiceLine.Calculated_Quantity__c = (noOfMonths/12.0);
                }

                system.debug('upliftPrice ' + upliftPrice);
                system.debug('newUnitPrice ' + newUnitPrice);
                newInvoiceLine.Unit_Price__c = upliftPrice;
                newInvoiceLine.Line_Amount__c = newUnitPrice * newInvoiceLine.Quantity__c;

                if(newInvoiceLine.Discount_Value__c == null) {
                    newInvoiceLine.Discount_Value__c = 0;
                }
                decimal netTotal = newInvoiceLine.Line_Amount__c - newInvoiceLine.Discount_Value__c;
                if(invoiceLine.Job_Rate_Plan_Charge__r.Tax_Percentage__c != null && invoiceLine.Job_Rate_Plan_Charge__r.Tax_Percentage__c > 0) {
                    newInvoiceLine.Tax__c = (netTotal/((100 - invoiceLine.Job_Rate_Plan_Charge__r.Tax_Percentage__c)/100) - netTotal);
                }

                if(invoiceLine.Job_Rate_Plan_Charge__r.VAT_Percentage__c != null && invoiceLine.Job_Rate_Plan_Charge__r.VAT_Percentage__c > 0) {
                    newInvoiceLine.VAT__c = (netTotal*invoiceLine.Job_Rate_Plan_Charge__r.VAT_Percentage__c/100);
                }


                invoiceLine.Service_End_Date__c =  invoiceLine.Job_Rate_Plan_Charge__r.Next_Uplift_Date__c.addDays(-1);
                noOfMonths = VTMig_IITCommonUtilClass.calculateDiffBetweenDatesInMonths( invoiceLine.Service_Start_Date__c,
                        invoiceLine.Service_End_Date__c.addDays(1),
                        priceType
                );

                if(priceType  == 'Half Yearly') {
                    newUnitPrice = noOfMonths * (invoiceLine.Job_Rate_Plan_Charge__r.Unit_Price__c/6);
                    invoiceLine.Calculated_Quantity__c = (noOfMonths/6.0);

                } else if(priceType == 'Annual') {
                    newUnitPrice = noOfMonths * (invoiceLine.Job_Rate_Plan_Charge__r.Unit_Price__c/12);
                    invoiceLine.Calculated_Quantity__c = (noOfMonths/12.0);
                }
                invoiceLine.Line_Amount__c = newUnitPrice * newInvoiceLine.Quantity__c;


                netTotal = invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c;
                if(invoiceLine.Job_Rate_Plan_Charge__r.Tax_Percentage__c != null && invoiceLine.Job_Rate_Plan_Charge__r.Tax_Percentage__c > 0) {
                    invoiceLine.Tax__c = (netTotal/((100 - invoiceLine.Job_Rate_Plan_Charge__r.Tax_Percentage__c)/100) - netTotal);
                }
                if(invoiceLine.Job_Rate_Plan_Charge__r.VAT_Percentage__c != null && invoiceLine.Job_Rate_Plan_Charge__r.VAT_Percentage__c > 0) {
                    invoiceLine.VAT__c = (netTotal*invoiceLine.Job_Rate_Plan_Charge__r.VAT_Percentage__c/100);
                }
                //rounding up the value upto two decimal points
                if(invoiceLine.Line_Amount__c != null && invoiceLine.Line_Amount__c > 0) {
                    invoiceLine.Line_Amount__c = invoiceLine.Line_Amount__c.setScale(2);
                }
                if(invoiceLine.Discount_Value__c != null && invoiceLine.Discount_Value__c > 0) {
                    invoiceLine.Discount_Value__c = invoiceLine.Discount_Value__c.setScale(2);
                }
                if(invoiceLine.VAT__c != null && invoiceLine.VAT__c > 0) {
                    invoiceLine.VAT__c = invoiceLine.VAT__c.setScale(2);
                }
                if(invoiceLine.Tax__c != null && invoiceLine.Tax__c > 0) {
                    invoiceLine.Tax__c = invoiceLine.Tax__c.setScale(2);
                }

                invoiceLinesToInsert.add(newInvoiceLine);
                system.debug('invoiceLinesToInsert---111>'+invoiceLinesToInsert);
            }
        }

        update invoiceLines;

        insert invoiceLinesToInsert;

        system.debug('condition is false');

    }

    public static decimal calculateDiffBetweenDatesInMonths(date calculationStartDate, date calculationEndDate, String priceType) {
        decimal noOfMonthsComputed = 0;
        decimal noOfDaysComputed = 0;
        decimal noOfTimesCharge = 0;

        Decimal noOfMonths = calculationStartDate.monthsBetween(calculationEndDate);
        // as a industry standard, we need to bill prorated days as days/30 days
        Decimal daysInAMonth = 30.0;
        system.debug('No of months initially == ' + noOfMonths);

        // just verify the dates by adding the noOfMonths
        // If dates are equal then 100%, we need to charges for noOfMonths
        // If dates are not equal then we need to calculate for how many extra days we need to compute i.e (noOfMonths - 1) + ExtraDays
        if(calculationStartDate.addMonths(Integer.ValueOf(noOfMonths)) == calculationEndDate) {
            noOfMonthsComputed = noOfMonths;
            noOfDaysComputed = 0;

            noOfTimesCharge = noOfMonths;

            system.debug('No of months == ' + noOfMonthsComputed);
            system.debug('No of days == ' + noOfDaysComputed);
            system.debug('noOfMonths  Value Laxman == ' + noOfTimesCharge);

            //return noOfTimesCharge;
        } else {
            noOfMonthsComputed = noOfMonths - 1;
            date removedComputedMonths = calculationStartDate.addMonths(integer.ValueOf(noOfMonthsComputed));
            Decimal remainingDays = removedComputedMonths.daysBetween(calculationEndDate);
            noOfDaysComputed = remainingDays;

            system.debug('noOfMonthsComputed is ' + noOfMonthsComputed);
            system.debug('removedComputedMonths is  ' + removedComputedMonths);
            system.debug('remainingDays is ' + remainingDays);


            // Some time remaning day might be greather than 30+ when noOfMonths is not calculated properly
            if(remainingDays > 28) {
                date oneMonthFront = removedComputedMonths.addMonths(1);
                ++noOfMonthsComputed;
                remainingDays = oneMonthFront.daysBetween(calculationEndDate);
            }

            if(noOfMonthsComputed <= 0) {
                // this is for calculations like : (five days) or (three days)
                //noOfMonths = remainingDays.Divide(daysInStartMonth, 3, System.RoundingMode.UP);
                noOfMonths = (remainingDays/daysInAMonth);
                system.debug('noOfMonths is ==== see this ====1 ' + noOfMonths);

            } else {
                // use the endDate Month for calculating the remanining days
                // subtract one day since both days are included
                system.debug('I am in prorated more than a month, subtracting one day');
                //remainingDays = remainingDays - 1;
                noOfMonths = noOfMonthsComputed + (remainingDays/daysInAMonth);
                system.debug('new calculations noOfMonths is ==== see this ====2 ' + noOfMonths);
            }
        }

        system.debug('final noOfMonths == ' + noOfMonths);

        return noOfMonths;
    }
}