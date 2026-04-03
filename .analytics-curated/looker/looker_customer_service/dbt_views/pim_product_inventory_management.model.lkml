connection: "es_snowflake_analytics"

include: "/dbt_views/*.view.lkml"

# Commented out due to low usage on 2026-03-26.
# explore: stg_t3__pim_product_info {
#   label: "PIM - Product Inventory Management"
#
#   join: stg_t3__pim_product_category {
#     relationship: one_to_many
#     sql_on: ${stg_t3__pim_product_info.pim_product_id} = ${stg_t3__pim_product_category.pim_product_id} ;;
#   }
#
#   join: stg_t3__pim_product_group {
#     relationship: one_to_many
#     sql_on: ${stg_t3__pim_product_info.pim_product_id} = ${stg_t3__pim_product_group.pim_product_id} ;;
#   }
#
#   join: stg_t3__pim_product_options {
#     relationship: one_to_many
#     sql_on: ${stg_t3__pim_product_info.pim_product_id} = ${stg_t3__pim_product_options.pim_product_id} ;;
#   }
#
#   join: stg_t3__pim_product_shipping_dimensions {
#     relationship: one_to_many
#     sql_on: ${stg_t3__pim_product_info.pim_product_id} = ${stg_t3__pim_product_shipping_dimensions.pim_product_id} ;;
#   }
#
# }
