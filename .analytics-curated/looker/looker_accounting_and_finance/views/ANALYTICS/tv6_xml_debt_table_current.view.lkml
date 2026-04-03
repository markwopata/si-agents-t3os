view: tv6_xml_debt_table_current {
  sql_table_name: "DEBT"."TV6_XML_DEBT_TABLE_CURRENT"
    ;;

  dimension: apr {
    type: number
    sql: ${TABLE}."APR" ;;
  }

  dimension: balance {
    type: number
    sql: ${TABLE}."BALANCE" ;;
  }

  dimension_group: commencement {
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
    sql: ${TABLE}."COMMENCEMENT_DATE" ;;
  }

  dimension: compounding {
    type: string
    sql: ${TABLE}."COMPOUNDING" ;;
  }

  dimension: compute_method {
    type: string
    sql: ${TABLE}."computeMethod" ;;
  }

  dimension: current_version {
    type: string
    sql: ${TABLE}."CURRENT_VERSION" ;;
  }

  dimension: custom_type {
    type: string
    sql: ${TABLE}."customType" ;;
  }

  dimension_group: date {
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
    sql: ${TABLE}."DATE" ;;
  }

  dimension: date_count_method_list {
    type: string
    sql: ${TABLE}."dateCountMethodList" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: finance_charge {
    type: number
    sql: ${TABLE}."financeCharge" ;;
  }

  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }

  dimension: gaap_non_gaap {
    type: string
    sql: ${TABLE}."GAAP_NON_GAAP" ;;
  }

  dimension: interest {
    type: number
    sql: ${TABLE}."INTEREST" ;;
  }

  dimension_group: maturity {
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
    sql: ${TABLE}."MATURITY_DATE" ;;
  }

  dimension: negative_cf {
    type: number
    sql: ${TABLE}."negativeCF" ;;
  }

  dimension: nominal_rate {
    type: number
    sql: ${TABLE}."nominalRate" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: phoenix_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PHOENIX_ID" ;;
  }

  dimension: positive_cf {
    type: number
    sql: ${TABLE}."positiveCF" ;;
  }

  dimension: principal {
    type: number
    sql: ${TABLE}."PRINCIPAL" ;;
  }

  dimension: total_payments {
    type: number
    sql: ${TABLE}."totalPayments" ;;
  }

  dimension: version_tv {
    type: string
    sql: ${TABLE}."VERSION_TV" ;;
  }

  dimension: year_length {
    type: string
    sql: ${TABLE}."yearLength" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
