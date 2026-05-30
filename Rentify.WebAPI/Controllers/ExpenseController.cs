using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    [Authorize(Roles = "Vlasnik,Admin")]
    public class ExpenseController
        : BaseCRUDController<ExpenseResponse, ExpenseSearchObject, ExpenseUpsertRequest, ExpenseUpsertRequest>
    {
        public ExpenseController(IExpenseService service) : base(service)
        {
        }
    }
}
