connection: "es_snowflake_analytics"

include: "/views/custom_sql/ar_transaction_recon_5000.view.lkml"
include: "/views/custom_sql/rpo_assets_revenue.view.lkml"
include: "/views/custom_sql/bulk_inventory_on_rent.view.lkml"

explore: ar_transaction_recon_5000 {}
explore: rpo_assets_revenue {}
explore: bulk_inventory_on_rent {}
