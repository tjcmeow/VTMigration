/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*  controller class for AssetHirerachy to show the asset hirerachy in lightning component by using
*  lighting tree
*
* Additional information about this class, multiple lines
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Jitendra Rawat   jrawat@kvh.com
* @repository     https://bitbucket.org/kvhdev/asset-hierarchy/src/master/
*/
public class AssetHirerachy_Controller {
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
                                          InstallDate,Sequence_No__c,Installed_By__c,
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