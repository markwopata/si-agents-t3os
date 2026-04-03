view: in_out_market_revenue_ttm {
  derived_table: {
    sql:
        select aicld.invoice_number,
           aicld.invoice_id,
           aicld.gl_date,
           aicld.billing_approved_date,
           aicld.is_billing_approved,
           aicld.invoice_date,
           aicld.market_id,
           aicld.market_name,
           aicld.company_id as customer_id,
           aicld.customer_name,
           aicld.line_item_id,
           aicld.credit_note_line_item_id,
           aicld.line_item_type_id,
           aicld.line_item_type_name,
           aicld.account_number,
           aicld.account_name,
           aicld.amount,
           aicld.url_invoice_admin,
           u.branch_id,
           u.employee_id,
           case when aicld.market_id != u.branch_id then false else true end as is_in_market_revenue
    from analytics.intacct_models.int_admin_invoice_and_credit_line_detail aicld
             left join es_warehouse.public.users u
                       on aicld.primary_salesperson_id = u.user_id
    -- exclude intercompany transactions
    where aicld.is_intercompany = false
      -- exclude deleted invoices
      and aicld.is_deleted = false
      and aicld.line_item_type_id in (6, 8, 108, 109)
      and date_trunc('month', aicld.billing_approved_date::date) between
                      date_trunc('month',dateadd(month, -11,
                                    (select min(trunc::date)
                                     from analytics.gs.plexi_periods
                                     where {% condition period_name %} display {% endcondition %})))
                      and
                      date_trunc('month',
                                    (select max(trunc::date)
                                     from analytics.gs.plexi_periods
                                     where {% condition period_name %} display {% endcondition %}));;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension_group: gl_date {
    type: time
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: billing_approved_date {
    type: time
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: is_billing_approved {
    type: yesno
    sql: ${TABLE}."IS_BILLING_APPROVED" ;;
  }

  dimension: invoice_date {
    type: date_time
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type_name {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: branch_id {
    type: string
    label: "Salesperson Market ID"
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: employee_id {
    type: string
    label: "Salesperson Employee ID"
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }


  dimension: links {
    label: "URL Invoice Admin"
    type: string
    sql: ${TABLE}.URL_INVOICE_ADMIN ;;
    html:
    <a href="{{ value }}" target="_blank">
      <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png"
           width="16" height="16">
      Admin
    </a> ;;
  }


  dimension: is_in_market_revenue {
    type: yesno
    sql:${TABLE}."IS_IN_MARKET_REVENUE";;
  }

  measure: amount {
    group_label: "Market Revenue"
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_in_market_revenue {
    group_label: "Market Revenue"
    type: sum
    sql: CASE WHEN ${is_in_market_revenue} THEN ${TABLE}."AMOUNT" END;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_out_market_revenue {
    group_label: "Market Revenue"
    type: sum
    sql: CASE WHEN NOT ${is_in_market_revenue} THEN ${TABLE}."AMOUNT" END;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }


  set: detail {
    fields: [
      invoice_number,
      customer_name,
      billing_approved_date_date,
      gl_date_date,
      account_number,
      account_name,
      links
    ]
  }
}
