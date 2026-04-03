view: jobs {
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
           r.deleted = false
          and o.deleted = false
          and j.company_id = {{ _user_attributes['company_id'] }}
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
           r.deleted = false
          and o.deleted = false
          and j.company_id = {{ _user_attributes['company_id'] }}
          )
          Select * from phases p
          UNION
          Select * from job_name_list j
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

dimension_group: start_date {
  type: time
  sql: ${TABLE}."START_DATE" ;;
}

dimension_group: end_date {
  type: time
  sql: ${TABLE}."END_DATE" ;;
}

dimension: phase_job_name {
  type: string
  sql: ${TABLE}."PHASE_JOB_NAME" ;;
}

dimension: phase_job_id {
  type: number
  sql: ${TABLE}."PHASE_JOB_ID" ;;
}

dimension: job_name {
  type: string
  sql: ${TABLE}."JOB_NAME" ;;
}

set: detail {
  fields: [
    job_id,
    asset_id,
    start_date_time,
    end_date_time,
    phase_job_name,
    phase_job_id,
    job_name
  ]
}
}
