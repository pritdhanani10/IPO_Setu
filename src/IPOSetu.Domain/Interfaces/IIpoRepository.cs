using IPOSetu.Domain.Entities;

namespace IPOSetu.Domain.Interfaces;

public interface IIpoRepository
{
    Task<IEnumerable<Ipo>> GetAllAsync(
        string? status = null,
        string? category = null,
        string? searchQuery = null,
        CancellationToken cancellationToken = default);

    Task<Ipo?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Ipo?> GetBySymbolAsync(string symbol, CancellationToken cancellationToken = default);
    Task<Ipo> UpsertAsync(Ipo ipo, CancellationToken cancellationToken = default);
    Task UpsertSubscriptionAsync(IpoSubscription subscription, CancellationToken cancellationToken = default);
    Task UpsertFinancialsAsync(IEnumerable<IpoFinancial> financials, CancellationToken cancellationToken = default);
    Task UpsertDocumentsAsync(IEnumerable<IpoDocument> documents, CancellationToken cancellationToken = default);
    Task LogSyncAsync(DataSyncLog log, CancellationToken cancellationToken = default);
}
