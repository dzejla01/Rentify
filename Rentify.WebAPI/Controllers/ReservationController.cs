using Microsoft.AspNetCore.Authorization;
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

        [HttpGet("unavailable-ap-dates")]
        public async Task<ActionResult<UnavailableDatesResponse>> GetUnavailableApDates(
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

        [HttpGet("unavailable-res-dates")]
        public async Task<ActionResult<UnavailableDatesResponse>> GetUnavailableResDates(
            [FromQuery] int propertyId,
            [FromQuery] DateTime? from,
            [FromQuery] DateTime? to
        )
        {
            if (propertyId <= 0) return BadRequest("propertyId nije validan.");

            var res = await _reservationService.GetUnavailableReservationDatesAsync(
                propertyId, from, to
            );

            return Ok(res);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<ReservationResponse?> Update(int id, [FromBody] ReservationUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Korisnik")]
        public override Task<ReservationResponse> Create([FromBody] ReservationUpsertRequest request)
        {
            return base.Create(request);
        }

    }
}
