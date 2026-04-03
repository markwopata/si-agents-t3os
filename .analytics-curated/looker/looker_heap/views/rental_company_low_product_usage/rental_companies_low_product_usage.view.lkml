
view: rental_companies_low_product_usage {
  derived_table: {
    sql: with company_current_rentals as (
      select
          c.company_id,
          c.name as company_name,
          count(*) as current_rentals
      from
          es_warehouse.public.orders o
          join es_warehouse.public.users u on o.user_id = u.user_id
          join es_warehouse.public.rentals r on r.order_id = o.order_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
      where
          r.rental_status_id = 5
          AND r.rental_type_id <> 4
          AND c.company_id <> 1854
      group by
          c.company_id,
          c.name
      )
      , company_rentals_by_market_type as (
      select
          c.company_id,
          c.name as company_name,
          sum(case when mrx.market_type = 'Advanced Solutions' then 1 else null end) as advanced_solutions_rentals,
          sum(case when mrx.market_type = 'Core Solutions' then 1 else null end) as core_solutions_rentals,
          sum(case when mrx.market_type = 'ITL' then 1 else null end) as itl_rentals
      from
          es_warehouse.public.orders o
          join es_warehouse.public.users u on o.user_id = u.user_id
          join es_warehouse.public.rentals r on r.order_id = o.order_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
          join es_warehouse.public.assets a on a.asset_id = r.asset_id
          join analytics.public.market_region_xwalk mrx on mrx.market_id = a.rental_branch_id
      where
          r.rental_status_id = 5
          AND r.rental_type_id <> 4
          AND c.company_id <> 1854
      group by
          c.company_id,
          c.name
      )
      , company_rentals_last_30 as (
      select
          c.company_id,
          c.name as company_name,
          count(*) as previous_rentals
      from
          es_warehouse.public.orders o
          join es_warehouse.public.users u on o.user_id = u.user_id
          join es_warehouse.public.rentals r on r.order_id = o.order_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
      where
          r.rental_status_id not in (1,2,3,4,5,8) --open, draft,pending, scheduled, on rent, cancelled
          AND r.rental_type_id <> 4
          AND r.end_date BETWEEN dateadd(days,-30,current_date) AND current_timestamp
          AND c.company_id <> 1854
      group by
          c.company_id,
          c.name
      )
      ,sessions_last_30_days as (
      SELECT
          u.company_id,
          count(distinct(ss.session_id)) as total_sessions
      FROM
          HEAP_T3_PLATFORM_PRODUCTION.HEAP.SESSIONS ss
          JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.USERS U on ss.user_id = u.user_id
      WHERE
          ss.time BETWEEN DATEADD(day,-31,current_date()) AND DATEADD(day,-1,current_date())
          AND u.mimic_user <> 'Yes'
          AND u.company_id in (select company_id from company_current_rentals)
      GROUP BY
          u.company_id
      )
      select
          ccr.company_id,
          ccr.company_name,
          ccr.current_rentals,
          cpr.previous_rentals,
          sl.total_sessions as total_sessions_last_30_days,
          coalesce(advanced_solutions_rentals,0) as advanced_solutions_rentals,
          coalesce(core_solutions_rentals,0) as core_solutions_rentals,
          coalesce(itl_rentals,0) as itl_rentals
      from
          company_current_rentals ccr
          left join company_rentals_last_30 cpr on ccr.company_id = cpr.company_id
          left join sessions_last_30_days sl on sl.company_id = ccr.company_id
          left join company_rentals_by_market_type crmt on crmt.company_id = ccr.company_id
      where
          total_sessions_last_30_days <= 10
      order by
          current_rentals desc ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: current_rentals {
    type: number
    sql: ${TABLE}."CURRENT_RENTALS" ;;
  }

  dimension: previous_rentals {
    label: "Completed Rentals Last 30 Days"
    type: number
    sql: ${TABLE}."PREVIOUS_RENTALS" ;;
  }

  dimension: total_sessions_last_30_days {
    label: "Total T3 Sessions Last 30 Days"
    type: number
    sql: ${TABLE}."TOTAL_SESSIONS_LAST_30_DAYS" ;;
  }

  dimension: advanced_solutions_rentals {
    type: number
    sql: ${TABLE}."ADVANCED_SOLUTIONS_RENTALS" ;;
  }

  dimension: core_solutions_rentals {
    type: number
    sql: ${TABLE}."CORE_SOLUTIONS_RENTALS" ;;
  }

  dimension: itl_rentals {
    label: "ITL Rentals"
    type: number
    sql: ${TABLE}."ITL_RENTALS" ;;
  }

  measure: aggregate_total_sessions_last_30_days {
    label: "Total T3 Sessions Last 30 Days"
    type: sum
    sql: ${total_sessions_last_30_days} ;;
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  }

  set: detail {
    fields: [
        user_info_sessions_last_30_days.user_name,
        user_info_sessions_last_30_days.email_address,
        user_info_sessions_last_30_days.total_t3_sessions
    ]
  }
}
