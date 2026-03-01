using Microsoft.AspNetCore.Mvc;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.Services.Services;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
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

            if (search.OwnerId <= 0)
                return BadRequest("OwnerId je obavezan.");

            var result = await _reportService.GetIncomeReportAsync(search);
            return Ok(result);
        }
    }
}