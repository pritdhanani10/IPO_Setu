using IPOSetu.Domain.Entities;
using IPOSetu.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace IPOSetu.Infrastructure.DataProviders;

public class CompositeIpoDataProvider : IIpoDataProvider
{
    private readonly IEnumerable<IIpoDataProvider> _providers;
    private readonly ILogger<CompositeIpoDataProvider> _logger;

    public string ProviderName => "Composite Market Providers";

    public CompositeIpoDataProvider(IEnumerable<IIpoDataProvider> providers, ILogger<CompositeIpoDataProvider> logger)
    {
        _providers = providers.Where(p => p is not CompositeIpoDataProvider).ToList();
        _logger = logger;
    }

    public async Task<IEnumerable<Ipo>> FetchIposAsync(CancellationToken cancellationToken = default)
    {
        var result = new Dictionary<string, Ipo>(StringComparer.OrdinalIgnoreCase);

        foreach (var provider in _providers)
        {
            try
            {
                var ipos = await provider.FetchIposAsync(cancellationToken);
                foreach (var ipo in ipos)
                {
                    if (!string.IsNullOrWhiteSpace(ipo.Symbol) && !result.ContainsKey(ipo.Symbol))
                    {
                        result[ipo.Symbol] = ipo;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Provider {ProviderName} failed to fetch IPOs", provider.ProviderName);
            }
        }

        return result.Values;
    }

    public async Task<IpoSubscription?> FetchSubscriptionAsync(string symbol, CancellationToken cancellationToken = default)
    {
        foreach (var provider in _providers)
        {
            var sub = await provider.FetchSubscriptionAsync(symbol, cancellationToken);
            if (sub != null) return sub;
        }
        return null;
    }

    public async Task<IEnumerable<IpoFinancial>> FetchFinancialsAsync(string symbol, CancellationToken cancellationToken = default)
    {
        foreach (var provider in _providers)
        {
            var fin = await provider.FetchFinancialsAsync(symbol, cancellationToken);
            var list = fin.ToList();
            if (list.Any()) return list;
        }
        return Enumerable.Empty<IpoFinancial>();
    }

    public async Task<IEnumerable<IpoDocument>> FetchDocumentsAsync(string symbol, CancellationToken cancellationToken = default)
    {
        foreach (var provider in _providers)
        {
            var docs = await provider.FetchDocumentsAsync(symbol, cancellationToken);
            var list = docs.ToList();
            if (list.Any()) return list;
        }
        return Enumerable.Empty<IpoDocument>();
    }
}
