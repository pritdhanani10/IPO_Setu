using IPOSetu.API.Middleware;
using IPOSetu.Application.Interfaces;
using IPOSetu.Application.Services;
using IPOSetu.Domain.Interfaces;
using IPOSetu.Infrastructure.BackgroundServices;
using IPOSetu.Infrastructure.DataProviders;
using IPOSetu.Infrastructure.Encryption;
using IPOSetu.Infrastructure.Firebase;
using IPOSetu.Infrastructure.Persistence;
using IPOSetu.Infrastructure.Persistence.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// 1. Database & Persistence
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    if (!string.IsNullOrWhiteSpace(connectionString))
    {
        options.UseNpgsql(connectionString);
    }
});

// 2. Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<ISavedPanRepository, SavedPanRepository>();
builder.Services.AddScoped<IIpoRepository, IpoRepository>();

// 3. Security & Encryption
builder.Services.AddSingleton<IPanEncryptionService, AesGcmPanEncryptionService>();

// 4. Firebase Authentication
builder.Services.AddSingleton<IFirebaseAuthService, FirebaseAdminService>();

// 5. Application Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IIpoService, IpoService>();
builder.Services.AddScoped<IPanService, PanService>();
builder.Services.AddScoped<IAllotmentService, AllotmentService>();
builder.Services.AddScoped<IRecaptchaService, IPOSetu.Infrastructure.Security.RecaptchaEnterpriseService>();

// 6. Data Providers
builder.Services.AddHttpClient<NseIpoProvider>();
builder.Services.AddHttpClient<BseIpoProvider>();
builder.Services.AddScoped<IIpoDataProvider, CompositeIpoDataProvider>(sp =>
{
    var nse = sp.GetRequiredService<NseIpoProvider>();
    var bse = sp.GetRequiredService<BseIpoProvider>();
    var logger = sp.GetRequiredService<ILogger<CompositeIpoDataProvider>>();
    return new CompositeIpoDataProvider(new IIpoDataProvider[] { nse, bse }, logger);
});

builder.Services.AddScoped<IAllotmentProvider, OfficialAllotmentProvider>();

// 7. Background Services
builder.Services.AddHostedService<IpoDataSyncBackgroundService>();

// 8. Controllers & Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "IPOSetu API",
        Version = "v1",
        Description = "Production REST API for IPOSetu: Indian IPO market information, official allotment tracking, and multi-PAN management."
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Firebase ID Token. Format: Bearer {token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
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

// 9. CORS Policy
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Auto-migrate database schema on startup if database is available
using (var scope = app.Services.CreateScope())
{
    try
    {
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        if (db.Database.CanConnect())
        {
            db.Database.EnsureCreated();
        }
    }
    catch (Exception ex)
    {
        app.Logger.LogWarning(ex, "Could not connect to PostgreSQL database on startup. Schema creation skipped.");
    }
}

app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment() || true)
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "IPOSetu API v1"));
}

app.UseCors("AllowAll");

app.UseMiddleware<FirebaseAuthMiddleware>();

app.UseAuthorization();

app.MapControllers();

app.Run();
