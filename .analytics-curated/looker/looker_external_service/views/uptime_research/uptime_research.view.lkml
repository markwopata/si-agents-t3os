view: uptime_research {
  derived_table: {
    sql: with wo_summary as (
        select
          wo.asset_id,
          date_trunc('month', wo.date_created) as month,
          count(distinct work_order_id) as wo_num,
          sum(date_part('epoch', wo.date_completed) - date_part('epoch',wo.date_created))/3600 as wo_time,
          (sum(date_part('epoch', wo.date_completed) - date_part('epoch', wo.date_created))/3600)*(1/3.) as wo_time_workday,
          coalesce(sum(case when wo.severity_level_id = 1 then 1 end),0) as wo_soft_down_count,
          coalesce(sum(case when wo.severity_level_id = 2 then 1 end),0) as wo_hard_down_count,
          m.company_id
        from work_orders.work_orders wo
        join work_orders.work_order_originators woo using(work_order_id)
        join markets m on branch_id = market_id
        join assets a on a.asset_id = wo.asset_id
        where
          m.company_id not in (1854,420)
          and originator_type_id in (1,4,5,6,8)
          and archived_date is null
          and asset_type_id = 2
        group by wo.asset_id, date_trunc('month', wo.date_created), m.company_id
      ),
      hourly_summary as (
        select
        asset_id,
        date_trunc('month' , to_timestamp(REPORT_RANGE:start_range)) as month,
        sum(timestampdiff('second',REPORT_RANGE:start_range::timestamp,REPORT_RANGE:end_range::timestamp) / 3600) as sum_in_hours
        from
          hourly_asset_usage hau
          join assets a using(asset_id)
        where
        --company_id = 50 and
          a.asset_type_id = 2
        group by date_trunc('month', to_timestamp(REPORT_RANGE:start_range)), asset_id
      ),
      series as (
      select
        (
        select
            count(*) as series
        from
        (
        select * from table(generate_series(
        '2020-01-01'::timestamp_tz,
        current_date::timestamp_tz,
        'day')
        )) days
        where
            dayname(series) not in ('Sat','Sun')) as workdays_in_month
      )
      select
      wo_summary.asset_id as wo_asset_id,
      hourly_summary.asset_id as trip_asset_id,
      wo_summary.month as wo_month,
      hourly_summary.month as trip_month,
      wo_summary.wo_time,
      hourly_summary.sum_in_hours,
      wo_summary.wo_num,
      wo_summary.wo_time_workday,
      case
      when hourly_summary.month is null then wo_summary.month
      else hourly_summary.month
      end as month,
      case
      when hourly_summary.asset_id is null then wo_summary.asset_id
      else hourly_summary.asset_id
      end as asset_id,
      wo_summary.wo_soft_down_count,
      wo_summary.wo_hard_down_count,
      wo_summary.company_id
      from
      wo_summary
      full outer join hourly_summary on wo_summary.month = hourly_summary.month and wo_summary.asset_id = hourly_summary.asset_id
      left join series t on true
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: wo_asset_id {
    type: number
    sql: ${TABLE}."WO_ASSET_ID" ;;
  }

  dimension: trip_asset_id {
    type: number
    sql: ${TABLE}."TRIP_ASSET_ID" ;;
  }

  dimension_group: wo_month {
    type: time
    sql: ${TABLE}."WO_MONTH" ;;
  }

  dimension: trip_month {
    type: date
    sql: ${TABLE}."TRIP_MONTH" ;;
  }

  dimension: wo_time {
    type: number
    sql: ${TABLE}."WO_TIME" ;;
  }

  dimension: sum_in_hours {
    type: number
    sql: ${TABLE}."SUM_IN_HOURS" ;;
  }

  dimension: wo_num {
    type: number
    sql: ${TABLE}."WO_NUM" ;;
  }

  dimension: wo_time_workday {
    type: number
    sql: ${TABLE}."WO_TIME_WORKDAY" ;;
  }

  dimension_group: month {
    type: time
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: wo_soft_down_count {
    type: number
    sql: ${TABLE}."WO_SOFT_DOWN_COUNT" ;;
  }

  dimension: wo_hard_down_count {
    type: number
    sql: ${TABLE}."WO_HARD_DOWN_COUNT" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_generation {
    type: time
    sql:coalesce(${wo_month_raw}, ${trip_month}) ;;
  }

  dimension: month_formatted {
    group_label: "Created" label: "Month"
    sql: ${month_month} ;;
    html: {{ rendered_value | append: "-01" | date: "%b %Y" }};;
  }

  dimension: last_day_of_month {
    type: date
    sql: last_day(${date_generation_raw}) ;;
  }

  dimension: first_day_of_month {
    type: date
    sql: date_trunc('month',${date_generation_raw}) ;;
  }

  dimension: workdays_in_month {
    type: number
    sql: DATEDIFF('day', ${first_day_of_month}, ${last_day_of_month}) + 1 -
          DATEDIFF('week', ${first_day_of_month}, DATEADD('day', 1, ${last_day_of_month})) -
          DATEDIFF('week', ${first_day_of_month}, ${last_day_of_month}) ;;
  }

  dimension: work_hours_in_month {
    type: number
    sql: ${workdays_in_month}*24 ;;
  }

  dimension: off {
    type: number
    # sql: (${workdays_in_month}*24) - (coalesce(${sum_in_hours}, 0) + coalesce(${wo_time_workday}, 0)) ;;
    sql: case when
        (coalesce(${sum_in_hours}, 0) + coalesce(${wo_time_workday}, 0)) > (${work_hours_in_month}) then 0
        else
        (${workdays_in_month}*24) - (coalesce(${sum_in_hours}, 0) + coalesce(${wo_time_workday}, 0))
        end ;;
  }

  measure: total_work_hours_in_month {
    type: sum
    sql: ${work_hours_in_month} ;;
  }

  dimension: downtime_percentage {
    type: number
    # sql: (coalesce(${wo_time_workday}::float, 0)/(${work_hours_in_month}))*100 ;;
    sql: (coalesce(case when ${wo_time_workday} > ${work_hours_in_month} then ${work_hours_in_month} - (${sum_in_hours}) else ${wo_time_workday}  end, 0)/(${work_hours_in_month}))*100 ;;
  }

  dimension: usage_percentage {
    type: number
    sql: (coalesce(${sum_in_hours}::float,0)/(${work_hours_in_month}))*100 ;;
  }

  dimension: off_percentage {
    type: number
    sql: (${work_hours_in_month} - (coalesce(${wo_time_workday},0) + coalesce(${sum_in_hours},0)))/(${workdays_in_month}*24)*100 ;;
  }

  measure: total_off_time {
    type: sum
    sql: coalesce(${off},0) ;;
    value_format_name: decimal_2
    # html: {{rendered_value}} | {{off_time_percentage._rendered_value}} of total ;;
  }

  measure: total_on_time {
    type: sum
    sql: coalesce(${sum_in_hours},0) ;;
    value_format_name: decimal_2
    # html: {{rendered_value}} | {{on_time_percentage._rendered_value}} of total ;;
  }

  measure: total_work_order_time {
    type: sum
    # sql: ${wo_time_workday} ;;
    sql: case when ${wo_time_workday} > ${work_hours_in_month} then ${work_hours_in_month} - (${sum_in_hours}) else ${wo_time_workday}  end ;;
    value_format_name: decimal_2
    # html: {{rendered_value}} | {{work_order_time_percentage._rendered_value}} of total ;;
  }

  measure: total_hours {
    type: sum
    sql: coalesce(${off},0) + coalesce(${sum_in_hours},0) + case when ${wo_time_workday} > ${work_hours_in_month} then ${work_hours_in_month} - (${sum_in_hours}) else coalesce(${wo_time_workday},0)  end ;;
  }

  measure: total_on_time_table {
    type: sum
    sql: ${sum_in_hours} ;;
    value_format_name: decimal_2
  }

  measure: total_work_order_time_table {
    type: sum
    # sql: ${wo_time_workday} ;;
    sql: case when ${wo_time_workday} > ${work_hours_in_month} then ${work_hours_in_month} - (${sum_in_hours}) else ${wo_time_workday}  end ;;
    value_format_name: decimal_2
  }

  measure: total_downtime_percentage {
    type: number
    sql: ${total_work_order_time}
          /
          case when coalesce(${total_hours},0) = 0 then null else coalesce(${total_hours},0) end  ;;
    value_format_name: percent_1
    # drill_fields: [work_orders_info*]
  }

  measure: total_work_orders {
    type: sum
    sql: ${wo_num} ;;
    # drill_fields: [work_orders_info*]
  }

  measure: total_soft_down_work_orders {
    type: sum
    sql: ${wo_soft_down_count} ;;
    # drill_fields: [work_orders_info*]
  }

  measure: total_hard_down_work_orders {
    type: sum
    sql: ${wo_hard_down_count} ;;
    # drill_fields: [work_orders_info*]
  }

  dimension: dimension_for_pie_chart {
    type: string
    sql: 'Work Order Breakdown';;
    html: &nbsp; ;;
  }

  measure: work_order_breakdown_string {
    type: number
    sql: ${total_hard_down_work_orders};;
    html: <font color="black">{{value}}</font> <font color="grey"> Ttl Hard Down WO </font> <font color="black">{{total_soft_down_work_orders._value}}</font> <font color="grey">Ttl Soft Down WO</font> ;;
  }

  measure: work_order_time_percentage {
    type: number
    sql: case when ${total_work_order_time} = 0 then null else ${total_work_order_time} end / case when ${total_hours} is null then null else ${total_hours} end ;;
    value_format_name: percent_1
  }

  measure: on_time_percentage {
    type: number
    sql: case when ${total_on_time} = 0 then null else ${total_on_time} end / case when ${total_hours} is null then null else ${total_hours} end ;;
    value_format_name: percent_1
  }

  measure: off_time_percentage {
    type: number
    sql: case when ${total_off_time} = 0 then null else ${total_off_time} end / case when ${total_hours} is null then null else ${total_hours} end ;;
    value_format_name: percent_1
  }

  measure: uptime_percentage {
    type: number
    sql: (${total_on_time} + ${total_off_time}) / case when (${total_on_time} + ${total_off_time} + ${total_work_order_time}) = 0 then null else (${total_on_time} + ${total_off_time} + ${total_work_order_time}) end ;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [
      wo_asset_id,
      trip_asset_id,
      wo_month_time,
      wo_time,
      sum_in_hours,
      wo_num,
      wo_time_workday,
      month_time,
      asset_id,
      wo_soft_down_count,
      wo_hard_down_count,
      company_id
    ]
  }
}
