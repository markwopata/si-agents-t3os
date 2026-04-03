view: all_equipment_rouse_estimates {
  derived_table: {
    sql: (SELECT *
                 FROM DATA_SCIENCE.FLEET_OPT.ALL_EQUIPMENT_ROUSE_ESTIMATES AERE
                     QUALIFY ROW_NUMBER() OVER (PARTITION BY AERE.ASSET_ID ORDER BY AERE.DATE_CREATED DESC) =
                             1) ;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: cost_with_attachments {
    type: number
    sql: ${TABLE}."COST_WITH_ATTACHMENTS" ;;
    value_format_name: usd
  }
  dimension: date_created {
    type: string
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: lower_sale_cutoff {
    type: number
    sql: ${TABLE}."LOWER_SALE_CUTOFF" ;;
  }
  dimension: net_book_value {
    type: number
    sql: ${TABLE}."NET_BOOK_VALUE" ;;
    value_format_name: usd
  }
  dimension: predictions_auction {
    type: number
    sql: ${TABLE}."PREDICTIONS_AUCTION" ;;
    value_format_name: usd
    label: "Predicted Auction"
  }
  dimension: predictions_auction_lower_25 {
    type: number
    sql: ${TABLE}."PREDICTIONS_AUCTION_LOWER_25" ;;
  }
  dimension: predictions_auction_upper_75 {
    type: number
    sql: ${TABLE}."PREDICTIONS_AUCTION_UPPER_75" ;;
  }
  dimension: predictions_retail {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PREDICTIONS_RETAIL" ;;
    label: "Predicted Retail"
  }
  dimension: predictions_retail_lower_25 {
    type: number
    sql: ${TABLE}."PREDICTIONS_RETAIL_LOWER_25" ;;
  }
  dimension: predictions_retail_plus_ten_percent {
    type: number
    sql: ${TABLE}."PREDICTIONS_RETAIL_PLUS_TEN_PERCENT" ;;
  }
  dimension: predictions_retail_upper_75 {
    type: number
    sql: ${TABLE}."PREDICTIONS_RETAIL_UPPER_75" ;;
  }
  dimension: predictions_wholesale {
    type: number
    sql: ${TABLE}."PREDICTIONS_WHOLESALE" ;;
    value_format_name: usd
    label: "Predicted Wholesale"
  }
  dimension: predictions_wholesale_lower_25 {
    type: number
    sql: ${TABLE}."PREDICTIONS_WHOLESALE_LOWER_25" ;;
  }
  dimension: predictions_wholesale_upper_75 {
    type: number
    sql: ${TABLE}."PREDICTIONS_WHOLESALE_UPPER_75" ;;
  }
  dimension: rouse_auction {
    type: number
    sql: ${TABLE}."ROUSE_AUCTION" ;;
  }
  dimension: rouse_retail {
    type: number
    sql: ${TABLE}."ROUSE_RETAIL" ;;
  }
  measure: market_value {
    type: number
    value_format_name: usd
    sql: coalesce(${TABLE}."ROUSE_RETAIL", ${TABLE}."PREDICTIONS_RETAIL") ;;
  }
  dimension: rouse_wholesale {
    type: number
    sql: ${TABLE}."ROUSE_WHOLESALE" ;;
  }

  measure: count {
    type: count
  }

  measure: estimated_olv {
    label: "Estimated OLV"
    type: number
    sql: round((0.7*${predictions_retail}) + (0.3*${predictions_auction}), 2) ;;
    value_format_name: usd
  }
}
