using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IReservationService
        : ICRUDService<ReservationResponse, ReservationSearchObject, ReservationUpsertRequest, ReservationUpsertRequest>
    {

       public Task<UnavailableAppointmentsResponse> GetUnavailableAppointmentDatesAsync(
        int propertyId,
        DateTime? from = null,
        DateTime? to = null);
    }
}
