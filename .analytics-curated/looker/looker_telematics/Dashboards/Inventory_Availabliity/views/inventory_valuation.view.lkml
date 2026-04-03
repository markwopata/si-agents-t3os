view: inventory_valuation {
  derived_table: {
    sql: select *
         from ANALYTICS.FISHBOWL_STAGING.INVENTORY_VALUATION
         where reportdate in (select max(reportdate) from ANALYTICS.FISHBOWL_STAGING.INVENTORY_VALUATION);;
  }

  dimension: id {
    primary_key: yes
    type: string
    sql: CONCAT(${partid}, '_', ${reportdate_date}, '_', ${location}) ;;
  }

  dimension: partid {
    type: number
    sql: ${TABLE}."PARTID" ;;
  }

  dimension: activeflag {
    type: yesno
    sql: ${TABLE}."ACTIVEFLAG" ;;
  }

  dimension: part {
    type: string
    sql: ${TABLE}."PART" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: standardcost {
    type: number
    sql: ${TABLE}."STANDARDUNITCOST" ;;
    value_format_name: usd
  }

  dimension: qty {
    type: number
    sql: ${TABLE}."QTY" ;;
  }

  dimension: averagecost {
    type: number
    sql: ${TABLE}."AVERAGEUNITCOST" ;;
    value_format_name: usd
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."TOTALCOST" ;;
  }

  dimension_group: reportdate {
    type: time
    timeframes: [date, week, month, time]
    sql: ${TABLE}."REPORTDATE" ;;
  }

  measure: totalqty {
    type: sum
    sql: ${qty} ;;
  }

  measure: standardcosttotal{
    label: "Total Standard Cost"
    type: sum
    sql: ${standardcost} ;;
    value_format_name: usd
  }

  measure: averagecosttotal {
    label: "Total Average Cost"
    type: sum
    sql: ${averagecost} ;;
    value_format_name: usd
  }

  measure: totalcost {
    label: "Total Cost"
    type: sum
    sql: ${cost} ;;
    value_format_name: usd
  }
  }
