connection: "es_snowflake"

include: "*.view.lkml"

explore: bulk_revenue {
  from: bulk_revenue
}
