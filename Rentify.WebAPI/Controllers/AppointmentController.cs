using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using System.Security.Claims;

namespace Rentify.WebAPI.Controllers
{
    public class AppointmentController
        : BaseCRUDController<AppointmentResponse, AppointmentSearchObject, AppointmentUpsertRequest, AppointmentUpsertRequest>
    {
        private readonly IAppointmentService _appointmentService;

        public AppointmentController(IAppointmentService service) : base(service)
        {
            _appointmentService = service;
        }

        [HttpGet("unavailable-ap-dates")]
        public async Task<UnavailableAppointmentsResponse> GetUnavailableAppointmentDates(
            [FromQuery] int propertyId,
            [FromQuery] DateTime? from,
            [FromQuery] DateTime? to
        )
        {
            return await _appointmentService.GetUnavailableAppointmentDatesAsync(
                propertyId, from, to
            );
        }

        [HttpGet("{id}/allowed-actions")]
        [Authorize(Roles = "Vlasnik,Korisnik")]
        public List<string> AllowedActions(int id)
        {
            return _appointmentService.AllowedActions(id);
        }

        [HttpPut("{id}/approve")]
        [Authorize(Roles = "Vlasnik")]
        public async Task<AppointmentResponse> Approve(int id)
        {
            return await _appointmentService.ApproveAsync(id);
        }

        [HttpPut("{id}/finish")]
        [Authorize(Roles = "Vlasnik")]
        public async Task<AppointmentResponse> Finish(int id)
        {
            return await _appointmentService.FinishAsync(id);
        }

        [HttpPut("{id}/reject")]
        [Authorize(Roles = "Vlasnik")]
        public async Task<AppointmentResponse> Reject(int id)
        {
            return await _appointmentService.RejectAsync(id);
        }

        [HttpPut("{id}/cancel")]
        [Authorize(Roles = "Vlasnik,Korisnik")]
        public async Task<AppointmentResponse> Cancel(int id)
        {
            return await _appointmentService.CancelAsync(id);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [Authorize(Roles = "Vlasnik,Korisnik")]
        public override Task<AppointmentResponse?> Update(int id, [FromBody] AppointmentUpsertRequest request)
        {
            return _appointmentService.UpdateAsync(id, request);
        }

        [Authorize(Roles = "Korisnik")]
        public override Task<AppointmentResponse> Create([FromBody] AppointmentUpsertRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out var userId))
                request.UserId = userId;
            return _appointmentService.CreateAsync(request);
        }
    }
}