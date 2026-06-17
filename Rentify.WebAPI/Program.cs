using DotNetEnv;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;
using Rentify.Services;
using Rentify.Services.AppointmentStateMachine;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using Rentify.Services.PaymentStateMachine;
using Rentify.Services.ReservationStateMachine;
using Rentify.Services.Services;
using Rentify.WebAPI.Authentication;
using Rentify.WebAPI.Configuration;
using Rentify.WebAPI.Services;
using Stripe;

var envPath = Path.Combine(Directory.GetCurrentDirectory(), "..", ".env");
if (System.IO.File.Exists(envPath))
{
    Env.Load(envPath);
}

var builder = WebApplication.CreateBuilder(args);

string GetRequiredEnv(string key)
{
    var value = Environment.GetEnvironmentVariable(key);
    if (string.IsNullOrWhiteSpace(value))
        throw new InvalidOperationException($"Missing env var: {key}");
    return value;
}

string? GetOptionalEnv(string key) => Environment.GetEnvironmentVariable(key);

int GetIntEnv(string key, int defaultValue)
{
    var raw = Environment.GetEnvironmentVariable(key);
    return int.TryParse(raw, out var value) ? value : defaultValue;
}

bool GetBoolEnv(string key, bool defaultValue = false)
{
    var raw = Environment.GetEnvironmentVariable(key);
    return bool.TryParse(raw, out var value) ? value : defaultValue;
}

var connectionString =
    GetOptionalEnv("ConnectionStrings__DefaultConnection")
    ?? GetOptionalEnv("CONNECTION_STRING_DOCKER")
    ?? GetRequiredEnv("CONNECTION_STRING_LOCAL");

builder.Services.AddDbContext<RentifyDbContext>(options =>
    options.UseNpgsql(connectionString)
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
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
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

// SERVICES
builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<IStatusService, StatusService>();
builder.Services.AddScoped<IBuildingTypeService, BuildingTypeService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPropertyService, PropertyService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();
builder.Services.AddScoped<IReservationService, ReservationService>();
builder.Services.AddScoped<IReviewService, Rentify.Services.Services.ReviewService>();
builder.Services.AddScoped<IImageService, ImageService>();
builder.Services.AddScoped<IPropertyImageService, PropertyImageService>();
builder.Services.AddScoped<IDeviceTokenService, DeviceTokenService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IQuestionService, QuestionService>();
builder.Services.AddScoped<IAnswerService, AnswerService>();
builder.Services.AddScoped<IFavoriteService, FavoriteService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IExpenseService, ExpenseService>();
builder.Services.AddScoped<PushNotificationService>();

// STATE MACHINE
builder.Services.AddTransient<BaseReservationState>();
builder.Services.AddTransient<InitialReservationState>();
builder.Services.AddTransient<PendingReservationState>();
builder.Services.AddTransient<ApprovedReservationState>();
builder.Services.AddTransient<FinishedReservationState>();
builder.Services.AddTransient<RejectedReservationState>();
builder.Services.AddTransient<CancelledReservationState>();

builder.Services.AddTransient<BaseAppointmentState>();
builder.Services.AddTransient<InitialAppointmentState>();
builder.Services.AddTransient<PendingAppointmentState>();
builder.Services.AddTransient<ApprovedAppointmentState>();
builder.Services.AddTransient<FinishedAppointmentState>();
builder.Services.AddTransient<RejectedAppointmentState>();
builder.Services.AddTransient<CancelledAppointmentState>();

builder.Services.AddTransient<BasePaymentState>();
builder.Services.AddScoped<PendingPaymentState>();
builder.Services.AddScoped<ProcessingPaymentState>();
builder.Services.AddScoped<PaidPaymentState>();
builder.Services.AddScoped<UnpaidPaymentState>();
builder.Services.AddScoped<CancelledPaymentState>();
builder.Services.AddScoped<FailedPaymentState>();

//TOOLS
builder.Services.AddHttpContextAccessor();

// STRIPE
var stripeSecretKey = GetRequiredEnv("STRIPE_SECRET_KEY");
var stripeWebhookSecret = GetRequiredEnv("STRIPE_WEBHOOK_SECRET");

StripeConfiguration.ApiKey = stripeSecretKey;

builder.Services.AddSingleton(new StripeSettings
{
    SecretKey = stripeSecretKey,
    WebhookSecret = stripeWebhookSecret
});

builder.Services.AddScoped<IStripeService, StripeService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();


builder.Services.AddSingleton<IConnection>(_ =>
{
    var host = GetRequiredEnv("RABBITMQ_HOST");
    var port = GetIntEnv("RABBITMQ_PORT", 5672);
    var user = GetRequiredEnv("RABBITMQ_USER");
    var pass = GetRequiredEnv("RABBITMQ_PASSWORD");
    var vhost = GetOptionalEnv("RABBITMQ_VIRTUALHOST") ?? "/";

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
    GetOptionalEnv("FIREBASE_CREDENTIALS_PATH")
    ?? GetOptionalEnv("FIREBASE_CREDENTIALS_PATH_DOCKER")
    ?? GetOptionalEnv("FIREBASE_CREDENTIALS_PATH_LOCAL");

if (string.IsNullOrWhiteSpace(firebasePath))
    throw new Exception("Firebase credentials path nije definisan!");

FirebaseApp.Create(new AppOptions
{
    Credential = GoogleCredential.FromFile(firebasePath)
});

// AUTH
builder.Services.AddJwtAuthentication(builder.Configuration);
builder.Services.AddAuthorization();

var app = builder.Build();

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.ContentType = "application/json";

        var error = context.Features.Get<IExceptionHandlerFeature>()?.Error;

        switch (error)
        {
            case UserException ex:
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                await context.Response.WriteAsJsonAsync(new { message = ex.Message });
                break;

            case ArgumentException ex:
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                await context.Response.WriteAsJsonAsync(new { message = ex.Message });
                break;

            case InvalidOperationException ex:
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                await context.Response.WriteAsJsonAsync(new { message = ex.Message });
                break;

            case ForbiddenException ex:
                context.Response.StatusCode = StatusCodes.Status403Forbidden;
                await context.Response.WriteAsJsonAsync(new { message = ex.Message });
                break;

            case NotFoundException ex:
                context.Response.StatusCode = StatusCodes.Status404NotFound;
                await context.Response.WriteAsJsonAsync(new { message = ex.Message });
                break;

            case NotSupportedException ex:
                context.Response.StatusCode = StatusCodes.Status405MethodNotAllowed;
                await context.Response.WriteAsJsonAsync(new { message = ex.Message });
                break;

            default:
                context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                await context.Response.WriteAsJsonAsync(new
                {
                    message = "Greska prilikom komunikacije sa serverom"
                });
                break;
        }
    });
});

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// MIGRATIONS
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
