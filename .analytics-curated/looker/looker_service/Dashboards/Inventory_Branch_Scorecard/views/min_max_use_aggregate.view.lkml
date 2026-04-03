view: min_max_use_aggregate {
  derived_table: {
    sql:
with flag_parts as (
    select MARKET_ID,
           date_trunc('month',TIMESTAMP)::date                                      as month,
           count(distinct PART_ID)                                                  as number_of_parts,
           number_of_parts * 2                                                      as possible_points,
           case
               when min is not null and max is not null then 2
               when min is not null or max is not null then 1
               else 0
           end                                                                      as points
    from ANALYTICS.INTACCT_MODELS.INVENTORY_BALANCE_MONTHLY_SNAPSHOT                as ibms
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                                 as il
        on ibms.MARKET_ID = il.BRANCH_ID
    where QUANTITY > 0 and il.DEFAULT_LOCATION = true
    group by MARKET_ID, il.default_location, part_id, month, min, max
)
select fp.MARKET_ID                                                                 as branch_id,
       fp.month,
       sum(number_of_parts)                                                         as total_number_of_parts,
       sum(fp.possible_points)                                                      as total_possible_points,
       sum(fp.points)                                                               as total_store_points,
--        we want 100% use here, so we use the ratio as the basis for the overall score
       round(zeroifnull(total_store_points/nullifzero(total_possible_points)),4)    as ratio,
       round(ratio * {% parameter weight %},2)                                                         as score
from flag_parts                                                                     as fp
group by fp.MARKET_ID, month
order by fp.MARKET_ID, month;;
  }
  label: "Min / Max Assignments"
  dimension: pkey {
    type: string
    hidden: yes
    primary_key: yes
    sql: CONCAT(${month}, ${branch_id});;
  }
  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: total_number_of_parts {
    type: number
    sql: ${TABLE}."TOTAL_NUMBER_OF_PARTS" ;;
  }
  dimension: total_possible_points {
    type: number
    sql: ${TABLE}."TOTAL_NUMBER_OF_PARTS" ;;
  }
  dimension: total_store_points {
    type: number
    sql: ${TABLE}."TOTAL_STORE_PARTS" ;;
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
