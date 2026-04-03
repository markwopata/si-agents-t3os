view: tracker_billing_output {
  sql_table_name: "ANALYTICS"."CONTRACTOR_PAYOUTS"."TRACKER_BILLING_OUTPUT"
    ;;

  dimension: asset_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: tracker_installed {
    type: string
    sql: ${TABLE}."TRACKER_INSTALLED" ;;
  }

  dimension: tracker_install_date {
    type: date
    sql: ${TABLE}."TRACKER_INSTALL_DATE" ;;
  }

  measure: cost {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."COST" ;;
  }

  dimension_group: dte {
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
    sql: ${TABLE}."DTE" ;;
  }

  dimension: tracker_month {
    type: string
    sql: ${dte_month} ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: payout_program_name {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_NAME" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: tracker_id {
    type: string
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [payout_program_name, company_name]
  }
}
