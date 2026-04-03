view: low_len_id_asset_list {
    derived_table: {
      sql:
      WITH valuations AS (
        SELECT
          asset_id,
          predictions_retail,
          predictions_wholesale,
          predictions_auction
        FROM data_science.fleet_opt.all_equipment_rouse_estimates
        WHERE date_created IN (
          SELECT MAX(date_created)
          FROM data_science.fleet_opt.all_equipment_rouse_estimates
        )
      )

      SELECT
        a.asset_id,
        a.asset_serial_number,
        a.asset_equipment_make,
        a.asset_equipment_model_name,
        a.asset_inventory_status,
        a.asset_year,
        a.is_asset_eligible_for_sale,
        b.market_id,
        b.market_district,
        b.market_name,
        b.market_region,
        a.asset_current_net_book_value AS net_book_value,
        a.asset_floor_target_price as floor_target_price,
        a.asset_floor_target_price - a.asset_current_net_book_value AS floor_margin,
        a.asset_bench_target_price as bench_target_price,
        a.asset_bench_target_price - a.asset_current_net_book_value AS bench_margin,
        a.asset_online_target_price as online_target_price,
        a.asset_online_target_price - a.asset_current_net_book_value AS online_margin,
        v.predictions_retail AS retail,
        v.predictions_wholesale AS wholesale,
        v.predictions_auction AS auction,
        COALESCE(1.05 * a.asset_current_net_book_value, floor_target_price) AS recommended_minimum_sale_price,
        CASE
          WHEN a.asset_current_net_book_value > floor_target_price THEN TRUE
          ELSE FALSE
        END AS nbv_high_flag
      FROM fleet_optimization.gold.dim_assets_fleet_opt a
      JOIN fleet_optimization.gold.dim_markets_fleet_opt b
        ON a.asset_market_key = b.market_key
      JOIN valuations v
        ON a.asset_id = v.asset_id
      WHERE LENGTH(a.asset_id) IN (1, 2, 3, 4)
        AND a.asset_company_id IN (1854)
      ORDER BY a.asset_id ASC
    ;;
    }

    dimension: asset_id {
      primary_key: yes
      type: number
      sql: ${TABLE}.asset_id ;;
      value_format_name: id
    }

    dimension: asset_serial_number {
      type: string
      sql: ${TABLE}.asset_serial_number ;;
    }

    dimension: asset_equipment_make {
      type: string
      sql: ${TABLE}.asset_equipment_make ;;
    }

    dimension: asset_equipment_model_name {
      type: string
      sql: ${TABLE}.asset_equipment_model_name ;;
    }

    dimension: asset_inventory_status {
      type: string
      sql: ${TABLE}.asset_inventory_status ;;
    }

    dimension: asset_year {
      type: number
      sql: ${TABLE}.asset_year ;;
    }

    dimension: market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.market_id ;;
    }

    dimension: market_district {
      type: string
      sql: ${TABLE}.market_district ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}.market_name ;;
    }

    dimension: market_region {
      type: string
      sql: ${TABLE}.market_region ;;
    }

    dimension: net_book_value {
      type: number
      sql: ${TABLE}.net_book_value ;;
      value_format_name: usd
    }

    dimension: floor_target_price {
      type: number
      sql: ${TABLE}.floor_target_price ;;
      value_format_name: usd
    }

    dimension: floor_margin {
      type: number
      sql: ${TABLE}.floor_margin ;;
      value_format_name: usd
    }

    dimension: bench_target_price {
      type: number
      sql: ${TABLE}.bench_target_price ;;
      value_format_name: usd
    }

    dimension: sale_eligibility {
      type: yesno
      sql: ${TABLE}.is_asset_eligible_for_sale ;;
    }

    dimension: bench_margin {
      type: number
      sql: ${TABLE}.bench_margin ;;
      value_format_name: usd
    }

    dimension: online_target_price {
      type: number
      sql: ${TABLE}.online_target_price ;;
      value_format_name: usd
    }

    dimension: online_margin {
      type: number
      sql: ${TABLE}.online_margin ;;
      value_format_name: usd
    }

    dimension: retail {
      type: number
      sql: ${TABLE}.retail ;;
      value_format_name: usd
    }

    dimension: wholesale {
      type: number
      sql: ${TABLE}.wholesale ;;
      value_format_name: usd
    }

    dimension: auction {
      type: number
      sql: ${TABLE}.auction ;;
      value_format_name: usd
    }

    dimension: recommended_minimum_sale_price {
      type: number
      sql: ${TABLE}.recommended_minimum_sale_price ;;
      value_format_name: usd
    }

    dimension: nbv_high_flag {
      type: yesno
      sql: ${TABLE}.nbv_high_flag ;;
    }

    measure: total_net_book_value{
      type: sum
      sql: ${net_book_value} ;;
      value_format_name: usd
    }

    measure: total_minimum_recommended_sale_price {
      type: sum
      sql: ${recommended_minimum_sale_price} ;;
      value_format_name: usd
    }

    measure: total_floor {
      type: sum
      sql: ${floor_target_price} ;;
      value_format_name: usd
    }

    measure: total_floor_margin {
      type: sum
      sql: ${floor_margin} ;;
      value_format_name: usd
    }

  measure: count_distinct{
    type: count_distinct
    sql: ${asset_id} ;;
  }

}
