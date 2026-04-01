using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Rentify.Model.RequestObjects;
using Rentify.Services.Database;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace Rentify.Services.Helpers
{
    public static class UserHelper
    {
        // 🔐 Password hash
        public static void CreatePasswordHash(string password, out string hashBase64, out string saltBase64)
        {
            using var hmac = new HMACSHA512();
            var salt = hmac.Key;
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(password));

            hashBase64 = Convert.ToBase64String(hash);
            saltBase64 = Convert.ToBase64String(salt);
        }

        
        public static bool VerifyPassword(string password, string storedHashBase64, string storedSaltBase64)
        {
            if (string.IsNullOrWhiteSpace(storedHashBase64) || string.IsNullOrWhiteSpace(storedSaltBase64))
                return false;

            var salt = Convert.FromBase64String(storedSaltBase64);
            var storedHash = Convert.FromBase64String(storedHashBase64);

            using var hmac = new HMACSHA512(salt);
            var computedHash = hmac.ComputeHash(Encoding.UTF8.GetBytes(password));

            return CryptographicOperations.FixedTimeEquals(computedHash, storedHash);
        }

        public static string CreateJwt(User user, IConfiguration configuration)
        {
            var jwtKey = configuration["JWT_SECRET"];
            var jwtIssuer = configuration["JWT_ISSUER"];
            var jwtAudience = configuration["JWT_AUDIENCE"];

            if (string.IsNullOrWhiteSpace(jwtKey))
                throw new InvalidOperationException("JWT_SECRET nije postavljen.");

            if (string.IsNullOrWhiteSpace(jwtIssuer))
                throw new InvalidOperationException("JWT_ISSUER nije postavljen.");

            var claims = new List<Claim>
    {
        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
        new Claim(ClaimTypes.Name, user.Username ?? string.Empty),
        new Claim("fullName", $"{user.FirstName} {user.LastName}".Trim()),
        new Claim("userImage", user.UserImage ?? string.Empty),
        new Claim("isLoggingFirstTime", user.IsLoggingFirstTime.ToString().ToLower())
    };

            if (user.UserRoles != null)
            {
                foreach (var userRole in user.UserRoles)
                {
                    if (userRole.Role != null && !string.IsNullOrWhiteSpace(userRole.Role.Name))
                    {
                        claims.Add(new Claim(ClaimTypes.Role, userRole.Role.Name));
                    }
                }
            }

            var signingKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey)
            );

            var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: jwtIssuer,
                audience: jwtAudience,
                claims: claims,
                expires: DateTime.UtcNow.AddHours(2),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public static Task AssignRoleByIsVlasnikAndLogFirstTimeAsync(
           User entity, UserInsertRequest request)
        {
            entity.IsLoggingFirstTime = true;
            var roleId = request.IsVlasnik ? 2 : 1;

            entity.UserRoles.Add(new UserRole
            {
                UserId = entity.Id,
                RoleId = roleId
            });

            return Task.CompletedTask;
        }

    }
}
