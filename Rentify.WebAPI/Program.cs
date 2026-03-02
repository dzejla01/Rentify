using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;
using Rentify.Services;
using Rentify.Services.Interfaces;
using Rentify.Services.Services;
using Rentify.WebAPI.Authentication;
using Rentify.WebAPI.Configuration;
using Rentify.WebAPI.Services;
using Stripe;
using DotNetEnv;

Env.Load(Path.Combine(Directory.GetCurrentDirectory(), "..", ".env"));

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<RentifyDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"))
);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Rentify API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Unesi: Bearer {token}"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

TypeAdapterConfig.GlobalSettings.Default
            .IgnoreNullValues(true)      
            .PreserveReference(true)     
            .ShallowCopyForSameType(true);

builder.Services.AddSingleton(TypeAdapterConfig.GlobalSettings);
builder.Services.AddScoped<IMapper, ServiceMapper>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPropertyService,PropertyService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IReservationService, ReservationService>();
builder.Services.AddScoped<IReviewService, Rentify.Services.Services.ReviewService>();
builder.Services.AddScoped<IImageService, ImageService>();
builder.Services.AddScoped<IPropertyImageService, PropertyImageService>();
builder.Services.AddScoped<IDeviceTokenService, DeviceTokenService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<PushNotificationService>();
builder.Services.AddScoped<StripeService>();


var stripeSecretKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");

if (string.IsNullOrEmpty(stripeSecretKey))
{
    throw new Exception("Stripe secret key nije pronađen u .env fajlu!");
}

StripeConfiguration.ApiKey = stripeSecretKey;


builder.Services.AddSingleton<IConnection>(_ =>
{
    var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST");
    var portRaw = Environment.GetEnvironmentVariable("RABBITMQ_PORT");
    var user = Environment.GetEnvironmentVariable("RABBITMQ_USER"); 
    var pass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD");
    var vhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

    if (string.IsNullOrWhiteSpace(host))
        throw new InvalidOperationException("Missing env var: RABBITMQ_HOST");
    if (string.IsNullOrWhiteSpace(portRaw) || !int.TryParse(portRaw, out var port))
        throw new InvalidOperationException("Missing/invalid env var: RABBITMQ_PORT");
    if (string.IsNullOrWhiteSpace(user))
        throw new InvalidOperationException("Missing env var: RABBITMQ_USER");
    if (string.IsNullOrWhiteSpace(pass))
        throw new InvalidOperationException("Missing env var: RABBITMQ_PASSWORD");

    var factory = new ConnectionFactory
    {
        HostName = host,
        Port = port,
        UserName = user,
        Password = pass,
        VirtualHost = vhost
    };

    return factory.CreateConnectionAsync().GetAwaiter().GetResult();
});

var firebasePath =
    builder.Configuration["FIREBASE_CREDENTIALS_PATH_DOCKER"] 
    ?? builder.Configuration["Firebase:ServiceAccountPath"]; 

FirebaseApp.Create(new AppOptions
{
    Credential = GoogleCredential.FromFile(firebasePath)
});

builder.Services.AddJwtAuthentication(builder.Configuration);
builder.Services.AddAuthorization();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<RentifyDbContext>();
    db.Database.Migrate();
}

app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.Run();