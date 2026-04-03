view: national_accounts {
  sql_table_name: "ANALYTICS"."GS"."NATIONAL_ACCOUNTS"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_id_string {
    type: string
    sql: company_id::varchar(15000);;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: rep_name {
    type: string
    sql: ${TABLE}."REP_NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: full_name_with_id {
    label: "Full Name with ID National"
    type: string
    sql: concat(${rep_name}, ' - ', ${user_id}) ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name, rep_name]
  }
}
