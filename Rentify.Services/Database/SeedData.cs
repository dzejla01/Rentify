// using Microsoft.EntityFrameworkCore;
// using Rentify.Services.Database;
// using Rentify.Services.Helpers;

// public static class SeedData
// {
//     private static string PropertyImageUrl(int propertyId, int index)
//         => $"https://picsum.photos/seed/property-{propertyId}-{index}/900/600";

//     public static void Seed(ModelBuilder modelBuilder)
//     {
//         UserHelper.CreatePasswordHash(
//            "Test123!",
//            out var hashBase64,
//            out var saltBase64
//         );

//         // ================= ROLES =================
//         modelBuilder.Entity<Role>().HasData(
//             new Role { Id = 1, Name = "Korisnik", Description = "Standardni korisnik aplikacije", IsActive = true, CreatedAt = DateTime.UtcNow },
//             new Role { Id = 2, Name = "Vlasnik", Description = "Vlasnik nekretnina", IsActive = true, CreatedAt = DateTime.UtcNow }
//         );

//         // ================= USERS =================
//         modelBuilder.Entity<User>().HasData(
//             new User { Id = 1, FirstName = "Marko", LastName = "Petrov", Email = "owner.testni@gmail.com", Username = "owner1", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = true, IsActive = true, IsLoggingFirstTime = false },
//             new User { Id = 2, FirstName = "Ivana", LastName = "Kovac", Email = "ivana.kovac@rentify.dev", Username = "user1", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
//             new User { Id = 3, FirstName = "Nikola", LastName = "Jovic", Email = "nikola.jovic@rentify.dev", Username = "owner2", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = true, IsActive = true, IsLoggingFirstTime = false },
//             new User { Id = 4, FirstName = "Amar", LastName = "Hodzic", Email = "amar.hodzic@rentify.dev", Username = "user2", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false }
//         );

//         modelBuilder.Entity<UserRole>().HasData(
//             new UserRole { UserId = 1, RoleId = 2 },
//             new UserRole { UserId = 2, RoleId = 1 },
//             new UserRole { UserId = 3, RoleId = 2 },
//             new UserRole { UserId = 4, RoleId = 1 }
//         );

//         // ================= PROPERTIES =================
//         modelBuilder.Entity<Property>().HasData(

//     // =========================
//     // SARAJEVO (8)
//     // =========================
//     new Property
//     {
//         Id = 1,
//         UserId = 1,
//         Name = "Central City Apartment",
//         City = "Sarajevo",
//         Location = "Zmaja od Bosne 12",
//         PricePerDay = 65,
//         PricePerMonth = 1550,
//         Tags = new() { "urban", "bright", "central", "modern" },
//         NumberOfsquares = "55",
//         Details = "Bright apartment in central Sarajevo.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 2,
//         UserId = 1,
//         Name = "Old Town Flat",
//         City = "Sarajevo",
//         Location = "Bistrik 7",
//         PricePerDay = 60,
//         PricePerMonth = 1450,
//         Tags = new() { "historic", "authentic", "warm" },
//         NumberOfsquares = "48",
//         Details = "Flat near the old town.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 3,
//         UserId = 3,
//         Name = "Hillside View Apartment",
//         City = "Sarajevo",
//         Location = "Alipašina 42",
//         PricePerDay = 70,
//         PricePerMonth = 1650,
//         Tags = new() { "view", "calm", "elevated" },
//         NumberOfsquares = "60",
//         Details = "Apartment with city views.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 4,
//         UserId = 1,
//         Name = "Modern Loft",
//         City = "Sarajevo",
//         Location = "Kolodvorska 18",
//         PricePerDay = 75,
//         PricePerMonth = 1800,
//         Tags = new() { "loft", "stylish", "open" },
//         NumberOfsquares = "62",
//         Details = "Modern loft style apartment.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 5,
//         UserId = 3,
//         Name = "Quiet Residential Flat",
//         City = "Sarajevo",
//         Location = "Grbavička 91",
//         PricePerDay = 55,
//         PricePerMonth = 1350,
//         Tags = new() { "quiet", "balanced", "comfortable" },
//         NumberOfsquares = "50",
//         Details = "Calm residential apartment.",
//         IsAvailable = false,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 6,
//         UserId = 1,
//         Name = "Sunny Apartment",
//         City = "Sarajevo",
//         Location = "Hamze Hume 5",
//         PricePerDay = 68,
//         PricePerMonth = 1600,
//         Tags = new() { "sunny", "warm", "airy" },
//         NumberOfsquares = "57",
//         Details = "Sunny apartment with open layout.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 7,
//         UserId = 3,
//         Name = "Compact Studio",
//         City = "Sarajevo",
//         Location = "Logavina 23",
//         PricePerDay = 45,
//         PricePerMonth = 1100,
//         Tags = new() { "compact", "simple", "efficient" },
//         NumberOfsquares = "32",
//         Details = "Compact studio apartment.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 8,
//         UserId = 1,
//         Name = "Panorama Residence",
//         City = "Sarajevo",
//         Location = "Skenderija 10",
//         PricePerDay = 80,
//         PricePerMonth = 1900,
//         Tags = new() { "panorama", "exclusive", "bright" },
//         NumberOfsquares = "70",
//         Details = "Residence with panoramic city view.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },

//     // =========================
//     // MOSTAR (7)
//     // =========================
//     new Property
//     {
//         Id = 9,
//         UserId = 3,
//         Name = "River Side Apartment",
//         City = "Mostar",
//         Location = "Maršala Tita 14",
//         PricePerDay = 70,
//         PricePerMonth = 1650,
//         Tags = new() { "river", "relaxing", "open" },
//         NumberOfsquares = "58",
//         Details = "Apartment near the river.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 10,
//         UserId = 1,
//         Name = "Old Bridge View Flat",
//         City = "Mostar",
//         Location = "Rade Bitange 3",
//         PricePerDay = 85,
//         PricePerMonth = 2000,
//         Tags = new() { "iconic", "view", "historic" },
//         NumberOfsquares = "65",
//         Details = "Flat with a view of the Old Bridge.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 11,
//         UserId = 3,
//         Name = "Stone House Apartment",
//         City = "Mostar",
//         Location = "Braće Fejića 27",
//         PricePerDay = 60,
//         PricePerMonth = 1450,
//         Tags = new() { "stone", "traditional", "cool" },
//         NumberOfsquares = "50",
//         Details = "Traditional stone apartment.",
//         IsAvailable = false,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 12,
//         UserId = 1,
//         Name = "Sunny Terrace Flat",
//         City = "Mostar",
//         Location = "Adema Buća 9",
//         PricePerDay = 75,
//         PricePerMonth = 1750,
//         Tags = new() { "sunny", "terrace", "open" },
//         NumberOfsquares = "60",
//         Details = "Apartment with sunny terrace.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 13,
//         UserId = 3,
//         Name = "Quiet Center Apartment",
//         City = "Mostar",
//         Location = "Kralja Tvrtka 6",
//         PricePerDay = 65,
//         PricePerMonth = 1550,
//         Tags = new() { "quiet", "central", "comfortable" },
//         NumberOfsquares = "54",
//         Details = "Quiet apartment in city center.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 14,
//         UserId = 1,
//         Name = "Minimal Flat",
//         City = "Mostar",
//         Location = "Splitska 22",
//         PricePerDay = 55,
//         PricePerMonth = 1300,
//         Tags = new() { "minimal", "clean", "simple" },
//         NumberOfsquares = "45",
//         Details = "Minimalist apartment.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 15,
//         UserId = 3,
//         Name = "Evening Light Apartment",
//         City = "Mostar",
//         Location = "Put Mladih Muslimana 4",
//         PricePerDay = 68,
//         PricePerMonth = 1600,
//         Tags = new() { "warm", "evening", "relaxed" },
//         NumberOfsquares = "56",
//         Details = "Warm and relaxed living space.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },

//     // =========================
//     // TUZLA (7)
//     // =========================
//     new Property
//     {
//         Id = 16,
//         UserId = 1,
//         Name = "City Center Apartment",
//         City = "Tuzla",
//         Location = "Slatina 15",
//         PricePerDay = 50,
//         PricePerMonth = 1200,
//         Tags = new() { "central", "balanced", "urban" },
//         NumberOfsquares = "48",
//         Details = "Apartment in city center.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 17,
//         UserId = 3,
//         Name = "Salt Lake View Flat",
//         City = "Tuzla",
//         Location = "Turalibegova 8",
//         PricePerDay = 65,
//         PricePerMonth = 1500,
//         Tags = new() { "lake", "fresh", "open" },
//         NumberOfsquares = "55",
//         Details = "Flat near salt lakes.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 18,
//         UserId = 1,
//         Name = "Quiet Residential Studio",
//         City = "Tuzla",
//         Location = "Batva 21",
//         PricePerDay = 40,
//         PricePerMonth = 950,
//         Tags = new() { "quiet", "compact", "simple" },
//         NumberOfsquares = "30",
//         Details = "Studio in a quiet area.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 19,
//         UserId = 3,
//         Name = "Modern Flat",
//         City = "Tuzla",
//         Location = "Krečka 33",
//         PricePerDay = 55,
//         PricePerMonth = 1300,
//         Tags = new() { "modern", "clean", "bright" },
//         NumberOfsquares = "50",
//         Details = "Modern city flat.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 20,
//         UserId = 1,
//         Name = "Family Apartment",
//         City = "Tuzla",
//         Location = "Brčanska Malta 12",
//         PricePerDay = 60,
//         PricePerMonth = 1400,
//         Tags = new() { "family", "comfortable", "spacious" },
//         NumberOfsquares = "62",
//         Details = "Spacious apartment for families.",
//         IsAvailable = false,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 21,
//         UserId = 3,
//         Name = "Sunlit Flat",
//         City = "Tuzla",
//         Location = "Stupine A2",
//         PricePerDay = 58,
//         PricePerMonth = 1350,
//         Tags = new() { "sunny", "open", "warm" },
//         NumberOfsquares = "53",
//         Details = "Flat with great sunlight.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 22,
//         UserId = 1,
//         Name = "Calm Living Space",
//         City = "Tuzla",
//         Location = "Irac 6",
//         PricePerDay = 52,
//         PricePerMonth = 1250,
//         Tags = new() { "calm", "balanced", "quiet" },
//         NumberOfsquares = "49",
//         Details = "Calm and balanced apartment.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },

//     // =========================
//     // BANJA LUKA (8)
//     // =========================
//     new Property
//     {
//         Id = 23,
//         UserId = 3,
//         Name = "City Loft",
//         City = "Banja Luka",
//         Location = "Kralja Petra I Karađorđevića 19",
//         PricePerDay = 70,
//         PricePerMonth = 1650,
//         Tags = new() { "loft", "urban", "creative" },
//         NumberOfsquares = "60",
//         Details = "Urban loft in city center.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 24,
//         UserId = 1,
//         Name = "River Walk Apartment",
//         City = "Banja Luka",
//         Location = "Obala Stepe Stepanovića 7",
//         PricePerDay = 75,
//         PricePerMonth = 1750,
//         Tags = new() { "river", "walkable", "fresh" },
//         NumberOfsquares = "58",
//         Details = "Apartment near river walk.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 25,
//         UserId = 3,
//         Name = "Minimal Residence",
//         City = "Banja Luka",
//         Location = "Cara Dušana 41",
//         PricePerDay = 55,
//         PricePerMonth = 1300,
//         Tags = new() { "minimal", "clean", "simple" },
//         NumberOfsquares = "47",
//         Details = "Minimalist residence.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 26,
//         UserId = 1,
//         Name = "Family City Home",
//         City = "Banja Luka",
//         Location = "Bulevar Vojvode Stepe 88",
//         PricePerDay = 65,
//         PricePerMonth = 1550,
//         Tags = new() { "family", "balanced", "comfortable" },
//         NumberOfsquares = "64",
//         Details = "Family-friendly city home.",
//         IsAvailable = false,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 27,
//         UserId = 3,
//         Name = "Bright Studio",
//         City = "Banja Luka",
//         Location = "Gundulićeva 10",
//         PricePerDay = 45,
//         PricePerMonth = 1050,
//         Tags = new() { "bright", "compact", "efficient" },
//         NumberOfsquares = "33",
//         Details = "Bright compact studio.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 28,
//         UserId = 1,
//         Name = "Panorama Flat",
//         City = "Banja Luka",
//         Location = "Kninska 25",
//         PricePerDay = 78,
//         PricePerMonth = 1850,
//         Tags = new() { "panorama", "open", "elevated" },
//         NumberOfsquares = "68",
//         Details = "Flat with panoramic view.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 29,
//         UserId = 3,
//         Name = "Quiet Corner Apartment",
//         City = "Banja Luka",
//         Location = "Solunska 3",
//         PricePerDay = 50,
//         PricePerMonth = 1200,
//         Tags = new() { "quiet", "corner", "calm" },
//         NumberOfsquares = "46",
//         Details = "Quiet corner apartment.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     },
//     new Property
//     {
//         Id = 30,
//         UserId = 1,
//         Name = "Elegant City Flat",
//         City = "Banja Luka",
//         Location = "Vase Pelagića 17",
//         PricePerDay = 72,
//         PricePerMonth = 1700,
//         Tags = new() { "elegant", "stylish", "urban" },
//         NumberOfsquares = "61",
//         Details = "Elegant flat in urban area.",
//         IsAvailable = true,
//         IsRentingPerDay = true,
//         IsActiveOnApp = true
//     }
// );

//         // ================= RESERVATIONS =================
//         modelBuilder.Entity<Reservation>().HasData(
//             new Reservation { Id = 1, UserId = 2, PropertyId = 1, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
//             new Reservation { Id = 2, UserId = 4, PropertyId = 2, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc) },
//             new Reservation { Id = 3, UserId = 2, PropertyId = 4, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 3, 0, 0, 0, DateTimeKind.Utc) },
//             new Reservation { Id = 4, UserId = 4, PropertyId = 6, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 4, 0, 0, 0, DateTimeKind.Utc) },

//             new Reservation { Id = 5, UserId = 2, PropertyId = 8, IsMonthly = false, StartDateOfRenting = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc), EndDateOfRenting = new DateTime(2026, 3, 5, 0, 0, 0, DateTimeKind.Utc), IsApproved = true, CreatedAt = new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc) }
//         );

//         // ================= PAYMENTS =================
//         modelBuilder.Entity<Payment>().HasData(
//             new Payment { Id = 1, UserId = 2, PropertyId = 1, Name = "Mjesečna rata 12.2025", Price = 1550, Comment = "", IsPayed = true, MonthNumber = 12, YearNumber = 2025 },
//             new Payment { Id = 2, UserId = 2, PropertyId = 1, Name = "Mjesečna rata 01.2026", Price = 1550, Comment = "", IsPayed = true, MonthNumber = 1, YearNumber = 2026 },
//             new Payment { Id = 3, UserId = 2, PropertyId = 1, Name = "Mjesečna rata 02.2026", Price = 1550, Comment = "", IsPayed = true, MonthNumber = 2, YearNumber = 2026 },
//             new Payment { Id = 4, UserId = 2, PropertyId = 8, Name = "Kratki boravak 03.2026", Price = 400, Comment = "", IsPayed = true, MonthNumber = 3, YearNumber = 2026 }
//         );

//         // ================= APPOINTMENTS (Samo available) =================
//         modelBuilder.Entity<Appointment>().HasData(
//             new Appointment { Id = 1, UserId = 2, PropertyId = 8, DateAppointment = new DateTime(2026, 3, 8, 11, 0, 0, DateTimeKind.Utc), IsApproved = true },
//             new Appointment { Id = 2, UserId = 4, PropertyId = 10, DateAppointment = new DateTime(2026, 3, 11, 9, 30, 0, DateTimeKind.Utc), IsApproved = null },
//             new Appointment { Id = 3, UserId = 2, PropertyId = 12, DateAppointment = new DateTime(2026, 3, 12, 13, 0, 0, DateTimeKind.Utc), IsApproved = true }
//         );
//     }
// }

using Microsoft.EntityFrameworkCore;
using Rentify.Services.Database;
using Rentify.Services.Helpers;

public static class SeedData
{
    private static string PropertyImageUrl(int propertyId, int index)
        => $"https://picsum.photos/seed/property-{propertyId}-{index}/900/600";

    public static void Seed(ModelBuilder modelBuilder)
    {
        UserHelper.CreatePasswordHash(
           "Test123!",
           out var hashBase64,
           out var saltBase64
        );

        var fixedCreatedAt = new DateTime(2025, 12, 1, 0, 0, 0, DateTimeKind.Utc);

        // ================= ROLES =================
        modelBuilder.Entity<Role>().HasData(
            new Role
            {
                Id = 1,
                Name = "Korisnik",
                Description = "Standardni korisnik aplikacije",
                IsActive = true,
                CreatedAt = fixedCreatedAt
            },
            new Role
            {
                Id = 2,
                Name = "Vlasnik",
                Description = "Vlasnik nekretnina",
                IsActive = true,
                CreatedAt = fixedCreatedAt
            }
        );

        // ================= USERS =================
        // Owners: 1 (Marko), 3 (Nikola)
        // Renters: 2,4,5,6,7,8,9,10  (Ivana može ostati ali više NIJE “glavni lik”)
        modelBuilder.Entity<User>().HasData(
            new User { Id = 1, FirstName = "Marko", LastName = "Petrov", Email = "owner.testni@gmail.com", Username = "owner1", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = true, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 3, FirstName = "Nikola", LastName = "Jovic", Email = "nikola.jovic@rentify.dev", Username = "owner2", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = true, IsActive = true, IsLoggingFirstTime = false },

            // Renters
            new User { Id = 2, FirstName = "Ivana", LastName = "Kovac", Email = "ivana.kovac@rentify.dev", Username = "user1", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 4, FirstName = "Amar", LastName = "Hodzic", Email = "amar.hodzic@rentify.dev", Username = "user2", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 5, FirstName = "Lejla", LastName = "Mehic", Email = "lejla.mehic@rentify.dev", Username = "user3", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 6, FirstName = "Haris", LastName = "Begic", Email = "haris.begic@rentify.dev", Username = "user4", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 7, FirstName = "Selma", LastName = "Kurtovic", Email = "selma.kurtovic@rentify.dev", Username = "user5", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 8, FirstName = "Adnan", LastName = "Delic", Email = "adnan.delic@rentify.dev", Username = "user6", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 9, FirstName = "Emina", LastName = "Zahiragic", Email = "emina.zahiragic@rentify.dev", Username = "user7", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false },
            new User { Id = 10, FirstName = "Nermin", LastName = "Basic", Email = "nermin.basic@rentify.dev", Username = "user8", PasswordHash = hashBase64, PasswordSalt = saltBase64, IsVlasnik = false, IsActive = true, IsLoggingFirstTime = false }
        );

        modelBuilder.Entity<UserRole>().HasData(
            new UserRole { UserId = 1, RoleId = 2 },  // owner
            new UserRole { UserId = 3, RoleId = 2 },  // owner

            new UserRole { UserId = 2, RoleId = 1 },
            new UserRole { UserId = 4, RoleId = 1 },
            new UserRole { UserId = 5, RoleId = 1 },
            new UserRole { UserId = 6, RoleId = 1 },
            new UserRole { UserId = 7, RoleId = 1 },
            new UserRole { UserId = 8, RoleId = 1 },
            new UserRole { UserId = 9, RoleId = 1 },
            new UserRole { UserId = 10, RoleId = 1 }
        );

        // ================= PROPERTIES =================
        // (ostavio sam ti iste property-e kao što imaš)
        modelBuilder.Entity<Property>().HasData(
            // Sarajevo
            new Property { Id = 1, UserId = 1, Name = "Central City Apartment", City = "Sarajevo", Location = "Zmaja od Bosne 12", PricePerDay = 65, PricePerMonth = 1550, Tags = new() { "urban", "bright", "central", "modern" }, NumberOfsquares = "55", Details = "Bright apartment in central Sarajevo.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 2, UserId = 1, Name = "Old Town Flat", City = "Sarajevo", Location = "Bistrik 7", PricePerDay = 60, PricePerMonth = 1450, Tags = new() { "historic", "authentic", "warm" }, NumberOfsquares = "48", Details = "Flat near the old town.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 3, UserId = 3, Name = "Hillside View Apartment", City = "Sarajevo", Location = "Alipašina 42", PricePerDay = 70, PricePerMonth = 1650, Tags = new() { "view", "calm", "elevated" }, NumberOfsquares = "60", Details = "Apartment with city views.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 4, UserId = 1, Name = "Modern Loft", City = "Sarajevo", Location = "Kolodvorska 18", PricePerDay = 75, PricePerMonth = 1800, Tags = new() { "loft", "stylish", "open" }, NumberOfsquares = "62", Details = "Modern loft style apartment.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 5, UserId = 3, Name = "Quiet Residential Flat", City = "Sarajevo", Location = "Grbavička 91", PricePerDay = 55, PricePerMonth = 1350, Tags = new() { "quiet", "balanced", "comfortable" }, NumberOfsquares = "50", Details = "Calm residential apartment.", IsAvailable = false, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 6, UserId = 1, Name = "Sunny Apartment", City = "Sarajevo", Location = "Hamze Hume 5", PricePerDay = 68, PricePerMonth = 1600, Tags = new() { "sunny", "warm", "airy" }, NumberOfsquares = "57", Details = "Sunny apartment with open layout.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 7, UserId = 3, Name = "Compact Studio", City = "Sarajevo", Location = "Logavina 23", PricePerDay = 45, PricePerMonth = 1100, Tags = new() { "compact", "simple", "efficient" }, NumberOfsquares = "32", Details = "Compact studio apartment.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 8, UserId = 1, Name = "Panorama Residence", City = "Sarajevo", Location = "Skenderija 10", PricePerDay = 80, PricePerMonth = 1900, Tags = new() { "panorama", "exclusive", "bright" }, NumberOfsquares = "70", Details = "Residence with panoramic city view.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },

            // Mostar
            new Property { Id = 9, UserId = 3, Name = "River Side Apartment", City = "Mostar", Location = "Maršala Tita 14", PricePerDay = 70, PricePerMonth = 1650, Tags = new() { "river", "relaxing", "open" }, NumberOfsquares = "58", Details = "Apartment near the river.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 10, UserId = 1, Name = "Old Bridge View Flat", City = "Mostar", Location = "Rade Bitange 3", PricePerDay = 85, PricePerMonth = 2000, Tags = new() { "iconic", "view", "historic" }, NumberOfsquares = "65", Details = "Flat with a view of the Old Bridge.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 11, UserId = 3, Name = "Stone House Apartment", City = "Mostar", Location = "Braće Fejića 27", PricePerDay = 60, PricePerMonth = 1450, Tags = new() { "stone", "traditional", "cool" }, NumberOfsquares = "50", Details = "Traditional stone apartment.", IsAvailable = false, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 12, UserId = 1, Name = "Sunny Terrace Flat", City = "Mostar", Location = "Adema Buća 9", PricePerDay = 75, PricePerMonth = 1750, Tags = new() { "sunny", "terrace", "open" }, NumberOfsquares = "60", Details = "Apartment with sunny terrace.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 13, UserId = 3, Name = "Quiet Center Apartment", City = "Mostar", Location = "Kralja Tvrtka 6", PricePerDay = 65, PricePerMonth = 1550, Tags = new() { "quiet", "central", "comfortable" }, NumberOfsquares = "54", Details = "Quiet apartment in city center.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 14, UserId = 1, Name = "Minimal Flat", City = "Mostar", Location = "Splitska 22", PricePerDay = 55, PricePerMonth = 1300, Tags = new() { "minimal", "clean", "simple" }, NumberOfsquares = "45", Details = "Minimalist apartment.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 15, UserId = 3, Name = "Evening Light Apartment", City = "Mostar", Location = "Put Mladih Muslimana 4", PricePerDay = 68, PricePerMonth = 1600, Tags = new() { "warm", "evening", "relaxed" }, NumberOfsquares = "56", Details = "Warm and relaxed living space.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },

            // Tuzla
            new Property { Id = 16, UserId = 1, Name = "City Center Apartment", City = "Tuzla", Location = "Slatina 15", PricePerDay = 50, PricePerMonth = 1200, Tags = new() { "central", "balanced", "urban" }, NumberOfsquares = "48", Details = "Apartment in city center.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 17, UserId = 3, Name = "Salt Lake View Flat", City = "Tuzla", Location = "Turalibegova 8", PricePerDay = 65, PricePerMonth = 1500, Tags = new() { "lake", "fresh", "open" }, NumberOfsquares = "55", Details = "Flat near salt lakes.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 18, UserId = 1, Name = "Quiet Residential Studio", City = "Tuzla", Location = "Batva 21", PricePerDay = 40, PricePerMonth = 950, Tags = new() { "quiet", "compact", "simple" }, NumberOfsquares = "30", Details = "Studio in a quiet area.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 19, UserId = 3, Name = "Modern Flat", City = "Tuzla", Location = "Krečka 33", PricePerDay = 55, PricePerMonth = 1300, Tags = new() { "modern", "clean", "bright" }, NumberOfsquares = "50", Details = "Modern city flat.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 20, UserId = 1, Name = "Family Apartment", City = "Tuzla", Location = "Brčanska Malta 12", PricePerDay = 60, PricePerMonth = 1400, Tags = new() { "family", "comfortable", "spacious" }, NumberOfsquares = "62", Details = "Spacious apartment for families.", IsAvailable = false, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 21, UserId = 3, Name = "Sunlit Flat", City = "Tuzla", Location = "Stupine A2", PricePerDay = 58, PricePerMonth = 1350, Tags = new() { "sunny", "open", "warm" }, NumberOfsquares = "53", Details = "Flat with great sunlight.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 22, UserId = 1, Name = "Calm Living Space", City = "Tuzla", Location = "Irac 6", PricePerDay = 52, PricePerMonth = 1250, Tags = new() { "calm", "balanced", "quiet" }, NumberOfsquares = "49", Details = "Calm and balanced apartment.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },

            // Banja Luka
            new Property { Id = 23, UserId = 3, Name = "City Loft", City = "Banja Luka", Location = "Kralja Petra I Karađorđevića 19", PricePerDay = 70, PricePerMonth = 1650, Tags = new() { "loft", "urban", "creative" }, NumberOfsquares = "60", Details = "Urban loft in city center.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 24, UserId = 1, Name = "River Walk Apartment", City = "Banja Luka", Location = "Obala Stepe Stepanovića 7", PricePerDay = 75, PricePerMonth = 1750, Tags = new() { "river", "walkable", "fresh" }, NumberOfsquares = "58", Details = "Apartment near river walk.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 25, UserId = 3, Name = "Minimal Residence", City = "Banja Luka", Location = "Cara Dušana 41", PricePerDay = 55, PricePerMonth = 1300, Tags = new() { "minimal", "clean", "simple" }, NumberOfsquares = "47", Details = "Minimalist residence.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 26, UserId = 1, Name = "Family City Home", City = "Banja Luka", Location = "Bulevar Vojvode Stepe 88", PricePerDay = 65, PricePerMonth = 1550, Tags = new() { "family", "balanced", "comfortable" }, NumberOfsquares = "64", Details = "Family-friendly city home.", IsAvailable = false, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 27, UserId = 3, Name = "Bright Studio", City = "Banja Luka", Location = "Gundulićeva 10", PricePerDay = 45, PricePerMonth = 1050, Tags = new() { "bright", "compact", "efficient" }, NumberOfsquares = "33", Details = "Bright compact studio.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 28, UserId = 1, Name = "Panorama Flat", City = "Banja Luka", Location = "Kninska 25", PricePerDay = 78, PricePerMonth = 1850, Tags = new() { "panorama", "open", "elevated" }, NumberOfsquares = "68", Details = "Flat with panoramic view.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 29, UserId = 3, Name = "Quiet Corner Apartment", City = "Banja Luka", Location = "Solunska 3", PricePerDay = 50, PricePerMonth = 1200, Tags = new() { "quiet", "corner", "calm" }, NumberOfsquares = "46", Details = "Quiet corner apartment.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true },
            new Property { Id = 30, UserId = 1, Name = "Elegant City Flat", City = "Banja Luka", Location = "Vase Pelagića 17", PricePerDay = 72, PricePerMonth = 1700, Tags = new() { "elegant", "stylish", "urban" }, NumberOfsquares = "61", Details = "Elegant flat in urban area.", IsAvailable = true, IsRentingPerDay = true, IsActiveOnApp = true }
        );

        // ================= PROPERTY IMAGES =================
        int imgId = 1;
        void AddPropertyImages(int propertyId)
        {
            modelBuilder.Entity<PropertyImage>().HasData(
                new PropertyImage { Id = imgId++, PropertyId = propertyId, PropertyImg = PropertyImageUrl(propertyId, 1), IsMain = true },
                new PropertyImage { Id = imgId++, PropertyId = propertyId, PropertyImg = PropertyImageUrl(propertyId, 2), IsMain = false },
                new PropertyImage { Id = imgId++, PropertyId = propertyId, PropertyImg = PropertyImageUrl(propertyId, 3), IsMain = false },
                new PropertyImage { Id = imgId++, PropertyId = propertyId, PropertyImg = PropertyImageUrl(propertyId, 4), IsMain = false }
            );
        }

        foreach (var propertyId in Enumerable.Range(1, 30))
            AddPropertyImages(propertyId);

        // ================= RESERVATIONS =================
        // Pravilo: 1 mjesečna po property-u (da nema konflikta).
        // Napravio sam više mjesečnih rezervacija da “logika” ima smisla sa payments.
        modelBuilder.Entity<Reservation>().HasData(
            new Reservation { Id = 1, UserId = 4, PropertyId = 1, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 2, UserId = 5, PropertyId = 2, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 2, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 3, UserId = 6, PropertyId = 3, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 3, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 4, UserId = 7, PropertyId = 4, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 4, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 5, UserId = 8, PropertyId = 9, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 5, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 6, UserId = 9, PropertyId = 10, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 6, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 7, UserId = 10, PropertyId = 16, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 7, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 8, UserId = 2, PropertyId = 23, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2025, 12, 8, 0, 0, 0, DateTimeKind.Utc) },

            // par kratkih boravaka (ne smeta reportu, ali da DB “živi”)
            new Reservation
            {
                Id = 9,
                UserId = 5,
                PropertyId = 12,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 2, 10, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 2, 15, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = true,
                CreatedAt = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc)
            },
            new Reservation
            {
                Id = 10,
                UserId = 6,
                PropertyId = 24,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 1, 5, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = true,
                CreatedAt = new DateTime(2025, 12, 28, 0, 0, 0, DateTimeKind.Utc)
            }
        );

        // ================= PAYMENTS =================
        // Fokus: puno plaćenih (IsPayed = true) za 12/2025, 01/2026, 02/2026
        // za više nekretnina oba vlasnika.
        var payments = new List<Payment>();
        int payId = 1;

        void AddMonthlyPayment(int userId, int propertyId, decimal price, int year, int month)
        {
            payments.Add(new Payment
            {
                Id = payId++,
                UserId = userId,
                PropertyId = propertyId,
                Name = $"Mjesečna rata {month:D2}.{year}",
                Comment = "Uplata evidentirana.",
                Price = (double)price,
                IsPayed = true,
                MonthNumber = month,
                YearNumber = year,
                DateToPay = new DateTime(year, month, 5, 0, 0, 0, DateTimeKind.Utc),
                WarningDateToPay = new DateTime(year, month, 12, 0, 0, 0, DateTimeKind.Utc),
            });
        }

        // Ovi parovi daju raznolikost (više usera, više property-a, oba vlasnika)
        // Owner1 property-i: 1,2,4,10,12,16,18,24,28,30
        // Owner2 property-i: 3,7,9,13,15,17,19,21,23,29
        var monthlyPairs = new (int userId, int propertyId, decimal price)[]
        {
            (4, 1, 1550),   // owner1
            (5, 2, 1450),
            (7, 4, 1800),
            (9, 10, 2000),
            (5, 12, 1750),
            (10, 16, 1200),
            (8, 18, 950),
            (6, 24, 1750),
            (7, 28, 1850),
            (4, 30, 1700),

            (6, 3, 1650),   // owner2
            (8, 7, 1100),
            (8, 9, 1650),
            (10, 13, 1550),
            (9, 15, 1600),
            (2, 17, 1500),
            (4, 19, 1300),
            (7, 21, 1350),
            (2, 23, 1650),
            (10, 29, 1200),
        };

        // 12/2025, 01/2026, 02/2026
        foreach (var (u, p, price) in monthlyPairs)
        {
            AddMonthlyPayment(u, p, price, 2025, 12);
            AddMonthlyPayment(u, p, price, 2026, 1);
            AddMonthlyPayment(u, p, price, 2026, 2);
        }

        // malo “kratkih boravaka” (također IsPayed=true) za dodatni promet i raznolikost
        payments.Add(new Payment
        {
            Id = payId++,
            UserId = 5,
            PropertyId = 8,
            Name = "Kratki boravak 12.2025",
            Comment = "Uplata za kratki boravak.",
            Price = 420,
            IsPayed = true,
            MonthNumber = 12,
            YearNumber = 2025,
            DateToPay = new DateTime(2025, 12, 18, 0, 0, 0, DateTimeKind.Utc),
            WarningDateToPay = new DateTime(2025, 12, 22, 0, 0, 0, DateTimeKind.Utc),
        });

        payments.Add(new Payment
        {
            Id = payId++,
            UserId = 6,
            PropertyId = 14,
            Name = "Kratki boravak 01.2026",
            Comment = "Uplata za kratki boravak.",
            Price = 380,
            IsPayed = true,
            MonthNumber = 1,
            YearNumber = 2026,
            DateToPay = new DateTime(2026, 1, 12, 0, 0, 0, DateTimeKind.Utc),
            WarningDateToPay = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc),
        });

        payments.Add(new Payment
        {
            Id = payId++,
            UserId = 9,
            PropertyId = 25,
            Name = "Kratki boravak 02.2026",
            Comment = "Uplata za kratki boravak.",
            Price = 510,
            IsPayed = true,
            MonthNumber = 2,
            YearNumber = 2026,
            DateToPay = new DateTime(2026, 2, 8, 0, 0, 0, DateTimeKind.Utc),
            WarningDateToPay = new DateTime(2026, 2, 12, 0, 0, 0, DateTimeKind.Utc),
        });

        // Par neplaćenih za 03/2026 (da vidiš da izvještaj neće računati)
        payments.Add(new Payment
        {
            Id = payId++,
            UserId = 4,
            PropertyId = 1,
            Name = "Mjesečna rata 03.2026 (NEPLAĆENO)",
            Comment = "Čeka uplatu.",
            Price = 1550,
            IsPayed = false,
            MonthNumber = 3,
            YearNumber = 2026,
            DateToPay = new DateTime(2026, 3, 5, 0, 0, 0, DateTimeKind.Utc),
            WarningDateToPay = new DateTime(2026, 3, 12, 0, 0, 0, DateTimeKind.Utc),
        });

        payments.Add(new Payment
        {
            Id = payId++,
            UserId = 10,
            PropertyId = 23,
            Name = "Mjesečna rata 03.2026 (NEPLAĆENO)",
            Comment = "Čeka uplatu.",
            Price = 1650,
            IsPayed = false,
            MonthNumber = 3,
            YearNumber = 2026,
            DateToPay = new DateTime(2026, 3, 5, 0, 0, 0, DateTimeKind.Utc),
            WarningDateToPay = new DateTime(2026, 3, 12, 0, 0, 0, DateTimeKind.Utc),
        });

        modelBuilder.Entity<Payment>().HasData(payments);

        // ================= APPOINTMENTS =================
        // Par termina (ne utiče na report)
        modelBuilder.Entity<Appointment>().HasData(
            new Appointment { Id = 1, UserId = 5, PropertyId = 8, DateAppointment = new DateTime(2026, 3, 8, 11, 0, 0, DateTimeKind.Utc), IsApproved = true },
            new Appointment { Id = 2, UserId = 6, PropertyId = 10, DateAppointment = new DateTime(2026, 3, 11, 9, 30, 0, DateTimeKind.Utc), IsApproved = null },
            new Appointment { Id = 3, UserId = 7, PropertyId = 12, DateAppointment = new DateTime(2026, 3, 12, 13, 0, 0, DateTimeKind.Utc), IsApproved = true }
        );

        // ================= REVIEWS =================
// Napomena: UserId su renteri (2..10), PropertyId postoje (1..30)
modelBuilder.Entity<Review>().HasData(
    // Sarajevo
    new Review { Id = 1,  UserId = 4,  PropertyId = 1,  StarRate = 5, Comment = "Odlična lokacija i baš čisto. Preporuka!" },
    new Review { Id = 2,  UserId = 5,  PropertyId = 2,  StarRate = 4, Comment = "Ugodan stan, blizu centra. Sve korektno." },
    new Review { Id = 3,  UserId = 6,  PropertyId = 3,  StarRate = 5, Comment = "Pogled je fantastičan, mirno naselje." },
    new Review { Id = 4,  UserId = 7,  PropertyId = 4,  StarRate = 4, Comment = "Moderan loft, sve kao na slikama." },
    new Review { Id = 5,  UserId = 8,  PropertyId = 6,  StarRate = 3, Comment = "Sve ok, ali bi moglo malo bolje održavanje." },
    new Review { Id = 6,  UserId = 9,  PropertyId = 8,  StarRate = 5, Comment = "Panoramski pogled i top ambijent." },

    // Mostar
    new Review { Id = 7,  UserId = 8,  PropertyId = 9,  StarRate = 4, Comment = "Lijep apartman, blizu rijeke. Ugodno." },
    new Review { Id = 8,  UserId = 9,  PropertyId = 10, StarRate = 5, Comment = "Lokacija savršena, pogled na Stari most." },
    new Review { Id = 9,  UserId = 5,  PropertyId = 12, StarRate = 4, Comment = "Terasa je odlična, sve uredno i čisto." },
    new Review { Id = 10, UserId = 10, PropertyId = 13, StarRate = 4, Comment = "Mirno, centralno, domaćin korektan." },
    new Review { Id = 11, UserId = 6,  PropertyId = 14, StarRate = 3, Comment = "Minimalistički, ok za kratki boravak." },
    new Review { Id = 12, UserId = 7,  PropertyId = 15, StarRate = 5, Comment = "Top ugođaj, sve preporuke!" },

    // Tuzla
    new Review { Id = 13, UserId = 10, PropertyId = 16, StarRate = 4, Comment = "Praktično i blizu svega. Komforno." },
    new Review { Id = 14, UserId = 2,  PropertyId = 17, StarRate = 5, Comment = "Pogled na jezera je predobar. Sve super." },
    new Review { Id = 15, UserId = 8,  PropertyId = 18, StarRate = 4, Comment = "Studio je mali ali uredan i funkcionalan." },
    new Review { Id = 16, UserId = 4,  PropertyId = 19, StarRate = 3, Comment = "Sve ok, ali je bilo malo buke navečer." },
    new Review { Id = 17, UserId = 6,  PropertyId = 22, StarRate = 4, Comment = "Mirno i udobno, dobra vrijednost za novac." },

    // Banja Luka
    new Review { Id = 18, UserId = 2,  PropertyId = 23, StarRate = 5, Comment = "Loft je unikatan i baš udoban." },
    new Review { Id = 19, UserId = 6,  PropertyId = 24, StarRate = 4, Comment = "Super lokacija uz rijeku, sve čisto." },
    new Review { Id = 20, UserId = 9,  PropertyId = 25, StarRate = 4, Comment = "Minimalistički i uredno, preporuka." },
    new Review { Id = 21, UserId = 7,  PropertyId = 28, StarRate = 5, Comment = "Panorama je nevjerovatna. Sve savršeno." },
    new Review { Id = 22, UserId = 10, PropertyId = 29, StarRate = 3, Comment = "Mirno, ali bi dobro došlo malo više opreme." },
    new Review { Id = 23, UserId = 4,  PropertyId = 30, StarRate = 4, Comment = "Elegantno i uredno, dobra lokacija." },

    // par “strožijih” ocjena da izgleda realnije
    new Review { Id = 24, UserId = 5,  PropertyId = 1,  StarRate = 2, Comment = "Lokacija dobra, ali higijena može bolje." },
    new Review { Id = 25, UserId = 8,  PropertyId = 10, StarRate = 3, Comment = "Sve ok, ali parkiranje je bilo problem." }
);
    }
}