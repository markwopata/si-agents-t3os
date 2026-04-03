view: product_specialist_on_rent_rolling_90 {
  derived_table: {
    sql:
    WITH rental_day_list AS (
                                SELECT DATEADD(DAY, '-' || ROW_NUMBER() OVER (ORDER BY NULL), DATEADD(DAY, '+1', CURRENT_TIMESTAMP())) AS rental_day
                                  FROM TABLE (GENERATOR(ROWCOUNT => 90))),
        product_specialist_orders AS (
                                            WITH dated_orders AS (
                                                                     SELECT os.*,
                                                                            o.date_created
                                                                       FROM es_warehouse.public.order_salespersons os
                                                                                LEFT JOIN es_warehouse.public.orders o
                                                                                ON os.order_id = o.order_id
                                                                      WHERE os.user_id IN (
                                                                                              SELECT salesperson_user_id
                                                                                                FROM analytics.public.commissions_salesperson_data
                                                                                               WHERE commission_type IN ('ITL', 'P&P'))
                                                                          AND os.salesperson_type_id = 2)
                                          SELECT distinct do.*
                                            FROM dated_orders do
                                                     LEFT JOIN analytics.public.commissions_salesperson_data csd
                                                     ON do.user_id = csd.salesperson_user_id
                                                   --  AND do.date_created BETWEEN csd.guarantee_start_date AND csd.commission_end_date
                                           WHERE commission_type IN ('ITL', 'P&P')),
         on_rent         AS (
                                SELECT rdl.rental_day::date                                                                     AS rental_day,
                                       o.market_id,
                                       m.name,
                                       CONCAT(u.first_name,' ', u.last_name)                                                    AS rep_name,
                                       ea.asset_id,
                                       ea.start_date,
                                       ea.end_date,
                                       pso.user_id                                                                              AS user_id,
                                       pso.salesperson_type_id,
                                       COALESCE(oec.purchase_price, (
                                                                        SELECT AVG(purchase_price) AS avg_oec
                                                                          FROM es_warehouse.public.asset_purchase_history
                                                                         WHERE company_id = 1854
                                                                           AND purchase_history_id IN (
                                                                                                          SELECT MAX(purchase_history_id)
                                                                                                            FROM es_warehouse.public.asset_purchase_history
                                                                                                           GROUP BY asset_id))) AS oec
                                  FROM product_specialist_orders pso
                                           JOIN es_warehouse.public.orders o
                                           ON pso.order_id = o.order_id
                                           JOIN es_warehouse.public.rentals r
                                           ON o.order_id = r.order_id
                                           JOIN es_warehouse.public.equipment_assignments ea
                                           ON r.rental_id = ea.rental_id
                                           JOIN es_warehouse.public.assets a
                                           ON ea.asset_id = a.asset_id
                                           LEFT JOIN es_warehouse.public.users u
                                           ON pso.user_id = u.user_id
                                           LEFT JOIN es_warehouse.public.markets m
                                           ON o.market_id = m.market_id
                                           LEFT JOIN (
                                                         SELECT asset_id,
                                                                purchase_price
                                                           FROM es_warehouse.public.asset_purchase_history
                                                          WHERE purchase_history_id IN (
                                                                                           SELECT MAX(purchase_history_id)
                                                                                             FROM es_warehouse.public.asset_purchase_history
                                                                                            GROUP BY asset_id)) oec
                                           ON a.asset_id = oec.asset_id
                                           JOIN rental_day_list rdl
                                           ON rdl.rental_day BETWEEN (CONVERT_TIMEZONE('America/Chicago', ea.start_date)) AND COALESCE((CONVERT_TIMEZONE('America/Chicago', ea.end_date)), '2099-12-31')
                                 WHERE m.company_id = 1854
                                   AND ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' AND SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') OR
                                        a.serial_number IS NULL))
  SELECT rental_day,
         rep_name,
         CONCAT(rep_name, ' - ',user_id)   AS full_name_with_id,
         COUNT(asset_id)                   AS on_rent,
         SUM(oec)                          AS oec_on_rent,
         CURRENT_TIMESTAMP()               AS last_updated,
         user_id,
         salesperson_type_id
    FROM on_rent
   GROUP BY rental_day, user_id, rep_name, CONCAT(rep_name, ' - ',user_id), salesperson_type_id;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_day {
    type: date
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  dimension: rep_name {
    type: string
    sql: ${TABLE}."REP_NAME" ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: ${TABLE}."FULL_NAME_WITH_ID" ;;
  }

  dimension: on_rent {
    type: number
    sql: ${TABLE}."ON_RENT" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  dimension: last_updated {
    type: date
    sql: ${TABLE}."LAST_UPDATED" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: salesperson_type_id {
    type: string
    sql: case
          when ${TABLE}."SALESPERSON_TYPE_ID" = 1 then 'Primary'
          else 'Secondary'
          end;;
  }

  measure: Total_Units {
    type: sum
    sql: ${on_rent} ;;
    drill_fields: [rep_name,salesperson_type_id,rental_day,on_rent]
  }

  measure: Total_OEC {
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd
    drill_fields: [rep_name,salesperson_type_id,rental_day,oec_on_rent]
  }

  set: detail {
    fields: [
      rental_day,
      full_name_with_id,
      on_rent,
      oec_on_rent,
      last_updated,
      user_id
    ]
  }
}
