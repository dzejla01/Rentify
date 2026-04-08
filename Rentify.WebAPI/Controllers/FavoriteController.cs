using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.WebAPI.Controllers;

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
    }
}