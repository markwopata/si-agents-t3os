view: year_trailing_class_utilization {
  derived_table: {
      sql:
select concat(a.asset_equipment_class_name, m.market_id) as primary_key
    , m.market_region as region_id
    , m.market_region_name as region_name
    , m.market_district as district
    , m.market_id
    , m.market_name
    , a.asset_equipment_class_name
    , sum(zeroifnull(dor.days_on_rent)) as market_class_days_on_rent
    , sum(zeroifnull(dif.days_in_fleet)) as market_class_days_in_fleet
    , iff(market_class_days_in_fleet <> 0, market_class_days_on_rent / market_class_days_in_fleet, null) as market_class_unit_ute
from FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC t1
join FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_ON_RENT_ASSET_MARKET dor
    on t1.tf_key = dor.tf_key
        and t1.timeframe = 'annually'
        and t1.start_date > '2023-01-01'
        and t1.run_date = iff(date_trunc(month, current_date)=current_date, dateadd(month,-1,current_date()),date_trunc(month, current_date))
        --modifying the date join due to nulls on the first of the month when the model has not yet ran. #HL 4.1.26
join FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_IN_FLEET_ASSET_MARKET dif
    on dif.asset_id = dor.asset_id
        and dif.market_id = dor.market_id
        and dif.tf_key = dor.tf_key
join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
    on a.asset_id = dor.asset_id
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    on m.market_id = dif.market_id
group by 1,2,3,4,5,6,7;;
    }

    dimension: primary_key {
      type: number
      primary_key: yes
      value_format_name: id
      sql: ${TABLE}.primary_key ;;
    }

    dimension: region_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.region_id ;;
    }

    dimension: region_name {
      type: string
      sql: ${TABLE}.region_name ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}.district ;;
    }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

    dimension: asset_class {
      type: string
      sql: ${TABLE}.asset_equipment_class_name ;;
    }

    dimension: market_class_days_on_rent {
      type: number
      sql: ${TABLE}.market_class_days_on_rent ;;
    }

    measure: days_on_rent {
      type: sum
      sql: ${market_class_days_on_rent} ;;
    }

    dimension: market_class_days_in_fleet {
      type: number
      sql: ${TABLE}.market_class_days_in_fleet ;;
    }

    measure: days_in_fleet {
      type: sum
      sql: ${market_class_days_in_fleet} ;;
    }

    dimension: market_class_unit_ute {
      type: number
      value_format_name: percent_1
      sql: ${TABLE}.market_class_unit_ute ;;
    }

    measure: unit_ute {
      type: number
      value_format_name: percent_1
      sql: iff(${days_in_fleet} <> 0, ${days_on_rent} / ${days_in_fleet}, null) ;;
    }
  }

view: year_trailing_district_class_utilization_agg {
  derived_table: {
    sql:
-- New Query Preagg District Ute
SELECT
    a.asset_equipment_class_name,
    m.market_district AS district,
    dor.tf_key,
    -- District-level rollup
    SUM(COALESCE(dor.days_on_rent, 0)) AS district_days_on_rent,
    SUM(COALESCE(dif.days_in_fleet, 0)) AS district_days_in_fleet,
    IFF(SUM(COALESCE(dif.days_in_fleet, 0)) <> 0,
        SUM(COALESCE(dor.days_on_rent, 0)) / SUM(COALESCE(dif.days_in_fleet, 0)),
        NULL) AS district_unit_ute
FROM FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC t1
JOIN FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_ON_RENT_ASSET_MARKET dor
    ON t1.tf_key = dor.tf_key
   AND t1.timeframe = 'annually'
   AND t1.start_date > '2023-01-01'
   AND t1.run_date = iff(date_trunc(month, current_date)=current_date, dateadd(month,-1,current_date()),date_trunc(month, current_date))
JOIN FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_IN_FLEET_ASSET_MARKET dif
    ON dif.asset_id = dor.asset_id
   AND dif.market_id = dor.market_id
   AND dif.tf_key = dor.tf_key
JOIN FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
    ON a.asset_id = dor.asset_id
JOIN FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    ON m.market_id = dif.market_id
GROUP BY
    a.asset_equipment_class_name,
    m.market_district,
    dor.tf_key;;
  }


  dimension: asset_equipment_class_name {
    type: string
    sql: ${TABLE}.asset_equipment_class_name ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: year_trailing_district_class_utilization {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.district_unit_ute ;;
  }
}

view: year_trailing_region_class_utilization_agg {
  derived_table: {
    sql:
    -- New Query Preagg Region Ute
SELECT
    a.asset_equipment_class_name,
    m.market_region AS region_id,
    m.market_region_name AS region_name,
    dor.tf_key,
    -- Region-level rollup
    SUM(COALESCE(dor.days_on_rent, 0)) AS region_days_on_rent,
    SUM(COALESCE(dif.days_in_fleet, 0)) AS region_days_in_fleet,
    IFF(SUM(COALESCE(dif.days_in_fleet, 0)) <> 0,
        SUM(COALESCE(dor.days_on_rent, 0)) / SUM(COALESCE(dif.days_in_fleet, 0)),
        NULL) AS region_unit_ute
FROM FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC t1
JOIN FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_ON_RENT_ASSET_MARKET dor
    ON t1.tf_key = dor.tf_key
   AND t1.timeframe = 'annually'
   AND t1.start_date > '2023-01-01'
   AND t1.run_date = iff(date_trunc(month, current_date)=current_date, dateadd(month,-1,current_date()),date_trunc(month, current_date))
JOIN FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_IN_FLEET_ASSET_MARKET dif
    ON dif.asset_id = dor.asset_id
   AND dif.market_id = dor.market_id
   AND dif.tf_key = dor.tf_key
JOIN FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
    ON a.asset_id = dor.asset_id
JOIN FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    ON m.market_id = dif.market_id
GROUP BY
    a.asset_equipment_class_name,
    m.market_region,
    m.market_region_name,
    dor.tf_key;;
    }

    dimension: asset_equipment_class_name {
      type: string
      sql: ${TABLE}.asset_equipment_class_name ;;
    }

    dimension: region_id {
      type: string
      sql: ${TABLE}.region_id ;;
    }

    dimension: year_trailing_region_class_utilization {
      type: number
      value_format_name: percent_1
      sql: ${TABLE}.region_unit_ute ;;
    }
  }
