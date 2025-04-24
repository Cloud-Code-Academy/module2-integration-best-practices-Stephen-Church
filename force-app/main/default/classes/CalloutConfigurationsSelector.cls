public with sharing class CalloutConfigurationsSelector {

    public static Callout_Configuration__mdt getSingleConfigBasedOnDeveloperName(String calloutConfigDeveloperName) {

        Callout_Configuration__mdt calloutConfig = [
            SELECT Id, DeveloperName, Named_Credential_Name__c, Static_Base_URL_Addition__c, Method__c
            FROM Callout_Configuration__mdt
            WHERE DeveloperName = :calloutConfigDeveloperName
            LIMIT 1
        ];
        return calloutConfig;
    }
}