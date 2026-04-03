view: purchase_order_aggregate {
  derived_table: {
    sql:
with generated_dates as (
    --12 months trailing end dates
    select last_day(dateadd(month,'-' || row_number() over (order by null),
                            dateadd(day, '+1', current_date())), 'month')           as generated_date
    from table (generator(rowcount => 12))
), po_dates as (
    select po.requesting_branch_id,
           po.purchase_order_id,
           po.PURCHASE_ORDER_NUMBER,
           po.date_created::date date_created,
           coalesce(el.date_created::date,iff(po.status='OPEN',current_date,null)) date_completed
       from PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
       left join (select purchase_order_id,
                         max(date_created) date_created
                  from PROCUREMENT.PUBLIC.PURCHASE_ORDER_EVENT_LOGS
                  where event_type = 'CLOSED'
                  group by 1) el
       on po.purchase_order_id = el.purchase_order_id
       where po.date_archived is null and
             date_completed is not null
-- ) select * from po_dates where REQUESTING_BRANCH_ID = 13575 and date_created <= '2024-11-30' and date_completed > '2024-11-30';
),total_pos as (
    select pod.REQUESTING_BRANCH_ID,
           //todo need to change this to as last of the month calculation
           date_trunc('month',gd.generated_date)::date              as month,
           count(distinct purchase_order_id)                        as num_of_pos
    from generated_dates                                            as gd
    join po_dates                                                   as pod
        on gd.generated_date >= pod.date_created and
           gd.generated_date < pod.date_completed
    group by 1,2
    order by 1,2
-- ) select * from total_open_pos where REQUESTING_BRANCH_ID = 13481 and month = '2025-03-01';
), total_pos_7_days as (
    select pod.REQUESTING_BRANCH_ID,
           //todo need to change this to as last of the month calculation
           date_trunc('month',gd.generated_date)::date              as month,
           count(distinct purchase_order_id)                        as num_of_pos
    from generated_dates                                            as gd
    join po_dates                                                   as pod
        on gd.generated_date >= pod.date_created and
           gd.generated_date < pod.date_completed
    where datediff('day',pod.DATE_CREATED,gd.generated_date) > 7 and
          to_char(pod.PURCHASE_ORDER_NUMBER) not in (select distinct EQUIPMENTSHARE_PO_NUMBER from ANALYTICS.MONDAY.PART_BACK_ORDER_REQUESTS_BOARD)
    group by 1,2
    order by 1,2
)
select topo.REQUESTING_BRANCH_ID                                            as branch_id,
       topo.month,
       topo.num_of_pos                                                      as total_pos,
       topo7.num_of_pos                                                     as total_pos_7_days,
       round(zeroifnull(total_pos_7_days/nullifzero(total_pos)),4)          as ratio,
--        we want 0% here, so we use the inverted_ratio as the basis for the overall score
       round((1-ratio) * {% parameter weight %},2)                                               as score
from total_pos                                                              as topo
left join total_pos_7_days                                                  as topo7
    on topo.REQUESTING_BRANCH_ID = topo7.REQUESTING_BRANCH_ID and
       topo.month = topo7.month
-- where branch_id = 109984 -- Rapid City, SD
group by 1,2,3,4
order by 1,2;;
  }
  label: "Purchase Orders open > 7 Days"
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
