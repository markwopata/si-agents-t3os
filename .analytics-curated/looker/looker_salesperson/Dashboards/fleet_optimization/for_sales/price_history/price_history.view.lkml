  view: price_history {
    derived_table: {
      sql:
with pricing_history as (
select
    round(aere.asset_id,0) as asset_id,
    aere.cost_with_attachments as oec,
    aere.net_book_value as nbv,
    aere.five_pct_commission_bound as online_price,
    aere.four_pct_commission_bound as bench_price,
    aere.lower_sale_cutoff as floor_price,
    aere.date_created as priced_date
from data_science.fleet_opt.all_equipment_rouse_estimates aere
where priced_date < (select date(min(snapshot_date)) from data_science.fleet_opt.asset_pricing_targets)
union
select
    round(apt.asset_id,0) as asset_id,
    aom2.asset_oec as oec,
    coalesce(
        apt.spc_nbv,
        nbvm.total_estimated_nbv
        )
         as nbv,
    apt.online_target_price as online_price,
    apt.bench_target_price as bench_price,
    apt.floor_target_price as floor_price,
    date(apt.snapshot_date) as priced_date
from data_science.fleet_opt.asset_pricing_targets apt
left join fleet_optimization.gold.v_asset_oec_by_month aom2
    on apt.asset_id = aom2.asset_id
    and date(apt.snapshot_date) between aom2.start_date and aom2.date_month_end
left join fleet_optimization.gold.dim_agg_asset_nbv_by_month nbvm
    on (apt.snapshot_date) = nbvm.nbv_as_of_date
)
select *
from pricing_history
order by asset_id desc, priced_date desc
    ;;
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}.asset_id ;;
      value_format_name: id
    }

    dimension: oec_estimate {
      type: number
      sql: ${TABLE}.oec ;;
      value_format_name: usd
    }

    dimension: nbv_estimate {
      type: number
      sql: ${TABLE}.nbv ;;
      value_format_name: usd
    }

    dimension: online_price_estimate {
      type: number
      sql: ${TABLE}.online_price ;;
      value_format_name: usd
    }

    dimension: bench_price_estimate {
      type: number
      sql: ${TABLE}.bench_price ;;
      value_format_name: usd
    }

    dimension: floor_price_estimate {
      type: number
      sql: ${TABLE}.floor_price ;;
      value_format_name: usd
    }

    dimension_group: live_in_production {
      type: time
      timeframes: [raw, time, date, week, month, year]
      sql: ${TABLE}.priced_date ;;
    }
  }
