using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Rentify.Services.Migrations
{
    /// <inheritdoc />
    public partial class fixingDatabase : Migration
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
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    LastLoginAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    PhoneNumber = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true)
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
                    Price = table.Column<double>(type: "double precision", nullable: false),
                    IsPayed = table.Column<bool>(type: "boolean", nullable: false),
                    DateToPay = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    WarningDateToPay = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
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
                    IsAproved = table.Column<bool>(type: "boolean", nullable: true)
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
                    { 1, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(163), "Standardni korisnik aplikacije", true, "Korisnik" },
                    { 2, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(166), "Vlasnik nekretnina koji može upravljati objektima", true, "Vlasnik" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAt", "DateOfBirth", "Email", "FirstName", "IsActive", "IsVlasnik", "LastLoginAt", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "UserImage", "Username" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(346), null, "marko.petrov@rentify.dev", "Marko", true, true, null, "Petrov", "Z4wbTY1vtyCVj8ZHkrGzHZgV71fPjStP5JaQhazVHIcLdBclaEu3l2boMA4sbFWvPhnhjV6jUr852XM07SNnhQ==", "9x+2HucsLx7FOQxfAqWJmxM+rRd7K0yqLucwHGAekMxMRt0i4zj5rTocSmlSJBGQ/IqpOyAUyXb8LyPnbL65CjwBV742F/ODn2XoznYp6E+RyxsVUi1rNLfHyXOO33SNF7f7cuLRx9dlzIolBs/dHIdmhlc2B44n1Zk5Ss/53K0=", null, null, "owner1" },
                    { 2, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(354), null, "ivana.kovac@rentify.dev", "Ivana", true, false, null, "Kovac", "Z4wbTY1vtyCVj8ZHkrGzHZgV71fPjStP5JaQhazVHIcLdBclaEu3l2boMA4sbFWvPhnhjV6jUr852XM07SNnhQ==", "9x+2HucsLx7FOQxfAqWJmxM+rRd7K0yqLucwHGAekMxMRt0i4zj5rTocSmlSJBGQ/IqpOyAUyXb8LyPnbL65CjwBV742F/ODn2XoznYp6E+RyxsVUi1rNLfHyXOO33SNF7f7cuLRx9dlzIolBs/dHIdmhlc2B44n1Zk5Ss/53K0=", null, null, "user1" },
                    { 3, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(357), null, "nikola.jovic@rentify.dev", "Nikola", true, true, null, "Jovic", "Z4wbTY1vtyCVj8ZHkrGzHZgV71fPjStP5JaQhazVHIcLdBclaEu3l2boMA4sbFWvPhnhjV6jUr852XM07SNnhQ==", "9x+2HucsLx7FOQxfAqWJmxM+rRd7K0yqLucwHGAekMxMRt0i4zj5rTocSmlSJBGQ/IqpOyAUyXb8LyPnbL65CjwBV742F/ODn2XoznYp6E+RyxsVUi1rNLfHyXOO33SNF7f7cuLRx9dlzIolBs/dHIdmhlc2B44n1Zk5Ss/53K0=", null, null, "owner2" }
                });

            migrationBuilder.InsertData(
                table: "Properties",
                columns: new[] { "Id", "City", "Details", "IsActiveOnApp", "IsAvailable", "IsRentingPerDay", "Location", "Name", "NumberOfsquares", "PricePerDay", "PricePerMonth", "Tags", "UserId" },
                values: new object[,]
                {
                    { 1, "Sarajevo", "Bright apartment in central Sarajevo.", true, true, false, "Zmaja od Bosne 12", "Central City Apartment", "55", 65.0, 1550.0, new List<string> { "urban", "bright", "central", "modern" }, 1 },
                    { 2, "Sarajevo", "Flat near the old town.", true, true, false, "Bistrik 7", "Old Town Flat", "48", 60.0, 1450.0, new List<string> { "historic", "authentic", "warm" }, 1 },
                    { 3, "Sarajevo", "Apartment with city views.", true, true, false, "Alipašina 42", "Hillside View Apartment", "60", 70.0, 1650.0, new List<string> { "view", "calm", "elevated" }, 3 },
                    { 4, "Sarajevo", "Modern loft style apartment.", true, true, false, "Kolodvorska 18", "Modern Loft", "62", 75.0, 1800.0, new List<string> { "loft", "stylish", "open" }, 1 },
                    { 5, "Sarajevo", "Calm residential apartment.", true, false, false, "Grbavička 91", "Quiet Residential Flat", "50", 55.0, 1350.0, new List<string> { "quiet", "balanced", "comfortable" }, 3 },
                    { 6, "Sarajevo", "Sunny apartment with open layout.", true, true, false, "Hamze Hume 5", "Sunny Apartment", "57", 68.0, 1600.0, new List<string> { "sunny", "warm", "airy" }, 1 },
                    { 7, "Sarajevo", "Compact studio apartment.", true, true, false, "Logavina 23", "Compact Studio", "32", 45.0, 1100.0, new List<string> { "compact", "simple", "efficient" }, 3 },
                    { 8, "Sarajevo", "Residence with panoramic city view.", true, true, false, "Skenderija 10", "Panorama Residence", "70", 80.0, 1900.0, new List<string> { "panorama", "exclusive", "bright" }, 1 },
                    { 9, "Mostar", "Apartment near the river.", true, true, false, "Maršala Tita 14", "River Side Apartment", "58", 70.0, 1650.0, new List<string> { "river", "relaxing", "open" }, 3 },
                    { 10, "Mostar", "Flat with a view of the Old Bridge.", true, true, false, "Rade Bitange 3", "Old Bridge View Flat", "65", 85.0, 2000.0, new List<string> { "iconic", "view", "historic" }, 1 },
                    { 11, "Mostar", "Traditional stone apartment.", true, false, false, "Braće Fejića 27", "Stone House Apartment", "50", 60.0, 1450.0, new List<string> { "stone", "traditional", "cool" }, 3 },
                    { 12, "Mostar", "Apartment with sunny terrace.", true, true, false, "Adema Buća 9", "Sunny Terrace Flat", "60", 75.0, 1750.0, new List<string> { "sunny", "terrace", "open" }, 1 },
                    { 13, "Mostar", "Quiet apartment in city center.", true, true, false, "Kralja Tvrtka 6", "Quiet Center Apartment", "54", 65.0, 1550.0, new List<string> { "quiet", "central", "comfortable" }, 3 },
                    { 14, "Mostar", "Minimalist apartment.", true, true, false, "Splitska 22", "Minimal Flat", "45", 55.0, 1300.0, new List<string> { "minimal", "clean", "simple" }, 1 },
                    { 15, "Mostar", "Warm and relaxed living space.", true, true, false, "Put Mladih Muslimana 4", "Evening Light Apartment", "56", 68.0, 1600.0, new List<string> { "warm", "evening", "relaxed" }, 3 },
                    { 16, "Tuzla", "Apartment in city center.", true, true, false, "Slatina 15", "City Center Apartment", "48", 50.0, 1200.0, new List<string> { "central", "balanced", "urban" }, 1 },
                    { 17, "Tuzla", "Flat near salt lakes.", true, true, false, "Turalibegova 8", "Salt Lake View Flat", "55", 65.0, 1500.0, new List<string> { "lake", "fresh", "open" }, 3 },
                    { 18, "Tuzla", "Studio in a quiet area.", true, true, false, "Batva 21", "Quiet Residential Studio", "30", 40.0, 950.0, new List<string> { "quiet", "compact", "simple" }, 1 },
                    { 19, "Tuzla", "Modern city flat.", true, true, false, "Krečka 33", "Modern Flat", "50", 55.0, 1300.0, new List<string> { "modern", "clean", "bright" }, 3 },
                    { 20, "Tuzla", "Spacious apartment for families.", true, false, false, "Brčanska Malta 12", "Family Apartment", "62", 60.0, 1400.0, new List<string> { "family", "comfortable", "spacious" }, 1 },
                    { 21, "Tuzla", "Flat with great sunlight.", true, true, false, "Stupine A2", "Sunlit Flat", "53", 58.0, 1350.0, new List<string> { "sunny", "open", "warm" }, 3 },
                    { 22, "Tuzla", "Calm and balanced apartment.", true, true, false, "Irac 6", "Calm Living Space", "49", 52.0, 1250.0, new List<string> { "calm", "balanced", "quiet" }, 1 },
                    { 23, "Banja Luka", "Urban loft in city center.", true, true, false, "Kralja Petra I Karađorđevića 19", "City Loft", "60", 70.0, 1650.0, new List<string> { "loft", "urban", "creative" }, 3 },
                    { 24, "Banja Luka", "Apartment near river walk.", true, true, false, "Obala Stepe Stepanovića 7", "River Walk Apartment", "58", 75.0, 1750.0, new List<string> { "river", "walkable", "fresh" }, 1 },
                    { 25, "Banja Luka", "Minimalist residence.", true, true, false, "Cara Dušana 41", "Minimal Residence", "47", 55.0, 1300.0, new List<string> { "minimal", "clean", "simple" }, 3 },
                    { 26, "Banja Luka", "Family-friendly city home.", true, false, false, "Bulevar Vojvode Stepe 88", "Family City Home", "64", 65.0, 1550.0, new List<string> { "family", "balanced", "comfortable" }, 1 },
                    { 27, "Banja Luka", "Bright compact studio.", true, true, false, "Gundulićeva 10", "Bright Studio", "33", 45.0, 1050.0, new List<string> { "bright", "compact", "efficient" }, 3 },
                    { 28, "Banja Luka", "Flat with panoramic view.", true, true, false, "Kninska 25", "Panorama Flat", "68", 78.0, 1850.0, new List<string> { "panorama", "open", "elevated" }, 1 },
                    { 29, "Banja Luka", "Quiet corner apartment.", true, true, false, "Solunska 3", "Quiet Corner Apartment", "46", 50.0, 1200.0, new List<string> { "quiet", "corner", "calm" }, 3 },
                    { 30, "Banja Luka", "Elegant flat in urban area.", true, true, false, "Vase Pelagića 17", "Elegant City Flat", "61", 72.0, 1700.0, new List<string> { "elegant", "stylish", "urban" }, 1 }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "RoleId", "UserId", "DateAssigned", "Id" },
                values: new object[,]
                {
                    { 2, 1, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(380), 0 },
                    { 1, 2, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(381), 0 },
                    { 2, 3, new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(382), 0 }
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
