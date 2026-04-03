view: line_items {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."LINE_ITEMS"
    ;;
  drill_fields: [invoice_id
      , line_item_id]

  dimension: line_item_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

measure: rental_revenue {
  type: sum
  value_format_name: usd
  sql: ${TABLE}."AMOUNT";;
  filters: [line_item_type_id: "8"]
  drill_fields: [market_region_xwalk.region_name
      , market_region_xwalk.market_name
      , t3_link_to_rental
      , invoices.date_created_date
      , admin_link_to_invoice
      , line_item_id
      , companies.name
      , asset_id
      , assets.make
      , assets.model
      , number_of_units
      , rental_revenue]
}

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: derived_asset_id {
    hidden:  no
    type: number
    sql: coalesce(${TABLE}."ASSET_ID",
      regexp_substr(${TABLE}."DESCRIPTION", 'Asset: (\\d{1,})', 1, 1, 'e')::integer
    );;
  }
  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: date_created_buckets {
    type: number
    sql: CASE
         WHEN ${date_created_date} <= current_date() AND ${date_created_date} >= dateadd(day, -30, current_date()) THEN 30
         WHEN ${date_created_date} < dateadd(day, -30, current_date()) AND ${date_created_date} >= dateadd(day, -60, current_date()) THEN 60
         WHEN ${date_created_date} < dateadd(day, -60, current_date()) AND ${date_created_date} >= dateadd(day, -90, current_date()) THEN 90
         ELSE NULL
         END;;
  }

  measure: parts_revenue_30 {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [date_created_buckets: "30", line_item_type_id: "11, 12, 49"]
    drill_fields: [providers.name, parts.part_number, part_types.description, parts_quantity, parts_revenue]
  }

  measure: parts_revenue_60 {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [date_created_buckets: "60", line_item_type_id: "11, 12, 49"]
    drill_fields: [providers.name, parts.part_number, part_types.description, parts_quantity, parts_revenue]
  }

  measure: parts_revenue_90 {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [date_created_buckets: "90", line_item_type_id: "11, 12, 49"]
    drill_fields: [providers.name, parts.part_number, part_types.description, parts_quantity, parts_revenue]
  }

  measure: parts_revenue_buckets_total {
    type: number
    sql: ${parts_revenue_30} + ${parts_revenue_60} + ${parts_revenue_90};;
    value_format_name: usd_0
    drill_fields: [providers.name, parts.part_number, part_types.description, parts_quantity, parts_revenue_30, parts_revenue_60, parts_revenue_90, parts_revenue_buckets_total]
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  measure: parts_quantity {
    type: sum
    sql: ${number_of_units} ;;
    filters: [line_item_type_id: "11, 12, 49"]
  }

  measure: warranty_parts_quantity {
    type: sum
    sql: ${number_of_units} ;;
    filters: [line_item_type_id: "23, 133"]
  }

  # Pulled part_id out of EXTENDED_DATA since PART_ID in the table is always null as of today (5/18/21) -Jack G
  # Converted type to string (5/3/23) -Matt B
  dimension: part_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA":"part_id" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_id]
  }
  measure: total_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  measure: assets_sales_revenue { #took these from the fleet total sales dashboard - HL 2.27.25
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id:"24, 50, 80, 81, 110, 111, 118, 120, 123, 125, 126, 127, 141"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_no, admin_link_to_invoice, assets_aggregate.asset_id,assets_aggregate.class,assets_aggregate.make,assets_aggregate.model,assets_aggregate.asset_id.year, assets_sales_revenue ]
  }

  measure: parts_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "11, 12, 49"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_no, parts_revenue]
  }
   measure: service_retail_parts {
   type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
   filters: [line_item_type_id: "11, 49"]
    drill_fields: [invoices.billing_approved_month, market_region_xwalk.market_name, companies.name, invoices.invoice_no, parts_revenue]
  }
  measure: parts_perc_asset_sales { #idea is that the more assets you sell, the higher opp for parts sales - HL 2.28.25
   type: number
    value_format_name: percent_1
    sql: ${service_retail_parts}/nullifzero(${assets_sales_revenue}) ;;
  }

  dimension: admin_link_to_invoice {
    label: "Invoice ID"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">{{invoice_id._value}}</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  dimension: t3_link_to_rental {
    label: "Rental ID"
    type: string
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/rentals/{{rental_id}}/overview?returnTo=/rentals/all" target="_blank">{{rental_id._value}}</a></font></u> ;;
    sql: ${rental_id}  ;;
  }


}
