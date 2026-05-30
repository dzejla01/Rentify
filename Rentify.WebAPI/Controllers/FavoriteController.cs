using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.WebAPI.Controllers;
using System.Security.Claims;

namespace Rentify.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Korisnik")]
    public class FavoriteController
        : BaseCRUDController<FavoriteResponse, FavoriteSearchObject, FavoriteUpsertRequest, FavoriteUpsertRequest>
    {
        public FavoriteController(IFavoriteService service) : base(service)
        {
        }

        public override Task<FavoriteResponse> Create([FromBody] FavoriteUpsertRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out var userId))
                request.UserId = userId;
            return base.Create(request);
        }
    }
}