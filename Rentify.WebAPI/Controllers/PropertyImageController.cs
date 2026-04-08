using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    public class PropertyImageController
        : BaseCRUDController<PropertyImageResponse, PropertyImageSearchObject, PropertyImageUpsertRequest, PropertyImageUpsertRequest>
    {
        public PropertyImageController(
            IPropertyImageService service)
            : base(service)
        {
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<PropertyImageResponse> Create([FromBody] PropertyImageUpsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<PropertyImageResponse?> Update(int id, [FromBody] PropertyImageUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
