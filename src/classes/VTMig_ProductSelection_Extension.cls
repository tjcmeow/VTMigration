/**
 * Created by jerry on 10/24/2019.
 */

public with sharing class VTMig_ProductSelection_Extension {

    public Id OppId {get; set;}
    public Opportunity Opp {get; set;}
    public Job__c Order {get; set;}

    public VTMig_ProductSelection_Extension(ApexPages.StandardController ctrlr){

    }

    public static void openList(){

    }

    public class selectableObject{
        public boolean selected {get; set;}
        public string type {get; set;}
        public sObject record {get; set;}
    }
}