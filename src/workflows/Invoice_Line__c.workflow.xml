<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Invoice_Line_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Invoice Line Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Legal_Entity</fullName>
        <field>Legal_Entity__c</field>
        <formula>TEXT(Job__r.Legal_Entity__c)</formula>
        <name>Update Legal Entity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Invoice__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Master_Order_ID_Field_On_invoice</fullName>
        <field>Master_Order_ID__c</field>
        <formula>Job__r.Master_Order__r.Id</formula>
        <name>Update Master Order ID Field On invoice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Invoice__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Master_Order_Name_Field_On_Invoic</fullName>
        <field>Master_Order_Name__c</field>
        <formula>Job__r.Master_Order__r.Name</formula>
        <name>Update Master Order Name Field On Invoic</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Invoice__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Revenue_Recognition_Date</fullName>
        <field>Revenue_Recognition_Date__c</field>
        <formula>Service_Start_Date__c</formula>
        <name>Update Revenue Recognition Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Revenue_Recognition_End_Date</fullName>
        <field>RevenueRecognitionEndDateNew__c</field>
        <formula>If( Service_End_Date__c != null, Service_End_Date__c, Service_Start_Date__c )</formula>
        <name>Update Revenue Recognition End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_payment_terms_field</fullName>
        <field>Master_Order_Payment_Terms__c</field>
        <formula>IF( Invoice__r.Order__c == NULL, TEXT (Job__r.Master_Order__r.Payment_Terms__c), TEXT( Job__r.Payment_Terms__c ))</formula>
        <name>update Master Order payment terms field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Invoice__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Cancelled to Draft</fullName>
        <actions>
            <name>Invoice_Line_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Line__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice__c.Invoice_Status__c</field>
            <operation>notEqual</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Line Update Date</fullName>
        <actions>
            <name>Update_Revenue_Recognition_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Revenue_Recognition_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Master Order On Invoice</fullName>
        <actions>
            <name>Update_Master_Order_ID_Field_On_invoice</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Master_Order_Name_Field_On_Invoic</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Order_ID__c</field>
            <operation>equals</operation>
            <value>NULL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Line__c.Sequence_No__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Legal Entity On Invoice</fullName>
        <actions>
            <name>Update_Legal_Entity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Line__c.Sequence_No__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Payment Terms On Invoice</fullName>
        <actions>
            <name>update_payment_terms_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Line__c.Sequence_No__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
