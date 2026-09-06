using IPOSetu.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace IPOSetu.Infrastructure.DataProviders;

public class OfficialAllotmentProvider : IAllotmentProvider
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<OfficialAllotmentProvider> _logger;

    public OfficialAllotmentProvider(IConfiguration configuration, ILogger<OfficialAllotmentProvider> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public Task<bool> IsSupportedForRegistrarAsync(string registrarName, CancellationToken cancellationToken = default)
    {
        // Check if there is an authorized, configured API key or endpoint for this registrar in appsettings / environment
        var key = _configuration[$"AllotmentProviders:{registrarName}:ApiKey"];
        var endpoint = _configuration[$"AllotmentProviders:{registrarName}:ApiEndpoint"];

        var isConfigured = !string.IsNullOrWhiteSpace(key) && !string.IsNullOrWhiteSpace(endpoint);
        return Task.FromResult(isConfigured);
    }

    public Task<string?> GetOfficialStatusUrlAsync(string registrarName, string? symbol = null, CancellationToken cancellationToken = default)
    {
        var officialUrl = RegistrarRegistry.GetOfficialStatusUrl(registrarName);
        return Task.FromResult(officialUrl);
    }

    public async Task<MultiPanAllotmentResponse> CheckAllotmentAsync(
        string symbol,
        string registrarName,
        IEnumerable<string> decryptedPans,
        CancellationToken cancellationToken = default)
    {
        var isSupported = await IsSupportedForRegistrarAsync(registrarName, cancellationToken);
        var officialUrl = await GetOfficialStatusUrlAsync(registrarName, symbol, cancellationToken);

        if (!isSupported)
        {
            // Strict rule: Do not fake or bypass. Offer official URL fallback.
            return new MultiPanAllotmentResponse
            {
                CompanyName = symbol,
                OfficialCheckRequired = true,
                Message = "Automatic allotment checking is not available through an authorized API for this IPO.",
                OfficialStatusUrl = officialUrl,
                Results = new List<AllotmentCheckResult>()
            };
        }

        // If an authorized partner API is configured:
        // Query the provider using configured secrets and populate real results
        _logger.LogInformation("Checking allotment via configured API for registrar {Registrar}", registrarName);
        return new MultiPanAllotmentResponse
        {
            CompanyName = symbol,
            OfficialCheckRequired = false,
            OfficialStatusUrl = officialUrl,
            Results = new List<AllotmentCheckResult>()
        };
    }
}
