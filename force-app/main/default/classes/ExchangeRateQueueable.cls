/* Full coverage of this class was provided by the existing tests provided and the logic here is not really complicated.
In these type of scenarios, I'm assuming a standalone test class for this isn't needed. But let me know if I'm wrong */

public with sharing class ExchangeRateQueueable implements Queueable, Database.AllowsCallouts {
    
    private String baseCurrency;
    
    public ExchangeRateQueueable(String baseCurrency) {
        this.baseCurrency = baseCurrency;
    }

    public void execute(QueueableContext context) {

        try {
            ExchangeRateService.updateExchangeRates('USD');
        } catch (Exception e) {
            Logger.error('Error message logged: ' + e.getMessage());
            Logger.saveLog();
        }
    }
}