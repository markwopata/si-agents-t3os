view: asset_rental {
  sql_table_name: "ANALYTICS"."ASSET_DETAILS"."ASSET_RENTAL"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  # removing this because it was added to asset_physical
  # dimension: asset_inventory_status {
  #   type: string
  #   sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  # }

  dimension_group: first_rental_assignment {
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
    sql: ${TABLE}."FIRST_RENTAL_ASSIGNMENT" ;;
  }

  dimension: last_contract_id {
    type: string
    sql: ${TABLE}."LAST_CONTRACT_ID" ;;
  }

  dimension: last_delivery_id {
    type: number
    sql: ${TABLE}."LAST_DELIVERY_ID" ;;
  }

  dimension: last_delivery_location {
    type: number
    sql: ${TABLE}."LAST_DELIVERY_LOCATION" ;;
  }

  dimension: last_invoice_id {
    type: number
    sql: ${TABLE}."LAST_INVOICE_ID" ;;
  }

  dimension: last_order_id {
    type: number
    sql: ${TABLE}."LAST_ORDER_ID" ;;
  }

  dimension_group: last_rental_assignment {
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
    sql: CAST(${TABLE}."LAST_RENTAL_ASSIGNMENT" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_off_rent {
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
    sql: ${TABLE}."LAST_OFF_RENT_DATE" ;;
  }

  dimension: last_rental_id {
    type: number
    sql: ${TABLE}."LAST_RENTAL_ID" ;;
  }

  dimension: last_rental_invoice_id {
    type: number
    sql: ${TABLE}."LAST_RENTAL_INVOICE_ID" ;;
  }

  # - - - - - SETS - - - - -

  set: asset_detail {
    fields: [asset_id,
      fleet_status.rental_branch,
      fleet_status.purchase_order_status,
      fleet_status.asset_type,
      fleet_status.company_name,
      fleet_status.custom_name,
      fleet_status.parent_category_name,
      fleet_status.sub_category_name,
      fleet_status.equip_class_name,
      fleet_status.make,
      fleet_status.model,
      fleet_status.date_created]
  }
}
