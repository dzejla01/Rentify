namespace Rentify.EmailConsumer.Messages
{
    public class ResetPasswordEmailMessage
    {
        public string To { get; set; } = string.Empty;
        public string ResetCode { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
    }
}
