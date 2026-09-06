using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using IPOSetu.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace IPOSetu.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PansController : ControllerBase
{
    private readonly IPanService _panService;

    public PansController(IPanService panService)
    {
        _panService = panService;
    }

    private Guid GetCurrentUserId()
    {
        if (HttpContext.Items.TryGetValue("CurrentUser", out var userObj) && userObj is User user)
        {
            return user.Id;
        }

        // Check if UserId header was set
        if (Request.Headers.TryGetValue("X-User-Id", out var uidStr) && Guid.TryParse(uidStr, out var uid))
        {
            return uid;
        }

        throw new UnauthorizedAccessException("Authentication required.");
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<SavedPanDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetPans(CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var pans = await _panService.GetUserPansAsync(userId, cancellationToken);
            return Ok(pans);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(SavedPanDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> AddPan([FromBody] CreatePanRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var created = await _panService.AddPanAsync(userId, request, cancellationToken);
            return CreatedAtAction(nameof(GetPans), new { id = created.Id }, created);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(SavedPanDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdatePan(Guid id, [FromBody] UpdatePanRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var updated = await _panService.UpdatePanAsync(userId, id, request, cancellationToken);
            if (updated == null) return NotFound(new { message = "PAN not found." });
            return Ok(updated);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeletePan(Guid id, CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var deleted = await _panService.DeletePanAsync(userId, id, cancellationToken);
            if (!deleted) return NotFound(new { message = "PAN not found." });
            return NoContent();
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
    }
}
