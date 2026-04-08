using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;

namespace Rentify.WebAPI.Controllers
{

    public class AppointmentController
        : BaseCRUDController<AppointmentResponse, AppointmentSearchObject, AppointmentUpsertRequest, AppointmentUpsertRequest>
    {
        IAppointmentService _Appservice;
        public AppointmentController(IAppointmentService service) : base(service)
        {
            _Appservice = service;
        }

        [HttpGet("unavailable-dates")]
        [Authorize(Roles = "Korisnik")]
        public async Task<ActionResult<UnavailableAppointmentsResponse>> GetUnavailableDates(
        int propertyId,
        DateTime? from = null,
        DateTime? to = null)
        {
            var result = await _Appservice
                .GetUnavailableAppointmentDatesAsync(propertyId, from, to);

            return Ok(result);
        }

        [Authorize(Roles = "Korisnik")]
        public override Task<AppointmentResponse> Create([FromBody] AppointmentUpsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Admin")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [Authorize(Roles = "Vlasnik")]
        public override Task<AppointmentResponse?> Update(int id, [FromBody] AppointmentUpsertRequest request)
        {
            return base.Update(id, request);
        }
    }
}
