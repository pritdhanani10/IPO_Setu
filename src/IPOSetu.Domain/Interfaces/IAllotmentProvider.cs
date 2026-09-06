namespace IPOSetu.Domain.Interfaces;

public class AllotmentCheckResult
{
    public string MaskedPan { get; set; } = string.Empty;
    public string Status { get; set; } = "NOT_AVAILABLE"; // ALLOTTED | NOT_ALLOTTED | NOT_AVAILABLE
    public int? SharesAllotted { get; set; }
    public decimal? AmountRefundedOrApplied { get; set; }
    public string? Message { get; set; }
}

public class MultiPanAllotmentResponse
{
    public string CompanyName { get; set; } = string.Empty;
    public bool OfficialCheckRequired { get; set; }
    public string? Message { get; set; }
    public string? OfficialStatusUrl { get; set; }
    public List<AllotmentCheckResult> Results { get; set; } = new();
    public int TotalPansChecked => Results.Count;
    public int AllottedCount => Results.Count(r => r.Status == "ALLOTTED");
    public int NotAllottedCount => Results.Count(r => r.Status == "NOT_ALLOTTED");
    public int UnavailableCount => Results.Count(r => r.Status == "NOT_AVAILABLE");
}

public interface IAllotmentProvider
{
    Task<bool> IsSupportedForRegistrarAsync(string registrarName, CancellationToken cancellationToken = default);
    Task<string?> GetOfficialStatusUrlAsync(string registrarName, string? symbol = null, CancellationToken cancellationToken = default);
    Task<MultiPanAllotmentResponse> CheckAllotmentAsync(string symbol, string registrarName, IEnumerable<string> decryptedPans, CancellationToken cancellationToken = default);
}
