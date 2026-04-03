
view: customer_on_rent_rolling_90 {
  derived_table: {
    sql: WITH rental_day_list AS
              (
              select
              dateadd(
              day,
              '-' || row_number() over (order by null),
              dateadd(day, '+1', current_timestamp())
              ) as rental_day
              from table (generator(rowcount => 90))
              ),
                   on_rent as
                   (
                       SELECT rdl.rental_day::date as rental_day
                            ---, o.market_id
                            ---, m.name
                            , c.COMPANY_ID
                            , c.NAME
                            , ea.asset_id
                            , ea.start_date
                            , ea.end_date
                            , a.oec
                            /* coalesce(oec.purchase_price
                                  , (SELECT avg(purchase_price) as avg_oec
                                      FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                                      WHERE company_id = 1854
                                      AND purchase_history_id in
                                          (SELECT max(purchase_history_id)
                                              FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                                              GROUP BY asset_id))) as oec */
                       FROM ES_WAREHOUSE.PUBLIC.orders o
                                JOIN ES_WAREHOUSE.PUBLIC.rentals r
                                     ON o.order_id = r.order_id
                                JOIN ES_WAREHOUSE.PUBLIC.USERS customer_user
                                     on o.USER_ID = customer_user.USER_ID
                                JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c
                                     on customer_user.COMPANY_ID = c.COMPANY_ID
                                JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea
                                     ON r.rental_id = ea.rental_id
                                JOIN analytics.bi_ops.asset_ownership ao
                                     on ea.asset_id = ao.asset_id
                                JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate a
                                     ON ea.asset_id = a.asset_id
                                LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m
                                          ON o.market_id = m.market_id
                                LEFT JOIN (SELECT asset_id, purchase_price
                                           FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                                           WHERE purchase_history_id IN
                                                 (SELECT max(purchase_history_id)
                                                  FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
                                                  GROUP BY asset_id)) oec
                                          ON a.asset_id = oec.asset_id
                                JOIN rental_day_list rdl
                                     ON rdl.rental_day BETWEEN (convert_timezone('America/Chicago',ea.start_date))
                                     AND coalesce((convert_timezone('America/Chicago',ea.end_date)), '2099-12-31')
                       WHERE m.company_id = 1854
                         and ao.ownership in ('ES', 'OWN')
                   )
          SELECT rental_day
              , COMPANY_ID as customer_id
              , NAME as customer_name
              , count(asset_id) as units_on_rent
              , sum(oec) as oec_on_rent
              ---, current_date() as last_updated
          FROM on_rent
          GROUP BY rental_day, customer_id, customer_name ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_day {
    type: date
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: REPLACE(TRIM(${TABLE}."CUSTOMER_NAME"),CHAR(9), '') ;;
  }

  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  measure: total_units {
    type: sum
    sql: ${units_on_rent} ;;
  }

  set: detail {
    fields: [
        rental_day,
  customer_id,
  customer_name,
  units_on_rent,
  oec_on_rent
    ]
  }
}
