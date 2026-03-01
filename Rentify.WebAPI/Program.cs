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
builder.Services.AddScoped<PushNotificationService>();
builder.Services.AddScoped<StripeService>();

var stripeSection = builder.Configuration.GetSection("Stripe");
builder.Services.Configure<StripeSettings>(stripeSection);

var stripeSettings = stripeSection.Get<StripeSettings>();
StripeConfiguration.ApiKey = stripeSettings.SecretKey;


builder.Services.AddSingleton<IConnection>(_ =>
{
    var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
    var port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672");
    var user = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
    var pass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
    var vhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

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

var firebasePath = builder.Configuration["Firebase:ServiceAccountPath"];
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
