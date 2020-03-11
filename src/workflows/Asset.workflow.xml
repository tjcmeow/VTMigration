<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Item</fullName>
        <field>Item__c</field>
        <formula>Product2.ProductCode</formula>
        <name>Item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Item_Description</fullName>
        <description>This action copies the related Product description to the Asset Item Description field</description>
        <field>Item_Description__c</field>
        <formula>LEFT(Product2.Description, 250)</formula>
        <name>Item Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Previous_Account_Value</fullName>
        <field>Previous_Account__c</field>
        <formula>PRIORVALUE(Account_Name__c)</formula>
        <name>Update Previous Account Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Asset Item Info</fullName>
        <actions>
            <name>Item</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Item_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updates the Asset.Item__c and and Asset.Item_Description__c fields with up-to-date values from the Product table if they exist (jthom 12/11/2012).</description>
        <formula>AND(NOT( ISBLANK( Product2.ProductCode )) , NOT (ISBLANK( Product2.Description ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Previous Account</fullName>
        <actions>
            <name>Update_Previous_Account_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( AccountId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
