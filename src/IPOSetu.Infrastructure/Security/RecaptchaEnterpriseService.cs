using Google.Api.Gax.ResourceNames;
using Google.Cloud.RecaptchaEnterprise.V1;
using IPOSetu.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace IPOSetu.Infrastructure.Security;

public class RecaptchaEnterpriseService : IRecaptchaService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<RecaptchaEnterpriseService> _logger;
    private readonly string _projectId;
    private readonly string _siteKey;

    public RecaptchaEnterpriseService(IConfiguration configuration, ILogger<RecaptchaEnterpriseService> logger)
    {
        _configuration = configuration;
        _logger = logger;
        _projectId = configuration["Recaptcha:ProjectId"] ?? "iposetu";
        _siteKey = configuration["Recaptcha:SiteKey"] ?? "6LddVqwtAAAAADqwYMvJEGCrUi5zQ4GqxDeFKRB5";
    }

    public async Task<RecaptchaAssessmentResult> CreateAssessmentAsync(
        string token,
        string expectedAction = "LOGIN",
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return new RecaptchaAssessmentResult { IsValid = false, Reason = "Empty token" };
        }

        try
        {
            var client = await RecaptchaEnterpriseServiceClient.CreateAsync(cancellationToken);
            var projectName = new ProjectName(_projectId);

            var createAssessmentRequest = new CreateAssessmentRequest
            {
                Assessment = new Assessment
                {
                    Event = new Event
                    {
                        SiteKey = _siteKey,
                        Token = token,
                        ExpectedAction = expectedAction
                    }
                },
                ParentAsProjectName = projectName
            };

            var response = await client.CreateAssessmentAsync(createAssessmentRequest);

            if (response.TokenProperties.Valid == false)
            {
                _logger.LogWarning("reCAPTCHA assessment failed: {Reason}", response.TokenProperties.InvalidReason);
                return new RecaptchaAssessmentResult
                {
                    IsValid = false,
                    Reason = response.TokenProperties.InvalidReason.ToString()
                };
            }

            if (response.TokenProperties.Action != expectedAction)
            {
                _logger.LogWarning("reCAPTCHA action mismatch. Expected: {Expected}, Actual: {Actual}",
                    expectedAction, response.TokenProperties.Action);
                return new RecaptchaAssessmentResult
                {
                    IsValid = false,
                    Reason = "Action mismatch"
                };
            }

            var score = (float)response.RiskAnalysis.Score;
            _logger.LogInformation("reCAPTCHA assessment successful with risk score: {Score}", score);

            return new RecaptchaAssessmentResult
            {
                IsValid = true,
                Score = score,
                Action = response.TokenProperties.Action
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error executing reCAPTCHA enterprise assessment.");
            return new RecaptchaAssessmentResult
            {
                IsValid = false,
                Reason = ex.Message
            };
        }
    }
}
