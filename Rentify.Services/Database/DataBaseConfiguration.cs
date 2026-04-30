using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace eTravelAgencija.Services.Database
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
            var connectionString =
                Environment.GetEnvironmentVariable("CONNECTION_STRING_DOCKER") ??
                Environment.GetEnvironmentVariable("CONNECTION_STRING_LOCAL");

            if (string.IsNullOrWhiteSpace(connectionString))
                throw new InvalidOperationException("Missing env var: CONNECTION_STRING_DOCKER or CONNECTION_STRING_LOCAL");

            return connectionString;
        }
    }
}
