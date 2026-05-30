using Rentify.Model.RequestObjects;
using MapsterMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.ResponseObject;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services;
using Rentify.Services.Interfaces;
using System.Security.Claims;

namespace Rentify.WebAPI.Controllers
{
    public class UserController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService;
        public UserController(IUserService service) : base(service) {

            _userService = service;

        }

        [Authorize(Roles = "Admin")]
        public override Task<PagedResult<UserResponse>> Get([FromQuery] UserSearchObject? search = null)
        {
            return base.Get(search);
        }

        [Authorize]
        public override async Task<UserResponse?> GetById(int id)
        {
            var loggedInId = GetLoggedInUserId();
            if (loggedInId == null) return null;

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && id != loggedInId.Value)
                throw new UnauthorizedAccessException("Nemate pristup ovom korisniku.");

            return await base.GetById(id);
        }

        [Authorize]
        public override async Task<UserResponse?> Update(int id, [FromBody] UserUpdateRequest request)
        {
            var loggedInId = GetLoggedInUserId();
            if (loggedInId == null) return null;

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && id != loggedInId.Value)
                throw new UnauthorizedAccessException("Nemate pravo mijenjati ovog korisnika.");

            return await base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [AllowAnonymous]
        public override Task<UserResponse> Create([FromBody] UserInsertRequest request)
        {
            return base.Create(request);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<LoginResponse> Login([FromBody] LoginRequest request)
        {
            return await _userService.LoginAsync(request);
        }

        [AllowAnonymous]
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(
        [FromBody] ForgotPasswordRequest request)
        {
            await _userService.ForgotPasswordAsync(request.Email);

            return Ok("Ako email postoji, poslan je link za reset lozinke.");
        }

        [AllowAnonymous]
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            await _userService.ResetPasswordAsync(request);
            return Ok("Lozinka je uspjesno promijenjena.");
        }

        private int? GetLoggedInUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }
    }
}
