using Rentify.Model.RequestObjects;
using MapsterMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.ResponseObject;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    public class UserController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService; 
        public UserController(IUserService service) : base(service) { 

            _userService = service;

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
    }
}
