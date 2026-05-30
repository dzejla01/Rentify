using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using System.Linq;
using System.Threading.Tasks;

namespace Rentify.Services.Services
{
    public class CityService
        : BaseCRUDService<CityResponse, CitySearchObject, City, CityUpsertRequest, CityUpsertRequest>,
          ICityService
    {
        public CityService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.Trim().ToLower()));

            if (!string.IsNullOrWhiteSpace(search.FTS))
                query = query.Where(x => x.Name.ToLower().Contains(search.FTS.Trim().ToLower()));

            return base.ApplyFilter(query, search);
        }

        protected override async Task BeforeDelete(City entity)
        {
            var isUsed = await _context.Properties
                .AnyAsync(x => x.CityId == entity.Id);

            if (isUsed)
                throw new UserException("Grad nije moguće obrisati jer se koristi na postojećim nekretninama.");

            await base.BeforeDelete(entity);
        }
    }
}
