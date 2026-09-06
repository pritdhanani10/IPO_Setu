namespace IPOSetu.Domain.Entities;

public class IpoDocument
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid IpoId { get; set; }
    public string Title { get; set; } = string.Empty; // e.g. "DRHP", "RHP", "Prospectus", "NSE Filing"
    public string DocumentType { get; set; } = "RHP"; // DRHP | RHP | Prospectus | Filing | Other
    public string OfficialUrl { get; set; } = string.Empty;
    public DateTime AddedAt { get; set; } = DateTime.UtcNow;

    public Ipo? Ipo { get; set; }
}
