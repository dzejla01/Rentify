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
    public class AnswerController 
        : BaseCRUDController<AnswerResponse, AnswerSearchObject, AnswerUpsertRequest, AnswerUpsertRequest>
    {
        public AnswerController(IAnswerService service) : base(service)
        {
        }
    }
}