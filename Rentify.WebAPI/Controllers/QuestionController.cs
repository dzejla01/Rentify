using Microsoft.AspNetCore.Authorization;
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

        [Authorize(Roles = "Korisnik")]
        public override Task<QuestionResponse> Create([FromBody] QuestionUpsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Korisnik")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [Authorize(Roles = "Korisnik")]
        public override Task<QuestionResponse?> Update(int id, [FromBody] QuestionUpsertRequest request)
        {
            return base.Update(id, request);
        }
    }
}