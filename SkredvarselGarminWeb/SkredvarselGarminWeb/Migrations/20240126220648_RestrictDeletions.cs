using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SkredvarselGarminWeb.Migrations
{
    /// <inheritdoc />
    public partial class RestrictDeletions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_agreements_users_user_id",
                table: "agreements");

            migrationBuilder.DropForeignKey(
                name: "fk_stripe_subscriptions_users_user_id",
                table: "stripe_subscriptions");

            migrationBuilder.AddForeignKey(
                name: "fk_agreements_users_user_id",
                table: "agreements",
                column: "user_id",
                principalTable: "users",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "fk_stripe_subscriptions_users_user_id",
                table: "stripe_subscriptions",
                column: "user_id",
                principalTable: "users",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_agreements_users_user_id",
                table: "agreements");

            migrationBuilder.DropForeignKey(
                name: "fk_stripe_subscriptions_users_user_id",
                table: "stripe_subscriptions");

            migrationBuilder.AddForeignKey(
                name: "fk_agreements_users_user_id",
                table: "agreements",
                column: "user_id",
                principalTable: "users",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "fk_stripe_subscriptions_users_user_id",
                table: "stripe_subscriptions",
                column: "user_id",
                principalTable: "users",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
