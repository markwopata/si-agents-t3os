view: companies_actively_renting_by_sales_rep_past_90 {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: with get_past_days as
        (
          select
              convert_timezone('America/Chicago',dateadd(
              day,
              '-' || row_number() over (order by null),
              dateadd(day, '+1', current_date())
              )) as generateddate
              from table (generator(rowcount => 90))
        )
      select
        pd.generateddate,
        coalesce(os.user_id,o.salesperson_user_id) as salesperson_user_id,
        u.first_name,
        u.last_name,
        COUNT(DISTINCT (c.company_id) ) AS companies_number_of_companies_distinct_count
      FROM ES_WAREHOUSE.public.orders  AS o
      INNER JOIN ES_WAREHOUSE.public.rentals  AS r ON r.order_id = o.order_id
      INNER JOIN ES_WAREHOUSE.public.equipment_assignments  AS ea ON ea.rental_id = r.rental_id
      INNER JOIN ES_WAREHOUSE.public.assets  AS a ON a.asset_id = ea.asset_id
      LEFT JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os on os.order_id = o.order_id
      LEFT JOIN ES_WAREHOUSE.public.users  AS u ON coalesce(os.user_id,o.salesperson_user_id) = u.user_id
      LEFT JOIN ES_WAREHOUSE.public.markets  AS m ON m.market_id = o.market_id
      LEFT JOIN market_region_xwalk  AS mrx ON mrx.market_id = m.market_id
      LEFT JOIN ES_WAREHOUSE.public.users  AS cu ON o.user_id = cu.user_id
      LEFT JOIN ES_WAREHOUSE.public.companies  AS c ON cu.company_id = c.company_id
      join get_past_days pd on pd.generateddate between ea.start_date::date and coalesce(ea.end_date::date, '2999-12-31')
      WHERE
      m.company_id  = 1854
      AND ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
      group by
      pd.generateddate,
      coalesce(os.user_id,o.salesperson_user_id),
      u.first_name,
      u.last_name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: generateddate {
    type: time
    sql: ${TABLE}."GENERATEDDATE" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: companies_number_of_companies_distinct_count {
    type: number
    sql: ${TABLE}."COMPANIES_NUMBER_OF_COMPANIES_DISTINCT_COUNT" ;;
  }

  measure: number_of_companies_renting {
    type: sum
    sql: ${companies_number_of_companies_distinct_count} ;;
  }

  dimension: full_name {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: sql: concat(${first_name},' ',${last_name},' - ',${salesperson_user_id})  ;;
  }

  set: detail {
    fields: [generateddate_time, salesperson_user_id, first_name, last_name, companies_number_of_companies_distinct_count]
  }
}
