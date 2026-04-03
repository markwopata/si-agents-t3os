view: sub_renters_table {
  # # You can specify the table name if it's different from the view name:

  sql_table_name: "PUBLIC"."sub_renters"
  ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: _es_load_timestamp {
    type: time
    sql: ${TABLE}."_ES_LOAD_TIMESTAMP" ;;
  }

  dimension: sub_renter_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_ID" ;;
  }

  dimension: sub_renter_purchase_order_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_PURCHASE_ORDER_ID" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: updated_by {
    type: number
    sql: ${TABLE}."UPDATED_BY" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: sub_renter_ordered_by_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_ORDERED_BY_ID" ;;
  }

  dimension: sub_renter_company_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_COMPANY_ID" ;;
  }

  set: detail {
    fields: [
      _es_update_timestamp_time,
      _es_load_timestamp_time,
      sub_renter_id,
      sub_renter_purchase_order_id,
      date_updated_time,
      created_by,
      updated_by,
      date_created_time,
      company_id,
      sub_renter_ordered_by_id,
      sub_renter_company_id
    ]
  }
}
