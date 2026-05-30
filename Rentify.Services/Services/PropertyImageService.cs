using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Rentify.Services.Services
{
    public class PropertyImageService
        : BaseCRUDService<PropertyImageResponse, PropertyImageSearchObject, PropertyImage, PropertyImageUpsertRequest, PropertyImageUpsertRequest>,
          IPropertyImageService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PropertyImageService(
            RentifyDbContext context,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        protected override IQueryable<PropertyImage> ApplyFilter(IQueryable<PropertyImage> query, PropertyImageSearchObject search)
        {
            if (search.PropertyId.HasValue)
            {
                query = query.Where(p => p.PropertyId == search.PropertyId);
            }

            if (search.IsMain.HasValue)
            {
                query = query.Where(p => p.IsMain == search.IsMain.Value);
            }

            return base.ApplyFilter(query, search);
        }

        protected override async Task BeforeInsert(PropertyImage entity, PropertyImageUpsertRequest request)
        {
            await EnsureCurrentUserOwnsPropertyAsync(entity.PropertyId);

            if (entity.IsMain)
                await ClearOtherMainImagesAsync(entity.PropertyId, excludeId: null);

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(PropertyImage entity, PropertyImageUpsertRequest request)
        {
            await EnsureCurrentUserOwnsPropertyAsync(entity.PropertyId);
            await EnsureCurrentUserOwnsPropertyAsync(request.PropertyId);

            if (request.IsMain)
                await ClearOtherMainImagesAsync(request.PropertyId, excludeId: entity.Id);

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(PropertyImage entity)
        {
            await EnsureCurrentUserOwnsPropertyAsync(entity.PropertyId);
            await base.BeforeDelete(entity);
        }

        private int? GetLoggedInUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }

        private bool IsAdmin()
        {
            return _httpContextAccessor.HttpContext?.User.IsInRole("Admin") ?? false;
        }

        private async Task EnsureCurrentUserOwnsPropertyAsync(int propertyId)
        {
            if (IsAdmin())
                return;

            var loggedInId = GetLoggedInUserId()
                ?? throw new ForbiddenException("Korisnik nije autentificiran.");

            var ownerId = await _context.Properties
                .Where(p => p.Id == propertyId)
                .Select(p => p.UserId)
                .FirstOrDefaultAsync();

            if (ownerId == 0)
                throw new UserException("Nekretnina nije pronađena.");

            if (ownerId != loggedInId)
                throw new ForbiddenException("Nemate pravo mijenjati slike za tuđu nekretninu.");
        }

        private async Task ClearOtherMainImagesAsync(int propertyId, int? excludeId)
        {
            var others = await _context.PropertiesImage
                .Where(p => p.PropertyId == propertyId && p.IsMain)
                .ToListAsync();

            foreach (var img in others)
            {
                if (excludeId.HasValue && img.Id == excludeId.Value)
                    continue;
                img.IsMain = false;
            }
        }
    }
}
