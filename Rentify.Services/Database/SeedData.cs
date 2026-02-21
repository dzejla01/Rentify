using Microsoft.EntityFrameworkCore;
using Rentify.Services.Database;
using Rentify.Services.Helpers;

public static class SeedData
{
    public static void Seed(ModelBuilder modelBuilder)
    {

        UserHelper.CreatePasswordHash(
           "Test123!",
           out var hashBase64,
           out var saltBase64
        );

        modelBuilder.Entity<Role>().HasData(
        new Role
        {
            Id = 1,
            Name = "Korisnik",
            Description = "Standardni korisnik aplikacije",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        },
        new Role
        {
            Id = 2,
            Name = "Vlasnik",
            Description = "Vlasnik nekretnina koji može upravljati objektima",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        }
        );

        // USERS (random, neutralni)
        modelBuilder.Entity<User>().HasData(
            new User
            {
                Id = 1,
                FirstName = "Marko",
                LastName = "Petrov",
                Email = "owner.testni@gmail.com",
                Username = "owner1",
                PasswordHash = hashBase64,
                PasswordSalt = saltBase64,
                IsVlasnik = true,
                IsActive = true,
            },
            new User
            {
                Id = 2,
                FirstName = "Ivana",
                LastName = "Kovac",
                Email = "ivana.kovac@rentify.dev",
                Username = "user1",
                PasswordHash = hashBase64,
                PasswordSalt = saltBase64,
                IsVlasnik = false,
                IsActive = true,
            },
            new User
            {
                Id = 3,
                FirstName = "Nikola",
                LastName = "Jovic",
                Email = "nikola.jovic@rentify.dev",
                Username = "owner2",
                PasswordHash = hashBase64,
                PasswordSalt = saltBase64,
                IsVlasnik = true,
                IsActive = true,
            },
            new User
            {
                Id = 4,
                FirstName = "Amar",
                LastName = "Hodzic",
                Email = "amar.hodzic@rentify.dev",
                Username = "user2",
                PasswordHash = hashBase64,
                PasswordSalt = saltBase64,
                IsVlasnik = false,
                IsActive = true
            }

        );

        modelBuilder.Entity<UserRole>().HasData(
            new UserRole { UserId = 1, RoleId = 2 }, // owner1 -> Vlasnik
            new UserRole { UserId = 2, RoleId = 1 }, // user1 -> Korisnik
            new UserRole { UserId = 3, RoleId = 2 },
            new UserRole { UserId = 4, RoleId = 1 }// owner2 -> Vlasnik
        );

        modelBuilder.Entity<Property>().HasData(

    // =========================
    // SARAJEVO (8)
    // =========================
    new Property
    {
        Id = 1,
        UserId = 1,
        Name = "Central City Apartment",
        City = "Sarajevo",
        Location = "Zmaja od Bosne 12",
        PricePerDay = 65,
        PricePerMonth = 1550,
        Tags = new() { "urban", "bright", "central", "modern" },
        NumberOfsquares = "55",
        Details = "Bright apartment in central Sarajevo.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 2,
        UserId = 1,
        Name = "Old Town Flat",
        City = "Sarajevo",
        Location = "Bistrik 7",
        PricePerDay = 60,
        PricePerMonth = 1450,
        Tags = new() { "historic", "authentic", "warm" },
        NumberOfsquares = "48",
        Details = "Flat near the old town.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 3,
        UserId = 3,
        Name = "Hillside View Apartment",
        City = "Sarajevo",
        Location = "Alipašina 42",
        PricePerDay = 70,
        PricePerMonth = 1650,
        Tags = new() { "view", "calm", "elevated" },
        NumberOfsquares = "60",
        Details = "Apartment with city views.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 4,
        UserId = 1,
        Name = "Modern Loft",
        City = "Sarajevo",
        Location = "Kolodvorska 18",
        PricePerDay = 75,
        PricePerMonth = 1800,
        Tags = new() { "loft", "stylish", "open" },
        NumberOfsquares = "62",
        Details = "Modern loft style apartment.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 5,
        UserId = 3,
        Name = "Quiet Residential Flat",
        City = "Sarajevo",
        Location = "Grbavička 91",
        PricePerDay = 55,
        PricePerMonth = 1350,
        Tags = new() { "quiet", "balanced", "comfortable" },
        NumberOfsquares = "50",
        Details = "Calm residential apartment.",
        IsAvailable = false,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 6,
        UserId = 1,
        Name = "Sunny Apartment",
        City = "Sarajevo",
        Location = "Hamze Hume 5",
        PricePerDay = 68,
        PricePerMonth = 1600,
        Tags = new() { "sunny", "warm", "airy" },
        NumberOfsquares = "57",
        Details = "Sunny apartment with open layout.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 7,
        UserId = 3,
        Name = "Compact Studio",
        City = "Sarajevo",
        Location = "Logavina 23",
        PricePerDay = 45,
        PricePerMonth = 1100,
        Tags = new() { "compact", "simple", "efficient" },
        NumberOfsquares = "32",
        Details = "Compact studio apartment.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 8,
        UserId = 1,
        Name = "Panorama Residence",
        City = "Sarajevo",
        Location = "Skenderija 10",
        PricePerDay = 80,
        PricePerMonth = 1900,
        Tags = new() { "panorama", "exclusive", "bright" },
        NumberOfsquares = "70",
        Details = "Residence with panoramic city view.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },

    // =========================
    // MOSTAR (7)
    // =========================
    new Property
    {
        Id = 9,
        UserId = 3,
        Name = "River Side Apartment",
        City = "Mostar",
        Location = "Maršala Tita 14",
        PricePerDay = 70,
        PricePerMonth = 1650,
        Tags = new() { "river", "relaxing", "open" },
        NumberOfsquares = "58",
        Details = "Apartment near the river.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 10,
        UserId = 1,
        Name = "Old Bridge View Flat",
        City = "Mostar",
        Location = "Rade Bitange 3",
        PricePerDay = 85,
        PricePerMonth = 2000,
        Tags = new() { "iconic", "view", "historic" },
        NumberOfsquares = "65",
        Details = "Flat with a view of the Old Bridge.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 11,
        UserId = 3,
        Name = "Stone House Apartment",
        City = "Mostar",
        Location = "Braće Fejića 27",
        PricePerDay = 60,
        PricePerMonth = 1450,
        Tags = new() { "stone", "traditional", "cool" },
        NumberOfsquares = "50",
        Details = "Traditional stone apartment.",
        IsAvailable = false,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 12,
        UserId = 1,
        Name = "Sunny Terrace Flat",
        City = "Mostar",
        Location = "Adema Buća 9",
        PricePerDay = 75,
        PricePerMonth = 1750,
        Tags = new() { "sunny", "terrace", "open" },
        NumberOfsquares = "60",
        Details = "Apartment with sunny terrace.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 13,
        UserId = 3,
        Name = "Quiet Center Apartment",
        City = "Mostar",
        Location = "Kralja Tvrtka 6",
        PricePerDay = 65,
        PricePerMonth = 1550,
        Tags = new() { "quiet", "central", "comfortable" },
        NumberOfsquares = "54",
        Details = "Quiet apartment in city center.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 14,
        UserId = 1,
        Name = "Minimal Flat",
        City = "Mostar",
        Location = "Splitska 22",
        PricePerDay = 55,
        PricePerMonth = 1300,
        Tags = new() { "minimal", "clean", "simple" },
        NumberOfsquares = "45",
        Details = "Minimalist apartment.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 15,
        UserId = 3,
        Name = "Evening Light Apartment",
        City = "Mostar",
        Location = "Put Mladih Muslimana 4",
        PricePerDay = 68,
        PricePerMonth = 1600,
        Tags = new() { "warm", "evening", "relaxed" },
        NumberOfsquares = "56",
        Details = "Warm and relaxed living space.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },

    // =========================
    // TUZLA (7)
    // =========================
    new Property
    {
        Id = 16,
        UserId = 1,
        Name = "City Center Apartment",
        City = "Tuzla",
        Location = "Slatina 15",
        PricePerDay = 50,
        PricePerMonth = 1200,
        Tags = new() { "central", "balanced", "urban" },
        NumberOfsquares = "48",
        Details = "Apartment in city center.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 17,
        UserId = 3,
        Name = "Salt Lake View Flat",
        City = "Tuzla",
        Location = "Turalibegova 8",
        PricePerDay = 65,
        PricePerMonth = 1500,
        Tags = new() { "lake", "fresh", "open" },
        NumberOfsquares = "55",
        Details = "Flat near salt lakes.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 18,
        UserId = 1,
        Name = "Quiet Residential Studio",
        City = "Tuzla",
        Location = "Batva 21",
        PricePerDay = 40,
        PricePerMonth = 950,
        Tags = new() { "quiet", "compact", "simple" },
        NumberOfsquares = "30",
        Details = "Studio in a quiet area.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 19,
        UserId = 3,
        Name = "Modern Flat",
        City = "Tuzla",
        Location = "Krečka 33",
        PricePerDay = 55,
        PricePerMonth = 1300,
        Tags = new() { "modern", "clean", "bright" },
        NumberOfsquares = "50",
        Details = "Modern city flat.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 20,
        UserId = 1,
        Name = "Family Apartment",
        City = "Tuzla",
        Location = "Brčanska Malta 12",
        PricePerDay = 60,
        PricePerMonth = 1400,
        Tags = new() { "family", "comfortable", "spacious" },
        NumberOfsquares = "62",
        Details = "Spacious apartment for families.",
        IsAvailable = false,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 21,
        UserId = 3,
        Name = "Sunlit Flat",
        City = "Tuzla",
        Location = "Stupine A2",
        PricePerDay = 58,
        PricePerMonth = 1350,
        Tags = new() { "sunny", "open", "warm" },
        NumberOfsquares = "53",
        Details = "Flat with great sunlight.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 22,
        UserId = 1,
        Name = "Calm Living Space",
        City = "Tuzla",
        Location = "Irac 6",
        PricePerDay = 52,
        PricePerMonth = 1250,
        Tags = new() { "calm", "balanced", "quiet" },
        NumberOfsquares = "49",
        Details = "Calm and balanced apartment.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },

    // =========================
    // BANJA LUKA (8)
    // =========================
    new Property
    {
        Id = 23,
        UserId = 3,
        Name = "City Loft",
        City = "Banja Luka",
        Location = "Kralja Petra I Karađorđevića 19",
        PricePerDay = 70,
        PricePerMonth = 1650,
        Tags = new() { "loft", "urban", "creative" },
        NumberOfsquares = "60",
        Details = "Urban loft in city center.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 24,
        UserId = 1,
        Name = "River Walk Apartment",
        City = "Banja Luka",
        Location = "Obala Stepe Stepanovića 7",
        PricePerDay = 75,
        PricePerMonth = 1750,
        Tags = new() { "river", "walkable", "fresh" },
        NumberOfsquares = "58",
        Details = "Apartment near river walk.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 25,
        UserId = 3,
        Name = "Minimal Residence",
        City = "Banja Luka",
        Location = "Cara Dušana 41",
        PricePerDay = 55,
        PricePerMonth = 1300,
        Tags = new() { "minimal", "clean", "simple" },
        NumberOfsquares = "47",
        Details = "Minimalist residence.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 26,
        UserId = 1,
        Name = "Family City Home",
        City = "Banja Luka",
        Location = "Bulevar Vojvode Stepe 88",
        PricePerDay = 65,
        PricePerMonth = 1550,
        Tags = new() { "family", "balanced", "comfortable" },
        NumberOfsquares = "64",
        Details = "Family-friendly city home.",
        IsAvailable = false,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 27,
        UserId = 3,
        Name = "Bright Studio",
        City = "Banja Luka",
        Location = "Gundulićeva 10",
        PricePerDay = 45,
        PricePerMonth = 1050,
        Tags = new() { "bright", "compact", "efficient" },
        NumberOfsquares = "33",
        Details = "Bright compact studio.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 28,
        UserId = 1,
        Name = "Panorama Flat",
        City = "Banja Luka",
        Location = "Kninska 25",
        PricePerDay = 78,
        PricePerMonth = 1850,
        Tags = new() { "panorama", "open", "elevated" },
        NumberOfsquares = "68",
        Details = "Flat with panoramic view.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 29,
        UserId = 3,
        Name = "Quiet Corner Apartment",
        City = "Banja Luka",
        Location = "Solunska 3",
        PricePerDay = 50,
        PricePerMonth = 1200,
        Tags = new() { "quiet", "corner", "calm" },
        NumberOfsquares = "46",
        Details = "Quiet corner apartment.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    },
    new Property
    {
        Id = 30,
        UserId = 1,
        Name = "Elegant City Flat",
        City = "Banja Luka",
        Location = "Vase Pelagića 17",
        PricePerDay = 72,
        PricePerMonth = 1700,
        Tags = new() { "elegant", "stylish", "urban" },
        NumberOfsquares = "61",
        Details = "Elegant flat in urban area.",
        IsAvailable = true,
        IsRentingPerDay = true,
        IsActiveOnApp = true
    }
);

        modelBuilder.Entity<Reservation>().HasData(

            // =============================
            // MJESEČNE (automatski odobrene)
            // =============================
            new Reservation { Id = 1, UserId = 2, PropertyId = 1, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 2, UserId = 4, PropertyId = 2, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 3, UserId = 2, PropertyId = 4, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 3, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation { Id = 4, UserId = 4, PropertyId = 6, IsMonthly = true, IsApproved = true, CreatedAt = new DateTime(2026, 1, 4, 0, 0, 0, DateTimeKind.Utc) },

            // =============================
            // DNEVNE (odobrene)
            // =============================
            new Reservation
            {
                Id = 5,
                UserId = 2,
                PropertyId = 8,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 3, 5, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = true,
                CreatedAt = new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new Reservation
            {
                Id = 6,
                UserId = 4,
                PropertyId = 10,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 3, 10, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 3, 15, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = true,
                CreatedAt = new DateTime(2026, 2, 2, 0, 0, 0, DateTimeKind.Utc)
            },
            new Reservation
            {
                Id = 7,
                UserId = 2,
                PropertyId = 12,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 4, 1, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 4, 7, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = true,
                CreatedAt = new DateTime(2026, 2, 3, 0, 0, 0, DateTimeKind.Utc)
            },
            new Reservation
            {
                Id = 8,
                UserId = 4,
                PropertyId = 14,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 4, 10, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 4, 14, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = true,
                CreatedAt = new DateTime(2026, 2, 4, 0, 0, 0, DateTimeKind.Utc)
            },

            // =============================
            // ZAHTJEVI NA ČEKANJU
            // =============================
            new Reservation { Id = 9, UserId = 2, PropertyId = 16, IsMonthly = true, IsApproved = null, CreatedAt = new DateTime(2026, 2, 5, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation
            {
                Id = 10,
                UserId = 4,
                PropertyId = 18,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 5, 1, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 5, 5, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = null,
                CreatedAt = new DateTime(2026, 2, 6, 0, 0, 0, DateTimeKind.Utc)
            },
            new Reservation { Id = 11, UserId = 2, PropertyId = 20, IsMonthly = true, IsApproved = null, CreatedAt = new DateTime(2026, 2, 7, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation
            {
                Id = 12,
                UserId = 4,
                PropertyId = 22,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 5, 10, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 5, 14, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = null,
                CreatedAt = new DateTime(2026, 2, 8, 0, 0, 0, DateTimeKind.Utc)
            },

            // =============================
            // ODBIJENE
            // =============================
            new Reservation { Id = 13, UserId = 2, PropertyId = 24, IsMonthly = true, IsApproved = false, CreatedAt = new DateTime(2026, 2, 9, 0, 0, 0, DateTimeKind.Utc) },
            new Reservation
            {
                Id = 14,
                UserId = 4,
                PropertyId = 26,
                IsMonthly = false,
                StartDateOfRenting = new DateTime(2026, 6, 1, 0, 0, 0, DateTimeKind.Utc),
                EndDateOfRenting = new DateTime(2026, 6, 5, 0, 0, 0, DateTimeKind.Utc),
                IsApproved = false,
                CreatedAt = new DateTime(2026, 2, 10, 0, 0, 0, DateTimeKind.Utc)
            }
        );

        modelBuilder.Entity<Payment>().HasData(

    // =======================================================
    // IVANA KOVAC (UserId=2) - MJESEČNA (PropertyId=1)
    // Plaćeno: 12/2025, 01/2026, 02/2026
    // Neplaćeno: 03/2026 -> treba poslati zahtjev za mart
    // =======================================================

    new Payment
    {
        Id = 1,
        UserId = 2,
        PropertyId = 1,
        Name = "Plaćanje mjesečne rate za 12.2025",
        Price = 1550,
        Comment = "Bez komentara",
        IsPayed = true,
        MonthNumber = 12,
        YearNumber = 2025,
        DateToPay = new DateTime(2025, 12, 5, 0, 0, 0, DateTimeKind.Utc),
        WarningDateToPay = new DateTime(2025, 12, 12, 0, 0, 0, DateTimeKind.Utc),
    },
    new Payment
    {
        Id = 2,
        UserId = 2,
        PropertyId = 1,
        Name = "Plaćanje mjesečne rate za 1.2026",
        Price = 1550,
        Comment = "Bez komentara",
        IsPayed = true,
        MonthNumber = 1,
        YearNumber = 2026,
        DateToPay = new DateTime(2026, 1, 5, 0, 0, 0, DateTimeKind.Utc),
        WarningDateToPay = new DateTime(2026, 1, 12, 0, 0, 0, DateTimeKind.Utc),
    },
    new Payment
    {
        Id = 3,
        UserId = 2,
        PropertyId = 1,
        Name = "Plaćanje mjesečne rate za 2.2026",
        Price = 1550,
        Comment = "Bez komentara",
        IsPayed = true,
        MonthNumber = 2,
        YearNumber = 2026,
        DateToPay = new DateTime(2026, 2, 5, 0, 0, 0, DateTimeKind.Utc),
        WarningDateToPay = new DateTime(2026, 2, 12, 0, 0, 0, DateTimeKind.Utc),
    },

    // =======================================================
    // IVANA KOVAC (UserId=2) - NIJE MJESEČNO (PropertyId=8)
    // Za non-monthly: jedan payment zapis (jednokratno)
    // =======================================================

    new Payment
    {
        Id = 5,
        UserId = 2,
        PropertyId = 8,
        Name = "Plaćanje kratkog boravka",
        Price = 400, 
        Comment = "Bez komentara",
        IsPayed = false,
        MonthNumber = 0,  
        YearNumber = 0,   
        DateToPay = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc),
        WarningDateToPay = new DateTime(2026, 3, 5, 0, 0, 0, DateTimeKind.Utc),
    }
);

modelBuilder.Entity<Review>().HasData(

    // ================================
    // IVANA KOVAC (UserId = 2)
    // ================================

    new Review
    {
        Id = 1,
        UserId = 2,
        PropertyId = 1,
        Comment = "Odličan stan, čisto i uredno. Lokacija savršena.",
        StarRate = 5
    },
    new Review
    {
        Id = 2,
        UserId = 2,
        PropertyId = 8,
        Comment = "Predivan pogled i jako ljubazan vlasnik.",
        StarRate = 5
    },
    new Review
    {
        Id = 3,
        UserId = 2,
        PropertyId = 4,
        Comment = "Stan je moderan i komforan, preporuka.",
        StarRate = 4
    },
    new Review
    {
        Id = 4,
        UserId = 2,
        PropertyId = 12,
        Comment = "Solidno iskustvo, sve je bilo korektno.",
        StarRate = 4
    },

    // ================================
    // AMAR HODZIC (UserId = 4)
    // ================================

    new Review
    {
        Id = 5,
        UserId = 4,
        PropertyId = 2,
        Comment = "Lijep ambijent i mirna lokacija.",
        StarRate = 4
    },
    new Review
    {
        Id = 6,
        UserId = 4,
        PropertyId = 6,
        Comment = "Stan je bio uredan, ali može bolje održavanje.",
        StarRate = 3
    },
    new Review
    {
        Id = 7,
        UserId = 4,
        PropertyId = 10,
        Comment = "Top lokacija u Mostaru, pogled fantastičan!",
        StarRate = 5
    },
    new Review
    {
        Id = 8,
        UserId = 4,
        PropertyId = 14,
        Comment = "Minimalistički stan, vrlo prijatan boravak.",
        StarRate = 4
    },

    // ================================
    // DODATNE (realistične raspodjele)
    // ================================

    new Review
    {
        Id = 9,
        UserId = 2,
        PropertyId = 16,
        Comment = "Praktičan stan u centru Tuzle.",
        StarRate = 4
    },
    new Review
    {
        Id = 10,
        UserId = 4,
        PropertyId = 23,
        Comment = "Loft je unikatan i jako udoban.",
        StarRate = 5
    },
    new Review
    {
        Id = 11,
        UserId = 2,
        PropertyId = 24,
        Comment = "Stan uz rijeku, veoma ugodno iskustvo.",
        StarRate = 4
    },
    new Review
    {
        Id = 12,
        UserId = 4,
        PropertyId = 28,
        Comment = "Panoramski pogled vrijedi svake marke.",
        StarRate = 5
    }
);



    }
}