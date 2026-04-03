view: es_companies {
  sql_table_name: "PUBLIC"."ES_COMPANIES" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: abl_eligible {
    type: yesno
    sql: ${TABLE}."ABL_ELIGIBLE" ;;
  }
  dimension: balance_sheet {
    type: yesno
    sql: ${TABLE}."BALANCE_SHEET" ;;
  }
  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  dimension: owned {
    type: yesno
    sql: ${TABLE}."OWNED" ;;
  }
  dimension: rental_fleet {
    type: yesno
    sql: ${TABLE}."RENTAL_FLEET" ;;
  }
  dimension: wide_search_allowed {
    type: yesno
    sql: ${TABLE}."WIDE_SEARCH_ALLOWED" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name]
  }
}
