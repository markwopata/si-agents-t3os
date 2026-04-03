view: credit_apps {
  sql_table_name: "ANALYTICS"."PUBLIC"."CREDIT_APPS"
    ;;

  dimension: app_status {
    type: string
    sql: ${TABLE}."APP_STATUS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: credit_score {
    type: number
    sql: ${TABLE}."CREDIT_SCORE" ;;
  }

  dimension: credit_specialist {
    type: string
    sql: ${TABLE}."CREDIT_SPECIALIST" ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension_group: date_received {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: duns {
    type: string
    sql: ${TABLE}."DUNS" ;;
  }

  dimension: es_admin_setup {
    type: yesno
    sql: ${TABLE}."ES_ADMIN_SETUP" ;;
  }

  dimension: fein {
    type: string
    sql: ${TABLE}."FEIN" ;;
  }

  dimension: government_entity {
    type: yesno
    sql: ${TABLE}."GOVERNMENT_ENTITY" ;;
  }

  dimension: linked_to_intacct {
    type: yesno
    sql: ${TABLE}."LINKED_TO_INTACCT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: naics_1 {
    type: number
    sql: ${TABLE}."NAICS_1" ;;
    value_format_name: id
  }

  dimension: naics_2 {
    type: number
    sql: ${TABLE}."NAICS_2" ;;
    value_format_name: id
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: ofac {
    type: string
    sql: ${TABLE}."OFAC" ;;
  }

  dimension: ra_required {
    type: yesno
    sql: ${TABLE}."RA_REQUIRED" ;;
  }

  dimension: row_number {
    type: number
    sql: ${TABLE}."ROW_NUMBER" ;;
    primary_key: yes
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  dimension: sic {
    type: number
    sql: ${TABLE}."SIC" ;;
    value_format_name: id
  }

  dimension: tin {
    type: number
    sql: ${TABLE}."TIN" ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: [company_name, market_name]
  }
}
