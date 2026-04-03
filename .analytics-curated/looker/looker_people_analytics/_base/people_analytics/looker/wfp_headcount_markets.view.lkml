view: wfp_headcount_markets {
  sql_table_name: "LOOKER"."WFP_MARKET_HEADCOUNTS" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: headcount {
    type: number
    sql: ${TABLE}."HEADCOUNT" ;;
  }

  dimension: market_age {
    type: string
    sql: ${TABLE}."MARKET_AGE" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: oec_category {
    type: string
    sql: ${TABLE}."OEC_CATEGORY" ;;
  }
  dimension: oec_range {
    type: string
    sql: ${TABLE}."OEC_RANGE" ;;
  }
  measure: count {
    type: count
    drill_fields: [id]
  }


}
