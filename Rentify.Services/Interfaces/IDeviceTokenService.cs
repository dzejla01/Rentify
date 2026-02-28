using Rentify.Model.RequestObjects;

namespace Rentify.Services.Interfaces
{
    public interface IDeviceTokenService
    {
        Task RegisterAsync(int userId, DeviceTokenRegisterRequest request);
        Task UnregisterAsync(int userId, DeviceTokenUnregisterRequest request);
        Task<List<string>> GetActiveTokensAsync(int userId);
    }
}