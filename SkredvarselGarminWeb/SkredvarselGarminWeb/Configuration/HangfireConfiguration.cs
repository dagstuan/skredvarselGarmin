using Hangfire;
using Hangfire.PostgreSql;

using Npgsql;

using SkredvarselGarminWeb.Options;

namespace SkredvarselGarminWeb.Configuration;

public static class HangfireConfiguration
{
    public static void ConfigureHangfireServices(this IServiceCollection serviceCollection, DatabaseOptions databaseOptions)
    {
        var connectionStringBuilder = new NpgsqlConnectionStringBuilder
        {
            Host = databaseOptions.Host,
            Port = databaseOptions.Port,
            Username = databaseOptions.Username,
            Password = databaseOptions.Password,
            Database = databaseOptions.HangfireDatabase
        };

        serviceCollection.AddHangfire(configuration => configuration
            .SetDataCompatibilityLevel(CompatibilityLevel.Version_170)
            .UseSimpleAssemblyNameTypeSerializer()
            .UseRecommendedSerializerSettings()
            .UsePostgreSqlStorage(options =>
            {
                options.UseNpgsqlConnection(connectionStringBuilder.ToString());
            }));

        serviceCollection.AddHangfireServer();
    }

    public static void MapHangfireDashboard(this IEndpointRouteBuilder app)
    {
        app.MapHangfireDashboardWithAuthorizationPolicy("Admin");
    }
}
