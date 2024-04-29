using System;

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SkredvarselGarminWeb.Migrations
{
    /// <inheritdoc />
    public partial class Watch : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "watch_add_requests",
                columns: table => new
                {
                    watch_id = table.Column<string>(type: "text", nullable: false),
                    part_number = table.Column<string>(type: "text", nullable: false),
                    key = table.Column<string>(type: "text", nullable: false),
                    created = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_watch_add_requests", x => x.watch_id);
                });

            migrationBuilder.CreateTable(
                name: "watches",
                columns: table => new
                {
                    id = table.Column<string>(type: "text", nullable: false),
                    part_number = table.Column<string>(type: "text", nullable: false),
                    user_id = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_watches", x => x.id);
                    table.ForeignKey(
                        name: "fk_watches_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "ix_watches_user_id",
                table: "watches",
                column: "user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "watch_add_requests");

            migrationBuilder.DropTable(
                name: "watches");
        }
    }
}
