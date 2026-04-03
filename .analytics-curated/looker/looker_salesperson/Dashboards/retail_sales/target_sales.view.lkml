view: target_sales {

    derived_table:{
              sql:
         WITH utilization_percentile AS (
            SELECT
                d.region_id,
                d.name AS district_name,
                m.district_id,
                dafo.asset_market_id as market_id,
                m.name AS market_name,
                uah1.asset_id as asset_id,
                afs.nbv,
                dif.days_in_fleet,
                anbv.hours,
                aa.owner,
                aa.make,
                aa.model,
                aa.category,
                aa.class,
                aere.four_pct_commission_bound,
                aere.five_pct_commission_bound,
                uah1.time_utilization,
                uah1.financial_utilization,
                NTILE(100) OVER (ORDER BY uah1.time_utilization ASC) AS time_utilization_percentile,
                NTILE(100) OVER (ORDER BY uah1.financial_utilization ASC) AS financial_utilization_percentile
            FROM fleet_optimization.gold.utilization_asset_historical uah1
            inner join fleet_optimization.gold.dim_assets_fleet_opt dafo
                ON uah1.asset_id = dafo.asset_id
            inner join fleet_optimization.gold.dim_agg_historic_days_in_fleet_asset dif
                on uah1.agg_dif_calculation_key = dif.agg_dif_calculation_key
            inner join fleet_optimization.gold.dim_timeframe_windows_historic tf
                on uah1.tf_key = tf.tf_key
            LEFT JOIN es_warehouse.public.markets m
                ON dafo.asset_market_id = m.market_id
            LEFT JOIN es_warehouse.public.districts d
                ON m.district_id = d.district_id
            LEFT JOIN es_warehouse.public.assets_aggregate aa
                ON uah1.asset_id = aa.asset_id
            LEFT JOIN analytics.public.asset_financing_snapshots afs
                on uah1.asset_id = afs.asset_id
            LEFT JOIN analytics.debt.asset_nbv_all_owners anbv
                on uah1.asset_id = anbv.asset_id
            LEFT JOIN data_science.fleet_opt.all_equipment_rouse_estimates aere
                on uah1.asset_id = aere.asset_id
            WHERE tf.end_date in (select MAX(end_date) from fleet_optimization.gold.dim_timeframe_windows_historic)
            AND afs.snapshot_date in (SELECT MAX(snapshot_date) from analytics.public.asset_financing_snapshots)
            AND tf.timeframe = 'annually'
            AND dif.days_in_fleet > 250
            AND afs.nbv > 10000
            AND m.market_id IS NOT NULL
            AND aa.owner ilike '%EQUIPMENTSHARE%'
            AND aere.date_created in (Select Max(date_created) from data_science.fleet_opt.all_equipment_rouse_estimates)
        )

        SELECT *
        FROM utilization_percentile
        WHERE time_utilization_percentile <= 1  -- Replace X with your desired percentile value
        AND financial_utilization_percentile <= 2  -- Replace Y with your desired percentile value
        ORDER BY region_id, district_id, market_id, category;;


            }

    dimension: asset_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: district_id {
      type: number
      sql: ${TABLE}."DISTRICT_ID" ;;
    }

    dimension: district_name {
      type: string
      sql: ${TABLE}."DISTRICT_NAME" ;;
    }

    dimension: region_id {
      type: number
      sql: ${TABLE}."REGION_ID" ;;
    }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }

  dimension: net_book_value {
    type: number
    sql: ${TABLE}."NBV" ;;
    value_format_name: usd_0
  }

  dimension: days_in_fleet {
    type: number
    sql: ${TABLE}."DAYS_IN_FLEET" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: class  {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: time_utilization_percentile {
    type: number
    sql: ${TABLE}."TIME_UTILIZATION_PERCENTILE" ;;
    value_format_name: decimal_1
  }

  dimension: financial_utilization_percentile {
    type: number
    sql: ${TABLE}."FINANCIAL_UTILIZATION_PERCENTILE" ;;
    value_format_name: decimal_1
  }

  dimension: submit_asset_quote_request {
    #type: string
    html: <font color="blue "><u><a href = "https://asset-retail-quote.equipmentshare.com/?assetId={{asset_id._value }}" target="_blank">Submit Quote Request</a></font></u> ;;
    sql: ${TABLE}.ASSET_ID
      ;;
  }

  measure: retail_4pct_commission_range {
    label: "Bench (4% Commission)"
    type: sum
    value_format_name: usd
    sql:${TABLE}."FOUR_PCT_COMMISSION_BOUND" ;;
}

  measure: retail_5pct_commission_range {
    label: "Bench (5% Commission)"
    type: sum
    value_format_name: usd
    sql:${TABLE}."FIVE_PCT_COMMISSION_BOUND" ;;
  }

    set: detail {
      fields: [asset_id,  net_book_value, district_id, district_name, region_id, market_id, market_name, days_in_fleet, hours, owner, make, model, category, class, time_utilization_percentile, financial_utilization_percentile, submit_asset_quote_request]
    }
  }
