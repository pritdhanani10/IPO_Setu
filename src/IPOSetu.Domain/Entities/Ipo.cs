namespace IPOSetu.Domain.Entities;

public class Ipo
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string? ExternalSourceId { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;
    public string Category { get; set; } = "mainboard"; // mainboard | sme
    public string Status { get; set; } = "upcoming";   // open | upcoming | closed | listed

    public DateTime? OpenDate { get; set; }
    public DateTime? CloseDate { get; set; }
    public string? OpenTime { get; set; }
    public string? CloseTime { get; set; }
    public DateTime? ListingDate { get; set; }
    public DateTime? AllotmentDate { get; set; }
    public DateTime? RefundDate { get; set; }
    public DateTime? DematCreditDate { get; set; }

    public decimal? LowerPrice { get; set; }
    public decimal? UpperPrice { get; set; }
    public int? LotSize { get; set; }
    public decimal? IssueSize { get; set; } // in Crores
    public decimal? FaceValue { get; set; }
    public decimal? FreshIssueAmount { get; set; }
    public decimal? OfferForSaleAmount { get; set; }
    public long? TotalShares { get; set; }
    public string? ListingExchange { get; set; }

    public string? RegistrarName { get; set; }
    public string? LeadManagers { get; set; }
    public string? Industry { get; set; }
    public string? BusinessDescription { get; set; }
    public string? BusinessModel { get; set; }
    public string? Promoters { get; set; }
    public string? CompanyWebsite { get; set; }
    public string? ObjectsOfIssue { get; set; }

    // Issue structure
    public decimal? RetailPortionPercent { get; set; }
    public decimal? QibPortionPercent { get; set; }
    public decimal? NiiPortionPercent { get; set; }
    public decimal? AnchorPortionPercent { get; set; }

    // Unofficial GMP (strictly only if provided by a legitimate configured provider)
    public decimal? GmpValue { get; set; }
    public string? GmpProvider { get; set; }
    public DateTime? GmpLastUpdated { get; set; }

    // Official links
    public string? OfficialNseUrl { get; set; }
    public string? OfficialBseUrl { get; set; }
    public string? OfficialAllotmentUrl { get; set; }
    public string? SourceName { get; set; }
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<IpoSubscription> Subscriptions { get; set; } = new List<IpoSubscription>();
    public ICollection<IpoFinancial> Financials { get; set; } = new List<IpoFinancial>();
    public ICollection<IpoDocument> Documents { get; set; } = new List<IpoDocument>();

    public decimal? MinimumInvestment =>
        UpperPrice.HasValue && LotSize.HasValue ? UpperPrice.Value * LotSize.Value : null;
}
