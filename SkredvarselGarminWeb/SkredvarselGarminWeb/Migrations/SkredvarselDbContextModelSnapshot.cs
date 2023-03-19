﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;
using SkredvarselGarminWeb.Database;

#nullable disable

namespace SkredvarselGarminWeb.Migrations
{
    [DbContext(typeof(SkredvarselDbContext))]
    partial class SkredvarselDbContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "7.0.3")
                .HasAnnotation("Relational:MaxIdentifierLength", 63);

            NpgsqlModelBuilderExtensions.UseIdentityByDefaultColumns(modelBuilder);

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.Agreement", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("text")
                        .HasColumnName("id");

                    b.Property<string>("ConfirmationUrl")
                        .HasColumnType("text")
                        .HasColumnName("confirmation_url");

                    b.Property<DateTime>("Created")
                        .HasColumnType("timestamp with time zone")
                        .HasColumnName("created");

                    b.Property<DateOnly?>("NextChargeDate")
                        .HasColumnType("date")
                        .HasColumnName("next_charge_date");

                    b.Property<string>("NextChargeId")
                        .HasColumnType("text")
                        .HasColumnName("next_charge_id");

                    b.Property<DateOnly>("Start")
                        .HasColumnType("date")
                        .HasColumnName("start");

                    b.Property<int>("Status")
                        .HasColumnType("integer")
                        .HasColumnName("status");

                    b.Property<string>("UserId")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("user_id");

                    b.HasKey("Id")
                        .HasName("pk_agreements");

                    b.HasIndex("UserId")
                        .HasDatabaseName("ix_agreements_user_id");

                    b.ToTable("agreements", (string)null);
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.User", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("text")
                        .HasColumnName("id");

                    b.Property<DateOnly>("CreatedDate")
                        .HasColumnType("date")
                        .HasColumnName("created_date");

                    b.Property<string>("Email")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("email");

                    b.Property<string>("Name")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("name");

                    b.Property<string>("PhoneNumber")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("phone_number");

                    b.HasKey("Id")
                        .HasName("pk_users");

                    b.ToTable("users", (string)null);
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.Watch", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("text")
                        .HasColumnName("id");

                    b.Property<string>("PartNumber")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("part_number");

                    b.Property<string>("UserId")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("user_id");

                    b.HasKey("Id")
                        .HasName("pk_watches");

                    b.HasIndex("UserId")
                        .HasDatabaseName("ix_watches_user_id");

                    b.ToTable("watches", (string)null);
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.WatchAddRequest", b =>
                {
                    b.Property<string>("WatchId")
                        .HasColumnType("text")
                        .HasColumnName("watch_id");

                    b.Property<DateTime>("Created")
                        .HasColumnType("timestamp with time zone")
                        .HasColumnName("created");

                    b.Property<string>("Key")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("key");

                    b.Property<string>("PartNumber")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("part_number");

                    b.HasKey("WatchId")
                        .HasName("pk_watch_add_requests");

                    b.ToTable("watch_add_requests", (string)null);
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.Agreement", b =>
                {
                    b.HasOne("SkredvarselGarminWeb.Entities.User", "User")
                        .WithMany("Agreements")
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired()
                        .HasConstraintName("fk_agreements_users_user_id");

                    b.Navigation("User");
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.Watch", b =>
                {
                    b.HasOne("SkredvarselGarminWeb.Entities.User", "User")
                        .WithMany("Watches")
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired()
                        .HasConstraintName("fk_watches_users_user_id");

                    b.Navigation("User");
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.User", b =>
                {
                    b.Navigation("Agreements");

                    b.Navigation("Watches");
                });
#pragma warning restore 612, 618
        }
    }
}
