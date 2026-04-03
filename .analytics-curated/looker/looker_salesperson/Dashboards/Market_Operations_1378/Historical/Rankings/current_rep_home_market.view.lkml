view: current_rep_home_market {
  derived_table: {
    sql: with most_recent_position as (select
      si.user_id,
      si.name as name,
      si.salesperson_jurisdiction_dated,
      si.employee_status_present,
     -- xwk.market_type,
      si.region_dated,
      si.region_name_dated,
      si.district_dated,
      si.home_market_id_dated,
      si.home_market_dated ,
      si.record_effective_date,
      si.date_terminated_present,
      si.direct_manager_user_id_present,
      si.first_date_as_tam,
      si.date_hired_initial,
      si.date_rehired_present,

      CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
          THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
          ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as direct_manager_name_present

FROM analytics.bi_ops.salesperson_info si

LEFT JOIN es_warehouse.public.users u ON u.user_id = si.direct_manager_user_id_present
LEFT JOIN analytics.payroll.company_directory cd ON lower(u.email_address) = lower(cd.work_email)
QUALIFY ROW_NUMBER() OVER (PARTITION BY si.user_id ORDER BY si.record_effective_date DESC) = 1
)
SELECT mrp.*,
  xwk.market_type
FROM most_recent_position mrp
LEFT JOIN analytics.public.market_region_xwalk xwk ON xwk.market_id = mrp.home_market_id_dated
;;

}


  dimension: user_id {
    type:  string
    sql:  ${TABLE}."USER_ID" ;;
  }

  dimension: name {
    type:  string
    sql:  ${TABLE}."NAME" ;;
  }

  dimension: jurisdiction {
    type:  string
    sql:  ${TABLE}."SALESPERSON_JURISDICTION" ;;
  }

  dimension: market_type {
    type:  string
    sql:  ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region {
    type:  string
    sql:  ${TABLE}."REGION_DATED" ;;
  }
  dimension: region_name {
    type:  string
    sql:   ${TABLE}."REGION_NAME_DATED"  ;;
  }


  dimension: district {
    type:  string
    sql:  ${TABLE}."DISTRICT_DATED" ;;
  }

  dimension: market_id {
    type:  string
    sql:  ${TABLE}."HOME_MARKET_ID_DATED" ;;
  }

  dimension: employee_current_status {
    type:  string
    sql:  ${TABLE}."EMPLOYEE_STATUS_PRESENT" ;;
  }
  dimension: market_name {
    type:  string
    sql:  ${TABLE}."HOME_MARKET_DATED" ;;
  }

  dimension: record_effective_date {
    type:  string
    sql:  ${TABLE}."RECORD_EFFECTIVE_DATE" ;;
  }

  dimension:  date_terminated_present {
    type:  string
    sql:  ${TABLE}."DATE_TERMINATED_PRESENT" ;;
  }


  dimension:  first_date_as_TAM {
    type:  string
    sql:  ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  dimension:direct_manager_id {
    type:  string
    sql: ${TABLE}."DIRECT_MANAGER_ID_PRESENT" ;;
  }

  dimension:  direct_manager_name {
    type:  string
    sql: ${TABLE}."DIRECT_MANAGER_NAME_PRESENT" ;;
  }

  dimension: current_location {
    type: string
    sql: COALESCE(${market_name}, concat('District ',${district}), ${region_name})  ;;
  }

  dimension: date_rehired_present {
    type: date
    sql: ${TABLE}."DATE_REHIRED_PRESENT" ;;
    }
  dimension: formatted_date_hired_initial {
    type: date
    sql: ${TABLE}."DATE_HIRED_INITIAL" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_date_rehired {
    type: date
    sql:  ${TABLE}."DATE_REHIRED_PRESENT";;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_first_date_TAM {
    type:  date
    sql:   ${TABLE}."FIRST_DATE_AS_TAM"  ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: start_date {
    type: date
    sql: IFF(${date_rehired_present} is not null,${formatted_date_rehired},${formatted_date_hired_initial}) ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_rep_count {
    type:  count_distinct
    sql: ${user_id} ;;
    filters: [employee_current_status: "Active"]
    drill_fields: [total_rep_drill*]
  }

  set: total_rep_drill  {
      fields:[new_accounts_revenue_oec_rankings.salesperson]
  }
}
