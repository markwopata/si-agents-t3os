connection: "es_snowflake_analytics"

include: "./*.view.lkml"

# Commented out due to low usage on 2026-03-26
# explore: low_len_id_asset_list {
#   group_label: "Fleet"
#   label: "Low-Length ID Asset List"
#   case_sensitive: no
# }
