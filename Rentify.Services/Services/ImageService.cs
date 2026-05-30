using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using System.Text.RegularExpressions;


namespace Rentify.Services
{
    public class ImageService : IImageService
    {

        private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg", ".jpeg", ".png", ".webp"
        };

        private const long MaxBytes = 10 * 1024 * 1024;

        private readonly IWebHostEnvironment _env;

        public ImageService(IWebHostEnvironment env)
        {
            _env = env;
        }

        private static readonly Dictionary<string, byte[]> MagicBytes = new()
        {
            { ".jpg",  new byte[] { 0xFF, 0xD8, 0xFF } },
            { ".jpeg", new byte[] { 0xFF, 0xD8, 0xFF } },
            { ".png",  new byte[] { 0x89, 0x50, 0x4E, 0x47 } },
            { ".webp", new byte[] { 0x52, 0x49, 0x46, 0x46 } }
        };

        private static async Task ValidateMagicBytesAsync(IFormFile file, string ext, CancellationToken ct)
        {
            if (!MagicBytes.TryGetValue(ext.ToLowerInvariant(), out var expected))
                return;

            var buffer = new byte[expected.Length];
            using var stream = file.OpenReadStream();
            var read = await stream.ReadAsync(buffer, 0, buffer.Length, ct);

            if (read < expected.Length || !buffer.Take(expected.Length).SequenceEqual(expected))
                throw new ArgumentException("Sadržaj fajla se ne poklapa sa deklarisanim formatom slike.");
        }

        public async Task<string> SaveAsync(IFormFile file, string nameOfTheFolder, string? desiredFileName = null, CancellationToken ct = default)
        {
            if (file == null || file.Length == 0)
                throw new UserException("Fajl nije poslan ili je prazan.");

            if (file.Length > MaxBytes)
                throw new ArgumentException("Slika je prevelika (max 10MB).");

            var folder = NormalizeFolder(nameOfTheFolder);


            var ext = Path.GetExtension(file.FileName);
            if (string.IsNullOrWhiteSpace(ext) || !AllowedExtensions.Contains(ext))
                throw new ArgumentException("Nedozvoljen format slike. Dozvoljeno: jpg, jpeg, png, webp.");

            await ValidateMagicBytesAsync(file, ext, ct);

            var safeFileName = MakeSafeFileName(desiredFileName);
            if (string.IsNullOrWhiteSpace(safeFileName))
            {
                
                safeFileName = $"{DateTime.UtcNow:yyyyMMdd_HHmmss}_{Guid.NewGuid():N}{ext}";
            }
            else
            {
                
                if (string.IsNullOrWhiteSpace(Path.GetExtension(safeFileName)))
                    safeFileName += ext;

                
                var desiredExt = Path.GetExtension(safeFileName);
                if (!AllowedExtensions.Contains(desiredExt))
                    safeFileName = Path.ChangeExtension(safeFileName, ext);
            }

            var physicalFolder = GetPhysicalFolder(folder);
            Directory.CreateDirectory(physicalFolder);

            var fullPath = Path.Combine(physicalFolder, safeFileName);

            
            using (var stream = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None))
            {
                await file.CopyToAsync(stream, ct);
            }

            
            return safeFileName;
        }

        public Task<bool> DeleteAsync(string fileName, string nameOfTheFolder, CancellationToken ct = default)
        {
            var folder = NormalizeFolder(nameOfTheFolder);
            

            var safeName = MakeSafeFileName(fileName);
            if (string.IsNullOrWhiteSpace(safeName))
                return Task.FromResult(false);

            var physicalFolder = GetPhysicalFolder(folder);
            var fullPath = Path.Combine(physicalFolder, safeName);

            if (!File.Exists(fullPath))
                return Task.FromResult(false);

            File.Delete(fullPath);
            return Task.FromResult(true);
        }

        public string GetPublicUrl(string fileName, string nameOfTheFolder)
        {
            var folder = NormalizeFolder(nameOfTheFolder);
            var safeName = MakeSafeFileName(fileName);
            return $"/images/{folder}/{safeName}";
        }

        private string GetPhysicalFolder(string folder)
        {
            var webRoot = _env.WebRootPath ?? Path.Combine(AppContext.BaseDirectory, "wwwroot");
            return Path.Combine(webRoot, "images", folder);
        }

        private static readonly HashSet<string> AllowedFolders = new(StringComparer.OrdinalIgnoreCase)
        {
            "users", "properties"
        };

        private static string NormalizeFolder(string folder)
        {
            var normalized = (folder ?? "").Trim().ToLowerInvariant();
            if (!AllowedFolders.Contains(normalized))
                throw new ArgumentException($"Folder '{normalized}' nije dozvoljen. Dozvoljeni folderi: {string.Join(", ", AllowedFolders)}.");
            return normalized;
        }

        private static string MakeSafeFileName(string? input)
        {
            if (string.IsNullOrWhiteSpace(input)) return "";

            var name = input.Trim();

            name = name.Replace("\\", "/");
            name = Path.GetFileName(name);

            name = Regex.Replace(name, @"[^a-zA-Z0-9._-]", "");

            if (name is "." or "..") return "";

            return name;
        }
    }
}
