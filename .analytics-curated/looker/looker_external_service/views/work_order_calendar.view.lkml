view: work_order_calendar {
  derived_table: {
    sql:
      select
         -- ds.day,
          wo.work_order_id,
          wo.urgency_level_name,
          wo.scheduled_date::date as start_date,
          case when coalesce(wo.due_date::date, dateadd(day,1,current_date())) = wo.scheduled_date::date then dateadd(day,1,coalesce(wo.due_date::date, dateadd(day,1,current_date()))) else coalesce(wo.due_date::date, dateadd(day,1,current_date())) end as end_date,
          woa.user_id,
          concat(u.first_name,' ',u.last_name) as user_assigned_to_wo,
          u.company_id
      from
          -- date_series ds
          -- join on ds.day between wo.scheduled_date::date AND wo.due_date::date
          work_orders.work_orders wo
          left join work_orders.work_order_user_assignments woa on wo.work_order_id = woa.work_order_id
          left join es_warehouse.public.users u on woa.user_id = u.user_id
      where
          scheduled_date is not null
          and u.company_id = 1854
       ;;
  }

  # with date_series as (
  #     select
  #     series::date as day
  #     from table
  #     (generate_series(
  #     convert_timezone('America/Chicago', DATEADD('day', -14, CURRENT_DATE()))::timestamp_tz,
  #     convert_timezone('America/Chicago', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE())))::timestamp_tz,
  #     'day')
  #     ))

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: urgency_level_name {
    type: string
    sql: ${TABLE}."URGENCY_LEVEL_NAME" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_assigned_to_wo {
    type: string
    sql: coalesce(${TABLE}."USER_ASSIGNED_TO_WO",'Test') ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: test {
    type: string
    sql: concat(${user_assigned_to_wo},' ',${urgency_level_name}) ;;
  }

  dimension: test_two {
    type: string
    sql: concat(${urgency_level_name},' ',${work_order_id}) ;;
  }


  set: detail {
    fields: [
      day,
      work_order_id,
      urgency_level_name,
      start_date,
      end_date,
      user_id,
      user_assigned_to_wo,
      company_id
    ]
  }
}
