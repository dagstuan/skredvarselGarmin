﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using NetTopologySuite.Geometries;
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
                .HasAnnotation("ProductVersion", "8.0.3")
                .HasAnnotation("Relational:MaxIdentifierLength", 63);

            NpgsqlModelBuilderExtensions.HasPostgresExtension(modelBuilder, "postgis");
            NpgsqlModelBuilderExtensions.UseIdentityByDefaultColumns(modelBuilder);

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.Agreement", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("text")
                        .HasColumnName("id");

                    b.Property<Guid?>("CallbackId")
                        .HasColumnType("uuid")
                        .HasColumnName("callback_id");

                    b.Property<string>("ConfirmationUrl")
                        .HasColumnType("text")
                        .HasColumnName("confirmation_url");

                    b.Property<DateTime>("Created")
                        .HasColumnType("timestamp with time zone")
                        .HasColumnName("created");

                    b.Property<int?>("NextChargeAmount")
                        .HasColumnType("integer")
                        .HasColumnName("next_charge_amount");

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
                        .HasColumnType("text")
                        .HasColumnName("user_id");

                    b.HasKey("Id")
                        .HasName("pk_agreements");

                    b.HasIndex("UserId")
                        .HasDatabaseName("ix_agreements_user_id");

                    b.ToTable("agreements", (string)null);
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.ForecastArea", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("integer")
                        .HasColumnName("id");

                    NpgsqlPropertyBuilderExtensions.UseIdentityByDefaultColumn(b.Property<int>("Id"));

                    b.Property<Polygon>("Area")
                        .IsRequired()
                        .HasColumnType("geometry (polygon, 25833)")
                        .HasColumnName("area");

                    b.Property<string>("Name")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("name");

                    b.Property<char>("RegionType")
                        .HasColumnType("character(1)")
                        .HasColumnName("region_type");

                    b.HasKey("Id")
                        .HasName("pk_forecast_areas");

                    b.ToTable("forecast_areas", (string)null);
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.StripeSubscription", b =>
                {
                    b.Property<string>("SubscriptionId")
                        .HasColumnType("text")
                        .HasColumnName("subscription_id");

                    b.Property<DateTime>("Created")
                        .HasColumnType("timestamp with time zone")
                        .HasColumnName("created");

                    b.Property<DateOnly?>("NextChargeDate")
                        .HasColumnType("date")
                        .HasColumnName("next_charge_date");

                    b.Property<int>("Status")
                        .HasColumnType("integer")
                        .HasColumnName("status");

                    b.Property<string>("UserId")
                        .IsRequired()
                        .HasColumnType("text")
                        .HasColumnName("user_id");

                    b.HasKey("SubscriptionId")
                        .HasName("pk_stripe_subscriptions");

                    b.HasIndex("UserId")
                        .HasDatabaseName("ix_stripe_subscriptions_user_id");

                    b.ToTable("stripe_subscriptions", (string)null);
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

                    b.Property<DateOnly>("LastLoggedIn")
                        .HasColumnType("date")
                        .HasColumnName("last_logged_in");

                    b.Property<string>("Name")
                        .HasColumnType("text")
                        .HasColumnName("name");

                    b.Property<string>("StripeCustomerId")
                        .HasColumnType("text")
                        .HasColumnName("stripe_customer_id");

                    b.HasKey("Id")
                        .HasName("pk_users");

                    b.HasIndex("StripeCustomerId")
                        .IsUnique()
                        .HasDatabaseName("ix_users_stripe_customer_id");

                    NpgsqlIndexBuilderExtensions.AreNullsDistinct(b.HasIndex("StripeCustomerId"), true);

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
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_agreements_users_user_id");

                    b.Navigation("User");
                });

            modelBuilder.Entity("SkredvarselGarminWeb.Entities.StripeSubscription", b =>
                {
                    b.HasOne("SkredvarselGarminWeb.Entities.User", "User")
                        .WithMany("StripeSubscriptions")
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.Restrict)
                        .IsRequired()
                        .HasConstraintName("fk_stripe_subscriptions_users_user_id");

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

                    b.Navigation("StripeSubscriptions");

                    b.Navigation("Watches");
                });
#pragma warning restore 612, 618
        }
    }
}
