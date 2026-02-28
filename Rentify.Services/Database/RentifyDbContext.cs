using Microsoft.EntityFrameworkCore;
using Rentify.Services.Database;

public class RentifyDbContext : DbContext
{
    public RentifyDbContext(DbContextOptions<RentifyDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<UserRole> UserRoles { get; set; }
    public DbSet<Role> Roles { get; set; }
    public DbSet<Appointment> Appointments { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<Property> Properties { get; set; }
    public DbSet<PropertyImage> PropertiesImage { get; set; }
    public DbSet<Reservation> Reservations { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<UserDeviceToken> UserDeviceTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<UserRole>()
            .HasKey(x => new { x.UserId, x.RoleId });

        modelBuilder.Entity<UserDeviceToken>()
    .HasIndex(x => x.Token)
    .IsUnique();

        modelBuilder.Entity<UserDeviceToken>()
            .HasIndex(x => new { x.UserId, x.IsActive });

        SeedData.Seed(modelBuilder);

    }
}
