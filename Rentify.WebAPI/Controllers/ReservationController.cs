using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.Services.ReservationStateMachine;
using System.Security.Claims;

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

        [HttpGet("unavailable-res-months")]
        public async Task<UnavailableDatesResponse> GetUnavailableResMonths(
    [FromQuery] int propertyId,
    [FromQuery] DateTime? from,
    [FromQuery] DateTime? to
)
        {
            return await _reservationService.GetUnavailableReservationMonthsAsync(
                propertyId, from, to
            );
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<bool> Delete(int id)
        {
            return _reservationService.DeleteAsync(id);
        }

        [Authorize(Roles = "Vlasnik,Korisnik")]
        public override Task<ReservationResponse?> Update(int id, [FromBody] ReservationUpsertRequest request)
        {
            throw new NotSupportedException("Direktno ažuriranje rezervacije nije dozvoljeno. Koristite akcije: approve, finish, reject, cancel.");
        }

        [Authorize(Roles = "Korisnik")]
        public override Task<ReservationResponse> Create([FromBody] ReservationUpsertRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out var userId))
                request.UserId = userId;
            return _reservationService.CreateAsync(request);
        }

        [HttpGet("{id}/allowed-actions")]
        [Authorize(Roles = "Vlasnik,Korisnik")]
        public List<string> AllowedActions(int id)
        {
            return _reservationService.AllowedActions(id);
        }

        [HttpPut("{id}/approve")]
        [Authorize(Roles = "Vlasnik")]
        public async Task<ReservationResponse> Approve(int id)
        {
            return await _reservationService.ApproveAsync(id);
        }

        [HttpPut("{id}/finish")]
        [Authorize(Roles = "Vlasnik")]
        public async Task<ReservationResponse> Finish(int id)
        {
            return await _reservationService.FinishAsync(id);
        }

        [HttpPut("{id}/reject")]
        [Authorize(Roles = "Vlasnik")]
        public async Task<ReservationResponse> Reject(int id, [FromBody] ReasonRequest? body = null)
        {
            return await _reservationService.RejectAsync(id, body?.Reason);
        }

        [HttpPut("{id}/cancel")]
        [Authorize(Roles = "Vlasnik,Korisnik")]
        public async Task<ReservationResponse> Cancel(int id, [FromBody] ReasonRequest? body = null)
        {
            return await _reservationService.CancelAsync(id, body?.Reason);
        }

    }
}
