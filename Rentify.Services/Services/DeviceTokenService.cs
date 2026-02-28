using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;

namespace Rentify.Services.Services
{
    public class DeviceTokenService : IDeviceTokenService
    {
        private readonly RentifyDbContext _context;

        public DeviceTokenService(RentifyDbContext context)
        {
            _context = context;
        }

        public async Task RegisterAsync(int userId, DeviceTokenRegisterRequest request)
        {
            var token = request.Token?.Trim();
            if (string.IsNullOrWhiteSpace(token))
                throw new ArgumentException("Token is required.");

            var existing = await _context.UserDeviceTokens
                .FirstOrDefaultAsync(x => x.Token == token);

            if (existing == null)
            {
                _context.UserDeviceTokens.Add(new UserDeviceToken
                {
                    UserId = userId,
                    Token = token,
                    Platform = string.IsNullOrWhiteSpace(request.Platform) ? "android" : request.Platform.Trim(),
                    IsActive = true,
                    UpdatedAt = DateTime.UtcNow
                });
            }
            else
            {
                existing.UserId = userId;
                existing.Platform = string.IsNullOrWhiteSpace(request.Platform) ? existing.Platform : request.Platform.Trim();
                existing.IsActive = true;
                existing.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
        }

        public async Task UnregisterAsync(int userId, DeviceTokenUnregisterRequest request)
        {
            var token = request.Token?.Trim();
            if (string.IsNullOrWhiteSpace(token))
                throw new ArgumentException("Token is required.");

            var existing = await _context.UserDeviceTokens
                .FirstOrDefaultAsync(x => x.UserId == userId && x.Token == token && x.IsActive);

            if (existing != null)
            {
                existing.IsActive = false;
                existing.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }
        }

        public async Task<List<string>> GetActiveTokensAsync(int userId)
        {
            return await _context.UserDeviceTokens
                .Where(x => x.UserId == userId && x.IsActive)
                .Select(x => x.Token)
                .ToListAsync();
        }
    }
}