view: units_on_rent_rolling_90_days_by_salesperson {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
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
    , concat(u.first_name,' ',u.last_name) as rep_name
    , ea.asset_id
    , ea.start_date
    , ea.end_date
    , coalesce(os.user_id,o.salesperson_user_id) as sales_id
    , coalesce(oec.purchase_price
    , (SELECT avg(purchase_price) as avg_oec
    FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
    WHERE company_id = 1854
    AND purchase_history_id in
    (SELECT max(purchase_history_id)
    FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
    GROUP BY asset_id))) as oec
    FROM ES_WAREHOUSE.PUBLIC.orders o
    JOIN ES_WAREHOUSE.PUBLIC.rentals r
    ON o.order_id = r.order_id
    JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea
    ON r.rental_id = ea.rental_id
    JOIN ES_WAREHOUSE.PUBLIC.assets a
    ON ea.asset_id = a.asset_id
    LEFT JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os
    on os.order_id = o.order_id
    LEFT JOIN ES_WAREHOUSE.PUBLIC.users u
    ON coalesce(os.user_id,o.salesperson_user_id) = u.user_id
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
    AND
    {% if _user_attributes['department']  == "'salesperson'" %}
    u.email_address = '{{ _user_attributes['email'] }}'
    {% else %}
    1 = 1
    {% endif %}
    )

    SELECT rental_day
    , rep_name
    , concat(rep_name,' - ',sales_id) as full_name_with_id
    , count(asset_id) as on_rent
    , sum(oec) as oec_on_rent
    , current_timestamp() as last_updated
    , sales_id
    FROM on_rent
    GROUP BY rental_day, sales_id, rep_name, concat(rep_name,' - ',sales_id)
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
  }

  dimension: last_updated {
    type: date
    sql: ${TABLE}."LAST_UPDATED" ;;
  }

  dimension: sales_id {
    type: number
    sql: ${TABLE}."SALES_ID" ;;
  }

  measure: Total_Units {
    type: sum
    sql: ${on_rent} ;;
    drill_fields: [rep_name,rental_day,on_rent]
  }

  measure: Total_OEC {
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd
    drill_fields: [rep_name,rental_day,oec_on_rent]
  }

  set: detail {
    fields: [
      rental_day,
      rep_name,
      full_name_with_id,
      on_rent,
      oec_on_rent,
      last_updated,
      sales_id
    ]
  }
}
