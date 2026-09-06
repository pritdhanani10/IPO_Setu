namespace IPOSetu.Application.DTOs;

public record IpoDto(
    Guid Id,
    string CompanyName,
    string Symbol,
    string Category,
    string Status,
    DateTime? OpenDate,
    DateTime? CloseDate,
    string? OpenTime,
    string? CloseTime,
    decimal? LowerPrice,
    decimal? UpperPrice,
    int? LotSize,
    decimal? MinimumInvestment,
    decimal? IssueSize,
    DateTime? ListingDate,
    string? RegistrarName,
    decimal? RetailSubscription,
    decimal? QibSubscription,
    decimal? NiiSubscription,
    decimal? TotalSubscription,
    decimal? GmpValue,
    string? GmpProvider,
    DateTime? GmpLastUpdated,
    string? OfficialAllotmentUrl,
    string? SourceName,
    DateTime LastUpdatedAt
);

public record IpoSubscriptionDto(
    decimal? RetailSubscription,
    decimal? QibSubscription,
    decimal? NiiSubscription,
    decimal? TotalSubscription,
    DateTime AsOfDate
);

public record IpoFinancialDto(
    string Period,
    decimal? Revenue,
    decimal? Ebitda,
    decimal? ProfitAfterTax,
    decimal? NetWorth,
    decimal? TotalAssets,
    decimal? Borrowings,
    decimal? Eps
);

public record IpoDocumentDto(
    string Title,
    string DocumentType,
    string OfficialUrl
);

public record IpoDetailDto(
    Guid Id,
    string CompanyName,
    string Symbol,
    string Category,
    string Status,
    DateTime? OpenDate,
    DateTime? CloseDate,
    DateTime? ListingDate,
    DateTime? AllotmentDate,
    DateTime? RefundDate,
    DateTime? DematCreditDate,
    decimal? LowerPrice,
    decimal? UpperPrice,
    int? LotSize,
    decimal? MinimumInvestment,
    decimal? IssueSize,
    decimal? FaceValue,
    decimal? FreshIssueAmount,
    decimal? OfferForSaleAmount,
    long? TotalShares,
    string? ListingExchange,
    string? RegistrarName,
    string? LeadManagers,
    string? Industry,
    string? BusinessDescription,
    string? BusinessModel,
    string? Promoters,
    string? CompanyWebsite,
    string? ObjectsOfIssue,
    decimal? RetailPortionPercent,
    decimal? QibPortionPercent,
    decimal? NiiPortionPercent,
    decimal? AnchorPortionPercent,
    decimal? GmpValue,
    string? GmpProvider,
    DateTime? GmpLastUpdated,
    string? OfficialNseUrl,
    string? OfficialBseUrl,
    string? OfficialAllotmentUrl,
    string? SourceName,
    DateTime LastUpdatedAt,
    IpoSubscriptionDto? Subscription,
    List<IpoFinancialDto> Financials,
    List<IpoDocumentDto> Documents
);
