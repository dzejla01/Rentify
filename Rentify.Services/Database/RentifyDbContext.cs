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
    public DbSet<Question> Questions { get; set; }
    public DbSet<Answer> Answers { get; set; }
    public DbSet<ReservationHistory> ReservationHistories { get; set; }
    public DbSet<AppointmentHistory> AppointmentHistories { get; set; }
    public DbSet<Favorite> Favorites { get; set; }
    public DbSet<City> Cities { get; set; }
    public DbSet<Status> Statuses { get; set; }
    public DbSet<BuildingType> BuildingTypes { get; set; }
    public DbSet<AppNotification> AppNotifications { get; set; }
    public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }
    public DbSet<Expense> Expenses { get; set; }

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

        modelBuilder.Entity<AppNotification>()
            .HasIndex(x => new { x.UserId, x.IsRead, x.CreatedAt });

        modelBuilder.Entity<PasswordResetToken>()
            .HasIndex(x => new { x.UserId, x.TokenHash, x.UsedAt });

        modelBuilder.Entity<Question>()
            .HasOne(q => q.User)
            .WithMany()
            .HasForeignKey(q => q.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Question>()
            .HasOne(q => q.Property)
            .WithMany()
            .HasForeignKey(q => q.PropertyId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Question>()
            .HasOne(q => q.Answer)
            .WithOne(a => a.Question)
            .HasForeignKey<Answer>(a => a.QuestionId);

        modelBuilder.Entity<Answer>()
            .HasOne(a => a.User)
            .WithMany()
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<ReservationHistory>()
            .HasOne(rh => rh.Reservation)
            .WithMany()
            .HasForeignKey(rh => rh.ReservationId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ReservationHistory>()
            .HasOne(rh => rh.Status)
            .WithMany()
            .HasForeignKey(rh => rh.StatusId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<AppointmentHistory>()
            .HasOne(ah => ah.Appointment)
            .WithMany()
            .HasForeignKey(ah => ah.AppointmentId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<AppointmentHistory>()
            .HasOne(ah => ah.Status)
            .WithMany()
            .HasForeignKey(ah => ah.StatusId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Favorite>()
            .HasOne(f => f.User)
            .WithMany()
            .HasForeignKey(f => f.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Favorite>()
            .HasOne(f => f.Property)
            .WithMany()
            .HasForeignKey(f => f.PropertyId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Favorite>()
            .HasIndex(f => new { f.UserId, f.PropertyId })
            .IsUnique();

        modelBuilder.Entity<Review>()
            .HasIndex(x => x.ReservationId)
            .IsUnique();

        modelBuilder.Entity<Property>()
            .HasOne(p => p.City)
            .WithMany()
            .HasForeignKey(p => p.CityId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Property>()
            .HasOne(p => p.BuildingType)
            .WithMany()
            .HasForeignKey(p => p.BuildingTypeId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Reservation>()
            .HasOne(r => r.Status)
            .WithMany()
            .HasForeignKey(r => r.StatusId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Appointment>()
            .HasOne(a => a.Status)
            .WithMany()
            .HasForeignKey(a => a.StatusId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Payment>()
            .HasOne(p => p.Status)
            .WithMany()
            .HasForeignKey(p => p.StatusId)
            .OnDelete(DeleteBehavior.Restrict);

        SeedData.Seed(modelBuilder);
    }
}
