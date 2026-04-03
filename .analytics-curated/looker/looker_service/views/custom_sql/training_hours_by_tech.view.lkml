view: training_hours_by_tech {
  derived_table: {
    sql: with enrollmenthistory as (
select
    *,
    case
        when enrollment_total_time_in_course ilike '%s%' then trim(enrollment_total_time_in_course,'s') / 60
        else 60 * trim(split_part(enrollment_total_time_in_course,' ',1),'h') + trim(split_part(enrollment_total_time_in_course,' ',2),'m')
    end as total_minutes
from analytics.docebo.enrollment_history
)

,count_tech as (
select
    date(_es_update_timestamp) as the_date,
    market_id,
    count(distinct employee_id) as count_tech
from analytics.payroll.company_directory_vault
where employee_status = 'Active'
and employee_title ilike '%Tech%'
group by the_date, market_id
)

,hours_of_training as (
select
    u.market_id,
    date(h.enrollment_date_complete) date_complete,
    sum(total_minutes) / 60 as training_hours,
    sum(duration) / 60 as duration_hours,
    training_hours + duration_hours as total_hours
from analytics.docebo.COURSES c
join enrollmenthistory h
    on c.UIDCOURSE=h.COURSE_UIDCOURSE
left join ANALYTICS.payroll.company_directory u
    on to_varchar(u.employee_id) = to_varchar(h.user_userid)
where COURSE_TYPE = 'classroom'
and u.employee_title ilike '%Tech%'
group by u.market_id, date_complete
having (training_hours != 0 or duration_hours != 0)
)

select
    ct.market_id,
    --month(ct.the_date) as the_month,
    --year(ct.the_date) as the_year,
    --coalesce(sum(ht.total_hours),0) as training_hours,
    --avg(ct.count_tech) as average_tech_headcount
    ct.the_date,
    coalesce(ht.total_hours,0) as training_hours,
    ct.count_tech as average_tech_headcount
from count_tech ct
left join hours_of_training ht
    on ht.date_complete = ct.the_date
    and ct.market_id = ht.market_id;;
# group by the_month, the_year, ct.market_id;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  # dimension: the_month {
  #   type: date_month
  #   sql: ${TABLE}."THE_MONTH" ;;
  # }

  # dimension: the_year {
  #   type: date_year
  #   sql: ${TABLE}."THE_YEAR" ;;
  # }

  dimension_group: the_date {
    type: time
    timeframes: [raw,date,day_of_month,time,month,quarter,year]
    sql: ${TABLE}."THE_DATE" ;;
  }

  dimension: training_hours {
    type: number
    sql: ${TABLE}."TRAINING_HOURS" ;;
  }

  dimension: tech_headcount {
    type: number
    sql: ${TABLE}."AVERAGE_TECH_HEADCOUNT" ;;
  }

  measure: sum_training_hours {
    type: sum
    sql: ${training_hours} ;;
  }

  measure: sum_tech_headcount {
    type: sum
    filters: [the_date_day_of_month: "1"]
    sql: ${tech_headcount} ;;
  }

  measure: training_hours_per_tech {
    type: number
    drill_fields: [market_id,training_hours_per_tech,training_hours,tech_headcount]
    sql: ${sum_training_hours} / ${sum_tech_headcount};;
  }
}
