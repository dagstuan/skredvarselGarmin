using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Database;

public class SkredvarselDbContext : DbContext
{
    public SkredvarselDbContext(DbContextOptions options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
}
