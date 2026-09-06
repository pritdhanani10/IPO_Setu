using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace IPOSetu.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class IposController : ControllerBase
{
    private readonly IIpoService _ipoService;

    public IposController(IIpoService ipoService)
    {
        _ipoService = ipoService;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<IpoDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetIpos(
        [FromQuery] string? status,
        [FromQuery] string? category,
        [FromQuery] string? search,
        CancellationToken cancellationToken)
    {
        var ipos = await _ipoService.GetIposAsync(status, category, search, cancellationToken);
        return Ok(ipos);
    }

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(IpoDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetIpoById(Guid id, CancellationToken cancellationToken)
    {
        var ipo = await _ipoService.GetIpoDetailAsync(id, cancellationToken);
        if (ipo == null) return NotFound(new { message = "IPO not found." });
        return Ok(ipo);
    }

    [HttpGet("{id:guid}/subscription")]
    [ProducesResponseType(typeof(IpoSubscriptionDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetSubscription(Guid id, CancellationToken cancellationToken)
    {
        var sub = await _ipoService.GetSubscriptionAsync(id, cancellationToken);
        if (sub == null) return NotFound(new { message = "Subscription data currently unavailable." });
        return Ok(sub);
    }

    [HttpGet("{id:guid}/financials")]
    [ProducesResponseType(typeof(IEnumerable<IpoFinancialDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetFinancials(Guid id, CancellationToken cancellationToken)
    {
        var financials = await _ipoService.GetFinancialsAsync(id, cancellationToken);
        return Ok(financials);
    }

    [HttpGet("{id:guid}/documents")]
    [ProducesResponseType(typeof(IEnumerable<IpoDocumentDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDocuments(Guid id, CancellationToken cancellationToken)
    {
        var documents = await _ipoService.GetDocumentsAsync(id, cancellationToken);
        return Ok(documents);
    }
}
