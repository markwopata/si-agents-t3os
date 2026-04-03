view: v_bridge_dim_office {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_BRIDGE_DIM_OFFICE" ;;

  dimension: bridge_dim_office_application_requisition_offer_key {
    type: string
    sql: ${TABLE}."BRIDGE_DIM_OFFICE_APPLICATION_REQUISITION_OFFER_KEY" ;;
  }
  dimension: bridge_dim_office_id_full_path {
    type: string
    sql: ${TABLE}."BRIDGE_DIM_OFFICE_ID_FULL_PATH" ;;
  }
  dimension: bridge_dim_office_key {
    type: number
    sql: ${TABLE}."BRIDGE_DIM_OFFICE_KEY" ;;
  }
  dimension: bridge_dim_office_name_full_path {
    type: string
    sql: ${TABLE}."BRIDGE_DIM_OFFICE_NAME_FULL_PATH" ;;
  }
  dimension: bridge_dim_office_requisition_key {
    type: number
    sql: ${TABLE}."BRIDGE_DIM_OFFICE_REQUISITION_KEY" ;;
  }
  measure: count {
    type: count
  }
}
