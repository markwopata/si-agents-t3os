view: jobs_list_archive {
 derived_table: {
  sql: with phases as (
      select
        o.job_id
      , r.asset_id
      , r.start_date
      , r.end_date
      , j.name as phase_job_name
      , j.job_id as phase_job_id
      , jp.name as job_name
      from
      es_warehouse.public.orders o
      left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
      join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is not null
      left join es_warehouse.public.jobs jp on (j.parent_job_id = jp.job_id)
      where
       r.asset_id is not null
      and r.deleted = false
      and o.deleted = false
      )
      , job_name_list as (
      select
        o.job_id
      , r.asset_id
      , r.start_date
      , r.end_date
      , NULL as phase_job_name
      , NULL as phase_job_id
      , j.name as job_name

    from
    es_warehouse.public.orders o
    left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
    join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is null
    where
    r.asset_id is not null
    and r.deleted = false
    and o.deleted = false
    )
    Select * from phases
    UNION
    Select * from job_name_list

    ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: job_id {
  type: number
  sql: ${TABLE}."JOB_ID" ;;
}

dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
}

dimension: start_date {
  type: date
  sql: ${TABLE}."START_DATE" ;;
}

dimension: end_date {
  type: date
  sql: ${TABLE}."END_DATE" ;;
}

dimension: job_name {
  type: string
  sql: ${TABLE}."JOB_NAME" ;;
}

dimension: custom_id {
  type: string
  sql: ${TABLE}."CUSTOM_ID" ;;
}

dimension: phase_job_id {
  type: number
  sql: ${TABLE}."PHASE_JOB_ID" ;;
}

dimension: phase_job_name {
  type: string
  sql: ${TABLE}."PHASE_JOB_NAME" ;;
}

dimension: phase_job_custom_id {
  type: string
  sql: ${TABLE}."PHASE_JOB_CUSTOM_ID" ;;
}

filter: date_filter {
  type: date_time
}

set: detail {
  fields: [
    job_id,
    asset_id,
    start_date,
    end_date,
    job_name,
    custom_id,
    phase_job_id,
    phase_job_name,
    phase_job_custom_id
  ]
}
}
