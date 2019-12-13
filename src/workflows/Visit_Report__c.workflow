<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_KV_of_New_Visit_Report</fullName>
        <description>Notify KV of New Visit Report</description>
        <protected>false</protected>
        <recipients>
            <recipient>aclarkson@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bgarranchan@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cchapman@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eforrester@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jbarreto@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nbrown@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Videotel_Sales_Templates/Notify_of_New_Visit_Report</template>
    </alerts>
    <rules>
        <fullName>New Videotel Report</fullName>
        <actions>
            <name>Notify_KV_of_New_Visit_Report</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
