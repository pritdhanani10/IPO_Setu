using IPOSetu.Application.DTOs;

namespace IPOSetu.Application.Interfaces;

public interface IIpoService
{
    Task<IEnumerable<IpoDto>> GetIposAsync(
        string? status = null,
        string? category = null,
        string? searchQuery = null,
        CancellationToken cancellationToken = default);

    Task<IpoDetailDto?> GetIpoDetailAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IpoSubscriptionDto?> GetSubscriptionAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<IpoFinancialDto>> GetFinancialsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<IpoDocumentDto>> GetDocumentsAsync(Guid id, CancellationToken cancellationToken = default);
}
