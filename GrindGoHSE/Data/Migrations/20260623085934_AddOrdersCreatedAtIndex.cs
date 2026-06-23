using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GrindGoHSE.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddOrdersCreatedAtIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_orders_created_at",
                table: "orders",
                column: "created_at");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_orders_created_at",
                table: "orders");
        }
    }
}
