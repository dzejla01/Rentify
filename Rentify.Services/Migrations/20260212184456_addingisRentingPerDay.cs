using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rentify.Services.Migrations
{
    /// <inheritdoc />
    public partial class addingisRentingPerDay : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "urban", "bright", "central", "modern" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "historic", "authentic", "warm" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "view", "calm", "elevated" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "loft", "stylish", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "quiet", "balanced", "comfortable" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "sunny", "warm", "airy" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "compact", "simple", "efficient" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "panorama", "exclusive", "bright" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "river", "relaxing", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "iconic", "view", "historic" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "stone", "traditional", "cool" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "sunny", "terrace", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 13,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "quiet", "central", "comfortable" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "minimal", "clean", "simple" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "warm", "evening", "relaxed" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "central", "balanced", "urban" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "lake", "fresh", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 18,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "quiet", "compact", "simple" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 19,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "modern", "clean", "bright" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 20,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "family", "comfortable", "spacious" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 21,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "sunny", "open", "warm" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 22,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "calm", "balanced", "quiet" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 23,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "loft", "urban", "creative" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 24,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "river", "walkable", "fresh" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 25,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "minimal", "clean", "simple" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 26,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "family", "balanced", "comfortable" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 27,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "bright", "compact", "efficient" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 28,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "panorama", "open", "elevated" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 29,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "quiet", "corner", "calm" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 30,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { true, new List<string> { "elegant", "stylish", "urban" } });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3297));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3300));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 1 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3467));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 2 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3468));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 3 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3469));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3435), "XNkQRGp+2dqdbwNz05fHEajjeI8RvxHME19epSCpfehGjEck9MXDi1jn0j6XeZHYQr991VQDulmnJpX24kucHg==", "5oMAqqQli4s1BkdzX9onmBq/9R6q0jya7qFv8xhTccyH10wxIOnDNJYYoJH8ac15DStwX/j3VqIAjWwszUkiLqGBs9qK63htH2maE8QhWVX+4ampjrXMzqjN2GUDVJSD3HJ+dcVOditi3hd0J+lQhiUowbxd66jQ0UQoM/IEFQw=" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3443), "XNkQRGp+2dqdbwNz05fHEajjeI8RvxHME19epSCpfehGjEck9MXDi1jn0j6XeZHYQr991VQDulmnJpX24kucHg==", "5oMAqqQli4s1BkdzX9onmBq/9R6q0jya7qFv8xhTccyH10wxIOnDNJYYoJH8ac15DStwX/j3VqIAjWwszUkiLqGBs9qK63htH2maE8QhWVX+4ampjrXMzqjN2GUDVJSD3HJ+dcVOditi3hd0J+lQhiUowbxd66jQ0UQoM/IEFQw=" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 2, 12, 18, 44, 55, 787, DateTimeKind.Utc).AddTicks(3445), "XNkQRGp+2dqdbwNz05fHEajjeI8RvxHME19epSCpfehGjEck9MXDi1jn0j6XeZHYQr991VQDulmnJpX24kucHg==", "5oMAqqQli4s1BkdzX9onmBq/9R6q0jya7qFv8xhTccyH10wxIOnDNJYYoJH8ac15DStwX/j3VqIAjWwszUkiLqGBs9qK63htH2maE8QhWVX+4ampjrXMzqjN2GUDVJSD3HJ+dcVOditi3hd0J+lQhiUowbxd66jQ0UQoM/IEFQw=" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "urban", "bright", "central", "modern" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "historic", "authentic", "warm" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "view", "calm", "elevated" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "loft", "stylish", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "quiet", "balanced", "comfortable" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "sunny", "warm", "airy" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "compact", "simple", "efficient" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "panorama", "exclusive", "bright" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "river", "relaxing", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "iconic", "view", "historic" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "stone", "traditional", "cool" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "sunny", "terrace", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 13,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "quiet", "central", "comfortable" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "minimal", "clean", "simple" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "warm", "evening", "relaxed" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "central", "balanced", "urban" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "lake", "fresh", "open" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 18,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "quiet", "compact", "simple" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 19,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "modern", "clean", "bright" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 20,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "family", "comfortable", "spacious" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 21,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "sunny", "open", "warm" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 22,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "calm", "balanced", "quiet" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 23,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "loft", "urban", "creative" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 24,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "river", "walkable", "fresh" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 25,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "minimal", "clean", "simple" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 26,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "family", "balanced", "comfortable" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 27,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "bright", "compact", "efficient" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 28,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "panorama", "open", "elevated" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 29,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "quiet", "corner", "calm" } });

            migrationBuilder.UpdateData(
                table: "Properties",
                keyColumn: "Id",
                keyValue: 30,
                columns: new[] { "IsRentingPerDay", "Tags" },
                values: new object[] { false, new List<string> { "elegant", "stylish", "urban" } });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(163));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(166));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 1 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(380));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1, 2 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(381));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 2, 3 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(382));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(346), "Z4wbTY1vtyCVj8ZHkrGzHZgV71fPjStP5JaQhazVHIcLdBclaEu3l2boMA4sbFWvPhnhjV6jUr852XM07SNnhQ==", "9x+2HucsLx7FOQxfAqWJmxM+rRd7K0yqLucwHGAekMxMRt0i4zj5rTocSmlSJBGQ/IqpOyAUyXb8LyPnbL65CjwBV742F/ODn2XoznYp6E+RyxsVUi1rNLfHyXOO33SNF7f7cuLRx9dlzIolBs/dHIdmhlc2B44n1Zk5Ss/53K0=" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(354), "Z4wbTY1vtyCVj8ZHkrGzHZgV71fPjStP5JaQhazVHIcLdBclaEu3l2boMA4sbFWvPhnhjV6jUr852XM07SNnhQ==", "9x+2HucsLx7FOQxfAqWJmxM+rRd7K0yqLucwHGAekMxMRt0i4zj5rTocSmlSJBGQ/IqpOyAUyXb8LyPnbL65CjwBV742F/ODn2XoznYp6E+RyxsVUi1rNLfHyXOO33SNF7f7cuLRx9dlzIolBs/dHIdmhlc2B44n1Zk5Ss/53K0=" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2026, 2, 12, 17, 43, 26, 216, DateTimeKind.Utc).AddTicks(357), "Z4wbTY1vtyCVj8ZHkrGzHZgV71fPjStP5JaQhazVHIcLdBclaEu3l2boMA4sbFWvPhnhjV6jUr852XM07SNnhQ==", "9x+2HucsLx7FOQxfAqWJmxM+rRd7K0yqLucwHGAekMxMRt0i4zj5rTocSmlSJBGQ/IqpOyAUyXb8LyPnbL65CjwBV742F/ODn2XoznYp6E+RyxsVUi1rNLfHyXOO33SNF7f7cuLRx9dlzIolBs/dHIdmhlc2B44n1Zk5Ss/53K0=" });
        }
    }
}
