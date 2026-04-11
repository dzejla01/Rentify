using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IReservationService
        : ICRUDService<ReservationResponse, ReservationSearchObject, ReservationUpsertRequest, ReservationUpsertRequest>
    {
        Task<UnavailableDatesResponse> GetUnavailableAppointmentDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null);

        Task<UnavailableDatesResponse> GetUnavailableReservationDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null);

        Task<UnavailableDatesResponse> GetUnavailableReservationMonthsAsync(
    int propertyId,
    DateTime? from = null,
    DateTime? to = null);

        Task<ReservationResponse> ApproveAsync(int id);

        Task<ReservationResponse> FinishAsync(int id);

        Task<ReservationResponse> RejectAsync(int id);

        Task<ReservationResponse> CancelAsync(int id);

        List<string> AllowedActions(int id);
    }
}