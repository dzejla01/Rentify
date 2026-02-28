using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{

    public class PaymentController
        : BaseCRUDController<PaymentResponse, PaymentSearchObject, PaymentUpsertRequest, PaymentUpsertRequest>
    {
        public PaymentController(IPaymentService service) : base(service)
        {
        }
    }
}
