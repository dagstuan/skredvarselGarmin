using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Database;

public class SkredvarselDbContext : DbContext
{
    public SkredvarselDbContext(DbContextOptions options) : base(options)
    {
    }

    public virtual DbSet<User> Users => Set<User>();
    public virtual DbSet<Agreement> Agreements => Set<Agreement>();
    public virtual DbSet<Watch> Watches => Set<Watch>();
    public virtual DbSet<WatchAddRequest> WatchAddRequests => Set<WatchAddRequest>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Agreement>()
            .HasOne(a => a.User)
            .WithMany(u => u.Agreements)
            .HasForeignKey(a => a.UserId);

        modelBuilder.Entity<Watch>()
            .HasOne(a => a.User)
            .WithMany(u => u.Watches)
            .HasForeignKey(a => a.UserId);
    }
}
