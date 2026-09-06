using System.Net.Http.Json;
using IPOSetu.Domain.Entities;
using IPOSetu.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace IPOSetu.Infrastructure.DataProviders;

public class NseIpoProvider : IIpoDataProvider
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<NseIpoProvider> _logger;

    public string ProviderName => "NSE Official";

    public NseIpoProvider(HttpClient httpClient, IConfiguration configuration, ILogger<NseIpoProvider> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<IEnumerable<Ipo>> FetchIposAsync(CancellationToken cancellationToken = default)
    {
        var apiKey = _configuration["MarketData:NseApiKey"];
        var endpoint = _configuration["MarketData:NseEndpoint"];

        if (string.IsNullOrWhiteSpace(endpoint))
        {
            _logger.LogInformation("NSE official provider endpoint not configured. Real data sync skipped for this provider.");
            return Enumerable.Empty<Ipo>();
        }

        try
        {
            var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
            if (!string.IsNullOrWhiteSpace(apiKey))
            {
                request.Headers.Add("X-API-KEY", apiKey);
            }

            var response = await _httpClient.SendAsync(request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("NSE official provider returned status {StatusCode}", response.StatusCode);
                return Enumerable.Empty<Ipo>();
            }

            var ipos = await response.Content.ReadFromJsonAsync<List<Ipo>>(cancellationToken: cancellationToken);
            return ipos ?? Enumerable.Empty<Ipo>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching IPO data from NSE provider.");
            return Enumerable.Empty<Ipo>();
        }
    }

    public Task<IpoSubscription?> FetchSubscriptionAsync(string symbol, CancellationToken cancellationToken = default)
    {
        return Task.FromResult<IpoSubscription?>(null);
    }

    public Task<IEnumerable<IpoFinancial>> FetchFinancialsAsync(string symbol, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(Enumerable.Empty<IpoFinancial>());
    }

    public Task<IEnumerable<IpoDocument>> FetchDocumentsAsync(string symbol, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(Enumerable.Empty<IpoDocument>());
    }
}
