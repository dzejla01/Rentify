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
    public class PropertyService : BaseCRUDService<PropertyResponse, PropertySearchObject, Database.Property, PropertyInsertRequest, PropertyUpdateRequest>, IPropertyService
    {
        public PropertyService(RentifyDbContext context, IMapper mapper) : base(context, mapper)
        {

        }

        protected override IQueryable<Property> ApplyFilter(IQueryable<Property> query, PropertySearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                var name = search.Name.Trim().ToLower();
                query = query.Where(x => x.Name.ToLower().Contains(name));
            }

            if (!string.IsNullOrWhiteSpace(search.City))
            {
                var city = search.City.Trim().ToLower();
                query = query.Where(x => x.City.ToLower().Contains(city));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }


            if (search.MinPriceMonth.HasValue)
            {
                query = query.Where(x => x.PricePerMonth >= search.MinPriceMonth.Value);
            }

            if (search.MaxPriceMonth.HasValue)
            {
                query = query.Where(x => x.PricePerMonth <= search.MaxPriceMonth.Value);
            }

            if (search.MinPriceDays.HasValue)
            {
                query = query.Where(x => x.PricePerDay >= search.MinPriceDays.Value);
            }

            if (search.MaxPriceDays.HasValue)
            {
                query = query.Where(x => x.PricePerDay <= search.MaxPriceDays.Value);
            }

            return base.ApplyFilter(query, search);
        }
    }
}
