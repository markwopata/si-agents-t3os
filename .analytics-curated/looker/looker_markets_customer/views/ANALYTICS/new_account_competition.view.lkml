view: new_account_competition {
  sql_table_name: "PUBLIC"."NEW_ACCOUNT_COMPETITION"
    ;;

  dimension: acct_with_1_k_rev {
    type: string
    sql: ${TABLE}."ACCT_WITH_1K_REV" ;;
  }

  dimension: acct_with_1_k_rev_80_rate {
    type: string
    sql: ${TABLE}."ACCT_WITH_1K_REV_80_RATE" ;;
  }

  dimension: acct_with_rev {
    type: string
    sql: ${TABLE}."ACCT_WITH_REV" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: dormant_ind {
    type: number
    sql: ${TABLE}."DORMANT_IND" ;;
  }

  dimension_group: final_invoice {
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
    sql: ${TABLE}."FINAL_INVOICE_DATE" ;;
  }

  dimension: final_invoice_id {
    type: number
    sql: ${TABLE}."FINAL_INVOICE_ID" ;;
  }

  dimension_group: final_rental {
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
    sql: ${TABLE}."FINAL_RENTAL_DATE" ;;
  }

  dimension_group: first_invoice {
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
    sql: ${TABLE}."FIRST_INVOICE_DATE" ;;
  }

  dimension: first_invoice_id {
    type: number
    sql: ${TABLE}."FIRST_INVOICE_ID" ;;
  }

  dimension_group: first_rental {
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
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
  }

  dimension: invoice_year_quarter {
    type: string
    sql: ${TABLE}."INVOICE_YEAR_QUARTER" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: number_of_invoices {
    type: number
    sql: ${TABLE}."NUMBER_OF_INVOICES" ;;
  }

  dimension: number_of_rentals {
    type: number
    sql: ${TABLE}."NUMBER_OF_RENTALS" ;;
  }

  dimension: perc_day_bench {
    type: number
    sql: ${TABLE}."PERC_DAY_BENCH" ;;
  }

  dimension: perc_month_bench {
    type: number
    sql: ${TABLE}."PERC_MONTH_BENCH" ;;
  }

  dimension: perc_week_bench {
    type: number
    sql: ${TABLE}."PERC_WEEK_BENCH" ;;
  }

  dimension: rental_year_quarter {
    type: string
    sql: ${TABLE}."RENTAL_YEAR_QUARTER" ;;
  }

  dimension: sales_user {
    type: number
    sql: ${TABLE}."SALES_USER" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: total_points {
    type: number
    sql: ${TABLE}."TOTAL_POINTS" ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}.COMPANY_ID,${TABLE}.MARKET_ID) ;;
  }

  dimension: account_status{
    type: string
    sql: CASE WHEN ${dormant_ind} = 1 THEN 'Previously a Dormant Account' ELSE 'New Account' END ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: concat(${salesperson}, ' - ',${sales_user}) ;;
  }
  set: detail {
    fields: [
      salesperson,
      market_name,
      first_rental_date,
      account_status,
      company_name
    ]
  }

  measure: new_account_count {
    type: count
    drill_fields: [detail*]
  }

  dimension: view_all_time_accounts_opened {
    type: string
    sql: 'View New Accounts History' ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/40?Salesperson=&Market=&Region=&District=&Rental%20Date=12%20months&SalespersonID={{ users.user_id._value | url_encode }}"
    }
  }

  measure: new_account_count_link_to_salesperson {
    type: count
    drill_fields: [detail*]
    link: {
      label: "View Salesperson Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/5?Sales%20Rep={{ full_name_with_id._value }}&Market=&District=&Region=&"
    }
  }
}
