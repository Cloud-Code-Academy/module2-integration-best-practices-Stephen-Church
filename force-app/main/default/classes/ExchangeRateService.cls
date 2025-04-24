/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */

public class ExchangeRateService {
    
    private static final String CALLOUT_CONFIG_NAME = 'ExchangeRate_API_Get';
    private static String errorString = 'Error making callout: ';
    
    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public static ExchangeRateWrapper getLatestRates(String baseCurrency) {
        Callout_Configuration__mdt calloutDetails = CalloutConfigurationsSelector.getSingleConfigBasedOnDeveloperName(CALLOUT_CONFIG_NAME);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + calloutDetails.Named_Credential_Name__c + calloutDetails.Static_Base_URL_Addition__c + baseCurrency);
        request.setMethod(calloutDetails.Method__c);
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try {
            response = http.send(request);
        } catch (CalloutException e) {
            errorString += e.getMessage();
            Logger.error(errorString);
            Logger.saveLog();
            throw new CalloutException(errorString);
        }
        if (response.getStatusCode() != 200) {
            errorString += 'Status code: ' + response.getStatusCode() + '. Response body: ' + response.getBody();
            Logger.error(errorString);
            Logger.saveLog();
            throw new CalloutException(errorString);
        }
        ExchangeRateWrapper rateData = ExchangeRateWrapper.parse(response.getBody());
        return rateData;
    }
    
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        return rateData.toExchangeRates(); 
    }
    
    /**
     * @description Combines getting and processing rates into a single operation
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> updateExchangeRates(String baseCurrency) {
        ExchangeRateWrapper rateData = getLatestRates(baseCurrency);
        return processRates(rateData);
    }
}