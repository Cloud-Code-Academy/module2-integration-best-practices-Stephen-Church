// Added this class so I could test a couple of the error handling methods that didn't get coverage through the existing tests
@isTest
public with sharing class ExchangeRateWrapperTest {

    @isTest
    static void checkForMissingTopLevelKeys_error() {

        ExchangeRateWrapper errorWrapper = new ExchangeRateWrapper();
        String errorString = null;

        Test.startTest();
        try {
            errorWrapper.checkForMissingTopLevelKeys();
        } catch (Exception e) {
            errorString = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(errorString.contains('base_code'), 'base_code should be in the error message since it is missing');
        Assert.isTrue(errorString.contains('conversion_rates'), 'conversion_rates should be in the error message since it is missing');
        Assert.isTrue(errorString.contains('time_last_update_unix'), 'time_last_update_unix should be in the error message since it is missing');
    }

    @isTest
    static void checkForMissingExchangeRate_error() {

        ExchangeRateWrapper errorWrapper = new ExchangeRateWrapper();
        errorWrapper.base_code = 'USD';
        errorWrapper.time_last_update_unix = '123456789';
        Map<String, Decimal> dummyRates = new Map<String, Decimal>();
        dummyRates.put('EUR', null);
        errorWrapper.conversion_rates = dummyRates;
        errorWrapper.currentTargetCurrency = 'EUR';

        String errorString = null;

        Test.startTest();
        try {
            errorWrapper.checkForMissingExchangeRate();
        } catch (Exception e) {
            errorString = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(errorString.contains('USD to EUR'), 'USD to EUR should be in the error message since this exchange rate is missing');
    }

    @isTest
    static void upsertExchangeRates_error() {

        ExchangeRateWrapper errorWrapper = new ExchangeRateWrapper();
        Exchange_Rate__c rate = new Exchange_Rate__c();
        errorWrapper.exchangeRates = new List<Exchange_Rate__c>();
        errorWrapper.exchangeRates.add(rate);
        Boolean exceptionCaught = false;

        Test.startTest();
        try {
            errorWrapper.upsertExchangeRates();
        } catch (Exception e) {
            exceptionCaught = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, 'An exception should have been caught because the record had missing required fields.');
    }
}