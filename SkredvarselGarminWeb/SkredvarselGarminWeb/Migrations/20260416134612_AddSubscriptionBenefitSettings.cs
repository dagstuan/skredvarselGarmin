using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SkredvarselGarminWeb.Migrations
{
    /// <inheritdoc />
    public partial class AddSubscriptionSettings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "subscription_settings",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false),
                    former_subscriber_extra_months = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_subscription_settings", x => x.id);
                });

            migrationBuilder.InsertData(
                table: "subscription_settings",
                columns: ["id", "former_subscriber_extra_months"],
                values: [1, 0]);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "subscription_settings");
        }
    }
}
