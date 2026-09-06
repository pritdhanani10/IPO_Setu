using IPOSetu.Domain.Entities;

namespace IPOSetu.Domain.Interfaces;

public interface ISavedPanRepository
{
    Task<IEnumerable<SavedPan>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<SavedPan?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<SavedPan> CreateAsync(SavedPan pan, CancellationToken cancellationToken = default);
    Task<SavedPan> UpdateAsync(SavedPan pan, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(Guid id, Guid userId, CancellationToken cancellationToken = default);
    Task<bool> ExistsForUserAsync(Guid userId, string maskedPan, CancellationToken cancellationToken = default);
}
