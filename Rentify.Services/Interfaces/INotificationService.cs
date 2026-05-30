using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface INotificationService : IService<NotificationResponse, NotificationSearchObject>
    {
        Task<NotificationResponse> CreateForUserAsync(
            int userId,
            string title,
            string message,
            string? type = null,
            string? referenceType = null,
            int? referenceId = null);

        Task<NotificationResponse?> MarkAsReadAsync(int id, int userId);
        Task<int> MarkAllAsReadAsync(int userId);
    }
}
