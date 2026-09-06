using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace IPOSetu.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Synchronizes Firebase User session and provisions/updates user account automatically.
    /// Mobile number is extracted securely from the verified Firebase ID Token.
    /// </summary>
    [HttpPost("sync")]
    [ProducesResponseType(typeof(SyncUserResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> SyncUser([FromBody] SyncUserRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.FirebaseToken))
        {
            return BadRequest(new { message = "Firebase token is required." });
        }

        try
        {
            var response = await _authService.SyncFirebaseUserAsync(request.FirebaseToken, cancellationToken);
            return Ok(response);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
