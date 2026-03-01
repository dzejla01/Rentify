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
    [Authorize(Roles = "Vlasnik, Korisnik")]
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

        
    }
}
