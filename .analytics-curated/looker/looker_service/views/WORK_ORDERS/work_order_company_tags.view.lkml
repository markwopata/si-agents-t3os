# The name of this view in Looker is "Work Order Company Tags"
view: work_order_company_tags {

  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_COMPANY_TAGS"
    ;;

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

  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}."WORK_ORDER_ID", '-', ${TABLE}."COMPANY_TAG_ID") ;;
  }
 dimension_group: deleted_on { #historical tags are now remaining in this table so deleted on needs to be null to get to current tags #HL 12.15.25
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
  sql: ${TABLE}."DELETED_ON" ;;
 }

  dimension: company_tag_id {
    type: number
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
  }

  dimension: name {
    type: string
    hidden: yes
    sql: ${company_tags.name} ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [
      work_orders.date_created_date,
      work_orders.work_order_id_with_link_to_work_order,
      work_orders.work_order_url_text,
      work_order.description,
      work_orders.work_order_status_name,
      work_orders.asset_id,
      current_inventory_status.asset_inventory_status,
      assets.make,
      assets.model,
      market_region_xwalk.market_name]
  }
}
