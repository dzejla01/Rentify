using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Rentify.Services.Interfaces;
using System.Text.RegularExpressions;


namespace Rentify.Services
{
    public class ImageService : IImageService
    {
        private static readonly HashSet<string> AllowedFolders = new(StringComparer.OrdinalIgnoreCase)
        {
            "users",
            "properties",
            "products"
            // dodaj po potrebi
        };

        private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg", ".jpeg", ".png", ".webp"
        };

        private const long MaxBytes = 10 * 1024 * 1024; // 10MB

        private readonly IWebHostEnvironment _env;

        public ImageService(IWebHostEnvironment env)
        {
            _env = env;
        }

        public async Task<string> SaveAsync(IFormFile file, string nameOfTheFolder, string? desiredFileName = null, CancellationToken ct = default)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("Fajl nije poslan ili je prazan.");

            if (file.Length > MaxBytes)
                throw new ArgumentException("Slika je prevelika (max 10MB).");

            var folder = NormalizeFolder(nameOfTheFolder);
            if (!AllowedFolders.Contains(folder))
                throw new ArgumentException("Folder nije dozvoljen.");

            var ext = Path.GetExtension(file.FileName);
            if (string.IsNullOrWhiteSpace(ext) || !AllowedExtensions.Contains(ext))
                throw new ArgumentException("Nedozvoljen format slike. Dozvoljeno: jpg, jpeg, png, webp.");

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
            if (!AllowedFolders.Contains(folder))
                throw new ArgumentException("Folder nije dozvoljen.");

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
            // wwwroot/images/{folder}
            var webRoot = _env.WebRootPath ?? Path.Combine(AppContext.BaseDirectory, "wwwroot");
            return Path.Combine(webRoot, "images", folder);
        }

        private static string NormalizeFolder(string folder)
        {
            return (folder ?? "").Trim().ToLowerInvariant();
        }

        private static string MakeSafeFileName(string? input)
        {
            if (string.IsNullOrWhiteSpace(input)) return "";

            var name = input.Trim();

            // spriječi putanje i traversal
            name = name.Replace("\\", "/");
            name = Path.GetFileName(name);

            // izbaci čudne znakove (samo slova, brojevi, -, _, .)
            name = Regex.Replace(name, @"[^a-zA-Z0-9._-]", "");

            // nije dozvoljeno da bude prazno ili "." ili ".."
            if (name is "." or "..") return "";

            return name;
        }
    }
}
