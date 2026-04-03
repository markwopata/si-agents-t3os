view: units_on_rent_rolling_90_days {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
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
                      , o.market_id
                      , m.name
                      , ea.asset_id
                      , ea.start_date
                      , ea.end_date
                      , o.salesperson_user_id
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
                          JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea
                               ON r.rental_id = ea.rental_id
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
                               ON rdl.rental_day::date BETWEEN ea.start_date::date
                               AND coalesce(ea.end_date::date, '2099-12-31')
                 WHERE m.company_id = 1854
                   and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
             )
    SELECT rental_day
        , market_id as rental_branch_id
        , name as market_name
        , count(asset_id) as units_on_rent
        , sum(oec) as oec_on_rent
        , current_date() as last_updated
    FROM on_rent
    GROUP BY rental_day, market_id, name
     ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_day {
    type: date
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
    primary_key: yes
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: last_updated {
    type: date
    sql: ${TABLE}."LAST_UPDATED" ;;
  }

  measure: Unit_Total {
    type:  sum
    sql: ${units_on_rent} ;;
  }

  measure: OEC_Total {
    type:  sum
    sql: ${oec_on_rent} ;;
    value_format:"0.0,,\" M\""
  }

  set: detail {
    fields: [rental_day, rental_branch_id, market_name, units_on_rent, oec_on_rent]
  }

}
