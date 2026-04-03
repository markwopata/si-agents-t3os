view: DIM_MARKET {
  sql_table_name: "BRANCH_EARNINGS"."DIM_MARKET"
    ;;

  dimension: ABBREVIATION {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: ACTIVE {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: AREA_CODE {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: COMPANY_ID {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: DISTRICT {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: IS_PUBLIC_MSP {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
  }

  dimension: IS_PUBLIC_RSP {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
  }

  dimension: MARKET_TYPE {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: MARKET_ID {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: MARKET_NAME {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: MARKET_NUMBER {
    type: number
    sql: ${TABLE}."MARKET_NUMBER" ;;
  }

  dimension: NUMBER_MONTHS_OPEN {
    type: number
    sql: ${TABLE}."NUMBER_MONTHS_OPEN" ;;
  }

  dimension: OPEN_GREATER_THAN_12_MONTHS {
    type: yesno
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."OPEN_GREATER_THAN_12_MONTHS" ;;
  }

  dimension: PARENT_CHILD_DISTRICT {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."PARENT_CHILD_DISTRICT" ;;
  }

  dimension: PARENT_CHILD_MARKET_ID {
    type: string
    sql: ${TABLE}."PARENT_CHILD_MARKET_ID" ;;
  }

  dimension: PARENT_CHILD_MARKET_NAME {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."PARENT_CHILD_MARKET_NAME" ;;
  }

  dimension: PARENT_CHILD_REGION {
    type: number
    sql: ${TABLE}."PARENT_CHILD_REGION" ;;
  }

  dimension: PARENT_CHILD_REGION_NAME {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."PARENT_CHILD_REGION_NAME" ;;
  }

  dimension: PILOT_ACCESS {
    type: yesno
    sql: ${TABLE}."PILOT_ACCESS" ;;
  }

  dimension: PK_MARKET {
    type: string
    hidden: yes
    primary_key: yes
    sql: ${TABLE}."PK_MARKET" ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  dimension: REGION {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: REGION_NAME {
    type: string
    suggest_persist_for: "30 minutes"
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: STATE {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    hidden: yes
    sql:  ${DIM_MARKET.DISTRICT} in ({{ _user_attributes['district'] }})
          OR ${DIM_MARKET.REGION_NAME} in ({{ _user_attributes['region'] }})
          OR ${DIM_MARKET.MARKET_ID} in ({{ _user_attributes['market_id'] }}) ;;
  }

  measure: count {
    type: count
    label: "NUMBER OF MARKETS"
    drill_fields: [MARKET_TYPE, COMPANY_ID, DISTRICT, REGION_NAME, MARKET_NUMBER, MARKET_NAME, ACTIVE]
  }
}
