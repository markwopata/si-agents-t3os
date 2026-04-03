view: business_unit_snapshots {
  sql_table_name: "PROCUREMENT"."PUBLIC"."BUSINESS_UNIT_SNAPSHOTS" ;;

  dimension: business_unit_snapshot_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."BUSINESS_UNIT_SNAPSHOT_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: business_unit_type {
    type: string
    sql: ${TABLE}."BUSINESS_UNIT_TYPE" ;;
  }

  dimension: business_unit_id {
    type: string
    sql: ${TABLE}."BUSINESS_UNIT_ID" ;;
  }
}
