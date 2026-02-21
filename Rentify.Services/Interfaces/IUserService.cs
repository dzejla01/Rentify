// Rentify.Services/Interfaces/IUserService.cs
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObject;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IUserService : ICRUDService<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Task<LoginResponse> LoginAsync(LoginRequest request);
        Task ForgotPasswordAsync(string email);
    }
}
