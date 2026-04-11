using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;

namespace Rentify.Services.Services
{
    public class FavoriteService 
        : BaseCRUDService<FavoriteResponse, FavoriteSearchObject, Favorite, FavoriteUpsertRequest, FavoriteUpsertRequest>, IFavoriteService
    {
        public FavoriteService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Favorite> ApplyFilter(IQueryable<Favorite> query,FavoriteSearchObject search)
        {
            //query = query.Include(x => x.User)
            //             .Include(x => x.Property);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Favorite> AddInclude(IQueryable<Favorite> query, FavoriteSearchObject search)
        {
            if (search.IncludeUser.HasValue)
                query = query.Include(x => x.User);

            if (search.IncludeProperty.HasValue)
                query = query.Include(x => x.Property);

            if (search.IncludePropertyOwner.HasValue)
                query = query.Include(x => x.Property).ThenInclude(x => x.User);

            return base.AddInclude(query, search);
        }

        protected override async Task BeforeInsert(Favorite entity,FavoriteUpsertRequest request)
        {
            var exists = await _context.Favorites.AnyAsync(x =>
                x.UserId == request.UserId &&
                x.PropertyId == request.PropertyId);

            if (exists)
                throw new InvalidOperationException("Nekretnina je već dodana u favorite");

            entity.CreatedAt = DateTime.UtcNow;

            await base.BeforeInsert(entity, request);
        }
    }
}