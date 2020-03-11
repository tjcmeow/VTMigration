<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Next_Uplift_Date_Field</fullName>
        <field>Next_Uplift_Date__c</field>
        <formula>If ( ISPICKVAL(Uplift_Frequency__c, &apos;Monthly&apos;) , Service_Activation_Date__c + 30 - 10,
If ( ISPICKVAL(Uplift_Frequency__c, &apos;Quarterly&apos;) , Service_Activation_Date__c + 90 - 10,
If ( ISPICKVAL(Uplift_Frequency__c, &apos;Half Yearly&apos;) , Service_Activation_Date__c + 180 - 10,
If ( ISPICKVAL(Uplift_Frequency__c, &apos;Annual&apos;) , Service_Activation_Date__c + 365 - 10,
null
)
)
)
)</formula>
        <name>Update Next Uplift Date Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unit_Price_for_1st_Year</fullName>
        <field>Unit_Price_1st_Year__c</field>
        <formula>Row_Total__c</formula>
        <name>Update Unit Price for 1st Year</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Year_1_Net_Total</fullName>
        <field>Year_1_Net_Total__c</field>
        <formula>IF(ISPICKVAL(Price_Type__c, &apos;Quarterly&apos;), (4*Net_Total__c), IF(ISPICKVAL(Price_Type__c, &apos;Half Yearly&apos;), (2*Net_Total__c), IF(ISPICKVAL(Price_Type__c, &apos;Monthly&apos;), (12*Net_Total__c), Net_Total__c)))</formula>
        <name>Update Year 1 Net Total</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Year_1_Row_Total</fullName>
        <field>Year_1_Row_Total__c</field>
        <formula>Year_1_Net_Total__c + Year_1_VAT__c</formula>
        <name>Update Year 1 Row Total</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Year_1_VAT</fullName>
        <field>Year_1_VAT__c</field>
        <formula>Year_1_Net_Total__c * VAT_Percentage__c</formula>
        <name>Update Year 1 VAT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Videotel%3A Calculate Order Subscription Charges Year 1 values</fullName>
        <actions>
            <name>Update_Year_1_Net_Total</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Year_1_Row_Total</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Year_1_VAT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Videotel%3A Update Next Uplift Date</fullName>
        <actions>
            <name>Update_Next_Uplift_Date_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Job_Rate_Plan_Charge__c.Service_Activation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Job_Rate_Plan_Charge__c.Next_Uplift_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Job_Rate_Plan_Charge__c.Uplift__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Videotel%3A Update Unit Price for 1st Year</fullName>
        <actions>
            <name>Update_Unit_Price_for_1st_Year</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
