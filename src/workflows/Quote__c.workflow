<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Recalculate_Check_Box</fullName>
        <field>Recalculate__c</field>
        <literalValue>1</literalValue>
        <name>Update Recalculate Check Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_On_Quote_Approve</fullName>
        <field>Approved_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Record Type On Quote (Approve)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_On_Quote_RentPending</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Pending_Approval_Rental</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type On Quote(RentPending)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_On_Quote_SalePending</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Sales_Quote</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type On Quote(SalePending)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Recalculate Values On Quote</fullName>
        <actions>
            <name>Update_Recalculate_Check_Box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(Vat_Roll_Up__c != VAT__c) || ( ISCHANGED(IITIntended_Use__c)) || ISCHANGED( Shipping_Account__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Quote Record Type To Approve</fullName>
        <actions>
            <name>Update_Record_Type_On_Quote_Approve</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Discount_Value__c == 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Quote Record Type To Pending Rental</fullName>
        <actions>
            <name>Update_Record_Type_On_Quote_RentPending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote__c.Discount_Value__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote__c.Approved_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote__c.Quote_Type__c</field>
            <operation>equals</operation>
            <value>Rental</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Quote Record Type To Pending Sale</fullName>
        <actions>
            <name>Update_Record_Type_On_Quote_SalePending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote__c.Discount_Value__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote__c.Approved_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote__c.Quote_Type__c</field>
            <operation>equals</operation>
            <value>Sale</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
