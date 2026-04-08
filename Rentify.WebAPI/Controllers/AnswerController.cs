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
    public class AnswerController 
        : BaseCRUDController<AnswerResponse, AnswerSearchObject, AnswerUpsertRequest, AnswerUpsertRequest>
    {
        public AnswerController(IAnswerService service) : base(service)
        {
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<AnswerResponse> Create([FromBody] AnswerUpsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<AnswerResponse?> Update(int id, [FromBody] AnswerUpsertRequest request)
        {
            return base.Update(id, request);
        }

    }
}