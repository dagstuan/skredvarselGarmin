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
            SslMode = SslMode.Prefer,
            TrustServerCertificate = true,
            Database = "postgres"
        };

        var dataSource = new NpgsqlDataSourceBuilder(connectionStringBuilder.ToString()).Build();
        var getCmd = dataSource.CreateCommand("SELECT 1 FROM pg_database WHERE datname = 'hangfire'");
        var res = getCmd.ExecuteReader();
        var databaseExists = res.HasRows;

        if (!databaseExists)
        {
            var cmd = dataSource.CreateCommand("CREATE DATABASE hangfire");
            cmd.ExecuteNonQuery();
        }

        connectionStringBuilder.Database = "hangfire";

        serviceCollection.AddHangfire(configuration => configuration
            .SetDataCompatibilityLevel(CompatibilityLevel.Version_170)
            .UseSimpleAssemblyNameTypeSerializer()
            .UseRecommendedSerializerSettings()
            .UsePostgreSqlStorage(connectionStringBuilder.ToString()));

        serviceCollection.AddHangfireServer();
    }
}
