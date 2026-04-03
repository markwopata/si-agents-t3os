view: prev_and_current_asset_branch {
  derived_table: {
      sql:
with prep_inventory as (
    select asset_id
        , lag(inventory_branch_id) over (partition by asset_id order by date_start asc) as prev_inventory_branch_id
        , lag(date_end) over (partition by asset_id order by date_start asc) prev_inventory_branch_end_date
        , inventory_branch_id current_inventory_branch_id
        , current_flag
    from ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY scd
)

, prep_rental as (
    select asset_id
        , lag(rental_branch_id) over (partition by asset_id order by date_start asc) as prev_rental_branch_id
        , lag(date_end) over (partition by asset_id order by date_start asc) prev_rental_branch_end_date
        , rental_branch_id current_rental_branch_id
        , current_flag
    from ES_WAREHOUSE.SCD.SCD_ASSET_RSP
)

select a.asset_id
    , coalesce(pr.prev_rental_branch_id, pi.prev_inventory_branch_id) as prev_branch_id
    , pm.market_name as prev_branch_name
    , coalesce(pr.prev_rental_branch_end_date, pi.prev_inventory_branch_end_date) as prev_branch_end_date
    , coalesce(pr.current_rental_branch_id, pi.current_inventory_branch_id) as current_branch_id
    , cm.market_name as current_branch_name
from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
left join prep_inventory pi
    on pi.asset_id = a.asset_id
        and pi.current_flag = true
left join prep_rental pr
    on pr.asset_id = a.asset_id
        and pr.current_flag = true
left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT pm
    on pm.market_id = coalesce(pr.prev_rental_branch_id, pi.prev_inventory_branch_id)
left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT cm
    on cm.market_id = coalesce(pr.current_rental_branch_id, pi.current_inventory_branch_id);;
    }

    dimension: asset_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.asset_id ;;
    }

    dimension: prev_branch_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.prev_branch_id ;;
    }

    dimension: prev_branch_name {
      type: string
      sql: ${TABLE}.prev_branch_name ;;
    }

    dimension_group: prev_branch_end {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}.prev_branch_end_date ;;
    }

    dimension: current_branch_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.current_branch_id  ;;
    }

    dimension: current_branch_name {
      type: string
      sql: ${TABLE}.current_branch_name ;;
    }
  }
