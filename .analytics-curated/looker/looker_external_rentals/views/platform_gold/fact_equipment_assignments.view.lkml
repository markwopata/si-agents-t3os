view: fact_equipment_assignments {
  sql_table_name: "PLATFORM"."GOLD"."V_EQUIPMENT_ASSIGNMENTS" ;;

  dimension: equipment_assignment_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_KEY" ;;
    hidden: yes
  }

  dimension: equipment_assignment_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ID" ;;
    value_format_name: id
  }

  dimension: equipment_assignment_asset_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: equipment_assignment_rental_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_RENTAL_KEY" ;;
    description: "FK to dim_rentals"
  }

  dimension: equipment_assignment_start_date_date_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_START_DATE_DATE_KEY" ;;
    hidden: yes
  }

  dimension: equipment_assignment_end_date_date_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_END_DATE_DATE_KEY" ;;
    hidden: yes
  }

  dimension: equipment_assignment_is_current {
    type: yesno
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_IS_CURRENT" ;;
  }

  dimension: equipment_assignment_recordtimestamp {
    type: string
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
