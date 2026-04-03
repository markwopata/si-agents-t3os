
view: onboarding_customers {
  derived_table: {
    sql: with original_app as (
      SELECT 
        company_id
      , min(date_created) as original_create_date
      FROM
      ANALYTICS.BI_OPS.CREDIT_APP_MASTER_RETOOL
      GROUP BY company_id
      )
      , credit_app as (
      SELECT
        car.*
      , o.original_create_date
      FROM
      ANALYTICS.BI_OPS.CREDIT_APP_MASTER_RETOOL CAR
      JOIN original_app o ON (o.company_id = CAR.COMPANY_ID AND o.original_create_date = CAR.date_created)
      WHERE car.app_status != 'Declined COD'
      AND CAR.DATE_COMPLETED >= dateadd(day, -60,current_date())
      ORDER BY car.date_created desc, car.company_id
      )
      , previous_60_day_users as (
      select
          distinct(user_id) as user_id
      from
          heap_t3_platform_production.heap.all_events
      where
          time >= dateadd(day,-60,current_date) 
      )
      , heap_user_info as (
      select
          user_id as heap_user_id,
          identity,
          user_name,
          company_name,
          _user_id as es_user_id,
          company_id
      from 
          heap_t3_platform_production.heap.users
      where
          mimic_user = 'No'
      )
      , active_users as (
      select
          company_id
          , count(distinct es_user_id) as distinct_T3_users_previous_60_days
      from 
          heap_user_info hui
          join previous_60_day_users pu on hui.heap_user_id = pu.user_id
          GROUP BY company_id
      )
      ,  active_company_rentals_by_market as (
      select
         c.company_id
       , m.name as market_name 
       , count(distinct ea.equipment_assignment_id) as active_rentals
       , min(r.date_created) as oldest_rental_create_date
       FROM
          ES_WAREHOUSE.PUBLIC.orders o
          INNER JOIN ES_WAREHOUSE.PUBLIC.rentals r ON r.order_id = o.order_id
          INNER JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea ON (ea.rental_id = r.rental_id and r.rental_status_id = 5)
          INNER JOIN ES_WAREHOUSE.PUBLIC.assets a ON a.asset_id = ea.asset_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.users u ON o.user_id = u.user_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.companies c ON u.company_id = c.company_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m ON m.market_id = o.market_id
          group by
            c.company_id
          , m.name
          order by c.company_id
      )
      , max_market as (
      Select 
      company_id
       , market_name as top_active_rentals_market
       , active_rentals
      , RANK() OVER (  PARTITION BY company_id ORDER BY active_rentals DESC ) as rentals_rank
      from active_company_rentals_by_market
      qualify rentals_rank = 1
      )
      , active_company_rentals as (
      select
         company_id
       , sum(active_rentals) as active_rentals
       , min(oldest_rental_create_date) as oldest_rental_create_date
       FROM
       active_company_rentals_by_market
       group by company_id
       )
      SELECT 
        c.name as company_name
      , c.company_id 
      , coalesce(mm.top_active_rentals_market, 'No Active Rentals') as top_active_rentals_market
      , coalesce(mm.active_rentals, 0) as top_market_active_rentals
      , coalesce(acr.active_rentals, 0) as total_active_rentals
      , acr.oldest_rental_create_date
      , coalesce(au.distinct_T3_users_previous_60_days, 0) as distinct_T3_users_previous_60_days
      , ca.original_create_date::date as credit_app_original_create_date
      , ca.date_completed::date as credit_app_approval_date
      FROM
      credit_app ca
      LEFT JOIN es_warehouse.public.companies c on (ca.company_id = c.company_id)
      LEFT JOIN active_users au on (au.company_id = ca.company_id)
      LEFT JOIN active_company_rentals acr on (acr.company_id = ca.company_id)
      LEFT JOIN max_market mm on (mm.company_id = ca.company_id)
      order by mm.top_active_rentals_market desc ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: top_active_rentals_market {
    type: string
    sql: ${TABLE}."TOP_ACTIVE_RENTALS_MARKET" ;;
  }

  dimension: top_market_active_rentals {
    type: number
    sql: ${TABLE}."TOP_MARKET_ACTIVE_RENTALS" ;;
  }

  dimension: total_active_rentals {
    type: number
    sql: ${TABLE}."TOTAL_ACTIVE_RENTALS" ;;
  }

  dimension_group: oldest_rental_create_date {
    type: time
    sql: ${TABLE}."OLDEST_RENTAL_CREATE_DATE" ;;
  }

  dimension: distinct_t3_users_previous_60_days {
    type: number
    sql: ${TABLE}."DISTINCT_T3_USERS_PREVIOUS_60_DAYS" ;;
  }

  dimension: credit_app_original_create_date {
    type: date
    sql: ${TABLE}."CREDIT_APP_ORIGINAL_CREATE_DATE" ;;
  }

  dimension: credit_app_approval_date {
    type: date
    sql: ${TABLE}."CREDIT_APP_APPROVAL_DATE" ;;
  }

  set: detail {
    fields: [
        company_name,
	company_id,
	top_active_rentals_market,
	top_market_active_rentals,
	total_active_rentals,
	oldest_rental_create_date_time,
	distinct_t3_users_previous_60_days,
	credit_app_original_create_date,
	credit_app_approval_date
    ]
  }
}
