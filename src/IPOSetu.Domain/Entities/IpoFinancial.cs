namespace IPOSetu.Domain.Entities;

public class IpoFinancial
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid IpoId { get; set; }
    public string Period { get; set; } = string.Empty; // e.g. "FY23", "FY24"
    public decimal? Revenue { get; set; }             // in Crores
    public decimal? Ebitda { get; set; }              // in Crores
    public decimal? ProfitAfterTax { get; set; }      // in Crores
    public decimal? NetWorth { get; set; }            // in Crores
    public decimal? TotalAssets { get; set; }         // in Crores
    public decimal? Borrowings { get; set; }          // in Crores
    public decimal? Eps { get; set; }

    public Ipo? Ipo { get; set; }
}
