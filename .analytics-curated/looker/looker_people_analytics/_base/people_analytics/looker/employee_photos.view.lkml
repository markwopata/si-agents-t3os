view: employee_photos {
  sql_table_name: "LOOKER"."EMPLOYEE_PHOTOS" ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: attachment_content {
    type: string
    sql: ${TABLE}."ATTACHMENT_CONTENT" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: last_functionally_updated {
    type: date_raw
    sql: ${TABLE}."LAST_FUNCTIONALLY_UPDATED";;
    hidden: yes
  }
  measure: count {
    type: count
  }
}
