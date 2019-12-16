/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*  test class for 'AssetHirerachy_Controller'
*
* Additional information about this class, multiple lines
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         kailash gurjar  kgurjar@kvh.com
* @repository     https://bitbucket.org/kvhdev/asset-hierarchy/src/master/
*/
@isTest
public class VTMig_AssetHierarchy_ControllerTest{
    
     @testSetup static void setup() {
        Account acct = New Account();
        acct.Name = 'TestAccName';
        insert acct;
        
        Product2 SystemRoot = new Product2();
        SystemRoot.Name = 'V11IP';
        insert SystemRoot;
        
        List<Asset> assetList = new List<Asset>();
        Asset Assetroot = new Asset();
        Assetroot.Name = '123456789';
        Assetroot.Product2Id = SystemRoot.Id;
        Assetroot.AccountId = acct.Id;
        assetList.add(Assetroot);
        
        Asset childAsset = new Asset();
        childAsset.Name = '123457689';
        childAsset.Product2Id = SystemRoot.Id;
        childAsset.AccountId = acct.Id;
        assetList.add(childAsset);
        insert assetList;      
    }
    
    static testMethod void getAssetHierarchyTest(){
        List<Asset> assets = [select Id from Asset];
        List<Asset> lst = AssetHirerachy_Controller.getAssetHierarchy(assets[0].Id);
        system.assertEquals(1, lst.size());
        
        assets[0].ParentId = assets[1].Id;
        update assets[0];
        lst = AssetHirerachy_Controller.getAssetHierarchy(assets[0].Id);
        system.assertEquals(2, lst.size());
        system.assertEquals(lst[1].Id, lst[0].RootAssetId);
    }
    
    static testMethod void nagativeTest(){
        try{
            List<Asset> assets = [select Id from Asset];
            List<Asset> lst = AssetHirerachy_Controller.getAssetHierarchy('123'); 
            system.assertEquals(0, lst.size());
        }Catch(Exception exp){}       
    }
}