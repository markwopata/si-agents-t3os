view: net_price {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."NET_PRICE" ;;

  dimension: deleted_date {
    type: date
    sql: ${TABLE}."DELETED_DATE" ;;
  }
#   dimension: description {
#     type: string
#     sql: ${TABLE}."DESCRIPTION" ;;
#   }
  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }
  # dimension: item_id {
  #   type: string
  #   sql: ${TABLE}."ITEM_ID" ;;
  # }
  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
  }
  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE" ;;
  }
  dimension: calculated_list_price { ## added for inclusion in the ecommerce/t3 comparison DB
    type: number
    sql: case
          when ${TABLE}."MSRP" <= 2.99 then round(${TABLE}."MSRP" * 1.5,2)
           when ${TABLE}."MSRP" <= 9.99 then round(${TABLE}."MSRP" * 1.4,2)
           when ${TABLE}."MSRP" <= 14.99 then round(${TABLE}."MSRP" * 1.3,2)
           when ${TABLE}."MSRP" <= 49.99 then round(${TABLE}."MSRP" * 1.2,2)
           when ${TABLE}."MSRP" <= 999.99 then round(${TABLE}."MSRP" * 1.12,2)
           else ${TABLE}."MSRP"
           end ;;
  }
  parameter: cost_plus_percent {
    type: number
  }
  dimension: cost_plus_price {
    type: number
    value_format: "0.##"
    sql: ${net_price}* (1 + {% parameter cost_plus_percent %}) ;;
  }
  # dimension: part_description {
  #   type: string
  #   sql: ${TABLE}."PART_DESCRIPTION" ;;
  # }
  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  # dimension: part_number {
  #   type: string
  #   sql: ${TABLE}."PART_NUMBER" ;;
  # }
  # dimension: product_dimensions {
  #   type: string
  #   sql: ${TABLE}."PRODUCT_DIMENSIONS" ;;
  # }
  # dimension: provider_id {
  #   type: string
  #   sql: ${TABLE}."PROVIDER_ID" ;;
  #   value_format_name: id
  # }
  # dimension: provider_name {
  #   type: string
  #   sql: ${TABLE}."PROVIDER_NAME" ;;
  # }
  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }
  # dimension: unit_of_measure {
  #   type: string
  #   sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  # }
  dimension: updated_date {
    type: date
    sql: ${TABLE}."UPDATED_DATE" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  # dimension: vendor_name {
  #   type: string
  #   sql: ${TABLE}."VENDOR_NAME" ;;
  # }
  # dimension: weight {
  #   type: string
  #   sql: ${TABLE}."WEIGHT" ;;
  # }
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: CONCAT(${part_id},'-',${vendor_id},', ',${start_date}) ;;
  }
  measure: avg_net_price {
    type: average
    sql: ${net_price} ;;
  }
}

view: net_price_lag {
  derived_table: {
    sql: select
    *,
    coalesce(lag(net_price) over (partition by part_id,vendor_id order by start_date),msrp) as previous_net_price
from ${net_price.SQL_TABLE_NAME} ;;
  }
  dimension: deleted_date {
    type: date
    sql: ${TABLE}."DELETED_DATE" ;;
  }
  # dimension: description {
  #   type: string
  #   sql: ${TABLE}."DESCRIPTION" ;;
  # }
  dimension: difference_net_price {
    type: number
    sql: ${previous_net_price} - ${net_price} ;;
    value_format_name: usd
  }
  dimension: difference_percentage {
    type: number
    sql: (${net_price} - ${previous_net_price}) / nullifzero(${previous_net_price}) ;;
    value_format_name: percent_2
  }
  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }
  # dimension: item_id {
  #   type: string
  #   sql: ${TABLE}."ITEM_ID" ;;
  # }
  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
    value_format_name: usd
  }
  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE" ;;
    value_format_name: usd
  }
  # dimension: part_description {
  #   type: string
  #   sql: ${TABLE}."PART_DESCRIPTION" ;;
  # }
  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  # dimension: part_number {
  #   type: string
  #   sql: ${TABLE}."PART_NUMBER" ;;
  # }
  dimension: previous_net_price {
    type: number
    sql: ${TABLE}."PREVIOUS_NET_PRICE" ;;
    value_format_name: usd
  }
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: ${TABLE}."PRIMARY_KEY" ;;
  }
  # dimension: product_dimensions {
  #   type: string
  #   sql: ${TABLE}."PRODUCT_DIMENSIONS" ;;
  # }
  # dimension: provider_id {
  #   type: string
  #   sql: ${TABLE}."PROVIDER_ID" ;;
  #   value_format_name: id
  # }
  # dimension: provider_name {
  #   type: string
  #   sql: ${TABLE}."PROVIDER_NAME" ;;
  # }
  dimension_group: start_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: date(${TABLE}."START_DATE") ;;
  }
  # dimension: unit_of_measure {
  #   type: string
  #   sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  # }
  dimension: updated_date {
    type: date
    sql: ${TABLE}."UPDATED_DATE" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  # dimension: vendor_name {
  #   type: string
  #   sql: ${TABLE}."VENDOR_NAME" ;;
  # }
  # dimension: weight {
  #   type: string
  #   sql: ${TABLE}."WEIGHT" ;;
  # }
  measure: average_percent_change {
    type: average
    sql: ${difference_percentage} ;;
    value_format_name: percent_2
  }
}
