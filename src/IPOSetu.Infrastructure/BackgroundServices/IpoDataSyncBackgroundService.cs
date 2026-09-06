using IPOSetu.Domain.Entities;
using IPOSetu.Domain.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace IPOSetu.Infrastructure.BackgroundServices;

public class IpoDataSyncBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<IpoDataSyncBackgroundService> _logger;
    private readonly TimeSpan _syncInterval = TimeSpan.FromMinutes(30);

    public IpoDataSyncBackgroundService(
        IServiceProvider serviceProvider,
        ILogger<IpoDataSyncBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("IPO Data Sync Background Service started.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await SyncDataAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred during IPO data sync.");
            }

            try
            {
                await Task.Delay(_syncInterval, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }

        _logger.LogInformation("IPO Data Sync Background Service stopped.");
    }

    private async Task SyncDataAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var ipoRepository = scope.ServiceProvider.GetRequiredService<IIpoRepository>();
        var dataProvider = scope.ServiceProvider.GetRequiredService<IIpoDataProvider>();

        _logger.LogInformation("Starting scheduled IPO data synchronization from {Provider}...", dataProvider.ProviderName);

        var syncLog = new DataSyncLog
        {
            ProviderName = dataProvider.ProviderName,
            SyncedAt = DateTime.UtcNow
        };

        try
        {
            var ipos = await dataProvider.FetchIposAsync(cancellationToken);
            int count = 0;

            foreach (var ipo in ipos)
            {
                await ipoRepository.UpsertAsync(ipo, cancellationToken);
                count++;

                var sub = await dataProvider.FetchSubscriptionAsync(ipo.Symbol, cancellationToken);
                if (sub != null)
                {
                    sub.IpoId = ipo.Id;
                    await ipoRepository.UpsertSubscriptionAsync(sub, cancellationToken);
                }

                var financials = await dataProvider.FetchFinancialsAsync(ipo.Symbol, cancellationToken);
                var finList = financials.ToList();
                if (finList.Any())
                {
                    finList.ForEach(f => f.IpoId = ipo.Id);
                    await ipoRepository.UpsertFinancialsAsync(finList, cancellationToken);
                }

                var documents = await dataProvider.FetchDocumentsAsync(ipo.Symbol, cancellationToken);
                var docList = documents.ToList();
                if (docList.Any())
                {
                    docList.ForEach(d => d.IpoId = ipo.Id);
                    await ipoRepository.UpsertDocumentsAsync(docList, cancellationToken);
                }
            }

            syncLog.Status = "Success";
            syncLog.RecordsUpdated = count;
            _logger.LogInformation("IPO data sync completed successfully. {Count} records updated.", count);
        }
        catch (Exception ex)
        {
            syncLog.Status = "Failed";
            syncLog.ErrorMessage = ex.Message;
            _logger.LogError(ex, "IPO data sync failed.");
        }
        finally
        {
            await ipoRepository.LogSyncAsync(syncLog, cancellationToken);
        }
    }
}
