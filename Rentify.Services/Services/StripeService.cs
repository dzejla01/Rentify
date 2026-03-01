using Stripe;

namespace Rentify.WebAPI.Services
{
    public class StripeService
    {
        public async Task<PaymentIntent> CreatePaymentIntentAsync(
            double amount,
            string currency,
            Dictionary<string, string> metadata)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(amount * 100), // 2 decimal currency
                Currency = currency,
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true
                },
                Metadata = metadata
            };

            var service = new PaymentIntentService();
            return await service.CreateAsync(options);
        }
    }
}