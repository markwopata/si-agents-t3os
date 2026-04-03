connection: "es_snowflake_analytics"

include: "/views/custom_sql/qbr_financial.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: qbr_financial{
#   case_sensitive: no
#   group_label: "Fleet QBR"
#   label: "QBR Financial"
# }
