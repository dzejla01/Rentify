using Rentify.Model.ResponseObject;
using Rentify.Model.RequestObjects;
using Rentify.Model.SearchObjects;
using Rentify.Model.ResponseObjects;

namespace Rentify.Services.Interfaces
{
    public interface IAnswerService : ICRUDService<AnswerResponse, AnswerSearchObject, AnswerUpsertRequest, AnswerUpsertRequest>
    {
    }
}