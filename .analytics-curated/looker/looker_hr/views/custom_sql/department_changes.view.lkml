view: department_changes {
  derived_table: {sql:
WITH gp AS (
                  SELECT employee_id,
                         LAST_VALUE(first_name) OVER (PARTITION BY employee_id ORDER BY _es_update_timestamp) AS first_name,
                         LAST_VALUE(last_name) OVER (PARTITION BY employee_id ORDER BY _es_update_timestamp)  AS last_name,
                         employee_title,
                         default_cost_centers_full_path,
                         market_id,
                         DATE_TRUNC('minute', _es_update_timestamp)                                           AS effective_date,
                         RANK() OVER (PARTITION BY employee_id, default_cost_centers_full_path ORDER BY _es_update_timestamp) AS change_num
                    FROM analytics.payroll.EE_COMPANY_DIRECTORY_12_MONTH
                   WHERE employee_title IS NOT NULL
                 QUALIFY change_num = 1)
SELECT employee_id,
       first_name,
       market_id,
       last_name,
       effective_date,
       default_cost_centers_full_path                                                                     AS current_cost_center,
       LEAD(default_cost_centers_full_path, 1) OVER (PARTITION BY employee_id ORDER BY effective_date DESC) AS previous_cost_center
  FROM gp
 WHERE employee_id is not null
 ORDER BY effective_date
 ;;}


  dimension: primary_key {
    primary_key: yes
    type: number
    sql: concat(${TABLE}."EMPLOYEE_ID", ${TABLE}."CURRENT_COST_CENTER", ${TABLE}."PREVIOUS_COST_CENTER", ${TABLE}."EFFECTIVE_DATE") ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    }

  dimension: current_cost_center {
    type: string
    sql: ${TABLE}."CURRENT_COST_CENTER" ;;

  }

  dimension_group: effective_date {
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
    sql: ${TABLE}."EFFECTIVE_DATE" ;;
  }


  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: prior_cost_center {
    type: string
    sql: ${TABLE}."PREVIOUS_COST_CENTER" ;;
  }


    dimension: current_district {
      type: string
      sql: CASE WHEN ${effective_date_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."CURRENT_COST_CENTER",'/','2')
        ELSE SPLIT_PART(${TABLE}."CURRENT_COST_CENTER",'/','3') END;;
    }

  dimension: previous_district {
    type: string
    sql: CASE WHEN ${effective_date_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."PREVIOUS_COST_CENTER",'/','2')
      ELSE SPLIT_PART(${TABLE}."PREVIOUS_COST_CENTER",'/','3') END;;
  }

    dimension: current_division {
      type: string
      sql: CASE WHEN (${effective_date_date} < TO_DATE('2023-01-01') AND startswith(${current_cost_center},'R')) THEN 'Rental'
        ELSE SPLIT_PART(${TABLE}."CURRENT_COST_CENTER",'/','1') END;;
    }

  dimension: prior_division {
    type: string
    sql: CASE WHEN (${effective_date_date} < TO_DATE('2023-01-01') AND startswith(${prior_cost_center},'R')) THEN 'Rental'
      ELSE SPLIT_PART(${TABLE}."PREVIOUS_COST_CENTER",'/','1') END;;
  }

  dimension: current_department {
    type: string
    sql: CASE WHEN ${effective_date_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."CURRENT_COST_CENTER",'/','3')
      ELSE SPLIT_PART(${TABLE}."CURRENT_COST_CENTER",'/','4') END;;
  }

  dimension: prior_department {
    type: string
    sql: CASE WHEN ${effective_date_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."PREVIOUS_COST_CENTER",'/','3')
      ELSE SPLIT_PART(${TABLE}."PREVIOUS_COST_CENTER",'/','4') END;;
  }

  measure: total_count {
    type: count
    sql: ${employee_id} ;;
    #drill_fields: [source,amount]
  }


  set: detail {
    fields: [employee_id, first_name, last_name, current_department, prior_department,  current_cost_center, prior_cost_center,effective_date_date, location, total_count]
  }

}
