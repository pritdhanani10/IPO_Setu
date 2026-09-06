namespace IPOSetu.Application.Interfaces;

public class RecaptchaAssessmentResult
{
    public bool IsValid { get; set; }
    public float Score { get; set; }
    public string? Action { get; set; }
    public string? Reason { get; set; }
}

public interface IRecaptchaService
{
    Task<RecaptchaAssessmentResult> CreateAssessmentAsync(
        string token,
        string expectedAction = "LOGIN",
        CancellationToken cancellationToken = default);
}
