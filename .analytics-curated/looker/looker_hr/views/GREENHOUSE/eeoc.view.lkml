view: eeoc {
  sql_table_name: "GREENHOUSE"."EEOC"
    ;;

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

  dimension: application_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: disability_status_description {
    type: string
    sql: ${TABLE}."DISABILITY_STATUS_DESCRIPTION" ;;
  }

  dimension: disability_status_id {
    type: number
    sql: ${TABLE}."DISABILITY_STATUS_ID" ;;
  }

  dimension: gender_description {
    type: string
    sql: ${TABLE}."GENDER_DESCRIPTION" ;;
  }

  dimension: gender_id {
    type: number
    sql: ${TABLE}."GENDER_ID" ;;
  }

  dimension: race_description {
    type: string
    sql: ${TABLE}."RACE_DESCRIPTION" ;;
  }

  dimension: race_id {
    type: number
    sql: ${TABLE}."RACE_ID" ;;
  }

  dimension_group: submitted {
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
    sql: CAST(${TABLE}."SUBMITTED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: veteran_status_id {
    type: number
    sql: ${TABLE}."VETERAN_STATUS_ID" ;;
  }

  dimension: veteran_status_message {
    type: string
    sql: ${TABLE}."VETERAN_STATUS_MESSAGE" ;;
  }

  measure: count {
    type: count
    drill_fields: [application.id]
  }
}
