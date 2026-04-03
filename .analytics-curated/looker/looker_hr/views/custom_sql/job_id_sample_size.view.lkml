view: job_id_sample_size {
  derived_table: {
    sql: select
      j.id
      ,j.name as job_title
      from analytics.greenhouse.job j
      where j.id in (1476757
      ,1476772
      ,1460853
      ,1469526
      ,1464660
      ,1472930
      ,1475411
      ,1387726
      ,1386012)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: job_title {
    type: string
    sql: ${TABLE}."JOB_TITLE" ;;
  }

  set: detail {
    fields: [job_id, job_title]
  }
}
