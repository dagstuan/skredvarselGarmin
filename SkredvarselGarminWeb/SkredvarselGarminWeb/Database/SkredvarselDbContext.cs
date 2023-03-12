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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Agreement>()
            .HasOne(a => a.User)
            .WithMany(u => u.Agreement)
            .HasForeignKey(a => a.UserId);
    }
}
