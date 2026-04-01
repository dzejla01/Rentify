namespace Rentify.EmailConsumer.Configuration
{
    public class AppConfig
    {
        public string PaymentCurrency { get; set; } = "bam";
        public string ResetPasswordQueue { get; set; } = "email.reset-password";
    }
}