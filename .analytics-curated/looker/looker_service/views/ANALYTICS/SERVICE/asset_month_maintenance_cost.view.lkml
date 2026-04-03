view: asset_month_maintenance_cost {
  sql_table_name: "ANALYTICS"."SERVICE"."ASSET_MONTH_MAINTENANCE_COST" ;;
filter: date_filter {
  type: date
}
  dimension: filter_start{
    type: date
    sql: {% date_start date_filter %} ;;
  }

  dimension: filter_end{
    type: date
    sql: {% date_end date_filter %}-1 ;;
  }
  dimension_group: diff_months_filter {
    type: duration
    sql_start: {% date_start date_filter %};;
    sql_end: {% date_end date_filter %};;
    intervals: [month]
    }
  dimension: asset_age {
    type: number
    sql: ${TABLE}."ASSET_AGE" ;;
  }
  measure: asset_hours_consumed {
    type: sum
    sql: ${TABLE}."ASSET_HOURS_CONSUMED" ;;
  }
  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }
  measure: asset_month_portion {
    type: sum
    sql: ${TABLE}."ASSET_MONTH_PORTION" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  measure: class_daily_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CLASS_DAILY_REVENUE" ;;
  }
  measure: maintenance_cost {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COST_TO_OWN" ;;
  }
  measure: cost_per_hour {
    type: number
    sql: ${maintenance_cost}/nullifzero(${asset_hours_consumed}) ;;
  }
  measure: customer_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CUSTOMER_REVENUE" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  measure: failure_days {#time between failures summed to use as numerator in mean time btwn failures
    type: sum
    sql: ${TABLE}."FAILURE_DAYS" ;;
  }
  measure: hard_down_days {
    type: sum
    sql: ${TABLE}."HARD_DOWN_DAYS" ;;
  }
  measure: labor_cost {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."LABOR_COST" ;;
  }
  measure: labor_hours {
    type: sum
    sql: ${TABLE}."LABOR_HOURS" ;;
  }
  measure: lost_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."LOST_REVENUE" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: make_model {
    type: string
    sql:${make}||' '||${model} ;;
  }
  dimension_group: month_group {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH_GROUP" ;;
  }
  measure: oec {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."OEC" ;;
  }
  measure: proportional_oec{
    type: number
    value_format_name: usd_0
    sql: ${oec}/nullifzero(${asset_month_portion}) ;;
  }
  measure: parts_cost {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PARTS_COST" ;;
  }
  measure: parts_delays {#summed to use as numerator in mean time to repair
    type: sum
    sql: ${TABLE}."PARTS_DELAYS" ;;
  }
  measure: rental_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  measure: repair_wo_count { #to be used as denominator in mean time to repair
    type: sum
    sql: ${TABLE}."REPAIR_WO_COUNT" ;;
  }
  measure: tech_days {#summed to use as numerator in mean time to repair
    type: sum
    sql: ${TABLE}."TECH_DAYS" ;;
  }
  measure: warranty_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."WARRANTY_REVENUE" ;;
  }
  measure: wo_count_failures {#to be used as denominator in mean time btwn failures
    type: sum
    sql: ${TABLE}."WO_COUNT_FAILURES" ;;
  }
  measure: mean_time_between_failures {
    type: number
    sql: ${failure_days}/nullifzero(${wo_count_failures}) ;;
  }
  measure: wo_durations {#summed to use as numerator in mean time to repair
    type: sum
    sql: ${TABLE}."WO_DURATIONS" ;;
  }
  measure: mttr_wo_duration { #one version of mean time to repair
    type: number
    sql: ${wo_durations}/nullifzero(${repair_wo_count}) ;;
  }
  measure: mttr_tech_days { #one version of mean time to repair
    type: number
    sql: ${tech_days}/nullifzero(${repair_wo_count}) ;;
  }
  measure: mttr_parts_delays { #one version of mean time to repair
    type: number
    sql: ${parts_delays}/nullifzero(${repair_wo_count}) ;;
  }
  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
  }
  measure: distinct_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }
   #need to validate the below prior to using
  # measure: maintenance_cost_per_asset {#isnt taking late entry into account this way
  #   type: number
  #   value_format_name: usd_0
  #   sql: ${maintenance_cost}/${distinct_assets} ;;}

  measure: maintenance_cost_per_asset_month { #best for monthly trend visuals, already accounts for late entry
    type: number
    value_format_name: usd_0
    sql: ${maintenance_cost}/nullifzero(${asset_month_portion}) ;;
  }
measure: wac_per_asset {#specifically for use when comparing per asset cost on a non-monthly basis. scales to the selected period
  #ex. if an asset is present for 2/3 months in the filter, the costs will be scaled up for properly comparing to those that were present the whole time
  type: number
  value_format_name: usd_0
  sql: ${maintenance_cost}*(${months_diff_months_filter}/nullifzero(${asset_month_portion})) ;;
}
measure: lost_revenue_per_asset {#do not use at monthly level
  type: number
  value_format_name: usd_0
  sql: ${lost_revenue}*(${months_diff_months_filter}/nullifzero(${asset_month_portion}))  ;;
}
  measure: lost_revenue_per_asset_month { #best for monthly trend visuals, already accounts for late entry
    type: number
    value_format_name: usd_0
    sql: ${lost_revenue}/nullifzero(${asset_month_portion}) ;;
  }

  dimension: selected_hierarchy_dimension {
    type: string
    sql: {% if model._in_query %}
           ${year}
         {% elsif make._in_query %}
          ${model}
         {% elsif class._in_query %}
           ${make}
         {% else %}
           ${class}
         {% endif %};;
  }
}

view: vendor_month_maintenance_score {
  derived_table: {
    sql:
with agg as (
    select v.mapped_vendor_name
        , v.vendor_type
        , sum(zeroifnull(oec)) / 12 as avg_oec
        , sum(zeroifnull(labor_cost)) as labor_cost
        , sum(zeroifnull(cost_to_own)) as cost_to_own
    from ${asset_month_maintenance_cost.SQL_TABLE_NAME} ammc
    join (
            select vendorid
                , vendor_name
                , mapped_vendor_name
                , vendor_type
                , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
                , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
            from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
            where primary_vendor ilike 'yes') v
        on upper(join1) = ammc.make or upper(join2) = ammc.make
    where ammc.month_group >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1, 2
    having avg_oec > 0
)

select tvm.vendorid
    -- , tvm.mapped_vendor_name
    , a.labor_cost / nullifzero(a.avg_oec) as vendor_labor_cost_oec
    , sum(pa.labor_cost) / sum(pa.avg_oec) as peers_labor_cost_oec
    , least(coalesce(peers_labor_cost_oec, 1), 0.01) as labor_cost_oec_target
    , iff((labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * 1.25 > 1.25, 1.25, (labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * 1.25) as labor_cost_oec_score
    , iff((labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * 10 > 10, 10, (labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * 10) as labor_cost_oec_score10

    , a.cost_to_own / nullifzero(a.avg_oec) as vendor_cost_to_own_oec
    , sum(pa.cost_to_own) / sum(pa.avg_oec) as peers_cost_to_own_oec
    , least(coalesce(peers_cost_to_own_oec, 1), 0.02) as cost_to_own_oec_target
    , iff((cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * 1.25 > 1.25, 1.25, (cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * 1.25) as cost_to_own_oec_score
    , iff((cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * 10 > 10, 10, (cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * 10) as cost_to_own_oec_score10
from agg a
left join agg pa
    on pa.mapped_vendor_name <> a.mapped_vendor_name
        and pa.vendor_type = a.vendor_type
left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
    on tvm.primary_vendor ilike 'yes'
        and tvm.mapped_vendor_name = a.mapped_vendor_name
group by 1, 2, vendor_cost_to_own_oec;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_labor_cost_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.vendor_labor_cost_oec ;;
  }
  dimension: peers_labor_cost_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.peers_labor_cost_oec ;;
  }
  dimension: labor_cost_oec_target {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.labor_cost_oec_target ;;
  }
  dimension: labor_cost_oec_score {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.labor_cost_oec_score ;;
  }
  dimension: labor_cost_oec_score10 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.labor_cost_oec_score10 ;;
  }

  dimension: vendor_cost_to_own_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.vendor_cost_to_own_oec ;;
  }
  dimension: peers_cost_to_own_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.peers_cost_to_own_oec ;;
  }
  dimension: cost_to_own_oec_target {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.cost_to_own_oec_target ;;
  }
  dimension: cost_to_own_oec_score {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.cost_to_own_oec_score ;;
  }
  dimension: cost_to_own_oec_score10 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.cost_to_own_oec_score10 ;;
  }
}
