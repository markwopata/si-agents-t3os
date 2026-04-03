view: direct_socf_transactions {
  sql_table_name: "ANALYTICS"."TREASURY"."DIRECT_SOCF_TRANSACTIONS" ;;

  #################### DATES ####################
  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: year_quarter {
    type: string
    sql: ${TABLE}."YEAR_QUARTER" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  #################### DIMENSIONS ####################

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: bank {
    type: string
    sql: ${TABLE}."BANK" ;;
  }

  dimension: cf1 {
    label: "CF1"
    type: string
    sql: ${TABLE}."CF1" ;;
  }

  dimension: cf2 {
    label: "CF2"
    type: string
    sql: ${TABLE}."CF2" ;;
  }

  dimension: cf3 {
    label: "CF3"
    type: string
    sql: ${TABLE}."CF3" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: line_item {
    label: "Item"
    type: string
    sql: ${TABLE}."LINE_ITEM" ;;
  }

  dimension: other_tags {
    type: string
    sql: ${TABLE}."OTHER_TAGS" ;;
  }

  dimension: section {
    type: string
    sql: ${TABLE}."SECTION" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  #################### MEASURES ####################

  measure: amount_mm {
    type: sum
    value_format: "$#,##0.0;($#,##0.0);-"
    drill_fields: [socf_details*]
    sql: ${TABLE}."AMOUNT"/1000000 ;;
  }

  measure: amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."AMOUNT" ;;
  }

#################### DRILL FIELDS ####################

  set: socf_details {
    fields: [
      date,year_quarter,bank,account_number,account_name,cf1,cf2,cf3,other_tags,
      line_item,section,amount, description
    ]
  }
}
