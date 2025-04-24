/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 * Students will implement the properties and methods to process the data
 */
public class ExchangeRateWrapper {
    
    public String result;
    public String documentation;
    public String terms_of_use;
    public String time_last_update_utc;
    public String time_next_update_utc;
    public String time_next_update_unix;
    public String base_code;
    public String time_last_update_unix;
    public DateTime dateTimeRatesLastUpdated;
    public Map<String, Decimal> conversion_rates;
    public String externalId;
    public List<Exchange_Rate__c> exchangeRates;
    public Exchange_Rate__c rate;
    public String currentTargetCurrency;
    Set<String> missingKeys;
    String missingKeysAsString;
    public final String MISSING_KEY_START = 'The following expected data points were not returned from the callout: ';
    String finalErrorString;
    
    /**
     * @description Converts the wrapper data to a list of Exchange_Rate__c records
     * @return List<Exchange_Rate__c> The list of exchange rate records
     */
    public List<Exchange_Rate__c> toExchangeRates() {

        checkForMissingTopLevelKeys();

        exchangeRates = new List<Exchange_Rate__c>();
        convertUnixDateTimeRatesLastUpdated();
        for (String targetCurrency : conversion_rates.keySet()) {
            currentTargetCurrency = targetCurrency;
            checkForMissingExchangeRate();

            generateExternalId();
            rate = new Exchange_Rate__c();
            rate.Name = externalId;
            rate.Base_Currency__c = base_code; 
            rate.External_Id__c = externalId; 
            rate.Last_Updated__c = dateTimeRatesLastUpdated;
            rate.Rate__c = conversion_rates.get(currentTargetCurrency);
            rate.Target_Currency__c = currentTargetCurrency; 

            exchangeRates.add(rate);
        }
        upsertExchangeRates();
        return exchangeRates;
    } 
    
    /**
     * @description Static method to parse the JSON response into the wrapper class
     * @param jsonResponse The JSON response from the API
     * @return ExchangeRateWrapper The parsed wrapper instance
     */
    public static ExchangeRateWrapper parse(String jsonResponse) {
        return (ExchangeRateWrapper)System.JSON.deserializeStrict(jsonResponse, ExchangeRateWrapper.class);
    }

    public void generateExternalId() {
        externalId = base_code + '_' + currentTargetCurrency;
    }

    public void convertUnixDateTimeRatesLastUpdated() {
        dateTimeRatesLastUpdated = DateTime.newInstance(long.valueOf(time_last_update_unix) * 1000);
    }

    public void checkForMissingTopLevelKeys() {
        missingKeys = new Set<String>();
        if (base_code == null) {
            missingKeys.add('base_code');
        }
        if (time_last_update_unix == null) {
            missingKeys.add('time_last_update_unix');
        }
        if (conversion_rates == null) {
            missingKeys.add('conversion_rates');
        }
        if (!missingKeys.isEmpty()) {
            missingKeysAsString = missingKeys.toString();
            finalErrorString = MISSING_KEY_START + missingKeysAsString;
            Logger.error(finalErrorString);
            Logger.saveLog();
            throw new CalloutException(finalErrorString);
        }
    }

    
    public void checkForMissingExchangeRate() {
        if (conversion_rates.get(currentTargetCurrency) == null) {
            finalErrorString = MISSING_KEY_START + 'Exchange Rate from ' + base_code + ' to ' + currentTargetCurrency;
            Logger.error(finalErrorString);
            Logger.saveLog();
            throw new CalloutException(finalErrorString);
        }
    }

    public void upsertExchangeRates() {
        try {
            upsert exchangeRates External_Id__c;
        } catch (Exception e) {
            finalErrorString = 'An error occurred: ' + e.getMessage();
            Logger.error(finalErrorString);
            Logger.saveLog();
            throw new DmlException(finalErrorString);
        }
    }
}