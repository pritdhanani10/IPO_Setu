using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using IPOSetu.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace IPOSetu.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AllotmentController : ControllerBase
{
    private readonly IAllotmentService _allotmentService;

    public AllotmentController(IAllotmentService allotmentService)
    {
        _allotmentService = allotmentService;
    }

    private Guid GetCurrentUserId()
    {
        if (HttpContext.Items.TryGetValue("CurrentUser", out var userObj) && userObj is User user)
        {
            return user.Id;
        }

        if (Request.Headers.TryGetValue("X-User-Id", out var uidStr) && Guid.TryParse(uidStr, out var uid))
        {
            return uid;
        }

        throw new UnauthorizedAccessException("Authentication required to check allotment.");
    }

    /// <summary>
    /// Checks allotment for the selected saved PAN cards.
    /// If an authorized API is configured, queries the registrar securely.
    /// Otherwise, provides officialCheckRequired: true with the direct official registrar status URL.
    /// </summary>
    [HttpPost("check")]
    [ProducesResponseType(typeof(CheckAllotmentResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> CheckAllotment([FromBody] CheckAllotmentRequest request, CancellationToken cancellationToken)
    {
        if (request.SelectedPanIds == null || !request.SelectedPanIds.Any())
        {
            return BadRequest(new { message = "At least one saved PAN card must be selected." });
        }

        try
        {
            var userId = GetCurrentUserId();
            var response = await _allotmentService.CheckAllotmentAsync(userId, request, cancellationToken);
            return Ok(response);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
