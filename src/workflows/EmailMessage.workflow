<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Is_New_is_False</fullName>
        <field>Is_New__c</field>
        <literalValue>0</literalValue>
        <name>Is New is False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Case_Status</fullName>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>New Case Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Incoming_Email</fullName>
        <field>Status</field>
        <literalValue>New Incoming Email</literalValue>
        <name>New Incoming Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reopen_Case</fullName>
        <description>Changing the status on reopening a case</description>
        <field>Status</field>
        <literalValue>New Incoming Email</literalValue>
        <name>Reopen Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>New Status on First Incoming Email</fullName>
        <actions>
            <name>Is_New_is_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>New_Case_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_New__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule will reopen a case when a new incoming email is present on a closed case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Reopen Case on Incoming Email</fullName>
        <actions>
            <name>Reopen_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_New__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This rule will reopen a case when a new incoming email is present on a closed case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Created Date</fullName>
        <actions>
            <name>New_Incoming_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
