view: phone_numbers {
  derived_table: {
    sql:
    select *
    from internal_tools.webex_integration.phone_numbers
    where type = 'work_extension'
    ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."VALUE" ;;
  }

  dimension: phone_number_type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: user_id {
    type: string
    hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [users.last_name, users.first_name, users.user_id, users.display_name, users.nickname]
  }
}
