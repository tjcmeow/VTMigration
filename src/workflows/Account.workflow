<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Account_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>KV_Prospect</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Account Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Add KV Prospect Record Type</fullName>
        <actions>
            <name>Update_Account_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Record_Type_Hidden__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
