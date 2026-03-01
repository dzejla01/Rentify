using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Rentify.Services.Migrations
{
    /// <inheritdoc />
    public partial class Init : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FirstName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    LastName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Username = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "text", nullable: false),
                    PasswordSalt = table.Column<string>(type: "text", nullable: false),
                    UserImage = table.Column<string>(type: "text", nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsVlasnik = table.Column<bool>(type: "boolean", nullable: false),
                    IsLoggingFirstTime = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    LastLoginAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    PhoneNumber = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    PreferedTagsIfNoReservations = table.Column<List<string>>(type: "text[]", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Properties",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Location = table.Column<string>(type: "text", nullable: false),
                    City = table.Column<string>(type: "text", nullable: false),
                    PricePerDay = table.Column<double>(type: "double precision", nullable: false),
                    PricePerMonth = table.Column<double>(type: "double precision", nullable: false),
                    Tags = table.Column<List<string>>(type: "text[]", nullable: false),
                    NumberOfsquares = table.Column<string>(type: "text", nullable: false),
                    Details = table.Column<string>(type: "text", nullable: false),
                    IsAvailable = table.Column<bool>(type: "boolean", nullable: false),
                    IsRentingPerDay = table.Column<bool>(type: "boolean", nullable: false),
                    IsActiveOnApp = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Properties", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Properties_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserDeviceTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    Token = table.Column<string>(type: "text", nullable: false),
                    Platform = table.Column<string>(type: "text", nullable: false),
                    DeviceId = table.Column<string>(type: "text", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserDeviceTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserDeviceTokens_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    RoleId = table.Column<int>(type: "integer", nullable: false),
                    Id = table.Column<int>(type: "integer", nullable: false),
                    DateAssigned = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Appointments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    PropertyId = table.Column<int>(type: "integer", nullable: false),
                    DateAppointment = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsApproved = table.Column<bool>(type: "boolean", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Appointments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Appointments_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Appointments_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    PropertyId = table.Column<int>(type: "integer", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Comment = table.Column<string>(type: "text", nullable: false),
                    Price = table.Column<double>(type: "double precision", nullable: false),
                    IsPayed = table.Column<bool>(type: "boolean", nullable: false),
                    MonthNumber = table.Column<int>(type: "integer", nullable: false),
                    YearNumber = table.Column<int>(type: "integer", nullable: false),
                    DateToPay = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    WarningDateToPay = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    StripePaymentIntentId = table.Column<string>(type: "text", nullable: true),
                    PaidAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    PaymentStatus = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Payments_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Payments_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PropertiesImage",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    PropertyId = table.Column<int>(type: "integer", nullable: false),
                    PropertyImg = table.Column<string>(type: "text", nullable: false),
                    IsMain = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertiesImage", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PropertiesImage_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Reservations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    PropertyId = table.Column<int>(type: "integer", nullable: false),
                    IsMonthly = table.Column<bool>(type: "boolean", nullable: false),
                    IsApproved = table.Column<bool>(type: "boolean", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    StartDateOfRenting = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    EndDateOfRenting = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reservations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reservations_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reservations_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    PropertyId = table.Column<int>(type: "integer", nullable: false),
                    Comment = table.Column<string>(type: "text", nullable: false),
                    StarRate = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reviews_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6393), "Standardni korisnik aplikacije", true, "Korisnik" },
                    { 2, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6395), "Vlasnik nekretnina", true, "Vlasnik" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAt", "DateOfBirth", "Email", "FirstName", "IsActive", "IsLoggingFirstTime", "IsVlasnik", "LastLoginAt", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "PreferedTagsIfNoReservations", "UserImage", "Username" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6525), null, "owner.testni@gmail.com", "Marko", true, false, true, null, "Petrov", "YhfiqcqWJ8k44HLVFxRw0rUQmnKj/ntVVSAWZg+97J8tmV+1AUZjSWbXGD5JrGvrCXj1Ga1GOWDQ6ghPgRul6w==", "gi1YkEudvLzDk7tFnT3D6inE16YowuhxlVXKGrUOKH2P1GlBOpgGSl5eEP8kL5sekUM0Bp+czNYsYvngWP7ERSk7XRcCEVAAOAajQJN8R/EiuMHxPwMUd4Vpg19JiLtGDwe4lIEOc7Nna69e5z5sz8nBBmdn4FNBxgUe3v4lyCw=", null, null, null, "owner1" },
                    { 2, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6534), null, "ivana.kovac@rentify.dev", "Ivana", true, false, false, null, "Kovac", "YhfiqcqWJ8k44HLVFxRw0rUQmnKj/ntVVSAWZg+97J8tmV+1AUZjSWbXGD5JrGvrCXj1Ga1GOWDQ6ghPgRul6w==", "gi1YkEudvLzDk7tFnT3D6inE16YowuhxlVXKGrUOKH2P1GlBOpgGSl5eEP8kL5sekUM0Bp+czNYsYvngWP7ERSk7XRcCEVAAOAajQJN8R/EiuMHxPwMUd4Vpg19JiLtGDwe4lIEOc7Nna69e5z5sz8nBBmdn4FNBxgUe3v4lyCw=", null, null, null, "user1" },
                    { 3, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6537), null, "nikola.jovic@rentify.dev", "Nikola", true, false, true, null, "Jovic", "YhfiqcqWJ8k44HLVFxRw0rUQmnKj/ntVVSAWZg+97J8tmV+1AUZjSWbXGD5JrGvrCXj1Ga1GOWDQ6ghPgRul6w==", "gi1YkEudvLzDk7tFnT3D6inE16YowuhxlVXKGrUOKH2P1GlBOpgGSl5eEP8kL5sekUM0Bp+czNYsYvngWP7ERSk7XRcCEVAAOAajQJN8R/EiuMHxPwMUd4Vpg19JiLtGDwe4lIEOc7Nna69e5z5sz8nBBmdn4FNBxgUe3v4lyCw=", null, null, null, "owner2" },
                    { 4, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6540), null, "amar.hodzic@rentify.dev", "Amar", true, false, false, null, "Hodzic", "YhfiqcqWJ8k44HLVFxRw0rUQmnKj/ntVVSAWZg+97J8tmV+1AUZjSWbXGD5JrGvrCXj1Ga1GOWDQ6ghPgRul6w==", "gi1YkEudvLzDk7tFnT3D6inE16YowuhxlVXKGrUOKH2P1GlBOpgGSl5eEP8kL5sekUM0Bp+czNYsYvngWP7ERSk7XRcCEVAAOAajQJN8R/EiuMHxPwMUd4Vpg19JiLtGDwe4lIEOc7Nna69e5z5sz8nBBmdn4FNBxgUe3v4lyCw=", null, null, null, "user2" }
                });

            migrationBuilder.InsertData(
                table: "Properties",
                columns: new[] { "Id", "City", "Details", "IsActiveOnApp", "IsAvailable", "IsRentingPerDay", "Location", "Name", "NumberOfsquares", "PricePerDay", "PricePerMonth", "Tags", "UserId" },
                values: new object[,]
                {
                    { 1, "Sarajevo", "Bright apartment in central Sarajevo.", true, true, true, "Zmaja od Bosne 12", "Central City Apartment", "55", 65.0, 1550.0, new List<string> { "urban", "bright", "central", "modern" }, 1 },
                    { 2, "Sarajevo", "Flat near the old town.", true, true, true, "Bistrik 7", "Old Town Flat", "48", 60.0, 1450.0, new List<string> { "historic", "authentic", "warm" }, 1 },
                    { 3, "Sarajevo", "Apartment with city views.", true, true, true, "Alipašina 42", "Hillside View Apartment", "60", 70.0, 1650.0, new List<string> { "view", "calm", "elevated" }, 3 },
                    { 4, "Sarajevo", "Modern loft style apartment.", true, true, true, "Kolodvorska 18", "Modern Loft", "62", 75.0, 1800.0, new List<string> { "loft", "stylish", "open" }, 1 },
                    { 5, "Sarajevo", "Calm residential apartment.", true, false, true, "Grbavička 91", "Quiet Residential Flat", "50", 55.0, 1350.0, new List<string> { "quiet", "balanced", "comfortable" }, 3 },
                    { 6, "Sarajevo", "Sunny apartment with open layout.", true, true, true, "Hamze Hume 5", "Sunny Apartment", "57", 68.0, 1600.0, new List<string> { "sunny", "warm", "airy" }, 1 },
                    { 7, "Sarajevo", "Compact studio apartment.", true, true, true, "Logavina 23", "Compact Studio", "32", 45.0, 1100.0, new List<string> { "compact", "simple", "efficient" }, 3 },
                    { 8, "Sarajevo", "Residence with panoramic city view.", true, true, true, "Skenderija 10", "Panorama Residence", "70", 80.0, 1900.0, new List<string> { "panorama", "exclusive", "bright" }, 1 },
                    { 9, "Mostar", "Apartment near the river.", true, true, true, "Maršala Tita 14", "River Side Apartment", "58", 70.0, 1650.0, new List<string> { "river", "relaxing", "open" }, 3 },
                    { 10, "Mostar", "Flat with a view of the Old Bridge.", true, true, true, "Rade Bitange 3", "Old Bridge View Flat", "65", 85.0, 2000.0, new List<string> { "iconic", "view", "historic" }, 1 },
                    { 11, "Mostar", "Traditional stone apartment.", true, false, true, "Braće Fejića 27", "Stone House Apartment", "50", 60.0, 1450.0, new List<string> { "stone", "traditional", "cool" }, 3 },
                    { 12, "Mostar", "Apartment with sunny terrace.", true, true, true, "Adema Buća 9", "Sunny Terrace Flat", "60", 75.0, 1750.0, new List<string> { "sunny", "terrace", "open" }, 1 },
                    { 13, "Mostar", "Quiet apartment in city center.", true, true, true, "Kralja Tvrtka 6", "Quiet Center Apartment", "54", 65.0, 1550.0, new List<string> { "quiet", "central", "comfortable" }, 3 },
                    { 14, "Mostar", "Minimalist apartment.", true, true, true, "Splitska 22", "Minimal Flat", "45", 55.0, 1300.0, new List<string> { "minimal", "clean", "simple" }, 1 },
                    { 15, "Mostar", "Warm and relaxed living space.", true, true, true, "Put Mladih Muslimana 4", "Evening Light Apartment", "56", 68.0, 1600.0, new List<string> { "warm", "evening", "relaxed" }, 3 },
                    { 16, "Tuzla", "Apartment in city center.", true, true, true, "Slatina 15", "City Center Apartment", "48", 50.0, 1200.0, new List<string> { "central", "balanced", "urban" }, 1 },
                    { 17, "Tuzla", "Flat near salt lakes.", true, true, true, "Turalibegova 8", "Salt Lake View Flat", "55", 65.0, 1500.0, new List<string> { "lake", "fresh", "open" }, 3 },
                    { 18, "Tuzla", "Studio in a quiet area.", true, true, true, "Batva 21", "Quiet Residential Studio", "30", 40.0, 950.0, new List<string> { "quiet", "compact", "simple" }, 1 },
                    { 19, "Tuzla", "Modern city flat.", true, true, true, "Krečka 33", "Modern Flat", "50", 55.0, 1300.0, new List<string> { "modern", "clean", "bright" }, 3 },
                    { 20, "Tuzla", "Spacious apartment for families.", true, false, true, "Brčanska Malta 12", "Family Apartment", "62", 60.0, 1400.0, new List<string> { "family", "comfortable", "spacious" }, 1 },
                    { 21, "Tuzla", "Flat with great sunlight.", true, true, true, "Stupine A2", "Sunlit Flat", "53", 58.0, 1350.0, new List<string> { "sunny", "open", "warm" }, 3 },
                    { 22, "Tuzla", "Calm and balanced apartment.", true, true, true, "Irac 6", "Calm Living Space", "49", 52.0, 1250.0, new List<string> { "calm", "balanced", "quiet" }, 1 },
                    { 23, "Banja Luka", "Urban loft in city center.", true, true, true, "Kralja Petra I Karađorđevića 19", "City Loft", "60", 70.0, 1650.0, new List<string> { "loft", "urban", "creative" }, 3 },
                    { 24, "Banja Luka", "Apartment near river walk.", true, true, true, "Obala Stepe Stepanovića 7", "River Walk Apartment", "58", 75.0, 1750.0, new List<string> { "river", "walkable", "fresh" }, 1 },
                    { 25, "Banja Luka", "Minimalist residence.", true, true, true, "Cara Dušana 41", "Minimal Residence", "47", 55.0, 1300.0, new List<string> { "minimal", "clean", "simple" }, 3 },
                    { 26, "Banja Luka", "Family-friendly city home.", true, false, true, "Bulevar Vojvode Stepe 88", "Family City Home", "64", 65.0, 1550.0, new List<string> { "family", "balanced", "comfortable" }, 1 },
                    { 27, "Banja Luka", "Bright compact studio.", true, true, true, "Gundulićeva 10", "Bright Studio", "33", 45.0, 1050.0, new List<string> { "bright", "compact", "efficient" }, 3 },
                    { 28, "Banja Luka", "Flat with panoramic view.", true, true, true, "Kninska 25", "Panorama Flat", "68", 78.0, 1850.0, new List<string> { "panorama", "open", "elevated" }, 1 },
                    { 29, "Banja Luka", "Quiet corner apartment.", true, true, true, "Solunska 3", "Quiet Corner Apartment", "46", 50.0, 1200.0, new List<string> { "quiet", "corner", "calm" }, 3 },
                    { 30, "Banja Luka", "Elegant flat in urban area.", true, true, true, "Vase Pelagića 17", "Elegant City Flat", "61", 72.0, 1700.0, new List<string> { "elegant", "stylish", "urban" }, 1 }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "RoleId", "UserId", "DateAssigned", "Id" },
                values: new object[,]
                {
                    { 2, 1, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6572), 0 },
                    { 1, 2, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6574), 0 },
                    { 2, 3, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6575), 0 },
                    { 1, 4, new DateTime(2026, 3, 1, 18, 33, 35, 284, DateTimeKind.Utc).AddTicks(6576), 0 }
                });

            migrationBuilder.InsertData(
                table: "Appointments",
                columns: new[] { "Id", "DateAppointment", "IsApproved", "PropertyId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 8, 11, 0, 0, 0, DateTimeKind.Utc), true, 8, 2 },
                    { 2, new DateTime(2026, 3, 11, 9, 30, 0, 0, DateTimeKind.Utc), null, 10, 4 },
                    { 3, new DateTime(2026, 3, 12, 13, 0, 0, 0, DateTimeKind.Utc), true, 12, 2 }
                });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Comment", "DateToPay", "IsPayed", "MonthNumber", "Name", "PaidAt", "PaymentStatus", "Price", "PropertyId", "StripePaymentIntentId", "UserId", "WarningDateToPay", "YearNumber" },
                values: new object[,]
                {
                    { 1, "", null, true, 12, "Mjesečna rata 12.2025", null, "Pending", 1550.0, 1, null, 2, null, 2025 },
                    { 2, "", null, true, 1, "Mjesečna rata 01.2026", null, "Pending", 1550.0, 1, null, 2, null, 2026 },
                    { 3, "", null, true, 2, "Mjesečna rata 02.2026", null, "Pending", 1550.0, 1, null, 2, null, 2026 },
                    { 4, "", null, true, 3, "Kratki boravak 03.2026", null, "Pending", 400.0, 8, null, 2, null, 2026 }
                });

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "CreatedAt", "EndDateOfRenting", "IsApproved", "IsMonthly", "PropertyId", "StartDateOfRenting", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 1, null, 2 },
                    { 2, new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 2, null, 4 },
                    { 3, new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 4, null, 2 },
                    { 4, new DateTime(2026, 1, 4, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 6, null, 4 },
                    { 5, new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 3, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, false, 8, new DateTime(2026, 3, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_PropertyId",
                table: "Appointments",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_UserId",
                table: "Appointments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_PropertyId",
                table: "Payments",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_UserId",
                table: "Payments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Properties_UserId",
                table: "Properties",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertiesImage_PropertyId",
                table: "PropertiesImage",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_PropertyId",
                table: "Reservations",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_UserId",
                table: "Reservations",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_PropertyId",
                table: "Reviews",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId",
                table: "Reviews",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_UserDeviceTokens_Token",
                table: "UserDeviceTokens",
                column: "Token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserDeviceTokens_UserId_IsActive",
                table: "UserDeviceTokens",
                columns: new[] { "UserId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleId",
                table: "UserRoles",
                column: "RoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Appointments");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "PropertiesImage");

            migrationBuilder.DropTable(
                name: "Reservations");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "UserDeviceTokens");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "Properties");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
