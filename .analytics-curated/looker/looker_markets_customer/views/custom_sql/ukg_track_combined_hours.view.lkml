view: ukg_track_combined_hours {
  derived_table: {
    sql: with pay_periods as (
    select cast(pay_id as int) pay_id,
           pay_date_from,
           pay_date_to,
          case when pay_date is null then dateadd(day,4,pay_date_to) else pay_date end pay_date
    from analytics.payroll.pay_periods_ukg
     where pay_id is not null)
,
      priorpp as (
          select pay_id prior_pay_id,
                 to_char(to_date(pay_date_from), 'MM/DD/YYYY') prior_pay_date_from,
                 to_char(to_date(pay_date_to), 'MM/DD/YYYY') prior_pay_date_to,
                 concat(to_char(to_date(pay_date_from), 'MM/DD/YYYY'), ' - ', to_char(to_date(pay_date_to), 'MM/DD/YYYY')) prior_pay_dates,
                  pay_date prior_pay_date
             from pay_periods where pay_id = (select max(pay_id)-2 from pay_periods where dateadd(day, 4, pay_date_from) <= CURRENT_DATE())
     ),
      currentpp as (
         select pay_id current_pay_id,
                to_char(to_date(pay_date_from), 'MM/DD/YYYY') current_pay_date_from,
                to_char(to_date(pay_date_to), 'MM/DD/YYYY') current_pay_date_to,
                concat(to_char(to_date(pay_date_from), 'MM/DD/YYYY'),' - ', to_char(to_date(pay_date_to), 'MM/DD/YYYY')) current_pay_dates,
                pay_date current_pay_date
            from pay_periods where pay_id = (select max(pay_id)-1
                                             from pay_periods
                                             where dateadd(day, 4, pay_date_from) <= CURRENT_DATE())
     )
select (select prior_pay_dates from priorpp) AS PAY_PERIOD_DATES_PRIOR,
       (select current_pay_dates from currentpp) AS PAY_PERIOD_DATES_CURRENT,
       cd.EMPLOYEE_ID                                                                                             AS EMPLOYEE_NUMBER,
       cd.FIRST_NAME                                                                                              AS EMPLOYEE_FIRST_NAME,
       cd.LAST_NAME                                                                                               AS EMPLOYEE_LAST_NAME,
       (SELECT SUM(hr.HOURS)
        FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting hr
        WHERE hr.E_D_T_CODE = 'OT'
          AND pay_date = (select prior_pay_date from priorpp)
          AND EMPLOYEE_ID = cd.EMPLOYEE_ID)                                                                       AS OT_HOURS,
       (SELECT SUM(hr.HOURS)
        FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting hr
        WHERE hr.E_D_T_CODE = 'Reg'
          AND pay_date = (select prior_pay_date from priorpp)
          AND EMPLOYEE_ID = cd.EMPLOYEE_ID)                                                                       AS REGULAR_HOURS,
       (SELECT SUM(hr.HOURS)
        FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting hr
        WHERE hr.E_D_T_CODE IN ('Reg', 'OT')
          AND pay_date = (select prior_pay_date from priorpp)
          AND EMPLOYEE_ID = cd.EMPLOYEE_ID)                                                                       AS TOTAL_HOURS,
       'Prior'                                                                                                  AS PAY_PERIOD,
       cd.default_cost_centers_full_path                                                                          AS COST_CENTER_FULL_PATH,
       cd.DIRECT_MANAGER_NAME                                                                                     AS MANAGER_NAME,
       'UKG'                                                                                                      AS SOURCE
FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting AS UKG
         left join analytics.payroll.company_directory cd
                   on ukg.employee_id = cd.employee_id
WHERE LOWER(split_part(cd.default_cost_centers_full_path, '/', 1)) NOT LIKE '%corp%'
GROUP BY cd.EMPLOYEE_ID, cd.FIRST_NAME, cd.LAST_NAME,PAY_PERIOD,
         cd.default_cost_centers_full_path, cd.DIRECT_MANAGER_NAME

union all

select (select prior_pay_dates from priorpp) AS PAY_PERIOD_DATES_PRIOR,
       (select current_pay_dates from currentpp) AS PAY_PERIOD_DATES_CURRENT,
       cd.EMPLOYEE_ID                                                                                             AS EMPLOYEE_NUMBER,
       cd.FIRST_NAME                                                                                              AS EMPLOYEE_FIRST_NAME,
       cd.LAST_NAME                                                                                               AS EMPLOYEE_LAST_NAME,
       (SELECT SUM(hr.HOURS)
        FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting hr
        WHERE hr.E_D_T_CODE = 'OT'
          AND pay_date = (select current_pay_date from currentpp)
          AND EMPLOYEE_ID = cd.EMPLOYEE_ID)                                                                       AS OT_HOURS,
       (SELECT SUM(hr.HOURS)
        FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting hr
        WHERE hr.E_D_T_CODE = 'Reg'
          AND pay_date = (select current_pay_date from currentpp)
          AND EMPLOYEE_ID = cd.EMPLOYEE_ID)                                                                       AS REGULAR_HOURS,
       (SELECT SUM(hr.HOURS)
        FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting hr
        WHERE hr.E_D_T_CODE IN ('Reg', 'OT')
          AND pay_date = (select current_pay_date from currentpp)
          AND EMPLOYEE_ID = cd.EMPLOYEE_ID)                                                                       AS TOTAL_HOURS,
       'Current'                                                                                                  AS PAY_PERIOD,
       cd.default_cost_centers_full_path                                                                          AS COST_CENTER_FULL_PATH,
       cd.DIRECT_MANAGER_NAME                                                                                     AS MANAGER_NAME,
       'UKG'                                                                                                      AS SOURCE
FROM ANALYTICS.PAYROLL.ukg_payroll_hourly_reporting AS UKG
         left join analytics.payroll.company_directory cd
                   on ukg.employee_id = cd.employee_id
WHERE LOWER(split_part(cd.default_cost_centers_full_path, '/', 1)) NOT LIKE '%corp%'
GROUP BY cd.EMPLOYEE_ID, cd.FIRST_NAME, cd.LAST_NAME,PAY_PERIOD,
         cd.default_cost_centers_full_path, cd.DIRECT_MANAGER_NAME
;;
  }

  dimension: pay_period_dates_prior {
    type: string
    sql: ${TABLE}."PAY_PERIOD_DATES_PRIOR"  ;;}

  dimension: pay_period_dates_current {
    type: string
    sql: ${TABLE}."PAY_PERIOD_DATES_CURRENT"  ;;}

  dimension: employee_number {
    type: string
    sql: ${TABLE}."EMPLOYEE_NUMBER"  ;;}

  dimension: employee_first_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_FIRST_NAME"  ;;}

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_LAST_NAME"  ;;}

  dimension: ot_hours {
    type: number
    sql: ${TABLE}."OT_HOURS"  ;;}

  dimension: regular_hours {
    type: number
    sql: ${TABLE}."REGULAR_HOURS"  ;;}

  dimension: total_hours {
    type: number
    sql: ${TABLE}."TOTAL_HOURS"  ;;}

  dimension: pay_period {
    type: string
    sql: ${TABLE}."PAY_PERIOD"  ;;}

  dimension: cost_center_full_path {
    type: string
    sql: ${TABLE}."COST_CENTER_FULL_PATH"  ;;}

dimension: dept_name {
  type: string
  sql: split_part(${TABLE}."COST_CENTER_FULL_PATH",'/',4) ;;
}

  dimension: manager_name {
    type: string
    sql: ${TABLE}."MANAGER_NAME"  ;;}

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE"  ;;}

  measure: total_hours_prior {
    type: sum
    filters: [pay_period: "Prior"]
    sql: ${TABLE}.TOTAL_HOURS ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_prior {
    type: sum
    filters: [pay_period: "Prior"]
    sql:  ${TABLE}.REGULAR_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_prior {
    type: sum
    filters: [pay_period: "Prior"]
    sql:  ${TABLE}.OT_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: pct_ot_total_prior {
    type: number
    sql:case when ${total_hours_prior} = 0 and ${overtime_hours_prior} > 0 then 1
        when ${total_hours_prior} = 0 and ${overtime_hours_prior} = 0 then 0
       else ${overtime_hours_prior} / ${total_hours_prior} end ;;
    value_format: "#,##0.#0%"
    link: {
      label: "Prior Period Payroll Hours by Employee"
      url: "https://equipmentshare.looker.com/looks/225?f[market_region_xwalk.market_name]={{ market_region_xwalk.market_name._filterable_value  | url_encode }}
      &f[ukg_track_combined_hours.pay_period]={{'Prior'  | url_encode }}&toggle=det"
    }
  }

  measure: total_hours_current {
    type: sum
    filters: [pay_period: "Current"]
    sql: ${TABLE}.TOTAL_HOURS ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_current {
    type: sum
    filters: [pay_period: "Current"]
    sql:  ${TABLE}.REGULAR_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_current {
    type: sum
    filters: [pay_period: "Current"]
    sql:  ${TABLE}.OT_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: pct_ot_total_current {
    type: number
    sql: case when ${total_hours_current} = 0 and ${overtime_hours_current} > 0 then 1
        when ${total_hours_current} = 0 and ${overtime_hours_current} = 0 then 0
       else ${overtime_hours_current} / ${total_hours_current} end ;;
    value_format: "#,##0.#0%"
    link: {
      label: "Current Period Payroll Hours by Employee"
      url: "https://equipmentshare.looker.com/looks/226?f[market_region_xwalk.market_name]={{ market_region_xwalk.market_name._filterable_value  | url_encode }}
      &f[ukg_track_combined_hours.pay_period]={{'Current'  | url_encode }}&toggle=det"
    }
  }
  }
