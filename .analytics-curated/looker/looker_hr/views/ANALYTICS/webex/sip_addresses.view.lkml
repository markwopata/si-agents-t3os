view: sip_addresses {
  sql_table_name: "WEBEX"."SIP_ADDRESSES"
    ;;

  dimension: primary {
    type: yesno
    sql: ${TABLE}."PRIMARY" ;;
  }

  dimension: type {
    label: "SIP Type"
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: user_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: value {
    label: "SIP Value"
    type: string
    sql: ${TABLE}."VALUE" ;;
  }

  measure: count {
    type: count
    drill_fields: [users.display_name, users.first_name, users.last_name, users.nickname, users.user_id]
  }
}
