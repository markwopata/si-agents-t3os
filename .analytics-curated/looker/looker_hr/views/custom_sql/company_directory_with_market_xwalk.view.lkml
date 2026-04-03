view: company_directory_with_market_xwalk {
  derived_table: {
    sql:  select
            *
          from analytics.payroll.company_directory cd;;
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
    datatype: date
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension_group: date_hired2 {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_HIRED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_most_recent_hire {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CASE
          WHEN ${TABLE}."DATE_REHIRED" IS NOT NULL THEN ${TABLE}."DATE_REHIRED"
          ELSE ${TABLE}."DATE_HIRED"END ;;
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
    datatype: date
    sql: ${TABLE}."DATE_REHIRED" ;;
  }

  dimension_group: date_rehired2 {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_REHIRED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: division {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',1) ;;
  }

  dimension: district {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH", '/', 3) ;;
  }

  dimension: cost_center_location {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH", '/', 4) ;;
  }

  dimension: department {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',4) ;;
  }

  dimension: direct_manager_employee_id {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
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

  dimension: employee_type {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
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
    sql: case when position(' ',coalesce(${nickname},${first_name})) = 0 then concat(coalesce(${nickname},${first_name}), ' ', ${last_name}, ' - ',${employee_id})
      else concat(coalesce(${nickname},concat(${first_name}, ' ',${last_name})), ' - ', ${employee_id}) end ;;
  }

  dimension: employee_name_with_id {
    type: string
    sql: case when position(' ',coalesce(${nickname},${first_name})) = 0 then concat(coalesce(${nickname},${first_name}), ' ', ${last_name}, ' - ',${employee_id})
      else concat(coalesce(${nickname},concat(${first_name}, ' ',${last_name})), ' - ', ${employee_id}) end;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
  }

  dimension: greenhouse_application_id {
    type: string
    sql: ${TABLE}."greenhouse_application_id" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }

  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }

  dimension: region {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',2) ;;
  }

  dimension: tax_location {
    type: string
    sql: ${TABLE}."TAX_LOCATION" ;;
  }

  dimension: subdepartment {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',5) ;;
  }

  dimension: market_based_email {
    type: string
    link: {label:"Transportation Dashboard dev"
      url:"https://equipmentshare.looker.com/dashboards/1317?District=&Make=&Model=&Region+Name=&Market+Name=&Licensed+%28Yes+%2F+No%29=&Owned+or+Rented="}
    sql:  {% if transportation_assets.asset_id._is_filtered %}
           ${work_email}
          {% elsif markets.name._is_filtered %}
           ${work_email}
          {% else %}
           'Select Market to Display'
          {% endif %} ;;
  }

  }
