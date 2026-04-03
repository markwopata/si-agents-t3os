view: vic__users {
  sql_table_name: "VIC_GOLD"."VIC__USERS" ;;

  dimension: pk_user_environment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.pk_user_environment_id ;;
    value_format_name: id
  }

  dimension: fk_user_id {
    type: number
    sql: ${TABLE}.fk_user_id ;;
    value_format_name: id
  }

  dimension: name_first {
    type: string
    sql: ${TABLE}.name_first ;;
  }

  dimension: name_last {
    type: string
    sql: ${TABLE}.name_last ;;
  }

  dimension: name_full {
    type: string
    sql: ${TABLE}.name_full ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: phone_number {
    type: number
    sql: ${TABLE}.phone_number ;;
    value_format_name: id
  }

  dimension: user_status {
    type: string
    sql: ${TABLE}.user_status ;;
  }

  dimension: timezone {
    type: string
    sql: ${TABLE}.timezone ;;
  }

  dimension: legacy_id {
    type: number
    sql: ${TABLE}.legacy_id ;;
  }

  dimension: address_json {
    type: string
    sql: ${TABLE}.address_json ;;
  }

  dimension: address_city {
    type: string
    sql: ${TABLE}.address_city ;;
  }

  dimension: address_country {
    type: string
    sql: ${TABLE}.address_country ;;
  }

  dimension: address_postal_code {
    type: string
    sql: ${TABLE}.address_postal_code ;;
  }

  dimension: address_state {
    type: string
    sql: ${TABLE}.address_state ;;
  }

  dimension: address_street_1 {
    type: string
    sql: ${TABLE}.address_street_1 ;;
  }

  dimension: address_street_2 {
    type: string
    sql: ${TABLE}.address_street_2 ;;
  }

  dimension: out_of_office_starts_at {
    type: string
    sql: ${TABLE}.out_of_office_starts_at ;;
  }

  dimension: out_of_office_ends_at {
    type: string
    sql: ${TABLE}.out_of_office_ends_at ;;
  }

  dimension: name_environment {
    type: string
    sql: ${TABLE}.name_environment ;;
  }

  dimension: name_environment_alias {
    type: string
    sql: ${TABLE}.name_environment_alias ;;
  }

  dimension: fk_company_id_numeric {
    type: number
    sql: ${TABLE}.fk_company_id_numeric ;;
  }

  dimension: fk_company_id_uuid {
    type: number
    sql: ${TABLE}.fk_company_id_uuid ;;
    value_format_name: id
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_created ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_modified ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_loaded ;;
  }
  measure: count {
    type: count
  }
}
