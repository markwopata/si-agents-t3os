view: contracts {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CONTRACTS"
    ;;
  drill_fields: [contract_id]

  dimension: contract_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."CONTRACT_ID"::TEXT ;;
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
    # hidden: yes
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
    sql: get(${terms},'order_id') ;;
  }

  dimension: contract_link {
    type: string
    html: <font color="blue "><u><a href="https://contracts.equipmentshare.com/c/{{contract_id}}" target="_blank">Link to Contract</a></font></u> ;;
    sql: ${contract_id}  ;;
  }

  measure: count {
    type: count
    drill_fields: [contract_id, contract_types.name, contract_types.contract_type_id,contract_link]
  }
}
