using IPOSetu.Domain.Entities;

namespace IPOSetu.Domain.Interfaces;

public interface IIpoDataProvider
{
    string ProviderName { get; }
    Task<IEnumerable<Ipo>> FetchIposAsync(CancellationToken cancellationToken = default);
    Task<IpoSubscription?> FetchSubscriptionAsync(string symbol, CancellationToken cancellationToken = default);
    Task<IEnumerable<IpoFinancial>> FetchFinancialsAsync(string symbol, CancellationToken cancellationToken = default);
    Task<IEnumerable<IpoDocument>> FetchDocumentsAsync(string symbol, CancellationToken cancellationToken = default);
}
