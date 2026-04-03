# view: all_equipment_rouse_estimates_new {
#   sql_table_name: "FLEET_OPT"."ALL_EQUIPMENT_ROUSE_ESTIMATES_NEW" ;;

# This table can be refreshed more often than AERE (not new), which is refreshed monthly

# Gets most recent values
  view: all_equipment_rouse_estimates_new {
    derived_table: {
      sql: (SELECT *
                 FROM DATA_SCIENCE.FLEET_OPT.ALL_EQUIPMENT_ROUSE_ESTIMATES_NEW AEREN
                     QUALIFY ROW_NUMBER() OVER (PARTITION BY AEREN.ASSET_ID ORDER BY AEREN.DATE_CREATED DESC) =
                             1) ;;
    }


  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: cost_with_attachments {
    type: number
    sql: ${TABLE}."COST_WITH_ATTACHMENTS" ;;
  }
  dimension: date_created {
    type: string
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: five_pct_commission_bound {
    type: number
    sql: ${TABLE}."FIVE_PCT_COMMISSION_BOUND" ;;
  }
  dimension: four_pct_commission_bound {
    type: number
    sql: ${TABLE}."FOUR_PCT_COMMISSION_BOUND" ;;
  }
  dimension: lower_sale_cutoff {
    type: number
    sql: ${TABLE}."LOWER_SALE_CUTOFF" ;;
  }
  dimension: net_book_value {
    type: number
    sql: ${TABLE}."NET_BOOK_VALUE" ;;
  }
  dimension: predictions_auction {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PREDICTIONS_AUCTION" ;;
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
  dimension: predictions_retail_upper_75 {
    type: number
    sql: ${TABLE}."PREDICTIONS_RETAIL_UPPER_75" ;;
  }
  dimension: predictions_wholesale {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PREDICTIONS_WHOLESALE" ;;
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
  dimension: rouse_wholesale {
    type: number
    sql: ${TABLE}."ROUSE_WHOLESALE" ;;
  }
  measure: count {
    type: count
  }
}
