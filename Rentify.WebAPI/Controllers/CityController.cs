using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    public class CityController
        : BaseCRUDController<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>
    {
        public CityController(ICityService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<CityResponse>> Get([FromQuery] CitySearchObject? search = null)
            => base.Get(search);

        [AllowAnonymous]
        public override Task<CityResponse?> GetById(int id)
            => base.GetById(id);

        [Authorize(Roles = "Admin")]
        public override Task<CityResponse> Create([FromBody] CityUpsertRequest request)
            => base.Create(request);

        [Authorize(Roles = "Admin")]
        public override Task<CityResponse?> Update(int id, [FromBody] CityUpsertRequest request)
            => base.Update(id, request);

        [Authorize(Roles = "Admin")]
        public override Task<bool> Delete(int id)
            => base.Delete(id);
    }
}
