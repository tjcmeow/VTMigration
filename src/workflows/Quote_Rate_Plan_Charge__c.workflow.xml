<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Annual_Net_Total</fullName>
        <field>Annual_Net_Total__c</field>
        <formula>IF(ISPICKVAL(Price_Type__c, &apos;Quarterly&apos;), (4*Net_Total__c), IF(ISPICKVAL(Price_Type__c, &apos;Half Yearly&apos;), (2*Net_Total__c), IF(ISPICKVAL(Price_Type__c, &apos;Monthly&apos;), (12*Net_Total__c), Net_Total__c)))</formula>
        <name>Update Annual Net Total</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Annual_Row_Total</fullName>
        <field>Annual_Row_Total__c</field>
        <formula>Annual_Net_Total__c + Annual_VAT__c</formula>
        <name>Update Annual Row Total</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Annual_VAT</fullName>
        <field>Annual_VAT__c</field>
        <formula>Annual_Net_Total__c * VAT_Percentage__c</formula>
        <name>Update Annual VAT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Calculate Annual Net Total</fullName>
        <actions>
            <name>Update_Annual_Net_Total</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote_Rate_Plan_Charge__c.Net_Total__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Calculate Annual Row Total</fullName>
        <actions>
            <name>Update_Annual_Row_Total</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote_Rate_Plan_Charge__c.Row_Total__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Calculate Annual VAT</fullName>
        <actions>
            <name>Update_Annual_VAT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote_Rate_Plan_Charge__c.VAT__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
