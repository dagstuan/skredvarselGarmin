using Microsoft.EntityFrameworkCore;
using Npgsql;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Options;

namespace SkredvarselGarminWeb.Configuration;

public static class DatabaseConfiguration
{
    public static void ConfigureDatabase(this IServiceCollection serviceCollection, DatabaseOptions databaseOptions)
    {
        var connectionStringBuilder = new NpgsqlConnectionStringBuilder
        {
            Host = databaseOptions.Host,
            Port = databaseOptions.Port,
            Username = databaseOptions.Username,
            Password = databaseOptions.Password,
            Database = databaseOptions.Database,
        };

        serviceCollection.AddDbContext<SkredvarselDbContext>(options =>
            options.UseNpgsql(connectionStringBuilder.ToString())
                .UseSnakeCaseNamingConvention());
    }
}
