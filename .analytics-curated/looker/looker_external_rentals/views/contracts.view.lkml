view: contracts {
  sql_table_name: "PUBLIC"."CONTRACTS"
    ;;
  drill_fields: [contract_id]

  dimension: contract_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: contract_type_id {
    type: number
    sql: ${TABLE}."CONTRACT_TYPE_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_signed {
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
    sql: CAST(${TABLE}."DATE_SIGNED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: signature {
    type: string
    sql: ${TABLE}."SIGNATURE" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.terms:order_id ;;
  }

  dimension: view_rental_contract {
    label: "Rental ID"
    type: string
    sql: ${rentals.rental_id} ;;
    html: <font color="#0063f3"><u><a href="https://contracts.equipmentshare.com/c/{{contract_id._value}}" target="_blank">{{ rentals.rental_id._value }}</a></font></u> ;;
  }

  measure: count {
    type: count
    drill_fields: [contract_id]
  }
}
