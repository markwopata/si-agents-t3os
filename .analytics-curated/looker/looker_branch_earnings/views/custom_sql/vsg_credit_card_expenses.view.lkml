view: vsg_credit_card_expenses {
  derived_table: {
    sql:
      with base as (
        select
            tv.transaction_id,
            tv.transaction_date,
            date_trunc('month', tv.transaction_date)::date as transaction_month,
            tv.upload_date,
            date_trunc('month', coalesce(tv.upload_date, tv.transaction_date))::date as coding_month,
            tv.transaction_amount,
            tv.transaction_merchant_name,
            tv.transaction_card_type,
            tv.transaction_mcc_code,
            tv.transaction_mcc,
            tv.corporate_account_name,
            tv.employee_id,
            coalesce(tv.full_name, tv.transaction_card_holder_name) as person_name,
            tv.work_email,
            tv.transaction_card_holder_name,
            tv.transaction_default_cost_centers_full_path,
            cd.market_id::varchar as employee_market_id,
            emp_market.name as employee_market_name,
            emp_mrx.division_name as employee_division_name,
            tv.upload_market_id as coded_market_id,
            coded_market.name as coded_market_name,
            coded_mrx.division_name as coded_division_name,
            tv.sub_department_id,
            tv.sub_department,
            tv.expense_line_id,
            tv.expense_line,
            tv.verified_status,
            tv.verified_status_desc,
            tv.upload_notes,
            tv.upload_submitted_at_date,
            tv.upload_modified_at_date,
            tv.upload_url,
            case
                when emp_mrx.division_name = 'Vehicle Solutions'
                    then 'Vehicle Solutions Store'
                when coded_mrx.division_name = 'Vehicle Solutions'
                    then 'Vehicle Solutions Store'
                else 'Out of Scope'
            end as vehicle_solutions_scope
        from analytics.credit_card.transaction_verification as tv
            left join analytics.payroll.company_directory as cd
                on tv.employee_id = cd.employee_id
            left join analytics.public.market_region_xwalk as emp_mrx
                on cd.market_id::varchar = emp_mrx.market_id::varchar
            left join es_warehouse.public.markets as emp_market
                on cd.market_id::varchar = emp_market.market_id::varchar
            left join analytics.public.market_region_xwalk as coded_mrx
                on tv.upload_market_id::varchar = coded_mrx.market_id::varchar
            left join es_warehouse.public.markets as coded_market
                on tv.upload_market_id::varchar = coded_market.market_id::varchar
      )

      select
      vehicle_solutions_scope,
      transaction_month,
      coding_month,
      transaction_date,
      upload_date,
      coded_market_id,
      coded_market_name,
      coded_division_name,
      employee_market_id,
      employee_market_name,
      employee_division_name,
      person_name,
      employee_id,
      work_email,
      transaction_id,
      transaction_card_type,
      corporate_account_name,
      transaction_merchant_name,
      transaction_amount,
      transaction_mcc_code,
      transaction_mcc,
      sub_department_id,
      sub_department,
      expense_line_id,
      expense_line,
      verified_status,
      verified_status_desc,
      transaction_default_cost_centers_full_path,
      upload_notes,
      upload_submitted_at_date,
      upload_modified_at_date,
      upload_url
      from base
      where vehicle_solutions_scope != 'Out of Scope' ;;
  }

  dimension: transaction_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: vehicle_solutions_scope {
    type: string
    sql: ${TABLE}.vehicle_solutions_scope ;;
  }

  dimension_group: transaction {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.transaction_date ;;
  }

  dimension_group: transaction_month {
    type: time
    timeframes: [raw, month, quarter, year]
    sql: ${TABLE}.transaction_month ;;
  }

  dimension_group: coding_month {
    type: time
    timeframes: [raw, month, quarter, year]
    sql: ${TABLE}.coding_month ;;
  }

  dimension_group: upload {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.upload_date ;;
  }

  dimension_group: upload_submitted_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.upload_submitted_at_date ;;
  }

  dimension_group: upload_modified_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.upload_modified_at_date ;;
  }

  dimension: coded_market_id {
    type: string
    sql: ${TABLE}.coded_market_id ;;
  }

  dimension: coded_market_name {
    type: string
    sql: ${TABLE}.coded_market_name ;;
  }

  dimension: coded_division_name {
    type: string
    sql: ${TABLE}.coded_division_name ;;
  }

  dimension: employee_market_id {
    type: string
    sql: ${TABLE}.employee_market_id ;;
  }

  dimension: employee_market_name {
    type: string
    sql: ${TABLE}.employee_market_name ;;
  }

  dimension: market_name {
    type: string
    sql: coalesce(${coded_market_name},${employee_market_name}) ;;
  }

  dimension: employee_division_name {
    type: string
    sql: ${TABLE}.employee_division_name ;;
  }

  dimension: person_name {
    type: string
    sql: ${TABLE}.person_name ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.employee_id ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}.work_email ;;
  }

  dimension: transaction_card_type {
    type: string
    sql: ${TABLE}.transaction_card_type ;;
  }

  dimension: corporate_account_name {
    type: string
    sql: ${TABLE}.corporate_account_name ;;
  }

  dimension: transaction_merchant_name {
    type: string
    sql: ${TABLE}.transaction_merchant_name ;;
  }

  dimension: transaction_mcc_code {
    type: string
    sql: ${TABLE}.transaction_mcc_code ;;
  }

  dimension: transaction_mcc {
    type: string
    sql: ${TABLE}.transaction_mcc ;;
  }

  dimension: sub_department_id {
    type: string
    sql: ${TABLE}.sub_department_id ;;
  }

  dimension: sub_department {
    type: string
    sql: ${TABLE}.sub_department ;;
  }

  dimension: expense_line_id {
    type: string
    sql: ${TABLE}.expense_line_id ;;
  }

  dimension: expense_line {
    type: string
    sql: ${TABLE}.expense_line ;;
  }

  dimension: verified_status {
    type: string
    sql: ${TABLE}.verified_status ;;
  }

  dimension: verified_status_desc {
    type: string
    sql: ${TABLE}.verified_status_desc ;;
  }

  dimension: transaction_default_cost_centers_full_path {
    type: string
    sql: ${TABLE}.transaction_default_cost_centers_full_path ;;
  }

  dimension: upload_notes {
    type: string
    sql: ${TABLE}.upload_notes ;;
  }

  dimension: transaction_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.transaction_amount ;;
  }

  dimension: upload_url {
    hidden: yes
    type: string
    sql:
    case
      when ${TABLE}.upload_url is null then null
      when trim(${TABLE}.upload_url) = '' then null
      else trim(${TABLE}.upload_url)
    end ;;
  }

  dimension: receipt_link {
    label: "Link to Receipt"
    type: string
    sql: ${upload_url} ;;
    html:
    {% assign cleaned_value = value | strip %}
    {% if cleaned_value != blank %}
      <a href="{{ cleaned_value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">
        Link to CC Receipt
      </a>
    {% endif %} ;;
  }

  measure: link_to_receipt {
    label: "Link to Receipts"
    type: list
    list_field: receipt_link
  }

  measure: count {
    type: count
    drill_fields: [transaction_id, person_name, transaction_merchant_name, transaction_amount]
  }

  measure: total_transaction_amount {
    type: sum
    value_format_name: usd
    sql: ${transaction_amount} ;;
  }
}
