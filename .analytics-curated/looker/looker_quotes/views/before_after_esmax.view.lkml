
view: before_after_esmax {
  derived_table: {
    sql: with current_total_amount as (
          SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,
           sum(li.AMOUNT) as total_amount,
           date_trunc(month, li.GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                   WHERE li.GL_DATE_CREATED >= '01/01/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        AND i.SALESPERSON_USER_ID in (13157,13852,20690,21124,21332,21335,23976,27010,
                                                      32809,44436,50556,64440,65203,71646,76361,81370,
                                                      82243,86416,99052,109981)
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
      ),
      above_online as (
          SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           sum(li.AMOUNT) as above_online_billing_approved,
           date_trunc(month, li.GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                   WHERE li.GL_DATE_CREATED >= '01/01/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        AND i.SALESPERSON_USER_ID in (13157,13852,20690,21124,21332,21335,23976,27010,
                                                      32809,44436,50556,64440,65203,71646,76361,81370,
                                                      82243,86416,99052,109981)
                        and RATE_TIER = 1
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
      ),
      between_floor as (
          SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           sum(li.AMOUNT) as between_floor_billing_approved,
           date_trunc(month, li.GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                   WHERE li.GL_DATE_CREATED >= '01/01/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        AND i.SALESPERSON_USER_ID in (13157,13852,20690,21124,21332,21335,23976,27010,
                                                      32809,44436,50556,64440,65203,71646,76361,81370,
                                                      82243,86416,99052,109981)
                        and RATE_TIER in (0,2,null)
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
      ),
      below_floor as (
          SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           sum(li.AMOUNT) as below_floor_billing_approved,
           date_trunc(month, GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                   WHERE li.GL_DATE_CREATED >= '01/01/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        AND i.SALESPERSON_USER_ID in (13157,13852,20690,21124,21332,21335,23976,27010,
                                                      32809,44436,50556,64440,65203,71646,76361,81370,
                                                      82243,86416,99052,109981)
                        and RATE_TIER = 3
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
      ),
      first_quote_date as (
          select sales_rep_id,
                 min(created_date) first_quote
          from quotes.quotes.quote
          group by sales_rep_id
      ),
      es_max as (
      select ci.salesperson_id,
             ci.salesperson_full_name,
             ci.billing_approved_month,
             ci.total_amount,
             ao.above_online_billing_approved as above_online_billing,
             bef.between_floor_billing_approved as between_floor_billing,
             bf.below_floor_billing_approved as below_floow_billing,
             date_trunc('month',fqd.first_quote) as first_quote_month,
             case when ci.billing_approved_month <= fqd.first_quote then 'Before ESMAX' else 'After ESMAX' end as es_max_time
      from current_total_amount ci
          join above_online ao
          on ao.salesperson_id = ci.salesperson_id and ao.billing_approved_month = ci.billing_approved_month
          join between_floor bef
          on bef.salesperson_id = ci.salesperson_id and bef.billing_approved_month = ci.billing_approved_month
          join below_floor bf
          on bf.salesperson_id = ci.salesperson_id and bf.billing_approved_month = ci.billing_approved_month
          left join first_quote_date fqd
          on fqd.sales_rep_id = ci.salesperson_id
      )
      select ci.salesperson_id,
             ci.salesperson_full_name,
             ci.billing_approved_month,
             em.first_quote_month,
             em.es_max_time,
             em.above_online_billing::INT as above_online_billing,
             em.between_floor_billing::INT as between_floor_billing,
             em.below_floow_billing::INT as below_floow_billing
      from current_total_amount ci
          join es_max em
          on em.salesperson_id = ci.salesperson_id and em.billing_approved_month = ci.billing_approved_month
      order by ci.salesperson_id, ci.billing_approved_month ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_id {
    type: number
    sql: ${TABLE}."SALESPERSON_ID" ;;
  }

  dimension: salesperson_full_name {
    type: string
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension_group: billing_approved_month {
    type: time
    sql: ${TABLE}."BILLING_APPROVED_MONTH" ;;
  }

  dimension_group: first_quote_month {
    type: time
    sql: ${TABLE}."FIRST_QUOTE_MONTH" ;;
  }

  dimension: es_max_time {
    type: string
    sql: ${TABLE}."ES_MAX_TIME" ;;
  }

  dimension: above_online_billing {
    type: number
    sql: ${TABLE}."ABOVE_ONLINE_BILLING" ;;
  }

  dimension: between_floor_billing {
    type: number
    sql: ${TABLE}."BETWEEN_FLOOR_BILLING" ;;
  }

  dimension: below_floow_billing {
    type: number
    sql: ${TABLE}."BELOW_FLOOW_BILLING" ;;
  }

  measure: above {
    label: "Above Online Billing Approved"
    type: sum
    sql: ${above_online_billing} ;;
  }

  measure: between {
    label: "Between Floor Online Billing Approved"
    type: sum
    sql: ${between_floor_billing} ;;
  }

  measure: below {
    label: "Below Floor Billing Approved"
    type: sum
    sql: ${below_floow_billing} ;;
  }

  measure: before_esmax_above_online_billing {
    type: sum
    sql: ${above_online_billing} ;;
    filters: [es_max_time: "Before ESMAX"]
  }

  measure: before_esmax_between_floor_billing {
    type: sum
    sql: ${between_floor_billing} ;;
    filters: [es_max_time: "Before ESMAX"]
  }

  measure: before_esmax_below_floor_billing {
    type: sum
    sql: ${below_floow_billing} ;;
    filters: [es_max_time: "Before ESMAX"]
  }

  measure: after_esmax_above_online_billing {
    type: sum
    sql: ${above_online_billing} ;;
    filters: [es_max_time: "After ESMAX"]
  }

  measure: after_esmax_between_floor_billing {
    type: sum
    sql: ${between_floor_billing} ;;
    filters: [es_max_time: "After ESMAX"]
  }

  measure: after_esmax_below_floor_billing {
    type: sum
    sql: ${below_floow_billing} ;;
    filters: [es_max_time: "After ESMAX"]
  }

  set: detail {
    fields: [
        salesperson_id,
  salesperson_full_name,
  billing_approved_month_time,
  first_quote_month_time,
  es_max_time,
  above_online_billing,
  between_floor_billing,
  below_floow_billing
    ]
  }
}
