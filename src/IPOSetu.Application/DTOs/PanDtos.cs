namespace IPOSetu.Application.DTOs;

public record CreatePanRequest(string Pan, string? Label);
public record UpdatePanRequest(string? Label);

public record SavedPanDto(
    Guid Id,
    string MaskedPan,
    string? Label,
    DateTime CreatedAt
);
