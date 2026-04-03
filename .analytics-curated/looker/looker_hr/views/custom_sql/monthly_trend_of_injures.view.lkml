view: monthly_trend_of_injures {
  derived_table: {
    sql: with incidents_per_market as (
          select
              count(wii._row) as incidents,
              date(wii.date_of_injury) as the_date,
              wii.market_id
          from analytics.claims.wc_injuries_internal as wii
          group by the_date, wii.market_id
          ),

          time as (
          select
              date(te.end_date) as the_date,
              sum(datediff(second,te.start_date,te.end_date)/3600) as time,
              u.branch_id
          from es_warehouse.time_tracking.time_entries as te
          left join es_warehouse.public.users as u
              on u.user_id = te.user_id
          where upper(te.approval_status) = 'APPROVED'
          group by the_date, u.branch_id
          )

          select
              t.the_date,
              t.branch_id as market_id,
              coalesce(i.incidents,0) as incident,
              t.time as labor_hours
          from time as t
          left join incidents_per_market as i
              on i.the_date = t.the_date
              and i.market_id = t.branch_id ;;
  }

  dimension_group: the_date {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: ${TABLE}."THE_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: incidents {
    type: number
    sql: ${TABLE}."INCIDENT" ;;
  }

  dimension: labor_hours {
    type: number
    sql: ${TABLE}."LABOR_HOURS" ;;
  }

  measure: sum_incidents {
    type: sum
    sql: ${incidents} ;;
  }

  measure: sum_labor_hours {
    type: sum
    sql: ${labor_hours} ;;
  }

  measure: labor_hours_between_injure{
    type: number
    sql: coalesce(${sum_labor_hours} / nullif(${sum_incidents},0),${sum_labor_hours});;
    drill_fields: [market_id, markets.name, incidents, labor_hours_between_injure]
  }

}
