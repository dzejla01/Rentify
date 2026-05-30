using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rentify.Services.Database;
using Rentify.Services.Interfaces;
using System.Security.Claims;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/images")]
    [Authorize]
    public class ImageController : ControllerBase
    {
        private readonly IImageService _imageService;
        private readonly RentifyDbContext _context;

        public ImageController(IImageService imageService, RentifyDbContext context)
        {
            _imageService = imageService;
            _context = context;
        }

        [HttpPost("upload")]
        [RequestSizeLimit(10 * 1024 * 1024)]
        public async Task<IActionResult> Upload(
            [FromQuery] string folder,
            IFormFile file,
            [FromQuery] string? fileName = null,
            [FromQuery] int? ownerUserId = null,
            [FromQuery] int? propertyId = null,
            CancellationToken ct = default)
        {
            if (file == null) return BadRequest("File je obavezan.");

            var authorization = await AuthorizeImageMutationAsync(folder, ownerUserId, propertyId, ct);
            if (authorization != null) return authorization;

            var savedName = await _imageService.SaveAsync(file, folder, fileName, ct);
            var url = _imageService.GetPublicUrl(savedName, folder);

            return Ok(new
            {
                fileName = savedName,
                url
            });
        }

        [HttpDelete]
        public async Task<IActionResult> Delete(
            [FromQuery] string folder,
            [FromQuery] string fileName,
            [FromQuery] int? ownerUserId = null,
            [FromQuery] int? propertyId = null,
            CancellationToken ct = default)
        {
            if (string.IsNullOrWhiteSpace(fileName)) return BadRequest("fileName je obavezan.");

            var authorization = await AuthorizeImageMutationAsync(folder, ownerUserId, propertyId, ct);
            if (authorization != null) return authorization;

            var ok = await _imageService.DeleteAsync(fileName, folder, ct);
            return ok ? Ok(new { deleted = true }) : NotFound(new { deleted = false });
        }

        private async Task<IActionResult?> AuthorizeImageMutationAsync(
            string folder,
            int? ownerUserId,
            int? propertyId,
            CancellationToken ct)
        {
            var normalizedFolder = (folder ?? "").Trim().ToLowerInvariant();
            var loggedInId = GetLoggedInUserId();

            if (loggedInId == null)
                return Unauthorized("UserId claim not found.");

            if (User.IsInRole("Admin"))
                return null;

            if (normalizedFolder == "users")
            {
                if (!ownerUserId.HasValue)
                    return BadRequest("ownerUserId je obavezan za korisnicke slike.");

                return ownerUserId.Value == loggedInId.Value
                    ? null
                    : Forbid();
            }

            if (normalizedFolder == "properties")
            {
                if (!propertyId.HasValue)
                    return BadRequest("propertyId je obavezan za slike nekretnina.");

                var ownerId = await _context.Properties
                    .Where(p => p.Id == propertyId.Value)
                    .Select(p => p.UserId)
                    .FirstOrDefaultAsync(ct);

                if (ownerId == 0)
                    return NotFound("Nekretnina nije pronadjena.");

                return ownerId == loggedInId.Value
                    ? null
                    : Forbid();
            }

            return BadRequest("Folder nije dozvoljen.");
        }

        private int? GetLoggedInUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }
    }
}
