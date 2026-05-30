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
    public class BuildingTypeService
        : BaseCRUDService<BuildingTypeResponse, BuildingTypeSearchObject, BuildingType, BuildingTypeUpsertRequest, BuildingTypeUpsertRequest>,
          IBuildingTypeService
    {
        public BuildingTypeService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<BuildingType> ApplyFilter(IQueryable<BuildingType> query, BuildingTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.Trim().ToLower()));

            if (!string.IsNullOrWhiteSpace(search.FTS))
                query = query.Where(x => x.Name.ToLower().Contains(search.FTS.Trim().ToLower()));

            return base.ApplyFilter(query, search);
        }

        protected override async Task BeforeDelete(BuildingType entity)
        {
            var isUsed = await _context.Properties
                .AnyAsync(x => x.BuildingTypeId == entity.Id);

            if (isUsed)
                throw new UserException("Tip nekretnine nije moguće obrisati jer se koristi na postojećim nekretninama.");

            await base.BeforeDelete(entity);
        }
    }
}
