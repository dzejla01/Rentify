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
        public async Task<ActionResult<UnavailableAppointmentsResponse>> GetUnavailableDates(
    int propertyId,
    DateTime? from = null,
    DateTime? to = null)
        {
            var result = await _Appservice
                .GetUnavailableAppointmentDatesAsync(propertyId, from, to);

            return Ok(result);
        }
    }
}
