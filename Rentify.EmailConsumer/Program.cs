using Rentify.EmailConsumer.Configuration;
using Rentify.EmailConsumer.Consumers;
using Rentify.EmailConsumer.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = Host.CreateApplicationBuilder(args);

builder.Configuration
    .AddJsonFile("appsettings.json", optional: true)
    .AddEnvironmentVariables();

var rabbitSettings = new RabbitMqSettings
{
    Host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
    Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
    User = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
    Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
    VirtualHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/"
};

var smtpSettings = new SmtpSettings
{
    Host = Environment.GetEnvironmentVariable("SMTP_HOST") ?? "smtp.gmail.com",
    Port = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "465"),
    User = Environment.GetEnvironmentVariable("SMTP_USER") ?? "owner.testni@gmail.com",
    Password = Environment.GetEnvironmentVariable("SMTP_PASS") ?? "jvbirwmajapudpcm",
    FromEmail = Environment.GetEnvironmentVariable("FROM_EMAIL") ?? "Rentify@gmail.com",
    FromName = Environment.GetEnvironmentVariable("FROM_NAME") ?? "Rentify",
    UseSsl = bool.Parse(Environment.GetEnvironmentVariable("SMTP_SSL") ?? "true")
};

builder.Services.AddEmailConsumer(rabbitSettings, smtpSettings);

var host = builder.Build();

var consumer = host.Services.GetRequiredService<EmailQueueConsumer>();
await consumer.StartAsync();

await host.RunAsync();
