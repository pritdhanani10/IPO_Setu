using IPOSetu.Application.DTOs;

namespace IPOSetu.Application.Interfaces;

public interface IAuthService
{
    Task<SyncUserResponse> SyncFirebaseUserAsync(string firebaseIdToken, CancellationToken cancellationToken = default);
}

public interface IFirebaseAuthService
{
    Task<(string FirebaseUid, string MobileNumber)> VerifyTokenAsync(string idToken, CancellationToken cancellationToken = default);
}
