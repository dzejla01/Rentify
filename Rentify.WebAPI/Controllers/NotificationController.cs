using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using System.Security.Claims;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class NotificationController : ControllerBase
    {
        private readonly INotificationService _notificationService;

        public NotificationController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        [HttpGet]
        public async Task<PagedResult<NotificationResponse>> Get([FromQuery] NotificationSearchObject? search = null)
        {
            var s = search ?? new NotificationSearchObject();

            if (!User.IsInRole("Admin"))
                s.UserId = GetLoggedInUserId();

            if (s.RetrieveAll && !User.IsInRole("Admin"))
                s.RetrieveAll = false;

            return await _notificationService.GetAsync(s);
        }

        [HttpPut("{id}/mark-as-read")]
        public async Task<ActionResult<NotificationResponse>> MarkAsRead(int id)
        {
            var userId = GetLoggedInUserId();
            if (userId == null) return Unauthorized("UserId claim not found.");

            var result = await _notificationService.MarkAsReadAsync(id, userId.Value);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPut("mark-all-as-read")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = GetLoggedInUserId();
            if (userId == null) return Unauthorized("UserId claim not found.");

            var count = await _notificationService.MarkAllAsReadAsync(userId.Value);
            return Ok(new { updated = count });
        }

        private int? GetLoggedInUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }
    }
}
