view: parsed_phone_numbers {
  sql_table_name: "ANALYTICS"."PUBLIC"."PARSED_PHONE_NUMBERS" ;;

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: phone_number {
    type: number
    sql: ${TABLE}."REGEX_PHONE_NUMBER" ;;
  }

  dimension: is_support {
    type: yesno
    sql: ${phone_number} not in (8888073687, 8333787225) ;;
  }

  measure: count {
    type: count
    drill_fields: [users.full_name_with_id, companies.name, phone_number]
  }
}
