/**
 * Created by jerry on 10/24/2019.
 */

public with sharing class VTMig_ProductSelection_Extension {

    public Id OppId {get; set;}
    public Opportunity Opp {get; set;}
    public Job__c Order {get; set;}
    public String prodSearchText {get; set;}
    public List<Product__c> ProductList {get; set;}
    public Product__c selectedProduct {get; set;}
    public Boolean showProducts {get; set;}
    public String pageStep {get; set;}

    public VTMig_ProductSelection_Extension(ApexPages.StandardController ctrlr){
        ProductList = new List<Product__c>();
        showProducts = false;
        pageStep = '1';
    }

    public void openList(){
        String activeStatus = 'Active';
        String query = 'SELECT Id, Name, Description__c, Effective_Period__c, External_ID__c, ' +
                'GL_Account_Receivable_Number__c, Manufacturer__c, Product_Code__c, Product_Family__c, ' +
                'Status__c, Unique_Identifier__c, Valid_From_Date__c, Valid_To_Date__c ' +
                'FROM Product__c WHERE Status__c = : activeStatus ';
        if(String.isNotEmpty(prodSearchText)){
            string prodSearch = '%' + prodSearchText + '%';
            query = query + 'AND Name LIKE : prodSearch';
        }
        ProductList = Database.query(query);
        showProducts = true;
    }

    public void selectProduct(){

    }
}