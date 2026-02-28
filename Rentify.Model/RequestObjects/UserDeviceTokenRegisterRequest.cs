namespace Rentify.Model.RequestObjects
{
    public class DeviceTokenRegisterRequest
    {
        public string Token { get; set; } = string.Empty;
        public string Platform { get; set; } = "android";
    }
}