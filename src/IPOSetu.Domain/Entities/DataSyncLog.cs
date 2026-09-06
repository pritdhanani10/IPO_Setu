namespace IPOSetu.Domain.Entities;

public class DataSyncLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string ProviderName { get; set; } = string.Empty;
    public string Status { get; set; } = "Success"; // Success | Failed | Partial
    public int RecordsUpdated { get; set; }
    public string? ErrorMessage { get; set; }
    public DateTime SyncedAt { get; set; } = DateTime.UtcNow;
}
