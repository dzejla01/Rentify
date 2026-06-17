using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rentify.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddAppointmentHistory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 1,
                column: "Tags",
                value: new List<string> { "sarajevo", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 2,
                column: "Tags",
                value: new List<string> { "mostar", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 3,
                column: "Tags",
                value: new List<string> { "tuzla", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 4,
                column: "Tags",
                value: new List<string> { "banja luka", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 5,
                column: "Tags",
                value: new List<string> { "zenica", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 6,
                column: "Tags",
                value: new List<string> { "bihać", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 7,
                column: "Tags",
                value: new List<string> { "sarajevo", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 8,
                column: "Tags",
                value: new List<string> { "mostar", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 9,
                column: "Tags",
                value: new List<string> { "tuzla", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 10,
                column: "Tags",
                value: new List<string> { "banja luka", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 11,
                column: "Tags",
                value: new List<string> { "mostar", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 12,
                column: "Tags",
                value: new List<string> { "tuzla", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 13,
                column: "Tags",
                value: new List<string> { "banja luka", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 14,
                column: "Tags",
                value: new List<string> { "zenica", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 15,
                column: "Tags",
                value: new List<string> { "tuzla", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 16,
                column: "Tags",
                value: new List<string> { "banja luka", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 17,
                column: "Tags",
                value: new List<string> { "zenica", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 18,
                column: "Tags",
                value: new List<string> { "bihać", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 19,
                column: "Tags",
                value: new List<string> { "banja luka", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 20,
                column: "Tags",
                value: new List<string> { "zenica", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 21,
                column: "Tags",
                value: new List<string> { "bihać", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 22,
                column: "Tags",
                value: new List<string> { "sarajevo", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 23,
                column: "Tags",
                value: new List<string> { "zenica", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 24,
                column: "Tags",
                value: new List<string> { "bihać", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 25,
                column: "Tags",
                value: new List<string> { "sarajevo", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 26,
                column: "Tags",
                value: new List<string> { "mostar", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 27,
                column: "Tags",
                value: new List<string> { "bihać", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 28,
                column: "Tags",
                value: new List<string> { "sarajevo", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 29,
                column: "Tags",
                value: new List<string> { "mostar", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 30,
                column: "Tags",
                value: new List<string> { "tuzla", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 31,
                column: "Tags",
                value: new List<string> { "sarajevo", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 32,
                column: "Tags",
                value: new List<string> { "mostar", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 33,
                column: "Tags",
                value: new List<string> { "tuzla", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 34,
                column: "Tags",
                value: new List<string> { "banja luka", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 35,
                column: "Tags",
                value: new List<string> { "mostar", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 36,
                column: "Tags",
                value: new List<string> { "tuzla", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 37,
                column: "Tags",
                value: new List<string> { "banja luka", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 38,
                column: "Tags",
                value: new List<string> { "zenica", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 39,
                column: "Tags",
                value: new List<string> { "tuzla", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 40,
                column: "Tags",
                value: new List<string> { "banja luka", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 41,
                column: "Tags",
                value: new List<string> { "zenica", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 42,
                column: "Tags",
                value: new List<string> { "bihać", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 43,
                column: "Tags",
                value: new List<string> { "banja luka", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 44,
                column: "Tags",
                value: new List<string> { "zenica", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 45,
                column: "Tags",
                value: new List<string> { "bihać", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 46,
                column: "Tags",
                value: new List<string> { "sarajevo", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 1 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3148));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 2 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3153));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 3 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3153));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 4 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3154));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 5 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3155));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 6 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3155));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 7 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3155));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 8 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3156));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 9 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3156));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 10 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3157));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 11 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3157));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 12 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3201));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 13 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3202));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 14 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3202));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 15 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3203));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 16 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3203));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 17 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3204));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 18 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3204));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 19 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3205));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 20 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3205));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 21 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3205));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 22 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3206));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 23 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3206));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 24 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3207));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 25 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3207));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 26 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3207));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 27 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3208));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 28 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3208));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 29 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3209));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 30 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3209));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 31 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3209));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 32 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3210));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 33 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3210));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 34 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3211));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 35 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3211));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 36 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3212));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 37 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3212));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 38 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3212));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 39 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3213));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 40 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3213));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 41 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3214));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 42 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3214));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 43 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3214));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 44 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3215));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 45 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3215));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 46 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3216));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 47 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3216));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 48 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3216));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 49 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3217));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 50 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3217));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 51 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3218));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 52 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3218));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 53 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3218));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 54 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3219));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 55 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3219));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 56 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3220));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 57 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3220));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 58 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3221));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 59 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3221));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 60 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3221));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 61 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3222));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 62 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3222));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 63 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3223));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 64 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3223));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 65 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3223));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 66 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3224));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 67 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3224));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 68 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3225));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 69 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3225));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 70 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3225));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 71 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3226));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 72 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3226));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 73 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3227));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 74 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3227));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 75 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3227));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 76 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3228));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 77 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3228));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 78 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3229));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 79 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3229));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 80 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3229));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 81 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3231));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 82 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3232));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 83 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3232));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 84 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3233));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 85 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3233));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 86 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3233));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 87 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3234));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 88 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3234));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 89 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3234));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 90 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3235));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 91 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3235));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 92 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3236));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 93 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3236));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 94 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3236));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 95 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3237));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 96 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3237));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 97 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3238));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 98 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3238));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 99 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3238));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 100 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3239));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 101 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3239));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 102 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3240));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 103 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3240));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 104 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3240));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 105 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3241));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 106 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3241));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 107 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3242));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 108 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3242));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 109 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3242));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 110 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3243));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 111 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(3243));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(338), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(408), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(674), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(791), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(808), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(824), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(837), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(853), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(932), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(983), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(999), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1013), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 13,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1026), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1039), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1071), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1140), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1206), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 18,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1224), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 19,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1239), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 20,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1252), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 21,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1265), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 22,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1312), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 23,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1324), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 24,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1337), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 25,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1350), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 26,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1363), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 27,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1383), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 28,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1403), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 29,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1454), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 30,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1468), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 31,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1487), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 32,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1501), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 33,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1514), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 34,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1527), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 35,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1539), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 36,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1586), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 37,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1599), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 38,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1622), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 39,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1636), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 40,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1681), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 41,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1694), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 42,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1707), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 43,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1721), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 44,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1735), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 45,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1749), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 46,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1761), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 47,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1775), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 48,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1819), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 49,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1832), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 50,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1844), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 51,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1857), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 52,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1870), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 53,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1883), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 54,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1895), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 55,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1931), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 56,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1944), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 57,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1957), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 58,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1970), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 59,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1984), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 60,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(1997), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 61,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2010), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 62,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2066), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 63,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2080), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 64,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2092), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 65,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2105), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 66,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2120), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 67,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2133), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 68,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2147), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 69,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2205), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 70,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2218), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 71,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2231), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 72,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2244), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 73,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2257), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 74,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2269), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 75,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2283), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 76,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2330), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 77,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2344), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 78,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2356), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 79,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2369), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 80,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2382), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 81,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2395), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 82,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2407), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 83,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2453), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 84,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2467), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 85,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2480), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 86,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2492), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 87,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2504), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 88,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2516), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 89,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2529), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 90,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2590), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 91,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2636), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 92,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2650), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 93,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2663), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 94,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2675), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 95,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2687), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 96,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2701), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 97,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2714), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 98,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2758), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 99,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2771), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 100,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2784), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 101,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2796), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 102,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2809), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 103,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2822), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 104,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2833), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 105,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2846), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 106,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2881), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 107,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2894), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 108,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2906), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 109,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2921), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 110,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2934), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 111,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 35, 33, 525, DateTimeKind.Utc).AddTicks(2947), "oCKI5j7itUKfmLck5IU474mZld7gWNfPBc3C1+M0ei4=", "PANM2r3hkNaJ1LBSHGKsKA==" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 1,
                column: "Tags",
                value: new List<string> { "sarajevo", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 2,
                column: "Tags",
                value: new List<string> { "mostar", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 3,
                column: "Tags",
                value: new List<string> { "tuzla", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 4,
                column: "Tags",
                value: new List<string> { "banja luka", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 5,
                column: "Tags",
                value: new List<string> { "zenica", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 6,
                column: "Tags",
                value: new List<string> { "bihać", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 7,
                column: "Tags",
                value: new List<string> { "sarajevo", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 8,
                column: "Tags",
                value: new List<string> { "mostar", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 9,
                column: "Tags",
                value: new List<string> { "tuzla", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 10,
                column: "Tags",
                value: new List<string> { "banja luka", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 11,
                column: "Tags",
                value: new List<string> { "mostar", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 12,
                column: "Tags",
                value: new List<string> { "tuzla", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 13,
                column: "Tags",
                value: new List<string> { "banja luka", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 14,
                column: "Tags",
                value: new List<string> { "zenica", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 15,
                column: "Tags",
                value: new List<string> { "tuzla", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 16,
                column: "Tags",
                value: new List<string> { "banja luka", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 17,
                column: "Tags",
                value: new List<string> { "zenica", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 18,
                column: "Tags",
                value: new List<string> { "bihać", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 19,
                column: "Tags",
                value: new List<string> { "banja luka", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 20,
                column: "Tags",
                value: new List<string> { "zenica", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 21,
                column: "Tags",
                value: new List<string> { "bihać", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 22,
                column: "Tags",
                value: new List<string> { "sarajevo", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 23,
                column: "Tags",
                value: new List<string> { "zenica", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 24,
                column: "Tags",
                value: new List<string> { "bihać", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 25,
                column: "Tags",
                value: new List<string> { "sarajevo", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 26,
                column: "Tags",
                value: new List<string> { "mostar", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 27,
                column: "Tags",
                value: new List<string> { "bihać", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 28,
                column: "Tags",
                value: new List<string> { "sarajevo", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 29,
                column: "Tags",
                value: new List<string> { "mostar", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 30,
                column: "Tags",
                value: new List<string> { "tuzla", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 31,
                column: "Tags",
                value: new List<string> { "sarajevo", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 32,
                column: "Tags",
                value: new List<string> { "mostar", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 33,
                column: "Tags",
                value: new List<string> { "tuzla", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 34,
                column: "Tags",
                value: new List<string> { "banja luka", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 35,
                column: "Tags",
                value: new List<string> { "mostar", "quiet", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 36,
                column: "Tags",
                value: new List<string> { "tuzla", "elegant", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 37,
                column: "Tags",
                value: new List<string> { "banja luka", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 38,
                column: "Tags",
                value: new List<string> { "zenica", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 39,
                column: "Tags",
                value: new List<string> { "tuzla", "panorama", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 40,
                column: "Tags",
                value: new List<string> { "banja luka", "comfort", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 41,
                column: "Tags",
                value: new List<string> { "zenica", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 42,
                column: "Tags",
                value: new List<string> { "bihać", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 43,
                column: "Tags",
                value: new List<string> { "banja luka", "bright", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 44,
                column: "Tags",
                value: new List<string> { "zenica", "green", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 45,
                column: "Tags",
                value: new List<string> { "bihać", "stylish", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 46,
                column: "Tags",
                value: new List<string> { "sarajevo", "modern", "modern", "comfortable" });

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 1 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1154));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 2 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1156));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 3 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1156));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 4 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1158));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 5 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1159));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 6 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1161));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 7 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1162));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 8 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1165));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 9 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1165));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 10 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1166));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 11 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1167));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 12 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1167));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 13 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1168));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 14 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1169));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 15 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1172));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 16 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1173));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 17 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1173));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 18 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1174));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 19 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1174));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 20 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1175));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 21 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1175));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 22 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1177));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 23 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1177));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 24 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1178));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 25 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1179));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 26 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1180));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 27 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1181));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 28 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1182));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 29 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1182));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 30 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1183));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 31 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1183));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 32 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1183));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 33 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1184));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 34 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1184));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 35 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1185));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 36 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1185));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 37 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1186));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 38 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1186));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 39 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1186));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 40 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1187));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 41 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1187));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 42 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1188));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 43 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1188));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 44 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1188));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 45 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1189));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 46 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1189));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 47 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1190));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 48 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1190));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 49 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1190));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 50 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1191));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 51 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1191));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 52 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1191));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 53 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1192));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 54 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1192));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 55 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1193));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 56 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1193));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 57 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1193));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 58 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1194));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 59 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1194));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 60 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1195));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 61 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1238));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 62 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1241));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 63 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1242));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 64 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1242));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 65 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1243));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 66 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1243));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 67 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1243));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 68 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1244));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 69 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1244));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 70 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1245));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 71 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1245));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 72 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1245));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 73 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1246));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 74 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1246));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 75 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1247));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 76 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1247));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 77 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1247));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 78 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1248));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 79 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1248));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 80 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1249));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 81 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1249));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 82 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1249));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 83 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1250));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 84 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1250));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 85 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1251));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 86 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1251));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 87 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1251));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 88 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1252));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 89 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1252));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 90 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1252));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 91 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1253));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 92 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1253));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 93 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1254));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 94 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1254));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 95 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1255));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 96 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1255));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 97 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1255));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 98 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1256));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 99 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1256));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 100 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1257));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 101 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1257));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 102 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1257));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 103 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1258));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 104 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1258));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 105 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1258));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 106 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1259));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 107 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1259));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 108 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1260));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 109 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1260));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 110 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1260));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 111 },
                column: "DateAssigned",
                value: new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1261));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8023), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8052), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8232), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8324), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8473), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8492), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8506), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8525), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8539), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8605), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8697), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8713), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 13,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8732), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8746), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8761), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8776), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8826), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 18,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8907), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 19,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8925), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 20,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8941), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 21,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8954), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 22,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8968), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 23,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(8981), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 24,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9079), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 25,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9096), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 26,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9111), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 27,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9124), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 28,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9380), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 29,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9457), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 30,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9480), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 31,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9505), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 32,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9611), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 33,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9625), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 34,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9639), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 35,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9651), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 36,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9662), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 37,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9674), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 38,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9748), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 39,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9761), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 40,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9771), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 41,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9782), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 42,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9793), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 43,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9837), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 44,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9848), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 45,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9859), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 46,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9870), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 47,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9882), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 48,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9892), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 49,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9903), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 50,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9981), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 51,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 542, DateTimeKind.Utc).AddTicks(9993), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 52,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(3), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 53,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(14), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 54,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(24), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 55,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(34), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 56,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(44), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 57,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(118), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 58,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(129), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 59,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(140), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 60,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(150), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 61,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(160), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 62,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(172), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 63,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(181), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 64,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(191), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 65,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(239), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 66,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(251), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 67,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(262), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 68,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(273), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 69,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(284), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 70,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(294), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 71,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(339), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 72,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(350), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 73,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(361), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 74,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(371), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 75,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(382), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 76,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(392), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 77,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(402), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 78,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(413), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 79,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(480), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 80,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(491), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 81,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(501), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 82,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(511), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 83,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(521), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 84,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(532), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 85,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(542), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 86,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(597), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 87,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(607), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 88,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(616), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 89,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(626), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 90,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(695), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 91,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(706), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 92,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(718), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 93,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(730), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 94,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(768), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 95,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(778), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 96,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(789), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 97,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(800), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 98,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(810), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 99,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(820), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 100,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(829), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 101,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(901), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 102,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(913), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 103,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(923), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 104,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(933), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 105,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(944), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 106,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(955), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 107,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(964), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 108,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1038), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 109,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1050), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 110,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1062), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 111,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 6, 16, 17, 24, 11, 543, DateTimeKind.Utc).AddTicks(1072), "UXKZ10h2MyZJYGRErtk7Yqv7pIYng3ytkGhF7b718Sg=", "Z0h3HWKfNho1pZ5VTWsuKw==" });
        }
    }
}
