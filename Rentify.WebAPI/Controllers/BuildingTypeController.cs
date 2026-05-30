using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    public class BuildingTypeController
        : BaseCRUDController<BuildingTypeResponse, BuildingTypeSearchObject, BuildingTypeUpsertRequest, BuildingTypeUpsertRequest>
    {
        public BuildingTypeController(IBuildingTypeService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<BuildingTypeResponse>> Get([FromQuery] BuildingTypeSearchObject? search = null)
            => base.Get(search);

        [AllowAnonymous]
        public override Task<BuildingTypeResponse?> GetById(int id)
            => base.GetById(id);

        [Authorize(Roles = "Admin")]
        public override Task<BuildingTypeResponse> Create([FromBody] BuildingTypeUpsertRequest request)
            => base.Create(request);

        [Authorize(Roles = "Admin")]
        public override Task<BuildingTypeResponse?> Update(int id, [FromBody] BuildingTypeUpsertRequest request)
            => base.Update(id, request);

        [Authorize(Roles = "Admin")]
        public override Task<bool> Delete(int id)
            => base.Delete(id);
    }
}
