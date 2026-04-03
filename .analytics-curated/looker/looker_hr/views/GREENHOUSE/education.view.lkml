view: education {
  sql_table_name: "GREENHOUSE"."EDUCATION"
    ;;
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

  dimension: candidate_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: degree {
    type: string
    sql: ${TABLE}."DEGREE" ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}."DISCIPLINE" ;;
  }

  dimension: end_date {
    type: string
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: school_name {
    type: string
    sql: ${TABLE}."SCHOOL_NAME" ;;
  }

  dimension: start_date {
    type: string
    sql: ${TABLE}."START_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, school_name, candidate.first_name, candidate.last_name, candidate.id]
  }
}
