using IPOSetu.Application.Interfaces;
using IPOSetu.Domain.Interfaces;

namespace IPOSetu.API.Middleware;

public class FirebaseAuthMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<FirebaseAuthMiddleware> _logger;

    public FirebaseAuthMiddleware(RequestDelegate next, ILogger<FirebaseAuthMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, IFirebaseAuthService firebaseAuthService, IUserRepository userRepository)
    {
        string? token = null;

        var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();
        if (!string.IsNullOrWhiteSpace(authHeader) && authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            token = authHeader["Bearer ".Length..].Trim();
        }
        else if (context.Request.Headers.TryGetValue("X-Firebase-Token", out var fbToken))
        {
            token = fbToken.FirstOrDefault();
        }

        if (!string.IsNullOrWhiteSpace(token))
        {
            try
            {
                var (firebaseUid, _) = await firebaseAuthService.VerifyTokenAsync(token);
                var user = await userRepository.GetByFirebaseUidAsync(firebaseUid);
                if (user != null)
                {
                    context.Items["CurrentUser"] = user;
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning("Token verification in middleware failed: {Message}", ex.Message);
            }
        }

        await _next(context);
    }
}
