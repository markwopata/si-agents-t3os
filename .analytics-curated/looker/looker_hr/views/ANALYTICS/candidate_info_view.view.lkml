view: candidate_info_view {
  sql_table_name: "GREENHOUSE"."CANDIDATE_INFO_VIEW"
    ;;

  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension_group: created {
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
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: disability {
    type: string
    sql: ${TABLE}."DISABILITY" ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}."DISCIPLINE" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}."GENDER" ;;
  }

  dimension: highest_degree {
    type: string
    sql: ${TABLE}."HIGHEST_DEGREE" ;;
  }

  dimension_group: last_activity {
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
    sql: CAST(${TABLE}."LAST_ACTIVITY" AS TIMESTAMP_NTZ) ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: race {
    type: string
    sql: ${TABLE}."RACE" ;;
  }

  dimension: school_name {
    type: string
    sql: ${TABLE}."SCHOOL_NAME" ;;
  }

  dimension: tag {
    type: string
    sql: ${TABLE}."TAG" ;;
  }

  dimension: veteran {
    type: string
    sql: ${TABLE}."VETERAN" ;;
  }

  measure: count {
    type: count
    drill_fields: [last_name, first_name, school_name]
  }
}
