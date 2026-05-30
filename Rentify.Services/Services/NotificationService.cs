using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;

namespace Rentify.Services.Services
{
    public class NotificationService
        : BaseService<NotificationResponse, NotificationSearchObject, AppNotification>,
          INotificationService
    {
        private readonly RentifyDbContext _db;

        public NotificationService(RentifyDbContext context, IMapper mapper)
            : base(context, mapper)
        {
            _db = context;
        }

        protected override IQueryable<AppNotification> ApplyFilter(
            IQueryable<AppNotification> query,
            NotificationSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.IsRead.HasValue)
                query = query.Where(x => x.IsRead == search.IsRead.Value);

            if (!string.IsNullOrWhiteSpace(search.Type))
                query = query.Where(x => x.Type == search.Type);

            return base.ApplyFilter(query, search)
                .OrderByDescending(x => x.CreatedAt);
        }

        public async Task<NotificationResponse> CreateForUserAsync(
            int userId,
            string title,
            string message,
            string? type = null,
            string? referenceType = null,
            int? referenceId = null)
        {
            var entity = new AppNotification
            {
                UserId = userId,
                Title = title,
                Message = message,
                Type = type,
                ReferenceType = referenceType,
                ReferenceId = referenceId,
                CreatedAt = DateTime.UtcNow
            };

            _db.Set<AppNotification>().Add(entity);
            await _db.SaveChangesAsync();

            return MapToResponse(entity);
        }

        public async Task<NotificationResponse?> MarkAsReadAsync(int id, int userId)
        {
            var entity = await _db.Set<AppNotification>()
                .FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId);

            if (entity == null)
                return null;

            if (!entity.IsRead)
            {
                entity.IsRead = true;
                entity.ReadAt = DateTime.UtcNow;
                await _db.SaveChangesAsync();
            }

            return MapToResponse(entity);
        }

        public async Task<int> MarkAllAsReadAsync(int userId)
        {
            var unread = await _db.Set<AppNotification>()
                .Where(x => x.UserId == userId && !x.IsRead)
                .ToListAsync();

            foreach (var notification in unread)
            {
                notification.IsRead = true;
                notification.ReadAt = DateTime.UtcNow;
            }

            await _db.SaveChangesAsync();
            return unread.Count;
        }
    }
}
