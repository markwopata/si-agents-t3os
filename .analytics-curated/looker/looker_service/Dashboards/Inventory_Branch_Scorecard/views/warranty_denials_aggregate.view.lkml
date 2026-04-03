view: warranty_denials_aggregate {
  #sql_table_name: ANALYTICS.WARRANTIES.WARRANTY_INVOICES ;;
  derived_table: {
    sql:
with monthly_ttm as (
  select wiai.BRANCH_ID,
         date_trunc('month', wiai.DATE_CREATED)::DATE                     as created_month,
         sum(iff(wi.DENIAL_CODE = '2',1,0))                               as parts_denials,
         count(wi.WORK_ORDER_NUMBER)                                      as total_denials,
  from ${warranty_invoices.SQL_TABLE_NAME}                                as wi
    join ${warranty_invoice_asset_info.SQL_TABLE_NAME}                    as wiai
      on wiai.work_order_id = wi.work_order_number
  group by 1,2
)
select d.market_id                                                        as branch_id,
       d.month                                                            as month,
       sum(zeroifnull(parts_denials)) as parts_denials_last_12_months,
       sum(zeroifnull(total_denials)) as total_denials_last_12_months,
--        we want 0% here, so we use the inverted_ratio as the basis for the overall score
       round(parts_denials_last_12_months/nullifzero(total_denials_last_12_months),4)   as ratio,
       round((1-ratio) * {% parameter weight %},2)                        as score
from ${market_region_xwalk_and_dates.SQL_TABLE_NAME}                      as d
left join monthly_ttm                                                     as mttm
    on d.market_id = mttm.branch_id and
       mttm.created_month <= month and
       mttm.created_month >= dateadd(month,-12,month)
group by 1,2;;
  }
  label: "Parts Warranty Denials"
  dimension: pkey {
    type: string
    hidden: yes
    primary_key: yes
    sql: CONCAT(DATE_TRUNC('month', ${TABLE}.month), ${TABLE}.branch_id) ;;
  }
  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  dimension: parts_denials_last_12_months {
    type: number
    sql: ${TABLE}."PARTS_DENIALS_LAST_12_MONTHS" ;;
  }
  dimension: total_denials_last_12_months {
    type: number
    sql: ${TABLE}."TOTAL_DENIALS_LAST_12_MONTHS" ;;
  }
  dimension: ratio {
    type: number
    value_format_name: percent_2
    sql: COALESCE(GREATEST(${TABLE}."RATIO",0),0) ;;
  }
  parameter: weight {
    hidden: yes
    default_value: "1"
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
