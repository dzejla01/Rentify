using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.Services.Services;
using System.Security.Claims;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Vlasnik,Admin")]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("income")]
        public async Task<ActionResult> GetIncomeReport([FromQuery] IncomeReportSearchObject search)
        {
            if (search == null)
                return BadRequest("Search parametri nisu validni.");

            var isAdmin = User.IsInRole("Admin");

            if (!isAdmin)
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!int.TryParse(userIdClaim, out var loggedInId))
                    return Unauthorized("Neispravan token.");
                search.OwnerId = loggedInId;
            }

            if (search.OwnerId <= 0)
                return BadRequest("OwnerId je obavezan.");

            var result = await _reportService.GetIncomeReportAsync(search);
            return Ok(result);
        }

        [HttpPost("best-owner-by-year")]
        public async Task<IActionResult> GetBestOwnerByYear([FromBody] BestOwnerByYearRequest request)
        {
            var result = await _reportService.GetBestOwnerByYearAsync(request);

            if (result == null)
                return NotFound($"Za godinu {request.Year} nije pronađen nijedan owner sa rezervacijama.");

            return Ok(result);
        }
    }
}