view: ute_vs_temp {
  derived_table: {
    sql:
with assets as (
    select a.asset_id
        , coalesce(scdr.rental_branch_id, scdi.inventory_branch_id) market_id
        , a.ASSET_EQUIPMENT_CLASS_NAME
        , u.unit_utilization --is this okay to average?
        , tf.start_date
    from PLATFORM.GOLD.DIM_ASSETS a
    join FLEET_OPTIMIZATION.GOLD.UTILIZATION_ASSET_HISTORICAL u
        on a.asset_id = u.asset_id
    join FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC tf
        on u.tf_key = tf.tf_key
    left join ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY scdi
        on scdi.asset_id = a.asset_id
            and scdi.date_start <= tf.start_date
            and scdi.date_end > tf.end_date
    left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP scdr
        on scdr.asset_id = a.asset_id
            and scdr.date_start <= tf.start_date
            and scdr.date_end > tf.end_date
    where tf.timeframe = 'monthly'
        and a.ASSET_EQUIPMENT_CLASS_NAME ilike any ('Chiller%Ton Air Cooled', 'Air Handler%Ton%', 'Chiller Pump Electric%GPM%', 'Chiller/Pump Test Stand 1000 Gallon')
        and coalesce(scdr.rental_branch_id, scdi.inventory_branch_id) is not null --Only want where it was a one branch the whole month
    order by a.ASSET_EQUIPMENT_CLASS_NAME, tf.start_date asc
)
-- select asset_id, start_date, count(asset_id, start_date) c from assets group by 1,2 order by c desc

--Need to find the average low temperature at each of these branches for the whole month
, markets as (
    select m.market_id
        , m.market_name
        , l.zip_code
        , postal_code
        , abs(l.zip_code - postal_code) as nearest
    from ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    join ES_WAREHOUSE.PUBLIC.MARKETS mr
        on mr.market_id = m.market_id
    left join ES_WAREHOUSE.PUBLIC.LOCATIONS l
        on l.location_id = mr.location_id
    full outer join (select distinct postal_code from WEATHER.STANDARD_TILE.HISTORY_DAY where country = 'US')
)

 , min_market as (
    select market_id
        , market_name
        , zip_code
        , min(nearest) as joinkey
    from markets
    group by 1,2,3
)

, closest_postal as (
    select mm.market_id
        , mm.market_name
        , mm.zip_code
        , m.postal_code --weather postal code
        , row_number() over (partition by mm.market_id order by m.postal_code) r
    from min_market mm
    join markets m
        on m.market_id = mm.market_id
            and m.nearest = mm.joinkey
    qualify r = 1
)

, avg_temp as (
    select cp.market_id
        , date_trunc(month, hd.date_valid_std) as mth
        , avg(hd.min_temperature_air_2m_f) as avg_low
    from closest_postal cp
    join WEATHER.STANDARD_TILE.HISTORY_DAY hd
        on hd.postal_code = cp.postal_code
    group by 1,2
)

-- , ute_temp as (
    select a.start_date
        , a.market_id
        -- , a.asset_id
        , a.ASSET_EQUIPMENT_CLASS_NAME
        , at.avg_low
        , avg(a.unit_utilization) avg_ute
    from assets a
    join avg_temp at
        on at.market_id = a.market_id
            and at.mth = a.start_date
    group by 1,2,3,4
    order by start_date asc, a.market_id ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}.start_date ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.ASSET_EQUIPMENT_CLASS_NAME ;;
  }

  dimension: branch_month_avg_low {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.avg_low ;;
  }

  measure: avg_low {
    type: number
    value_format_name: decimal_1
    sql: ${branch_month_avg_low} ;;
  }

  dimension: branch_month_class_avg_ute {
    type: number
    value_format_name: decimal_3
    sql: ${TABLE}.avg_ute ;;
  }

  measure: avg_ute {
    type: average
    value_format_name: decimal_3
    sql: ${branch_month_class_avg_ute} ;;
  }
}
