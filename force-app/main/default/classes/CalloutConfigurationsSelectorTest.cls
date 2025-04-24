@isTest
public with sharing class CalloutConfigurationsSelectorTest {

    @isTest
    static void getSingleConfigBasedOnDeveloperName_recordReturned() {

        Callout_Configuration__mdt config = [SELECT Id, DeveloperName FROM Callout_Configuration__mdt LIMIT 1];
        
        Test.startTest();
        Callout_Configuration__mdt returnedConfig = CalloutConfigurationsSelector.getSingleConfigBasedOnDeveloperName(config.DeveloperName);
        Test.stopTest();

        Assert.areEqual(config.DeveloperName, returnedConfig.DeveloperName, 'The returned Callout Config does not have the expected DeveloperName.');
    }
}