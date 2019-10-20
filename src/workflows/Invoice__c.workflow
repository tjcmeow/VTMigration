<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Cancel_Invoice</fullName>
        <field>Invoice_Status__c</field>
        <literalValue>Cancelled</literalValue>
        <name>Cancel Invoice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invalid_Invoice_Status</fullName>
        <field>Invoice_Status__c</field>
        <literalValue>Invalid</literalValue>
        <name>Invalid Invoice Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invoice_Date_Paid</fullName>
        <description>When the Payment Status is updated to Paid, add Date Pad = Today</description>
        <field>Date_Paid__c</field>
        <formula>TODAY()</formula>
        <name>Invoice Date Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Due_Date_Field_On_Invoice</fullName>
        <field>Due_Date__c</field>
        <formula>IF (Payment_Terms__c == &quot;Net 30&quot;, Invoice_Date__c + 30, IF (Payment_Terms__c == &quot;Net 45&quot;, Invoice_Date__c + 45, IF (Payment_Terms__c == &quot;Net 60&quot;, Invoice_Date__c + 60, Invoice_Date__c)))</formula>
        <name>Update Due Date Field On Invoice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Email_Sent_Field</fullName>
        <field>Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Update Invoice Email Sent Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Cancel Invoice from Credit Note</fullName>
        <actions>
            <name>Cancel_Invoice</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.For_Admin_Use__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invalid Invoice Status</fullName>
        <actions>
            <name>Invalid_Invoice_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISPICKVAL( PRIORVALUE( Invoice_Status__c ), &apos;Draft&apos;), ISPICKVAL(Invoice_Status__c, &apos;Cancelled&apos;), NOT(ISNULL(TEXT(Cancellation_Reason__c))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Paid</fullName>
        <actions>
            <name>Invoice_Date_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>And(IsChanged(Unpaid_Amount__c), (Payment_Status__c = &quot;Paid&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Due Date For Consolidate Invoices</fullName>
        <actions>
            <name>Update_Due_Date_Field_On_Invoice</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Order_ID__c</field>
            <operation>equals</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
