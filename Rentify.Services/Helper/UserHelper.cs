using Konscious.Security.Cryptography;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Rentify.Model.RequestObjects;
using Rentify.Services.Database;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Rentify.Services.Helpers
{
    public static class UserHelper
    {
        
        private const int SaltSize = 16;          
        private const int HashSize = 32;          
        private const int Iterations = 4;
        private const int MemorySizeKb = 65536;   
        private const int DegreeOfParallelism = 2;

        public static void CreatePasswordHash(string password, out string hashBase64, out string saltBase64)
        {
            if (string.IsNullOrWhiteSpace(password))
                throw new ArgumentException("Password ne može biti prazan.", nameof(password));

            byte[] salt = RandomNumberGenerator.GetBytes(SaltSize);

            using var argon2 = new Argon2id(Encoding.UTF8.GetBytes(password))
            {
                Salt = salt,
                Iterations = Iterations,
                MemorySize = MemorySizeKb,
                DegreeOfParallelism = DegreeOfParallelism
            };

            byte[] hash = argon2.GetBytes(HashSize);

            hashBase64 = Convert.ToBase64String(hash);
            saltBase64 = Convert.ToBase64String(salt);
        }

        public static bool VerifyPassword(string password, string storedHashBase64, string storedSaltBase64)
        {
            if (string.IsNullOrWhiteSpace(password) ||
                string.IsNullOrWhiteSpace(storedHashBase64) ||
                string.IsNullOrWhiteSpace(storedSaltBase64))
            {
                return false;
            }

            byte[] salt;
            byte[] storedHash;

            try
            {
                salt = Convert.FromBase64String(storedSaltBase64);
                storedHash = Convert.FromBase64String(storedHashBase64);
            }
            catch
            {
                return false;
            }

            using var argon2 = new Argon2id(Encoding.UTF8.GetBytes(password))
            {
                Salt = salt,
                Iterations = Iterations,
                MemorySize = MemorySizeKb,
                DegreeOfParallelism = DegreeOfParallelism
            };

            byte[] computedHash = argon2.GetBytes(storedHash.Length);

            return CryptographicOperations.FixedTimeEquals(computedHash, storedHash);
        }

        public static string GenerateSecurePassword(int length = 12)
        {
            if (length < 8)
                throw new ArgumentException("Lozinka mora imati najmanje 8 karaktera.", nameof(length));

            const string upper = "ABCDEFGHJKLMNOPQRSTUVWXYZ";
            const string lower = "abcdefghijkmnopqrstuvwxyz";
            const string digits = "0123456789";
            const string special = "!@$?";
            const string all = upper + lower + digits + special;

            var passwordChars = new List<char>
            {
                GetRandomChar(upper),
                GetRandomChar(lower),
                GetRandomChar(digits),
                GetRandomChar(special)
            };

            for (int i = passwordChars.Count; i < length; i++)
            {
                passwordChars.Add(GetRandomChar(all));
            }

            Shuffle(passwordChars);

            return new string(passwordChars.ToArray());
        }

        private static char GetRandomChar(string source)
        {
            int index = RandomNumberGenerator.GetInt32(source.Length);
            return source[index];
        }

        private static void Shuffle(IList<char> chars)
        {
            for (int i = chars.Count - 1; i > 0; i--)
            {
                int j = RandomNumberGenerator.GetInt32(i + 1);
                (chars[i], chars[j]) = (chars[j], chars[i]);
            }
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

            var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
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

        public static Task AssignRoleByIsVlasnikAndLogFirstTimeAsync(User entity, UserInsertRequest request)
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