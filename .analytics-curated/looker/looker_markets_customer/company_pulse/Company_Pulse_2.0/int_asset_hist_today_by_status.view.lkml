view: int_asset_hist_today_by_status {
  derived_table: {
    sql:
      SELECT
        daily_timestamp,
        asset_inventory_status,
        rental_branch_id,
        SUM(rental_fleet_units) AS rental_fleet_units_sum,
        SUM(rental_fleet_oec)   AS rental_fleet_oec_sum
      FROM analytics.assets.int_asset_historical h
      WHERE daily_timestamp >= CURRENT_DATE
        AND daily_timestamp <  CURRENT_DATE + INTERVAL '1 day'
        AND in_rental_fleet
      GROUP BY 1,2,3
      ;;

  }

  dimension_group: daily_timestamp {
    type: time
    sql: ${TABLE}."DAILY_TIMESTAMP" ;;
  }
  dimension: rental_branch_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  measure: rental_fleet_units_sum {
    type: sum
    sql: ${TABLE}."RENTAL_FLEET_UNITS_SUM" ;;
    #drill_fields: [drill*]
  }

  measure: rental_fleet_oec_sum   {
    type: sum
    sql: ${TABLE}."RENTAL_FLEET_OEC_SUM"   ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
   # drill_fields: [drill*]
  }

  measure: rental_fleet_oec_percent_of_total {
    type: number
    sql: ${rental_fleet_oec_sum} / NULLIF(SUM(${rental_fleet_oec_sum}) OVER (), 0) ;;
    value_format_name: percent_1
  }

  set: drill{
    fields: [asset_inventory_status, rental_branch_id, int_asset_historical_current_day.asset_id, int_asset_historical_current_day.oec]
  }
}
