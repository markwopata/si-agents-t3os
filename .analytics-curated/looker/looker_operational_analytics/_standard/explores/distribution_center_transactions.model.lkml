connection: "es_snowflake_analytics"

include: "/_standard/custom_sql/distribution_center_transactions.view.lkml"

explore: distribution_center_transactions {
  label: "dc_transactions"
}
