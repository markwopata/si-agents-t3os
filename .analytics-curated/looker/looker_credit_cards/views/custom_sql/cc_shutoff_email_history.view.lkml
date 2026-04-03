view: cc_shutoff_email_history {
  derived_table: {
    sql:
      select md5(cd.EMPLOYEE_ID || cseh.TRANSACTION_DATE || cseh.DAYS_UNTIL_SHUTOFF) as pk_id,
             cd.employee_id,
             coalesce(cd.nickname, cd.full_name)                                     as full_name,
             cd.work_email                                                           as email_address,
             cseh.card_type,
             --cseh.card_status,
             cseh.transaction_date,
             cseh.shutoff_date,
             cseh.days_until_shutoff,
             cseh.total_receipts_not_received,
             cseh.shutoff_status,
             cseh._es_update_timestamp                                               as run_timestamp
      from analytics.credit_card.cc_shutoff_email_history cseh
               join analytics.payroll.stg_analytics_payroll__company_directory cd
                    on cseh.employee_id = cd.employee_id
      where (cseh.run_mode is null or cseh.run_mode = '') -- Table can store test data too, ignore that for front end
    ;;
  }

  dimension: pk_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.pk_id ;;
  }

  dimension: employee_id {
    value_format_name: id
    sql: ${TABLE}.employee_id ;;
  }

  dimension: full_name {
    sql: ${TABLE}.full_name ;;
  }

  dimension: email_address {
    sql: ${TABLE}.email_address ;;
  }

  dimension: card_type {
    sql: ${TABLE}.card_type ;;
  }

  # dimension: card_status {
  #   sql: ${TABLE}.card_status ;;
  # }

  dimension: transaction_date {
    type: date
    sql: ${TABLE}.transaction_date ;;
  }

  dimension: shutoff_date {
    type: date
    sql: ${TABLE}.shutoff_date ;;
  }

  dimension: days_until_shutoff {
    type: number
    sql: ${TABLE}.days_until_shutoff ;;
  }

  dimension: total_receipts_not_received {
    type: number
    sql: ${TABLE}.total_receipts_not_received ;;
  }

  dimension: shutoff_status {
    sql: ${TABLE}.shutoff_status ;;
  }

  dimension_group: run_timestamp {
    type: time
    timeframes: [raw, date, month, quarter, year]
    sql: ${TABLE}.run_timestamp ;;
  }

  measure: count {
    type: count
  }
}
