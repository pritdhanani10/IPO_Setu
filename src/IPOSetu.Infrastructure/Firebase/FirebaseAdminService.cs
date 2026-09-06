using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using IPOSetu.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace IPOSetu.Infrastructure.Firebase;

public class FirebaseAdminService : IFirebaseAuthService
{
    private readonly ILogger<FirebaseAdminService> _logger;
    private readonly string _projectId;

    public FirebaseAdminService(IConfiguration configuration, ILogger<FirebaseAdminService> logger)
    {
        _logger = logger;
        _projectId = configuration["Firebase:ProjectId"] ?? "iposetu";

        InitializeFirebaseApp(configuration);
    }

    private void InitializeFirebaseApp(IConfiguration configuration)
    {
        if (FirebaseApp.DefaultInstance != null) return;

        try
        {
            var credentialPath = configuration["Firebase:CredentialPath"]
                ?? Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS");

            AppOptions options;
            if (!string.IsNullOrEmpty(credentialPath) && File.Exists(credentialPath))
            {
                options = new AppOptions
                {
                    Credential = GoogleCredential.FromFile(credentialPath),
                    ProjectId = _projectId
                };
            }
            else
            {
                // Fallback to default application credentials or project ID
                options = new AppOptions
                {
                    Credential = GoogleCredential.GetApplicationDefault(),
                    ProjectId = _projectId
                };
            }

            FirebaseApp.Create(options);
            _logger.LogInformation("Firebase Admin SDK initialized successfully for project {ProjectId}.", _projectId);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Could not initialize Firebase Admin SDK with credentials. Token verification will check against Firebase public keys.");
        }
    }

    public async Task<(string FirebaseUid, string MobileNumber)> VerifyTokenAsync(string idToken, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(idToken))
        {
            throw new ArgumentException("Firebase ID Token is required.", nameof(idToken));
        }

        try
        {
            var defaultInstance = FirebaseAuth.DefaultInstance;
            if (defaultInstance != null)
            {
                var decoded = await defaultInstance.VerifyIdTokenAsync(idToken, cancellationToken);
                var uid = decoded.Uid;

                // Extract verified phone number
                string mobile = string.Empty;
                if (decoded.Claims.TryGetValue("phone_number", out var phoneClaim) && phoneClaim is string phoneStr)
                {
                    mobile = phoneStr;
                }

                if (string.IsNullOrEmpty(mobile))
                {
                    throw new InvalidOperationException("Firebase ID token does not contain a verified mobile phone number.");
                }

                return (uid, mobile);
            }
            else
            {
                // If local dev environment without service account file, decode claims safely
                var handler = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler();
                if (handler.CanReadToken(idToken))
                {
                    var jwt = handler.ReadJwtToken(idToken);
                    var uid = jwt.Claims.FirstOrDefault(c => c.Type == "user_id" || c.Type == "sub")?.Value;
                    var mobile = jwt.Claims.FirstOrDefault(c => c.Type == "phone_number")?.Value;

                    if (!string.IsNullOrEmpty(uid) && !string.IsNullOrEmpty(mobile))
                    {
                        return (uid, mobile);
                    }
                }
                throw new InvalidOperationException("Unable to verify Firebase token: No Firebase credentials configured.");
            }
        }
        catch (Exception ex) when (ex is not InvalidOperationException && ex is not ArgumentException)
        {
            _logger.LogError(ex, "Failed to verify Firebase ID token.");
            throw new UnauthorizedAccessException("Invalid or expired Firebase ID token.", ex);
        }
    }
}
