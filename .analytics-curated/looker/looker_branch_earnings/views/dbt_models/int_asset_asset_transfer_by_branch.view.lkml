view: int_asset_asset_transfer_by_branch {
    derived_table: {
      sql:
          select *
          from analytics.assets.int_asset_asset_transfer_by_branch
          where date_trunc('month', transfer_date) =
            date_trunc(
              'month',
              (select max(trunc::date)
               from analytics.gs.plexi_periods
               where {% condition period_name %} display {% endcondition %})
            )
          ;;
    }


  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_status_as_transferred {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_AS_TRANSFERRED" ;;
  }
  dimension: is_new_market {
    type: yesno
    sql: ${TABLE}."IS_NEW_MARKET" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: next_market_id {
    type: number
    sql: ${TABLE}."NEXT_MARKET_ID" ;;
  }
  dimension: next_market_name {
    type: string
    sql: ${TABLE}."NEXT_MARKET_NAME" ;;
  }
  measure: oec {
    label: "Total OEC (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."OEC" ;;
    drill_fields: [asset_id,asset_inventory_status_as_transferred,next_market_id, next_market_name,transfer_date_date]
  }

  dimension: receiver_market_be_age {
    type: number
    sql: ${TABLE}."RECEIVER_MARKET_BE_AGE" ;;
  }
  dimension_group: transfer_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."TRANSFER_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [asset_id,asset_inventory_status_as_transferred,next_market_id, next_market_name,transfer_date_date]
  }
}
