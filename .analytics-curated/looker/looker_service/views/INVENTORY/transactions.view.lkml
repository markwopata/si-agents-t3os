view: transactions {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."TRANSACTIONS"
    ;;
  drill_fields: [transaction_id]

  dimension: transaction_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: custom_id {
    type: string
    sql: ${TABLE}."CUSTOM_ID" ;;
  }

  dimension_group: date_cancelled {
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
    sql: ${TABLE}."DATE_CANCELLED" ;;
  }

  dimension_group: date_completed {
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
    sql: ${TABLE}."DATE_COMPLETED" ;;
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
    sql: ${TABLE}."DATE_CREATED" ;;
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
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: from_id {
    type: number
    sql: ${TABLE}."FROM_ID" ;;
  }

  dimension: po_id {
    type: string
    sql: ${TABLE}."FROM_UUID_ID" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: modified_by {
    type: number
    sql: ${TABLE}."MODIFIED_BY" ;;
  }

  dimension: split_from {
    type: number
    sql: ${TABLE}."SPLIT_FROM" ;;
  }

  dimension: to_id {
    type: number
    sql: ${TABLE}."TO_ID" ;;
  }

  dimension: transaction_group_id {
    type: number
    sql: ${TABLE}."TRANSACTION_GROUP_ID" ;;
  }

  dimension: transaction_status_id {
    type: number
    sql: ${TABLE}."TRANSACTION_STATUS_ID" ;;
  }

  dimension: transaction_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }

  measure: part_count_work_order_inventory_link {
    type: count
    drill_fields: [
      market_region_xwalk.market_name,
      assets.make_and_model,
      part_types.description
    ]

    link: {
      label: "View Store Parts Inventory Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/97?Part%20Description={{ part_types.description._filterable_value | url_encode }}&Market={{ _filters['market_region_xwalk.market_name'] | url_encode }}&Region={{ _filters['market_region_xwalk.region_name'] | url_encode }}&District={{ _filters['market_region_xwalk.district'] | url_encode }}"
    }
    description: "This links out to the Store Parts Inventory Dashboard"
  }

  measure: count {
    type: count
    drill_fields: [transaction_id, transaction_types.transaction_type_id, transaction_types.name, transaction_items.count]
  }


}
