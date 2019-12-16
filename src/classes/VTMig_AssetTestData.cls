/**
 * Created by triciaigoe on 2019-12-13.
 */
@IsTest
public with sharing class VTMig_AssetTestData {

    //Need to get a couple of Record Types...
    private static final Id testPlatform = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Platform').getRecordTypeId();
    private static final Id testDirect = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KV Customers').getRecordTypeId();
    private static final Id testHardware = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('VOD Hardware').getRecordTypeId();

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        // HotFix per HTSSF-1063
        // Added Test.startTest() and Test.stopTest()
        createTestingAccounts();
        Account aPlatform = [SELECT Id, Name FROM Account WHERE Name = 'Hierarchy Test Platform'];
        Test.startTest();
        createTestingHierarchy(aPlatform);
        Test.stopTest();

    }
    public static void createTestingHierarchy(Account acct){
        system.debug('Platform Name : ' + acct.Name);
        //Need a few Products...
        List<Product2> pList = new List<Product2>();
        Product2 SystemRoot = new Product2();
        SystemRoot.Name = 'SystemRoot';
        pList.add(SystemRoot);
        Product2 Antenna = new Product2();
        Antenna.Name = 'Antenna';
        pList.add(Antenna);
        Product2 ICM = new Product2();
        ICM.Name = 'ICM';
        pList.add(ICM);
        Product2 swSerial = new Product2();
        swSerial.Name = 'swSerial';
        pList.add(swSerial);
        Product2 MediaServer = new Product2();
        MediaServer.Name = 'MediaServer';
        pList.add(MediaServer);
        Product2 MSLicense = new Product2();
        MSLicense.Name = 'MS License';
        pList.add(MSLicense);
        insert pList;
        //Now Create the Asset Hierarchy, top down...
        Asset Assetroot = new Asset();
        Assetroot.Name = 'System Root Asset';
        Assetroot.Product2Id = SystemRoot.Id;
        Assetroot.AccountId = acct.Id;
        insert Assetroot;

        List<Asset> asstList = new List<Asset>();
        Asset Assetantenna = new Asset();
        Assetantenna.Name = 'Antenna V3';
        Assetantenna.Product2Id = Antenna.Id;
        Assetantenna.parentid = Assetroot.Id;
        Assetantenna.AccountId = acct.Id;
        asstList.add(Assetantenna);

        Asset AssetICM = new Asset();
        AssetICM.Name = 'ICM';
        AssetICM.Product2Id = ICM.Id;
        AssetICM.parentid = Assetroot.Id;
        AssetICM.AccountId = acct.Id;
        asstList.add(AssetICM);

        Asset AssetMS = new Asset();
        AssetMS.Name = 'Media Server';
        AssetMS.Product2Id = MediaServer.Id;
        AssetMS.parentid = Assetroot.Id;
        AssetMS.AccountId = acct.Id;
        asstList.add(AssetMS);

        insert asstList;
        asstList.clear();			//Reset...

        Asset AssetIPAddress = new Asset();
        AssetIPAddress.Name = 'IP Address';
        AssetIPAddress.parentid = AssetICM.Id;
        AssetIPAddress.AccountId = acct.Id;
        asstList.add(AssetIPAddress);

        Asset AssetswSerial= new Asset();
        AssetswSerial.Name = 'CBX LICENSE';
        AssetswSerial.Product2Id = swSerial.Id;
        AssetswSerial.parentid = AssetICM.Id;
        AssetswSerial.AccountId = acct.Id;
        asstList.add(AssetswSerial);

        Asset AssetMSLic= new Asset();
        AssetMSLic.Name = 'MS LICENSE';
        AssetMSLic.Product2Id = MSLicense.Id;
        AssetMSLic.parentid = AssetMS.Id;
        AssetMSLic.AccountId = acct.Id;
        asstList.add(AssetMSLic);

        insert asstList;
    }

    public static void createTestingAccounts(){
        List<Account> acctList = new List<Account>();
        Account a1 = new Account();
        a1.Name = 'Direct Customer';
        a1.RecordTypeId = testDirect;
        insert a1;
        //acctList.add(a1);
        Account a2 = new Account();
        a2.Name = 'Hierarchy Test Platform';
        a2.RecordTypeId = testPlatform;
        a2.ParentId = a1.Id;
        insert a2;
        //acctList.add(a2);
        //insert acctList;
    }

}