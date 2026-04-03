view: v_orders {
  view_label: "Orders"
  sql_table_name: "GOLD"."V_ORDERS" ;;

  dimension: order_deleted {
    type: yesno
    sql: ${TABLE}."ORDER_DELETED" ;;
  }
  dimension: order_delivery_required {
    type: yesno
    sql: ${TABLE}."ORDER_DELIVERY_REQUIRED" ;;
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: order_insurance_covers_rental {
    type: yesno
    sql: ${TABLE}."ORDER_INSURANCE_COVERS_RENTAL" ;;
  }
  dimension: order_key {
    type: number
    primary_key: yes
    sql: ${TABLE}."ORDER_KEY" ;;
  }
  dimension: order_project_type {
    type: string
    sql: ${TABLE}."ORDER_PROJECT_TYPE" ;;
  }
  dimension: order_recordtimestamp {
    type: date
    sql: ${TABLE}."ORDER_RECORDTIMESTAMP" ;;
  }
  dimension: order_reference {
    type: string
    sql: ${TABLE}."ORDER_REFERENCE" ;;
  }
  dimension: order_source {
    type: string
    sql: ${TABLE}."ORDER_SOURCE" ;;
  }
  dimension: order_status_id {
    type: number
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
  }
  dimension: order_status_name {
    type: string
    sql: ${TABLE}."ORDER_STATUS_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [order_status_name]
  }
}
