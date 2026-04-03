view: salesperson_to_market {
  derived_table: {
  #Changed from a main market based on revenue to a the main market assigned in UKG. Jolene 10/28/2021

    # datagroup_trigger: 6AM_update
    # sql: select
    # distinct(salesperson_user_id),
    # salesperson,
    # final_market
    # from
    # rateachievement_points rp
    # ;;
  # }
  sql:
  select case
        when cd.market_id is not null then mrx.MARKET_NAME
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=6 then concat('District ',substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,4,3))
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=2 then concat('Region ',substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,2,1))  end as final_market,
  case
        when cd.market_id is not null then as_varchar(mrx.MARKET_ID)
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=6 then substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,4,3)
        when mrx.MARKET_NAME is null and length(cd.DEFAULT_COST_CENTERS_FULL_PATH)=2 then substr(cd.DEFAULT_COST_CENTERS_FULL_PATH,2,1)  end as final_market_code,
  concat(coalesce(trim(cd.NICKNAME),trim(cd.first_name)),' ',trim(cd.LAST_NAME)) as salesperson,
  u.USER_ID as salesperson_user_id,
  u.EMPLOYEE_id

  from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
  --left join ANALYTICS.PAYROLL.INTAACT_CODE_BY_EE ice on cd.EMPLOYEE_ID = ice.EMPLOYEE_ID
  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on cd.MARKET_ID = mrx.MARKET_ID
  left join ES_WAREHOUSE.PUBLIC.USERS u on cd.EMPLOYEE_ID = try_to_number(u.EMPLOYEE_ID)
  where
  {% if _user_attributes['department']  == "'salesperson'" %}
  cd.work_email ILIKE '{{ _user_attributes['email'] }}'
  {% else %}
  1 = 1
  {% endif %}
  ;;
}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: final_market {
    type: string
    sql: ${TABLE}."FINAL_MARKET" ;;
  }

  dimension: final_market_code {
    type: string
    sql: ${TABLE}."FINAL_MARKET_CODE" ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: concat(${salesperson}, ' - ',${salesperson_user_id}) ;;
  }

  measure: final_market_distinct_count {
    type: count_distinct
    sql: ${final_market} ;;
    description: "Used to toggle final market name on salesperson dashboard"
  }

  dimension: is_main_market {
    type: yesno
    sql: ${salesperson_user_id} = ${users.user_id} AND (${market_region_xwalk.market_name} = ${final_market}
                                                          OR ${market_region_xwalk.region} = ${final_market_code}
                                                           OR ${market_region_xwalk.district} = ${final_market_code});;
  }

  filter: salesperson_filter {
  }

  set: detail {
    fields: [salesperson_user_id, salesperson, final_market, full_name_with_id]
  }
}
