using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using IPOSetu.Domain.Entities;
using IPOSetu.Domain.Interfaces;

namespace IPOSetu.Application.Services;

public class PanService : IPanService
{
    private readonly ISavedPanRepository _panRepository;
    private readonly IPanEncryptionService _encryptionService;

    public PanService(ISavedPanRepository panRepository, IPanEncryptionService encryptionService)
    {
        _panRepository = panRepository;
        _encryptionService = encryptionService;
    }

    public async Task<IEnumerable<SavedPanDto>> GetUserPansAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var pans = await _panRepository.GetByUserIdAsync(userId, cancellationToken);
        return pans.Select(p => new SavedPanDto(p.Id, p.MaskedPan, p.Label, p.CreatedAt));
    }

    public async Task<SavedPanDto> AddPanAsync(Guid userId, CreatePanRequest request, CancellationToken cancellationToken = default)
    {
        var normalizedPan = request.Pan.Trim().ToUpperInvariant();
        if (!_encryptionService.IsValidFormat(normalizedPan))
        {
            throw new ArgumentException("Invalid PAN format. PAN must be 10 characters: 5 uppercase letters, 4 digits, 1 uppercase letter.");
        }

        var masked = _encryptionService.Mask(normalizedPan);
        var exists = await _panRepository.ExistsForUserAsync(userId, masked, cancellationToken);
        if (exists)
        {
            throw new InvalidOperationException("This PAN card is already saved in your account.");
        }

        var encrypted = _encryptionService.Encrypt(normalizedPan);
        var pan = new SavedPan
        {
            UserId = userId,
            EncryptedPan = encrypted,
            MaskedPan = masked,
            Label = string.IsNullOrWhiteSpace(request.Label) ? null : request.Label.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var created = await _panRepository.CreateAsync(pan, cancellationToken);
        return new SavedPanDto(created.Id, created.MaskedPan, created.Label, created.CreatedAt);
    }

    public async Task<SavedPanDto?> UpdatePanAsync(Guid userId, Guid panId, UpdatePanRequest request, CancellationToken cancellationToken = default)
    {
        var pan = await _panRepository.GetByIdAsync(panId, cancellationToken);
        if (pan == null || pan.UserId != userId) return null;

        pan.Label = string.IsNullOrWhiteSpace(request.Label) ? null : request.Label.Trim();
        pan.UpdatedAt = DateTime.UtcNow;

        var updated = await _panRepository.UpdateAsync(pan, cancellationToken);
        return new SavedPanDto(updated.Id, updated.MaskedPan, updated.Label, updated.CreatedAt);
    }

    public async Task<bool> DeletePanAsync(Guid userId, Guid panId, CancellationToken cancellationToken = default)
    {
        return await _panRepository.DeleteAsync(panId, userId, cancellationToken);
    }
}
