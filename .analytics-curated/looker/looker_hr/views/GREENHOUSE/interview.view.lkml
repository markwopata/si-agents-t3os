view: interview {
  derived_table: {
    sql:  with consolidate_interviews as(
        select
        *
        ,ROW_NUMBER() OVER(PARTITION BY job_stage_id ORDER BY id desc) as rn
        from greenhouse.interview i
        )
        select
        *
        from consolidate_interviews
        where rn = 1
       ;;
  }

  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: interview_kit_content {
    type: string
    sql: ${TABLE}."INTERVIEW_KIT_CONTENT" ;;
  }

  dimension: job_stage_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."JOB_STAGE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      name,
      job_stage.name,
      job_stage.id,
      interview_question.count,
      scheduled_interview.count
    ]
  }
}
