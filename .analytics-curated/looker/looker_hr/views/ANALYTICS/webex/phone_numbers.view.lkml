view: phone_numbers {
  sql_table_name: "WEBEX"."PHONE_NUMBERS"
    ;;

  dimension: type {
    label: "Phone Type"
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: user_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: value {
    label: "Phone Number"
    type: string
    sql: ${TABLE}."VALUE" ;;
  }

  measure: count {
    type: count
    drill_fields: [users.display_name, users.first_name, users.last_name, users.nickname, users.user_id]
  }
}
