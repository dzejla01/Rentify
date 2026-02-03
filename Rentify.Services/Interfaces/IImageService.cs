using Microsoft.AspNetCore.Http;

namespace Rentify.Services.Interfaces
{
    public interface IImageService
    {
        Task<string> SaveAsync(IFormFile file, string nameOfTheFolder, string? desiredFileName = null, CancellationToken ct = default);

        Task<bool> DeleteAsync(string fileName, string nameOfTheFolder, CancellationToken ct = default);

        string GetPublicUrl(string fileName, string nameOfTheFolder);
    }
}
