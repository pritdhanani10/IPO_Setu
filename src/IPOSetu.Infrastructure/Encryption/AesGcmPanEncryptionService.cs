using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using IPOSetu.Domain.Interfaces;
using Microsoft.Extensions.Configuration;

namespace IPOSetu.Infrastructure.Encryption;

public class AesGcmPanEncryptionService : IPanEncryptionService
{
    private static readonly Regex PanRegex = new(@"^[A-Z]{5}[0-9]{4}[A-Z]{1}$", RegexOptions.Compiled);
    private readonly byte[] _key;

    public AesGcmPanEncryptionService(IConfiguration configuration)
    {
        var secret = configuration["Security:PanEncryptionKey"]
            ?? Environment.GetEnvironmentVariable("PAN_ENCRYPTION_KEY")
            ?? "IPOSetuSecretKey2026MasterKeyAES256GCM32Bytes!"; // 32 chars fallback for dev

        // Ensure key is 32 bytes (256 bits)
        _key = SHA256.HashData(Encoding.UTF8.GetBytes(secret));
    }

    public string Encrypt(string plainPan)
    {
        var normalized = plainPan.Trim().ToUpperInvariant();
        if (!IsValidFormat(normalized))
        {
            throw new ArgumentException("Invalid PAN format.", nameof(plainPan));
        }

        var plaintextBytes = Encoding.UTF8.GetBytes(normalized);
        var nonce = new byte[AesGcm.NonceByteSizes.MaxSize]; // 12 bytes
        RandomNumberGenerator.Fill(nonce);

        var ciphertext = new byte[plaintextBytes.Length];
        var tag = new byte[AesGcm.TagByteSizes.MaxSize]; // 16 bytes

        using var aesGcm = new AesGcm(_key, AesGcm.TagByteSizes.MaxSize);
        aesGcm.Encrypt(nonce, plaintextBytes, ciphertext, tag);

        // Format: Base64(nonce) : Base64(tag) : Base64(ciphertext)
        return $"{Convert.ToBase64String(nonce)}:{Convert.ToBase64String(tag)}:{Convert.ToBase64String(ciphertext)}";
    }

    public string Decrypt(string cipherText)
    {
        var parts = cipherText.Split(':');
        if (parts.Length != 3)
        {
            throw new FormatException("Invalid encrypted payload format.");
        }

        var nonce = Convert.FromBase64String(parts[0]);
        var tag = Convert.FromBase64String(parts[1]);
        var ciphertext = Convert.FromBase64String(parts[2]);

        var decryptedBytes = new byte[ciphertext.Length];
        using var aesGcm = new AesGcm(_key, AesGcm.TagByteSizes.MaxSize);
        aesGcm.Decrypt(nonce, ciphertext, tag, decryptedBytes);

        return Encoding.UTF8.GetString(decryptedBytes);
    }

    public string Mask(string plainPan)
    {
        var normalized = plainPan.Trim().ToUpperInvariant();
        if (normalized.Length != 10) return "**********";

        // ABCDE****F
        return $"{normalized[..5]}****{normalized[^1]}";
    }

    public bool IsValidFormat(string pan)
    {
        if (string.IsNullOrWhiteSpace(pan)) return false;
        return PanRegex.IsMatch(pan.Trim().ToUpperInvariant());
    }
}
