using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{

    public class ReservationController
        : BaseCRUDController<ReservationResponse, ReservationSearchObject, ReservationUpsertRequest, ReservationUpsertRequest>
    {
        IReservationService _reservationService;
        public ReservationController(IReservationService service) : base(service)
        {
            _reservationService = service;
        }

        // GET api/reservations/unavailable-dates?propertyId=12&from=2026-03-01&to=2026-06-01
    [HttpGet("unavailable-dates")]
    public async Task<ActionResult<UnavailableDatesResponse>> GetUnavailableDates(
        [FromQuery] int propertyId,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to
    )
    {
        if (propertyId <= 0) return BadRequest("propertyId nije validan.");

        var res = await _reservationService.GetUnavailableAppointmentDatesAsync(
            propertyId, from, to
        );

        return Ok(res);
    }
    }
}
