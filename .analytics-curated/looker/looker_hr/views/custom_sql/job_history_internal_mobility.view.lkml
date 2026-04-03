view: job_history_internal_mobility {
  derived_table: {sql:
  with df as (     SELECT employee_id, first_name, last_name, employee_title, _es_update_timestamp
            from analytics.payroll.company_directory_vault
            union
               SELECT employee_id, first_name, last_name, employee_title, _es_update_timestamp
            from analytics.payroll.job_history
                       where _es_update_timestamp > '2021-5-31'),
                cp AS (
        SELECT employee_id,
                LAST_VALUE(first_name) OVER (PARTITION BY employee_id ORDER BY _es_update_timestamp) AS first_name,
                LAST_VALUE(last_name) OVER (PARTITION BY employee_id ORDER BY _es_update_timestamp)  AS last_name,
                employee_title,
                DATE_TRUNC('minute', _es_update_timestamp)                                           AS effective_date,
                RANK() OVER (PARTITION BY employee_id, employee_title ORDER BY _es_update_timestamp) AS change_num
                FROM df
                WHERE employee_title IS NOT NULL
                QUALIFY change_num = 1)
                SELECT employee_id,
                first_name,
                last_name,
                effective_date,
                dateadd(SECONDS,-1,lead(effective_date, -1) OVER (PARTITION BY employee_id ORDER BY effective_date)) as previous_effective_date,
                employee_title                                                                       AS current_title,
                LEAD(employee_title, 1) OVER (PARTITION BY employee_id ORDER BY effective_date DESC) AS previous_title
                FROM cp
                WHERE employee_title IS NOT NULL
                ORDER BY effective_date
    ;;}


  dimension: key {
    primary_key: yes
    type: string
    sql: concat(${employee_id},${prior_title},${current_title},${effective_date_date}) ;;
  }


  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: current_title {
    type: string
    sql: ${TABLE}."CURRENT_TITLE" ;;
  }

  dimension_group: effective_date {
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
    sql: cast(${TABLE}."EFFECTIVE_DATE" AS TIMESTAMP_NTZ) ;;
  }


  dimension_group: previous_effective_date {
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
    sql: cast(${TABLE}."PREVIOUS_EFFECTIVE_DATE" AS TIMESTAMP_NTZ) ;;
  }



  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: prior_title {
    type: string
    sql: ${TABLE}."PREVIOUS_TITLE" ;;
  }

  dimension: key_ops_jobs_previous{
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'General Manager') AND NOT CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Assistant General Manager') THEN 'General Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Assistant General Manager') THEN 'Assistant General Managers'
          WHEN (CONTAINS(${TABLE}."PREVIOUS_TITLE", 'CDL') AND CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Driver') AND NOT CONTAINS(${TABLE}."PREVIOUS_TITLE", 'non-CDL') AND NOT CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Non-CDL')) THEN 'Drivers (CDL)'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Driver') THEN 'Drivers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Field Technician') THEN 'Field Technicians'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Shop Technician') THEN 'Shop Technicians'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Yard Technician') THEN 'Yard Technician'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Rental Coordinator') THEN 'Rental Coordinators'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Service Manager') THEN 'Service Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Parts Assistant') THEN 'Parts Assistants'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Parts Manager') THEN 'Parts Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Dispatcher') THEN 'Dispatchers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Regional Manager') THEN 'Regional Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'District Manager') THEN 'District Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Territory Account Manager') THEN 'Territory Account Managers'
          WHEN CONTAINS(${TABLE}."PREVIOUS_TITLE", 'Telematics Installer') THEN 'Telematics Installers'
          ELSE 'Other' END ;;
  }

  dimension: key_ops_jobs_current{
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'General Manager') AND NOT CONTAINS(${TABLE}."CURRENT_TITLE", 'Assistant General Manager') THEN 'General Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Assistant General Manager') THEN 'Assistant General Managers'
          WHEN (CONTAINS(${TABLE}."CURRENT_TITLE", 'CDL') AND CONTAINS(${TABLE}."CURRENT_TITLE", 'Driver') AND NOT CONTAINS(${TABLE}."CURRENT_TITLE", 'non-CDL') AND NOT CONTAINS(${TABLE}."CURRENT_TITLE", 'Non-CDL')) THEN 'Drivers (CDL)'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Driver') THEN 'Drivers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Field Technician') THEN 'Field Technicians'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Shop Technician') THEN 'Shop Technicians'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Yard Technician') THEN 'Yard Technician'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Rental Coordinator') THEN 'Rental Coordinators'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Service Manager') THEN 'Service Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Parts Assistant') THEN 'Parts Assistants'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Parts Manager') THEN 'Parts Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Dispatcher') THEN 'Dispatchers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Regional Manager') THEN 'Regional Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'District Manager') THEN 'District Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Territory Account Manager') THEN 'Territory Account Managers'
          WHEN CONTAINS(${TABLE}."CURRENT_TITLE", 'Telematics Installer') THEN 'Telematics Installers'
          ELSE 'Other' END ;;
  }


  measure: total_count {
    type: count
    sql: ${employee_id} ;;
    #drill_fields: [source,amount]
  }


  set: detail {
    fields: [employee_id, first_name, last_name,key_ops_jobs_current, key_ops_jobs_previous,  current_title, prior_title,previous_effective_date_date,effective_date_date,  total_count]
  }

}
