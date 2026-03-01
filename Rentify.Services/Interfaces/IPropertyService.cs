using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IPropertyService
        : ICRUDService<PropertyResponse, PropertySearchObject, PropertyInsertRequest, PropertyUpdateRequest>
    {
        public Task<List<PropertyResponse>> GetRecommendedPropertiesAsync(int userId, int take = 5);
    }
}
