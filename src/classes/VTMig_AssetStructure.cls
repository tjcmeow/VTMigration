/**
 * Created by triciaigoe on 2019-12-13.
 */

public with sharing class VTMig_AssetStructure {

    //Declare variables
    public String currentId;
    public List<ObjectStructureMap> asm ;
    public Map<String, ObjectStructureMap> masm;
    public List<Integer> maxLevel;

    /**
    * Contructor
    */
    public VTMig_AssetStructure() {
        this.asm = new List<ObjectStructureMap>{};
        this.masm = new Map<String, ObjectStructureMap>{};
        this.maxLevel = new List<Integer>{};
    }

    /**
    * Allow page to set the current ID
    */
    public void setcurrentId( String cid ){
        currentId = cid;
    }

    public string getcurrentId(){
        return currentId;
    }

    /**
    * Return ObjectStructureMap to page
    * @return asm
    */
    public List<ObjectStructureMap> getObjectStructure(){
        asm.clear();
        if ( currentId == null ) {
            currentId = System.currentPageReference().getParameters().get( 'id' );
        }

        System.assertNotEquals( currentId, null, 'sObject ID must be provided' );
        asm = formatObjectStructure( CurrentId );

        return asm;
    }

    /**
    * Query Account from top down to build the ObjectStructureMap
    * @param currentId
    * @return asm
    */
    public ObjectStructureMap[] formatObjectStructure( String currentId ){

        List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
        masm.clear();

        //Change below
        List<Asset> al            = new List<Asset>{};
        List<ID> currentParent      = new List<ID>{};
        Map<ID, String> nodeList    = new Map<ID, String>{};
        List<String> nodeSortList   = new List<String>{};
        List<Boolean> levelFlag     = new List<Boolean>{};
        List<Boolean> closeFlag     = new List<Boolean>{};
        String nodeId               = '0';
        String nodeType             = 'child';
        Integer count               = 0;
        Integer level               = 0;
        Boolean endOfStructure      = false;

        //Find highest level obejct in the structure
        currentParent.add( GetTopElement( currentId ) );

        //Loop though all children
        while ( !endOfStructure ){

            if( level == 0 ){
                //Change below     (removed  a.Site,  a.OwnerId,  a.Industry,)
                al = [ SELECT a.item__c, a.ParentId, a.Name, a.Id, a.Item_Description__c,
                        a.InstallDate, a.Date_Removed__c,a.Product2.name
                FROM Asset a
                WHERE a.id IN : CurrentParent
                ORDER BY a.Name ];
            }
            else {
                //Change below      
                al = [ SELECT a.item__c, a.ParentId, a.Name, a.Id, a.Item_Description__c,
                        a.InstallDate, a.Date_Removed__c,a.Product2.name
                FROM Asset a
                WHERE a.ParentId IN : CurrentParent
                ORDER BY a.Name ];
            }

            if( al.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                String Seq = '';
                Boolean hasSequenceNo = null;
                for ( Integer i = 0 ; i < al.size(); i++ ){
                    //Change below
                    Asset a = al[i];
                    //The following line acts like an IIF statement, AND breaks the alphabetical order of the children!
                    //nodeId = ( level > 0 ) ? NodeList.get( a.ParentId )+'.'+String.valueOf( i ) : String.valueOf( i );
                    /*The node sort list looks like {0, 0.1, 0.2, 1.0, ... 0.12, .0.13}
                    This can cause a problem with sorting of there are >10 children... it might not sort in 
                    alphabetical order. Adding leading 0s to the sort string will alleviate the problem as long as
                    there are not more than 10000 children.*/
                    //Rather than an alhpabetical sort, let's inject the Sequence number into NodeSortList
                    Seq = String.valueOf( i );
                    If( level > 0) {
                        nodeId = NodeList.get( a.ParentId )+'.'+Seq.leftPad(5);
                        nodeId = nodeId.replaceAll(' ', '0');
                    }  else  {
                        nodeId = Seq.leftPad(5); // we want at least 5 chars for sorting purposes
                        nodeId = nodeId.replaceAll(' ', '0');
                    }

                    system.debug(nodeId +', '+Seq+' ,'+ a.name);

                    masm.put( NodeID, new ObjectStructureMap( nodeID, levelFlag, closeFlag, nodeType, false, false, a ) );
                    currentParent.add( a.id );
                    nodeList.put( a.id,nodeId );
                    nodeSortList.add( nodeId );
                }

                maxLevel.add( level );
                level++;
            }
        }

        //Account structure must now be formatted
        NodeSortList.sort();
        for( Integer i = 0; i < NodeSortList.size(); i++ ){
            List<String> pnl = new List<String> {};
            List<String> cnl = new List<String> {};
            List<String> nnl = new List<String> {};

            if ( i > 0 ){
                String pn   = NodeSortList[i-1];
                pnl         = pn.split( '\\.', -1 );
            }

            String cn   = NodeSortList[i];
            cnl         = cn.split( '\\.', -1 );

            if( i < NodeSortList.size()-1 ){
                String nn = NodeSortList[i+1];
                nnl = nn.split( '\\.', -1 );
            }

            ObjectStructureMap tasm = masm.get( cn );
            if ( cnl.size() < nnl.size() ){
                //Parent
                tasm.nodeType = ( isLastNode( cnl ) ) ? 'parent_end' : 'parent';
            }
            else if( cnl.size() > nnl.size() ){
                tasm.nodeType   = 'child_end';
                tasm.closeFlag  = setcloseFlag( cnl, nnl, tasm.nodeType );
            }
            else{
                tasm.nodeType = 'child';
            }

            tasm.levelFlag = setlevelFlag( cnl, tasm.nodeType );

            //Change below 
            if ( tasm.asset.id == currentId ) {
                tasm.currentNode = true;
            }
            asm.add( tasm );
        }

        asm[0].nodeType             = 'start';
        asm[asm.size()-1].nodeType  = 'end';

        return asm;
    }

    /**
    * Determin parent elements relationship to current element
    * @return flagList
    */
    public List<Boolean> setlevelFlag( List<String> nodeElements, String nodeType ){

        List<Boolean> flagList = new List<Boolean>{};
        String searchNode   = '';
        String workNode     = '';
        Integer cn          = 0;

        for( Integer i = 0; i < nodeElements.size() - 1; i++ ){
            cn = Integer.valueOf( nodeElements[i] );
            cn++;
            searchNode  = workNode + String.valueOf( cn );
            workNode    = workNode + nodeElements[i] + '.';
            if ( masm.containsKey( searchNode ) ){
                flagList.add( true );
            }
            else {
                flagList.add( false );
            }
        }

        return flagList;
    }

    /**
    * Determin if the element is a closing element
    * @return flagList
    */
    public List<Boolean> setcloseFlag( List<String> cnl, List<String> nnl, String nodeType ){

        List<Boolean> flagList = new List<Boolean>{};
        String searchNode   = '';
        String workNode     = '';
        Integer cn          = 0;

        for( Integer i = nnl.size(); i < cnl.size(); i++ ){
            flagList.add( true );
        }

        return flagList;
    }

    /**
    * Determin if Element is the bottom node  
    * @return Boolean
    */
    public Boolean isLastNode( List<String> nodeElements ){

        String searchNode   = '';
        Integer cn          = 0;

        for( Integer i = 0; i < nodeElements.size(); i++ ){
            if ( i == nodeElements.size()-1 ){
                cn = Integer.valueOf( nodeElements[i] );
                cn++;
                searchNode = searchNode + String.valueOf( cn );
            }
            else {
                searchNode = searchNode + nodeElements[i] + '.';
            }
        }
        if ( masm.containsKey( searchNode ) ){
            return false;
        }
        else{
            return true;
        }
    }

    /**
    * Find the tom most element in Heirarchy  
    * @return objId
    */
    public String GetTopElement( String objId ){

        Boolean top = false;
        while ( !top ) {
            //Change below
            //Safer to return a List than a limit 1...

            //Asset a = [ Select a.Id, a.ParentId From Asset a where a.Id =: objId limit 1 ]; original line

            //start new code
            List<Asset> soqla = [ Select a.Id, a.ParentId From Asset a where a.Id =: objId ];
            Asset a = null;
            if (!soqla.isEmpty()) { // we got records!
                a = soqla.get(0);   // just want the first one
            }   else    {
                // do something else?!
            }
            //end new code

            if ( a.ParentId != null ) {
                objId = a.ParentId;
            }
            else {
                top = true;
            }
        }
        return objId ;
    }

    /**
    * Find the tom most multiple elements in Heirarchy (Method created By Gopi)
    * @return Multiple Asset Parent objIds.
    */
    public Static Map<ID,ID> GetTopMultipleElements( Set<ID> objId ){
        MAP<ID,ID> mutipleAssetParentIds = new MAP<ID,ID>();

        MAP<ID,ID> FindTopLevelAssets = new MAP<ID,ID>();

        for(integer repeatLoop=0;repeatLoop<integer.valueOF(system.label.VTMig_AssetLevelExecution);repeatLoop++){

            List<Asset> soqla = [Select a.Id,

                    a.ParentId,

                    a.Parent.ParentId,

                    a.Parent.Parent.ParentId,

                    a.Parent.Parent.Parent.ParentId,

                    a.Parent.Parent.Parent.Parent.ParentId From Asset a where a.Id =: objId ];

            Asset a = null;
            if (!soqla.isEmpty()) { // we got records!
                for(integer i=0;i<soqla.size();i++){
                    a = soqla.get(i);
                    if(a.Parent.Parent.Parent.Parent.ParentId!=null){
                        ID singleobjId = a.Parent.Parent.Parent.Parent.ParentId;
                        objId.add(singleobjId);
                        FindTopLevelAssets.put(singleobjId,a.id);
                    }else if(a.Parent.Parent.Parent.ParentId!=null){
                        ID singleobjId = a.Parent.Parent.Parent.ParentId;
                        if(FindTopLevelAssets.containskey(a.id)){
                            mutipleAssetParentIds.put(FindTopLevelAssets.get(a.id),singleobjId);
                        }else{
                            mutipleAssetParentIds.put(soqla[i].ID,singleobjId);
                        }
                    }else if(a.Parent.Parent.ParentId!=null){
                        ID singleobjId = a.Parent.Parent.ParentId;
                        if(FindTopLevelAssets.containskey(a.id)){
                            mutipleAssetParentIds.put(FindTopLevelAssets.get(a.id),singleobjId);
                        }else{
                            mutipleAssetParentIds.put(soqla[i].ID,singleobjId);
                        }
                    }else if(a.Parent.ParentId!=null){
                        ID singleobjId = a.Parent.ParentId;
                        if(FindTopLevelAssets.containskey(a.id)){
                            mutipleAssetParentIds.put(FindTopLevelAssets.get(a.id),singleobjId);
                        }else{
                            mutipleAssetParentIds.put(soqla[i].ID,singleobjId);
                        }
                    }else if ( a.ParentId != null ) {
                        ID singleobjId = a.ParentId;
                        if(FindTopLevelAssets.containskey(a.id)){
                            mutipleAssetParentIds.put(FindTopLevelAssets.get(a.id),singleobjId);
                        }else{
                            mutipleAssetParentIds.put(soqla[i].ID,singleobjId);
                        }
                    }else if ( a.ParentId == null ) {
                        ID singleobjId = a.Id;
                        mutipleAssetParentIds.put(soqla[i].ID,singleobjId);
                    }
                }
            }
        }
        return mutipleAssetParentIds;
    }


    /**
    * Wrapper class
    */
    public with sharing class ObjectStructureMap {

        public String nodeId;
        public Boolean[] levelFlag = new Boolean[]{};
        public Boolean[] closeFlag = new Boolean[]{};
        public String nodeType;
        public Boolean currentNode;

        /**
        * @Change this to your sObject
        */
        public Asset asset;

        public String getnodeId() { return nodeId; }
        public Boolean[] getlevelFlag() { return levelFlag; }
        public Boolean[] getcloseFlag() { return closeFlag; }
        public String getnodeType() { return nodeType; }
        public Boolean getcurrentNode() { return currentNode; }


        /**
        * @Change this to your sObject
        */
        public Asset getasset() { return asset; }

        public void setnodeId( String n ) { this.nodeId = n; }
        public void setlevelFlag( Boolean l ) { this.levelFlag.add(l); }
        public void setlcloseFlag( Boolean l ) { this.closeFlag.add(l); }
        public void setnodeType( String nt ) { this.nodeType = nt; }
        public void setcurrentNode( Boolean cn ) { this.currentNode = cn; }

        /**
        * @Change this to your sObject
        */
        public void setasset( Asset a ) { this.asset = a; }

        /**
        * @Change the parameters to your sObject
        */
        public ObjectStructureMap( String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, Asset a ){

            this.nodeId         = nodeId;
            this.levelFlag      = levelFlag;
            this.closeFlag      = closeFlag;
            this.nodeType       = nodeType;
            this.currentNode    = currentNode;

            //Change this to your sObject  
            this.asset = a;
        }
    }
}