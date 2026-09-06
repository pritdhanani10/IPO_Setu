namespace IPOSetu.Domain.Entities;

public class SavedPan
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string EncryptedPan { get; set; } = string.Empty;
    public string MaskedPan { get; set; } = string.Empty;
    public string? Label { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public User? User { get; set; }
}
