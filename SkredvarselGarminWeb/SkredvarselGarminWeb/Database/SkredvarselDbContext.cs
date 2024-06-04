using Microsoft.EntityFrameworkCore;

using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Database;

public class SkredvarselDbContext(DbContextOptions options) : DbContext(options)
{
    public virtual DbSet<User> Users => Set<User>();
    public virtual DbSet<Agreement> Agreements => Set<Agreement>();
    public virtual DbSet<Watch> Watches => Set<Watch>();
    public virtual DbSet<WatchAddRequest> WatchAddRequests => Set<WatchAddRequest>();
    public virtual DbSet<StripeSubscription> StripeSubscriptions => Set<StripeSubscription>();
    public virtual DbSet<ForecastArea> ForecastAreas => Set<ForecastArea>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("postgis");

        modelBuilder.Entity<User>()
            .HasIndex(x => x.StripeCustomerId)
            .IsUnique()
            .AreNullsDistinct(true);

        modelBuilder.Entity<Agreement>()
            .HasOne(a => a.User)
            .WithMany(u => u.Agreements)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Watch>()
            .HasOne(a => a.User)
            .WithMany(u => u.Watches)
            .HasForeignKey(a => a.UserId);

        modelBuilder.Entity<StripeSubscription>()
            .HasOne(ss => ss.User)
            .WithMany(u => u.StripeSubscriptions)
            .HasForeignKey(ss => ss.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
