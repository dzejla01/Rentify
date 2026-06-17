using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IAppointmentService
        : ICRUDService<AppointmentResponse, AppointmentSearchObject, AppointmentUpsertRequest, AppointmentUpsertRequest>
    {
        Task<UnavailableAppointmentsResponse> GetUnavailableAppointmentDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null);

        Task<AppointmentResponse> ApproveAsync(int id);

        Task<AppointmentResponse> FinishAsync(int id);

        Task<AppointmentResponse> RejectAsync(int id, string? reason = null);

        Task<AppointmentResponse> CancelAsync(int id, string? reason = null);

        List<string> AllowedActions(int id);
    }
}