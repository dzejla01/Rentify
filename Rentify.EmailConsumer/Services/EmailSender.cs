using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Rentify.EmailConsumer.Configuration;
using Rentify.EmailConsumer.Messages;

namespace Rentify.EmailConsumer.Services;

public class EmailSender
{
    private readonly SmtpSettings _settings;

    public EmailSender(SmtpSettings settings)
    {
        _settings = settings;
    }

    public async Task SendResetPasswordEmailAsync(
    string to,
    string userName,
    string newPassword)
{
    var message = new MimeMessage();
    message.From.Add(
        new MailboxAddress(_settings.FromName, _settings.FromEmail)
    );
    message.To.Add(MailboxAddress.Parse(to));
    message.Subject = "Nova lozinka – Rentify";

    message.Body = new TextPart("html")
    {
        Text = $"""
            <h2>Zdravo {userName},</h2>

            <p>Vaša nova lozinka je:</p>

            <h3 style="color:#2c7be5">{newPassword}</h3>

            <p>
                Preporučujemo da se odmah prijavite i promijenite lozinku.
            </p>

            <br/>
            <small>Rentify tim</small>
        """
    };

    using var client = new SmtpClient();
    await client.ConnectAsync(
        _settings.Host,
        _settings.Port,
        _settings.UseSsl
            ? SecureSocketOptions.SslOnConnect
            : SecureSocketOptions.StartTls
    );

    await client.AuthenticateAsync(
        _settings.User,
        _settings.Password
    );

    await client.SendAsync(message);
    await client.DisconnectAsync(true);
}
    
}
