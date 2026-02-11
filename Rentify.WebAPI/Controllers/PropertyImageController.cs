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
    }
}
