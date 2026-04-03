view: jobs_internal_mobility {

    derived_table: {
      sql: WITH jo AS (SELECT ID AS JOB_ID, NAME AS JOB_NAME, REQUISITION_ID, CREATED_AT AS OPENED_AT, CLOSED_AT, STATUS, CUSTOM_REQ_TYPE
            FROM  ANALYTICS.GREENHOUSE.JOB
            where STATUS <> 'draft'
)
SELECT jo.JOB_ID, jo.REQUISITION_ID, jo.JOB_NAME, jo.STATUS, jo.OPENED_AT, jo.CLOSED_AT, COUNT(hi.CANDIDATE_ID) AS HIRES_FROM_REQ, MAX(hi.STARTS_AT) AS STARTS_AT, CUSTOM_REQ_TYPE from jo left join
(SELECT * FROM ANALYTICS.GREENHOUSE.HIRES_INFO_VIEW) hi
ON hi.JOB_ID = jo.JOB_ID
WHERE (hi.STARTS_AT >= jo.OPENED_AT OR hi.STARTS_AT IS NULL)
AND (hi.CREATED_AT >= jo.OPENED_AT OR hi.CREATED_AT IS NULL)
AND (hi.APPLIED_AT >= jo.OPENED_AT OR hi.APPLIED_AT IS NULL)
AND (hi.CREATED_AT <= jo.CLOSED_AT OR hi.CREATED_AT IS NULL OR jo.CLOSED_AT IS NULL)
GROUP BY jo.REQUISITION_ID, jo.JOB_NAME, jo.JOB_ID, jo.OPENED_AT, jo.CLOSED_AT, jo.STATUS, jo.CUSTOM_REQ_TYPE;;
    }



    dimension: job_id {
      primary_key: yes
      type: string
      sql: ${TABLE}."JOB_ID" ;;
    }

    dimension: job_name {
      type: string
      sql: ${TABLE}."JOB_NAME" ;;
    }

    dimension_group: req_closed_at {
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
      sql: CAST(${TABLE}."CLOSED_AT" AS TIMESTAMP_NTZ) ;;
    }

    dimension_group: req_opened_at {
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
      sql: CAST(${TABLE}."OPENED_AT" AS TIMESTAMP_NTZ) ;;
    }
    dimension: req_hires_dim {
      type: number
      sql: ${TABLE}."HIRES_FROM_REQ"  ;;
    }

    dimension: requisition_id {
      type: string
      sql: ${TABLE}."REQUISITION_ID" ;;
    }

    dimension_group: starts_at {
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
      sql: CAST(${TABLE}."STARTS_AT" AS TIMESTAMP_NTZ) ;;
    }

    dimension: status {
      type: string
      sql: ${TABLE}."STATUS" ;;
    }

    dimension: req_type {
      type: string
      sql: ${TABLE}."CUSTOM_REQ_TYPE" ;;
    }

    dimension: job_greenhouse_link{
      type: string
      sql: ${job_id};;
      html: <font color="blue "><u><a href="https://app.greenhouse.io/sdash/{{ value | url_encode }}" target="_blank" title="Link to Greenhouse">{{value}}</a> ;;

    }

    dimension: advanced_solutions {
      type: string
      sql: CASE WHEN CONTAINS(${TABLE}."JOB_NAME", 'Advanced Solutions') THEN 'Advanced Solutions' ELSE 'Not' END ;;
    }

    dimension: key_ops_jobs {
      type: string
      sql: CASE WHEN CONTAINS(${TABLE}."JOB_NAME", 'General Manager') AND NOT CONTAINS(${TABLE}."JOB_NAME", 'Assistant General Manager') THEN 'General Managers'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Assistant General Manager') THEN 'Assistant General Managers'
            WHEN (CONTAINS(${TABLE}."JOB_NAME", 'CDL') AND CONTAINS(${TABLE}."JOB_NAME", 'Driver') AND NOT CONTAINS(${TABLE}."JOB_NAME", 'non-CDL') AND NOT CONTAINS(${TABLE}."JOB_NAME", 'Non-CDL')) THEN 'Drivers (CDL)'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Driver') THEN 'Drivers'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Field Technician') THEN 'Field Technicians'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Shop Technician') THEN 'Shop Technicians'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Yard Technician') THEN 'Yard Technician'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Rental Coordinator') THEN 'Rental Coordinators'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Service Manager') THEN 'Service Managers'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Parts Assistant') THEN 'Parts Assistants'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Parts Manager') THEN 'Parts Managers'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Dispatcher') THEN 'Dispatchers'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Regional Manager') THEN 'Regional Managers'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Territory Account Manager') THEN 'Territory Account Managers'
            WHEN CONTAINS(${TABLE}."JOB_NAME", 'Telematics Installer') THEN 'Telematics Installers'
            ELSE 'Other' END ;;
    }

    measure: count_unique_reqs {
      type: count_distinct
      label: "Number Reqs"
      sql: ${requisition_id}  ;;
      drill_fields: [requisition_id, job_name, job_id, status, job_greenhouse_link, req_opened_at_date, req_closed_at_date]
    }

    measure: req_hires {
      type: sum
      sql: ${TABLE}."HIRES_FROM_REQ"  ;;
    }

    measure:  req_days_open_from_close_date{
      type: average
      sql:  datediff(day, ${req_opened_at_date}, ${req_closed_at_date}) ;;
    }

    measure:  req_days_open_from_start_date{
      type: average
      sql:  datediff(day, ${req_opened_at_date}, ${starts_at_date}) ;;
    }

    measure:  req_days_open_as_of_today{
      type: average
      label: "Average Days Open"
      sql:  datediff(day, ${req_opened_at_date}, CURRENT_TIMESTAMP()) ;;
      value_format: "0.0"
      drill_fields: [requisition_id, job_name, job_id, status, job_greenhouse_link, req_opened_at_date, req_closed_at_date]
    }

  }
