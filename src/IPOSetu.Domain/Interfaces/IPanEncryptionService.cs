namespace IPOSetu.Domain.Interfaces;

public interface IPanEncryptionService
{
    string Encrypt(string plainPan);
    string Decrypt(string cipherText);
    string Mask(string plainPan);
    bool IsValidFormat(string pan);
}
