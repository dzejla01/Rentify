using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    public class StatusController
        : BaseCRUDController<StatusResponse, StatusSearchObject, StatusUpsertRequest, StatusUpsertRequest>
    {
        public StatusController(IStatusService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<StatusResponse>> Get([FromQuery] StatusSearchObject? search = null)
            => base.Get(search);

        [AllowAnonymous]
        public override Task<StatusResponse?> GetById(int id)
            => base.GetById(id);

        [Authorize(Roles = "Admin")]
        public override Task<StatusResponse> Create([FromBody] StatusUpsertRequest request)
            => base.Create(request);

        [Authorize(Roles = "Admin")]
        public override Task<StatusResponse?> Update(int id, [FromBody] StatusUpsertRequest request)
            => base.Update(id, request);

        [Authorize(Roles = "Admin")]
        public override Task<bool> Delete(int id)
            => base.Delete(id);
    }
}
