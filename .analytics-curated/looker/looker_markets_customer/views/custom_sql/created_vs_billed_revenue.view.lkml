view: created_vs_billed_revenue {
  derived_table: {
    sql:
      select date_trunc('month', li.gl_billing_approved_date)::DATE as date,
        i.ship_from:branch_id as market_id,
        FALSE as date_created_bool,
        mg.revenue_goals,
        i.invoice_id,
        li.line_item_id,
        li.credit_note_line_item_id,
        li.amount
    from ES_WAREHOUSE.PUBLIC.invoices i
      left join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
      left join market_region_xwalk m on m.market_id = i.ship_from:branch_id
      left join market_goals mg on mg.market_id = m.market_id and
                                  (date_trunc('month', li.gl_billing_approved_date::DATE) =
                                  date_trunc('month', mg.months::date) and
                                  date_trunc('year', li.gl_billing_approved_date::DATE) =
                                  date_trunc('year', mg.months::date))
        where li.line_item_type_id in (6,8,108,109)
        and date_trunc('month', li.gl_billing_approved_date::DATE) >=
          (date_trunc('month', current_date) - interval '5 months')
    UNION ALL
      select date_trunc('month', li.gl_date_created)::DATE as date,
        i.ship_from:branch_id as market_id,
        TRUE as date_created_bool,
        null as revenue_goals,
        i.invoice_id,
        li.line_item_id,
        li.credit_note_line_item_id,
        li.amount
    from ES_WAREHOUSE.PUBLIC.invoices i
      left join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
      left join market_region_xwalk m on m.market_id = i.ship_from:branch_id
      where li.line_item_type_id in (6,8,108,109)
      and date_trunc('month', li.gl_date_created::DATE) >=
          (date_trunc('month', current_date) - interval '5 months')
;;
  }

  dimension_group: date {
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
    sql: CAST(${TABLE}."DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: date_created_bool {
    type: yesno
    sql: ${TABLE}."DATE_CREATED_BOOL" ;;
  }

  dimension: revenue_goals {
    type: number
    sql: ${TABLE}."REVENUE_GOALS" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: invoice_id_pk {
    type: number
    sql: concat(${TABLE}."INVOICE_ID", ${TABLE}."LINE_ITEM_ID",COALESCE(${TABLE}."CREDIT_NOTE_LINE_ITEM_ID",0) ) ;;
    primary_key: yes
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: billing_approved_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_bool: "False"]
  }

  measure: date_created_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_bool: "True"]
  }

  }
