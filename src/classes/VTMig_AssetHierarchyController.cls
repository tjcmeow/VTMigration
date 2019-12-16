/**
 * Created by triciaigoe on 2019-12-13.
 */

public without sharing class VTMig_AssetHierarchyController { 

    /*
    Method to get the List of Asset Hierarchy records passing any Asset of the Hierarchy structure.
    */
    @AuraEnabled
    public static List<Asset> getAssetHierarchy(string assetId) {
        try{
            Asset theRootAsset = [SELECT RootAssetId FROM Asset WHERE ID =: assetId];
            String rootAssetId;
            if(theRootAsset.RootAssetId == null){
                rootAssetId = assetId;
            }else{
                rootAssetId = theRootAsset.RootAssetId;
            }
            List<Asset> assetHierarchy = [SELECT id, Name, Product2.Name, ParentId, AccountID, Date_Removed__c,
                    InstallDate,Installed_By__c,
                    RootAssetId,RootAsset.Name,
                    RootAsset.Product2.Name, Item_Description__c,Account_Name__c,
                    Item__c,
                    Asset.Product2.ProductCode
            FROM Asset
            WHERE RootAssetId =: rootAssetId OR ID =: rootAssetId];
            return assetHierarchy;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage() + ' ' +ex.getLineNumber());
        }

    }

}