view: product_specialist_orders {
  derived_table: {
    sql:
        WITH dated_orders AS (
                                SELECT os.*,
                                       o.date_created,
                                       o.market_id
                                  FROM es_warehouse.public.order_salespersons os
                                           LEFT JOIN es_warehouse.public.orders o
                                           ON os.order_id = o.order_id
                                 WHERE os.user_id IN (
                                                         SELECT salesperson_user_id
                                                           FROM analytics.public.commissions_salesperson_data
                                                          WHERE commission_type IN ('ITL', 'P&P'))
                                    AND os.salesperson_type_id = 2)
                                SELECT DISTINCT do.*
                                  FROM dated_orders do
                                           LEFT JOIN analytics.public.commissions_salesperson_data csd
                                           ON do.user_id = csd.salesperson_user_id
                                          -- AND do.date_created BETWEEN csd.guarantee_start_date AND csd.commission_end_date
                                 WHERE commission_type IN ('ITL', 'P&P');;
  }

    dimension: order_salesperson_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."ORDER_SALESPERSON_ID" ;;
    }

    dimension_group: _es_update_timestamp {
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
      sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    }

    dimension: commission {
      type: number
      sql: ${TABLE}."COMMISSION" ;;
    }

    dimension: order_id {
      type: number
      sql: ${TABLE}."ORDER_ID" ;;
    }

    dimension: market_id {
      type: number
      sql: ${TABLE}."MARKET_ID" ;;
      value_format_name: id
    }

    dimension: salesperson_type_id {
      type: string
      sql: case
            when ${TABLE}."SALESPERSON_TYPE_ID" = 1 then 'Primary'
            else 'Secondary'
            end;;
    }

    dimension: user_id {
      type: number
      sql: ${TABLE}."USER_ID" ;;
    }

  dimension_group: date_created {
    label: "From Orders table"
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

    measure: count {
      type: count
      drill_fields: [order_salesperson_id]
    }
}
