

using FirebaseAdmin.Messaging;

namespace Rentify.Services.Services
{
    public class PushNotificationService
    {
        public async Task SendToTokensAsync(
            IEnumerable<string> tokens,
            string title,
            string body,
            Dictionary<string, string>? data = null)
        {
            var list = tokens
                .Where(t => !string.IsNullOrWhiteSpace(t))
                .Distinct()
                .ToList();

            if (list.Count == 0) return;

            var msg = new MulticastMessage
            {
                Tokens = list,
                Notification = new Notification { Title = title, Body = body },
                Data = data ?? new Dictionary<string, string>()
            };

            await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(msg);
        }
    }
}