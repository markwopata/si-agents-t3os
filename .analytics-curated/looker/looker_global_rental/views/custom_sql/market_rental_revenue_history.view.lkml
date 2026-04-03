view: market_rental_revenue_history {
  derived_table: {
    # datagroup_trigger: Every_5_Min_Update
    sql:  select m.market_id as branch_id,
            m.name as branch,
            i.order_id,
            li.rental_id as rental_id,
            i.invoice_no as invoice_name,
            convert_timezone('{{ _user_attributes['user_timezone'] }}', i.invoice_date) as issue_date,
            convert_timezone('{{ _user_attributes['user_timezone'] }}', i.due_date) as due_date,
            i.status as invoice_status,
            --m.name as market_name,
            --mg.revenue_goals,
            li.sub_total as rental_revenue,
            li.tax,
            li.total
          from
            ES_WAREHOUSE.PUBLIC.orders o
            join ES_WAREHOUSE.PUBLIC.global_invoices i on i.order_id = o.order_id
            join ES_WAREHOUSE.PUBLIC.global_line_items li on li.invoice_id = i.invoice_id
            left join ES_WAREHOUSE.PUBLIC.markets m on m.market_id = o.market_id
            --left join market_goals mg on mg.market_id = m.market_id and (date_trunc('month',i.billing_approved_date::DATE) = date_trunc('month',mg.months::date) and date_trunc('year',i.billing_approved_date::DATE) = date_trunc('year',mg.months::date))
          where
            li.line_item_type_id = 1
            and date_trunc('month',i.invoice_date::DATE) >= (date_trunc('month', current_date) - interval '6 months')
            --and li.charge_id = 1
            and i.deleted_date is null
            and li.deleted_date is null
            and m.company_id = {{ _user_attributes['company_id'] }}
            and i.status = 'approved'
       ;;
  }

  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: CONCAT(${rental_id}, ${invoice_name});;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID";;
    value_format_name: id
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH";;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID";;
    value_format_name: id
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID";;
    value_format_name: id
  }

  dimension: invoice_name {
    type: string
    sql: ${TABLE}."INVOICE_NAME";;
  }

  dimension: issue_date {
    label: "issue"
    type: date_time
    sql: ${TABLE}."ISSUE_DATE" ;;
  }

  dimension_group: issue_date {
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
    sql: ${TABLE}."ISSUE_DATE" ;;
  }

  dimension: due_date {
    type: date_time
    sql: ${TABLE}."DUE_DATE";;
  }

  dimension: invoice_status {
    type: string
    sql: ${TABLE}."INVOICE_STATUS";;
  }

  dimension: rental_revenue {
    label: "Subtotal"
    type: number
    sql: ${TABLE}."RENTAL_REVENUE";;
    value_format_name: usd_0
  }

  dimension: tax {
    type: number
    sql: ${TABLE}."TAX";;
    value_format_name: usd_0
  }

  dimension: total {
    type: number
    sql: ${TABLE}."TOTAL";;
    value_format_name: usd_0
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
    drill_fields: [invoice_name,  issue_date, due_date, rental_revenue, tax, total]
  }

  dimension: MTD {
    type: yesno
    sql: month(${issue_date_raw}) = month(current_date);;
  }

  dimension: current_year_issue_date {
    type: yesno
    sql: year(${issue_date_raw}) = year(current_date) ;;
  }

  dimension: last_year_issue_date {
    type: yesno
    sql: year(${issue_date_raw}) = year(dateadd('year', -1, current_date)) ;;
  }


  measure: MTD_rental_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    filters: [MTD: "yes"]
    value_format_name: usd_0
    drill_fields: [invoice_name,  issue_date, due_date, rental_revenue, tax, total]
  }

  measure: current_year_rental_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    filters: [current_year_issue_date: "yes"]
    value_format_name: usd_0
    drill_fields: [invoice_name,  issue_date, due_date, rental_revenue, tax, total]
  }

  measure: last_year_rental_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    filters: [last_year_issue_date: "yes"]
    value_format_name: usd_0
    drill_fields: [invoice_name,  issue_date, due_date, rental_revenue, tax, total]
  }
  }
