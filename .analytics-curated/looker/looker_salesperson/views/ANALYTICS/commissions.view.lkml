view: commissions {
  sql_table_name: "ANALYTICS"."COMMISSION_CLAWBACKS"."COMMISSIONS"
    ;;

  dimension_group: dte {
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
    sql: ${TABLE}."DTE" ;;
  }

  dimension: check_month {
    type: string
    sql: monthname(to_date(${dte_raw})) ;;
  }

  dimension: amount {
    type: number
    label: "Rental Revenue"
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: commission_percentage {
    type: number
    sql: ${TABLE}."COMMISSION_PERCENTAGE" ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
    drill_fields: [invoice_detail*]
  }

  dimension: employee_type {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }

  dimension: salesperson_type {
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE" ;;
  }

  dimension: rep_type {
    type: string
    label: "Salesperson Type"
    sql: case when ${salesperson_type} = 1 then 'Primary' else 'Secondary' end;;
  }

  dimension: split {
    type: number
    sql: ${TABLE}."SPLIT" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  # filter: date_filter {
  #   type: date
  # }

  # dimension_group: filter_start_date {
  #   hidden: yes
  #   type: time
  #   timeframes: [raw,date]
  #   sql: case when {% date_start ${date_filter} is null then ' ;;
  # }

  # dimension: is_selected_month {
  #   type: yesno
  #   sql: {% condition ${date_filter} %} ${action_raw} {% endcondition %} ;;
  # }

  # dimension: is_previous_month {
  #   type: yesno
  #   sql: ${action_raw} > add_months (-1, {% date_start ${date_selector} %}) and ${action_raw} < add_months(-1, {date_end ${date_selector} %});;
  # }


  dimension: amount_paid {
    type: number
    label: "Amount"
    value_format_name: usd
    sql:case
        when ${type} = 'clawback' then ${amount}*${split}*${commission_percentage}*-1
        else ${amount}*${split}*${commission_percentage}
        end;;
  }

  measure: total_clawbacks {
    type: sum
    value_format_name: usd
    sql: case
        when ${type} = 'clawback' or ${type} = 'reimbursement' then ${amount_paid}
        when ${type} = 'exception' then 0
        else 0
        end;;
    drill_fields: [detail*]
  }

  measure: revenue_amount {
    type: sum
    value_format_name: usd
    sql: ${amount} ;;
  }

  # measure: total {
  #   type: sum
  #   value_format_name: usd
  #   filters: [is_selected_month: "yes"]
  #   sql: case
  #       when ${type} in ('clawback','reimbursement','commission') then ${amount_paid}
  #       when ${type} = 'exception' then 0
  #       else 0
  #       end;;
  #   drill_fields: [detail*]
  # }

  # measure: prior_month_total {
  #   type: sum
  #   value_format_name: usd
  #   filters: [is_previous_month: "yes"]
  #   sql: case
  #         when ${type} in ('clawback','reimbursement','commission') then ${amount_paid}
  #         when ${type} = 'exception' then 0
  #         else 0
  #         end;;
  #   drill_fields: [detail*]
  # }

  measure: count {
    type: count
    drill_fields: []
  }

  set: detail {
    fields: [
      invoices.company_id,
      companies.name,
      invoice_id,
      invoices.invoice_no,
      invoices.billing_approved_date,
      users.Full_Name,
      salesperson_type,
      amount,
      type,
      amount_paid
    ]
  }

  set: invoice_detail {
    fields: [
    invoice_id,
    invoices.billing_approved_date,
    dte_date,
    type,
    amount_paid
    ]
  }

}
