include: "/_base/analytics/commission/commission_details_test_data.view.lkml"

view: +commission_details_test_data {
  label: "Commission Details Test Data"

  ##################DIMENSTIONS####################

  dimension: asset_id {
    type: number
    value_format_name: id
  }
  dimension: branch_id {
    type: number
    value_format_name: id
    description: "Branch id from line items."
  }
  dimension: class {
    sql: ${rental_class_from_line_item} ;;
    label: "Equipment Class"
    description: "Name of equipment class for asset on the commission line item."
  }

  dimension: commission_id {
    description: "Hashed ID field created to prevent duplicate records in commission tables."
    primary_key: yes
    hidden: yes
  }
  dimension: commission_percentage {
    sql: ${commission_rate} ;;
    value_format_name: percent_0
    description: "Commission percent paid for line item based on rate achievement."
  }
  dimension: override_rate {
    value_format_name: percent_0
  }
  dimension: company_id {
    value_format_name: id
    description: "Company ID from invoice."
  }
  dimension: company_name {
    description: "Company Name from invoice."
  }
  dimension: email_address {
    description: "Email address for salesperson listed on the invoice at time of billing."
  }
  dimension: employee_id {
    value_format_name: id
    description: "Employee ID field for HR/Payroll purposes."
  }
  dimension: employee_type {
    description: "Field identifying the commision status of an employee when invoice was created (commission, guarantee, non-salesperson). "
  }
  dimension: equipment_class_id {
    sql: ${rental_class_id_from_rental} ;;
    value_format_name: id
    description: "Equipment class ID for rental."
  }
  dimension: full_name {
    description: "Full name of salesperson listed on the invoice at time of billing."
  }
  dimension: hidden {
    sql: case
          when current_timestamp < dateadd(day,-1,${payroll_paycheck_raw}) then true
          else false end;;
    description: "Internally used field to hide transactions until statement release date (1 day prior to payroll paycheck date)."
  }
  dimension: invoice_id {
    value_format_name: id
    description: "Invoice ID for commission eligible line items."
  }
  dimension: invoice_no {
    description: "Invoice number for commission eligible line items."
  }
  # dimension: is_finalized {
  #   description: "Internally used field to lock transactions from recalculating once submitted to payroll."
  # }
  dimension: line_item_amount {
    value_format_name: usd
    description: "Line item amount for commission eligible line items."
  }
  dimension: line_item_id {
    value_format_name: id
    description: "Line item id for commission eligible line items."
  }
  dimension: line_item_type {
    description: "Line item description for commission eligible line items."
  }
  dimension: line_item_type_id {
    value_format_name: id
    description: "Line item ID for commission eligible line items."
  }
  dimension: make {
    sql: ${invoice_asset_make} ;;
    description: "Equipment make for asset on commission eligible line items."
  }
  dimension: rate_tier {
    value_format_name: id
    description: "Rate achievement as calculated based on quoted rates and posted rates."
  }
  dimension: salesperson_type {
    description: "How the rep is listed on the invoice, primary or secondary,"
  }
  dimension: salesperson_type_varchar {
    sql: case when ${salesperson_type_id} = 1 then 'Primary'
      when ${salesperson_type_id} = 2 then 'Secondary' else null end;;
  }
  dimension: split {
    value_format_name: percent_0
    description: "The percentage of total commission available the rep received based on the reps on the invoice."
  }
  dimension: transaction_description {
    description: "Detailed description of the commission transaction calculations from dbt code."
  }
  dimension: transaction_description_stmt {
    sql: case
        when ${manual_adjustment_id} is null then ${transaction_description}
        else ${description} end;;
    description: "Detailed description of the commission transaction for statement, including manual adjustments."
  }
  dimension: transaction_type {
    type: string
    description: "Type of commission transaction, commission, clawback, etc."
  }
  dimension: user_id {
    sql: ${salesperson_user_id} ;;
    value_format_name: id
    description: "Salesperson user_id from approved invoice."
  }
  dimension: is_prior_month {
    type: yesno
    sql:  ${commission_month_raw} = dateadd(month, -1, ${commission_month_raw});;
  }

  dimension: comments {
    description: "Additional comments for manual adjustments."
  }
  dimension: requester_full_name {
    description: "Name of manager requesting the manual adjustment."
  }
  dimension: requester_id {
    value_format_name:id
  }
  dimension: description {
    description: "Short description of why manual adjustment is being made."
  }
  dimension_group: submitted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${submitted};;
    description: "The date the manual adjustment was submitted for payment."
  }


  ##################DATES####################


  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${billing_approved} ;;
    description: "Billing approved date from invoice."
  }
  dimension_group: commission_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${commission_month} ;;
    description: "Action month for commission transactions, not the month commissions were paid."
  }
  dimension_group: transaction {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${transaction} ;;
    description: "Date for commission action, could be billing approved, credit created, 120 days after billing, invoice paid date."
  }
  dimension_group: payroll_paycheck {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${paycheck} ;;
    description: "Date for the paycheck when transaction was paid."
  }
  dimension_group: order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${order} ;;
    description: "Date order was created."
  }
  dimension_group: rental {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${rental_date_created} ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${rental_start} ;;
  }


  ##################MEASURES####################

  measure: transaction_amount {
    description: "Calculated amount of commission paid for line item."
    type: sum
    sql: ${commission_amount} ;;
    value_format_name: usd
  }
  measure: total_commission {
    type: sum
    sql: ${commission_amount} ;;
    value_format_name: usd
  }
  measure: commission_total {
    type: sum
    sql: ${commission_amount} ;;
    filters: [transaction_type_id: "1",credit_note_line_item_id: "NULL"]
    value_format_name: usd
  }
  measure: credit_total{
    type: sum
    sql: ${commission_amount} ;;
    filters: [transaction_type_id: "1",credit_note_line_item_id: "NOT NULL"]
    value_format_name: usd
  }
  measure: clawback_total {
    type: sum
    sql: ${commission_amount} ;;
    filters: [transaction_type_id: "2"]
    value_format_name: usd
  }
  measure: reimbursement_total {
    type: sum
    sql: ${commission_amount} ;;
    filters: [transaction_type_id: "3"]
    value_format_name: usd
  }
  measure: total_commissionable_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type_id: "1"]
    value_format_name: usd
  }
  measure: rental_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type_id: "1",line_item_type_id: "6,8,43,108,109,129,130,131,132"]
    value_format_name: usd
  }
  measure: bulk_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type_id: "1",line_item_type_id: "44"]
    value_format_name: usd
  }
  measure: delivery_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type_id: "1",line_item_type_id: "5"]
    value_format_name: usd
  }
  measure: retail_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type_id: "1",line_item_type_id: "24,80,81,110,111,123"]
    value_format_name: usd
  }
  measure: parts_revenue {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type_id: "1",line_item_type_id: "49"]
    value_format_name: usd
  }

  # measure: prior_month_commission {
  #   type: sum
  #   sql: ${commission_amount} ;;
  #   filters: [is_prior_month: "yes"]
  # }

  measure: rental_revenue_drilldowns {
    type: sum
    sql: ${line_item_amount}*${split} ;;
    filters: [transaction_type_id: "1",line_item_type_id: "6,8,43,108,109,129,130,131,132"]
    drill_fields: [full_name,market_name,rental_revenue, commission_amount, company_name,billing_approved_date]
    value_format_name: usd
  }

  measure: commission_drilldowns {
    type: sum
    sql: ${commission_amount} ;;
    filters: [transaction_type_id: "1",line_item_type_id: "6,8,43,108,109,129,130,131,132"]
    drill_fields: [full_name,market_name,rental_revenue, commission_amount, company_name,billing_approved_date]
    value_format_name: usd
  }

  dimension: invoice_link {
    #description: "Invoice number for commission eligible line items."
    type: string
    html:
      <font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id | url_encode }}" target="_blank">{{invoice_no}}</a></font></u>;;
    sql: 'Link' ;;
  }

}
