using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using IPOSetu.Domain.Interfaces;

namespace IPOSetu.Application.Services;

public class IpoService : IIpoService
{
    private readonly IIpoRepository _ipoRepository;

    public IpoService(IIpoRepository ipoRepository)
    {
        _ipoRepository = ipoRepository;
    }

    public async Task<IEnumerable<IpoDto>> GetIposAsync(
        string? status = null,
        string? category = null,
        string? searchQuery = null,
        CancellationToken cancellationToken = default)
    {
        var ipos = await _ipoRepository.GetAllAsync(status, category, searchQuery, cancellationToken);

        return ipos.Select(ipo =>
        {
            var latestSub = ipo.Subscriptions.OrderByDescending(s => s.AsOfDate).FirstOrDefault();

            return new IpoDto(
                ipo.Id,
                ipo.CompanyName,
                ipo.Symbol,
                ipo.Category,
                ipo.Status,
                ipo.OpenDate,
                ipo.CloseDate,
                ipo.OpenTime,
                ipo.CloseTime,
                ipo.LowerPrice,
                ipo.UpperPrice,
                ipo.LotSize,
                ipo.MinimumInvestment,
                ipo.IssueSize,
                ipo.ListingDate,
                ipo.RegistrarName,
                latestSub?.RetailSubscription,
                latestSub?.QibSubscription,
                latestSub?.NiiSubscription,
                latestSub?.TotalSubscription,
                ipo.GmpValue,
                ipo.GmpProvider,
                ipo.GmpLastUpdated,
                ipo.OfficialAllotmentUrl,
                ipo.SourceName,
                ipo.LastUpdatedAt
            );
        });
    }

    public async Task<IpoDetailDto?> GetIpoDetailAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var ipo = await _ipoRepository.GetByIdAsync(id, cancellationToken);
        if (ipo == null) return null;

        var latestSub = ipo.Subscriptions.OrderByDescending(s => s.AsOfDate).FirstOrDefault();

        return new IpoDetailDto(
            ipo.Id,
            ipo.CompanyName,
            ipo.Symbol,
            ipo.Category,
            ipo.Status,
            ipo.OpenDate,
            ipo.CloseDate,
            ipo.ListingDate,
            ipo.AllotmentDate,
            ipo.RefundDate,
            ipo.DematCreditDate,
            ipo.LowerPrice,
            ipo.UpperPrice,
            ipo.LotSize,
            ipo.MinimumInvestment,
            ipo.IssueSize,
            ipo.FaceValue,
            ipo.FreshIssueAmount,
            ipo.OfferForSaleAmount,
            ipo.TotalShares,
            ipo.ListingExchange,
            ipo.RegistrarName,
            ipo.LeadManagers,
            ipo.Industry,
            ipo.BusinessDescription,
            ipo.BusinessModel,
            ipo.Promoters,
            ipo.CompanyWebsite,
            ipo.ObjectsOfIssue,
            ipo.RetailPortionPercent,
            ipo.QibPortionPercent,
            ipo.NiiPortionPercent,
            ipo.AnchorPortionPercent,
            ipo.GmpValue,
            ipo.GmpProvider,
            ipo.GmpLastUpdated,
            ipo.OfficialNseUrl,
            ipo.OfficialBseUrl,
            ipo.OfficialAllotmentUrl,
            ipo.SourceName,
            ipo.LastUpdatedAt,
            latestSub != null ? new IpoSubscriptionDto(
                latestSub.RetailSubscription,
                latestSub.QibSubscription,
                latestSub.NiiSubscription,
                latestSub.TotalSubscription,
                latestSub.AsOfDate
            ) : null,
            ipo.Financials.Select(f => new IpoFinancialDto(
                f.Period,
                f.Revenue,
                f.Ebitda,
                f.ProfitAfterTax,
                f.NetWorth,
                f.TotalAssets,
                f.Borrowings,
                f.Eps
            )).ToList(),
            ipo.Documents.Select(d => new IpoDocumentDto(
                d.Title,
                d.DocumentType,
                d.OfficialUrl
            )).ToList()
        );
    }

    public async Task<IpoSubscriptionDto?> GetSubscriptionAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var ipo = await _ipoRepository.GetByIdAsync(id, cancellationToken);
        var latestSub = ipo?.Subscriptions.OrderByDescending(s => s.AsOfDate).FirstOrDefault();
        if (latestSub == null) return null;

        return new IpoSubscriptionDto(
            latestSub.RetailSubscription,
            latestSub.QibSubscription,
            latestSub.NiiSubscription,
            latestSub.TotalSubscription,
            latestSub.AsOfDate
        );
    }

    public async Task<IEnumerable<IpoFinancialDto>> GetFinancialsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var ipo = await _ipoRepository.GetByIdAsync(id, cancellationToken);
        if (ipo == null) return Enumerable.Empty<IpoFinancialDto>();

        return ipo.Financials.Select(f => new IpoFinancialDto(
            f.Period,
            f.Revenue,
            f.Ebitda,
            f.ProfitAfterTax,
            f.NetWorth,
            f.TotalAssets,
            f.Borrowings,
            f.Eps
        ));
    }

    public async Task<IEnumerable<IpoDocumentDto>> GetDocumentsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var ipo = await _ipoRepository.GetByIdAsync(id, cancellationToken);
        if (ipo == null) return Enumerable.Empty<IpoDocumentDto>();

        return ipo.Documents.Select(d => new IpoDocumentDto(
            d.Title,
            d.DocumentType,
            d.OfficialUrl
        ));
    }
}
