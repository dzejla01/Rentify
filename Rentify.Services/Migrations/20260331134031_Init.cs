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
                name: "Favorites",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    PropertyId = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Favorites", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Favorites_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Favorites_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
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
                name: "Questions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    PropertyId = table.Column<int>(type: "integer", nullable: false),
                    Content = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsAnswered = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Questions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Questions_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Questions_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
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

            migrationBuilder.CreateTable(
                name: "Answers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    QuestionId = table.Column<int>(type: "integer", nullable: false),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    Content = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Answers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Answers_Questions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "Questions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Answers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ReservationId = table.Column<int>(type: "integer", nullable: false),
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
                        name: "FK_Payments_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ReservationHistories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ReservationId = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Note = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ChangedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReservationHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ReservationHistories_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Standardni korisnik aplikacije", true, "Korisnik" },
                    { 2, new DateTime(2025, 12, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Vlasnik nekretnina", true, "Vlasnik" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAt", "DateOfBirth", "Email", "FirstName", "IsActive", "IsLoggingFirstTime", "IsVlasnik", "LastLoginAt", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "PreferedTagsIfNoReservations", "UserImage", "Username" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7896), null, "marko.petrov@rentify.dev", "Marko", true, false, true, null, "Petrov", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "owner1" },
                    { 2, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7906), null, "usertestni089@gmail.com", "Ivana", true, false, false, null, "Kovac", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user1" },
                    { 3, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7904), null, "owner.testni@gmail.com", "Nikola", true, false, true, null, "Jovic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "owner2" },
                    { 4, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7908), null, "amar.hodzic@rentify.dev", "Amar", true, false, false, null, "Hodzic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user2" },
                    { 5, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7909), null, "lejla.mehic@rentify.dev", "Lejla", true, false, false, null, "Mehic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user3" },
                    { 6, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7918), null, "haris.begic@rentify.dev", "Haris", true, false, false, null, "Begic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user4" },
                    { 7, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7919), null, "selma.kurtovic@rentify.dev", "Selma", true, false, false, null, "Kurtovic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user5" },
                    { 8, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7921), null, "adnan.delic@rentify.dev", "Adnan", true, false, false, null, "Delic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user6" },
                    { 9, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7923), null, "emina.zahiragic@rentify.dev", "Emina", true, false, false, null, "Zahiragic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user7" },
                    { 10, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7924), null, "nermin.basic@rentify.dev", "Nermin", true, false, false, null, "Basic", "0UAaWu8l0tMqVZdRpSzbPIIJriW6Enu8Sphjl+KU0nx9lw3sVs6ngWIIJwPYlmuULRQPsJifK4LOdZL7rgZGXQ==", "63YducqX/EsPy1zU2kvdVv0UklrRYryCKRlnddEIaOVu/fNtYFTqghNa9BMbRL+ApjbDnbW87Ug1qxfIP0LhIQ/IF5MoWOSgl2mzXjoAwVemYb9HIc48+gZrP7veSWH0Gb1/6qtmOQtLGBGahlJPp68OEBwTImaDWrHG/mT332k=", null, null, null, "user8" }
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
                    { 2, 1, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7960), 0 },
                    { 1, 2, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7963), 0 },
                    { 2, 3, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7962), 0 },
                    { 1, 4, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7963), 0 },
                    { 1, 5, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7964), 0 },
                    { 1, 6, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7964), 0 },
                    { 1, 7, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7965), 0 },
                    { 1, 8, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7965), 0 },
                    { 1, 9, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7966), 0 },
                    { 1, 10, new DateTime(2026, 3, 31, 13, 40, 30, 593, DateTimeKind.Utc).AddTicks(7966), 0 }
                });

            migrationBuilder.InsertData(
                table: "Appointments",
                columns: new[] { "Id", "DateAppointment", "IsApproved", "PropertyId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 8, 11, 0, 0, 0, DateTimeKind.Utc), true, 8, 5 },
                    { 2, new DateTime(2026, 3, 11, 9, 30, 0, 0, DateTimeKind.Utc), null, 10, 6 },
                    { 3, new DateTime(2026, 3, 12, 13, 0, 0, 0, DateTimeKind.Utc), true, 12, 7 }
                });

            migrationBuilder.InsertData(
                table: "PropertiesImage",
                columns: new[] { "Id", "IsMain", "PropertyId", "PropertyImg" },
                values: new object[,]
                {
                    { 1, true, 1, "https://picsum.photos/seed/property-1-1/900/600" },
                    { 2, false, 1, "https://picsum.photos/seed/property-1-2/900/600" },
                    { 3, false, 1, "https://picsum.photos/seed/property-1-3/900/600" },
                    { 4, false, 1, "https://picsum.photos/seed/property-1-4/900/600" },
                    { 5, true, 2, "https://picsum.photos/seed/property-2-1/900/600" },
                    { 6, false, 2, "https://picsum.photos/seed/property-2-2/900/600" },
                    { 7, false, 2, "https://picsum.photos/seed/property-2-3/900/600" },
                    { 8, false, 2, "https://picsum.photos/seed/property-2-4/900/600" },
                    { 9, true, 3, "https://picsum.photos/seed/property-3-1/900/600" },
                    { 10, false, 3, "https://picsum.photos/seed/property-3-2/900/600" },
                    { 11, false, 3, "https://picsum.photos/seed/property-3-3/900/600" },
                    { 12, false, 3, "https://picsum.photos/seed/property-3-4/900/600" },
                    { 13, true, 4, "https://picsum.photos/seed/property-4-1/900/600" },
                    { 14, false, 4, "https://picsum.photos/seed/property-4-2/900/600" },
                    { 15, false, 4, "https://picsum.photos/seed/property-4-3/900/600" },
                    { 16, false, 4, "https://picsum.photos/seed/property-4-4/900/600" },
                    { 17, true, 5, "https://picsum.photos/seed/property-5-1/900/600" },
                    { 18, false, 5, "https://picsum.photos/seed/property-5-2/900/600" },
                    { 19, false, 5, "https://picsum.photos/seed/property-5-3/900/600" },
                    { 20, false, 5, "https://picsum.photos/seed/property-5-4/900/600" },
                    { 21, true, 6, "https://picsum.photos/seed/property-6-1/900/600" },
                    { 22, false, 6, "https://picsum.photos/seed/property-6-2/900/600" },
                    { 23, false, 6, "https://picsum.photos/seed/property-6-3/900/600" },
                    { 24, false, 6, "https://picsum.photos/seed/property-6-4/900/600" },
                    { 25, true, 7, "https://picsum.photos/seed/property-7-1/900/600" },
                    { 26, false, 7, "https://picsum.photos/seed/property-7-2/900/600" },
                    { 27, false, 7, "https://picsum.photos/seed/property-7-3/900/600" },
                    { 28, false, 7, "https://picsum.photos/seed/property-7-4/900/600" },
                    { 29, true, 8, "https://picsum.photos/seed/property-8-1/900/600" },
                    { 30, false, 8, "https://picsum.photos/seed/property-8-2/900/600" },
                    { 31, false, 8, "https://picsum.photos/seed/property-8-3/900/600" },
                    { 32, false, 8, "https://picsum.photos/seed/property-8-4/900/600" },
                    { 33, true, 9, "https://picsum.photos/seed/property-9-1/900/600" },
                    { 34, false, 9, "https://picsum.photos/seed/property-9-2/900/600" },
                    { 35, false, 9, "https://picsum.photos/seed/property-9-3/900/600" },
                    { 36, false, 9, "https://picsum.photos/seed/property-9-4/900/600" },
                    { 37, true, 10, "https://picsum.photos/seed/property-10-1/900/600" },
                    { 38, false, 10, "https://picsum.photos/seed/property-10-2/900/600" },
                    { 39, false, 10, "https://picsum.photos/seed/property-10-3/900/600" },
                    { 40, false, 10, "https://picsum.photos/seed/property-10-4/900/600" },
                    { 41, true, 11, "https://picsum.photos/seed/property-11-1/900/600" },
                    { 42, false, 11, "https://picsum.photos/seed/property-11-2/900/600" },
                    { 43, false, 11, "https://picsum.photos/seed/property-11-3/900/600" },
                    { 44, false, 11, "https://picsum.photos/seed/property-11-4/900/600" },
                    { 45, true, 12, "https://picsum.photos/seed/property-12-1/900/600" },
                    { 46, false, 12, "https://picsum.photos/seed/property-12-2/900/600" },
                    { 47, false, 12, "https://picsum.photos/seed/property-12-3/900/600" },
                    { 48, false, 12, "https://picsum.photos/seed/property-12-4/900/600" },
                    { 49, true, 13, "https://picsum.photos/seed/property-13-1/900/600" },
                    { 50, false, 13, "https://picsum.photos/seed/property-13-2/900/600" },
                    { 51, false, 13, "https://picsum.photos/seed/property-13-3/900/600" },
                    { 52, false, 13, "https://picsum.photos/seed/property-13-4/900/600" },
                    { 53, true, 14, "https://picsum.photos/seed/property-14-1/900/600" },
                    { 54, false, 14, "https://picsum.photos/seed/property-14-2/900/600" },
                    { 55, false, 14, "https://picsum.photos/seed/property-14-3/900/600" },
                    { 56, false, 14, "https://picsum.photos/seed/property-14-4/900/600" },
                    { 57, true, 15, "https://picsum.photos/seed/property-15-1/900/600" },
                    { 58, false, 15, "https://picsum.photos/seed/property-15-2/900/600" },
                    { 59, false, 15, "https://picsum.photos/seed/property-15-3/900/600" },
                    { 60, false, 15, "https://picsum.photos/seed/property-15-4/900/600" },
                    { 61, true, 16, "https://picsum.photos/seed/property-16-1/900/600" },
                    { 62, false, 16, "https://picsum.photos/seed/property-16-2/900/600" },
                    { 63, false, 16, "https://picsum.photos/seed/property-16-3/900/600" },
                    { 64, false, 16, "https://picsum.photos/seed/property-16-4/900/600" },
                    { 65, true, 17, "https://picsum.photos/seed/property-17-1/900/600" },
                    { 66, false, 17, "https://picsum.photos/seed/property-17-2/900/600" },
                    { 67, false, 17, "https://picsum.photos/seed/property-17-3/900/600" },
                    { 68, false, 17, "https://picsum.photos/seed/property-17-4/900/600" },
                    { 69, true, 18, "https://picsum.photos/seed/property-18-1/900/600" },
                    { 70, false, 18, "https://picsum.photos/seed/property-18-2/900/600" },
                    { 71, false, 18, "https://picsum.photos/seed/property-18-3/900/600" },
                    { 72, false, 18, "https://picsum.photos/seed/property-18-4/900/600" },
                    { 73, true, 19, "https://picsum.photos/seed/property-19-1/900/600" },
                    { 74, false, 19, "https://picsum.photos/seed/property-19-2/900/600" },
                    { 75, false, 19, "https://picsum.photos/seed/property-19-3/900/600" },
                    { 76, false, 19, "https://picsum.photos/seed/property-19-4/900/600" },
                    { 77, true, 20, "https://picsum.photos/seed/property-20-1/900/600" },
                    { 78, false, 20, "https://picsum.photos/seed/property-20-2/900/600" },
                    { 79, false, 20, "https://picsum.photos/seed/property-20-3/900/600" },
                    { 80, false, 20, "https://picsum.photos/seed/property-20-4/900/600" },
                    { 81, true, 21, "https://picsum.photos/seed/property-21-1/900/600" },
                    { 82, false, 21, "https://picsum.photos/seed/property-21-2/900/600" },
                    { 83, false, 21, "https://picsum.photos/seed/property-21-3/900/600" },
                    { 84, false, 21, "https://picsum.photos/seed/property-21-4/900/600" },
                    { 85, true, 22, "https://picsum.photos/seed/property-22-1/900/600" },
                    { 86, false, 22, "https://picsum.photos/seed/property-22-2/900/600" },
                    { 87, false, 22, "https://picsum.photos/seed/property-22-3/900/600" },
                    { 88, false, 22, "https://picsum.photos/seed/property-22-4/900/600" },
                    { 89, true, 23, "https://picsum.photos/seed/property-23-1/900/600" },
                    { 90, false, 23, "https://picsum.photos/seed/property-23-2/900/600" },
                    { 91, false, 23, "https://picsum.photos/seed/property-23-3/900/600" },
                    { 92, false, 23, "https://picsum.photos/seed/property-23-4/900/600" },
                    { 93, true, 24, "https://picsum.photos/seed/property-24-1/900/600" },
                    { 94, false, 24, "https://picsum.photos/seed/property-24-2/900/600" },
                    { 95, false, 24, "https://picsum.photos/seed/property-24-3/900/600" },
                    { 96, false, 24, "https://picsum.photos/seed/property-24-4/900/600" },
                    { 97, true, 25, "https://picsum.photos/seed/property-25-1/900/600" },
                    { 98, false, 25, "https://picsum.photos/seed/property-25-2/900/600" },
                    { 99, false, 25, "https://picsum.photos/seed/property-25-3/900/600" },
                    { 100, false, 25, "https://picsum.photos/seed/property-25-4/900/600" },
                    { 101, true, 26, "https://picsum.photos/seed/property-26-1/900/600" },
                    { 102, false, 26, "https://picsum.photos/seed/property-26-2/900/600" },
                    { 103, false, 26, "https://picsum.photos/seed/property-26-3/900/600" },
                    { 104, false, 26, "https://picsum.photos/seed/property-26-4/900/600" },
                    { 105, true, 27, "https://picsum.photos/seed/property-27-1/900/600" },
                    { 106, false, 27, "https://picsum.photos/seed/property-27-2/900/600" },
                    { 107, false, 27, "https://picsum.photos/seed/property-27-3/900/600" },
                    { 108, false, 27, "https://picsum.photos/seed/property-27-4/900/600" },
                    { 109, true, 28, "https://picsum.photos/seed/property-28-1/900/600" },
                    { 110, false, 28, "https://picsum.photos/seed/property-28-2/900/600" },
                    { 111, false, 28, "https://picsum.photos/seed/property-28-3/900/600" },
                    { 112, false, 28, "https://picsum.photos/seed/property-28-4/900/600" },
                    { 113, true, 29, "https://picsum.photos/seed/property-29-1/900/600" },
                    { 114, false, 29, "https://picsum.photos/seed/property-29-2/900/600" },
                    { 115, false, 29, "https://picsum.photos/seed/property-29-3/900/600" },
                    { 116, false, 29, "https://picsum.photos/seed/property-29-4/900/600" },
                    { 117, true, 30, "https://picsum.photos/seed/property-30-1/900/600" },
                    { 118, false, 30, "https://picsum.photos/seed/property-30-2/900/600" },
                    { 119, false, 30, "https://picsum.photos/seed/property-30-3/900/600" },
                    { 120, false, 30, "https://picsum.photos/seed/property-30-4/900/600" }
                });

            migrationBuilder.InsertData(
                table: "Questions",
                columns: new[] { "Id", "Content", "CreatedAt", "IsAnswered", "PropertyId", "UserId" },
                values: new object[,]
                {
                    { 1, "Da li su režije uključene u cijenu najma?", new DateTime(2026, 3, 1, 10, 15, 0, 0, DateTimeKind.Utc), true, 1, 2 },
                    { 2, "Da li je dozvoljeno držanje kućnih ljubimaca?", new DateTime(2026, 3, 2, 11, 20, 0, 0, DateTimeKind.Utc), true, 2, 4 },
                    { 3, "Koliki je depozit za ovu nekretninu?", new DateTime(2026, 3, 3, 9, 45, 0, 0, DateTimeKind.Utc), false, 3, 5 },
                    { 4, "Da li stan ima parking mjesto?", new DateTime(2026, 3, 4, 14, 10, 0, 0, DateTimeKind.Utc), true, 4, 6 },
                    { 5, "Da li je internet uključen u cijenu?", new DateTime(2026, 3, 5, 16, 0, 0, 0, DateTimeKind.Utc), false, 5, 7 },
                    { 6, "Može li se nekretnina iznajmiti samo na mjesec dana?", new DateTime(2026, 3, 6, 12, 30, 0, 0, DateTimeKind.Utc), true, 6, 8 },
                    { 7, "Koji je minimalan period najma?", new DateTime(2026, 3, 7, 8, 50, 0, 0, DateTimeKind.Utc), false, 7, 9 },
                    { 8, "Da li je grijanje centralno ili etažno?", new DateTime(2026, 3, 8, 13, 15, 0, 0, DateTimeKind.Utc), true, 8, 10 },
                    { 9, "Postoji li mogućnost razgledanja uživo vikendom?", new DateTime(2026, 3, 9, 10, 40, 0, 0, DateTimeKind.Utc), true, 9, 2 },
                    { 10, "Da li su dozvoljene manje adaptacije u stanu?", new DateTime(2026, 3, 10, 15, 25, 0, 0, DateTimeKind.Utc), false, 10, 4 },
                    { 11, "Ima li zgrada lift?", new DateTime(2026, 3, 11, 9, 5, 0, 0, DateTimeKind.Utc), true, 1, 5 },
                    { 12, "Da li je stan odmah useljiv?", new DateTime(2026, 3, 12, 17, 35, 0, 0, DateTimeKind.Utc), false, 2, 6 },
                    { 13, "Koliko iznose prosječne mjesečne režije?", new DateTime(2026, 3, 13, 11, 55, 0, 0, DateTimeKind.Utc), true, 3, 7 },
                    { 14, "Da li nekretnina ima balkon?", new DateTime(2026, 3, 14, 14, 45, 0, 0, DateTimeKind.Utc), false, 4, 8 },
                    { 15, "Da li je moguće platiti depozit u dvije rate?", new DateTime(2026, 3, 15, 10, 10, 0, 0, DateTimeKind.Utc), true, 5, 9 },
                    { 16, "Da li su studenti poželjni kao zakupci?", new DateTime(2026, 3, 16, 13, 20, 0, 0, DateTimeKind.Utc), false, 6, 10 },
                    { 17, "Da li kuhinja dolazi sa svim aparatima?", new DateTime(2026, 3, 17, 16, 40, 0, 0, DateTimeKind.Utc), true, 7, 2 },
                    { 18, "Može li se rezervisati termin razgledanja za sutra?", new DateTime(2026, 3, 18, 12, 5, 0, 0, DateTimeKind.Utc), false, 8, 4 },
                    { 19, "Da li se uz stan dobija i podrumska ostava?", new DateTime(2026, 3, 19, 9, 30, 0, 0, DateTimeKind.Utc), true, 9, 5 },
                    { 20, "Koliko je udaljena najbliža autobuska stanica?", new DateTime(2026, 3, 20, 18, 10, 0, 0, DateTimeKind.Utc), false, 10, 6 }
                });

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "CreatedAt", "EndDateOfRenting", "IsApproved", "IsMonthly", "PropertyId", "StartDateOfRenting", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 1, null, 4 },
                    { 2, new DateTime(2025, 12, 2, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 2, null, 5 },
                    { 3, new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 3, null, 6 },
                    { 4, new DateTime(2025, 12, 4, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 4, null, 7 },
                    { 5, new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 9, null, 8 },
                    { 6, new DateTime(2025, 12, 6, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 10, null, 9 },
                    { 7, new DateTime(2025, 12, 7, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 16, null, 10 },
                    { 8, new DateTime(2025, 12, 8, 0, 0, 0, 0, DateTimeKind.Utc), null, true, true, 23, null, 2 },
                    { 9, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 2, 15, 0, 0, 0, 0, DateTimeKind.Utc), true, false, 12, new DateTime(2026, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), 5 },
                    { 10, new DateTime(2025, 12, 28, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 10, 0, 0, 0, 0, DateTimeKind.Utc), true, false, 24, new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), 6 }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "Comment", "PropertyId", "StarRate", "UserId" },
                values: new object[,]
                {
                    { 1, "Odlična lokacija i baš čisto. Preporuka!", 1, 5, 4 },
                    { 2, "Ugodan stan, blizu centra. Sve korektno.", 2, 4, 5 },
                    { 3, "Pogled je fantastičan, mirno naselje.", 3, 5, 6 },
                    { 4, "Moderan loft, sve kao na slikama.", 4, 4, 7 },
                    { 5, "Sve ok, ali bi moglo malo bolje održavanje.", 6, 3, 8 },
                    { 6, "Panoramski pogled i top ambijent.", 8, 5, 9 },
                    { 7, "Lijep apartman, blizu rijeke. Ugodno.", 9, 4, 8 },
                    { 8, "Lokacija savršena, pogled na Stari most.", 10, 5, 9 },
                    { 9, "Terasa je odlična, sve uredno i čisto.", 12, 4, 5 },
                    { 10, "Mirno, centralno, domaćin korektan.", 13, 4, 10 },
                    { 11, "Minimalistički, ok za kratki boravak.", 14, 3, 6 },
                    { 12, "Top ugođaj, sve preporuke!", 15, 5, 7 },
                    { 13, "Praktično i blizu svega. Komforno.", 16, 4, 10 },
                    { 14, "Pogled na jezera je predobar. Sve super.", 17, 5, 2 },
                    { 15, "Studio je mali ali uredan i funkcionalan.", 18, 4, 8 },
                    { 16, "Sve ok, ali je bilo malo buke navečer.", 19, 3, 4 },
                    { 17, "Mirno i udobno, dobra vrijednost za novac.", 22, 4, 6 },
                    { 18, "Loft je unikatan i baš udoban.", 23, 5, 2 },
                    { 19, "Super lokacija uz rijeku, sve čisto.", 24, 4, 6 },
                    { 20, "Minimalistički i uredno, preporuka.", 25, 4, 9 },
                    { 21, "Panorama je nevjerovatna. Sve savršeno.", 28, 5, 7 },
                    { 22, "Mirno, ali bi dobro došlo malo više opreme.", 29, 3, 10 },
                    { 23, "Elegantno i uredno, dobra lokacija.", 30, 4, 4 },
                    { 24, "Lokacija dobra, ali higijena može bolje.", 1, 2, 5 },
                    { 25, "Sve ok, ali parkiranje je bilo problem.", 10, 3, 8 }
                });

            migrationBuilder.InsertData(
                table: "Answers",
                columns: new[] { "Id", "Content", "CreatedAt", "QuestionId", "UserId" },
                values: new object[,]
                {
                    { 1, "Režije nisu uključene u cijenu i plaćaju se odvojeno svaki mjesec.", new DateTime(2026, 3, 1, 12, 0, 0, 0, DateTimeKind.Utc), 1, 1 },
                    { 2, "Kućni ljubimci su dozvoljeni uz prethodni dogovor sa vlasnikom.", new DateTime(2026, 3, 2, 13, 10, 0, 0, DateTimeKind.Utc), 2, 1 },
                    { 3, "Da, uz stan dolazi jedno privatno parking mjesto.", new DateTime(2026, 3, 4, 15, 0, 0, 0, DateTimeKind.Utc), 4, 1 },
                    { 4, "Moguće je iznajmiti nekretninu i na period od jednog mjeseca.", new DateTime(2026, 3, 6, 14, 20, 0, 0, DateTimeKind.Utc), 6, 1 },
                    { 5, "Grijanje je centralno i uključeno je u redovne mjesečne troškove.", new DateTime(2026, 3, 8, 15, 45, 0, 0, DateTimeKind.Utc), 8, 1 },
                    { 6, "Da, moguće je zakazati razgledanje i vikendom uz prethodnu rezervaciju termina.", new DateTime(2026, 3, 9, 12, 0, 0, 0, DateTimeKind.Utc), 9, 1 },
                    { 7, "Da, zgrada posjeduje lift koji je redovno održavan.", new DateTime(2026, 3, 11, 11, 30, 0, 0, DateTimeKind.Utc), 11, 1 },
                    { 8, "Prosječne mjesečne režije iznose između 120 KM i 180 KM, zavisno od sezone.", new DateTime(2026, 3, 13, 13, 40, 0, 0, DateTimeKind.Utc), 13, 1 },
                    { 9, "Da, moguće je depozit platiti u dvije rate prema dogovoru.", new DateTime(2026, 3, 15, 12, 25, 0, 0, DateTimeKind.Utc), 15, 1 },
                    { 10, "Da, kuhinja dolazi sa frižiderom, šporetom i mašinom za suđe.", new DateTime(2026, 3, 17, 18, 10, 0, 0, DateTimeKind.Utc), 17, 1 },
                    { 11, "Da, uz stan se dobija i podrumska ostava koja je uključena u cijenu.", new DateTime(2026, 3, 19, 11, 0, 0, 0, DateTimeKind.Utc), 19, 1 }
                });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Comment", "DateToPay", "IsPayed", "MonthNumber", "Name", "PaidAt", "PaymentStatus", "Price", "ReservationId", "StripePaymentIntentId", "WarningDateToPay", "YearNumber" },
                values: new object[,]
                {
                    { 1, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1550.0, 1, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 2, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1550.0, 1, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 3, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1550.0, 1, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 4, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1450.0, 2, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 5, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1450.0, 2, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 6, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1450.0, 2, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 7, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 3, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 8, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 3, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 9, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 3, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 10, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1800.0, 4, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 11, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1800.0, 4, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 12, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1800.0, 4, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 13, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 5, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 14, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 5, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 15, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 5, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 16, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 2000.0, 6, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 17, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 2000.0, 6, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 18, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 2000.0, 6, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 19, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1200.0, 7, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 20, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1200.0, 7, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 21, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1200.0, 7, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 22, "Uplata evidentirana.", new DateTime(2025, 12, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 12, "Mjesečna rata 12.2025", new DateTime(2025, 12, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 8, null, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2025 },
                    { 23, "Uplata evidentirana.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Mjesečna rata 01.2026", new DateTime(2026, 1, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 8, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 24, "Uplata evidentirana.", new DateTime(2026, 2, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Mjesečna rata 02.2026", new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 1650.0, 8, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 25, "Uplata za kratki boravak.", new DateTime(2026, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), true, 2, "Kratki boravak 02.2026", new DateTime(2026, 2, 9, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 420.0, 9, null, new DateTime(2026, 2, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 26, "Uplata za kratki boravak.", new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), true, 1, "Kratki boravak 01.2026", new DateTime(2026, 1, 4, 0, 0, 0, 0, DateTimeKind.Utc), "Paid", 380.0, 10, null, new DateTime(2026, 1, 8, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 27, "Čeka uplatu.", new DateTime(2026, 3, 5, 0, 0, 0, 0, DateTimeKind.Utc), false, 3, "Mjesečna rata 03.2026 (NEPLAĆENO)", null, "Pending", 1550.0, 1, null, new DateTime(2026, 3, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 },
                    { 28, "Čeka uplatu.", new DateTime(2026, 3, 5, 0, 0, 0, 0, DateTimeKind.Utc), false, 3, "Mjesečna rata 03.2026 (NEPLAĆENO)", null, "Pending", 2000.0, 6, null, new DateTime(2026, 3, 12, 0, 0, 0, 0, DateTimeKind.Utc), 2026 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Answers_QuestionId",
                table: "Answers",
                column: "QuestionId");

            migrationBuilder.CreateIndex(
                name: "IX_Answers_UserId",
                table: "Answers",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_PropertyId",
                table: "Appointments",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_UserId",
                table: "Appointments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Favorites_PropertyId",
                table: "Favorites",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Favorites_UserId_PropertyId",
                table: "Favorites",
                columns: new[] { "UserId", "PropertyId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Payments_ReservationId",
                table: "Payments",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_Properties_UserId",
                table: "Properties",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertiesImage_PropertyId",
                table: "PropertiesImage",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_PropertyId",
                table: "Questions",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_UserId",
                table: "Questions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ReservationHistories_ReservationId",
                table: "ReservationHistories",
                column: "ReservationId");

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
                name: "Answers");

            migrationBuilder.DropTable(
                name: "Appointments");

            migrationBuilder.DropTable(
                name: "Favorites");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "PropertiesImage");

            migrationBuilder.DropTable(
                name: "ReservationHistories");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "UserDeviceTokens");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "Questions");

            migrationBuilder.DropTable(
                name: "Reservations");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "Properties");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
