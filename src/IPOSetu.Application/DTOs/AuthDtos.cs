namespace IPOSetu.Application.DTOs;

public record SyncUserRequest(string FirebaseToken);

public record SyncUserResponse(
    Guid UserId,
    string FirebaseUid,
    string MobileNumber,
    DateTime CreatedAt
);
