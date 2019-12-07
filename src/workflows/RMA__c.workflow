<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Order_Administration_on_VOD_Returned_for_Vessel_Sold_or_Exchange</fullName>
        <ccEmails>administration@videotel.com</ccEmails>
        <description>Email Order Administration on VOD Returned for Vessel Sold or Exchange</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>KV_Support/RMA_VOD_Replaced_or_Vessel_Sold</template>
    </alerts>
    <alerts>
        <fullName>VOD_RMA_received_for_Vessel_Sold_or_Exchange</fullName>
        <ccEmails>vodproduction@kvh.com</ccEmails>
        <description>VOD RMA received for Vessel Sold or Exchange</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>KV_Support/RMA_VOD_Replaced_or_Vessel_Sold</template>
    </alerts>
</Workflow>
