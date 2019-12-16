/**
 * Created by triciaigoe on 2019-12-13.
 */

@IsTest
public with sharing class VTMig_AssetHierarchy_ControllerTest {

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
        List<Asset> lst = VTMig_AssetHierarchyController.getAssetHierarchy(assets[0].Id);
        system.assertEquals(1, lst.size());

        assets[0].ParentId = assets[1].Id;
        update assets[0];
        lst = VTMig_AssetHierarchyController.getAssetHierarchy(assets[0].Id);
        system.assertEquals(2, lst.size());
        system.assertEquals(lst[1].Id, lst[0].RootAssetId);
    }

    static testMethod void nagativeTest(){
        try{
            List<Asset> assets = [select Id from Asset];
            List<Asset> lst = VTMig_AssetHierarchyController.getAssetHierarchy('123');
            system.assertEquals(0, lst.size());
        }Catch(Exception exp){}
    }

}