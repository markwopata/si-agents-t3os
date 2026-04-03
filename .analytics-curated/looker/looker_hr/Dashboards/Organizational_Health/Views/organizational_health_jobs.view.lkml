view: organizational_health_jobs {
  derived_table: {
    sql:WITH jo AS (SELECT ID AS JOB_ID, NAME AS JOB_NAME, REQUISITION_ID, CREATED_AT AS OPENED_AT, CLOSED_AT, STATUS
            FROM  ANALYTICS.GREENHOUSE.JOB
            where STATUS <> 'draft'
),
df as (SELECT jo.JOB_ID, jo.REQUISITION_ID, jo.JOB_NAME, jo.STATUS, jo.OPENED_AT, jo.CLOSED_AT, COUNT(hi.CANDIDATE_ID) AS HIRES_FROM_REQ, MAX(hi.STARTS_AT) AS STARTS_AT from jo left join
(SELECT * FROM ANALYTICS.GREENHOUSE.HIRES_INFO_VIEW) hi
ON hi.JOB_ID = jo.JOB_ID
WHERE (hi.STARTS_AT >= jo.OPENED_AT OR hi.STARTS_AT IS NULL)
AND (hi.CREATED_AT >= jo.OPENED_AT OR hi.CREATED_AT IS NULL)
AND (hi.APPLIED_AT >= jo.OPENED_AT OR hi.APPLIED_AT IS NULL)
AND (hi.CREATED_AT <= jo.CLOSED_AT OR hi.CREATED_AT IS NULL OR jo.CLOSED_AT IS NULL)
GROUP BY jo.REQUISITION_ID, jo.JOB_NAME, jo.JOB_ID, jo.OPENED_AT, jo.CLOSED_AT, jo.STATUS),

o1 as (SELECT JOB_ID, OFFICE_ID
FROM (SELECT *, ROW_NUMBER () OVER (PARTITION BY JOB_ID ORDER BY _FIVETRAN_SYNCED DESC) AS rn FROM GREENHOUSE.JOB_OFFICE)
where rn = 1),

o2 as (SELECT * from o1 left join
(SELECT * FROM GREENHOUSE.OFFICE) jo2
ON o1.OFFICE_ID = jo2.ID),

o3 as (select * from o2 left join
(SELECT * from GREENHOUSE.LOCATION_REGION_XWALK) loc ON
o2.LOCATION_NAME = loc.LOCATION),

df2 as (SELECT df.JOB_ID, df.REQUISITION_ID, df.JOB_NAME, df.STATUS, df.OPENED_AT, df.CLOSED_AT, df.HIRES_FROM_REQ, df.STARTS_AT, jf.JOB_FAMILY_GROUP, jf.JOB_FAMILY FROM df left join
(SELECT * FROM ANALYTICS.GREENHOUSE.JOB_NAME_JOB_FAMILY_XWALK) jf on
df.JOB_NAME=jf.JOB_NAME)

select df2.JOB_ID, df2.REQUISITION_ID, df2.JOB_NAME, df2.STATUS, df2.OPENED_AT, df2.CLOSED_AT, df2.HIRES_FROM_REQ, df2.STARTS_AT, df2.JOB_FAMILY_GROUP, df2.JOB_FAMILY, o4.LOCATION, o4.REGION, o4.DISTRICT, o4.MARKET_ID, o4.MARKET_TYPE  from df2 left join
(Select * from o3) o4 on
df2.JOB_ID=o4.JOB_ID

 ;;
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

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: job_family {
    type: string
    sql: ${TABLE}."JOB_FAMILY" ;;
  }

  dimension: job_greenhouse_link{
    type: string
    sql: ${job_id};;
    html: <font color="blue "><u><a href="https://app.greenhouse.io/sdash/{{ value | url_encode }}" target="_blank" title="Link to Greenhouse">{{value}}</a> ;;

  }



  measure: count_unique_reqs {
    type: count_distinct
    sql: ${requisition_id}  ;;
    drill_fields: [requisition_id, job_name, job_id, status, req_opened_at_date, req_closed_at_date]
  }

  measure: count_unique_open_reqs {
    type: count_distinct
    sql: ${requisition_id}  ;;
    filters: [ status: "open"]
    drill_fields: [requisition_id, job_name, job_id, status, req_opened_at_date, req_closed_at_date]
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
    sql:  datediff(day, ${req_opened_at_date}, CURRENT_TIMESTAMP()) ;;
  }

}
