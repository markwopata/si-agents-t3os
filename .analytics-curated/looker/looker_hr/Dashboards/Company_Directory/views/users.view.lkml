view: users {
  sql_table_name: "INTERNAL_TOOLS"."WEBEX_INTEGRATION"."USERS"
    ;;
  drill_fields: [user_id]

  dimension: user_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension_group: created {
    type: time
    convert_tz: yes
    timeframes: [date, week, month, year]
    sql: ${TABLE}."CREATED" ;;
  }

  dimension: display_name {
    type: string
    sql: ${TABLE}."DISPLAY_NAME" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: invite_pending {
    type: yesno
    sql: ${TABLE}."INVITE_PENDING" ;;
  }

  dimension_group: last_activity {
    type: time
    convert_tz: yes
    timeframes: [date, week, month, year]
    sql: ${TABLE}."LAST_ACTIVITY" ;;
  }

  dimension_group: last_modified {
    type: time
    convert_tz: yes
    timeframes: [date, week, month, year]
    sql: ${TABLE}."LAST_MODIFIED" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      user_id,
      last_name,
      first_name,
      display_name,
      nickname,
      phone_numbers.count,
      sip_addresses.count
    ]
  }
}
