
namespace Rentify.Services.Database
{
    public class UserDeviceToken
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public string Token { get; set; } = string.Empty;

    public string Platform { get; set; } = "android";
    public string? DeviceId { get; set; } 

    public bool IsActive { get; set; } = true;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
    
}
