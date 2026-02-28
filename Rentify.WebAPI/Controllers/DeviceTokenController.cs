using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Services.Interfaces;
using System.Security.Claims;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/device-tokens")]
    [Authorize]
    public class DeviceTokensController : ControllerBase
    {
        private readonly IDeviceTokenService _service;

        public DeviceTokensController(IDeviceTokenService service)
        {
            _service = service;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] DeviceTokenRegisterRequest req)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            await _service.RegisterAsync(userId, req);
            return Ok();
        }

        [HttpPost("unregister")]
        public async Task<IActionResult> Unregister([FromBody] DeviceTokenUnregisterRequest req)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            await _service.UnregisterAsync(userId, req);
            return Ok();
        }
    }
}