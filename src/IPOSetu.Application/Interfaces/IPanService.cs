using IPOSetu.Application.DTOs;

namespace IPOSetu.Application.Interfaces;

public interface IPanService
{
    Task<IEnumerable<SavedPanDto>> GetUserPansAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<SavedPanDto> AddPanAsync(Guid userId, CreatePanRequest request, CancellationToken cancellationToken = default);
    Task<SavedPanDto?> UpdatePanAsync(Guid userId, Guid panId, UpdatePanRequest request, CancellationToken cancellationToken = default);
    Task<bool> DeletePanAsync(Guid userId, Guid panId, CancellationToken cancellationToken = default);
}

public interface IAllotmentService
{
    Task<CheckAllotmentResponse> CheckAllotmentAsync(Guid userId, CheckAllotmentRequest request, CancellationToken cancellationToken = default);
}
