view: sales_rep_main_market {
  derived_table: {
  #Changed from a main market based on revenue to a the main market assigned in UKG. Jolene 10/28/2021
  #   sql: with pull_rep_market as (
  #     select
  #       final_market,
  #       salesperson,
  #       salesperson_user_id,
  #       sum(case when final_market is not null then 1 else 0 end) as test_column
  #     from
  #       rateachievement_points
  #     group by
  #       final_market,
  #       salesperson,
  #       salesperson_user_id
  #     )
  #     select
  #       final_market as main_market,
  #       salesperson,
  #       salesperson_user_id
  #     from
  #       pull_rep_market
  #     ;;
  # }
      sql:
      select case
        when ice.default_cost_centers_intaact is not null then mrx.MARKET_NAME
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=6 then concat('District ',substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,4,3))
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=2 then concat('Region ',substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,2,1))
        when ice.DEFAULT_COST_CENTERS_INTAACT is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)>6 then cd.LOCATION end as main_market,
  case
        when ice.default_cost_centers_intaact is not null then mrx.MARKET_ID::varchar
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=6 then substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,4,3)
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=2 then substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,2,1)  end as main_market_code,
  concat(coalesce(trim(cd.NICKNAME),trim(cd.first_name)),' ',trim(cd.LAST_NAME)) as salesperson,
  u.USER_ID as salesperson_user_id,
  u.EMPLOYEE_id

  from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
  --left join ANALYTICS.PAYROLL.INTAACT_CODE_BY_EE ice on cd.EMPLOYEE_ID = ice.EMPLOYEE_ID
  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on cd.MARKET_ID = mrx.MARKET_ID
  left join ES_WAREHOUSE.PUBLIC.USERS u on cd.EMPLOYEE_ID = try_to_number(u.EMPLOYEE_ID);;
}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: main_market {
    type: string
    sql: coalesce(${TABLE}."MAIN_MARKET",'Corporate') ;;
  }

  dimension: main_market_code {
    type: string
    sql: ${TABLE}."MAIN_MARKET_CODE" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: is_main_market {
    type: yesno
    sql: ${salesperson_user_id} = ${users.user_id} AND (${market_region_xwalk.market_name} = ${main_market}
                                                          OR ${market_region_xwalk.region} = try_to_number(${main_market_code})
                                                           OR ${market_region_xwalk.district} = ${main_market_code});;
  }

  set: detail {
    fields: [main_market, salesperson, salesperson_user_id]
  }
}
