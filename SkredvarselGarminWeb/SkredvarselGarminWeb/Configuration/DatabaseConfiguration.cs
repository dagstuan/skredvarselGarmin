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

        var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionStringBuilder.ToString());
        dataSourceBuilder.UseNetTopologySuite();
        var dataSource = dataSourceBuilder.Build();

        serviceCollection.AddDbContext<SkredvarselDbContext>(options =>
            options.UseNpgsql(dataSource, o =>
                    o.UseQuerySplittingBehavior(QuerySplittingBehavior.SingleQuery)
                     .UseNetTopologySuite())
                .UseSnakeCaseNamingConvention());
    }
}
