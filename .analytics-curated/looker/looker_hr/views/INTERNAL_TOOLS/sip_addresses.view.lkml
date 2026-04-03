view: sip_addresses {
  sql_table_name: "INTERNAL_TOOLS"."WEBEX_INTEGRATION"."SIP_ADDRESSES"
    ;;

  dimension: primary {
    type: yesno
    sql: ${TABLE}."PRIMARY" ;;
  }

  dimension: sip_address {
    type: string
    sql: ${TABLE}."SIP_ADDRESS" ;;
  }

  dimension: sip_address_type {
    type: string
    sql: ${TABLE}."SIP_ADDRESS_TYPE" ;;
  }

  dimension: user_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [users.last_name, users.first_name, users.user_id, users.display_name, users.nickname]
  }
}
