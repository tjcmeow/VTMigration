/**
 * Created by tricia on 10/24/2019.
 */

public with sharing class VTMig_ProductSelection_Extension {

    public Id OppId {get; set;}
    public Opportunity Opp {get; set;}
    public String prodSearchText {get; set;}
    public List<Product__c> ProductList {get; set;}
    public String selectedProductId {get; set;}
    public String selectedPlanId {get; set;}
    public String selectedChargeId {get; set;}
    public Integer removeChargeId {get; set;}
    public Integer highestInteger {get;set;}
    public Decimal overallDiscount {get;set;}
    public Decimal grandTotal {get;set;}
    public Product_Rate_Plan_Charge__c selectedCharge {get; set;}
    public List<Product_Rate_Plan__c> plans {get; set;}
    public List<ProdCharge> prodCharges {get; set;}
    public Boolean showProducts {get; set;}
    public Boolean showPlans {get; set;}
    public Boolean showCharges {get; set;}
    public Boolean showChosenCharges {get; set;}
    public String pageStep {get; set;}
    public List<OppCharge> selectedCharges {get;set;}
    public List<OppCharge> removedCharges {get; set;}
    public List<ProdCharge> selectedProdCharges {get;set;}
    public OppCharge currentOppCharge {get; set;}

    public VTMig_ProductSelection_Extension(ApexPages.StandardController ctrlr){
        highestInteger = 0;
        OppId = ApexPages.currentPage().getParameters().get('Id');
        selectedCharges = new List<OppCharge>();
        prodCharges = new List<ProdCharge>();
        ProductList = new List<Product__c>();
        selectedProdCharges = new List<ProdCharge>();
        showProducts = false;
        showPlans = false;
        showCharges = false;
        pageStep = '1';
        grandTotal = 0;
        removedCharges = new List<OppCharge>();
        Opp = [
                SELECT Name, AccountId, Wet_or_Dry_Cargo__c, Partner_Agent_Account__c, Platform_or_Vessel_Detail__c, Shipping_Account__c,
                        Shipping_Contact__c, Partner_Agent__c, IITIntended_Use__c, Legal_Entity__c, Discount_Percent__c,
                        VAT__c, Tax__c
                FROM Opportunity WHERE Id = : OppId
        ];

        if(Opp.Discount_Percent__c != null) {
            overallDiscount = Opp.Discount_Percent__c;
        } else {
            overallDiscount = 0;
        }

        List<Opportunity_Rate_Plan_Charge__c> currentCharges = [
                SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Opportunity_Rate_Plan__r.Opportunity_Product__r.Name,
                        Opportunity_Rate_Plan__r.Opportunity_Product__r.Product__c, Product_Rate_Plan_Charge__c, Product_Rate_Plan_Charge__r.Product_Rate_Plan__r.Product__r.Name,
                        Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Model__c, Unit_Price__c, Uplift__c, Net_Total__c,
                        Quantity__c, Opportunity_Rate_Plan__r.Opportunity_Product__r.Product_Code__c, Opportunity_Rate_Plan__r.Product_Rate_Plan__c,
                        Product_Rate_Plan_Charge__r.Product_Rate_Plan__r.Product__r.Product_Code__c, Discount_Percent__c, Price__c, Discount_Value__c
                FROM Opportunity_Rate_Plan_Charge__c WHERE Opportunity__c = : OppId
        ];
        if(currentCharges.size() > 0) {
            for(Opportunity_Rate_Plan_Charge__c currentCharge : currentCharges) {
                OppCharge newCharge = new OppCharge();
                newCharge.indexInteger = highestInteger;
                highestInteger++;
                newCharge.chargeId  = currentCharge.Id;
                newCharge.opportunityRatePlanCharge = currentCharge;
                newCharge.productName = currentCharge.Product_Rate_Plan_Charge__r.Product_Rate_Plan__r.Product__r.Name;

                ProdCharge singleProdCharge = new ProdCharge();
                singleProdCharge.prodCharge = [
                        SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Product_Rate_Plan__r.Product__r.Name,
                                Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Format__c, Unit_Price__c,
                                Product_Rate_Plan__r.Product__r.Product_Code__c, Uplift__c
                        FROM Product_Rate_Plan_Charge__c WHERE Id = : currentCharge.Product_Rate_Plan_Charge__c];
                singleProdCharge.quantity = Integer.valueOf(currentCharge.Quantity__c);
                singleProdCharge.planId = currentCharge.Opportunity_Rate_Plan__r.Product_Rate_Plan__c;
                singleProdCharge.prodId = currentCharge.Opportunity_Rate_Plan__r.Opportunity_Product__r.Product__c;
                singleProdCharge.chargeId = currentCharge.Id;
                singleProdCharge.chargeName = currentCharge.Name;
                newCharge.prodCharge = singleProdCharge;
                selectedCharges.add(newCharge);
            }
            showChosenCharges = true;
        } else {
            showChosenCharges = false;
        }
    }

    public void openList(){
        String activeStatus = 'Active';
        String query = 'SELECT Id, Name, Description__c, Effective_Period__c, External_ID__c, ' +
                'GL_Account_Receivable_Number__c, Manufacturer__c, Product_Code__c, Product_Family__c, ' +
                'Status__c, Unique_Identifier__c, Valid_From_Date__c, Valid_To_Date__c ' +
                'FROM Product__c WHERE Status__c = : activeStatus ';
        if(String.isNotEmpty(prodSearchText)){
            String prodSearch = '%' + prodSearchText + '%';
            query = query + 'AND Name LIKE : prodSearch';
        }
        ProductList = Database.query(query);
        showProducts = true;
        showPlans = false;
        showCharges = false;
    }

    public void selectProduct(){
        System.debug(selectedProductId);
        showProducts = false;
        showCharges = false;
        plans = [SELECT Id, Name, Description__c FROM Product_Rate_Plan__c WHERE Status__c = 'Active' AND Product__c = : selectedProductId];
        showPlans = true;
    }

    public void selectPlan(){
        showProducts = false;
        showPlans = false;
        List<Product_Rate_Plan_Charge__c> charges = [
                SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Product_Rate_Plan__r.Product__r.Name,
                        Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Format__c, Unit_Price__c, Quantity__c,
                        Product_Rate_Plan__r.Product__r.Product_Code__c, Uplift__c
        FROM Product_Rate_Plan_Charge__c WHERE Product_Rate_Plan__c = : selectedPlanId];
        for(Product_Rate_Plan_Charge__c charge : charges) {
            ProdCharge newProdCharge = new ProdCharge();
            newProdCharge.prodCharge = charge;
            newProdCharge.prodId = selectedProductId;
            newProdCharge.planId = selectedPlanId;
            prodCharges.add(newProdCharge);
        }
        showCharges = true;
    }

    public void selectCharge(){

        Integer quantity = 0;
        ProdCharge selectedProdCharge = new ProdCharge();
        Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge = new Opportunity_Rate_Plan_Charge__c();
        for(ProdCharge prodCharge : prodCharges) {
            if(prodCharge.prodCharge.Id == selectedChargeId) {
                quantity = prodCharge.quantity;
                selectedProdCharge = prodCharge;
                opportunityRatePlanCharge.Quantity__c = quantity;
                opportunityRatePlanCharge = configCharge(opportunityRatePlanCharge, prodCharge.prodCharge);
                OppCharge newCharge = new OppCharge();
                newCharge.opportunityRatePlanCharge = opportunityRatePlanCharge;
                newCharge.prodCharge = prodCharge;
                newCharge.productName = ProdCharge.prodCharge.Product_Rate_Plan__r.Product__r.Name;
                newCharge.indexInteger = highestInteger;
                highestInteger++;
                selectedCharges.add(newCharge);
            }
        }

        prodSearchText = '';
        selectedChargeId = '';
        selectedPlanId = '';
        selectedProductId = '';
        plans.clear();
        prodCharges.clear();
        showCharges = false;
        showPlans = false;
        showProducts = false;
        showChosenCharges = true;
    }

    public void removeCharge(){

        for(OppCharge selectedCharge : selectedCharges) {
            if(removeChargeId == selectedCharge.indexInteger) {
                selectedCharges.remove(selectedCharges.indexOf(selectedCharge));
                removedCharges.add(selectedCharge);
                break;
            }
        }
        removeChargeId = null;
    }

    public void step2(){

        for(OppCharge currentCharge : selectedCharges) {
            currentCharge.chargeId = currentCharge.prodCharge.chargeId;
            currentCharge.opportunityProduct = configOppProd(currentCharge.prodCharge.prodId, currentCharge.prodCharge.chargeId, currentCharge);
            currentCharge.opportunityRatePlan = configOppPlan(currentCharge.prodCharge.planId, currentCharge.opportunityProduct.Id, currentCharge.prodCharge.chargeId);
            grandTotal = grandTotal + currentCharge.opportunityRatePlanCharge.Price__c;
        }
        pageStep = '2';
    }

    public void step1(){
        selectedCharges.clear();
        pageStep = '1';
    }

    public PageReference saveProducts(){

        List<Opportunity_Product__c> oppProducts = new List<Opportunity_Product__c>();
        List<Opportunity_Rate_Plan__c> oppRatePlans = new List<Opportunity_Rate_Plan__c>();
        List<Opportunity_Rate_Plan_Charge__c> oppCharges = new List<Opportunity_Rate_Plan_Charge__c>();
        for(OppCharge opportunityCharge : selectedCharges) {
            if(opportunityCharge.chargeId == null) {
                oppProducts.add(opportunityCharge.opportunityProduct);
            }
        }
        upsert oppProducts;
        for(OppCharge opportunityCharge : selectedCharges) {
            Id oppProdId;
            for(Opportunity_Product__c oppProduct : oppProducts) {
                if(oppProduct.Product__c == opportunityCharge.prodCharge.prodId){
                    oppProdId = oppProduct.Id;
                }
            }
            Opportunity_Rate_Plan__c oppRatePlan = configOppPlan(opportunityCharge.prodCharge.planId, oppProdId, opportunityCharge.chargeId);
            oppRatePlans.add(oppRatePlan);
        }
        upsert oppRatePlans;
        Decimal runningSubtotal = 0;
        for(OppCharge opportunityCharge : selectedCharges) {
            Id ratePlanId;
            for(Opportunity_Rate_Plan__c oppRatePlan : oppRatePlans) {
                if(oppRatePlan.Product_Rate_Plan__c == opportunityCharge.prodCharge.planId) {
                    ratePlanId = oppRatePlan.Id;
                }
            }
            runningSubtotal = runningSubtotal + opportunityCharge.opportunityRatePlanCharge.Unit_Price__c * opportunityCharge.opportunityRatePlanCharge.Quantity__c;
            Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge = new Opportunity_Rate_Plan_Charge__c();
            opportunityRatePlanCharge.Opportunity_Rate_Plan__c = ratePlanId;
            opportunityRatePlanCharge = configOppCharge(opportunityCharge.opportunityRatePlanCharge, opportunityCharge.chargeId, opportunityRatePlanCharge);
            oppCharges.add(opportunityRatePlanCharge);
        }
        upsert oppCharges;
        Opp.Sub_total__c = runningSubtotal;
        Opp.Discount_Value__c = Opp.Sub_total__c * (overallDiscount/100);
        Opp.Net_Total__c = Opp.Sub_total__c - Opp.Discount_Value__c;
        if(Opp.VAT__c == null) {
            Opp.VAT__c = 0;
        }
        if(Opp.Tax__c == null) {
            Opp.Tax__c = 0;
        }
        Opp.Total__c = Opp.Net_Total__c + Opp.VAT__c + Opp.Tax__c;
        Opp.Amount = Opp.Total__c;
        update Opp;
        if(removedCharges.size() > 0) {
            removeCharges();
        }
        PageReference pageRef = new PageReference('/'+OppId);
        return pageRef;
    }

    public void removeCharges(){

        List<Id> removedChargeIds = new List<Id>();
        for(OppCharge removedCharge : removedCharges) {
            if(String.isNotBlank(removedCharge.chargeId)) {
                removedChargeIds.add(removedCharge.chargeId);
            }
        }
        List<Opportunity_Rate_Plan_Charge__c> charges = [SELECT Id, Opportunity_Rate_Plan__c FROM Opportunity_Rate_Plan_Charge__c WHERE Id IN : removedChargeIds];
        if(charges.size() > 0) {
            List<Id> removedPlanIds = new List<Id>();
            for(Opportunity_Rate_Plan_Charge__c charge : charges) {
                removedPlanIds.add(charge.Opportunity_Rate_Plan__c);
            }
            List<Opportunity_Rate_Plan__c> plans = [SELECT Id, Opportunity_Product__c FROM Opportunity_Rate_Plan__c WHERE Id IN : removedPlanIds];
            List<Id> removedProductIds = new List<Id>();
            List<Opportunity_Product__c> products = [SELECT Id FROM Opportunity_Product__c WHERE Id IN : removedProductIds];
            try {
                delete charges;
                delete plans;
                delete products;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    public Opportunity_Rate_Plan__c configOppPlan(String planId, String oppProdId, Id chargeId) {

        Opportunity_Rate_Plan__c oppRatePlan = new Opportunity_Rate_Plan__c();
        if(chargeId == null) {
            Product_Rate_Plan__c ratePlan = [SELECT Id, Name, Description__c, Sequence_Number__c FROM Product_Rate_Plan__c WHERE Id =: planId];
            oppRatePlan.Name = ratePlan.Name;
            oppRatePlan.Product_Rate_Plan__c = ratePlan.Id;
            oppRatePlan.Description__c = ratePlan.Description__c;
            oppRatePlan.Opportunity_Product__c = oppProdId;
        } else {
            String oppPlanId = [SELECT Opportunity_Rate_Plan__r.Id FROM Opportunity_Rate_Plan_Charge__c WHERE Id =: chargeId].Opportunity_Rate_Plan__r.Id;
            oppRatePlan = [SELECT Name, Id, Product_Rate_Plan__c, Description__c, Opportunity_Product__c FROM Opportunity_Rate_Plan__c WHERE Id = : oppPlanId];
        }
        return oppRatePlan;
    }

    public Opportunity_Product__c configOppProd(String prodId, Id chargeId, OppCharge theOppCharge) {

        Opportunity_Product__c OppProduct = new Opportunity_Product__c();
        if(chargeId == null) {
            Product__c chosenProduct = [SELECT Id, Description__c, Product_Code__c, Product_Family__c, Name FROM Product__c WHERE Id =: prodId];
            OppProduct.Name = theOppCharge.productName;
            OppProduct.Description__c = chosenProduct.Description__c;
            OppProduct.Product__c = prodId;
            OppProduct.Product_Family__c = chosenProduct.Product_Family__c;
            OppProduct.Product_Code__c = chosenProduct.Product_Code__c;
            OppProduct.Opportunity__c = oppId;
        } else {
            String oppProductId = [SELECT Opportunity_Rate_Plan__r.Opportunity_Product__r.Id FROM Opportunity_Rate_Plan_Charge__c WHERE Id =: chargeId].Opportunity_Rate_Plan__r.Opportunity_Product__r.Id;
            OppProduct = [SELECT Id, Name, Description__c, Product__c, Product_Family__c, Product_Code__c, Opportunity__c FROM Opportunity_Product__c WHERE Id =: oppProductId];
        }
        return OppProduct;
    }

    public Opportunity_Rate_Plan_Charge__c configOppCharge(Opportunity_Rate_Plan_Charge__c charge, Id chargeId, Opportunity_Rate_Plan_Charge__c newCharge) {

        newCharge.Name = charge.Name;
        newCharge.Product_Charge_Category__c = charge.Product_Charge_Category__c;
        newCharge.Subscription_Product__c = charge.Subscription_Product__c;
        newCharge.Title_Product__c = charge.Title_Product__c;
        newCharge.Unit_Of_Measurement__c = charge.Unit_Of_Measurement__c;
        newCharge.Price_Type__c = charge.Price_Type__c;
        newCharge.Pricing_Model__c = charge.Pricing_Model__c;
        newCharge.Unit_Price__c = charge.Unit_Price__c;
        newCharge.External_Id__c = selectedPlanId;
        newCharge.Product_Rate_Plan_Charge__c = charge.Product_Rate_Plan_Charge__c;
        newCharge.Quantity__c = charge.Quantity__c;
        newCharge.Price__c = charge.Unit_Price__c * charge.Quantity__c;
        newCharge.Discount_Percent__c = charge.Discount_Percent__c;
        newCharge.Discount_Value__c = newCharge.Price__c * newCharge.Discount_Percent__c/100;
        newCharge.Net_Total__c = newCharge.Price__c - newCharge.Discount_Value__c;
        newCharge.Opportunity__c = OppId;
        newCharge.Id = chargeId;
        newCharge.Uplift__c = charge.Uplift__c;
        return newCharge;
    }

    public Opportunity_Rate_Plan_Charge__c configCharge(Opportunity_Rate_Plan_Charge__c newCharge, Product_Rate_Plan_Charge__c charge){

        newCharge.Name = charge.Name;
        newCharge.Product_Charge_Category__c = charge.Product_Charge_Category__c;
        newCharge.Subscription_Product__c = charge.Subscription_Product__c;
        newCharge.Title_Product__c = charge.Title_Product__c;
        newCharge.Unit_Of_Measurement__c = charge.Unit_Of_Measurement__c;
        newCharge.Price_Type__c = charge.Price_Type__c;
        newCharge.Pricing_Model__c = charge.Pricing_Format__c;
        newCharge.Unit_Price__c = charge.Unit_Price__c;
        newCharge.External_Id__c = selectedPlanId;
        newCharge.Product_Rate_Plan_Charge__c = charge.Id;
        newCharge.Price__c = charge.Unit_Price__c * newCharge.Quantity__c;
        newCharge.Discount_Percent__c = 0.00;
        newCharge.Discount_Value__c = 0;
        newCharge.Net_Total__c = newCharge.Price__c - newCharge.Discount_Value__c;
        newCharge.Opportunity__c = oppId;
        newCharge.Uplift__c = charge.Uplift__c;
        return newCharge;

    }

    public void recalculate(){

        grandTotal = 0;
        for(OppCharge selectedCharge: selectedCharges) {
            selectedCharge.opportunityRatePlanCharge.Price__c = selectedCharge.opportunityRatePlanCharge.Unit_Price__c * selectedCharge.opportunityRatePlanCharge.Quantity__c * (1-(selectedCharge.opportunityRatePlanCharge.Discount_Percent__c/100));
            selectedCharge.opportunityRatePlanCharge.Discount_Value__c = selectedCharge.opportunityRatePlanCharge.Unit_Price__c * selectedCharge.opportunityRatePlanCharge.Quantity__c - selectedCharge.opportunityRatePlanCharge.Price__c;
            selectedCharge.opportunityRatePlanCharge.Net_Total__c = selectedCharge.opportunityRatePlanCharge.Price__c - selectedCharge.opportunityRatePlanCharge.Discount_Value__c;
            grandTotal = grandTotal + selectedCharge.opportunityRatePlanCharge.Net_Total__c;
        }
        if(overallDiscount > 0) {
            grandTotal = grandTotal * (1-(overallDiscount/100));
        }

    }

    public class OppCharge{
        public ProdCharge prodCharge {get;set;}
        public Opportunity_Rate_Plan__c opportunityRatePlan {get;set;}
        public Opportunity_Product__c opportunityProduct {get;set;}
        public Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge {get;set;}
        public String chargeId {get;set;}
        public String productName {get;set;}
        public Integer indexInteger {get;set;}

        public OppCharge(){}
    }

    public class ProdCharge{
        public Product_Rate_Plan_Charge__c prodCharge {get;set;}
        public Integer quantity {get;set;}
        public String prodId {get;set;}
        public String planId {get;set;}
        public String chargeId {get;set;}
        public String chargeName {get;set;}

        public ProdCharge(){}
    }
}