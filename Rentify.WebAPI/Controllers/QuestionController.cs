using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.WebAPI.Controllers;

namespace Rentify.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class QuestionController 
        : BaseCRUDController<QuestionResponse, QuestionSearchObject, QuestionUpsertRequest, QuestionUpsertRequest>
    {
        public QuestionController(IQuestionService service) : base(service)
        {
        }
    }
}