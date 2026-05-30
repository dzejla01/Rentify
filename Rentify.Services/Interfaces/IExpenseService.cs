using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IExpenseService
        : ICRUDService<ExpenseResponse, ExpenseSearchObject, ExpenseUpsertRequest, ExpenseUpsertRequest>
    {
    }
}
