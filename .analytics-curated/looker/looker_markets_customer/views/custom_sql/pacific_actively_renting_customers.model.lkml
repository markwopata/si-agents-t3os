connection: "es_snowflake_analytics"

include: "/views/custom_sql/*.view.lkml"

explore: pacific_actively_renting_customers {}

explore: pacific_monthly_avg_renting_customers {}

explore: historical_market_company_aor_oec {}

explore: historical_actively_renting_customers {}

explore: historical_actively_renting_customers_by_region {}

explore: historical_actively_renting_customers_by_district {}
