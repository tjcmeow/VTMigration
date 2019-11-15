/**
 * Created by triciaigoe on 2019-11-11.
 */

public with sharing class VTMig_AddOrderProduct {

        public Id orderId {get; set;}
        public Job__c order {get; set;}
        public String prodSearchText {get; set;}
        public List<Product__c> productList {get; set;}
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
        public List<OrderCharge> selectedCharges {get;set;}
        public List<ProdCharge> selectedProdCharges {get;set;}

        public VTMig_AddOrderProduct(ApexPages.StandardController ctrlr){
            orderId = ApexPages.currentPage().getParameters().get('Id');
            selectedCharges = new List<OrderCharge>();
            prodCharges = new List<ProdCharge>();
            productList = new List<Product__c>();
            selectedProdCharges = new List<ProdCharge>();
            showProducts = false;
            showPlans = false;
            showCharges = false;
            pageStep = '1';
            grandTotal = 0;
            order = [
                    SELECT Id, Account__c, Shipping_Contact__c, Shipping_Account__c, Legal_Entity__c, Partner_Agent__c, IITIntended_Use__c,
                            Wet_or_Dry_Cargo__c, Platform_or_Vessel_detail__c, Name
                    FROM Job__c WHERE Id = : orderId
            ];
            List<Job_Rate_Plan_Charge__c> currentCharges = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Job_Rate_Plan__r.Job_Product__r.Name,
                    Job_Rate_Plan__r.Job_Product__r.Product__c, Product_Rate_Plan_Charge__c,
                    Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Price_Format__c, Unit_Price__c,
                    Quantity__c, Job_Rate_Plan__r.Job_Product__r.Product_Code__c, Job_Rate_Plan__r.Product_Rate_Plan__c
            FROM Job_Rate_Plan_Charge__c WHERE Order__c = : orderId];
            if(currentCharges.size() > 0) {
                for(Job_Rate_Plan_Charge__c currentCharge : currentCharges) {
                    ProdCharge singleProdCharge = new ProdCharge();
                    singleProdCharge.prodCharge = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c, Product_Rate_Plan__r.Product__r.Name,
                            Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Format__c, Unit_Price__c, Product_Rate_Plan__r.Product__r.Product_Code__c
                    FROM Product_Rate_Plan_Charge__c WHERE Id = : currentCharge.Product_Rate_Plan_Charge__c];
                    singleProdCharge.quantity = Integer.valueOf(currentCharge.Quantity__c);
                    singleProdCharge.planId = currentCharge.Job_Rate_Plan__r.Product_Rate_Plan__c;
                    singleProdCharge.prodId = currentCharge.Job_Rate_Plan__r.Job_Product__r.Product__c;
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
            productList = Database.query(query);
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
                OrderCharge currentCharge = new OrderCharge();
                currentCharge.prodCharge = selectedProdCharge;
                currentCharge.orderProduct = configOrderProd(selectedProdCharge.prodId);
                currentCharge.orderRatePlan = configOrderPlan(selectedProdCharge.planId, currentCharge.orderProduct.Id);
                currentCharge.orderRatePlanCharge = configOrderCharge(selectedProdCharge.prodCharge.Id, currentCharge.orderRatePlan.Id, selectedProdCharge.quantity);
                selectedCharges.add(currentCharge);
                grandTotal = grandTotal + currentCharge.orderRatePlanCharge.Price__c;
            }
            pageStep = '2';
        }

        public void step1(){
            selectedCharges.clear();
            pageStep = '1';
        }

        public PageReference saveProducts(){

            List<Job_Product__c> OrderProducts = new List<Job_Product__c>();
            List<Job_Rate_Plan__c> OrderRatePlans = new List<Job_Rate_Plan__c>();
            List<Job_Rate_Plan_Charge__c> OrderCharges = new List<Job_Rate_Plan_Charge__c>();
            for(OrderCharge OrderCharge : selectedCharges) {
                OrderProducts.add(OrderCharge.orderProduct);
            }
            insert OrderProducts;
            for(OrderCharge OrderCharge : selectedCharges) {
                Id OrderProdId;
                for(Job_Product__c OrderProduct : OrderProducts) {
                    if(OrderProduct.Product__c == OrderCharge.prodCharge.prodId){
                        OrderProdId = OrderProduct.Id;
                    }
                }
                Job_Rate_Plan__c OrderRatePlan = configOrderPlan(OrderCharge.prodCharge.planId, OrderProdId);
                OrderRatePlans.add(OrderRatePlan);
            }
            insert OrderRatePlans;
            Decimal runningTotal = 0;
            for(OrderCharge OrderCharge : selectedCharges) {
                Id ratePlanId;
                for(Job_Rate_Plan__c OrderRatePlan : OrderRatePlans) {
                    if(OrderRatePlan.Product_Rate_Plan__c == OrderCharge.prodCharge.planId) {
                        ratePlanId = OrderRatePlan.Id;
                    }
                }
                runningTotal = runningTotal + OrderCharge.orderRatePlanCharge.Unit_Price__c * OrderCharge.orderRatePlanCharge.Quantity__c;
                Job_Rate_Plan_Charge__c OrderRatePlanCharge = configOrderCharge(OrderCharge.prodCharge.prodCharge.Id, ratePlanId, OrderCharge.prodCharge.quantity);
                OrderCharges.add(OrderRatePlanCharge);
            }
            insert OrderCharges;
            order.Discount_Value__c = runningTotal - grandTotal;
            order.Total__c = grandTotal;
            update order;
            PageReference pageRef = new PageReference('/'+orderId);
            return pageRef;
        }

        public Job_Rate_Plan__c configOrderPlan(String planId, String OrderProdId) {

            Product_Rate_Plan__c ratePlan = [SELECT Id, Name, Description__c, Sequence_Number__c FROM Product_Rate_Plan__c WHERE Id =: planId];
            Job_Rate_Plan__c OrderRatePlan = new Job_Rate_Plan__c();
            OrderRatePlan.Name = ratePlan.Name;
            OrderRatePlan.Product_Rate_Plan__c = ratePlan.Id;
            OrderRatePlan.Description__c = ratePlan.Description__c;
            OrderRatePlan.Sequence_Number__c = ratePlan.Sequence_Number__c;
            OrderRatePlan.Job_Product__c = OrderProdId;
            return OrderRatePlan;
        }

        public Job_Product__c configOrderProd(String prodId) {

            Product__c chosenProduct = [SELECT Id, Description__c, Product_Code__c, Product_Family__c, Name FROM Product__c WHERE Id =: prodId];
            Job_Product__c OrderProduct = new Job_Product__c();
            OrderProduct.Name = chosenProduct.Name;
            OrderProduct.Description__c = chosenProduct.Description__c;
            OrderProduct.Product__c = prodId;
            OrderProduct.Product_Family__c = chosenProduct.Product_Family__c;
            OrderProduct.Product_Code__c = chosenProduct.Product_Code__c;
            OrderProduct.Job__c = orderId;
            return OrderProduct;
        }

        public Job_Rate_Plan_Charge__c configOrderCharge(String chargeId, String planId, Integer quantityInteger) {
            Product_Rate_Plan_Charge__c charge = [SELECT Id, Name, Product_Charge_Category__c, Subscription_Product__c,
                    Title_Product__c, Unit_Of_Measurement__c, Price_Type__c, Pricing_Format__c, Unit_Price__c
            FROM Product_Rate_Plan_Charge__c WHERE Id =: chargeId];
            Job_Rate_Plan_Charge__c newCharge = new Job_Rate_Plan_Charge__c();
            newCharge.Name = charge.Name;
            newCharge.Product_Charge_Category__c = charge.Product_Charge_Category__c;
            newCharge.Subscription_Product__c = charge.Subscription_Product__c;
            newCharge.Title_Product__c = charge.Title_Product__c;
            newCharge.Unit_Of_Measurement__c = charge.Unit_Of_Measurement__c;
            newCharge.Price_Type__c = charge.Price_Type__c;
            newCharge.Price_Format__c = charge.Pricing_Format__c;
            newCharge.Unit_Price__c = charge.Unit_Price__c;
            newCharge.External_Id__c = selectedPlanId;
            newCharge.Product_Rate_Plan_Charge__c = charge.Id;
            newCharge.Quantity__c = quantityInteger;
            newCharge.Job_Rate_Plan__c = planId;
            newCharge.Price__c = charge.Unit_Price__c * quantityInteger;
            newCharge.Discount_Percent__c = 0.00;
            newCharge.Order__c = orderId;
            return newCharge;
        }

        public void recalculate(){

            grandTotal = 0;
            for(OrderCharge selectedCharge: selectedCharges) {
                selectedCharge.orderRatePlanCharge.Price__c = selectedCharge.orderRatePlanCharge.Unit_Price__c * selectedCharge.orderRatePlanCharge.Quantity__c * (1-(selectedCharge.orderRatePlanCharge.Discount_Percent__c/100));
                selectedCharge.orderRatePlanCharge.Discount_Value__c = selectedCharge.orderRatePlanCharge.Unit_Price__c * selectedCharge.orderRatePlanCharge.Quantity__c - selectedCharge.orderRatePlanCharge.Price__c;
                grandTotal = grandTotal + selectedCharge.orderRatePlanCharge.Price__c;
            }
            if(overallDiscount > 0) {
                grandTotal = grandTotal * (1-(overallDiscount/100));
            }

        }

        public class OrderCharge{
            public ProdCharge prodCharge {get;set;}
            public Job_Rate_Plan__c orderRatePlan {get;set;}
            public Job_Product__c orderProduct {get;set;}
            public Job_Rate_Plan_Charge__c orderRatePlanCharge {get;set;}

            public OrderCharge(){}
        }

        public class ProdCharge{
            public Product_Rate_Plan_Charge__c prodCharge {get;set;}
            public Integer quantity {get;set;}
            public String prodId {get;set;}
            public String planId {get;set;}

            public ProdCharge(){}
        }

}