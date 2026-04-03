view: bin_locations_aggregate {
  derived_table: {
    sql:
with hist_bin as (
    select PARAMETERS__ENTITY_ID store_part_id,
           PARAMETERS__CHANGES__LOCATION bin,
           date_created start_date,
           coalesce(lead(date_created) over (partition by PARAMETERS__ENTITY_ID order by date_created asc),'9999-01-01') end_date
    from analytics.intacct_models.stg_es_warehouse_inventory__command_audit
    where command = 'UpdateStorePart'
      and bin != ''
    order by store_part_id, start_date
)
select MARKET_ID                                                                as branch_id,
       date_trunc('month',TIMESTAMP)::date                                      as month,
       --i.part_id,
       count(i.PART_ID)                                                         as number_of_parts, --now that this is not distinct, it is really number of bin opportunities
       sum(iff(b.bin is not null,1,0))                                          as set_bin_locations,
--        we want 100% use here, so we use the ratio as the basis for the overall score
       round(zeroifnull(set_bin_locations/nullifzero(number_of_parts)),4)       as ratio,
       round(ratio * {% parameter weight %},2)                                                      as score
from ANALYTICS.INTACCT_MODELS.INVENTORY_BALANCE_MONTHLY_SNAPSHOT i
join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                                 as il
        on i.MARKET_ID = il.BRANCH_ID
left join hist_bin b
    on i.store_part_id = b.store_part_id
   and i.timestamp >= b.start_date
   and i.timestamp < b.end_date
where i.QUANTITY > 0 and il.DEFAULT_LOCATION = true
group by 1,2
order by 1,2;;

# select MARKET_ID                                                                as branch_id,
# --        STORE_NAME,
#       date_trunc('month',TIMESTAMP)::date                                      as month,
#       ibms.PART_ID,
#       count(distinct ibms.PART_ID)                                             as number_of_parts,
#       sum(iff(sp.LOCATION is null,1,0))                                        as unset_bin_locations,
#       sum(iff(sp.LOCATION is not null,1,0))                                    as set_bin_locations,
# --        we want 0% UNSET bin locations, so we use the ratio as the basis for the overall score
#       round(zeroifnull(set_bin_locations/nullifzero(number_of_parts)),4)       as ratio,
#       round(ratio * .25,2)                                                     as score,
# from ANALYTICS.INTACCT_MODELS.INVENTORY_BALANCE_MONTHLY_SNAPSHOT                as ibms
# join ES_WAREHOUSE.INVENTORY.STORES                                              as s
#     on ibms.STORE_ID = s.STORE_ID
# join ES_WAREHOUSE.INVENTORY.STORE_PARTS                                         as sp
#     on ibms.STORE_PART_ID = sp.STORE_PART_ID
# --looking at parts that are at the store for the month this ran.  Doesn't necessarily capture all parts but should help eliminate parts that aren't kept in stock
# where ibms.QUANTITY > 0
# and ibms.part_id = 125676
# and ibms.market_id = 1
# and month = '2024-10-01'
# group by 1,2,3
# order by MARKET_ID, month, part_id;;
  }
  label: "Bin Location Assignment"
  dimension: pkey {
    type: string
    hidden: yes
    primary_key: yes
    sql: CONCAT(DATE_TRUNC('month', ${TABLE}.month), ${TABLE}.branch_id) ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: number_of_parts {
    type: number
    sql: ${TABLE}."NUMBER_OF_PARTS" ;;
  }
  dimension: unset_bin_locations {
    type: number
    sql: ${TABLE}."UNSET_BIN_LOCATIONS" ;;
  }
  dimension: ratio {
    type: number
    value_format_name: percent_2
    sql: COALESCE(LEAST(${TABLE}."RATIO",1),1) ;;
  }
  parameter: weight {
    hidden: yes
    default_value: ".5"
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
