using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;
using Rentify.EmailConsumer.Messages;
using Rentify.EmailConsumer.Services;

namespace Rentify.EmailConsumer.Consumers;

public class EmailQueueConsumer
{
    private readonly IChannel _channel;
    private readonly EmailSender _emailSender;

    public EmailQueueConsumer(
        IConnection connection,
        EmailSender emailSender)
    {
        _emailSender = emailSender;

        _channel = connection.CreateChannelAsync().GetAwaiter().GetResult();

        _channel.QueueDeclareAsync(
            queue: "email.reset-password",
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null
        ).Wait();


        _channel.BasicQosAsync(0, 1, false).Wait();
    }

    public async Task StartAsync()
    {
        // ===============================
        // RESET PASSWORD CONSUMER
        // ===============================
        var resetConsumer = new AsyncEventingBasicConsumer(_channel);

        resetConsumer.ReceivedAsync += async (sender, e) =>
        {
            try
            {
                var json = Encoding.UTF8.GetString(e.Body.ToArray());

                var message =
                    JsonSerializer.Deserialize<ResetPasswordEmailMessage>(json)
                    ?? throw new Exception("Nevalidna poruka");

                await _emailSender.SendResetPasswordEmailAsync(
                    message.To,
                    message.UserName,
                    message.NewPassword
                );

                await _channel.BasicAckAsync(e.DeliveryTag, false);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[RESET EMAIL ERROR] {ex.Message}");
                await _channel.BasicNackAsync(
                    e.DeliveryTag,
                    false,
                    requeue: false
                );
            }
        };

        await _channel.BasicConsumeAsync(
            queue: "email.reset-password",
            autoAck: false,
            consumer: resetConsumer
        );

    }
}

