view: offer {
  sql_table_name: "GREENHOUSE"."OFFER"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
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

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
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

  dimension: custom_benefits {
    type: string
    sql: ${TABLE}."CUSTOM_BENEFITS" ;;
  }

  dimension: custom_bonus {
    type: string
    sql: ${TABLE}."CUSTOM_BONUS" ;;
  }

  dimension_group: custom_date_of_birth {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CUSTOM_DATE_OF_BIRTH" ;;
  }

  dimension: custom_employment_type {
    type: string
    sql: ${TABLE}."CUSTOM_EMPLOYMENT_TYPE" ;;
  }

  dimension: custom_hourly_rate {
    type: string
    sql: ${TABLE}."CUSTOM_HOURLY_RATE" ;;
  }

  dimension: custom_notes {
    type: string
    sql: ${TABLE}."CUSTOM_NOTES" ;;
  }

  dimension: custom_options {
    type: string
    sql: ${TABLE}."CUSTOM_OPTIONS" ;;
  }

  dimension: custom_salary {
    type: string
    sql: ${TABLE}."CUSTOM_SALARY" ;;
  }

  dimension: custom_starting_pay {
    type: string
    sql: ${TABLE}."CUSTOM_STARTING_PAY" ;;
  }

  dimension_group: resolved {
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
    sql: CAST(${TABLE}."RESOLVED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: sent {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SENT_AT" ;;
  }

  dimension_group: starts {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."STARTS_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: version {
    type: number
    sql: ${TABLE}."VERSION" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
