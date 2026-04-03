view: user_recruiters {
  derived_table: {
    sql: select
      j.id as job_id
      ,j.name as job
      ,j.status
      ,j.created_at::date as job_created
      ,j.updated_at::date as job_updated
      ,j.closed_at::date as job_closed
      ,j.custom_employment_type
      ,ht.role
      ,ht.user_id
      ,u.first_name
      ,u.last_name
      ,u.site_admin
      ,u.created_at::date as user_created
      ,u.updated_at::date as user_updated
      ,ue.email
      from analytics.greenhouse.job j
      left join analytics.greenhouse.hiring_team ht
      on j.id=ht.job_id
      left join analytics.greenhouse.user u
      on ht.user_id=u.id
      left join analytics.greenhouse.user_email ue
      on u.id=ue.user_id
      where ht.role in ('recruiters', 'coordinators')
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job {
    type: string
    sql: ${TABLE}."JOB" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: job_created {
    type: date
    sql: ${TABLE}."JOB_CREATED" ;;
  }

  dimension: job_updated {
    type: date
    sql: ${TABLE}."JOB_UPDATED" ;;
  }

  dimension: job_closed {
    type: date
    sql: ${TABLE}."JOB_CLOSED" ;;
  }

  dimension: custom_employment_type {
    type: string
    sql: ${TABLE}."CUSTOM_EMPLOYMENT_TYPE" ;;
  }

  dimension: role {
    type: string
    sql: ${TABLE}."ROLE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: recruiter_full_name {
    type: string
    sql: CASE WHEN  ${TABLE}."ROLE" = 'recruiters' THEN concat(${first_name},' ',${last_name})
    END ;;
  }

  dimension: coordinator_full_name {
    type: string
    sql: CASE WHEN  ${TABLE}."ROLE" = 'coordinators' THEN concat(${first_name},' ',${last_name})
    END;;
  }

  dimension: site_admin {
    type: string
    sql: ${TABLE}."SITE_ADMIN" ;;
  }

  dimension: user_created {
    type: date
    sql: ${TABLE}."USER_CREATED" ;;
  }

  dimension: user_updated {
    type: date
    sql: ${TABLE}."USER_UPDATED" ;;
  }

  set: detail {
    fields: [
      job_id,
      job,
      status,
      job_created,
      job_updated,
      job_closed,
      custom_employment_type,
      role,
      user_id,
      first_name,
      last_name,
      site_admin,
      user_created,
      user_updated
    ]
  }
}
