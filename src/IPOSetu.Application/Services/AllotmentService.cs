using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using IPOSetu.Domain.Interfaces;

namespace IPOSetu.Application.Services;

public class AllotmentService : IAllotmentService
{
    private readonly IIpoRepository _ipoRepository;
    private readonly ISavedPanRepository _panRepository;
    private readonly IAllotmentProvider _allotmentProvider;
    private readonly IPanEncryptionService _encryptionService;

    public AllotmentService(
        IIpoRepository ipoRepository,
        ISavedPanRepository panRepository,
        IAllotmentProvider allotmentProvider,
        IPanEncryptionService encryptionService)
    {
        _ipoRepository = ipoRepository;
        _panRepository = panRepository;
        _allotmentProvider = allotmentProvider;
        _encryptionService = encryptionService;
    }

    public async Task<CheckAllotmentResponse> CheckAllotmentAsync(
        Guid userId,
        CheckAllotmentRequest request,
        CancellationToken cancellationToken = default)
    {
        var ipo = await _ipoRepository.GetByIdAsync(request.IpoId, cancellationToken);
        if (ipo == null)
        {
            throw new KeyNotFoundException("IPO not found.");
        }

        var userPans = (await _panRepository.GetByUserIdAsync(userId, cancellationToken))
            .Where(p => request.SelectedPanIds.Contains(p.Id))
            .ToList();

        if (!userPans.Any())
        {
            throw new ArgumentException("No valid PAN cards selected.");
        }

        var registrar = ipo.RegistrarName ?? string.Empty;
        var isSupported = await _allotmentProvider.IsSupportedForRegistrarAsync(registrar, cancellationToken);

        if (!isSupported)
        {
            var officialUrl = await _allotmentProvider.GetOfficialStatusUrlAsync(registrar, ipo.Symbol, cancellationToken)
                ?? ipo.OfficialAllotmentUrl;

            return new CheckAllotmentResponse(
                CompanyName: ipo.CompanyName,
                OfficialCheckRequired: true,
                Message: "Automatic allotment checking is not available through an authorized API for this IPO.",
                OfficialStatusUrl: officialUrl,
                Results: new List<PanAllotmentResultDto>(),
                TotalPansChecked: userPans.Count,
                AllottedCount: 0,
                NotAllottedCount: 0,
                UnavailableCount: userPans.Count
            );
        }

        // Programmatic check through authorized integration
        var decryptedPans = userPans.Select(p => _encryptionService.Decrypt(p.EncryptedPan)).ToList();
        var providerResult = await _allotmentProvider.CheckAllotmentAsync(ipo.Symbol, registrar, decryptedPans, cancellationToken);

        return new CheckAllotmentResponse(
            CompanyName: ipo.CompanyName,
            OfficialCheckRequired: providerResult.OfficialCheckRequired,
            Message: providerResult.Message,
            OfficialStatusUrl: providerResult.OfficialStatusUrl ?? ipo.OfficialAllotmentUrl,
            Results: providerResult.Results.Select(r => new PanAllotmentResultDto(
                r.MaskedPan,
                r.Status,
                r.SharesAllotted,
                r.AmountRefundedOrApplied,
                r.Message
            )).ToList(),
            TotalPansChecked: providerResult.TotalPansChecked,
            AllottedCount: providerResult.AllottedCount,
            NotAllottedCount: providerResult.NotAllottedCount,
            UnavailableCount: providerResult.UnavailableCount
        );
    }
}
