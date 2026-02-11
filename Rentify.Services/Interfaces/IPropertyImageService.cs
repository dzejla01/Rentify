using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IPropertyImageService
        : ICRUDService<PropertyImageResponse, PropertyImageSearchObject, PropertyImageUpsertRequest, PropertyImageUpsertRequest>
    {
    }
}
