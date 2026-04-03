view: commission_statement_data {
  sql_table_name: "ANALYTICS"."COMMISSION"."COMMISSION_DETAILS"
  ;;

  dimension: commission_id {
    type: string
    sql: ${TABLE}."COMMISSION_ID" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: line_item_amount {
    label: "Line Item Amount"
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
    value_format_name: usd

  }
  measure: total_amount {
    type: sum
    sql: ${line_item_amount} ;;
    value_format_name: usd
  }

  dimension_group: commission_month {
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
    sql: CAST(${TABLE}."COMMISSION_MONTH" AS TIMESTAMP_NTZ) ;;
  }

  dimension: payroll_check_date {
    type: date
    sql: CAST(${TABLE}."PAYCHECK_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: current_payroll_date {
    type: date
    sql: case when now()>= add_days(-1,${payroll_check_date}) then ${payroll_check_date} else null end;;
  }

  dimension_group: billing_approved {
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
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: commission_percentage {
    description: "The earned percentage for the commission month based on revenue and rate achievement."
    type: number
    sql: ${TABLE}."COMMISSION_PERCENTAGE" ;;
    value_format_name: percent_0
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

  dimension_group: dte {
    label: "Action Date"
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
    sql: CAST(${TABLE}."DTE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_type {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }


  dimension: full_name {
    label: "Salesperson Full Name"
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: hidden {
    description: "Current month finalized records are hidden until the day before payroll check date."
    type: yesno
    sql: ${TABLE}."HIDDEN" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    value_format_name: id
  }

  dimension: salesperson_type {
    type: string
    sql: case when ${TABLE}."SALESPERSON_TYPE" = 1 then 'Primary' else 'Secondary' end;;
  }

  dimension: split {
    label: "Commission Split"
    description: "Percentage of commission received based on Primary or Secondary status on the invoice."
    type: number
    sql: ${TABLE}."SPLIT" ;;
    value_format_name: percent_0
  }

  dimension: transaction_amount {
    hidden: yes
    type: number
    sql: ${TABLE}."COMMISSION_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: transaction_description {
    type: string
    sql: ${TABLE}."TRANSACTION_DESCRIPTION" ;;
  }

  dimension: transaction_type {
    label: "Transaction Type"
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  dimension: user_id {
    label: "Salesperson User ID"
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: Full_Name_with_ID {
    type: string
    sql: concat(${full_name},' - ',${user_id}) ;;
    suggest_persist_for: "5 hours"
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: grace_period_flag {
    type: yesno
    sql: ${TABLE}."GRACE_PERIOD_FLAG" ;;
  }

  measure: calculated_transaction_amount {
    label: "Transaction Amount"
    description: "Calculated amount based on line item total, split and percentage."
    type: sum
    sql: ${transaction_amount} ;;
    value_format_name: usd
  }

  measure: sales_db_revenue {
    type: sum
    sql: ${line_item_amount} ;;
    value_format_name: usd_0
  }


  # measure: sales_db_primary_revenue {
  #   type: sum
  #   sql:case when ${salesperson_type} = 'Primary' then ${line_item_amount}
  #       else 0 end ;;
  #   value_format_name: usd_0
  # }

  # measure: sales_db_secondary_revenue {
  #   type: sum
  #   sql:case when ${salesperson_type} = 'Secondary' then ${line_item_amount}
  #     else 0 end ;;
  #   value_format_name: usd_0
  # }

  measure: total_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type: "commission,credit"]
    value_format_name: usd
  }

  measure: rental_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type: "commission,credit",line_item_type_id: "6,8,108,109"]
    value_format_name: usd
  }

  measure: bulk_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type: "commission,credit",line_item_type_id: "44"]
    value_format_name: usd
  }

  measure: delivery_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type: "commission,credit",line_item_type_id: "5"]
    value_format_name: usd
  }

  measure: commission_total {
    type: sum
    sql: ${transaction_amount} ;;
    filters: [transaction_type: "commission"]
    value_format_name: usd
  }

  measure: credit_total{
    type: sum
    sql: ${transaction_amount} ;;
    filters: [transaction_type: "credit"]
    value_format_name: usd
  }

  measure: clawback_total {
    type: sum
    sql: ${transaction_amount} ;;
    filters: [transaction_type: "clawback"]
    value_format_name: usd
  }

  measure: reimbursement_total {
    type: sum
    sql: ${transaction_amount} ;;
    filters: [transaction_type: "reimbursement"]
    value_format_name: usd
  }

  dimension: revenue_split_group {
    group_label: "Revenue Crosswalk"
    type: string
    sql: case when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
         and ${salesperson_type} = 'Primary' and ${split} = 1 then 'Rental'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
         and ${salesperson_type} = 'Primary' and ${split} = .5 then 'Rental'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
         and ${salesperson_type} = 'Primary' and ${split} = 1 then 'Ancillary'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
         and ${salesperson_type} = 'Primary' and ${split} = .5 then 'Ancillary'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
         and ${salesperson_type} = 'Secondary' and ${split} <= .5 then 'Rental'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
         and ${salesperson_type} = 'Secondary' and ${split} <= .5 then 'Ancillary'
         else null end;;
  }

  dimension: revenue_split_desc {
    group_label: "Revenue Crosswalk"
    type: string
    sql: case when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type} = 'Primary' and ${split} = 1 then 'Rental - Primary Rep, no Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type} = 'Primary' and ${split} = .5 then 'Rental - Primary Rep, with Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type} = 'Primary' and ${split} = 1 then 'Ancillary - Primary Rep, no Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type} = 'Primary' and ${split} = .5 then 'Ancillary - Primary Rep, with Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type} = 'Secondary' and ${split} <= .5 then 'Rental - Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type} = 'Secondary' and ${split} <= .5 then 'Ancillary - Secondary Rep (not currently on Salesperson DB)'
              else null end;;
    order_by_field: custom_order
  }

  dimension: commission_split {
    group_label: "Revenue Crosswalk"
    type: string
    sql: case when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type} = 'Primary' and ${split} = 1 then '100%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type} = 'Primary' and ${split} = .5 then '50%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type} = 'Primary' and ${split} = 1 then '100%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type} = 'Primary' and ${split} = .5 then '50%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type} = 'Secondary' and ${split} <= .5 then '50% (or less if multiple secondary reps)'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type} = 'Secondary' and ${split} <= .5 then '50% (or less if multiple secondary reps)'
              else null end;;
  }


  dimension: custom_order {
    type: number
    sql: case
          when ${revenue_split_desc} = 'Rental - Primary Rep, no Secondary Rep' then 1
          when ${revenue_split_desc} = 'Rental - Primary Rep, with Secondary Rep' then 2
          when ${revenue_split_desc} = 'Ancillary - Primary Rep, no Secondary Rep' then 3
          when ${revenue_split_desc} = 'Ancillary - Primary Rep, with Secondary Rep' then 4
          when ${revenue_split_desc} = 'Rental - Secondary Rep' then 5
          else 6
          end;;
    hidden: yes
    description: "This dimension is used to force sort on the dashboard."
  }

  measure: count {
    type: count
    drill_fields: [company_name, full_name]
  }
}
