using System.Security.Claims;
using MapsterMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{

    public class PropertyController
        : BaseCRUDController<PropertyResponse, PropertySearchObject, PropertyInsertRequest, PropertyUpdateRequest>
    {
        private readonly IMapper _mapper;
        private readonly IPropertyService _service;

        public PropertyController(IPropertyService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("recommended")]
        [Authorize(Roles = "Korisnik")]
        public async Task<ActionResult<List<PropertyResponse>>> GetRecommended([FromQuery] int take = 5)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);

            if (userIdClaim == null)
                return Unauthorized("UserId claim not found.");

            if (!int.TryParse(userIdClaim.Value, out int userId))
                return Unauthorized("Invalid user id.");

            var result = await _service.GetRecommendedPropertiesAsync(userId, take);

            return Ok(result);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<PropertyResponse?> Update(int id, [FromBody] PropertyUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<PropertyResponse> Create([FromBody] PropertyInsertRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out var userId))
                request.UserId = userId;
            return base.Create(request);
        }

    }
}
