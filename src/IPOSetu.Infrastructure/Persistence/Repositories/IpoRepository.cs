using IPOSetu.Domain.Entities;
using IPOSetu.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace IPOSetu.Infrastructure.Persistence.Repositories;

public class IpoRepository : IIpoRepository
{
    private readonly ApplicationDbContext _context;

    public IpoRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Ipo>> GetAllAsync(
        string? status = null,
        string? category = null,
        string? searchQuery = null,
        CancellationToken cancellationToken = default)
    {
        var query = _context.Ipos
            .Include(i => i.Subscriptions)
            .AsNoTracking()
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
        {
            var normalizedStatus = status.Trim().ToLowerInvariant();
            query = query.Where(i => i.Status.ToLower() == normalizedStatus);
        }

        if (!string.IsNullOrWhiteSpace(category))
        {
            var normalizedCategory = category.Trim().ToLowerInvariant();
            query = query.Where(i => i.Category.ToLower() == normalizedCategory);
        }

        if (!string.IsNullOrWhiteSpace(searchQuery))
        {
            var term = searchQuery.Trim().ToLowerInvariant();
            query = query.Where(i => i.CompanyName.ToLower().Contains(term) || i.Symbol.ToLower().Contains(term));
        }

        return await query
            .OrderByDescending(i => i.OpenDate ?? i.LastUpdatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<Ipo?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Ipos
            .Include(i => i.Subscriptions)
            .Include(i => i.Financials)
            .Include(i => i.Documents)
            .FirstOrDefaultAsync(i => i.Id == id, cancellationToken);
    }

    public async Task<Ipo?> GetBySymbolAsync(string symbol, CancellationToken cancellationToken = default)
    {
        var normalized = symbol.Trim().ToUpperInvariant();
        return await _context.Ipos
            .Include(i => i.Subscriptions)
            .Include(i => i.Financials)
            .Include(i => i.Documents)
            .FirstOrDefaultAsync(i => i.Symbol.ToUpper() == normalized, cancellationToken);
    }

    public async Task<Ipo> UpsertAsync(Ipo ipo, CancellationToken cancellationToken = default)
    {
        var existing = await _context.Ipos.FirstOrDefaultAsync(i => i.Symbol == ipo.Symbol, cancellationToken);
        if (existing == null)
        {
            ipo.LastUpdatedAt = DateTime.UtcNow;
            await _context.Ipos.AddAsync(ipo, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            return ipo;
        }

        // Update fields from official source
        existing.CompanyName = ipo.CompanyName;
        existing.Category = ipo.Category;
        existing.Status = ipo.Status;
        existing.OpenDate = ipo.OpenDate;
        existing.CloseDate = ipo.CloseDate;
        existing.OpenTime = ipo.OpenTime;
        existing.CloseTime = ipo.CloseTime;
        existing.LowerPrice = ipo.LowerPrice;
        existing.UpperPrice = ipo.UpperPrice;
        existing.LotSize = ipo.LotSize;
        existing.IssueSize = ipo.IssueSize;
        existing.ListingDate = ipo.ListingDate;
        existing.AllotmentDate = ipo.AllotmentDate;
        existing.RefundDate = ipo.RefundDate;
        existing.DematCreditDate = ipo.DematCreditDate;
        existing.FaceValue = ipo.FaceValue;
        existing.FreshIssueAmount = ipo.FreshIssueAmount;
        existing.OfferForSaleAmount = ipo.OfferForSaleAmount;
        existing.TotalShares = ipo.TotalShares;
        existing.ListingExchange = ipo.ListingExchange;
        existing.RegistrarName = ipo.RegistrarName;
        existing.LeadManagers = ipo.LeadManagers;
        existing.Industry = ipo.Industry;
        existing.BusinessDescription = ipo.BusinessDescription;
        existing.BusinessModel = ipo.BusinessModel;
        existing.Promoters = ipo.Promoters;
        existing.CompanyWebsite = ipo.CompanyWebsite;
        existing.ObjectsOfIssue = ipo.ObjectsOfIssue;
        existing.RetailPortionPercent = ipo.RetailPortionPercent;
        existing.QibPortionPercent = ipo.QibPortionPercent;
        existing.NiiPortionPercent = ipo.NiiPortionPercent;
        existing.AnchorPortionPercent = ipo.AnchorPortionPercent;

        if (ipo.GmpValue.HasValue)
        {
            existing.GmpValue = ipo.GmpValue;
            existing.GmpProvider = ipo.GmpProvider;
            existing.GmpLastUpdated = ipo.GmpLastUpdated;
        }

        existing.OfficialNseUrl = ipo.OfficialNseUrl ?? existing.OfficialNseUrl;
        existing.OfficialBseUrl = ipo.OfficialBseUrl ?? existing.OfficialBseUrl;
        existing.OfficialAllotmentUrl = ipo.OfficialAllotmentUrl ?? existing.OfficialAllotmentUrl;
        existing.SourceName = ipo.SourceName ?? existing.SourceName;
        existing.LastUpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);
        return existing;
    }

    public async Task UpsertSubscriptionAsync(IpoSubscription subscription, CancellationToken cancellationToken = default)
    {
        var existing = await _context.IpoSubscriptions
            .FirstOrDefaultAsync(s => s.IpoId == subscription.IpoId, cancellationToken);

        if (existing == null)
        {
            await _context.IpoSubscriptions.AddAsync(subscription, cancellationToken);
        }
        else
        {
            existing.RetailSubscription = subscription.RetailSubscription;
            existing.QibSubscription = subscription.QibSubscription;
            existing.NiiSubscription = subscription.NiiSubscription;
            existing.TotalSubscription = subscription.TotalSubscription;
            existing.AsOfDate = subscription.AsOfDate;
        }

        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpsertFinancialsAsync(IEnumerable<IpoFinancial> financials, CancellationToken cancellationToken = default)
    {
        foreach (var fin in financials)
        {
            var existing = await _context.IpoFinancials
                .FirstOrDefaultAsync(f => f.IpoId == fin.IpoId && f.Period == fin.Period, cancellationToken);

            if (existing == null)
            {
                await _context.IpoFinancials.AddAsync(fin, cancellationToken);
            }
            else
            {
                existing.Revenue = fin.Revenue;
                existing.Ebitda = fin.Ebitda;
                existing.ProfitAfterTax = fin.ProfitAfterTax;
                existing.NetWorth = fin.NetWorth;
                existing.TotalAssets = fin.TotalAssets;
                existing.Borrowings = fin.Borrowings;
                existing.Eps = fin.Eps;
            }
        }
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpsertDocumentsAsync(IEnumerable<IpoDocument> documents, CancellationToken cancellationToken = default)
    {
        foreach (var doc in documents)
        {
            var existing = await _context.IpoDocuments
                .FirstOrDefaultAsync(d => d.IpoId == doc.IpoId && d.DocumentType == doc.DocumentType, cancellationToken);

            if (existing == null)
            {
                await _context.IpoDocuments.AddAsync(doc, cancellationToken);
            }
            else
            {
                existing.Title = doc.Title;
                existing.OfficialUrl = doc.OfficialUrl;
            }
        }
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task LogSyncAsync(DataSyncLog log, CancellationToken cancellationToken = default)
    {
        await _context.DataSyncLogs.AddAsync(log, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
