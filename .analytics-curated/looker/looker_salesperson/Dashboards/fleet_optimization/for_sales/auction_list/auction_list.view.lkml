view: auction_list {
  derived_table: {
    sql:
      with assets as (
    select aere.asset_id as asset_id,
           dmfo.market_name,
           dafo.asset_inventory_status,
           dafo.asset_description,
           dafo.asset_year,
           dafo.asset_hours,
           dafo.asset_equipment_make as asset_equipment_make,
           dafo.asset_equipment_model_name,
           dafo.asset_equipment_class_name,
           dafo.asset_serial_number,
           case when asset_equipment_make = 'WACKER NEUSON' and asset_equipment_model_name ilike any ('SW21', 'SW24', 'SW28', 'ST31', 'ST35', 'ST45') then aere.predictions_auction + 10000
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY135%') then aere.predictions_auction + 11500
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY155%') then aere.predictions_auction + 11500
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY215%') then aere.predictions_auction + 17000
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY225%') then aere.predictions_auction + 17000
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY235%') then aere.predictions_auction + 17000
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY265%') then aere.predictions_auction + 23000
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY365%') then aere.predictions_auction + 28000
                when (asset_equipment_make = 'SANY' and asset_equipment_model_name ilike '%SY500%') then aere.predictions_auction + 35000
                else aere.predictions_auction
           end as auction_p,
           aere.predictions_auction as predictions_auction,
           dafo.asset_current_oec as asset_current_oec,
           dafo.asset_current_net_book_value as nbv,
           (auction_p - nbv) as sale_margin_no_fee,
           COUNT(*) OVER (PARTITION BY dafo.asset_equipment_make, dafo.asset_equipment_model_name) as total_asset_count_by_make_and_model,
           uah.time_utilization as asset_time_utilization,
           NTILE(100) OVER (ORDER BY uah.time_utilization ASC) AS asset_time_utilization_percentile,
           uah.financial_utilization as asset_financial_utilization,
           NTILE(100) OVER (ORDER BY uah.financial_utilization ASC) AS asset_financial_utilization_percentile
    from data_science.fleet_opt.all_equipment_rouse_estimates aere
    left join fleet_optimization.gold.utilization_asset_historical uah
           on aere.asset_id = uah.asset_id
    inner join fleet_optimization.gold.dim_timeframe_windows_historic tf
           on uah.tf_key = tf.tf_key
    left join fleet_optimization.gold.dim_assets_fleet_opt dafo
           on aere.asset_id = dafo.asset_id
    inner join fleet_optimization.gold.dim_markets_fleet_opt dmfo
           on dafo.asset_market_id = dmfo.market_id
    left join analytics.debt.asset_nbv_all_owners afs
           on aere.asset_id = afs.asset_id
    where aere.date_created = (select max(date_created) from data_science.fleet_opt.all_equipment_rouse_estimates)
      and aere.net_book_value > 0
      and aere.predictions_auction > 0
      and dafo.asset_current_oec > 0
      and dafo.asset_hours > 1
      and sale_margin_no_fee > 0
      and nbv is not null
      and tf.timeframe = 'annually'
      and tf.end_date in (select MAX(end_date) from fleet_optimization.gold.dim_timeframe_windows_historic)
      and asset_inventory_status not ilike '%Hard Down%'
      and asset_inventory_status not ilike '%Soft Down%'
      and asset_inventory_status not ilike '%Needs Inspection%'
      and asset_inventory_status not ilike '%Unrecognized%'
      -- and asset_inventory_status not ilike '%On Rent%'
      and dafo.asset_year < 2023
      and dafo.asset_oef_deal_flag = FALSE
      and dafo.asset_company_id = 1854
      and dafo.asset_own_flag = FALSE
      and dafo.asset_deal_sales_flag = FALSE
      and dafo.asset_oem_deal_flag = FALSE
      order by sale_margin_no_fee desc
),
class_utilization as (
    --sample query for historical utilization calculations at the asset subcategory level.
        select
              asset.asset_equipment_class_name
            , tf.days_in_period
        --sum up the measures of interest using these formulas
            , sum(util.asset_count)                                      as total_assets
            , sum(dor.days_on_rent)                                      as total_days_on_rent
            , nullif(sum(dif.days_in_fleet),0)                           as total_days_in_fleet
            , round(nullif(sum(util.rental_oec),0),2)                    as total_rental_oec
            , round(nullif(sum(util.in_fleet_oec),0),2)                  as total_in_fleet_oec
            , sum(util.oec_adjusted)                                     as total_oec_adjusted
            , sum(rev.revenue)                                           as total_revenue
            , round(((total_revenue * 365) / tf.days_in_period),2)       as annualized_revenue
            , total_days_on_rent / total_days_in_fleet                   as unit_utilization
            , total_rental_oec / total_in_fleet_oec                      as class_time_utilization
            , annualized_revenue / total_oec_adjusted                    as class_financial_utilization
            , ntile(100) over (order by class_time_utilization asc) as class_time_utilization_percentile
            , ntile(100) over (order by class_financial_utilization asc) as class_financial_utilization_percentile

        from fleet_optimization.gold.utilization_asset_historical util

        --join in all needed dimensions
        inner join fleet_optimization.gold.dim_agg_historic_days_in_fleet_asset dif
            on util.agg_dif_calculation_key = dif.agg_dif_calculation_key
        inner join fleet_optimization.gold.dim_agg_historic_days_on_rent_asset dor
            on util.agg_dor_calculation_key = dor.agg_dor_calculation_key
        inner join fleet_optimization.gold.dim_agg_historic_revenue_asset rev
            on util.agg_rev_calculation_key = rev.agg_rev_calculation_key
        inner join fleet_optimization.gold.dim_assets_fleet_opt asset
            on util.asset_id = asset.asset_id
        inner join fleet_optimization.gold.dim_timeframe_windows_historic tf
            on util.tf_key = tf.tf_key

        --for historical utilization, filters are necessary to avoid duplication!
        --use a RUN DATE to anchor your query and a TIMEFRAME to specify the aggregation level
        where tf.end_date in (select MAX(end_date) from fleet_optimization.gold.dim_timeframe_windows_historic)
        and tf.timeframe = 'annually'
            --and util.asset_company_id = 1854 --you may want to filter assets based on the company_id of ownership

        group by 1,2
),

asset_data as (
    select a.*,
           cu.class_time_utilization,
           cu.class_time_utilization_percentile,
           cu.class_financial_utilization,
           cu.class_financial_utilization_percentile,
           COUNT(*) OVER (PARTITION BY a.asset_equipment_make, a.asset_equipment_model_name) AS result_asset_count_by_make_and_model
    from assets a
    join class_utilization cu
        on a.asset_equipment_class_name = cu.asset_equipment_class_name
    WHERE a.total_asset_count_by_make_and_model > 1
      AND a.asset_time_utilization_percentile <=90
      AND a.asset_financial_utilization_percentile <= 90
      AND cu.class_time_utilization_percentile <= 90
      AND cu.class_financial_utilization_percentile <= 90
)

SELECT *,
       CASE
            WHEN result_asset_count_by_make_and_model = total_asset_count_by_make_and_model THEN 1
            ELSE 0
       END AS sell_out_flag
FROM asset_data
WHERE sell_out_flag = 0
order by sale_margin_no_fee desc



;;
  }

  parameter: fee_pct {
    type: number
    description: "Select a fee percentage between 0 and 20%"
    allowed_value: {
      value: "0"
      label: "0%"
    }
    allowed_value: {
      value: "0.01"
      label: "1%"
    }
    allowed_value: {
      value: "0.02"
      label: "2%"
    }
    allowed_value: {
      value: "0.03"
      label: "3%"
    }
    allowed_value: {
      value: "0.04"
      label: "4%"
    }
    allowed_value: {
      value: "0.05"
      label: "5%"
    }
    allowed_value: {
      value: "0.06"
      label: "6%"
    }
    allowed_value: {
      value: "0.08"
      label: "8%"
    }
    allowed_value: {
      value: "0.1"
      label: "10%"
    }
    allowed_value: {
      value: "0.12"
      label: "12%"
    }
    allowed_value: {
      value: "0.15"
      label: "15%"
    }
    allowed_value: {
      value: "0.2"
      label: "20%"
    }

  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: asset_description {
    type: string
    sql: ${TABLE}."ASSET_DESCRIPTION" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: asset_year {
    type: number
    sql: ${TABLE}."ASSET_YEAR" ;;
    value_format_name: id
  }

  dimension: asset_hours {
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
  }

  dimension: asset_equipment_make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
  }

  dimension: asset_serial_number {
    type: string
    sql: ${TABLE}."ASSET_SERIAL_NUMBER" ;;
  }

  dimension: asset_equipment_model_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME" ;;
  }

  dimension: asset_equipment_class_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: auction_sale_margin_no_fee {
    type: number
    sql: ${TABLE}."SALE_MARGIN_NO_FEE" ;;
    value_format_name: usd
  }

  dimension: total_asset_count_by_make_and_model {
    type: number
    sql: ${TABLE}."TOTAL_ASSET_COUNT_BY_MAKE_AND_MODEL" ;;
  }

  dimension: asset_time_utilization {
    type: number
    sql: ${TABLE}."ASSET_TIME_UTILIZATION" ;;
    value_format_name: percent_2
  }

  dimension: asset_time_utilization_percentile {
    type: number
    sql: ${TABLE}."ASSET_TIME_UTILIZATION_PERCENTILE" ;;
  }

  dimension: asset_financial_utilization {
    type: number
    sql: ${TABLE}."ASSET_FINANCIAL_UTILIZATION" ;;
    value_format_name: percent_2
  }

  dimension: asset_financial_utilization_percentile {
    type: number
    sql: ${TABLE}."ASSET_FINANCIAL_UTILIZATION_PERCENTILE" ;;
  }

  dimension: class_time_utilization {
    type: number
    sql: ${TABLE}."CLASS_TIME_UTILIZATION" ;;
    value_format_name: percent_2
  }

  dimension: class_time_utilization_percentile {
    type: number
    sql: ${TABLE}."CLASS_TIME_UTILIZATION_PERCENTILE" ;;
  }

  dimension: class_financial_utilization {
    type: number
    sql: ${TABLE}."CLASS_FINANCIAL_UTILIZATION" ;;
    value_format_name: percent_2
  }

  dimension: class_financial_utilization_percentile {
    type: number
    sql: ${TABLE}."CLASS_FINANCIAL_UTILIZATION_PERCENTILE" ;;
  }

  dimension: net_book_value {
    type: number
    sql: ${TABLE}."NBV" ;;
    value_format_name: usd
  }

  dimension: auction_price {
    type: number
    sql: ${TABLE}."PREDICTIONS_AUCTION" ;;
    value_format_name: usd
  }

  dimension: asset_current_oec {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
    value_format_name: usd
  }

  dimension: fee {
    type: number
    sql: (${auction_price} * {% parameter fee_pct %}) ;;
    value_format_name: usd
  }


  dimension: auction_sale_margin_with_fee {
    type: number
    sql: (${auction_price} + ${subsidy} - ${fee} - ${net_book_value}) ;;
    value_format_name: usd
  }

  dimension: auction_sale_margin_pct {
    type: number
    sql: (${auction_price} +${subsidy} - ${fee} - ${net_book_value}) / (${auction_price}+${subsidy});;
    value_format_name: percent_2
  }

  dimension: subsidy {
    type: number
    sql: case when asset_equipment_make = 'WACKER NEUSON' and ${asset_equipment_model_name} ilike any ('SW21', 'SW24', 'SW28', 'ST31', 'ST35', 'ST45') then 10000
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY135%') then 11500
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY155%') then 11500
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY215%') then 17000
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY225%') then 17000
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY235%') then 17000
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY265%') then 23000
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY365%') then 28000
                when (asset_equipment_make ilike '%SANY%' and asset_equipment_model_name ilike '%SY500%') then 35000
                else 0
           end;;
    value_format_name: usd
  }

  measure: sum_of_auction_sale_margin{
    type: sum
    sql: ${auction_sale_margin_with_fee} ;;
    value_format_name: usd
  }

  measure: sum_of_auction_price{
    type: sum
    sql: ${auction_price} ;;
    value_format_name: usd
  }

  measure: sum_of_fees{
    type: sum
    sql: ${fee} ;;
    value_format_name: usd
  }

  measure: sum_of_net_book_value {
    type: sum
    sql: ${net_book_value} ;;
    value_format_name: usd
  }

  measure: sum_of_subsidy {
    type: sum
    sql: ${subsidy} ;;
    value_format_name: usd
  }

  set: detail {
    fields: [
      asset_id, market_name, asset_inventory_status, asset_year, asset_hours,
      asset_equipment_make, net_book_value, auction_price, asset_current_oec,
      asset_serial_number, asset_equipment_model_name,
      asset_equipment_class_name, auction_sale_margin_no_fee, total_asset_count_by_make_and_model,
      asset_time_utilization, asset_time_utilization_percentile, asset_financial_utilization,
      asset_financial_utilization_percentile, class_time_utilization, asset_description,
      class_time_utilization_percentile, class_financial_utilization,
      class_financial_utilization_percentile, fee, auction_sale_margin_with_fee, auction_sale_margin_pct
    ]
  }

  }
