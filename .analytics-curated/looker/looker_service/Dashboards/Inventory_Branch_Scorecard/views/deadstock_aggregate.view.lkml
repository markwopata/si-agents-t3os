#-----=====deadstock aggregate for the Inventory Branch Scorecard dashboard=====-----#
view: deadstock_aggregate {
  derived_table: {
    sql:
with generated_dates as (
    --12 months trailing end dates
    select last_day(dateadd(month,'-' || row_number() over (order by null),
                            dateadd(day, '+1', current_date())), 'month')                           as generated_date
    from table (generator(rowcount => 12))
), total_inventory as (
    select ibs.BRANCH_ID,
           ibs.TIMESTAMP::date                                                      as month,
           count(distinct ibs.PART_NUMBER)                                          as number_of_parts,
           sum(ibs.QUANTITY)                                                        as quantity_of_all_parts,
           round(sum(ibs.QUANTITY * wac.WEIGHTED_AVERAGE_COST),2)                   as total_inventory_value
    from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT                               as ibs
    join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS                     as wac
        on ibs.PART_ID = wac.PRODUCT_ID and
           ibs.STORE_ID = wac.INVENTORY_LOCATION_ID
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                                 as il
        on ibs.store_id = il.inventory_location_id
    join generated_dates                                                            as gd
        on ibs.TIMESTAMP::date = gd.generated_date
    left join ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS                         as tpi
        on tpi.part_id = ibs.part_id
    left join ES_WAREHOUSE.INVENTORY.PARTS                                          as p
        on ibs.part_id = p.part_id
    where ibs.timestamp like '% 17:0%' and
          ibs.store_id not in (432,6004,400,9814) and
          il.date_archived is null and
          wac.is_current = true and
          tpi.part_id is null and
          il.NAME not ilike '%tele%' and
          p.provider_id not in (select api.provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS as api)
    group by 1,2
-- ) select * from total_inventory where BRANCH_ID = 1 and month = '2025-03-31';
), total_deadstock as (
    select ds.MARKET_ID                                                             as market_id,
           ds.SNAP_DATE::date                                                       as month,
           round(sum(zeroifnull(dead_stock)),2)                                     as total_dead_value    --should not be used as a measure
    from ANALYTICS.PARTS_INVENTORY.DEADSTOCK_SNAPSHOT                               as ds
        join generated_dates                                                        as gd
            on ds.SNAP_DATE::date = gd.generated_date
    group by 1,2
)
-- select * from total_deadstock where market_id = 1 and month = '2025-03-31';
select market_id                                                                as market_id,
       date_trunc('month',gd.generated_date)                                    as month,
       ti.total_inventory_value,
       tds.total_dead_value,
--        we want 0% here, so we use the inverted_ratio as the basis for the overall score
       round(total_dead_value/nullifzero(total_inventory_value),4)              as ratio,
       round((1-ratio) * {% parameter weight %},2)                                                 as score
from generated_dates                                                            as gd
join total_inventory                                                          as ti
    on gd.generated_date = ti.month
join total_deadstock                                                          as tds
    on tds.market_id = ti.BRANCH_ID and
       gd.generated_date = tds.month
order by market_id, month;;
  }
  label: "Deadstock Ratio"
  dimension: pkey {
    type: string
    hidden: yes
    primary_key: yes
    sql: CONCAT(${month}, ${market_id});;
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: total_inventory_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_INVENTORY_VALUE" ;;
  }
  dimension: total_dead_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_DEAD_VALUE" ;;
  }
  dimension: ratio {
    type: number
    value_format_name: percent_2
    sql: COALESCE(GREATEST(${TABLE}."RATIO",0),0) ;;
  }
  parameter: weight {
    hidden: yes
    default_value: "2"
  }
  dimension: score {
    type: number
    value_format: "0.00"
    sql: COALESCE(LEAST(${TABLE}."SCORE",{% parameter weight %}),{% parameter weight %}) ;;
  }
  measure: ratio_avg_last_1_month {
    type: average
    value_format_name: percent_2
    sql: case when ${inventory_branch_scorecard.is_last_1_month} then ${ratio} else null end;;
  }
  measure: ratio_avg_last_3_months {
    type: average
    value_format_name: percent_2
    sql: case when ${inventory_branch_scorecard.is_last_3_months} then ${ratio} else null end;;
  }
  measure: ratio_avg_last_6_months {
    type: average
    value_format_name: percent_2
    sql: case when ${inventory_branch_scorecard.is_last_6_months} then ${ratio} else null end;;
  }
  measure: ratio_avg_last_12_months {
    type: average
    value_format_name: percent_2
    sql: case when ${inventory_branch_scorecard.is_last_12_months} then ${ratio} else null end;;
  }
  measure: score_avg_last_1_month {
    type: average
    value_format: "0.00"
    html: {{score_avg_last_1_month._rendered_value}} / {{ratio_avg_last_1_month._rendered_value}} ;;
    sql:  case when ${inventory_branch_scorecard.is_last_1_month} then ${score} else null end;;
  }
  measure: score_avg_last_3_months {
    type: average
    value_format: "0.00"
    html: {{score_avg_last_3_months._rendered_value}} / {{ratio_avg_last_3_months._rendered_value}} ;;
    sql:  case when ${inventory_branch_scorecard.is_last_3_months} then ${score} else null end;;
  }
  measure: score_avg_last_6_months {
    type: average
    value_format: "0.00"
    html: {{score_avg_last_6_months._rendered_value}} / {{ratio_avg_last_6_months._rendered_value}} ;;
    sql:  case when ${inventory_branch_scorecard.is_last_6_months} then ${score} else null end;;
  }
  measure: score_avg_last_12_months {
    type: average
    value_format: "0.00"
    html: {{score_avg_last_12_months._rendered_value}} / {{ratio_avg_last_12_months._rendered_value}} ;;
    sql:  case when ${inventory_branch_scorecard.is_last_12_months} then ${score} else null end;;
  }
}
