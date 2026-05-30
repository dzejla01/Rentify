using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Rentify.Services.Database
{
    public class RentifyDbContextFactory : IDesignTimeDbContextFactory<RentifyDbContext>
    {
        public RentifyDbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<RentifyDbContext>();
            optionsBuilder.UseNpgsql(GetConnectionString());

            return new RentifyDbContext(optionsBuilder.Options);
        }

        private static string GetConnectionString()
        {
            LoadDotEnv();

            var connectionString =
                //Environment.GetEnvironmentVariable("CONNECTION_STRING_LOCAL"); //??
                Environment.GetEnvironmentVariable("CONNECTION_STRING_DOCKER");

            if (string.IsNullOrWhiteSpace(connectionString))
                throw new InvalidOperationException("Missing env var: CONNECTION_STRING_DOCKER or CONNECTION_STRING_LOCAL");

            return connectionString;
        }

        private static void LoadDotEnv()
        {
            var directory = new DirectoryInfo(Directory.GetCurrentDirectory());

            while (directory != null)
            {
                var envPath = Path.Combine(directory.FullName, ".env");
                if (File.Exists(envPath))
                {
                    foreach (var line in File.ReadAllLines(envPath))
                    {
                        var trimmed = line.Trim();
                        if (string.IsNullOrWhiteSpace(trimmed) || trimmed.StartsWith("#"))
                            continue;

                        var separatorIndex = trimmed.IndexOf('=');
                        if (separatorIndex <= 0)
                            continue;

                        var key = trimmed[..separatorIndex].Trim();
                        var value = trimmed[(separatorIndex + 1)..].Trim().Trim('"');

                        if (string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(key)))
                            Environment.SetEnvironmentVariable(key, value);
                    }

                    return;
                }

                directory = directory.Parent;
            }
        }
    }
}
