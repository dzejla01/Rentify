using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IPaymentService 
        : ICRUDService<PaymentResponse, PaymentSearchObject, PaymentUpsertRequest, PaymentUpsertRequest>
    {
        Task<object> CreateNewPaymentIntentAsync(CreatePaymentIntentRequest request);

        Task HandlePaymentIntentSucceededAsync(
            string paymentIntentId,
            IDictionary<string, string> metadata);

        Task HandlePaymentIntentFailedAsync(
            string paymentIntentId,
            IDictionary<string, string> metadata);

        Task HandlePaymentIntentCanceledAsync(
            string paymentIntentId,
            IDictionary<string, string> metadata);
    }
}