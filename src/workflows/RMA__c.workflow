<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Create_Email2Case_for_KVProduction</fullName>
        <ccEmails>VODProduction@kvh.com</ccEmails>
        <description>Create Email2Case for KVProduction</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>KV_Support/RMA_VOD_Repair</template>
    </alerts>
    <alerts>
        <fullName>Create_Email2Case_for_KVProduction_VOD_Exchange</fullName>
        <description>Create Email2Case for KVProduction - VOD Exchange</description>
        <protected>false</protected>
        <recipients>
            <recipient>krodrigues@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>KV_Support/RMA_VOD_Replaced_or_Vessel_Sold</template>
    </alerts>
    <alerts>
        <fullName>Email_Order_Admin_on_VOD_Returned_without_Order</fullName>
        <ccEmails>administration@videotel.com</ccEmails>
        <description>Email Order Admin on VOD Returned without Order</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Videotel_Admin_Templates/RMA_VOD_Received_for_Vessel_Sold_or_Exchange</template>
    </alerts>
    <alerts>
        <fullName>Email_Order_Administration_on_VOD_Returned_for_Vessel_Sold_or_Exchange</fullName>
        <ccEmails>administration@videotel.com</ccEmails>
        <description>Email Order Administration on VOD Returned for Vessel Sold or Exchange</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Videotel_Admin_Templates/RMA_VOD_Received_for_Vessel_Sold_or_Exchange</template>
    </alerts>
    <alerts>
        <fullName>Email_VOD_Production_RMA_for_Repair</fullName>
        <description>Email VOD Production RMA for Repair</description>
        <protected>false</protected>
        <recipients>
            <recipient>krodrigues@videotel.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>KV_Support/RMA_VOD_Repair</template>
    </alerts>
    <alerts>
        <fullName>VODProductionCase_Received_without_RMA</fullName>
        <ccEmails>vodproduction@kvh.com</ccEmails>
        <description>VODProductionCase - Received without RMA</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>KV_Support/RMA_VOD_Received_without_RMA</template>
    </alerts>
    <alerts>
        <fullName>VOD_RMA_received_for_Vessel_Sold_or_Exchange</fullName>
        <ccEmails>vodproduction@kvh.com</ccEmails>
        <description>VOD RMA received for Vessel Sold or Exchange</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>KV_Support/RMA_VOD_Replaced_or_Vessel_Sold</template>
    </alerts>
    <alerts>
        <fullName>Videotel_Send_email_to_owner</fullName>
        <description>Videotel: Send email to owner</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Videotel_Admin_Templates/RMA_date_received_any</template>
    </alerts>
    <alerts>
        <fullName>Videotel_Send_email_to_owner_v2</fullName>
        <description>Videotel: Send email to owner v2</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>administration@videotel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Videotel_Admin_Templates/RMA_date_received</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Date_Off_Hold</fullName>
        <description>Clear the Date off Hold when setting the RMA Status to On Hold</description>
        <field>Date_Unit_off_Hold__c</field>
        <name>Clear Date Off Hold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Payment_Terms</fullName>
        <field>Terms__c</field>
        <formula>Account__r.Terms_of_Payment__c</formula>
        <name>Update Payment Terms</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Total_Number_of_Days_on_Hold</fullName>
        <description>When adding a Date off Hold, update the Total Number of Customer Hold Days</description>
        <field>Total_Custom_Hold_Days__c</field>
        <formula>Most_Recent_Hold_Days__c +  Total_Custom_Hold_Days__c</formula>
        <name>Update the Total Number of Days on Hold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_owner_email</fullName>
        <field>Owner_Email__c</field>
        <formula>Order__r.Account__r.Owner.Email</formula>
        <name>Update the owner email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>RMA Off Customer Hold</fullName>
        <actions>
            <name>Update_the_Total_Number_of_Days_on_Hold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.Date_Unit_off_Hold__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Confirm that the RMA was updated to change the Date off Hold.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMA On Customer Hold</fullName>
        <actions>
            <name>Clear_Date_Off_Hold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.RMA_Status__c</field>
            <operation>equals</operation>
            <value>On Hold</value>
        </criteriaItems>
        <description>Confiirm that the RMA wuas updated to change the Date on Hold.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMA VOD Repair</fullName>
        <actions>
            <name>Email_VOD_Production_RMA_for_Repair</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.Date_Received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Reason_for_RMA__c</field>
            <operation>equals</operation>
            <value>Repair</value>
        </criteriaItems>
        <description>RMA - VOD Returned for Repair</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>VOD RMA Exchange-Sold Received</fullName>
        <actions>
            <name>Create_Email2Case_for_KVProduction_VOD_Exchange</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>VOD_RMA_Received</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.Date_Received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Reason_for_RMA__c</field>
            <operation>equals</operation>
            <value>Vessel SOLD</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Received_By__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Create Case for VOD RMA Vessel sold or unit exchanged</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Videotel%3A KV RMA automatic emails</fullName>
        <actions>
            <name>Videotel_Send_email_to_owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.Date_Received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Reason_for_RMA__c</field>
            <operation>equals</operation>
            <value>Received without RMA</value>
        </criteriaItems>
        <description>sends automatic emails when reason is &quot;received without rma&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Videotel%3A KV RMA automatic emails part 2</fullName>
        <actions>
            <name>Videotel_Send_email_to_owner_v2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>RMA__c.Date_Received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Reason_for_RMA__c</field>
            <operation>notEqual</operation>
            <value>Received without RMA</value>
        </criteriaItems>
        <description>sends automatic emails when reason is not &quot;received without rma&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Videotel%3A Update RMA With Owner Email</fullName>
        <actions>
            <name>Update_the_owner_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED( KV_Owner_Email__c ), Owner_Email__c = null)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>VOD_RMA_Received</fullName>
        <assignedTo>krodrigues@videotel.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>VOD RMA for unit exchange or Vessel being sold had been received. Please update the Order.</description>
        <dueDateOffset>4</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>RMA__c.Date_Received__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>VOD RMA Received</subject>
    </tasks>
    <tasks>
        <fullName>VOD_RMA_Received_Without_Order</fullName>
        <assignedTo>krodrigues@videotel.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>VOD RMA has been received without an Order. Please research the orders to confirm, and update the RMA &amp; Order</description>
        <dueDateOffset>4</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>RMA__c.Date_Received__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>VOD RMA Received Without Order</subject>
    </tasks>
</Workflow>
