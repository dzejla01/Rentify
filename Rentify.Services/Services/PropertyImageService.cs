using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;
using System.Linq;
using System.Threading.Tasks;

namespace Rentify.Services.Services
{
    public class PropertyImageService
        : BaseCRUDService<PropertyImageResponse, PropertyImageSearchObject, PropertyImage, PropertyImageUpsertRequest, PropertyImageUpsertRequest>,
          IPropertyImageService
    {
        public PropertyImageService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<PropertyImage> ApplyFilter(IQueryable<PropertyImage> query, PropertyImageSearchObject search)
        {
            if (search.PropertyId.HasValue)
            {
                query = query.Where(p => p.PropertyId == search.PropertyId);
            }
            return base.ApplyFilter(query, search);
        }

      
    }
}
