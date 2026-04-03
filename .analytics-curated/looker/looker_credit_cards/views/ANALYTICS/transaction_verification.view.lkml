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
          select t.PK_TRANSACTION,
       t.PK_UPLOAD,
       t.TRANSACTION_ID,
       t.TRANSACTION_DATE,
       t.TRANSACTION_AMOUNT,
       t.TRANSACTION_MERCHANT_NAME,
       t.TRANSACTION_MCC_CODE,
       t.TRANSACTION_MCC,
       t.TRANSACTION_CARD_TYPE,
       t.UPLOAD_ID,
       t.UPLOAD_DATE,
       t.UPLOAD_AMOUNT,
       t.EMPLOYEE_ID,
       t.FULL_NAME,
       t.WORK_EMAIL,
       t.TRANSACTION_DEFAULT_COST_CENTERS_FULL_PATH,
       t.TRANSACTION_CARD_HOLDER_NAME,
       t.UPLOAD_MARKET_ID,
       t.UPLOAD_MARKET_VERIFIED,
       t.SUB_DEPARTMENT_ID,
       t.SUB_DEPARTMENT,
       t.EXPENSE_LINE_ID,
       t.EXPENSE_LINE,
       case when t.FULL_NAME = 'NAVANTRAVEL DEPARTMENT' then 1 else VERIFIED_STATUS END as VERIFIED_STATUS,
       case when t.FULL_NAME = 'NAVANTRAVEL DEPARTMENT' then 'Verified' else VERIFIED_STATUS_DESC END as VERIFIED_STATUS_DESC,
       t.UPLOAD_NOTES,
       t.UPLOAD_URL,
       t.UPLOAD_SUBMITTED_AT_DATE,
       t.LOAD_SECTION,
       t.RECORDTIMESTAMP,
       r.receipt_list_by_page,
       t.UPLOAD_MODIFIED_AT_DATE,
       t.CORPORATE_ACCOUNT_NAME
from transaction_list t
         left join receipt_flatten r
                   on t.PK_TRANSACTION = r.PK_TRANSACTION
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
  html: <font color="#000000">
        {{rendered_value}} - {{company_directory.employee_id._rendered_value}}
        </font>;;
}

  dimension: cardholder_with_employee_id {
    label: "Cardholder Name with Employee ID"
    type: string
    sql: concat(${TABLE}."TRANSACTION_CARD_HOLDER_NAME",' - ',${TABLE}."EMPLOYEE_ID") ;;
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

  dimension: transaction_mcc_code {
    type: string
    sql: ${TABLE}."TRANSACTION_MCC_CODE" ;;
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

  dimension_group: upload_modified_at_date {
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
    sql: ${TABLE}."UPLOAD_MODIFIED_AT_DATE" ;;
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

  dimension: corporate_account_name {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NAME" ;;
  }

  dimension: transaction_date_plus_ten {
    type: date
    sql: DATEADD(DAY, 10, ${transaction_date_date});;
  }

  dimension: link_to_receipt {
    type: string
    # html: <font color="#0063f3"><u><a href ="{{rendered_value}}" target="_blank">Link to CC Receipt</a></font></u>;;
    html: <a href="{{rendered_value}}" target="_blank" style="color: #0063f3; text-decoration: underline;">Link to CC Receipt</a>;;
    sql: ${receipt_list_by_page};;
  }

  dimension: receipt_list_by_page {
    type: string
    html: <font color="blue "><u><a href ="{{rendered_value}}"target="_blank">{{rendered_value}}</a></font></u>;;
    sql: ${TABLE}."RECEIPT_LIST_BY_PAGE" ;;
  }

  dimension: card_information{
    type: string
    sql: ${card_type} ;;
    html:
    <b>Cardholder:</b><br /> <font color="#000000">
          {{cardholder_full_name._rendered_value}}
          </font> <br />
    <b>Card Type:</b><br /> {{card_type._rendered_value}} <br />
    <b> # of Unverified Transactions (Credit Card Only):</b><br /> {{unverified_count._rendered_value}}<br />
    ;;
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
    drill_fields: [ merchant_name, full_name,card_type,transaction_date_date,transaction_id, transaction_mcc, transaction_amount ,
      receipt_notes, link_to_receipt]
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

  dimension:  is_last_month_to_date {
    type: yesno
    sql: date_part(month , ${transaction_date_date}::DATE)  = date_part(month , (date_trunc('month', current_timestamp - interval '1 month')))
      and date_part(year , ${transaction_date_date}::DATE) = date_part(year , (date_trunc('year',current_timestamp - interval '1 month')))
      and date_part(day , ${transaction_date_date}::DATE) <= date_part(day , (current_date));;
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

  measure: last_mtd_count {
    type: count_distinct
    filters: [is_last_month_to_date: "yes"]
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

  dimension: receipt_upload_modified_at_date {
    type: date
    group_label: "HTML Passed Date Format" label: "Receipt Modified Date"
    sql: ${upload_modified_at_date_date} ;;
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
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  measure: last_month_to_date_spend {
    type: sum
    sql: ${transaction_amount} ;;
    value_format_name: usd
    filters: {
      field: is_last_month_to_date
      value: "yes"
    }
    drill_fields: [cardholder_full_name, card_type, merchant_name, transaction_date_formatted,transaction_id, transaction_mcc, transaction_amount, receipt_notes, receipt_list]
  }

  measure: mtd_vs_lmtd_difference {
    type: number
    sql: ${current_month_to_date_spend} - ${last_month_to_date_spend_with_transactions} ;;
    value_format_name: usd
  }

  measure: current_month_to_date_spend_with_transactions {
    label: "Month to Date $"
    type: sum
    sql: ${transaction_amount} ;;
    value_format_name: usd
    filters: {
      field: is_month_to_date
      value: "yes"
    }
    html:
    {{rendered_value}}
    <br />
    <span style="color: #8C8C8C;"> Transactions: {{ mtd_count._rendered_value }} </span>;;
    drill_fields: [ merchant_name, full_name,card_type,transaction_date_date,transaction_id, transaction_mcc, transaction_amount ,
      receipt_notes, link_to_receipt]
  }

  dimension: inapproptiate_ind {
    type: yesno
    sql: ${transaction_mcc_code} in ('5813','5993','5921','3731','5912','5815','5818','4899') OR (UPPER(${merchant_name}) like '%BAR %' AND UPPER(${merchant_name}) not like '%ELECTRIC%')
          OR (UPPER(${merchant_name}) like '%BREW%'AND UPPER(${merchant_name}) not like '%OIL%') OR UPPER(${merchant_name}) like '%CIGAR%'
          OR UPPER(${merchant_name}) like '%TAVERN%' OR UPPER(${merchant_name}) like '%SALOON%' OR UPPER(${merchant_name}) like '%TAP %'
          OR UPPER(${merchant_name}) like '%PUB %' OR UPPER(${merchant_name}) like '%GOLF%' OR UPPER(${merchant_name}) like '%BEER%' OR UPPER(${merchant_name}) like '%LIQUOR%' OR UPPER(${merchant_name}) like '%RELAXATION%'
           OR UPPER(${merchant_name}) like '% SPA %';;
  }

  measure: last_month_to_date_spend_with_transactions {
    label: "Last MTD $"
    type: sum
    sql: ${transaction_amount} ;;
    value_format_name: usd
    filters: {
      field: is_last_month_to_date
      value: "yes"
    }
    html:
          {{rendered_value}} <br />
          <span style="color: #8C8C8C;"> Transactions: {{ last_mtd_count._rendered_value }}  </span>;;
    drill_fields: [ merchant_name, full_name,card_type,transaction_date_date,transaction_id, transaction_mcc, transaction_amount ,
      receipt_notes, link_to_receipt]
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

############### AUDIT ############################################

############### CORP/FIELD ############################################
  dimension: corp_field {
    type: string
    sql: IFF(SPLIT_PART(${default_cost_center_full_path},'/',1)='Corp','CORP','FIELD') ;;
  }

  dimension: dept {
    label: "Department"
    type: string
    sql: case when  SPLIT_PART(${default_cost_center_full_path},'/',4) is null or SPLIT_PART(${default_cost_center_full_path},'/',4) = '' then 'Regional'
         else  SPLIT_PART(${default_cost_center_full_path},'/',4) end;;
  }

############### DATES ############################################

  filter: date_filter {
    type: date
    suggest_dimension: transaction_date_date
  }

  dimension: date_start {
    type: date
    sql: DATEADD('MONTH',-1,DATE_TRUNC('MONTH', {% date_start date_filter %}))::DATE ;;
  }

  dimension: date_end {
    type: date
    sql: LAST_DAY(DATEADD('DAY',-32,DATE_TRUNC('MONTH', {% date_end date_filter %})))::DATE  ;;
  }


  dimension: is_current_period {
    type: yesno
    sql: ${transaction_date_date} between  {% date_start date_filter %}::date and {% date_end date_filter %}::date;;
  }

  dimension: is_prior_month {
    type: yesno
    sql: ${transaction_date_date} between DATEADD('MONTH',-1,DATE_TRUNC('MONTH', {% date_start date_filter %}::DATE))
      AND LAST_DAY(DATEADD('MONTH',-1,DATE_TRUNC('MONTH', {% date_end date_filter %}::DATE)));;
  }


############### CURRENT PERIOD MEASURES ##########################

  measure: transaction_amount_current {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [cc_details_current*]
    link: {label: "Drill Detail" url:"{{ transaction_amount_current._link }}&f[transaction_verification.is_current_period]=True" }
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: average_transaction_amount {
    type: average
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }



  measure: median_transaction_amount {
    type: median
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: min_transaction_amount {
    type: min
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: max_transaction_amount {
    type: max
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: transaction_count {
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_ID",null) ;;
  }


############### PRIOR MONTH MEASURES ##########################

  measure: prior_month_transaction_amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [cc_details_prior_month*]
    link: {label: "Drill Detail" url:"{{ prior_month_transaction_amount._link }}&f[transaction_verification.is_prior_month]=True" }
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_average_transaction_amount {
    type: average
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_amount {
    type: average
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }


  measure: prior_month_median_transaction_amount {
    type: median
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_min_transaction_amount {
    type: min
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_max_transaction_amount {
    type: max
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_transaction_count {
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_ID",null) ;;
  }

############### DRILL FIELDS ##########################

  set: cc_details_current {
    fields: [
       transaction_verification.cardholder_full_name,credit_card_users.employee_title,transaction_verification.default_cost_center_full_path,
       transaction_verification.transaction_mcc,transaction_verification.merchant_name,transaction_verification.card_type,
       transaction_verification.transaction_date_date,transaction_verification.receipt_notes,transaction_verification.receipt_list,transaction_verification.transaction_id,
       transaction_verification.verified_status_description,
       transaction_verification.transaction_amount_current
    ]
  }

  set: cc_details_prior_month {
    fields: [
       transaction_verification.cardholder_full_name,credit_card_users.employee_title,transaction_verification.default_cost_center_full_path,
       transaction_verification.transaction_mcc,transaction_verification.merchant_name,transaction_verification.card_type,
       transaction_verification.transaction_date_date,transaction_verification.receipt_notes,transaction_verification.receipt_list,transaction_verification.transaction_id,
      transaction_verification.verified_status_description,
      transaction_verification.prior_month_amount
    ]
  }

}
