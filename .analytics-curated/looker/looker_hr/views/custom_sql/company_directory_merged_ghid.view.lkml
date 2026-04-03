view: company_directory_merged_ghid {
  derived_table: {
    sql:
          select cd.employee_id,
                 cd.first_name,
                cd.last_name,
                cd.work_email,
                cd.employee_status,
                cd.date_hired,
                cd.date_rehired,
                cd.date_terminated,
                cd.employee_title,
                cd.location,
                cd.default_cost_centers_full_path,
                cd.direct_manager_employee_id,
                cd.nickname,
                case when cd.greenhouse_application_id is not null then cd.greenhouse_application_id
                    else mat.greenhouse_application_id
                    end GREENHOUSE_APPLICATION_ID
            from analytics.payroll.company_directory cd
            left join analytics.greenhouse.greenhouse_eeid_matches mat on mat.employee_id = cd.employee_id
       ;;
  }

  dimension_group: date_hired {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: ${TABLE}."DATE_HIRED"::DATE ;;
  }

  dimension_group: date_rehired {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: ${TABLE}."DATE_REHIRED"::DATE ;;
  }

  dimension_group: date_terminated {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: ${TABLE}."DATE_TERMINATED"::DATE ;;
  }

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: direct_manager_employee_id {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: employee_name {
    type: string
    sql: coalesce(${nickname} , ${first_name})||' '||${last_name} ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: GREENHOUSE_APPLICATION_ID {
    type: string
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

  dimension: recent_week {
    type: string
    sql: case when to_date(${TABLE}."DATE_HIRED")<previous_day(current_date(),'Monday') then TRUE else FALSE end ;;
  }

  measure: count {
    type: count
    drill_fields: [employee_name,employee_title]
  }

  measure: distinct_ghid {
    type: count_distinct
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

  #measure: hire_count {
  #  type: count
  #  drill_fields: [date_hired_date,date_hired_year,date_hired_week]
  #}

  measure: hire_count {
    type: count_distinct
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: department {
    type:  string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',4) ;;
  }

  dimension: division {
    type:  string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',1) ;;
  }

  dimension_group: dem {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: case when ${TABLE}."DATE_HIRED"::DATE < current_date()-365 then current_date()-365 else ${TABLE}."DATE_HIRED"::DATE end;;
  }

  set: detail {
    fields: [employee_title]
  }
}
