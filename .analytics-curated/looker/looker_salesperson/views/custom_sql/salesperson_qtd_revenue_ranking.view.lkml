view: salesperson_qtd_revenue_ranking {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with qtd_revenue as (
      select
        ais.primary_salesperson_id as salesperson_user_id,
        concat(u.first_name, ' ', u.last_name) as Salesperson,
        sum(li.amount) as qtd_revenue,
        mr.market_name as Market_Name
       from
          ES_WAREHOUSE.PUBLIC.orders o
          join ES_WAREHOUSE.PUBLIC.rentals r on o.order_id = r.order_id
          left join ES_WAREHOUSE.PUBLIC.invoices i on o.order_id = i.order_id
          left join ANALYTICS.PUBLIC.v_line_items li on i.invoice_id = li.invoice_id
          left join ES_WAREHOUSE.PUBLIC.approved_invoice_salespersons ais on i.invoice_id = ais.invoice_id
          join ES_WAREHOUSE.PUBLIC.line_item_types lty on li.line_item_type_id = lty.line_item_type_id
          join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ais.primary_salesperson_id
          left join market_region_xwalk mr on mr.market_id  = coalesce(o.market_id,li.branch_id)
        where
          u.last_name <> 'House Sales'
          and date_trunc(year,convert_timezone('America/Chicago',li.gl_billing_approved_date))::date = (date_trunc('year', current_date::date))
          and date_trunc(quarter,convert_timezone('America/Chicago',li.gl_billing_approved_date))::date = (date_trunc('quarter', current_date::date))
          and li.line_item_type_id in (6,8,108,109)
       group by
          ais.primary_salesperson_id, u.first_name, u.last_name, mr.market_name
       ),
       last_month_revenue as (
       select
       ais.primary_salesperson_id as salesperson_user_id,
       concat(u.first_name, ' ', u.last_name) as Salesperson,
       sum(li.amount) as last_month_revenue,
       mr.market_name as Market_Name
      from
          ES_WAREHOUSE.PUBLIC.orders o
          join ES_WAREHOUSE.PUBLIC.rentals r on o.order_id = r.order_id
          left join ES_WAREHOUSE.PUBLIC.invoices i on o.order_id = i.order_id
          left join ANALYTICS.PUBLIC.v_line_items li on i.invoice_id = li.invoice_id
          left join ES_WAREHOUSE.PUBLIC.approved_invoice_salespersons ais on i.invoice_id = ais.invoice_id
          join ES_WAREHOUSE.PUBLIC.line_item_types lty on li.line_item_type_id = lty.line_item_type_id
          join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ais.primary_salesperson_id
          left join market_region_xwalk mr on mr.market_id  = coalesce(o.market_id,li.branch_id)
        where
          not u.last_name = 'House Sales'
        and date_trunc(year,convert_timezone('America/Chicago',li.gl_billing_approved_date))::date = (date_trunc('year', current_date::date - interval '1 month'))
        and date_trunc(month,convert_timezone('America/Chicago',li.gl_billing_approved_date))::date = (date_trunc('month', current_date::date - interval '1 month'))
          and li.line_item_type_id in (6,8,108,109)
       group by
          ais.primary_salesperson_id, u.first_name, u.last_name, mr.market_name
       ),
       qtd_revenue_total_salesperson as (
       select
        salesperson_user_id,
        salesperson,
        sum(qtd_revenue) as ttl_qtd_revenue
       from
        qtd_revenue
       group by
          salesperson_user_id,
        salesperson
      ),
      rank_salesperson_qtd_revenue as (
      select
        *,
        RANK() OVER(
        order by ttl_qtd_revenue desc
        ) as ranking
      from
        qtd_revenue_total_salesperson
      )
      select
        qre.salesperson_user_id,
        qre.salesperson,
        qre.market_name,
        qre.qtd_revenue,
        lmr.last_month_revenue,
        rsr.ranking
      from
        qtd_revenue qre
        left join last_month_revenue lmr on lmr.salesperson_user_id = qre.salesperson_user_id and lmr.salesperson = qre.salesperson and qre.market_name = lmr.market_name
        left join rank_salesperson_qtd_revenue rsr on rsr.salesperson_user_id = qre.salesperson_user_id and rsr.salesperson = qre.salesperson
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
    drill_fields: [detail*]
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: salesperson_market {
    primary_key: yes
    type: string
    sql: concat(${salesperson_user_id},' ',${market_name}) ;;
  }

  dimension: qtd_revenue {
    type: number
    sql: ${TABLE}."QTD_REVENUE" ;;
  }

  dimension: last_month_revenue {
    type: number
    sql: ${TABLE}."LAST_MONTH_REVENUE" ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: rank {
    type: number
    sql: ${TABLE}."RANKING" ;;
    link: {
      label: "View Leaderboard"
      url: "https://equipmentshare.looker.com/dashboards/24"
    }
  }

  measure: last_month_total_revenue {
    type: sum
    sql: ${last_month_revenue} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: QTD_revenue_total{
    type: sum
    sql: ${qtd_revenue};;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: full_name_with_id {
    type: string
    sql: concat(${salesperson}, ' - ',${salesperson_user_id}) ;;
  }

  set: detail {
    fields: [salesperson, salesperson_user_id, market_name, QTD_revenue_total, last_month_revenue]
  }
}
