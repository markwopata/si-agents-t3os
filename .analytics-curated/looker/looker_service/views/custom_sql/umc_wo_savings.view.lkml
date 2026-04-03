view: umc_wo_savings {
  derived_table: {
    sql:
    with wo_tag as (
select
    work_order_id,
    ct.name
from es_warehouse.work_orders.work_order_company_tags woct
join es_warehouse.work_orders.company_tags ct
    using(company_tag_id)
where ct.company_id = 1854
and ct.name = 'UMC'
)

,wo_agg as (
select
    work_order_id,
    make,
    model,
    year,
    correction,
    datediff(day,date_created,date_completed) as down_time,
    sum(zeroifnull(expense)) as wo_expense,
    sum(zeroifnull(parts_cost)) as wo_parts,
    sum(zeroifnull(total_hours)) as wo_hours
from analytics.service.daily_work_order_info
where work_order_id not in (select work_order_id from wo_tag)
and work_order_type_name = 'General'
and date_completed is not null
and date_created >= {% parameter hist_wo_date %}
group by
    work_order_id,
    make,
    model,
    year,
    correction,
    date_created,
    date_completed
)

,hist_avg as (
select
    make,
    model,
    year,
    correction,
    avg(down_time) as avg_down_time,
    avg(wo_expense) as avg_expense,
    avg(wo_parts) as avg_parts,
    avg(wo_hours) as avg_hours
from wo_agg
group by
    make,
    model,
    year,
    correction
)

select
    wo.work_order_id,
    ot.name as originator_type,
    wo.description,
    wo.date_created,
    wo.date_completed,
    wo.asset_id,
    dwo.category,
    dwo.sub_category,
    dwo.class,
    dwo.make,
    dwo.model,
    dwo.year,
    dwo.complaint,
    dwo.cause,
    dwo.correction,
    dwo.problem_group,
    datediff(day,wo.date_created,wo.date_completed) as down_time,
    ha.avg_down_time,
    sum(zeroifnull(dwo.expense)) as wo_expense,
    ha.avg_expense,
    sum(zeroifnull(dwo.total_hours)) as wo_hours,
    ha.avg_hours,
    sum(zeroifnull(dwo.parts_cost)) as wo_parts,
    ha.avg_parts
from es_warehouse.work_orders.work_orders wo
left join analytics.service.daily_work_order_info dwo
    using(work_order_id)
join es_warehouse.work_orders.work_order_originators woo
    using(work_order_id)
join es_warehouse.work_orders.originator_types ot
    using(originator_type_id)
left join hist_avg ha
    using(make,model,year,correction)
where work_order_id in (select work_order_id from wo_tag)
and wo.date_completed is not null
group by
    wo.work_order_id,
    ot.name,
    wo.description,
    wo.date_created,
    wo.date_completed,
    wo.asset_id,
    dwo.category,
    dwo.sub_category,
    dwo.class,
    dwo.make,
    dwo.model,
    dwo.year,
    dwo.complaint,
    dwo.cause,
    dwo.correction,
    dwo.problem_group,
    ha.avg_down_time,
    ha.avg_expense,
    ha.avg_parts,
    ha.avg_hours;;
  }
  parameter: hist_wo_date {
    type: date
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: work_order_originator_type {
    type: string
    sql: ${TABLE}."ORIGINATOR_TYPE" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format_name: id
  }
  dimension: complaint {
    type: string
    sql: ${TABLE}."COMPLAINT" ;;
  }
  dimension: cause {
    type: string
    sql: ${TABLE}."CAUSE" ;;
  }
  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION" ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
  dimension: down_time {
    type: number
    sql: ${TABLE}."DOWN_TIME" ;;
  }
  dimension: expected_down_time {
    type: number
    sql: ${TABLE}."AVG_DOWN_TIME" ;;
  }
  dimension: saved_down_time {
    type: number
    sql: ${expected_down_time} - ${down_time} ;;
  }
  dimension: wo_expense {
    type: number
    sql: ${TABLE}."WO_EXPENSE" ;;
    value_format_name: usd
  }
  dimension: expected_expense {
    type: number
    sql: ${TABLE}."AVG_EXPENSE" ;;
    value_format_name: usd
  }
  dimension: saved_expense {
    type: number
    sql: ${expected_expense} - ${wo_expense} ;;
    value_format_name: usd
  }
  dimension: wo_hours {
    type: number
    sql: ${TABLE}."WO_HOURS" ;;
    value_format_name: decimal_2
  }
  dimension: expected_hours {
    type: number
    sql: ${TABLE}."AVG_HOURS" ;;
    value_format_name: decimal_2
  }
  dimension: saved_hours {
    type: number
    sql: ${expected_hours} - ${wo_hours} ;;
    value_format_name: decimal_2
  }
  dimension: wo_parts {
    type: number
    sql: ${TABLE}."WO_PARTS" ;;
    value_format_name: usd
  }
  dimension: expected_parts {
    type: number
    sql: ${TABLE}."AVG_PARTS" ;;
    value_format_name: usd
  }
  dimension: saved_parts {
    type: number
    sql: ${expected_parts} - ${wo_parts} ;;
    value_format_name: usd
  }
  measure: count_work_orders {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [drill*]
  }
  measure: total_saved_down_time {
    type: sum
    sql: ${saved_down_time} ;;
    drill_fields: [drill*]
  }
  measure: total_saved_expense {
    type: sum
    sql: ${saved_expense} ;;
    value_format_name: usd
    drill_fields: [drill*]
  }
  measure: total_saved_hours {
    type: sum
    sql: ${saved_hours} ;;
    value_format_name: decimal_2
    drill_fields: [drill*]
  }
  measure: total_saved_parts {
    type: sum
    sql: ${saved_parts} ;;
    value_format_name: usd
    drill_fields: [drill*]
  }
  set: drill {
    fields: [work_order_id,
            description,
            date_created_date,
            date_completed_date,
            asset_id,
            make,
            model,
            year,
            complaint,
            cause,
            correction,
            problem_group,
            down_time,
            expected_down_time,
            wo_hours,
            expected_hours,
            saved_hours,
            wo_parts,
            expected_parts,
            saved_parts,
            wo_expense,
            expected_expense,
            saved_expense
            ]
  }
}
