using IPOSetu.Application.DTOs;
using IPOSetu.Application.Interfaces;
using IPOSetu.Domain.Entities;
using IPOSetu.Domain.Interfaces;

namespace IPOSetu.Application.Services;

public class AuthService : IAuthService
{
    private readonly IFirebaseAuthService _firebaseAuthService;
    private readonly IUserRepository _userRepository;

    public AuthService(IFirebaseAuthService firebaseAuthService, IUserRepository userRepository)
    {
        _firebaseAuthService = firebaseAuthService;
        _userRepository = userRepository;
    }

    public async Task<SyncUserResponse> SyncFirebaseUserAsync(string firebaseIdToken, CancellationToken cancellationToken = default)
    {
        var (firebaseUid, mobileNumber) = await _firebaseAuthService.VerifyTokenAsync(firebaseIdToken, cancellationToken);

        var existingUser = await _userRepository.GetByFirebaseUidAsync(firebaseUid, cancellationToken);
        if (existingUser != null)
        {
            existingUser.MobileNumber = mobileNumber;
            existingUser.UpdatedAt = DateTime.UtcNow;
            await _userRepository.UpdateAsync(existingUser, cancellationToken);

            return new SyncUserResponse(existingUser.Id, existingUser.FirebaseUid, existingUser.MobileNumber, existingUser.CreatedAt);
        }

        var newUser = new User
        {
            FirebaseUid = firebaseUid,
            MobileNumber = mobileNumber,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var created = await _userRepository.CreateAsync(newUser, cancellationToken);
        return new SyncUserResponse(created.Id, created.FirebaseUid, created.MobileNumber, created.CreatedAt);
    }
}
