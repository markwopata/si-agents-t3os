view: email {
  sql_table_name: "GREENHOUSE"."EMAIL"
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

  dimension: body {
    type: string
    sql: ${TABLE}."BODY" ;;
  }

  dimension: candidate_id {
    type: number
    # hidden: yes
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

  dimension: from {
    type: string
    sql: ${TABLE}."FROM" ;;
  }

  dimension: subject {
    type: string
    sql: ${TABLE}."SUBJECT" ;;
  }

  dimension: to {
    type: string
    sql: ${TABLE}."TO" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      user.id,
      user.first_name,
      user.last_name,
      candidate.first_name,
      candidate.last_name,
      candidate.id,
      email_cc.count
    ]
  }
}
