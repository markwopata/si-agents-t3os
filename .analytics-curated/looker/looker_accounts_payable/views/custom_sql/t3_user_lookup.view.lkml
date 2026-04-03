view: t3_user_lookup {
  derived_table: {
    sql: SELECT
          u.USER_ID,
          u.FIRST_NAME,
          u.LAST_NAME,
          u.EMAIL_ADDRESS
      FROM "ES_WAREHOUSE"."PUBLIC"."USERS" u
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
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

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  set: detail {
    fields: [user_id, first_name, last_name, email_address]
  }
}
