namespace IPOSetu.Application.DTOs;

public record CheckAllotmentRequest(
    Guid IpoId,
    List<Guid> SelectedPanIds
);

public record PanAllotmentResultDto(
    string MaskedPan,
    string Status, // ALLOTTED | NOT_ALLOTTED | NOT_AVAILABLE
    int? Shares,
    decimal? Amount,
    string? Message
);

public record CheckAllotmentResponse(
    string CompanyName,
    bool OfficialCheckRequired,
    string? Message,
    string? OfficialStatusUrl,
    List<PanAllotmentResultDto> Results,
    int TotalPansChecked,
    int AllottedCount,
    int NotAllottedCount,
    int UnavailableCount
);
