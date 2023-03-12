using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Database;

public class SkredvarselDbContext : DbContext
{
    public SkredvarselDbContext(DbContextOptions options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Agreement> Agreements => Set<Agreement>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .HasOne(u => u.Agreement)
            .WithOne(a => a.User)
            .HasForeignKey<Agreement>(a => a.UserId);
    }
}
