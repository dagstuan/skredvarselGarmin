using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SkredvarselGarminWeb.Migrations
{
    /// <inheritdoc />
    public partial class NextChargeAmount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "next_charge_amount",
                table: "agreements",
                type: "integer",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "next_charge_amount",
                table: "agreements");
        }
    }
}
