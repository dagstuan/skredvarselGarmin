using System;

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SkredvarselGarminWeb.Migrations
{
    /// <inheritdoc />
    public partial class AddStripeSubscription : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "stripe_customer_id",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "stripe_subscriptions",
                columns: table => new
                {
                    subscription_id = table.Column<string>(type: "text", nullable: false),
                    created = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    status = table.Column<int>(type: "integer", nullable: false),
                    next_charge_date = table.Column<DateOnly>(type: "date", nullable: true),
                    user_id = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_stripe_subscriptions", x => x.subscription_id);
                    table.ForeignKey(
                        name: "fk_stripe_subscriptions_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "ix_users_stripe_customer_id",
                table: "users",
                column: "stripe_customer_id",
                unique: true)
                .Annotation("Npgsql:NullsDistinct", true);

            migrationBuilder.CreateIndex(
                name: "ix_stripe_subscriptions_user_id",
                table: "stripe_subscriptions",
                column: "user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "stripe_subscriptions");

            migrationBuilder.DropIndex(
                name: "ix_users_stripe_customer_id",
                table: "users");

            migrationBuilder.DropColumn(
                name: "stripe_customer_id",
                table: "users");
        }
    }
}
