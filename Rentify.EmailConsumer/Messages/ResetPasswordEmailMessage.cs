namespace Rentify.EmailConsumer.Messages
{
    public class ResetPasswordEmailMessage
    {
        public string To { get; set; }
        public string NewPassword { get; set; }
        public string UserName { get; set; }
    }
}

