view: parts_needed_wo_aggregate {
  derived_table: {
    sql:
with generated_dates as (
    --12 months trailing end dates
    //todo: need to make sure we evaluate on the last day
    select last_day(dateadd(month,'-' || row_number() over (order by null),
                            dateadd(day, '+1', current_date())), 'month')                           as generated_date
    from table (generator(rowcount => 12))
), tag_dates as (
    select ca.PARAMETERS:work_order_id                                                              as work_order_id,
           ca.PARAMETERS:tag_name                                                                   as tag_name,
           ca.COMMAND,
           ca.PARAMETERS,
--         Tag Applied Date (TAD), Tag Removed Date (TRD), wo.date_completed (LCD) all used to get to the number of
--         days a tag was applied.  If it wasn't removed before closing the WO, then the date closed is the last day.
--         If neither has happened yet, then we calculate to today's date.
           ca.DATE_CREATED                                                                          as tad,
           lead(ca.DATE_CREATED) over (partition by ca.parameters:work_order_id,tag_name
                                       order by ca.DATE_CREATED asc)                                as trd,
           wo.date_completed,
           //TODO:  Do we penalize here for a work order still being tagged after closing?
           least(coalesce(trd,wo.date_completed),coalesce(wo.date_completed,current_date))          as calculated_last_tag_date,
           datediff(days, tad, calculated_last_tag_date)                                            as tagged_days
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT                                                          as ca
        join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS                                                   as wo
            on ca.PARAMETERS:work_order_id = wo.work_order_id
    where ca.COMMAND in ('DisassociateWorkOrderTag',
                         'AssociateCompanyTag',
                         'UpdateTag',
                         'CreateAndAssociateCompanyTag') and
          ca.PARAMETERS:tag_name ilike '%Parts Needed%'
--      and BRANCH_ID = 1
  qualify tagged_days > 7
)
select wo.BRANCH_ID,
       date_trunc(month, gd.generated_date) month, --this is the field that would now be the month to plot
       count(distinct wo.work_order_id) total_open_wos,
       count(distinct iff(td.work_order_id is null, null,wo.work_order_id)) total_parts_needed_wos,
       round(zeroifnull(total_parts_needed_wos/nullifzero(total_open_wos)),4)                   as ratio, --we should be showing the ratio as the true metric and doing the inversion behind the score
       round((1-ratio) * {% parameter weight %},2)                                              as score
from generated_dates                                                                            as gd
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS                                                   as wo
        on gd.generated_date >= wo.date_created and gd.generated_date < coalesce(wo.date_completed, current_date)
    left join tag_dates                                                                         as td
        on wo.WORK_ORDER_ID = td.work_order_id and
           gd.generated_date >= td.tad and
           gd.generated_date < td.calculated_last_tag_date
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE                                                   as aa
        on wo.ASSET_ID = aa.ASSET_ID
where wo.archived_date is null
    and (command != 'DisassociateWorkOrderTag' or command is null)
    group by 1,2
    order by 1,2;;
  }
  label: "Work Orders Tagged Parts Needed > 7 days"
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
  dimension: total_open_wos {
    type: number
    sql: ${TABLE}."TOTAL_OPEN_WOS" ;;
  }
  dimension: parts_needed_wos {
    type: number
    sql: ${TABLE}."PARTS_NEEDED_WOS" ;;
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
