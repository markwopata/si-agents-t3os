view: transaction_verification {
  derived_table: {
    sql: with transaction_list as (
              select *
              from analytics.credit_card.transaction_verification
              where verified_status <> 2),
          receipt_flatten as (
              select pk_transaction,
                replace(replace(replace(c.value::string,'[',''),']',''),'"','') as receipt_list_by_page
              from transaction_list,
              LATERAL SPLIT_TO_TABLE(upload_url, ',') c)
          select t.*, r.receipt_list_by_page from transaction_list t left join receipt_flatten r on t.pk_transaction = r.pk_transaction
              ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: expense_line {
    type: string
    sql: ${TABLE}."EXPENSE_LINE" ;;
  }

  dimension: expense_line_id {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }

  dimension: sub_department {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT" ;;
  }

  dimension: sub_department_id {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME";;
  }

  dimension: cardholder_full_name {
    label: "Cardholder"
    type: string
    sql: ${TABLE}."TRANSACTION_CARD_HOLDER_NAME" ;;
  }

  dimension: cardholder_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: pk_transaction {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}."PK_TRANSACTION" ;;
  }

  dimension: pk_upload {
    hidden: yes
    type: string
    sql: ${TABLE}."PK_UPLOAD" ;;
  }

  dimension_group: receipt_timestamp {
    type: time
    sql: ${TABLE}."RECORDTIMESTAMP" ;;
  }

  dimension: transaction_amount{
    type: number
    sql: ${TABLE}."TRANSACTION_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: card_type {
    type: string
    sql: ${TABLE}."TRANSACTION_CARD_TYPE" ;;
    html:
    {% if card_type._value == 'amex'  %}
    Amex
    {% elsif card_type._value == 'cent' %}
    Central Bank
    {% elsif card_type._value == 'citi' %}
    Citi
    {% elsif card_type._value == 'fuel' %}
    Fuel Card
    {% else %}
    Unknown
    {% endif %}
    ;;
  }

  dimension_group: transaction_date {
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
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }



  dimension: default_cost_center_full_path {
    type: string
    sql: ${TABLE}."TRANSACTION_DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}."TRANSACTION_ID" ;;
    value_format_name: id
  }

  dimension: transaction_mcc {
    type: string
    sql: ${TABLE}."TRANSACTION_MCC" ;;
  }

  dimension: merchant_name {
    type: string
    sql: ${TABLE}."TRANSACTION_MERCHANT_NAME" ;;
  }

  dimension: receipt_amount {
    type: number
    sql: ${TABLE}."UPLOAD_AMOUNT" ;;
    value_format_name: usd
  }

  dimension_group: receipt_upload_date {
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
    sql: ${TABLE}."UPLOAD_SUBMITTED_AT_DATE" ;;
  }

  dimension: receipt_upload_id {
    type: number
    sql: ${TABLE}."UPLOAD_ID" ;;
    value_format_name: id
  }

  dimension: receipt_market_id {
    type: string
    sql: ${TABLE}."UPLOAD_MARKET_ID" ;;
  }

  dimension: receipt_market_verified {
    type: yesno
    sql: ${TABLE}."UPLOAD_MARKET_VERIFIED" ;;
  }

  dimension: receipt_notes {
    type: string
    sql: ${TABLE}."UPLOAD_NOTES" ;;
  }

  dimension: receipt_link {
    type: string
    sql: ${TABLE}."UPLOAD_URL" ;;
  }

  dimension: verified_status {
    type: yesno
    sql: ${TABLE}."VERIFIED_STATUS" ;;
  }

  dimension: verified_status_description {
    type: string
    sql: ${TABLE}."VERIFIED_STATUS_DESC" ;;
  }

  dimension: transaction_date_plus_ten {
    type: date
    sql: DATEADD(DAY, 10, ${transaction_date_date});;
  }

  dimension: link_to_receipt {
    type: string
    html: <font color="blue "><u><a href ="{{rendered_value}}"target="_blank">Link to CC Receipt</a></font></u>;;
    sql: ${receipt_list_by_page};;
  }

  dimension: receipt_list_by_page {
    type: string
    sql: ${TABLE}."RECEIPT_LIST_BY_PAGE" ;;
  }


  ### MEASURES ###

  measure: receipt_list {
    label: "Link to Receipts"
    type: list
    list_field: link_to_receipt
  }

  measure: amount {
    type: sum
    sql: ${transaction_amount};;
  }

  measure: count {
    type: count_distinct
    sql: ${pk_transaction} ;;
  }

  # Verified Status Grain

  measure: unverified_amount {
    type: sum
    filters: [verified_status: "0"]
    sql: ${transaction_amount} ;;
    value_format_name: usd
  }

  measure: verified_amount {
    type: sum
    filters: [verified_status: "1"]
    sql: ${transaction_amount} ;;
    value_format_name: usd
  }

  measure: unverified_count {
    type: count_distinct
    filters: [verified_status: "0"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }

  measure: unverified_shutoff_eligible_count {
    type: count_distinct
    filters: [verified_status: "0", card_type: "amex,citi"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }

  measure: unverified_nonshutoff_eligible_count {
    type: count_distinct
    filters: [verified_status: "0", card_type: "fuel,cent"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }

  measure: verified_count {
    type: count_distinct
    filters: [verified_status: "1"]
    sql: ${pk_transaction};;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  # Date Binning Grain

  dimension: is_month_to_date {
    type: yesno
    sql: date_trunc('month',${transaction_date_date}::DATE)::DATE=date_trunc('month',current_timestamp)::DATE;;
  }

  dimension:  is_last_month {
    type: yesno
    sql: date_part(month , ${transaction_date_date}::DATE)  = date_part(month , (date_trunc('month', current_timestamp - interval '1 month')))
      and date_part(year , ${transaction_date_date}::DATE) = date_part(year , (date_trunc('year',current_timestamp - interval '1 month'))) ;;
  }

  measure: mtd_amount {
    type: sum
    filters: [is_month_to_date: "yes"]
    sql: ${transaction_amount};;
    value_format_name: usd
  }

  measure: mtd_count {
    type: count_distinct
    filters: [is_month_to_date: "yes"]
    sql: ${pk_transaction} ;;
  }

  measure: last_month_amount {
    type: sum
    filters: [is_last_month: "yes"]
    sql: ${transaction_amount};;
    value_format_name: usd
  }

  measure: last_month_count {
    type: count_distinct
    filters: [is_last_month: "yes"]
    sql: ${pk_transaction} ;;
  }

  dimension: transaction_date_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Transaction Date"
    sql: ${transaction_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: receipt_upload_date_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Receipt Upload Date"
    sql: ${receipt_upload_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: amex_unverified_count {
    type: count_distinct
    filters: [verified_status: "0", card_type: "amex"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }

  measure: citi_unverified_count {
    type: count_distinct
    filters: [verified_status: "0", card_type: "citi"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }

  measure: fuel_card_unverified_count {
    type: count_distinct
    filters: [verified_status: "0", card_type: "fuel"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }

  measure: central_bank_unverified_count {
    type: count_distinct
    filters: [verified_status: "0", card_type: "cent"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }


  measure: amex_verified_count {
    type: count_distinct
    filters: [verified_status: "1", card_type: "amex"]
    sql: ${pk_transaction};;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  measure: citi_verified_count {
    type: count_distinct
    filters: [verified_status: "1", card_type: "citi"]
    sql: ${pk_transaction};;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  measure: fuel_card_verified_count {
    type: count_distinct
    filters: [verified_status: "1", card_type: "fuel"]
    sql: ${pk_transaction};;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  measure: central_bank_verified_count {
    type: count_distinct
    filters: [verified_status: "1", card_type: "cent"]
    sql: ${pk_transaction};;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  dimension: day_of_month {
    type: date_day_of_month
    sql: ${transaction_date_raw} ;;
  }

  measure: current_month_running_spend {
    type: running_total
    sql: ${current_month_to_date_spend} ;;
    value_format_name: usd
  }

  measure: last_month_running_spend {
    type: running_total
    sql: ${last_month_to_date_spend} ;;
    value_format_name: usd
  }

  measure: current_month_to_date_spend {
    type: sum
    sql: ${transaction_amount} ;;
    value_format_name: usd
    filters: {
      field: is_month_to_date
      value: "yes"
    }
  }

  measure: last_month_to_date_spend {
    type: sum
    sql: ${transaction_amount} ;;
    value_format_name: usd
    filters: {
      field: is_last_month
      value: "yes"
    }
  }

  dimension: credit_card_group {
    type: string
    sql:
    case when ${card_type} = 'fuel' then 'Fuel Card' else 'Credit Card' end ;;
  }

  measure: credit_card_unverified_count {
    type: count_distinct
    filters: [verified_status: "0", credit_card_group: "Credit Card"]
    sql: ${pk_transaction} ;;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount]
  }

  measure: credit_card_verified_count {
    type: count_distinct
    filters: [verified_status: "1", credit_card_group: "Credit Card"]
    sql: ${pk_transaction};;
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  measure: receipt_count {
    type: count_distinct
    sql: ${pk_upload} ;;
  }

}
