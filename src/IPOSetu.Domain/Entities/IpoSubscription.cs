namespace IPOSetu.Domain.Entities;

public class IpoSubscription
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid IpoId { get; set; }
    public decimal? RetailSubscription { get; set; }
    public decimal? QibSubscription { get; set; }
    public decimal? NiiSubscription { get; set; }
    public decimal? TotalSubscription { get; set; }
    public DateTime AsOfDate { get; set; } = DateTime.UtcNow;

    public Ipo? Ipo { get; set; }
}
