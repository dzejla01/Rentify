using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;
using Rentify.EmailConsumer.Messages;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObject;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Helpers;
using Rentify.Services.Interfaces;
using Rentify.Services.Services;
using System;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Rentify.Services
{
    public class UserService
        : BaseCRUDService<UserResponse, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>,
          IUserService
    {
        private readonly IConfiguration _configuration;
        private readonly IConnection _rabbitConnection;

        public UserService(
            RentifyDbContext context,
            IConfiguration configuration,
            IMapper mapper,
            IConnection rabbitConnection
        ) : base(context, mapper)
        {
            _configuration = configuration;
            _rabbitConnection = rabbitConnection;
        }

        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject search)
        {
            var nameFts = !string.IsNullOrWhiteSpace(search.NameFTS)
                ? search.NameFTS
                : search.FTS;

            if (!string.IsNullOrWhiteSpace(nameFts))
            {
                var s = string.Join(" ", nameFts.Trim().ToLower().Split(' ', StringSplitOptions.RemoveEmptyEntries));

                query = query.Where(x =>
                    x.FirstName.ToLower().Contains(s) ||
                    x.LastName.ToLower().Contains(s) ||
                    (x.FirstName + " " + x.LastName).ToLower().Contains(s) ||
                    (x.LastName + " " + x.FirstName).ToLower().Contains(s) ||
                    x.Username.ToLower().Contains(s) ||
                    x.Email.ToLower().Contains(s));
            }

            if (search.IsActive.HasValue)
                query = query.Where(x => x.IsActive == search.IsActive.Value);

            if (search.IsVlasnik.HasValue)
                query = query.Where(x => x.IsVlasnik == search.IsVlasnik.Value);

            return query;
        }

        protected override User MapInsertToEntity(User entity, UserInsertRequest request)
        {
            _mapper.Map(request, entity);

            if (!string.IsNullOrWhiteSpace(request.Password))
            {
                UserHelper.CreatePasswordHash(request.Password, out var hash, out var salt);
                entity.PasswordHash = hash;
                entity.PasswordSalt = salt;
            }

            entity.CreatedAt = DateTime.UtcNow;
            return entity;
        }

        protected override void MapUpdateToEntity(User entity, UserUpdateRequest request)
        {
            var createdAt = entity.CreatedAt;

            _mapper.Map(request, entity);

            entity.CreatedAt = createdAt;

            if (!string.IsNullOrWhiteSpace(request.Password))
            {
                UserHelper.CreatePasswordHash(request.Password, out var hash, out var salt);
                entity.PasswordHash = hash;
                entity.PasswordSalt = salt;
            }
        }

        protected override async Task BeforeInsert(User entity, UserInsertRequest request)
        {
            var exists = await _context.Users.AnyAsync(x =>
                x.Username == entity.Username || x.Email == entity.Email);

            if (exists)
                throw new InvalidOperationException("Korisnik sa istim username/email već postoji.");

            await UserHelper.AssignRoleByIsVlasnikAndLogFirstTimeAsync(entity, request);
        }

        protected override async Task BeforeUpdate(User entity, UserUpdateRequest request)
        {
            entity.IsLoggingFirstTime = false;

            var exists = await _context.Users.AnyAsync(x =>
                x.Id != entity.Id &&
                (x.Username == request.Username || x.Email == request.Email));

            if (exists)
                throw new InvalidOperationException("Korisnik sa istim username/email već postoji.");
        }

        public async Task<LoginResponse> LoginAsync(LoginRequest request)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(x => x.Username == request.Username);

            if (user == null)
                throw new UserException("Pogrešan username ili password.");

            if (!user.IsActive)
                throw new UserException("Korisnik je neaktivan, kontaktirajte admina.");

            if (!UserHelper.VerifyPassword(request.Password, user.PasswordHash, user.PasswordSalt))
                throw new UserException("Pogrešan username ili password.");

            var token = UserHelper.CreateJwt(user, _configuration);

            var response = new LoginResponse
            {
                UserId = user.Id,
                UserName = request.Username,
                FullName = $"{user.FirstName} {user.LastName}".Trim(),
                UserImage = user.UserImage,
                Token = token,
                Roles = user.UserRoles
                    .Where(ur => ur.Role != null)
                    .Select(ur => ur.Role.Name)
                    .ToList(),
                IsLoggingFirstTime = user.IsLoggingFirstTime
            };

            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return response;
        }

        public async Task ForgotPasswordAsync(string email)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Email == email);

            if (user == null)
                throw new NotFoundException("Email nije povezan ni sa jednim nalogom.");

            var newPassword = UserHelper.GenerateSecurePassword(12);

            UserHelper.CreatePasswordHash(newPassword, out string hash, out string salt);

            user.PasswordHash = hash;
            user.PasswordSalt = salt;

            await _context.SaveChangesAsync();

            var channel = await _rabbitConnection.CreateChannelAsync();

            await channel.QueueDeclareAsync(
                queue: "email.reset-password",
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            var message = new ResetPasswordEmailMessage
            {
                To = user.Email!,
                UserName = user.Username ?? user.FirstName ?? "Korisnik",
                NewPassword = newPassword
            };

            var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

            await channel.BasicPublishAsync(
                exchange: "",
                routingKey: "email.reset-password",
                body: body
            );
        }
    }
}
