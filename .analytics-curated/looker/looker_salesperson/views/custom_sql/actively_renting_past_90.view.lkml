view: actively_renting_past_90 {
    derived_table: {
      # datagroup_trigger: Every_Two_Hours_Update
      sql: with get_past_days as
        (
          select
              convert_timezone('America/Chicago',dateadd(
              day,
              '-' || row_number() over (order by null),
              dateadd(day, '+2', current_date())
              )) as generateddate
              from table (generator(rowcount => 91))
        )

        select pd.generateddate,
                coalesce(os.user_id,o.salesperson_user_id) as salesperson_user_id,
                u.first_name,
                u.last_name,
                o.market_id,
                mrx.market_name,
                mrx.region_name,
                mrx.district,
                c.company_id,
                ea.asset_id
        FROM ES_WAREHOUSE.PUBLIC.ORDERS AS o
        INNER JOIN ES_WAREHOUSE.PUBLIC.RENTALS as r on r.order_id = o.order_id
        INNER JOIN ES_WAREHOUSE.public.equipment_assignments  AS ea ON ea.rental_id = r.rental_id
        INNER JOIN ES_WAREHOUSE.public.assets  AS a ON a.asset_id = ea.asset_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os on os.order_id = o.order_id
        LEFT JOIN ES_WAREHOUSE.public.users  AS u ON coalesce(os.user_id,o.salesperson_user_id) = u.user_id
        LEFT JOIN ES_WAREHOUSE.public.markets  AS m ON m.market_id = o.market_id
        LEFT JOIN market_region_xwalk  AS mrx ON mrx.market_id = m.market_id
        LEFT JOIN ES_WAREHOUSE.public.users  AS cu ON o.user_id = cu.user_id
        LEFT JOIN ES_WAREHOUSE.public.companies  AS c ON cu.company_id = c.company_id
        JOIN get_past_days pd on pd.generateddate between ea.start_date::date and coalesce(ea.end_date::date, '2999-12-31')
        WHERE
            m.company_id  = 1854
            AND ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
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



    dimension: full_name {
      type: string
      sql: concat(${first_name},' ',${last_name}) ;;
    }

    dimension: full_name_with_id {
      type: string
      sql: concat(${first_name},' ',${last_name},' - ',${salesperson_user_id})  ;;
    }

    dimension: market {
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: region {
      type: string
      sql: ${TABLE}."REGION_NAME" ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: company_id {
      type: number
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: is_today {
      type: yesno
      sql: ${generateddate_date} = CURRENT_DATE() ;;
    }

  dimension: is_mtd {
    type: yesno
    sql: ${generateddate_raw}> TO_DATE(DATE_TRUNC('month', CURRENT_DATE())) AND ${generateddate_raw} < TO_DATE(DATEADD('month', 1, DATE_TRUNC('month', CURRENT_DATE()))) ;;
  }


  measure: number_of_companies_renting {
    type: count_distinct
    drill_fields: [detail*]
    sql: ${company_id}  ;;
  }

  measure: number_of_assets_on_rent {
    type: count_distinct
    drill_fields: [detail*]
    sql: ${asset_id} ;;
  }


    set: detail {
      fields: [generateddate_date, market, salesperson_user_id, first_name, last_name, number_of_companies_renting, number_of_assets_on_rent]
    }
  }
