using Rentify.Model;
using Rentify.Model.SearchObjects;
using Rentify.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : BaseSearchObject, new()
    {
        protected readonly IService<T, TSearch> _service;
        
        public BaseController(IService<T, TSearch> service) {
            _service = service;
        }

        [HttpGet("")]
        public virtual async Task<PagedResult<T>> Get([FromQuery]TSearch? search = null)
        {
            var s = search ?? new TSearch();
            if (s.RetrieveAll && !User.IsInRole("Admin"))
                s.RetrieveAll = false;
            return await _service.GetAsync(s);
        }

        [HttpGet("{id}")]
        public virtual async Task<T?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}
