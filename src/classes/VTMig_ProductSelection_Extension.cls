/**
 * Created by tricia on 10/24/2019.
 */

public with sharing class VTMig_ProductSelection_Extension {

    public Id OppId {get; set;}
    public Opportunity Opp {get; set;}
    public Job__c Order {get; set;}
    public String prodSearchText {get; set;}
    public List<Product__c> ProductList {get; set;}
    public String selectedProductId {get; set;}
    public String selectedPlanId {get; set;}
    public String selectedChargeId {get; set;}
    public String removeChargeId {get; set;}
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
    public List<ProdCharge> selectedProdCharges {get;set;}

    public VTMig_ProductSelection_Extension(ApexPages.StandardController ctrlr){
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
        Opp = [SELECT Name, AccountId, Wet_or_Dry_Cargo__c, Platform_or_Vessel_Detail__c, Shipping_Account__c, Shipping_Contact__c, Partner_Agent__c, IITIntended_Use__c, Legal_Entity__c FROM Opportunity WHERE Id = : OppId];
        List<Opportunity_Rate_Plan_Charge__c> currentCharges = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Opportunity_Rate_Plan__r.Opportunity_Product__r.Name,
                Opportunity_Rate_Plan__r.Opportunity_Product__r.Product__c, Product_Rate_Plan_Charge__c,
                Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Model__c, Unit_Price__c,
                Quantity__c, Opportunity_Rate_Plan__r.Opportunity_Product__r.Product_Code__c, Opportunity_Rate_Plan__r.Product_Rate_Plan__c
        FROM Opportunity_Rate_Plan_Charge__c WHERE Opportunity__c = : OppId];
        if(currentCharges.size() > 0) {
            for(Opportunity_Rate_Plan_Charge__c currentCharge : currentCharges) {
                ProdCharge singleProdCharge = new ProdCharge();
                singleProdCharge.prodCharge = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Product_Rate_Plan__r.Product__r.Name,
                        Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Format__c, Unit_Price__c, Product_Rate_Plan__r.Product__r.Product_Code__c
                FROM Product_Rate_Plan_Charge__c WHERE Id = : currentCharge.Product_Rate_Plan_Charge__c];
                singleProdCharge.quantity = Integer.valueOf(currentCharge.Quantity__c);
                singleProdCharge.planId = currentCharge.Opportunity_Rate_Plan__r.Product_Rate_Plan__c;
                singleProdCharge.prodId = currentCharge.Opportunity_Rate_Plan__r.Opportunity_Product__r.Product__c;
                selectedProdCharges.add(singleProdCharge);
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
        List<Product_Rate_Plan_Charge__c> charges = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Product_Rate_Plan__r.Product__r.Name,
                Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Format__c, Unit_Price__c, Quantity__c, Product_Rate_Plan__r.Product__r.Product_Code__c
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
        for(ProdCharge prodCharge : prodCharges) {
            if(prodCharge.prodCharge.Id == selectedChargeId) {
                quantity = prodCharge.quantity;
                selectedProdCharge = prodCharge;
            }
        }
        selectedProdCharges.add(selectedProdCharge);
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

        for(Integer i = 0; i<selectedProdCharges.size(); i++) {
            if(removeChargeId == selectedProdCharges[i].prodCharge.Id) {
                selectedProdCharges.remove(i);
            }
        }
        removeChargeId = '';
    }

    public void step2(){

        for(ProdCharge selectedProdCharge : selectedProdCharges) {
            OppCharge currentCharge = new OppCharge();
            currentCharge.prodCharge = selectedProdCharge;
            currentCharge.opportunityProduct = configOppProd(selectedProdCharge.prodId);
            currentCharge.opportunityRatePlan = configOppPlan(selectedProdCharge.planId, currentCharge.opportunityProduct.Id);
            currentCharge.opportunityRatePlanCharge = configOppCharge(selectedProdCharge.prodCharge.Id, currentCharge.opportunityRatePlan.Id, selectedProdCharge.quantity);
            selectedCharges.add(currentCharge);
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
            oppProducts.add(opportunityCharge.opportunityProduct);
        }
        insert oppProducts;
        for(OppCharge opportunityCharge : selectedCharges) {
            Id oppProdId;
            for(Opportunity_Product__c oppProduct : oppProducts) {
                if(oppProduct.Product__c == opportunityCharge.prodCharge.prodId){
                    oppProdId = oppProduct.Id;
                }
            }
            Opportunity_Rate_Plan__c oppRatePlan = configOppPlan(opportunityCharge.prodCharge.planId, oppProdId);
            oppRatePlans.add(oppRatePlan);
        }
        insert oppRatePlans;
        Decimal runningTotal = 0;
        for(OppCharge opportunityCharge : selectedCharges) {
            Id ratePlanId;
            for(Opportunity_Rate_Plan__c oppRatePlan : oppRatePlans) {
                if(oppRatePlan.Product_Rate_Plan__c == opportunityCharge.prodCharge.planId) {
                    ratePlanId = oppRatePlan.Id;
                }
            }
            runningTotal = runningTotal + opportunityCharge.opportunityRatePlanCharge.Unit_Price__c * opportunityCharge.opportunityRatePlanCharge.Quantity__c;
            Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = configOppCharge(opportunityCharge.prodCharge.prodCharge.Id, ratePlanId, opportunityCharge.prodCharge.quantity);
            oppCharges.add(oppRatePlanCharge);
        }
        insert oppCharges;
        Opp.Discount_Value__c = runningTotal - grandTotal;
        Opp.Amount = grandTotal;
        update Opp;
        PageReference pageRef = new PageReference('/'+OppId);
        return pageRef;
    }

    public Opportunity_Rate_Plan__c configOppPlan(String planId, String oppProdId) {

        Product_Rate_Plan__c ratePlan = [SELECT Id, Name, Description__c, Sequence_Number__c FROM Product_Rate_Plan__c WHERE Id =: planId];
        Opportunity_Rate_Plan__c opportunityRatePlan = new Opportunity_Rate_Plan__c();
        opportunityRatePlan.Name = ratePlan.Name;
        opportunityRatePlan.Product_Rate_Plan__c = ratePlan.Id;
        opportunityRatePlan.Description__c = ratePlan.Description__c;
        opportunityRatePlan.SequenceNumber__c = ratePlan.Sequence_Number__c;
        opportunityRatePlan.Opportunity_Product__c = oppProdId;
        return opportunityRatePlan;
    }

    public Opportunity_Product__c configOppProd(String prodId) {

        Product__c chosenProduct = [SELECT Id, Description__c, Product_Code__c, Product_Family__c, Name FROM Product__c WHERE Id =: prodId];
        Opportunity_Product__c oppProduct = new Opportunity_Product__c();
        oppProduct.Name = chosenProduct.Name;
        oppProduct.Description__c = chosenProduct.Description__c;
        oppProduct.Product__c = prodId;
        oppProduct.Product_Family__c = chosenProduct.Product_Family__c;
        oppProduct.Product_Code__c = chosenProduct.Product_Code__c;
        oppProduct.Opportunity__c = OppId;
        return oppProduct;
    }

    public Opportunity_Rate_Plan_Charge__c configOppCharge(String chargeId, String planId, Integer quantityInteger) {
        Product_Rate_Plan_Charge__c charge = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c,
                Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Format__c, Unit_Price__c
        FROM Product_Rate_Plan_Charge__c WHERE Id =: chargeId];
        Opportunity_Rate_Plan_Charge__c newCharge = new Opportunity_Rate_Plan_Charge__c();
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
        newCharge.Quantity__c = quantityInteger;
        newCharge.Opportunity_Rate_Plan__c = planId;
        newCharge.Price__c = charge.Unit_Price__c * quantityInteger;
        newCharge.Discount_Percent__c = 0.00;
        newCharge.Opportunity__c = OppId;
        return newCharge;
    }

    public void recalculate(){

        grandTotal = 0;
        for(OppCharge selectedCharge: selectedCharges) {
            selectedCharge.opportunityRatePlanCharge.Price__c = selectedCharge.opportunityRatePlanCharge.Unit_Price__c * selectedCharge.opportunityRatePlanCharge.Quantity__c * (1-(selectedCharge.opportunityRatePlanCharge.Discount_Percent__c/100));
            selectedCharge.opportunityRatePlanCharge.Discount_Value__c = selectedCharge.opportunityRatePlanCharge.Unit_Price__c * selectedCharge.opportunityRatePlanCharge.Quantity__c - selectedCharge.opportunityRatePlanCharge.Price__c;
            grandTotal = grandTotal + selectedCharge.opportunityRatePlanCharge.Price__c;
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

        public OppCharge(){}
    }

    public class ProdCharge{
        public Product_Rate_Plan_Charge__c prodCharge {get;set;}
        public Integer quantity {get;set;}
        public String prodId {get;set;}
        public String planId {get;set;}

        public ProdCharge(){}
    }
}