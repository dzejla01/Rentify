using RabbitMQ.Client;
using Rentify.EmailConsumer.Configuration;
using Rentify.EmailConsumer.Consumers;
using Rentify.EmailConsumer.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Rentify.EmailConsumer.DependencyInjection;

public static class EmailConsumerDI
{
    public static IServiceCollection AddEmailConsumer(
        this IServiceCollection services,
        RabbitMqSettings rabbit,
        SmtpSettings smtp)
    {
        var factory = new ConnectionFactory
        {
            HostName = rabbit.Host,
            Port = rabbit.Port,
            UserName = rabbit.User,
            Password = rabbit.Password,
            VirtualHost = rabbit.VirtualHost
        };

        services.AddSingleton<IConnection>(_ =>
            factory.CreateConnectionAsync().GetAwaiter().GetResult()
        );

        services.AddSingleton(smtp);
        services.AddSingleton<EmailSender>();
        services.AddSingleton<EmailQueueConsumer>();

        return services;
    }
}
