
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IQuestionService 
        : ICRUDService<QuestionResponse, QuestionSearchObject, QuestionUpsertRequest, QuestionUpsertRequest>
    {
    }
}