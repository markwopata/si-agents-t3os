view: fact_asset_last_checkins {
  sql_table_name: "PLATFORM"."GOLD"."V_ASSET_LAST_CHECKINS" ;;

  dimension: asset_last_checkin_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."ASSET_LAST_CHECKIN_KEY" ;;
    hidden: yes
  }

  dimension: asset_last_checkin_askv_id {
    type: number
    sql: ${TABLE}."ASSET_LAST_CHECKIN_ASKV_ID" ;;
    value_format_name: id
  }

  dimension: asset_last_checkin_asset_key {
    type: string
    sql: ${TABLE}."ASSET_LAST_CHECKIN_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: asset_last_checkin_date_key {
    type: string
    sql: ${TABLE}."ASSET_LAST_CHECKIN_DATE_KEY" ;;
    hidden: yes
  }

  dimension: asset_last_checkin_time_key {
    type: string
    sql: ${TABLE}."ASSET_LAST_CHECKIN_TIME_KEY" ;;
    hidden: yes
  }

  dimension: asset_last_checkin_recordtimestamp {
    type: string
    sql: ${TABLE}."ASSET_LAST_CHECKIN_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
