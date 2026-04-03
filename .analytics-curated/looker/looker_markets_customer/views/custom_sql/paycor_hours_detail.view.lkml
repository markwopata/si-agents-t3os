view: paycor_hours_detail {
  derived_table: {
    sql:  select pr.*, lm.loc_name as location_name, lm.region_name as region_name, lm.district as district,
      lm.mkt_name as market_name, lm.mkt_abbrev as mkt_abbrev,
      case when dept_name = 'OPS' then 'Operations'
      when dept_name = 'TEL' then 'Telematics'
      when dept_name = 'ADM' then 'Administration'
      when dept_name = 'Pum' then 'Pump and Power' else dept_name end as department_name
      from analytics.payroll.prtest_detail as pr
      LEFT JOIN ANALYTICS.PAYROLL.PAYROLL_MARKET_MAPPING AS PMM
      ON pr.LOC_NAME||pr.DEPT_NAME = PMM.LOC_DEPTS
      LEFT JOIN ANALYTICS.PAYROLL.LOCATION_MAPPING AS lm
      ON lm.MKT_ABBREV = PMM.ABBREVIATIONS
      where lm.loc_name not in ('Remote','Corporate Office','Telematics Office','Telematics Warehouse')
      and pr.hours <> 0
                               ;;
  }



  dimension: paygroup {
    type: string
    sql: ${TABLE}.paygroup ;;
  }

  dimension: loc_dept {
    type: string
    sql: ${TABLE}.loc_dept ;;
  }

  dimension: pay_period_dates_prior {
    type: string
    sql: ${TABLE}.pay_period_dates_prior ;;
  }

  dimension: pay_period_dates_current {
    type: string
    sql: ${TABLE}.pay_period_dates_current ;;
  }

  dimension: pay_period_filter {
    type: string
    sql: ${TABLE}.pay_period_filter ;;
  }


  dimension: employee_number {
    type: number
    sql: ${TABLE}.employee_number ;;
    value_format: "###0"
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.employee_first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.employee_last_name ;;
  }

  dimension: mkt_abbrev {
    type: string
    sql: ${TABLE}.mkt_abbrev ;;
  }


  dimension: employee_status {
    type: string
    sql: ${TABLE}.employee_status ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: district {
    type: number
    sql: ${TABLE}.district ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: earning_code {
    type: string
    sql: ${TABLE}.earning_code ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}.hours ;;
  }

  dimension: daily_notes {
    type: number
    sql: ${TABLE}.daily_notes ;;
  }

  dimension: employee_name {
    type: string
    sql: CONCAT(${first_name}, ' ', ${last_name})   ;;
  }


  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
    #order_by_field: pct_ot_total
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}.location_name ;;
    #order_by_field: pct_ot_total
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: sub_department_name {
    type: string
    sql: ${TABLE}.sub_dept_name ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.manager_name ;;
  }

  dimension: pay_period {
    type: string
    sql: ${TABLE}.pay_period ;;
  }

  measure: total_hours_prior {
    type: sum
    filters: [pay_period_filter: "Prior"]
    sql: ${TABLE}.hours ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_prior {
    type: sum
    filters: [earning_code: "Reg",pay_period_filter: "Prior"]
    sql:  ${TABLE}.hours;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_prior {
    type: sum
    filters: [earning_code : "OT, 9-Double T",pay_period_filter: "Prior"]
    sql:  ${TABLE}.hours;;
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
      url: "https://equipmentshare.looker.com/looks/154?f[market_region_xwalk.market_name]={{_filters['market_region_xwalk.market_name']  | url_encode }}
      &f[market_region_xwalk.region_name]={{_filters['market_region_xwalk.region_name']  | url_encode }}
      &f[market_region_xwalk.district_text]={{_filters['market_region_xwalk.district_text']  | url_encode }}
      &f[paycor_hours_detail.department_name]={{_filters['paycor_hours_detail.department_name']  | url_encode }}
      &f[paycor_hours_detail.sub_department_name]={{_filters['paycor_hours_detail.sub_department_name']  | url_encode }}
      &f[paycor_hours_detail.pay_period_filter]={{'Prior'  | url_encode }}&toggle=det"
    }
  }

  measure: total_hours_current {
    type: sum
    filters: [pay_period_filter: "Current"]
    sql: ${TABLE}.hours ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_current {
    type: sum
    filters: [earning_code: "Reg",pay_period_filter: "Current"]
    sql:  ${TABLE}.hours;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_current {
    type: sum
    filters: [earning_code : "OT, 9-Double T",pay_period_filter: "Current"]
    sql:  ${TABLE}.hours;;
    value_format: "#,##0.#0"
  }

  measure: pct_ot_total_current {
    type: number
    sql: case when ${total_hours_current} = 0 and ${overtime_hours_current} > 0 then 1
        when ${total_hours_current} = 0 and ${overtime_hours_current} = 0 then 0
       else ${overtime_hours_current} / ${total_hours_current} end ;;
    value_format: "#,##0.00%"
    link: {
      label: "Current Period Payroll Hours by Employee"
      url: "https://equipmentshare.looker.com/looks/155?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}
      &f[market_region_xwalk.region_name]={{_filters['market_region_xwalk.region_name']  | url_encode }}
      &f[market_region_xwalk.district_text]={{_filters['market_region_xwalk.district_text']  | url_encode }}
      &f[paycor_hours_detail.department_name]={{_filters['paycor_hours_detail.department_name']  | url_encode }}
      &f[paycor_hours_detail.sub_department_name]={{_filters['paycor_hours_detail.sub_department_name']  | url_encode }}
      &f[paycor_hours_detail.pay_period_filter]={{'Current'  | url_encode }}&toggle=det"
    }
  }









}
