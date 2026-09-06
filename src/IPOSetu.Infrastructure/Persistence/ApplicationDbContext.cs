using IPOSetu.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace IPOSetu.Infrastructure.Persistence;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<SavedPan> SavedPans => Set<SavedPan>();
    public DbSet<Ipo> Ipos => Set<Ipo>();
    public DbSet<IpoSubscription> IpoSubscriptions => Set<IpoSubscription>();
    public DbSet<IpoFinancial> IpoFinancials => Set<IpoFinancial>();
    public DbSet<IpoDocument> IpoDocuments => Set<IpoDocument>();
    public DbSet<DataSyncLog> DataSyncLogs => Set<DataSyncLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(u => u.Id);
            entity.HasIndex(u => u.FirebaseUid).IsUnique();
            entity.Property(u => u.FirebaseUid).IsRequired().HasMaxLength(128);
            entity.Property(u => u.MobileNumber).IsRequired().HasMaxLength(20);
        });

        modelBuilder.Entity<SavedPan>(entity =>
        {
            entity.HasKey(p => p.Id);
            entity.HasIndex(p => new { p.UserId, p.MaskedPan }).IsUnique();
            entity.Property(p => p.EncryptedPan).IsRequired();
            entity.Property(p => p.MaskedPan).IsRequired().HasMaxLength(10);
            entity.Property(p => p.Label).HasMaxLength(50);

            entity.HasOne(p => p.User)
                  .WithMany(u => u.SavedPans)
                  .HasForeignKey(p => p.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Ipo>(entity =>
        {
            entity.HasKey(i => i.Id);
            entity.HasIndex(i => i.Symbol).IsUnique();
            entity.Property(i => i.Symbol).IsRequired().HasMaxLength(50);
            entity.Property(i => i.CompanyName).IsRequired().HasMaxLength(255);
            entity.Property(i => i.Category).IsRequired().HasMaxLength(20);
            entity.Property(i => i.Status).IsRequired().HasMaxLength(20);
            entity.Property(i => i.LowerPrice).HasPrecision(18, 2);
            entity.Property(i => i.UpperPrice).HasPrecision(18, 2);
            entity.Property(i => i.IssueSize).HasPrecision(18, 2);
            entity.Property(i => i.FaceValue).HasPrecision(18, 2);
            entity.Property(i => i.FreshIssueAmount).HasPrecision(18, 2);
            entity.Property(i => i.OfferForSaleAmount).HasPrecision(18, 2);
            entity.Property(i => i.GmpValue).HasPrecision(18, 2);
        });

        modelBuilder.Entity<IpoSubscription>(entity =>
        {
            entity.HasKey(s => s.Id);
            entity.HasOne(s => s.Ipo)
                  .WithMany(i => i.Subscriptions)
                  .HasForeignKey(s => s.IpoId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(s => s.RetailSubscription).HasPrecision(10, 2);
            entity.Property(s => s.QibSubscription).HasPrecision(10, 2);
            entity.Property(s => s.NiiSubscription).HasPrecision(10, 2);
            entity.Property(s => s.TotalSubscription).HasPrecision(10, 2);
        });

        modelBuilder.Entity<IpoFinancial>(entity =>
        {
            entity.HasKey(f => f.Id);
            entity.HasOne(f => f.Ipo)
                  .WithMany(i => i.Financials)
                  .HasForeignKey(f => f.IpoId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(f => f.Revenue).HasPrecision(18, 2);
            entity.Property(f => f.Ebitda).HasPrecision(18, 2);
            entity.Property(f => f.ProfitAfterTax).HasPrecision(18, 2);
            entity.Property(f => f.NetWorth).HasPrecision(18, 2);
            entity.Property(f => f.TotalAssets).HasPrecision(18, 2);
            entity.Property(f => f.Borrowings).HasPrecision(18, 2);
            entity.Property(f => f.Eps).HasPrecision(18, 2);
        });

        modelBuilder.Entity<IpoDocument>(entity =>
        {
            entity.HasKey(d => d.Id);
            entity.HasOne(d => d.Ipo)
                  .WithMany(i => i.Documents)
                  .HasForeignKey(d => d.IpoId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<DataSyncLog>(entity =>
        {
            entity.HasKey(l => l.Id);
            entity.Property(l => l.ProviderName).IsRequired().HasMaxLength(100);
            entity.Property(l => l.Status).IsRequired().HasMaxLength(20);
        });
    }
}
