view: users {
  sql_table_name: "WEBEX"."USERS"
    ;;
  drill_fields: [user_id]

  dimension: user_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: created {
    type: string
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

  dimension: last_activity {
    type: string
    sql: ${TABLE}."LAST_ACTIVITY" ;;
  }

  dimension: last_modified {
    type: string
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
      display_name,
      first_name,
      last_name,
      nickname,
      phone_numbers.count,
      sip_addresses.count
    ]
  }
}
