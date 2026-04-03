view: shopify_ops_price_snapshot {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."SHOPIFY_OPS_PRICE_SNAPSHOT" ;;

  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: product_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PRODUCT_ID" ;;
  }
  dimension: product_table_max_price {
    type: number
    sql: ${TABLE}."PRODUCT_TABLE_MAX_PRICE" ;;
  }
  dimension: product_table_min_price {
    type: number
    sql: ${TABLE}."PRODUCT_TABLE_MIN_PRICE" ;;
  }
  dimension: product_variant_id {
    type: number
    sql: ${TABLE}."PRODUCT_VARIANT_ID" ;;
  }
  dimension: product_variant_price {
    type: number
    sql: ${TABLE}."PRODUCT_VARIANT_PRICE" ;;
  }
  dimension: snapshot_month {
    type: date
    convert_tz: no
    sql: ${TABLE}."SNAPSHOT_MONTH" ;;
  }
  dimension: last_day_snapshot_month {
    type: date
    convert_tz: no
    sql: last_day(${TABLE}."SNAPSHOT_MONTH", 'month') ;;
  }
  dimension: unique_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."PRODUCT_VARIANT_ID"||${TABLE}."DATE_UPDATED" ;;
  }

}
