using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rentify.Services.Services
{
    public class PropertyService : BaseCRUDService<PropertyResponse, PropertySearchObject, Database.Property,PropertyInsertRequest, PropertyUpdateRequest>, IPropertyService
    {
        public PropertyService(RentifyDbContext context, IMapper mapper) : base(context, mapper)
        {

        }

        protected override IQueryable<Property> ApplyFilter(IQueryable<Property> query, PropertySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId);
            }

            return base.ApplyFilter(query, search);
        }
    }
}
