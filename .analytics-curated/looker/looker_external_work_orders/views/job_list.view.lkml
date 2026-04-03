view: job_list {
  derived_table: {
    sql: with phases as (
                select
                  j.name as phase_job_name
                , j.job_id as phase_job_id
                , jp.name as job_name
                , jp.job_id as job_id
                from
                es_warehouse.public.jobs j
                left join es_warehouse.public.jobs jp on (j.parent_job_id = jp.job_id)
                where j.parent_job_id is not null
                )
                , job_name_list as (
                select
                  NULL as phase_job_name
                , NULL as phase_job_id
                , j.name as job_name
                , j.job_id as job_id

                from
                es_warehouse.public.jobs j
                where
                j.parent_job_id is null
                )

                Select * from phases
                UNION
                Select * from job_name_list ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
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

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  filter: job_filter {
    type: string
  }

  filter: phase_filter {
    type: string
  }

  set: detail {
    fields: [
      phase_job_name,
      phase_job_id,
      job_name,
      job_id
    ]
  }
}
