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

        // 🔐 Password verify
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
            var jwtKey = configuration["Jwt:Key"]!;
            var jwtIssuer = configuration["Jwt:Issuer"]!;

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username)
            };

            if (user.IsVlasnik)
            {
                claims.Add(new Claim(ClaimTypes.Role, "Vlasnik"));
            }
            else
            {
                claims.Add(new Claim(ClaimTypes.Role, "Korisnik"));
            }


            var signingKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey)
            );

            var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: jwtIssuer,
                audience: jwtIssuer,
                claims: claims,
                expires: DateTime.UtcNow.AddHours(2),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public static Task AssignRoleByIsVlasnikAsync(
           User entity, UserInsertRequest request)
        {
            
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
