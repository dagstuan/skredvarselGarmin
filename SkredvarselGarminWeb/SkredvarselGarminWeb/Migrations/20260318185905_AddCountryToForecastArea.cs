using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SkredvarselGarminWeb.Migrations
{
    /// <inheritdoc />
    public partial class AddCountryToForecastArea : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "country",
                table: "forecast_areas",
                type: "text",
                nullable: false,
                defaultValue: "NO");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "country",
                table: "forecast_areas");
        }
    }
}
