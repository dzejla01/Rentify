using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;
using Rentify.EmailConsumer.Messages;
using Rentify.EmailConsumer.Services;
using Microsoft.Extensions.Logging;

namespace Rentify.EmailConsumer.Consumers;

public class EmailQueueConsumer
{
    private const string ResetPasswordQueue = "email.reset-password";
    private const string ResetPasswordRetryQueue = "email.reset-password.retry";
    private const string ResetPasswordDeadQueue = "email.reset-password.dead";
    private const int MaxRetryCount = 3;
    private const int RetryDelayMilliseconds = 30000;

    private readonly IChannel _channel;
    private readonly EmailSender _emailSender;
    private readonly ILogger<EmailQueueConsumer> _logger;

    public EmailQueueConsumer(
        IConnection connection,
        EmailSender emailSender,
        ILogger<EmailQueueConsumer> logger)
    {
        _emailSender = emailSender;
        _logger = logger;

        _channel = connection.CreateChannelAsync().GetAwaiter().GetResult();

        _channel.QueueDeclareAsync(
            queue: ResetPasswordQueue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null
        ).Wait();

        _channel.QueueDeclareAsync(
            queue: ResetPasswordRetryQueue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: new Dictionary<string, object?>
            {
                ["x-message-ttl"] = RetryDelayMilliseconds,
                ["x-dead-letter-exchange"] = "",
                ["x-dead-letter-routing-key"] = ResetPasswordQueue
            }
        ).Wait();

        _channel.QueueDeclareAsync(
            queue: ResetPasswordDeadQueue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null
        ).Wait();

        _channel.BasicQosAsync(0, 1, false).Wait();
    }

    public async Task StartAsync()
    {
        var resetConsumer = new AsyncEventingBasicConsumer(_channel);

        resetConsumer.ReceivedAsync += async (sender, e) =>
        {
            try
            {
                var json = Encoding.UTF8.GetString(e.Body.ToArray());

                var message =
                    JsonSerializer.Deserialize<ResetPasswordEmailMessage>(json)
                    ?? throw new InvalidOperationException("Nevalidna poruka");

                await _emailSender.SendResetPasswordEmailAsync(
                    message.To,
                    message.UserName,
                    message.ResetCode
                );

                await _channel.BasicAckAsync(e.DeliveryTag, false);
            }
            catch (Exception ex)
            {
                var retryCount = GetRetryCount(e.BasicProperties?.Headers);

                _logger.LogError(
                    ex,
                    "Reset password email failed. Attempt {Attempt}/{MaxRetryCount}",
                    retryCount + 1,
                    MaxRetryCount
                );

                if (retryCount < MaxRetryCount)
                {
                    await RepublishAsync(e.Body, ResetPasswordRetryQueue, retryCount + 1);
                    await _channel.BasicAckAsync(e.DeliveryTag, false);
                    return;
                }

                await RepublishAsync(e.Body, ResetPasswordDeadQueue, retryCount);
                await _channel.BasicAckAsync(e.DeliveryTag, false);
            }
        };

        await _channel.BasicConsumeAsync(
            queue: ResetPasswordQueue,
            autoAck: false,
            consumer: resetConsumer
        );
    }

    private async Task RepublishAsync(
        ReadOnlyMemory<byte> body,
        string queue,
        int retryCount)
    {
        var properties = new BasicProperties
        {
            Persistent = true,
            Headers = new Dictionary<string, object?>
            {
                ["x-retry-count"] = retryCount
            }
        };

        await _channel.BasicPublishAsync(
            exchange: "",
            routingKey: queue,
            mandatory: false,
            basicProperties: properties,
            body: body
        );
    }

    private static int GetRetryCount(IDictionary<string, object?>? headers)
    {
        if (headers == null || !headers.TryGetValue("x-retry-count", out var value))
            return 0;

        return value switch
        {
            byte[] bytes when int.TryParse(Encoding.UTF8.GetString(bytes), out var parsed) => parsed,
            int number => number,
            long number => (int)number,
            _ => 0
        };
    }
}
